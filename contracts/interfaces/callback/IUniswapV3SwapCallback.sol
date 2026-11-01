// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title IUniswapV3PoolActions#swap 的回调
/// @notice 任何调用 IUniswapV3PoolActions#swap 的合约都必须实现此接口
interface IUniswapV3SwapCallback {
    /// @notice 在通过 IUniswapV3Pool#swap 执行兑换之后，对 `msg.sender` 调用。
    /// @dev 在实现中，你必须向池子支付该次兑换应付的代币。
    /// 必须检查此方法的调用者是由官方 UniswapV3Factory 部署的 UniswapV3Pool。
    /// 若没有兑换任何代币，amount0Delta 和 amount1Delta 可以都为 0。
    /// @param amount0Delta 截至兑换结束时，池子已发出（负值）或必须收到（正值）的 token0 数量。
    /// 若为正值，回调必须向池子发送该数量的 token0。
    /// @param amount1Delta 截至兑换结束时，池子已发出（负值）或必须收到（正值）的 token1 数量。
    /// 若为正值，回调必须向池子发送该数量的 token1。
    /// @param data 调用方通过 IUniswapV3PoolActions#swap 调用传入的任意数据
    function uniswapV3SwapCallback(
        int256 amount0Delta,
        int256 amount1Delta,
        bytes calldata data
    ) external;
}
