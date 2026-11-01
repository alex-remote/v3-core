// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.5.0 <0.8.0;

import './FullMath.sol';
import './FixedPoint128.sol';
import './LiquidityMath.sol';

/// @title Position
/// @notice 头寸表示某个所有者地址在下边界 tick 与上边界 tick 之间的流动性
/// @dev 头寸会存储额外的状态，用于跟踪该头寸应得的手续费
library Position {
    // 为每个用户的头寸存储的信息
    struct Info {
        // 该头寸拥有的流动性数量
        uint128 liquidity;
        // 截至上次更新流动性或应得手续费时，每单位流动性的手续费增长
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        // 应付给头寸所有者的 token0/token1 手续费
        uint128 tokensOwed0;
        uint128 tokensOwed1;
    }

    /// @notice 给定所有者和头寸边界，返回该头寸的 Info 结构体
    /// @param self 包含所有用户头寸的映射
    /// @param owner 头寸所有者的地址
    /// @param tickLower 头寸的下边界 tick
    /// @param tickUpper 头寸的上边界 tick
    /// @return position 给定所有者的头寸的信息结构体
    function get(
        mapping(bytes32 => Info) storage self,
        address owner,
        int24 tickLower,
        int24 tickUpper
    ) internal view returns (Position.Info storage position) {
        position = self[keccak256(abi.encodePacked(owner, tickLower, tickUpper))];
    }

    /// @notice 将累积的手续费记入用户的头寸
    /// @param self 要更新的单个头寸
    /// @param liquidityDelta 头寸更新所导致的池子流动性变化量
    /// @param feeGrowthInside0X128 头寸 tick 边界内、每单位流动性的 token0 历史累计手续费增长
    /// @param feeGrowthInside1X128 头寸 tick 边界内、每单位流动性的 token1 历史累计手续费增长
    function update(
        Info storage self,
        int128 liquidityDelta,
        uint256 feeGrowthInside0X128,
        uint256 feeGrowthInside1X128
    ) internal {
        Info memory _self = self;

        uint128 liquidityNext;
        if (liquidityDelta == 0) {
            require(_self.liquidity > 0, 'NP'); // 不允许对流动性为 0 的头寸进行 poke
            liquidityNext = _self.liquidity;
        } else {
            liquidityNext = LiquidityMath.addDelta(_self.liquidity, liquidityDelta);
        }

        // 计算累积的手续费
        uint128 tokensOwed0 =
            uint128(
                FullMath.mulDiv(
                    feeGrowthInside0X128 - _self.feeGrowthInside0LastX128,
                    _self.liquidity,
                    FixedPoint128.Q128
                )
            );
        uint128 tokensOwed1 =
            uint128(
                FullMath.mulDiv(
                    feeGrowthInside1X128 - _self.feeGrowthInside1LastX128,
                    _self.liquidity,
                    FixedPoint128.Q128
                )
            );

        // 更新头寸
        if (liquidityDelta != 0) self.liquidity = liquidityNext;
        self.feeGrowthInside0LastX128 = feeGrowthInside0X128;
        self.feeGrowthInside1LastX128 = feeGrowthInside1X128;
        if (tokensOwed0 > 0 || tokensOwed1 > 0) {
            // 溢出是可以接受的，必须在手续费达到 type(uint128).max 之前将其提取出来
            self.tokensOwed0 += tokensOwed0;
            self.tokensOwed1 += tokensOwed1;
        }
    }
}
