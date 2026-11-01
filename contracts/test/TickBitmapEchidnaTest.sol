// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.7.6;

import '../libraries/TickBitmap.sol';

contract TickBitmapEchidnaTest {
    using TickBitmap for mapping(int16 => uint256);

    mapping(int16 => uint256) private bitmap;

    // 返回给定的 tick 是否已初始化
    function isInitialized(int24 tick) private view returns (bool) {
        (int24 next, bool initialized) = bitmap.nextInitializedTickWithinOneWord(tick, 1, true);
        return next == tick ? initialized : false;
    }

    function flipTick(int24 tick) external {
        bool before = isInitialized(tick);
        bitmap.flipTick(tick, 1);
        assert(isInitialized(tick) == !before);
    }

    function checkNextInitializedTickWithinOneWordInvariants(int24 tick, bool lte) external view {
        (int24 next, bool initialized) = bitmap.nextInitializedTickWithinOneWord(tick, 1, lte);
        if (lte) {
            // type(int24).min + 256
            require(tick >= -8388352);
            assert(next <= tick);
            assert(tick - next < 256);
            // 输入 tick 与下一个 tick 之间的所有 tick 都应为未初始化
            for (int24 i = tick; i > next; i--) {
                assert(!isInitialized(i));
            }
            assert(isInitialized(next) == initialized);
        } else {
            // type(int24).max - 256
            require(tick < 8388351);
            assert(next > tick);
            assert(next - tick <= 256);
            // 输入 tick 与下一个 tick 之间的所有 tick 都应为未初始化
            for (int24 i = tick + 1; i < next; i++) {
                assert(!isInitialized(i));
            }
            assert(isInitialized(next) == initialized);
        }
    }
}
