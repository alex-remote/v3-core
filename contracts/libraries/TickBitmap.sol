// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.5.0;

import './BitMath.sol';

/// @title 紧凑打包的 tick 初始化状态库
/// @notice 存储从 tick 索引到其初始化状态的紧凑打包映射
/// @dev 该映射使用 int16 作为键，因为 tick 用 int24 表示，且每个字（word）包含 256 (2^8) 个值。
library TickBitmap {
    /// @notice 计算某个 tick 的初始化标志位在映射中所处的位置
    /// @param tick 要计算位置的 tick
    /// @return wordPos 映射中的键，对应存储该位的字（word）
    /// @return bitPos 该标志在字中存储的位位置
    function position(int24 tick) private pure returns (int16 wordPos, uint8 bitPos) {
        wordPos = int16(tick >> 8);
        bitPos = uint8(tick % 256);
    }

    /// @notice 将给定 tick 的初始化状态从 false 翻转为 true，或反之
    /// @param self 要在其中翻转该 tick 的映射
    /// @param tick 要翻转的 tick
    /// @param tickSpacing 可用 tick 之间的间距
    function flipTick(
        mapping(int16 => uint256) storage self,
        int24 tick,
        int24 tickSpacing
    ) internal {
        require(tick % tickSpacing == 0); // 确保该 tick 符合 tick 间距
        (int16 wordPos, uint8 bitPos) = position(tick / tickSpacing);
        uint256 mask = 1 << bitPos;
        self[wordPos] ^= mask;
    }

    /// @notice 返回与给定 tick 位于同一个字（或相邻字）中、且位于给定 tick
    /// 左侧（小于或等于）或右侧（大于）的下一个已初始化 tick
    /// @param self 用于计算下一个已初始化 tick 的映射
    /// @param tick 起始 tick
    /// @param tickSpacing 可用 tick 之间的间距
    /// @param lte 是否向左（小于或等于起始 tick）搜索下一个已初始化的 tick
    /// @return next 距当前 tick 至多 256 个 tick 范围内的下一个已初始化或未初始化的 tick
    /// @return initialized 下一个 tick 是否已初始化，因为该函数最多只在 256 个 tick 范围内搜索
    function nextInitializedTickWithinOneWord(
        mapping(int16 => uint256) storage self,
        int24 tick,
        int24 tickSpacing,
        bool lte
    ) internal view returns (int24 next, bool initialized) {
        int24 compressed = tick / tickSpacing;
        if (tick < 0 && tick % tickSpacing != 0) compressed--; // 向负无穷方向取整

        if (lte) {
            (int16 wordPos, uint8 bitPos) = position(compressed);
            // 当前 bitPos 处及其右侧的所有 1
            uint256 mask = (1 << bitPos) - 1 + (1 << bitPos);
            uint256 masked = self[wordPos] & mask;

            // 如果当前 tick 处及其右侧没有已初始化的 tick，则返回该字中最右侧的 tick
            initialized = masked != 0;
            // 可能发生溢出/下溢，但外部通过同时限制 tickSpacing 和 tick 加以防止
            next = initialized
                ? (compressed - int24(bitPos - BitMath.mostSignificantBit(masked))) * tickSpacing
                : (compressed - int24(bitPos)) * tickSpacing;
        } else {
            // 从下一个 tick 所在的字开始，因为当前 tick 的状态无关紧要
            (int16 wordPos, uint8 bitPos) = position(compressed + 1);
            // bitPos 处及其左侧的所有 1
            uint256 mask = ~((1 << bitPos) - 1);
            uint256 masked = self[wordPos] & mask;

            // 如果当前 tick 左侧没有已初始化的 tick，则返回该字中最左侧的 tick
            initialized = masked != 0;
            // 可能发生溢出/下溢，但外部通过同时限制 tickSpacing 和 tick 加以防止
            next = initialized
                ? (compressed + 1 + int24(BitMath.leastSignificantBit(masked) - bitPos)) * tickSpacing
                : (compressed + 1 + int24(type(uint8).max - bitPos)) * tickSpacing;
        }
    }
}
