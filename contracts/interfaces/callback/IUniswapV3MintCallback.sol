// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title IUniswapV3PoolActions#mint 的回调
/// @notice 任何调用 IUniswapV3PoolActions#mint 的合约都必须实现此接口
interface IUniswapV3MintCallback {
    /// @notice 在通过 IUniswapV3Pool#mint 向某个头寸铸造流动性之后，对 `msg.sender` 调用。
    /// @dev 在实现中，你必须向池子支付所铸造流动性应付的代币。
    /// 必须检查此方法的调用者是由官方 UniswapV3Factory 部署的 UniswapV3Pool。
    /// @param amount0Owed 所铸造流动性应付给池子的 token0 数量
    /// @param amount1Owed 所铸造流动性应付给池子的 token1 数量
    /// @param data 调用方通过 IUniswapV3PoolActions#mint 调用传入的任意数据
    function uniswapV3MintCallback(
        uint256 amount0Owed,
        uint256 amount1Owed,
        bytes calldata data
    ) external;
}
