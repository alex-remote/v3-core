// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title 不检查输入或输出的数学函数
/// @notice 包含执行常见数学运算的方法，但不进行任何溢出或下溢检查
library UnsafeMath {
    /// @notice 返回 ceil(x / y)
    /// @dev 除以 0 的行为未作规定，必须在外部进行检查
    /// @param x 被除数
    /// @param y 除数
    /// @return z 商，即 ceil(x / y)
    function divRoundingUp(uint256 x, uint256 y) internal pure returns (uint256 z) {
        assembly {
            z := add(div(x, y), gt(mod(x, y), 0))
        }
    }
}
