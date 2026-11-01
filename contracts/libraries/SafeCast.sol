// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title 安全类型转换方法
/// @notice 包含在类型之间进行安全转换的方法
library SafeCast {
    /// @notice 将 uint256 转换为 uint160，溢出时回滚（revert）
    /// @param y 待向下转换的 uint256
    /// @return z 向下转换后的整数，现为 uint160 类型
    function toUint160(uint256 y) internal pure returns (uint160 z) {
        require((z = uint160(y)) == y);
    }

    /// @notice 将 int256 转换为 int128，溢出或下溢时回滚
    /// @param y 待向下转换的 int256
    /// @return z 向下转换后的整数，现为 int128 类型
    function toInt128(int256 y) internal pure returns (int128 z) {
        require((z = int128(y)) == y);
    }

    /// @notice 将 uint256 转换为 int256，溢出时回滚
    /// @param y 待转换的 uint256
    /// @return z 转换后的整数，现为 int256 类型
    function toInt256(uint256 y) internal pure returns (int256 z) {
        require(y < 2**255);
        z = int256(y);
    }
}
