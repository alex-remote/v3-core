// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title 可变的池子状态
/// @notice 这些方法构成了池子的状态，其值可能以任意频率变化，包括在单笔交易中
/// 变化多次
interface IUniswapV3PoolState {
    /// @notice 池子的第 0 个存储槽存放了许多值，并以单个方法的形式对外暴露，以便在外部访问时
    /// 节省 gas。
    /// @return sqrtPriceX96 池子的当前价格，以 sqrt(token1/token0) 的 Q64.96 值表示
    /// tick 池子的当前 tick，即根据最近一次执行的 tick 转换得出的 tick。
    /// 该值可能并不总是等于 SqrtTickMath.getTickAtSqrtRatio(sqrtPriceX96)，
    /// 当价格恰好位于 tick 边界上时即可能出现这种情况。
    /// observationIndex 最近一次写入的预言机观测值的索引，
    /// observationCardinality 池子中当前存储的观测值的最大数量，
    /// observationCardinalityNext 下一个观测值最大数量，将在观测时更新。
    /// feeProtocol 池子中两种代币的协议手续费。
    /// 编码为两个 4 位的值，其中 token1 的协议手续费左移 4 位，token0 的协议手续费
    /// 占低 4 位。用作兑换手续费分数的分母，例如 4 表示兑换手续费的 1/4。
    /// unlocked 池子当前是否为防止重入而处于锁定状态
    function slot0()
        external
        view
        returns (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        );

    /// @notice 手续费增长，以 Q128.128 表示池子整个生命周期内每单位流动性所收取的 token0 手续费
    /// @dev 该值可能溢出 uint256
    function feeGrowthGlobal0X128() external view returns (uint256);

    /// @notice 手续费增长，以 Q128.128 表示池子整个生命周期内每单位流动性所收取的 token1 手续费
    /// @dev 该值可能溢出 uint256
    function feeGrowthGlobal1X128() external view returns (uint256);

    /// @notice 应付给协议的 token0 和 token1 数量
    /// @dev 任一代币的协议手续费都不会超过 uint128 的最大值
    function protocolFees() external view returns (uint128 token0, uint128 token1);

    /// @notice 池子当前可用的、在区间内的流动性
    /// @dev 该值与所有 tick 上的流动性总量没有关系
    function liquidity() external view returns (uint128);

    /// @notice 查询池子中某个特定 tick 的信息
    /// @param tick 要查询的 tick
    /// @return liquidityGross 在池子中将该 tick 用作下界 tick 或
    /// 上界 tick 的头寸流动性总量，
    /// liquidityNet 池子价格穿越该 tick 时流动性的变化量，
    /// feeGrowthOutside0X128 该 tick 相对于当前 tick 另一侧的 token0 手续费增长，
    /// feeGrowthOutside1X128 该 tick 相对于当前 tick 另一侧的 token1 手续费增长，
    /// tickCumulativeOutside 该 tick 相对于当前 tick 另一侧的 tick 累计值
    /// secondsPerLiquidityOutsideX128 该 tick 相对于当前 tick 另一侧所经历的每单位流动性秒数，
    /// secondsOutside 该 tick 相对于当前 tick 另一侧所经历的秒数，
    /// initialized 若该 tick 已初始化（即 liquidityGross 大于 0）则为 true，否则为 false。
    /// 只有当该 tick 已初始化（即 liquidityGross 大于 0）时，outside 值才可使用。
    /// 此外，这些值只是相对值，只能用于与某个特定头寸先前的
    /// 快照进行比较。
    function ticks(int24 tick)
        external
        view
        returns (
            uint128 liquidityGross,
            int128 liquidityNet,
            uint256 feeGrowthOutside0X128,
            uint256 feeGrowthOutside1X128,
            int56 tickCumulativeOutside,
            uint160 secondsPerLiquidityOutsideX128,
            uint32 secondsOutside,
            bool initialized
        );

    /// @notice 返回 256 个打包在一起的、表示 tick 是否已初始化的布尔值。更多信息参见 TickBitmap
    function tickBitmap(int16 wordPosition) external view returns (uint256);

    /// @notice 根据头寸的 key 返回该头寸的信息
    /// @param key 头寸的 key，是由所有者（owner）、tickLower 和 tickUpper 组成的原像的哈希
    /// @return _liquidity 头寸中的流动性数量，
    /// 返回 feeGrowthInside0LastX128：截至最近一次铸造/销毁/poke 时，tick 区间内 token0 的手续费增长，
    /// 返回 feeGrowthInside1LastX128：截至最近一次铸造/销毁/poke 时，tick 区间内 token1 的手续费增长，
    /// 返回 tokensOwed0：截至最近一次铸造/销毁/poke 时，计算得出的应付给该头寸的 token0 数量，
    /// 返回 tokensOwed1：截至最近一次铸造/销毁/poke 时，计算得出的应付给该头寸的 token1 数量
    function positions(bytes32 key)
        external
        view
        returns (
            uint128 _liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        );

    /// @notice 返回特定观测值索引处的数据
    /// @param index 要获取的 observations 数组元素
    /// @dev 若要获取距今一段时间之前的观测值，而非数组中特定索引处的观测值，你很可能应该
    /// 使用 #observe() 而不是本方法。
    /// @return blockTimestamp 观测值的时间戳，
    /// 返回 tickCumulative：截至该观测值的时间戳，池子在整个生命周期内 tick 乘以所经过秒数的值，
    /// 返回 secondsPerLiquidityCumulativeX128：截至该观测值的时间戳，池子在整个生命周期内每单位在区间内流动性的秒数，
    /// 返回 initialized：该观测值是否已初始化、其值是否可以安全使用
    function observations(uint256 index)
        external
        view
        returns (
            uint32 blockTimestamp,
            int56 tickCumulative,
            uint160 secondsPerLiquidityCumulativeX128,
            bool initialized
        );
}
