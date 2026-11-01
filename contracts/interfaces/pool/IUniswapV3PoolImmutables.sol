// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title 永不改变的池子状态
/// @notice 这些参数对一个池子而言永久固定，即这些方法总是返回相同的值
interface IUniswapV3PoolImmutables {
    /// @notice 部署该池子的合约，它必须遵循 IUniswapV3Factory 接口
    /// @return 合约地址
    function factory() external view returns (address);

    /// @notice 池子两种代币中的第一种，按地址排序
    /// @return 代币合约地址
    function token0() external view returns (address);

    /// @notice 池子两种代币中的第二种，按地址排序
    /// @return 代币合约地址
    function token1() external view returns (address);

    /// @notice 池子的手续费，以百分之一个基点（bip）为单位，即 1e-6
    /// @return 手续费
    function fee() external view returns (uint24);

    /// @notice 池子的 tick 间距
    /// @dev 只能使用该值整数倍处的 tick，该值最小为 1，且始终为正
    /// 例如：tickSpacing 为 3 表示每隔 3 个 tick 才能初始化一个 tick，即 ..., -6, -3, 0, 3, 6, ...
    /// 尽管该值始终为正，它仍使用 int24 类型，以避免类型转换。
    /// @return tick 间距
    function tickSpacing() external view returns (int24);

    /// @notice 可以使用区间内任意 tick 的头寸流动性的最大数量
    /// @dev 该参数按每个 tick 强制执行，以防止流动性在任何时刻溢出 uint128，并且
    /// 还能防止区间外的流动性被用来阻止向池子添加在区间内的流动性
    /// @return 每个 tick 的最大流动性数量
    function maxLiquidityPerTick() external view returns (uint128);
}
