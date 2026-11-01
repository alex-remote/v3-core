# 注释中文翻译 · 任务进度跟踪

> 任务：将仓库内所有英文注释**原地**译为中文，便于精读代码。
>
> - 在英文原文位置直接替换为中文，**译后行数不变**，代码本身一字不改；
> - 保留专有名词、函数名、变量名、NatSpec 标签（`@notice` / `@param 名称` / `@return` 等）及 `SPDX-License-Identifier`；
> - 英文 `.md` 文件另存同路径译本，命名为 `原文件名_zh.md`（逐行对应，行数一致）；
> - 由多个子代理按批次并行翻译，主代理负责同步本文档；
> - 结果提交至分支 `v3-core_zh`。
>
> 最后更新：2026-11-01 14:23　　总体进度：**104 / 104** 个文件（21 / 21 个批次）

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
| B01 | 核心合约：池子主合约 | 1 | 869 | ✅ 已完成 |
| B02 | 核心库：预言机 | 1 | 325 | ✅ 已完成 |
| B03 | 核心库：价格与兑换数学 | 2 | 325 | ✅ 已完成 |
| B04 | 核心库：底层数学 | 5 | 253 | ✅ 已完成 |
| B05 | 核心库：Tick 与位图 | 2 | 263 | ✅ 已完成 |
| B06 | 核心库：TickMath / 头寸 / 安全运算 | 6 | 407 | ✅ 已完成 |
| B07 | 池子接口：操作 / 管理 / 不可变量 | 3 | 161 | ✅ 已完成 |
| B08 | 池子接口：事件 / 派生状态 | 2 | 161 | ✅ 已完成 |
| B09 | 池子接口：状态 / 聚合接口 | 2 | 140 | ✅ 已完成 |
| B10 | 其他接口与回调 | 6 | 213 | ✅ 已完成 |
| B11 | 工厂 / 部署器 / 防委托调用 | 3 | 138 | ✅ 已完成 |
| B12 | 测试合约：Echidna 模糊测试 | 11 | 766 | ✅ 已完成 |
| B13 | 测试合约：单元测试辅助 | 18 | 972 | ✅ 已完成 |
| B14 | 审计（ToB）：E2E 铸造/销毁 | 1 | 503 | ✅ 已完成 |
| B15 | 审计（ToB）：E2E 兑换 | 1 | 487 | ✅ 已完成 |
| B16 | 审计（ToB）：Setup / 配置 / Manticore | 8 | 291 | ✅ 已完成 |
| B17 | 配置文件：Echidna / CI / Hardhat | 7 | 366 | ✅ 已完成 |
| B18 | TS 测试：池子主测试 | 1 | 2043 | ✅ 已完成 |
| B19 | TS 测试：其余用例与共享工具 | 21 | 4601 | ✅ 已完成 |
| B20 | Markdown：根目录文档 | 2 | 142 | ✅ 已完成 |
| B21 | Markdown：ToB 审计说明 | 1 | 166 | ✅ 已完成 |

## 三、文件明细

格式：`- [ ] 文件路径 — 原行数`；完成后勾选，并附译后行数（`.md` 为 `_zh.md` 译本行数）。

### B01 · 核心合约：池子主合约

- [x] `contracts/UniswapV3Pool.sol` — 869 行 → 869 行 ✅ 行数一致；注：第 70 行原注释“whether the pool is locked”与字段名 unlocked 语义相反，按原文直译

### B02 · 核心库：预言机

- [x] `contracts/libraries/Oracle.sol` — 325 行 → 325 行 ✅ 行数一致

### B03 · 核心库：价格与兑换数学

- [x] `contracts/libraries/SqrtPriceMath.sol` — 227 行 → 227 行 ✅ 行数一致
- [x] `contracts/libraries/SwapMath.sol` — 98 行 → 98 行 ✅ 行数一致

### B04 · 核心库：底层数学

- [x] `contracts/libraries/FullMath.sol` — 124 行 → 124 行 ✅ 行数一致；原文笔误 correct correct / precoditions 已按原意译出
- [x] `contracts/libraries/BitMath.sol` — 94 行 → 94 行 ✅ 行数一致
- [x] `contracts/libraries/UnsafeMath.sol` — 17 行 → 17 行 ✅ 行数一致
- [x] `contracts/libraries/FixedPoint128.sol` — 8 行 → 8 行 ✅ 行数一致
- [x] `contracts/libraries/FixedPoint96.sol` — 10 行 → 10 行 ✅ 行数一致

### B05 · 核心库：Tick 与位图

- [x] `contracts/libraries/Tick.sol` — 185 行 → 185 行 ✅ 行数一致
- [x] `contracts/libraries/TickBitmap.sol` — 78 行 → 78 行 ✅ 行数一致

### B06 · 核心库：TickMath / 头寸 / 安全运算

- [x] `contracts/libraries/TickMath.sol` — 205 行 → 205 行 ✅ 行数一致
- [x] `contracts/libraries/Position.sol` — 88 行 → 88 行 ✅ 行数一致
- [x] `contracts/libraries/LiquidityMath.sol` — 17 行 → 17 行 ✅ 行数一致；注：@return z 原文称 delta，实际返回变化后的流动性，按原文直译
- [x] `contracts/libraries/LowGasSafeMath.sol` — 46 行 → 46 行 ✅ 行数一致
- [x] `contracts/libraries/SafeCast.sol` — 28 行 → 28 行 ✅ 行数一致
- [x] `contracts/libraries/TransferHelper.sol` — 23 行 → 23 行 ✅ 行数一致

### B07 · 池子接口：操作 / 管理 / 不可变量

- [x] `contracts/interfaces/pool/IUniswapV3PoolActions.sol` — 103 行 → 103 行 ✅ 行数一致
- [x] `contracts/interfaces/pool/IUniswapV3PoolOwnerActions.sol` — 23 行 → 23 行 ✅ 行数一致
- [x] `contracts/interfaces/pool/IUniswapV3PoolImmutables.sol` — 35 行 → 35 行 ✅ 行数一致

### B08 · 池子接口：事件 / 派生状态

- [x] `contracts/interfaces/pool/IUniswapV3PoolEvents.sol` — 121 行 → 121 行 ✅ 行数一致；注：第 119 行原文 @param 名误写为 amount0（实指 token1），按原文保留
- [x] `contracts/interfaces/pool/IUniswapV3PoolDerivedState.sol` — 40 行 → 40 行 ✅ 行数一致；注：第 31 行 secondsInside 的说明照抄了上一行，按原文直译

### B09 · 池子接口：状态 / 聚合接口

- [x] `contracts/interfaces/pool/IUniswapV3PoolState.sol` — 116 行 → 116 行 ✅ 行数一致
- [x] `contracts/interfaces/IUniswapV3Pool.sol` — 24 行 → 24 行 ✅ 行数一致

### B10 · 其他接口与回调

- [x] `contracts/interfaces/IUniswapV3Factory.sol` — 78 行 → 78 行 ✅ 行数一致
- [x] `contracts/interfaces/IERC20Minimal.sol` — 52 行 → 52 行 ✅ 行数一致
- [x] `contracts/interfaces/IUniswapV3PoolDeployer.sol` — 26 行 → 26 行 ✅ 行数一致
- [x] `contracts/interfaces/callback/IUniswapV3FlashCallback.sol` — 18 行 → 18 行 ✅ 行数一致
- [x] `contracts/interfaces/callback/IUniswapV3MintCallback.sol` — 18 行 → 18 行 ✅ 行数一致
- [x] `contracts/interfaces/callback/IUniswapV3SwapCallback.sol` — 21 行 → 21 行 ✅ 行数一致

### B11 · 工厂 / 部署器 / 防委托调用

- [x] `contracts/NoDelegateCall.sol` — 27 行 → 27 行 ✅ 行数一致
- [x] `contracts/UniswapV3Factory.sol` — 73 行 → 73 行 ✅ 行数一致
- [x] `contracts/UniswapV3PoolDeployer.sol` — 38 行 → 38 行 ✅ 行数一致

### B12 · 测试合约：Echidna 模糊测试

- [x] `contracts/test/BitMathEchidnaTest.sol` — 18 行 → 18 行 ✅ 行数一致；无可翻译注释，保持原样
- [x] `contracts/test/FullMathEchidnaTest.sol` — 67 行 → 67 行 ✅ 行数一致；注：第 58 行注释复制自第 36 行，与该函数断言 x2 >= x 相反，按原文直译
- [x] `contracts/test/LowGasSafeMathEchidnaTest.sol` — 36 行 → 36 行 ✅ 行数一致；无可翻译注释，保持原样
- [x] `contracts/test/OracleEchidnaTest.sol` — 137 行 → 137 行 ✅ 行数一致
- [x] `contracts/test/SqrtPriceMathEchidnaTest.sol` — 232 行 → 232 行 ✅ 行数一致
- [x] `contracts/test/SwapMathEchidnaTest.sol` — 52 行 → 52 行 ✅ 行数一致
- [x] `contracts/test/TickBitmapEchidnaTest.sol` — 47 行 → 47 行 ✅ 行数一致
- [x] `contracts/test/TickEchidnaTest.sol` — 27 行 → 27 行 ✅ 行数一致
- [x] `contracts/test/TickMathEchidnaTest.sol` — 22 行 → 22 行 ✅ 行数一致
- [x] `contracts/test/TickOverflowSafetyEchidnaTest.sol` — 111 行 → 111 行 ✅ 行数一致
- [x] `contracts/test/UnsafeMathEchidnaTest.sol` — 17 行 → 17 行 ✅ 行数一致；无可翻译注释，保持原样

### B13 · 测试合约：单元测试辅助

- [x] `contracts/test/BitMathTest.sol` — 26 行 → 26 行 ✅ 行数一致；无可翻译注释（仅 SPDX 行），保持原样
- [x] `contracts/test/FullMathTest.sol` — 22 行 → 22 行 ✅ 行数一致；无可翻译注释（仅 SPDX 行），保持原样
- [x] `contracts/test/LiquidityMathTest.sol` — 16 行 → 16 行 ✅ 行数一致；无可翻译注释（仅 SPDX 行），保持原样
- [x] `contracts/test/MockTimeUniswapV3Pool.sol` — 26 行 → 26 行 ✅ 行数一致
- [x] `contracts/test/MockTimeUniswapV3PoolDeployer.sol` — 35 行 → 35 行 ✅ 行数一致；无可翻译注释（仅 SPDX 行），保持原样
- [x] `contracts/test/NoDelegateCallTest.sol` — 32 行 → 32 行 ✅ 行数一致；无可翻译注释（仅 SPDX 行），保持原样
- [x] `contracts/test/OracleTest.sol` — 100 行 → 100 行 ✅ 行数一致
- [x] `contracts/test/SqrtPriceMathTest.sol` — 86 行 → 86 行 ✅ 行数一致；无可翻译注释（仅 SPDX 行），保持原样
- [x] `contracts/test/SwapMathTest.sol` — 37 行 → 37 行 ✅ 行数一致；无可翻译注释（仅 SPDX 行），保持原样
- [x] `contracts/test/TestERC20.sol` — 59 行 → 59 行 ✅ 行数一致；无可翻译注释（仅 SPDX 行），保持原样
- [x] `contracts/test/TestUniswapV3Callee.sol` — 142 行 → 142 行 ✅ 行数一致
- [x] `contracts/test/TestUniswapV3ReentrantCallee.sol` — 56 行 → 56 行 ✅ 行数一致
- [x] `contracts/test/TestUniswapV3Router.sol` — 91 行 → 91 行 ✅ 行数一致
- [x] `contracts/test/TestUniswapV3SwapPay.sol` — 41 行 → 41 行 ✅ 行数一致；无可翻译注释（仅 SPDX 行），保持原样
- [x] `contracts/test/TickBitmapTest.sol` — 40 行 → 40 行 ✅ 行数一致
- [x] `contracts/test/TickMathTest.sol` — 34 行 → 34 行 ✅ 行数一致；无可翻译注释（仅 SPDX 行），保持原样
- [x] `contracts/test/TickTest.sol` — 79 行 → 79 行 ✅ 行数一致；无可翻译注释（仅 SPDX 行），保持原样
- [x] `contracts/test/UniswapV3PoolSwapTest.sol` — 50 行 → 50 行 ✅ 行数一致；无可翻译注释（仅 SPDX 行），保持原样

### B14 · 审计（ToB）：E2E 铸造/销毁

- [x] `audits/tob/contracts/crytic/echidna/E2E_mint_burn.sol` — 503 行 → 503 行 ✅ 行数一致

### B15 · 审计（ToB）：E2E 兑换

- [x] `audits/tob/contracts/crytic/echidna/E2E_swap.sol` — 487 行 → 487 行 ✅ 行数一致

### B16 · 审计（ToB）：Setup / 配置 / Manticore

- [x] `audits/tob/contracts/crytic/echidna/Setup.sol` — 205 行 → 205 行 ✅ 行数一致；注：第 12 行原注释称 100 tokens，与代码 1e12 ether 不符，按原文直译
- [x] `audits/tob/contracts/crytic/echidna/Other.sol` — 21 行 → 21 行 ✅ 行数一致
- [x] `audits/tob/contracts/crytic/echidna/E2E_mint_burn.config.yaml` — 16 行 → 16 行 ✅ 行数一致
- [x] `audits/tob/contracts/crytic/echidna/E2E_swap.config.yaml` — 10 行 → 10 行 ✅ 行数一致
- [x] `audits/tob/contracts/crytic/echidna/Other.config.yaml` — 7 行 → 7 行 ✅ 行数一致
- [x] `audits/tob/contracts/crytic/manticore/001.sol` — 11 行 → 11 行 ✅ 行数一致；无可翻译注释，保持原样
- [x] `audits/tob/contracts/crytic/manticore/002.sol` — 12 行 → 12 行 ✅ 行数一致
- [x] `audits/tob/contracts/crytic/manticore/003.sol` — 9 行 → 9 行 ✅ 行数一致；无可翻译注释，保持原样

### B17 · 配置文件：Echidna / CI / Hardhat

- [x] `echidna.config.yml` — 74 行 → 74 行 ✅ 行数一致；被注释掉的配置项原样保留，仅译说明文字
- [x] `hardhat.config.ts` — 68 行 → 68 行 ✅ 行数一致
- [x] `.github/stale.yml` — 25 行 → 25 行 ✅ 行数一致
- [x] `.github/workflows/fuzz-testing.yml` — 60 行 → 60 行 ✅ 行数一致；无可翻译注释，保持原样
- [x] `.github/workflows/lint.yml` — 36 行 → 36 行 ✅ 行数一致；无可翻译注释，保持原样
- [x] `.github/workflows/mythx.yml` — 65 行 → 65 行 ✅ 行数一致；无可翻译注释，保持原样
- [x] `.github/workflows/tests.yml` — 38 行 → 38 行 ✅ 行数一致

### B18 · TS 测试：池子主测试

- [x] `test/UniswapV3Pool.spec.ts` — 2043 行 → 2043 行 ✅ 行数一致；第 1349 行为 issue URL，按规则保留英文

### B19 · TS 测试：其余用例与共享工具

- [x] `test/BitMath.spec.ts` — 79 行 → 79 行 ✅ 行数一致；无可翻译注释，保持原样
- [x] `test/FullMath.spec.ts` — 182 行 → 182 行 ✅ 行数一致
- [x] `test/LiquidityMath.spec.ts` — 44 行 → 44 行 ✅ 行数一致；无可翻译注释，保持原样
- [x] `test/NoDelegateCall.spec.ts` — 54 行 → 54 行 ✅ 行数一致；无可翻译注释，保持原样
- [x] `test/Oracle.spec.ts` — 798 行 → 798 行 ✅ 行数一致
- [x] `test/SqrtPriceMath.spec.ts` — 379 行 → 379 行 ✅ 行数一致
- [x] `test/SwapMath.spec.ts` — 324 行 → 324 行 ✅ 行数一致
- [x] `test/Tick.spec.ts` — 329 行 → 329 行 ✅ 行数一致
- [x] `test/TickBitmap.spec.ts` — 227 行 → 227 行 ✅ 行数一致
- [x] `test/TickMath.spec.ts` — 166 行 → 166 行 ✅ 行数一致；无可翻译注释，保持原样
- [x] `test/UniswapV3Factory.spec.ts` — 177 行 → 177 行 ✅ 行数一致；无可翻译注释，保持原样
- [x] `test/UniswapV3Pool.arbitrage.spec.ts` — 373 行 → 373 行 ✅ 行数一致
- [x] `test/UniswapV3Pool.gas.spec.ts` — 315 行 → 315 行 ✅ 行数一致
- [x] `test/UniswapV3Pool.swaps.spec.ts` — 588 行 → 588 行 ✅ 行数一致
- [x] `test/UniswapV3Router.spec.ts` — 133 行 → 133 行 ✅ 行数一致
- [x] `test/shared/checkObservationEquals.ts` — 38 行 → 38 行 ✅ 行数一致
- [x] `test/shared/expect.ts` — 8 行 → 8 行 ✅ 行数一致；无可翻译注释，保持原样
- [x] `test/shared/fixtures.ts` — 92 行 → 92 行 ✅ 行数一致
- [x] `test/shared/format.ts` — 10 行 → 10 行 ✅ 行数一致；无可翻译注释，保持原样
- [x] `test/shared/snapshotGasCost.ts` — 27 行 → 27 行 ✅ 行数一致；无可翻译注释，保持原样
- [x] `test/shared/utilities.ts` — 258 行 → 258 行 ✅ 行数一致

### B20 · Markdown：根目录文档

- [x] `README.md` — 66 行 → 66 行 ✅ 行数一致（译本 `README_zh.md`）；徽章、链接、代码原样保留
- [x] `bug-bounty.md` — 76 行 → 76 行 ✅ 行数一致（译本 `bug-bounty_zh.md`）

### B21 · Markdown：ToB 审计说明

- [x] `audits/tob/README.md` — 166 行 → 166 行 ✅ 行数一致（译本 `audits/tob/README_zh.md`）；目录锚点已改为指向中文标题，保证页内跳转有效
