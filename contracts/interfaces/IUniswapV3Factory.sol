// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title Uniswap V3 工厂的接口
/// @notice Uniswap V3 工厂负责创建 Uniswap V3 池子，并控制协议手续费
interface IUniswapV3Factory {
    /// @notice 当工厂的所有者变更时触发
    /// @param oldOwner 变更前的所有者
    /// @param newOwner 变更后的所有者
    event OwnerChanged(address indexed oldOwner, address indexed newOwner);

    /// @notice 当创建池子时触发
    /// @param token0 按地址排序时池子的第一个代币
    /// @param token1 按地址排序时池子的第二个代币
    /// @param fee 池子中每次兑换收取的手续费，以百分之一 bip 为单位
    /// @param tickSpacing 已初始化的 tick 之间的最小 tick 数
    /// @param pool 所创建池子的地址
    event PoolCreated(
        address indexed token0,
        address indexed token1,
        uint24 indexed fee,
        int24 tickSpacing,
        address pool
    );

    /// @notice 当通过工厂启用一个新的手续费数额以供创建池子时触发
    /// @param fee 被启用的手续费，以百分之一 bip 为单位
    /// @param tickSpacing 以该手续费创建的池子中，已初始化的 tick 之间的最小 tick 数
    event FeeAmountEnabled(uint24 indexed fee, int24 indexed tickSpacing);

    /// @notice 返回工厂的当前所有者
    /// @dev 可由当前所有者通过 setOwner 变更
    /// @return 工厂所有者的地址
    function owner() external view returns (address);

    /// @notice 返回给定手续费数额对应的 tick 间距；若已启用则返回该值，未启用则返回 0
    /// @dev 手续费数额永远不能被移除，因此该值应在调用上下文中硬编码或缓存
    /// @param fee 已启用的手续费，以百分之一 bip 为单位。若该手续费未启用则返回 0
    /// @return 对应的 tick 间距
    function feeAmountTickSpacing(uint24 fee) external view returns (int24);

    /// @notice 返回给定代币对与手续费对应的池子地址；若池子不存在则返回地址 0
    /// @dev tokenA 与 tokenB 可以按 token0/token1 或 token1/token0 任一顺序传入
    /// @param tokenA token0 或 token1 二者之一的合约地址
    /// @param tokenB 另一个代币的合约地址
    /// @param fee 池子中每次兑换收取的手续费，以百分之一 bip 为单位
    /// @return pool 池子地址
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);

    /// @notice 为给定的两个代币和手续费创建一个池子
    /// @param tokenA 目标池子中两个代币之一
    /// @param tokenB 目标池子中两个代币的另一个
    /// @param fee 期望的池子手续费
    /// @dev tokenA 与 tokenB 可以按任一顺序传入：token0/token1 或 token1/token0。tickSpacing 根据
    /// 手续费获取。若池子已存在、手续费无效或代币参数无效，
    /// 调用将回滚（revert）。
    /// @return pool 新创建池子的地址
    function createPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external returns (address pool);

    /// @notice 更新工厂的所有者
    /// @dev 必须由当前所有者调用
    /// @param _owner 工厂的新所有者
    function setOwner(address _owner) external;

    /// @notice 以给定的 tickSpacing 启用一个手续费数额
    /// @dev 手续费数额一经启用便永远不能被移除
    /// @param fee 要启用的手续费数额，以百分之一 bip 为单位（即 1e-6）
    /// @param tickSpacing 对以该手续费数额创建的所有池子强制执行的 tick 间距
    function enableFeeAmount(uint24 fee, int24 tickSpacing) external;
}
