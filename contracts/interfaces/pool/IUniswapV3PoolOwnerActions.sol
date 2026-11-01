// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title 需要许可的池子操作
/// @notice 包含只能由工厂所有者调用的池子方法
interface IUniswapV3PoolOwnerActions {
    /// @notice 设置协议在手续费中所占百分比份额的分母
    /// @param feeProtocol0 池子 token0 的新协议手续费
    /// @param feeProtocol1 池子 token1 的新协议手续费
    function setFeeProtocol(uint8 feeProtocol0, uint8 feeProtocol1) external;

    /// @notice 提取池子中累积的协议手续费
    /// @param recipient 所提取的协议手续费应发送到的地址
    /// @param amount0Requested 要发送的 token0 最大数量，可设为 0 以仅提取 token1 形式的手续费
    /// @param amount1Requested 要发送的 token1 最大数量，可设为 0 以仅提取 token0 形式的手续费
    /// @return amount0 以 token0 计的已提取协议手续费
    /// @return amount1 以 token1 计的已提取协议手续费
    function collectProtocol(
        address recipient,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);
}
