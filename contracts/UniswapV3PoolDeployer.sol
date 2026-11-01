// SPDX-License-Identifier: BUSL-1.1
pragma solidity =0.7.6;

import './interfaces/IUniswapV3PoolDeployer.sol';

import './UniswapV3Pool.sol';

contract UniswapV3PoolDeployer is IUniswapV3PoolDeployer {
    struct Parameters {
        address factory;
        address token0;
        address token1;
        uint24 fee;
        int24 tickSpacing;
    }

    /// @inheritdoc IUniswapV3PoolDeployer
    Parameters public override parameters;

    /// @dev 使用给定参数部署一个池子：先临时设置 parameters 存储槽，然后在部署完池子后
    /// 将其清除。
    /// @param factory Uniswap V3 工厂的合约地址
    /// @param token0 按地址排序后池子的第一个代币
    /// @param token1 按地址排序后池子的第二个代币
    /// @param fee 池子中每次兑换收取的手续费，以百分之一 bip 为单位
    /// @param tickSpacing 可用 tick 之间的间距
    function deploy(
        address factory,
        address token0,
        address token1,
        uint24 fee,
        int24 tickSpacing
    ) internal returns (address pool) {
        parameters = Parameters({factory: factory, token0: token0, token1: token1, fee: fee, tickSpacing: tickSpacing});
        pool = address(new UniswapV3Pool{salt: keccak256(abi.encode(token0, token1, fee))}());
        delete parameters;
    }
}
