// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;

/// @title 防止对合约进行 delegatecall
/// @notice 基础合约，提供一个修饰器，用于防止对子合约中的方法进行 delegatecall
abstract contract NoDelegateCall {
    /// @dev 本合约的原始地址
    address private immutable original;

    constructor() {
        // immutable 变量在合约的初始化代码（init code）中计算，然后被内联到部署后的字节码中。
        // 换言之，该变量在运行时被检查时不会发生变化。
        original = address(this);
    }

    /// @dev 这里使用私有方法而不是直接内联到修饰器中，因为修饰器会被复制到每个方法中，
    ///     而使用 immutable 意味着地址字节会被复制到每一个使用该修饰器的地方。
    function checkNotDelegateCall() private view {
        require(address(this) == original);
    }

    /// @notice 防止对被修饰的方法进行 delegatecall
    modifier noDelegateCall() {
        checkNotDelegateCall();
        _;
    }
}
