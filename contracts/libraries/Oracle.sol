// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.5.0 <0.8.0;

/// @title Oracle
/// @notice 提供价格和流动性数据，适用于各种各样的系统设计
/// @dev 存储的预言机数据实例（即“观测值”）收集在预言机数组中
/// 每个池子初始化时，预言机数组的长度为 1。任何人都可以支付 SSTORE 的费用来增加
/// 预言机数组的最大长度。当数组被完全填满时，才会加入新的槽位。
/// 当预言机数组的全部长度都被填满后，观测值会被覆盖。
/// 无论预言机数组的长度如何，都可以通过向 observe() 传入 0 来获取最近的观测值
library Oracle {
    struct Observation {
        // 该观测值的区块时间戳
        uint32 blockTimestamp;
        // tick 累加器，即 tick * 自池子首次初始化以来经过的时间
        int56 tickCumulative;
        // 每单位流动性秒数，即自池子首次初始化以来经过的秒数 / max(1, liquidity)
        uint160 secondsPerLiquidityCumulativeX128;
        // 该观测值是否已初始化
        bool initialized;
    }

    /// @notice 在给定经过的时间以及当前 tick 和流动性值的情况下，将先前的观测值转换为新的观测值
    /// @dev blockTimestamp _必须_ 在时间顺序上等于或晚于 last.blockTimestamp，在发生 0 次或 1 次溢出时是安全的
    /// @param last 待转换的指定观测值
    /// @param blockTimestamp 新观测值的时间戳
    /// @param tick 新观测值时刻的活跃 tick
    /// @param liquidity 新观测值时刻在区间内的总流动性
    /// @return Observation 新填充的观测值
    function transform(
        Observation memory last,
        uint32 blockTimestamp,
        int24 tick,
        uint128 liquidity
    ) private pure returns (Observation memory) {
        uint32 delta = blockTimestamp - last.blockTimestamp;
        return
            Observation({
                blockTimestamp: blockTimestamp,
                tickCumulative: last.tickCumulative + int56(tick) * delta,
                secondsPerLiquidityCumulativeX128: last.secondsPerLiquidityCumulativeX128 +
                    ((uint160(delta) << 128) / (liquidity > 0 ? liquidity : 1)),
                initialized: true
            });
    }

    /// @notice 通过写入第一个槽位来初始化预言机数组。在观测值数组的整个生命周期中只调用一次
    /// @param self 存储的预言机数组
    /// @param time 预言机初始化的时间，取自截断为 uint32 的 block.timestamp
    /// @return cardinality 预言机数组中已填充元素的数量
    /// @return cardinalityNext 预言机数组的新长度，与填充情况无关
    function initialize(Observation[65535] storage self, uint32 time)
        internal
        returns (uint16 cardinality, uint16 cardinalityNext)
    {
        self[0] = Observation({
            blockTimestamp: time,
            tickCumulative: 0,
            secondsPerLiquidityCumulativeX128: 0,
            initialized: true
        });
        return (1, 1);
    }

    /// @notice 将一个预言机观测值写入数组
    /// @dev 每个区块最多可写入一次。index 表示最近写入的元素。cardinality 和 index 必须在外部跟踪。
    /// 如果 index 位于允许的数组长度末尾（依据 cardinality），并且下一个基数
    /// 大于当前基数，则 cardinality 可以增加。设置此限制是为了保持顺序。
    /// @param self 存储的预言机数组
    /// @param index 最近一次写入观测值数组的观测值的索引
    /// @param blockTimestamp 新观测值的时间戳
    /// @param tick 新观测值时刻的活跃 tick
    /// @param liquidity 新观测值时刻在区间内的总流动性
    /// @param cardinality 预言机数组中已填充元素的数量
    /// @param cardinalityNext 预言机数组的新长度，与填充情况无关
    /// @return indexUpdated 预言机数组中最近写入元素的新索引
    /// @return cardinalityUpdated 预言机数组的新基数
    function write(
        Observation[65535] storage self,
        uint16 index,
        uint32 blockTimestamp,
        int24 tick,
        uint128 liquidity,
        uint16 cardinality,
        uint16 cardinalityNext
    ) internal returns (uint16 indexUpdated, uint16 cardinalityUpdated) {
        Observation memory last = self[index];

        // 如果本区块已经写入过观测值，则提前返回
        if (last.blockTimestamp == blockTimestamp) return (index, cardinality);

        // 如果条件满足，就可以提升基数
        if (cardinalityNext > cardinality && index == (cardinality - 1)) {
            cardinalityUpdated = cardinalityNext;
        } else {
            cardinalityUpdated = cardinality;
        }

        indexUpdated = (index + 1) % cardinalityUpdated;
        self[indexUpdated] = transform(last, blockTimestamp, tick, liquidity);
    }

    /// @notice 准备预言机数组，使其最多可存储 `next` 个观测值
    /// @param self 存储的预言机数组
    /// @param current 预言机数组当前的下一个基数
    /// @param next 提议的、将在预言机数组中填充的下一个基数
    /// @return next 将在预言机数组中填充的下一个基数
    function grow(
        Observation[65535] storage self,
        uint16 current,
        uint16 next
    ) internal returns (uint16) {
        require(current > 0, 'I');
        // 如果传入的 next 值不大于当前的 next 值，则不执行任何操作
        if (next <= current) return current;
        // 在每个槽位中写入数据，以避免在兑换中产生全新的 SSTORE
        // 这些数据不会被使用，因为 initialized 布尔值仍为 false
        for (uint16 i = current; i < next; i++) self[i].blockTimestamp = 1;
        return next;
    }

    /// @notice 32 位时间戳的比较器
    /// @dev 在发生 0 次或 1 次溢出时是安全的，a 和 b _必须_ 在时间顺序上早于或等于 time
    /// @param time 截断为 32 位的时间戳
    /// @param a 一个比较时间戳，据此确定 `time` 的相对位置
    /// @param b 据此确定 `time` 的相对位置
    /// @return bool `a` 在时间顺序上是否 <= `b`
    function lte(
        uint32 time,
        uint32 a,
        uint32 b
    ) private pure returns (bool) {
        // 如果没有发生溢出，则无需调整
        if (a <= time && b <= time) return a <= b;

        uint256 aAdjusted = a > time ? a : a + 2**32;
        uint256 bAdjusted = b > time ? b : b + 2**32;

        return aAdjusted <= bAdjusted;
    }

    /// @notice 获取目标的 beforeOrAt 和 atOrAfter 观测值，即满足 [beforeOrAt, atOrAfter] 的观测值。
    /// 结果可能是同一个观测值，也可能是相邻的观测值。
    /// @dev 答案必须包含在数组中，用于目标位于已存储观测值
    /// 边界之内的情况：早于最近的观测值，且晚于或等于最旧的观测值
    /// @param self 存储的预言机数组
    /// @param time 当前的 block.timestamp
    /// @param target 预留的观测值所应对应的时间戳
    /// @param index 最近一次写入观测值数组的观测值的索引
    /// @param cardinality 预言机数组中已填充元素的数量
    /// @return beforeOrAt 在目标之前或恰好在目标时刻记录的观测值
    /// @return atOrAfter 恰好在目标时刻或在目标之后记录的观测值
    function binarySearch(
        Observation[65535] storage self,
        uint32 time,
        uint32 target,
        uint16 index,
        uint16 cardinality
    ) private view returns (Observation memory beforeOrAt, Observation memory atOrAfter) {
        uint256 l = (index + 1) % cardinality; // 最旧的观测值
        uint256 r = l + cardinality - 1; // 最新的观测值
        uint256 i;
        while (true) {
            i = (l + r) / 2;

            beforeOrAt = self[i % cardinality];

            // 落在了一个未初始化的 tick 上，继续向更高处（更近的时间）搜索
            if (!beforeOrAt.initialized) {
                l = i + 1;
                continue;
            }

            atOrAfter = self[(i + 1) % cardinality];

            bool targetAtOrAfter = lte(time, beforeOrAt.blockTimestamp, target);

            // 检查是否已找到答案！
            if (targetAtOrAfter && lte(time, target, atOrAfter.blockTimestamp)) break;

            if (!targetAtOrAfter) r = i - 1;
            else l = i + 1;
        }
    }

    /// @notice 获取给定目标的 beforeOrAt 和 atOrAfter 观测值，即满足 [beforeOrAt, atOrAfter] 的观测值
    /// @dev 假设至少存在 1 个已初始化的观测值。
    /// 由 observeSingle() 调用，用于计算截至给定区块时间戳的反事实累加器值。
    /// @param self 存储的预言机数组
    /// @param time 当前的 block.timestamp
    /// @param target 预留的观测值所应对应的时间戳
    /// @param tick 返回的或模拟的观测值时刻的活跃 tick
    /// @param index 最近一次写入观测值数组的观测值的索引
    /// @param liquidity 调用时刻池子的总流动性
    /// @param cardinality 预言机数组中已填充元素的数量
    /// @return beforeOrAt 在给定时间戳或之前发生的观测值
    /// @return atOrAfter 在给定时间戳或之后发生的观测值
    function getSurroundingObservations(
        Observation[65535] storage self,
        uint32 time,
        uint32 target,
        int24 tick,
        uint16 index,
        uint128 liquidity,
        uint16 cardinality
    ) private view returns (Observation memory beforeOrAt, Observation memory atOrAfter) {
        // 乐观地将 before 设为最新的观测值
        beforeOrAt = self[index];

        // 如果目标在时间顺序上等于或晚于最新的观测值，就可以提前返回
        if (lte(time, beforeOrAt.blockTimestamp, target)) {
            if (beforeOrAt.blockTimestamp == target) {
                // 如果最新的观测值等于目标，说明处于同一区块，因此可以忽略 atOrAfter
                return (beforeOrAt, atOrAfter);
            } else {
                // 否则，需要进行转换
                return (beforeOrAt, transform(beforeOrAt, target, tick, liquidity));
            }
        }

        // 现在，将 before 设为最旧的观测值
        beforeOrAt = self[(index + 1) % cardinality];
        if (!beforeOrAt.initialized) beforeOrAt = self[0];

        // 确保目标在时间顺序上等于或晚于最旧的观测值
        require(lte(time, beforeOrAt.blockTimestamp, target), 'OLD');

        // 如果执行到这里，就必须进行二分查找
        return binarySearch(self, time, target, index, cardinality);
    }

    /// @dev 如果不存在位于所需观测时间戳或其之前的观测值，则回滚（revert）。
    /// 可以将 0 作为 `secondsAgo' 传入，以返回当前的累计值。
    /// 如果调用时的时间戳落在两个观测值之间，则返回恰好在两个观测值之间
    /// 该时间戳处的反事实累加器值。
    /// @param self 存储的预言机数组
    /// @param time 当前的区块时间戳
    /// @param secondsAgo 回溯的时长（以秒为单位），在该时间点返回一个观测值
    /// @param tick 当前的 tick
    /// @param index 最近一次写入观测值数组的观测值的索引
    /// @param liquidity 当前池子在区间内的流动性
    /// @param cardinality 预言机数组中已填充元素的数量
    /// @return tickCumulative 截至 `secondsAgo` 时，tick * 自池子首次初始化以来经过的时间
    /// @return secondsPerLiquidityCumulativeX128 截至 `secondsAgo` 时，自池子首次初始化以来经过的时间 / max(1, liquidity)
    function observeSingle(
        Observation[65535] storage self,
        uint32 time,
        uint32 secondsAgo,
        int24 tick,
        uint16 index,
        uint128 liquidity,
        uint16 cardinality
    ) internal view returns (int56 tickCumulative, uint160 secondsPerLiquidityCumulativeX128) {
        if (secondsAgo == 0) {
            Observation memory last = self[index];
            if (last.blockTimestamp != time) last = transform(last, time, tick, liquidity);
            return (last.tickCumulative, last.secondsPerLiquidityCumulativeX128);
        }

        uint32 target = time - secondsAgo;

        (Observation memory beforeOrAt, Observation memory atOrAfter) =
            getSurroundingObservations(self, time, target, tick, index, liquidity, cardinality);

        if (target == beforeOrAt.blockTimestamp) {
            // 位于左边界
            return (beforeOrAt.tickCumulative, beforeOrAt.secondsPerLiquidityCumulativeX128);
        } else if (target == atOrAfter.blockTimestamp) {
            // 位于右边界
            return (atOrAfter.tickCumulative, atOrAfter.secondsPerLiquidityCumulativeX128);
        } else {
            // 位于中间
            uint32 observationTimeDelta = atOrAfter.blockTimestamp - beforeOrAt.blockTimestamp;
            uint32 targetDelta = target - beforeOrAt.blockTimestamp;
            return (
                beforeOrAt.tickCumulative +
                    ((atOrAfter.tickCumulative - beforeOrAt.tickCumulative) / observationTimeDelta) *
                    targetDelta,
                beforeOrAt.secondsPerLiquidityCumulativeX128 +
                    uint160(
                        (uint256(
                            atOrAfter.secondsPerLiquidityCumulativeX128 - beforeOrAt.secondsPerLiquidityCumulativeX128
                        ) * targetDelta) / observationTimeDelta
                    )
            );
        }
    }

    /// @notice 针对 `secondsAgos` 数组中的每个值，返回从给定时间回溯相应秒数时的累加器值
    /// @dev 如果 `secondsAgos` > 最旧的观测值，则回滚（revert）
    /// @param self 存储的预言机数组
    /// @param time 当前的 block.timestamp
    /// @param secondsAgos 每个回溯的时长（以秒为单位），在该时间点返回一个观测值
    /// @param tick 当前的 tick
    /// @param index 最近一次写入观测值数组的观测值的索引
    /// @param liquidity 当前池子在区间内的流动性
    /// @param cardinality 预言机数组中已填充元素的数量
    /// @return tickCumulatives 截至每个 `secondsAgo` 时，tick * 自池子首次初始化以来经过的时间
    /// @return secondsPerLiquidityCumulativeX128s 截至每个 `secondsAgo` 时，自池子首次初始化以来的累计秒数 / max(1, liquidity)
    function observe(
        Observation[65535] storage self,
        uint32 time,
        uint32[] memory secondsAgos,
        int24 tick,
        uint16 index,
        uint128 liquidity,
        uint16 cardinality
    ) internal view returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s) {
        require(cardinality > 0, 'I');

        tickCumulatives = new int56[](secondsAgos.length);
        secondsPerLiquidityCumulativeX128s = new uint160[](secondsAgos.length);
        for (uint256 i = 0; i < secondsAgos.length; i++) {
            (tickCumulatives[i], secondsPerLiquidityCumulativeX128s[i]) = observeSingle(
                self,
                time,
                secondsAgos[i],
                tick,
                index,
                liquidity,
                cardinality
            );
        }
    }
}
