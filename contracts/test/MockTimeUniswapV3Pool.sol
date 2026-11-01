// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import '../UniswapV3Pool.sol';

// 用于测试与时间相关的行为
contract MockTimeUniswapV3Pool is UniswapV3Pool {
    // 2020 年 10 月 5 日（星期一）上午 9:00:00 GMT-05:00
    uint256 public time = 1601906400;

    function setFeeGrowthGlobal0X128(uint256 _feeGrowthGlobal0X128) external {
        feeGrowthGlobal0X128 = _feeGrowthGlobal0X128;
    }

    function setFeeGrowthGlobal1X128(uint256 _feeGrowthGlobal1X128) external {
        feeGrowthGlobal1X128 = _feeGrowthGlobal1X128;
    }

    function advanceTime(uint256 by) external {
        time += by;
    }

    function _blockTimestamp() internal view override returns (uint32) {
        return uint32(time);
    }
}
