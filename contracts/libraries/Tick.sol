// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.5.0 <0.8.0;

import './LowGasSafeMath.sol';
import './SafeCast.sol';

import './TickMath.sol';
import './LiquidityMath.sol';

/// @title Tick
/// @notice 包含用于管理 tick 相关流程及相应计算的函数
library Tick {
    using LowGasSafeMath for int256;
    using SafeCast for int256;

    // 为每个已初始化的 tick 单独存储的信息
    struct Info {
        // 引用该 tick 的所有头寸流动性总量
        uint128 liquidityGross;
        // 从左向右（从右向左）穿越该 tick 时增加（减少）的净流动性数量，
        int128 liquidityNet;
        // 该 tick _另一侧_（相对于当前 tick）每单位流动性的手续费增长
        // 只有相对意义而非绝对意义——其数值取决于该 tick 何时被初始化
        uint256 feeGrowthOutside0X128;
        uint256 feeGrowthOutside1X128;
        // 该 tick 另一侧的 tick 累计值
        int56 tickCumulativeOutside;
        // 该 tick _另一侧_（相对于当前 tick）的每单位流动性秒数
        // 只有相对意义而非绝对意义——其数值取决于该 tick 何时被初始化
        uint160 secondsPerLiquidityOutsideX128;
        // 在该 tick 另一侧（相对于当前 tick）所经历的秒数
        // 只有相对意义而非绝对意义——其数值取决于该 tick 何时被初始化
        uint32 secondsOutside;
        // 当且仅当该 tick 已初始化时为 true，即该值与表达式 liquidityGross != 0 完全等价
        // 设置这 8 位是为了在穿越新初始化的 tick 时避免对全新存储槽执行 sstore
        bool initialized;
    }

    /// @notice 根据给定的 tick 间距推导出每个 tick 的最大流动性
    /// @dev 在池子的构造函数中执行
    /// @param tickSpacing 所需的 tick 间隔量，以 `tickSpacing` 的倍数实现
    ///     例如，tickSpacing 为 3 时要求每隔 3 个 tick 初始化一个 tick，即 ..., -6, -3, 0, 3, 6, ...
    /// @return 每个 tick 的最大流动性
    function tickSpacingToMaxLiquidityPerTick(int24 tickSpacing) internal pure returns (uint128) {
        int24 minTick = (TickMath.MIN_TICK / tickSpacing) * tickSpacing;
        int24 maxTick = (TickMath.MAX_TICK / tickSpacing) * tickSpacing;
        uint24 numTicks = uint24((maxTick - minTick) / tickSpacing) + 1;
        return type(uint128).max / numTicks;
    }

    /// @notice 获取手续费增长数据
    /// @param self 包含所有已初始化 tick 信息的映射
    /// @param tickLower 头寸的 tick 下边界
    /// @param tickUpper 头寸的 tick 上边界
    /// @param tickCurrent 当前 tick
    /// @param feeGrowthGlobal0X128 自始至今的全局手续费增长，按每单位流动性计，以 token0 计价
    /// @param feeGrowthGlobal1X128 自始至今的全局手续费增长，按每单位流动性计，以 token1 计价
    /// @return feeGrowthInside0X128 头寸 tick 边界内自始至今以 token0 计价的手续费增长，按每单位流动性计
    /// @return feeGrowthInside1X128 头寸 tick 边界内自始至今以 token1 计价的手续费增长，按每单位流动性计
    function getFeeGrowthInside(
        mapping(int24 => Tick.Info) storage self,
        int24 tickLower,
        int24 tickUpper,
        int24 tickCurrent,
        uint256 feeGrowthGlobal0X128,
        uint256 feeGrowthGlobal1X128
    ) internal view returns (uint256 feeGrowthInside0X128, uint256 feeGrowthInside1X128) {
        Info storage lower = self[tickLower];
        Info storage upper = self[tickUpper];

        // 计算下方的手续费增长
        uint256 feeGrowthBelow0X128;
        uint256 feeGrowthBelow1X128;
        if (tickCurrent >= tickLower) {
            feeGrowthBelow0X128 = lower.feeGrowthOutside0X128;
            feeGrowthBelow1X128 = lower.feeGrowthOutside1X128;
        } else {
            feeGrowthBelow0X128 = feeGrowthGlobal0X128 - lower.feeGrowthOutside0X128;
            feeGrowthBelow1X128 = feeGrowthGlobal1X128 - lower.feeGrowthOutside1X128;
        }

        // 计算上方的手续费增长
        uint256 feeGrowthAbove0X128;
        uint256 feeGrowthAbove1X128;
        if (tickCurrent < tickUpper) {
            feeGrowthAbove0X128 = upper.feeGrowthOutside0X128;
            feeGrowthAbove1X128 = upper.feeGrowthOutside1X128;
        } else {
            feeGrowthAbove0X128 = feeGrowthGlobal0X128 - upper.feeGrowthOutside0X128;
            feeGrowthAbove1X128 = feeGrowthGlobal1X128 - upper.feeGrowthOutside1X128;
        }

        feeGrowthInside0X128 = feeGrowthGlobal0X128 - feeGrowthBelow0X128 - feeGrowthAbove0X128;
        feeGrowthInside1X128 = feeGrowthGlobal1X128 - feeGrowthBelow1X128 - feeGrowthAbove1X128;
    }

    /// @notice 更新一个 tick，若该 tick 从已初始化翻转为未初始化（或反之）则返回 true
    /// @param self 包含所有已初始化 tick 信息的映射
    /// @param tick 将被更新的 tick
    /// @param tickCurrent 当前 tick
    /// @param liquidityDelta 从左向右（从右向左）穿越该 tick 时要增加（减少）的新的流动性数量
    /// @param feeGrowthGlobal0X128 自始至今的全局手续费增长，按每单位流动性计，以 token0 计价
    /// @param feeGrowthGlobal1X128 自始至今的全局手续费增长，按每单位流动性计，以 token1 计价
    /// @param secondsPerLiquidityCumulativeX128 池子自始至今累计的每 max(1, liquidity) 秒数
    /// @param tickCumulative 自池子首次初始化以来累计的 tick * 经过时间
    /// @param time 转换为 uint32 的当前区块时间戳
    /// @param upper 更新头寸的上边界 tick 时为 true，更新头寸的下边界 tick 时为 false
    /// @param maxLiquidity 单个 tick 可分配的最大流动性
    /// @return flipped 该 tick 是否从已初始化翻转为未初始化，或反之
    function update(
        mapping(int24 => Tick.Info) storage self,
        int24 tick,
        int24 tickCurrent,
        int128 liquidityDelta,
        uint256 feeGrowthGlobal0X128,
        uint256 feeGrowthGlobal1X128,
        uint160 secondsPerLiquidityCumulativeX128,
        int56 tickCumulative,
        uint32 time,
        bool upper,
        uint128 maxLiquidity
    ) internal returns (bool flipped) {
        Tick.Info storage info = self[tick];

        uint128 liquidityGrossBefore = info.liquidityGross;
        uint128 liquidityGrossAfter = LiquidityMath.addDelta(liquidityGrossBefore, liquidityDelta);

        require(liquidityGrossAfter <= maxLiquidity, 'LO');

        flipped = (liquidityGrossAfter == 0) != (liquidityGrossBefore == 0);

        if (liquidityGrossBefore == 0) {
            // 按照约定，我们假设在 tick 初始化之前的所有增长都发生在该 tick _下方_
            if (tick <= tickCurrent) {
                info.feeGrowthOutside0X128 = feeGrowthGlobal0X128;
                info.feeGrowthOutside1X128 = feeGrowthGlobal1X128;
                info.secondsPerLiquidityOutsideX128 = secondsPerLiquidityCumulativeX128;
                info.tickCumulativeOutside = tickCumulative;
                info.secondsOutside = time;
            }
            info.initialized = true;
        }

        info.liquidityGross = liquidityGrossAfter;

        // 当下边界（上边界）tick 被从左向右（从右向左）穿越时，必须增加（移除）流动性
        info.liquidityNet = upper
            ? int256(info.liquidityNet).sub(liquidityDelta).toInt128()
            : int256(info.liquidityNet).add(liquidityDelta).toInt128();
    }

    /// @notice 清除 tick 数据
    /// @param self 包含所有已初始化 tick 的 tick 信息的映射
    /// @param tick 将被清除的 tick
    function clear(mapping(int24 => Tick.Info) storage self, int24 tick) internal {
        delete self[tick];
    }

    /// @notice 根据价格变动的需要转移到下一个 tick
    /// @param self 包含所有已初始化 tick 信息的映射
    /// @param tick 本次转移的目标 tick
    /// @param feeGrowthGlobal0X128 自始至今的全局手续费增长，按每单位流动性计，以 token0 计价
    /// @param feeGrowthGlobal1X128 自始至今的全局手续费增长，按每单位流动性计，以 token1 计价
    /// @param secondsPerLiquidityCumulativeX128 当前的每单位流动性秒数
    /// @param tickCumulative 自池子首次初始化以来累计的 tick * 经过时间
    /// @param time 当前的 block.timestamp
    /// @return liquidityNet 从左向右（从右向左）穿越该 tick 时增加（减少）的流动性数量
    function cross(
        mapping(int24 => Tick.Info) storage self,
        int24 tick,
        uint256 feeGrowthGlobal0X128,
        uint256 feeGrowthGlobal1X128,
        uint160 secondsPerLiquidityCumulativeX128,
        int56 tickCumulative,
        uint32 time
    ) internal returns (int128 liquidityNet) {
        Tick.Info storage info = self[tick];
        info.feeGrowthOutside0X128 = feeGrowthGlobal0X128 - info.feeGrowthOutside0X128;
        info.feeGrowthOutside1X128 = feeGrowthGlobal1X128 - info.feeGrowthOutside1X128;
        info.secondsPerLiquidityOutsideX128 = secondsPerLiquidityCumulativeX128 - info.secondsPerLiquidityOutsideX128;
        info.tickCumulativeOutside = tickCumulative - info.tickCumulativeOutside;
        info.secondsOutside = time - info.secondsOutside;
        liquidityNet = info.liquidityNet;
    }
}
