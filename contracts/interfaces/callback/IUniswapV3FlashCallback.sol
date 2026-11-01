// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title IUniswapV3PoolActions#flash 的回调
/// @notice 任何调用 IUniswapV3PoolActions#flash 的合约都必须实现此接口
interface IUniswapV3FlashCallback {
    /// @notice 在 IUniswapV3Pool#flash 向接收方转账之后，对 `msg.sender` 调用。
    /// @dev 在实现中，你必须向池子偿还闪电贷发出的代币，外加计算出的手续费数额。
    /// 必须检查此方法的调用者是由官方 UniswapV3Factory 部署的 UniswapV3Pool。
    /// @param fee0 闪电贷结束时应付给池子的 token0 手续费数额
    /// @param fee1 闪电贷结束时应付给池子的 token1 手续费数额
    /// @param data 调用方通过 IUniswapV3PoolActions#flash 调用传入的任意数据
    function uniswapV3FlashCallback(
        uint256 fee0,
        uint256 fee1,
        bytes calldata data
    ) external;
}
