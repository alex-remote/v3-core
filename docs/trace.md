# 注释中文翻译 · 任务进度跟踪

> 任务：将仓库内所有英文注释**原地**译为中文，便于精读代码。
>
> - 在英文原文位置直接替换为中文，**译后行数不变**，代码本身一字不改；
> - 保留专有名词、函数名、变量名、NatSpec 标签（`@notice` / `@param 名称` / `@return` 等）及 `SPDX-License-Identifier`；
> - 英文 `.md` 文件另存同路径译本，命名为 `原文件名_zh.md`（逐行对应，行数一致）；
> - 由多个子代理按批次并行翻译，主代理负责同步本文档；
> - 结果提交至分支 `v3-core_zh`。
>
> 最后更新：2026-11-01 14:15　　总体进度：**0 / 104** 个文件（0 / 21 个批次）

## 一、统计概览

| 类别 | 文件数 | 总行数 |
| --- | ---: | ---: |
| Solidity（.sol） | 69 | 6241 |
| TypeScript（.ts） | 23 | 6712 |
| YAML（.yml/.yaml） | 9 | 331 |
| Markdown（.md → _zh.md） | 3 | 308 |
| **合计** | **104** | **13592** |

仓库原有 130 个受版本控制的文件，其中 104 个纳入翻译范围；其余 26 个不在范围内：

| 文件 | 不翻译原因 |
| --- | --- |
| test/__snapshots__/*.snap（12 个） | Jest/Mocha 自动生成的快照，首行头注释由工具校验，不应手改 |
| audits/abdk/audit.pdf、audits/tob/audit.pdf | 二进制 PDF 审计报告 |
| LICENSE、contracts/interfaces/LICENSE、contracts/libraries/LICENSE、contracts/libraries/LICENSE_MIT | 法律许可证文本，非代码注释，保留原文以免产生法律歧义 |
| package.json、tsconfig.json、.solhint.json | JSON 不支持注释 |
| yarn.lock | 依赖锁文件，自动生成 |
| .gitattributes、.gitignore、.prettierrc、.yarnrc | 无注释的工具配置 |

## 二、批次总览

| 批次 | 内容 | 文件数 | 行数 | 状态 |
| --- | --- | ---: | ---: | --- |
| B01 | 核心合约：池子主合约 | 1 | 869 | ⏳ 进行中 |
| B02 | 核心库：预言机 | 1 | 325 | ⏳ 进行中 |
| B03 | 核心库：价格与兑换数学 | 2 | 325 | ⏳ 进行中 |
| B04 | 核心库：底层数学 | 5 | 253 | ⏳ 进行中 |
| B05 | 核心库：Tick 与位图 | 2 | 263 | ⏳ 进行中 |
| B06 | 核心库：TickMath / 头寸 / 安全运算 | 6 | 407 | ⏳ 进行中 |
| B07 | 池子接口：操作 / 管理 / 不可变量 | 3 | 161 | ⏳ 进行中 |
| B08 | 池子接口：事件 / 派生状态 | 2 | 161 | ⏳ 进行中 |
| B09 | 池子接口：状态 / 聚合接口 | 2 | 140 | ⏳ 进行中 |
| B10 | 其他接口与回调 | 6 | 213 | ⏳ 进行中 |
| B11 | 工厂 / 部署器 / 防委托调用 | 3 | 138 | ⏳ 进行中 |
| B12 | 测试合约：Echidna 模糊测试 | 11 | 766 | ⏳ 进行中 |
| B13 | 测试合约：单元测试辅助 | 18 | 972 | ⏳ 进行中 |
| B14 | 审计（ToB）：E2E 铸造/销毁 | 1 | 503 | ⏳ 进行中 |
| B15 | 审计（ToB）：E2E 兑换 | 1 | 487 | ⏳ 进行中 |
| B16 | 审计（ToB）：Setup / 配置 / Manticore | 8 | 291 | ⏳ 进行中 |
| B17 | 配置文件：Echidna / CI / Hardhat | 7 | 366 | ⏳ 进行中 |
| B18 | TS 测试：池子主测试 | 1 | 2043 | ⏳ 进行中 |
| B19 | TS 测试：其余用例与共享工具 | 21 | 4601 | ⏳ 进行中 |
| B20 | Markdown：根目录文档 | 2 | 142 | ⏳ 进行中 |
| B21 | Markdown：ToB 审计说明 | 1 | 166 | ⏳ 进行中 |

## 三、文件明细

格式：`- [ ] 文件路径 — 原行数`；完成后勾选，并附译后行数（`.md` 为 `_zh.md` 译本行数）。

### B01 · 核心合约：池子主合约

- [ ] `contracts/UniswapV3Pool.sol` — 869 行

### B02 · 核心库：预言机

- [ ] `contracts/libraries/Oracle.sol` — 325 行

### B03 · 核心库：价格与兑换数学

- [ ] `contracts/libraries/SqrtPriceMath.sol` — 227 行
- [ ] `contracts/libraries/SwapMath.sol` — 98 行

### B04 · 核心库：底层数学

- [ ] `contracts/libraries/FullMath.sol` — 124 行
- [ ] `contracts/libraries/BitMath.sol` — 94 行
- [ ] `contracts/libraries/UnsafeMath.sol` — 17 行
- [ ] `contracts/libraries/FixedPoint128.sol` — 8 行
- [ ] `contracts/libraries/FixedPoint96.sol` — 10 行

### B05 · 核心库：Tick 与位图

- [ ] `contracts/libraries/Tick.sol` — 185 行
- [ ] `contracts/libraries/TickBitmap.sol` — 78 行

### B06 · 核心库：TickMath / 头寸 / 安全运算

- [ ] `contracts/libraries/TickMath.sol` — 205 行
- [ ] `contracts/libraries/Position.sol` — 88 行
- [ ] `contracts/libraries/LiquidityMath.sol` — 17 行
- [ ] `contracts/libraries/LowGasSafeMath.sol` — 46 行
- [ ] `contracts/libraries/SafeCast.sol` — 28 行
- [ ] `contracts/libraries/TransferHelper.sol` — 23 行

### B07 · 池子接口：操作 / 管理 / 不可变量

- [ ] `contracts/interfaces/pool/IUniswapV3PoolActions.sol` — 103 行
- [ ] `contracts/interfaces/pool/IUniswapV3PoolOwnerActions.sol` — 23 行
- [ ] `contracts/interfaces/pool/IUniswapV3PoolImmutables.sol` — 35 行

### B08 · 池子接口：事件 / 派生状态

- [ ] `contracts/interfaces/pool/IUniswapV3PoolEvents.sol` — 121 行
- [ ] `contracts/interfaces/pool/IUniswapV3PoolDerivedState.sol` — 40 行

### B09 · 池子接口：状态 / 聚合接口

- [ ] `contracts/interfaces/pool/IUniswapV3PoolState.sol` — 116 行
- [ ] `contracts/interfaces/IUniswapV3Pool.sol` — 24 行

### B10 · 其他接口与回调

- [ ] `contracts/interfaces/IUniswapV3Factory.sol` — 78 行
- [ ] `contracts/interfaces/IERC20Minimal.sol` — 52 行
- [ ] `contracts/interfaces/IUniswapV3PoolDeployer.sol` — 26 行
- [ ] `contracts/interfaces/callback/IUniswapV3FlashCallback.sol` — 18 行
- [ ] `contracts/interfaces/callback/IUniswapV3MintCallback.sol` — 18 行
- [ ] `contracts/interfaces/callback/IUniswapV3SwapCallback.sol` — 21 行

### B11 · 工厂 / 部署器 / 防委托调用

- [ ] `contracts/NoDelegateCall.sol` — 27 行
- [ ] `contracts/UniswapV3Factory.sol` — 73 行
- [ ] `contracts/UniswapV3PoolDeployer.sol` — 38 行

### B12 · 测试合约：Echidna 模糊测试

- [ ] `contracts/test/BitMathEchidnaTest.sol` — 18 行
- [ ] `contracts/test/FullMathEchidnaTest.sol` — 67 行
- [ ] `contracts/test/LowGasSafeMathEchidnaTest.sol` — 36 行
- [ ] `contracts/test/OracleEchidnaTest.sol` — 137 行
- [ ] `contracts/test/SqrtPriceMathEchidnaTest.sol` — 232 行
- [ ] `contracts/test/SwapMathEchidnaTest.sol` — 52 行
- [ ] `contracts/test/TickBitmapEchidnaTest.sol` — 47 行
- [ ] `contracts/test/TickEchidnaTest.sol` — 27 行
- [ ] `contracts/test/TickMathEchidnaTest.sol` — 22 行
- [ ] `contracts/test/TickOverflowSafetyEchidnaTest.sol` — 111 行
- [ ] `contracts/test/UnsafeMathEchidnaTest.sol` — 17 行

### B13 · 测试合约：单元测试辅助

- [ ] `contracts/test/BitMathTest.sol` — 26 行
- [ ] `contracts/test/FullMathTest.sol` — 22 行
- [ ] `contracts/test/LiquidityMathTest.sol` — 16 行
- [ ] `contracts/test/MockTimeUniswapV3Pool.sol` — 26 行
- [ ] `contracts/test/MockTimeUniswapV3PoolDeployer.sol` — 35 行
- [ ] `contracts/test/NoDelegateCallTest.sol` — 32 行
- [ ] `contracts/test/OracleTest.sol` — 100 行
- [ ] `contracts/test/SqrtPriceMathTest.sol` — 86 行
- [ ] `contracts/test/SwapMathTest.sol` — 37 行
- [ ] `contracts/test/TestERC20.sol` — 59 行
- [ ] `contracts/test/TestUniswapV3Callee.sol` — 142 行
- [ ] `contracts/test/TestUniswapV3ReentrantCallee.sol` — 56 行
- [ ] `contracts/test/TestUniswapV3Router.sol` — 91 行
- [ ] `contracts/test/TestUniswapV3SwapPay.sol` — 41 行
- [ ] `contracts/test/TickBitmapTest.sol` — 40 行
- [ ] `contracts/test/TickMathTest.sol` — 34 行
- [ ] `contracts/test/TickTest.sol` — 79 行
- [ ] `contracts/test/UniswapV3PoolSwapTest.sol` — 50 行

### B14 · 审计（ToB）：E2E 铸造/销毁

- [ ] `audits/tob/contracts/crytic/echidna/E2E_mint_burn.sol` — 503 行

### B15 · 审计（ToB）：E2E 兑换

- [ ] `audits/tob/contracts/crytic/echidna/E2E_swap.sol` — 487 行

### B16 · 审计（ToB）：Setup / 配置 / Manticore

- [ ] `audits/tob/contracts/crytic/echidna/Setup.sol` — 205 行
- [ ] `audits/tob/contracts/crytic/echidna/Other.sol` — 21 行
- [ ] `audits/tob/contracts/crytic/echidna/E2E_mint_burn.config.yaml` — 16 行
- [ ] `audits/tob/contracts/crytic/echidna/E2E_swap.config.yaml` — 10 行
- [ ] `audits/tob/contracts/crytic/echidna/Other.config.yaml` — 7 行
- [ ] `audits/tob/contracts/crytic/manticore/001.sol` — 11 行
- [ ] `audits/tob/contracts/crytic/manticore/002.sol` — 12 行
- [ ] `audits/tob/contracts/crytic/manticore/003.sol` — 9 行

### B17 · 配置文件：Echidna / CI / Hardhat

- [ ] `echidna.config.yml` — 74 行
- [ ] `hardhat.config.ts` — 68 行
- [ ] `.github/stale.yml` — 25 行
- [ ] `.github/workflows/fuzz-testing.yml` — 60 行
- [ ] `.github/workflows/lint.yml` — 36 行
- [ ] `.github/workflows/mythx.yml` — 65 行
- [ ] `.github/workflows/tests.yml` — 38 行

### B18 · TS 测试：池子主测试

- [ ] `test/UniswapV3Pool.spec.ts` — 2043 行

### B19 · TS 测试：其余用例与共享工具

- [ ] `test/BitMath.spec.ts` — 79 行
- [ ] `test/FullMath.spec.ts` — 182 行
- [ ] `test/LiquidityMath.spec.ts` — 44 行
- [ ] `test/NoDelegateCall.spec.ts` — 54 行
- [ ] `test/Oracle.spec.ts` — 798 行
- [ ] `test/SqrtPriceMath.spec.ts` — 379 行
- [ ] `test/SwapMath.spec.ts` — 324 行
- [ ] `test/Tick.spec.ts` — 329 行
- [ ] `test/TickBitmap.spec.ts` — 227 行
- [ ] `test/TickMath.spec.ts` — 166 行
- [ ] `test/UniswapV3Factory.spec.ts` — 177 行
- [ ] `test/UniswapV3Pool.arbitrage.spec.ts` — 373 行
- [ ] `test/UniswapV3Pool.gas.spec.ts` — 315 行
- [ ] `test/UniswapV3Pool.swaps.spec.ts` — 588 行
- [ ] `test/UniswapV3Router.spec.ts` — 133 行
- [ ] `test/shared/checkObservationEquals.ts` — 38 行
- [ ] `test/shared/expect.ts` — 8 行
- [ ] `test/shared/fixtures.ts` — 92 行
- [ ] `test/shared/format.ts` — 10 行
- [ ] `test/shared/snapshotGasCost.ts` — 27 行
- [ ] `test/shared/utilities.ts` — 258 行

### B20 · Markdown：根目录文档

- [ ] `README.md` — 66 行
- [ ] `bug-bounty.md` — 76 行

### B21 · Markdown：ToB 审计说明

- [ ] `audits/tob/README.md` — 166 行
