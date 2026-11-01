// SPDX-License-Identifier: BUSL-1.1
pragma solidity >=0.5.0;

import './LowGasSafeMath.sol';
import './SafeCast.sol';

import './FullMath.sol';
import './UnsafeMath.sol';
import './FixedPoint96.sol';

/// @title 基于 Q64.96 平方根价格和流动性的函数
/// @notice 包含使用 Q64.96 格式的价格平方根和流动性来计算变化量（delta）的数学运算
library SqrtPriceMath {
    using LowGasSafeMath for uint256;
    using SafeCast for uint256;

    /// @notice 给定 token0 的变化量，求下一个平方根价格
    /// @dev 始终向上取整，因为在精确输出的情况下（价格上升），我们需要让价格至少移动
    /// 足够远以得到期望的输出数量；而在精确输入的情况下（价格下降），我们需要让
    /// 价格少移动一些，以免送出过多的输出。
    /// 对此最精确的公式是 liquidity * sqrtPX96 / (liquidity +- amount * sqrtPX96)，
    /// 如果因溢出而无法如此计算，我们就改为计算 liquidity / (liquidity / sqrtPX96 +- amount)。
    /// @param sqrtPX96 起始价格，即计入 token0 变化量之前的价格
    /// @param liquidity 可用流动性的数量
    /// @param amount 要向虚拟储备中添加或从中移除的 token0 数量
    /// @param add 是添加还是移除该数量的 token0
    /// @return 根据 add 添加或移除 amount 之后的价格
    function getNextSqrtPriceFromAmount0RoundingUp(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) internal pure returns (uint160) {
        // 对 amount == 0 直接短路返回，因为否则无法保证结果等于输入价格
        if (amount == 0) return sqrtPX96;
        uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;

        if (add) {
            uint256 product;
            if ((product = amount * sqrtPX96) / amount == sqrtPX96) {
                uint256 denominator = numerator1 + product;
                if (denominator >= numerator1)
                    // 结果总能放入 160 位
                    return uint160(FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator));
            }

            return uint160(UnsafeMath.divRoundingUp(numerator1, (numerator1 / sqrtPX96).add(amount)));
        } else {
            uint256 product;
            // 如果乘积溢出，我们就知道分母会下溢
            // 此外，我们还必须检查分母不会下溢
            require((product = amount * sqrtPX96) / amount == sqrtPX96 && numerator1 > product);
            uint256 denominator = numerator1 - product;
            return FullMath.mulDivRoundingUp(numerator1, sqrtPX96, denominator).toUint160();
        }
    }

    /// @notice 给定 token1 的变化量，求下一个平方根价格
    /// @dev 始终向下取整，因为在精确输出的情况下（价格下降），我们需要让价格至少移动
    /// 足够远以得到期望的输出数量；而在精确输入的情况下（价格上升），我们需要让
    /// 价格少移动一些，以免送出过多的输出。
    /// 我们计算的公式与无损版本相差不到 1 wei：sqrtPX96 +- amount / liquidity
    /// @param sqrtPX96 起始价格，即计入 token1 变化量之前的价格
    /// @param liquidity 可用流动性的数量
    /// @param amount 要向虚拟储备中添加或从中移除的 token1 数量
    /// @param add 是添加还是移除该数量的 token1
    /// @return 添加或移除 `amount` 之后的价格
    function getNextSqrtPriceFromAmount1RoundingDown(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amount,
        bool add
    ) internal pure returns (uint160) {
        // 如果是加（减），向下取整就要求将商向下（向上）取整
        // 两种情况下，都对大多数输入避免使用 mulDiv
        if (add) {
            uint256 quotient =
                (
                    amount <= type(uint160).max
                        ? (amount << FixedPoint96.RESOLUTION) / liquidity
                        : FullMath.mulDiv(amount, FixedPoint96.Q96, liquidity)
                );

            return uint256(sqrtPX96).add(quotient).toUint160();
        } else {
            uint256 quotient =
                (
                    amount <= type(uint160).max
                        ? UnsafeMath.divRoundingUp(amount << FixedPoint96.RESOLUTION, liquidity)
                        : FullMath.mulDivRoundingUp(amount, FixedPoint96.Q96, liquidity)
                );

            require(sqrtPX96 > quotient);
            // 结果总能放入 160 位
            return uint160(sqrtPX96 - quotient);
        }
    }

    /// @notice 给定 token0 或 token1 的输入数量，求下一个平方根价格
    /// @dev 如果价格或流动性为 0，或者下一个价格超出边界，则抛出异常
    /// @param sqrtPX96 起始价格，即计入输入数量之前的价格
    /// @param liquidity 可用流动性的数量
    /// @param amountIn 被兑换进来的 token0 或 token1 的数量
    /// @param zeroForOne 输入数量是 token0 还是 token1
    /// @return sqrtQX96 将输入数量加到 token0 或 token1 之后的价格
    function getNextSqrtPriceFromInput(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amountIn,
        bool zeroForOne
    ) internal pure returns (uint160 sqrtQX96) {
        require(sqrtPX96 > 0);
        require(liquidity > 0);

        // 取整以确保不会越过目标价格
        return
            zeroForOne
                ? getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amountIn, true)
                : getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amountIn, true);
    }

    /// @notice 给定 token0 或 token1 的输出数量，求下一个平方根价格
    /// @dev 如果价格或流动性为 0，或者下一个价格超出边界，则抛出异常
    /// @param sqrtPX96 计入输出数量之前的起始价格
    /// @param liquidity 可用流动性的数量
    /// @param amountOut 被兑换出去的 token0 或 token1 的数量
    /// @param zeroForOne 输出数量是 token0 还是 token1
    /// @return sqrtQX96 移除 token0 或 token1 的输出数量之后的价格
    function getNextSqrtPriceFromOutput(
        uint160 sqrtPX96,
        uint128 liquidity,
        uint256 amountOut,
        bool zeroForOne
    ) internal pure returns (uint160 sqrtQX96) {
        require(sqrtPX96 > 0);
        require(liquidity > 0);

        // 取整以确保越过目标价格
        return
            zeroForOne
                ? getNextSqrtPriceFromAmount1RoundingDown(sqrtPX96, liquidity, amountOut, false)
                : getNextSqrtPriceFromAmount0RoundingUp(sqrtPX96, liquidity, amountOut, false);
    }

    /// @notice 求两个价格之间的 amount0 变化量
    /// @dev 计算 liquidity / sqrt(lower) - liquidity / sqrt(upper)，
    /// 即 liquidity * (sqrt(upper) - sqrt(lower)) / (sqrt(upper) * sqrt(lower))
    /// @param sqrtRatioAX96 一个平方根价格
    /// @param sqrtRatioBX96 另一个平方根价格
    /// @param liquidity 可用流动性的数量
    /// @param roundUp 数量是向上还是向下取整
    /// @return amount0 在传入的两个价格之间覆盖大小为 liquidity 的头寸所需的 token0 数量
    function getAmount0Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount0) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        uint256 numerator1 = uint256(liquidity) << FixedPoint96.RESOLUTION;
        uint256 numerator2 = sqrtRatioBX96 - sqrtRatioAX96;

        require(sqrtRatioAX96 > 0);

        return
            roundUp
                ? UnsafeMath.divRoundingUp(
                    FullMath.mulDivRoundingUp(numerator1, numerator2, sqrtRatioBX96),
                    sqrtRatioAX96
                )
                : FullMath.mulDiv(numerator1, numerator2, sqrtRatioBX96) / sqrtRatioAX96;
    }

    /// @notice 求两个价格之间的 amount1 变化量
    /// @dev 计算 liquidity * (sqrt(upper) - sqrt(lower))
    /// @param sqrtRatioAX96 一个平方根价格
    /// @param sqrtRatioBX96 另一个平方根价格
    /// @param liquidity 可用流动性的数量
    /// @param roundUp 数量是向上还是向下取整
    /// @return amount1 在传入的两个价格之间覆盖大小为 liquidity 的头寸所需的 token1 数量
    function getAmount1Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        uint128 liquidity,
        bool roundUp
    ) internal pure returns (uint256 amount1) {
        if (sqrtRatioAX96 > sqrtRatioBX96) (sqrtRatioAX96, sqrtRatioBX96) = (sqrtRatioBX96, sqrtRatioAX96);

        return
            roundUp
                ? FullMath.mulDivRoundingUp(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96)
                : FullMath.mulDiv(liquidity, sqrtRatioBX96 - sqrtRatioAX96, FixedPoint96.Q96);
    }

    /// @notice 求带符号 token0 变化量的辅助函数
    /// @param sqrtRatioAX96 一个平方根价格
    /// @param sqrtRatioBX96 另一个平方根价格
    /// @param liquidity 用于计算 amount0 变化量的流动性变化
    /// @return amount0 在两个价格之间与传入的 liquidityDelta 对应的 token0 数量
    function getAmount0Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        int128 liquidity
    ) internal pure returns (int256 amount0) {
        return
            liquidity < 0
                ? -getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(-liquidity), false).toInt256()
                : getAmount0Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(liquidity), true).toInt256();
    }

    /// @notice 求带符号 token1 变化量的辅助函数
    /// @param sqrtRatioAX96 一个平方根价格
    /// @param sqrtRatioBX96 另一个平方根价格
    /// @param liquidity 用于计算 amount1 变化量的流动性变化
    /// @return amount1 在两个价格之间与传入的 liquidityDelta 对应的 token1 数量
    function getAmount1Delta(
        uint160 sqrtRatioAX96,
        uint160 sqrtRatioBX96,
        int128 liquidity
    ) internal pure returns (int256 amount1) {
        return
            liquidity < 0
                ? -getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(-liquidity), false).toInt256()
                : getAmount1Delta(sqrtRatioAX96, sqrtRatioBX96, uint128(liquidity), true).toInt256();
    }
}
