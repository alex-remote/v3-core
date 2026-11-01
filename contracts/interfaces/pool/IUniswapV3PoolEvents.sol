// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title 池子触发的事件
/// @notice 包含池子触发的所有事件
interface IUniswapV3PoolEvents {
    /// @notice 当池子上首次调用 #initialize 时，由池子恰好触发一次
    /// @dev 在 Initialize 之前，池子不会触发 Mint/Burn/Swap
    /// @param sqrtPriceX96 池子的初始平方根价格，格式为 Q64.96
    /// @param tick 池子的初始 tick，即池子起始价格以 1.0001 为底的对数
    event Initialize(uint160 sqrtPriceX96, int24 tick);

    /// @notice 当为给定头寸铸造流动性时触发
    /// @param sender 铸造该流动性的地址
    /// @param owner 头寸的所有者，也是所铸造流动性的接收者
    /// @param tickLower 头寸的下界 tick
    /// @param tickUpper 头寸的上界 tick
    /// @param amount 铸造到该头寸区间的流动性数量
    /// @param amount0 铸造该流动性所需的 token0 数量
    /// @param amount1 铸造该流动性所需的 token1 数量
    event Mint(
        address sender,
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice 当头寸所有者提取手续费时触发
    /// @dev 当调用者选择不提取手续费时，Collect 事件触发时 amount0 和 amount1 可能为零
    /// @param owner 被提取手续费的头寸的所有者
    /// @param tickLower 头寸的下界 tick
    /// @param tickUpper 头寸的上界 tick
    /// @param amount0 提取的 token0 手续费数量
    /// @param amount1 提取的 token1 手续费数量
    event Collect(
        address indexed owner,
        address recipient,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount0,
        uint128 amount1
    );

    /// @notice 当移除头寸的流动性时触发
    /// @dev 不会取出该流动性头寸已赚取的任何手续费，这些手续费必须通过 #collect 取出
    /// @param owner 被移除流动性的头寸的所有者
    /// @param tickLower 头寸的下界 tick
    /// @param tickUpper 头寸的上界 tick
    /// @param amount 要移除的流动性数量
    /// @param amount0 取出的 token0 数量
    /// @param amount1 取出的 token1 数量
    event Burn(
        address indexed owner,
        int24 indexed tickLower,
        int24 indexed tickUpper,
        uint128 amount,
        uint256 amount0,
        uint256 amount1
    );

    /// @notice 池子在 token0 与 token1 之间发生任何兑换时触发
    /// @param sender 发起兑换调用并接收回调的地址
    /// @param recipient 接收兑换输出的地址
    /// @param amount0 池子 token0 余额的变化量
    /// @param amount1 池子 token1 余额的变化量
    /// @param sqrtPriceX96 兑换后池子的 sqrt(price)，格式为 Q64.96
    /// @param liquidity 兑换后池子的流动性
    /// @param tick 兑换后池子价格以 1.0001 为底的对数
    event Swap(
        address indexed sender,
        address indexed recipient,
        int256 amount0,
        int256 amount1,
        uint160 sqrtPriceX96,
        uint128 liquidity,
        int24 tick
    );

    /// @notice 池子发生任何 token0/token1 闪电贷时触发
    /// @param sender 发起兑换调用并接收回调的地址
    /// @param recipient 从闪电贷中接收代币的地址
    /// @param amount0 闪电贷借出的 token0 数量
    /// @param amount1 闪电贷借出的 token1 数量
    /// @param paid0 为闪电贷支付的 token0 数量，可以超过 amount0 加上手续费
    /// @param paid1 为闪电贷支付的 token1 数量，可以超过 amount1 加上手续费
    event Flash(
        address indexed sender,
        address indexed recipient,
        uint256 amount0,
        uint256 amount1,
        uint256 paid0,
        uint256 paid1
    );

    /// @notice 池子增加可存储的观测值数量时触发
    /// @dev 直到在某次 mint/swap/burn 之前于该索引处写入一个观测值，observationCardinalityNext
    /// 才会成为观测基数。
    /// @param observationCardinalityNextOld 下一个观测基数的旧值
    /// @param observationCardinalityNextNew 下一个观测基数的新值
    event IncreaseObservationCardinalityNext(
        uint16 observationCardinalityNextOld,
        uint16 observationCardinalityNextNew
    );

    /// @notice 当池子的协议手续费被修改时触发
    /// @param feeProtocol0Old token0 协议手续费的旧值
    /// @param feeProtocol1Old token1 协议手续费的旧值
    /// @param feeProtocol0New token0 协议手续费的新值
    /// @param feeProtocol1New token1 协议手续费的新值
    event SetFeeProtocol(uint8 feeProtocol0Old, uint8 feeProtocol1Old, uint8 feeProtocol0New, uint8 feeProtocol1New);

    /// @notice 当工厂所有者取出已收取的协议手续费时触发
    /// @param sender 提取协议手续费的地址
    /// @param recipient 接收所提取协议手续费的地址
    /// @param amount0 取出的 token0 协议手续费数量
    /// @param amount0 取出的 token1 协议手续费数量
    event CollectProtocol(address indexed sender, address indexed recipient, uint128 amount0, uint128 amount1);
}
