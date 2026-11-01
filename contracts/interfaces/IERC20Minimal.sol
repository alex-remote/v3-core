// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title 供 Uniswap 使用的最小化 ERC20 接口
/// @notice 包含完整 ERC20 接口中在 Uniswap V3 里用到的子集
interface IERC20Minimal {
    /// @notice 返回代币的余额
    /// @param account 要查询其持有代币数量（即余额）的账户
    /// @return 该账户持有的代币数量
    function balanceOf(address account) external view returns (uint256);

    /// @notice 将一定数量的代币从 `msg.sender` 转给接收方
    /// @param recipient 将收到所转数量的账户
    /// @param amount 从发送方发给接收方的代币数量
    /// @return 转账成功返回 true，转账失败返回 false
    function transfer(address recipient, uint256 amount) external returns (bool);

    /// @notice 返回所有者给予某个支出者的当前授权额度
    /// @param owner 代币所有者的账户
    /// @param spender 代币支出者的账户
    /// @return 由 `owner` 授予 `spender` 的当前授权额度
    function allowance(address owner, address spender) external view returns (uint256);

    /// @notice 将 `msg.sender` 给予某个支出者的授权额度设置为 `amount`
    /// @param spender 将被允许支出所有者一定数量代币的账户
    /// @param amount 允许 `spender` 使用的代币数量
    /// @return 授权成功返回 true，失败返回 false
    function approve(address spender, uint256 amount) external returns (bool);

    /// @notice 在给予 `msg.sender` 的授权额度范围内，将 `amount` 数量的代币从 `sender` 转给 `recipient`
    /// @param sender 转账从其发起的账户
    /// @param recipient 转账的接收方
    /// @param amount 转账的数量
    /// @return 转账成功返回 true，失败返回 false
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    /// @notice 当代币从一个地址转移到另一个地址时触发的事件，无论是通过 `#transfer` 还是 `#transferFrom`。
    /// @param from 代币从中发出的账户，即余额减少的一方
    /// @param to 代币发往的账户，即余额增加的一方
    /// @param value 被转移的代币数量
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// @notice 当某个所有者的代币对其支出者的授权数量发生变化时触发的事件。
    /// @param owner 批准他人支出其代币的账户
    /// @param spender 支出授权额度被修改的账户
    /// @param value 所有者给予支出者的新授权额度
    event Approval(address indexed owner, address indexed spender, uint256 value);
}
