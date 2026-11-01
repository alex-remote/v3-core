// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title 不存储的池子状态
/// @notice 包含提供池子相关信息的 view 函数，这些信息是计算得出的，而非存储在
/// 区块链上。此处的函数可能具有可变的 gas 成本。
interface IUniswapV3PoolDerivedState {
    /// @notice 返回距当前区块时间戳 `secondsAgo` 之前的每个时间点的累计 tick 和流动性
    /// @dev 要获得时间加权平均 tick 或在区间内的流动性，必须用两个值调用此函数，一个表示
    /// 时间段的开始，另一个表示时间段的结束。例如，要获得最近一小时的时间加权平均 tick，
    /// 必须使用 secondsAgos = [3600, 0] 调用。
    /// @dev 时间加权平均 tick 代表池子的几何时间加权平均价格，即 token1 / token0
    /// 以 sqrt(1.0001) 为底的对数。可以使用 TickMath 库将 tick 值转换为比率。
    /// @param secondsAgos 每个累计 tick 和流动性值应当从多久之前返回
    /// @return tickCumulatives 距当前区块时间戳每个 `secondsAgos` 之前的 tick 累计值
    /// @return secondsPerLiquidityCumulativeX128s 距当前区块时间戳每个 `secondsAgos` 之前的、在区间内流动性的累计
    /// 每单位流动性秒数值
    function observe(uint32[] calldata secondsAgos)
        external
        view
        returns (int56[] memory tickCumulatives, uint160[] memory secondsPerLiquidityCumulativeX128s);

    /// @notice 返回某个 tick 区间内的 tick 累计值、每单位流动性秒数以及区间内秒数的快照
    /// @dev 快照只能与其他快照进行比较，且这些快照须取自某个头寸存续的时间段内。
    /// 也就是说，如果在第一个快照与第二个快照的拍摄之间的整个时间段内未持有头寸，
    /// 则不能比较这些快照。
    /// @param tickLower 区间的下界 tick
    /// @param tickUpper 区间的上界 tick
    /// @return tickCumulativeInside 该区间的 tick 累加器快照
    /// @return secondsPerLiquidityInsideX128 该区间的每单位流动性秒数快照
    /// @return secondsInside 该区间的每单位流动性秒数快照
    function snapshotCumulativesInside(int24 tickLower, int24 tickUpper)
        external
        view
        returns (
            int56 tickCumulativeInside,
            uint160 secondsPerLiquidityInsideX128,
            uint32 secondsInside
        );
}
