import { BigNumber, BigNumberish } from 'ethers'
import { expect } from './expect'

// 辅助函数：因为 ethers 返回的观测值结果对象继承自数组，
// 所以无法直接对其做简单的深度相等比较
export default function checkObservationEquals(
  {
    tickCumulative,
    blockTimestamp,
    initialized,
    secondsPerLiquidityCumulativeX128,
  }: {
    tickCumulative: BigNumber
    secondsPerLiquidityCumulativeX128: BigNumber
    initialized: boolean
    blockTimestamp: number
  },
  expected: {
    tickCumulative: BigNumberish
    secondsPerLiquidityCumulativeX128: BigNumberish
    initialized: boolean
    blockTimestamp: number
  }
) {
  expect(
    {
      initialized,
      blockTimestamp,
      tickCumulative: tickCumulative.toString(),
      secondsPerLiquidityCumulativeX128: secondsPerLiquidityCumulativeX128.toString(),
    },
    `observation is equivalent`
  ).to.deep.eq({
    ...expected,
    tickCumulative: expected.tickCumulative.toString(),
    secondsPerLiquidityCumulativeX128: expected.secondsPerLiquidityCumulativeX128.toString(),
  })
}
