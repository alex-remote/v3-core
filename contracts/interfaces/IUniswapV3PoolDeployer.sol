// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title 能够部署 Uniswap V3 池子的合约的接口
/// @notice 构造池子的合约必须实现此接口，以便向池子传递参数
/// @dev 这样做是为了避免池子合约带有构造函数参数，从而使池子的 init code hash
/// 保持不变，进而可以在链上以低成本计算出池子的 CREATE2 地址
interface IUniswapV3PoolDeployer {
    /// @notice 获取构造池子时要使用的参数，这些参数在池子创建期间临时设置。
    /// @dev 由池子的构造函数调用，以获取池子的参数
    /// Returns factory 工厂地址
    /// Returns token0 按地址排序时池子的第一个代币
    /// Returns token1 按地址排序时池子的第二个代币
    /// Returns fee 池子中每次兑换收取的手续费，以百分之一 bip 为单位
    /// Returns tickSpacing 已初始化的 tick 之间的最小 tick 数
    function parameters()
        external
        view
        returns (
            address factory,
            address token0,
            address token1,
            uint24 fee,
            int24 tickSpacing
        );
}
