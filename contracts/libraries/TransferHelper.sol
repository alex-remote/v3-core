// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.6.0;

import '../interfaces/IERC20Minimal.sol';

/// @title TransferHelper
/// @notice 包含用于与不总是一致返回 true/false 的 ERC20 代币进行交互的辅助方法
library TransferHelper {
    /// @notice 将代币从 msg.sender 转给接收者
    /// @dev 调用代币合约的 transfer，若转账失败则以 TF 报错
    /// @param token 待转账代币的合约地址
    /// @param to 转账的接收者
    /// @param value 转账的金额
    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        (bool success, bytes memory data) =
            token.call(abi.encodeWithSelector(IERC20Minimal.transfer.selector, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TF');
    }
}
