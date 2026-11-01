// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.0;

/// @title 经过优化的、防溢出和下溢的安全数学运算
/// @notice 包含以最小 gas 成本执行数学运算、并在溢出或下溢时回滚（revert）的方法
library LowGasSafeMath {
    /// @notice 返回 x + y，若和溢出 uint256 则回滚
    /// @param x 被加数
    /// @param y 加数
    /// @return z x 与 y 之和
    function add(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x + y) >= x);
    }

    /// @notice 返回 x - y，若下溢则回滚
    /// @param x 被减数
    /// @param y 减数
    /// @return z x 与 y 之差
    function sub(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require((z = x - y) <= x);
    }

    /// @notice 返回 x * y，若溢出则回滚
    /// @param x 被乘数
    /// @param y 乘数
    /// @return z x 与 y 之积
    function mul(uint256 x, uint256 y) internal pure returns (uint256 z) {
        require(x == 0 || (z = x * y) / x == y);
    }

    /// @notice 返回 x + y，若溢出或下溢则回滚
    /// @param x 被加数
    /// @param y 加数
    /// @return z x 与 y 之和
    function add(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x + y) >= x == (y >= 0));
    }

    /// @notice 返回 x - y，若溢出或下溢则回滚
    /// @param x 被减数
    /// @param y 减数
    /// @return z x 与 y 之差
    function sub(int256 x, int256 y) internal pure returns (int256 z) {
        require((z = x - y) <= x == (y >= 0));
    }
}
