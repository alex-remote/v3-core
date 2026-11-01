# Uniswap V3

[![Lint](https://github.com/Uniswap/uniswap-v3-core/actions/workflows/lint.yml/badge.svg)](https://github.com/Uniswap/uniswap-v3-core/actions/workflows/lint.yml)
[![Tests](https://github.com/Uniswap/uniswap-v3-core/actions/workflows/tests.yml/badge.svg)](https://github.com/Uniswap/uniswap-v3-core/actions/workflows/tests.yml)
[![Fuzz Testing](https://github.com/Uniswap/uniswap-v3-core/actions/workflows/fuzz-testing.yml/badge.svg)](https://github.com/Uniswap/uniswap-v3-core/actions/workflows/fuzz-testing.yml)
[![Mythx](https://github.com/Uniswap/uniswap-v3-core/actions/workflows/mythx.yml/badge.svg)](https://github.com/Uniswap/uniswap-v3-core/actions/workflows/mythx.yml)
[![npm version](https://img.shields.io/npm/v/@uniswap/v3-core/latest.svg)](https://www.npmjs.com/package/@uniswap/v3-core/v/latest)

本仓库包含 Uniswap V3 协议的核心智能合约。
如需更高层级的合约，请参阅 [uniswap-v3-periphery](https://github.com/Uniswap/uniswap-v3-periphery)
仓库。

## 漏洞赏金

本仓库适用 Uniswap V3 漏洞赏金计划，具体条款见[此处](./bug-bounty.md)。

## 本地部署

若要将此代码部署到本地测试网，你应当安装 npm 包
`@uniswap/v3-core`
并导入位于以下路径的工厂字节码：
`@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json`。
例如：

```typescript
import {
  abi as FACTORY_ABI,
  bytecode as FACTORY_BYTECODE,
} from '@uniswap/v3-core/artifacts/contracts/UniswapV3Factory.sol/UniswapV3Factory.json'

// 部署字节码
```

这将确保你测试时所用的字节码与部署到
主网和公共测试网上的字节码完全相同，并且所有 Uniswap 代码都能与
你的本地部署正确地互操作。

## 使用 Solidity 接口

Uniswap v3 的接口可通过 npm 构件 `@uniswap/v3-core`
导入到 Solidity 智能合约中，例如：

```solidity
import '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

contract MyContract {
  IUniswapV3Pool pool;

  function doSomethingWithPool() {
    // pool.swap(...);
  }
}

```

## 许可证

Uniswap V3 Core 的主要许可证为 Business Source License 1.1（`BUSL-1.1`），见 [`LICENSE`](./LICENSE)。不过，部分文件采用双重许可，同时也以 `GPL-2.0-or-later` 授权：

- `contracts/interfaces/` 中的所有文件也可依据 `GPL-2.0-or-later` 授权（如其 SPDX 头部所示），见 [`contracts/interfaces/LICENSE`](./contracts/interfaces/LICENSE)
- `contracts/libraries/` 中的若干文件也可依据 `GPL-2.0-or-later` 授权（如其 SPDX 头部所示），见 [`contracts/libraries/LICENSE`](contracts/libraries/LICENSE)

### 其他例外

- `contracts/libraries/FullMath.sol` 依据 `MIT` 许可证授权（如其 SPDX 头部所示），见 [`contracts/libraries/LICENSE_MIT`](contracts/libraries/LICENSE_MIT)
- `contracts/test` 中的所有文件仍不附带任何许可证（如其 SPDX 头部所示）。
