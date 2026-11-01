以下内容包含 Trail of Bits 编写的性质。

- [使用 Echidna 进行端到端测试](#使用-echidna-进行端到端测试)
- [使用 Manticore 进行验证](#使用-manticore-进行验证)

# 使用 Echidna 进行端到端测试

我们为 Uniswap V3 Core 的池子合约实现了端到端性质。

## 安装

要运行这些测试，你需要安装 [echidna 1.7.0](https://github.com/crytic/echidna/releases/tag/v1.7.0)。

## 运行

假设你位于仓库根目录下

```
echidna-test contracts/crytic/echidna/E2E_swap.sol --config contracts/crytic/echidna/E2E_swap.config.yaml --contract E2E_swap

echidna-test contracts/crytic/echidna/E2E_mint_burn.sol --config contracts/crytic/echidna/E2E_mint_burn.config.yaml --contract E2E_mint_burn

echidna-test contracts/crytic/echidna/Other.sol --config contracts/crytic/echidna/Other.config.yaml --contract Other
```

## 随机但有效的池子初始化、所创建的头寸以及 priceLimit

为了帮助 Echidna 获得良好的覆盖率，我们使用了多个辅助函数来：

- 在执行兑换或铸造/销毁之前，创建随机但有效的池子初始化参数（手续费、tickSpacing、初始价格）[链接](./E2E_mint_burn.sol#L303-L337) [链接](./E2E_swap.sol#L196-L230)
- 在测试兑换之前，创建随机数量的、随机但有效的头寸 [链接](./E2E_swap.sol#L233-L283)
- 执行兑换时，创建随机但有效的 priceLimit [链接](./E2E_swap.sol#L68-L80)
- 执行铸造时，创建随机但有效的头寸参数 [链接](./E2E_mint_burn.sol#L102-L130)

通过上述做法，Echidna 能够测试我们真正想要测试的性质，而不是在无效的 priceLimit 或无效的头寸参数上反复碰壁。上述做法还使得在执行兑换之前可以创建动态数量的随机头寸，而不必使用一个静态列表。

为了得到上述“随机但有效”的结果，我们将兑换/铸造/销毁调用中的 `uint128 _amount` 用作种子，在辅助函数中生成随机性。这也意味着要找回实际使用的确切参数并不那么直接。不过，结合使用 hardhat 的 `console.sol` 并编写一个小型 js 单元测试，就可以找回每一次（或每一组）调用所使用的确切参数。

## 调整 hardhat.config.ts

由于构造函数内部包含大量调用，部署 Echidna 合约所需的 gas 过高。

将 `hardhat.config.ts` 调整为：

```json
hardhat: {
    allowUnlimitedContractSize: true,
    gas: 950000000,
    blockGasLimit: 950000000,
    gasPrice: 1,
},
```

### E2E_swap：找回池子初始化参数和所创建的头寸

池子初始化和头寸创建是确定性的，并且有一个 `view` 函数可以返回任意特定 `_amount`（用作 `_seed`）将会创建的内容。

编写一个 js 单元测试：

```js
console.log(await E2E_swap.viewRandomInit('<the _amount of the first swap call>'))
```

### E2E_swap：找回某次兑换所使用的 priceLimit

priceLimit 取决于池子合约的状态，因此最简单的找回方式是使用 hardhat 的 `console.sol`。

取消注释以下几行：

- 在 `E2E_swap.sol` 顶部：`// import 'hardhat/console.sol';`
- 在各个兑换函数内部：`// console.log('sqrtPriceLimitX96 = %s', sqrtPriceLimitX96); `

假设 Echidna 报告的不是一次兑换调用，而是两次兑换调用，并且第二次调用导致了断言失败。

```js
// 获取池子参数 + 所创建的头寸
console.log(await E2E_swap.viewRandomInit('<the _amount of the first swap call>'))

// 执行该兑换，这将创建上述内容，并把所使用的 priceLimit 输出到控制台
await E2E_swap.test_swap_exactOut_oneForZero('<the _amount of the first swap call>')

// 执行该兑换，把所使用的 priceLimit 输出到控制台
await E2E_swap.test_swap_exactIn_oneForZero('<the _amount of the second swap call>')
```

### E2E_mint_burn：找回池子初始化参数

池子初始化参数的生成是确定性的，并且有一个 `view` 函数可以返回任意特定 `_amount`（用作 `_seed`）将会创建的内容。

编写一个 js 单元测试：

```js
console.log(await E2E_mint_burn.viewInitRandomPoolParams('<the _amount of the first mint call>'))
```

### E2E_mint_burn：找回某次铸造所创建的随机头寸

```js
const poolInitParams = await E2E_mint_burn.viewInitRandomPoolParams('<the _amount of the first mint call>')

const positionParams = await E2E_mint_burn.viewMintRandomNewPosition(
  '<the _amount of the first mint call>',
  poolInitParams.tickSpacing,
  poolInitParams.tickCount,
  poolInitParams.maxTick
)

console.log(positionParams)
```

### E2E_mint_burn：找回某次销毁所使用的头寸

取消注释以下几行：

- 在 `E2E_mint_burn.sol` 顶部：`// import 'hardhat/console.sol';`
- 在相应的销毁函数内部：`// console.log('burn posIdx = %s', posIdx);`
- 如果这是一次部分销毁，你还会想查看被销毁的数量。在 `test_burn_partial` 函数内部：`// console.log('burn amount = %s', burnAmount);`

然后在 js 测试中执行该销毁。

```js
// 显示池子初始化参数
const poolInitParams = await E2E_mint_burn.viewInitRandomPoolParams('<the _amount of the first mint call>')
console.log(positionParams)

// 显示池子铸造所创建的头寸参数
const positionParams = await E2E_mint_burn.viewMintRandomNewPosition(
  '<the _amount of the first mint call>',
  poolInitParams.tickSpacing,
  poolInitParams.tickCount,
  poolInitParams.maxTick
)
console.log(positionParams)

// 执行第一次铸造
await E2E_mint_burn.test_mint('<the _amount of the first mint call>')

// 执行销毁
await E2E_mint_burn.test_burn_partial('<the _amount of the first test_burn_partial call>')
// 这应当会把被销毁头寸的索引输出到控制台，
// 以及被销毁的数量。
// 结合上面的输出，应当就能清楚看出究竟是哪个头寸
// 被销毁了，以及销毁了多少
```

# 使用 Manticore 进行验证

验证是使用实验性分支 [dev-evm-experiments](https://github.com/trailofbits/manticore/tree/dev-evm-experiments) 完成的，该分支包含新的优化，目前仍在开发中。一旦该分支趋于稳定并被纳入 Manticore 的正式发布版本，Trail of Bits 将确保以下性质依然成立。

为方便起见，我们遵循“如果存在可达路径，就存在 bug”的模式。

要验证某个性质，请运行：

```
manticore . --contract CONTRACT_NAME --txlimit 1 --smt.solver all --quick-mode --lazy-evaluation --core.procs 1
```

> 一旦 `dev-evm-experiments` 趋于稳定，该命令可能会发生变化

Manticore 会创建一个 `mcore_X` 目录。如果没有生成 `X.tx` 文件，则说明 Manticore 没有找到违反该性质的路径。

| ID  | 描述                                                                                                 | 合约                                                                  | 状态     |
| --- | ---------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------- | -------- |
| 01  | `BitMath.mostSignificantBit returns a value in x >= 2**msb && (msb == 255 or x < 2**(msb+1)).`       | [`VerifyBitMathMsb`](./contracts/crytic/manticore/001.sol)            | 已验证   |
| 02  | `BitMath.leastSignificantBit returns a value in ((x & 2** lsb) != 0) && ((x & (2**(lsb -1))) == 0).` | [`VerifyBitMathLsb`](./contracts/crytic/manticore/002.sol)            | 已验证   |
| 03  | `If LiquidityMath.addDelta returns, the value will be equal to x + uint128(y).`                      | [`VerifyLiquidityMathAddDelta`](./contracts/crytic/manticore/003.sol) | 已验证   |
