// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.5.0;

/// @title 无需许可的池子操作
/// @notice 包含任何人都可以调用的池子方法
interface IUniswapV3PoolActions {
    /// @notice 设置池子的初始价格
    /// @dev 价格表示为 sqrt(amountToken1/amountToken0) 的 Q64.96 值
    /// @param sqrtPriceX96 池子的初始平方根价格，格式为 Q64.96
    function initialize(uint160 sqrtPriceX96) external;

    /// @notice 为给定的 recipient/tickLower/tickUpper 头寸添加流动性
    /// @dev 本方法的调用者会收到一个形式为 IUniswapV3MintCallback#uniswapV3MintCallback 的回调，
    /// 调用者必须在该回调中支付该流动性所欠的 token0 或 token1。应付的 token0/token1 数量取决于
    /// tickLower、tickUpper、流动性数量以及当前价格。
    /// @param recipient 将为其创建流动性的地址
    /// @param tickLower 要添加流动性的头寸的下界 tick
    /// @param tickUpper 要添加流动性的头寸的上界 tick
    /// @param amount 要铸造的流动性数量
    /// @param data 需要透传给回调的任意数据
    /// @return amount0 为铸造给定数量的流动性而支付的 token0 数量，与回调中的值一致
    /// @return amount1 为铸造给定数量的流动性而支付的 token1 数量，与回调中的值一致
    function mint(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount,
        bytes calldata data
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice 提取欠付给某个头寸的代币
    /// @dev 不会重新计算已赚取的手续费，重新计算须通过铸造或销毁任意数量的流动性来完成。
    /// 必须由头寸所有者调用 collect。若只想取出 token0 或只取出 token1，可将 amount0Requested 或
    /// amount1Requested 设为零。若要取出全部欠付代币，调用者可以传入任何大于
    /// 实际欠付代币数量的值，例如 type(uint128).max。欠付代币可能来自累计的兑换手续费或已销毁的流动性。
    /// @param recipient 接收所提取手续费的地址
    /// @param tickLower 要提取手续费的头寸的下界 tick
    /// @param tickUpper 要提取手续费的头寸的上界 tick
    /// @param amount0Requested 要从欠付手续费中取出多少 token0
    /// @param amount1Requested 要从欠付手续费中取出多少 token1
    /// @return amount0 以 token0 计的已提取手续费数量
    /// @return amount1 以 token1 计的已提取手续费数量
    function collect(
        address recipient,
        int24 tickLower,
        int24 tickUpper,
        uint128 amount0Requested,
        uint128 amount1Requested
    ) external returns (uint128 amount0, uint128 amount1);

    /// @notice 销毁调用者（sender）的流动性，并将该流动性对应的欠付代币记入头寸
    /// @dev 可通过以数量 0 调用本方法，来触发对头寸欠付手续费的重新计算
    /// @dev 手续费必须通过调用 #collect 单独提取
    /// @param tickLower 要销毁流动性的头寸的下界 tick
    /// @param tickUpper 要销毁流动性的头寸的上界 tick
    /// @param amount 要销毁的流动性数量
    /// @return amount0 发送给接收者的 token0 数量
    /// @return amount1 发送给接收者的 token1 数量
    function burn(
        int24 tickLower,
        int24 tickUpper,
        uint128 amount
    ) external returns (uint256 amount0, uint256 amount1);

    /// @notice 用 token0 兑换 token1，或用 token1 兑换 token0
    /// @dev 本方法的调用者会收到一个形式为 IUniswapV3SwapCallback#uniswapV3SwapCallback 的回调
    /// @param recipient 接收兑换输出的地址
    /// @param zeroForOne 兑换方向，true 表示 token0 换 token1，false 表示 token1 换 token0
    /// @param amountSpecified 兑换的数量，其正负隐式地将兑换设定为精确输入（正数）或精确输出（负数）
    /// @param sqrtPriceLimitX96 Q64.96 格式的平方根价格限制。若为 zero for one 方向，兑换后价格不能低于
    /// 该值。若为 one for zero 方向，兑换后价格不能高于该值
    /// @param data 需要透传给回调的任意数据
    /// @return amount0 池子 token0 余额的变化量，为负时是精确值，为正时是最小值
    /// @return amount1 池子 token1 余额的变化量，为负时是精确值，为正时是最小值
    function swap(
        address recipient,
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96,
        bytes calldata data
    ) external returns (int256 amount0, int256 amount1);

    /// @notice 接收 token0 和/或 token1，并在回调中连同手续费一起归还
    /// @dev 本方法的调用者会收到一个形式为 IUniswapV3FlashCallback#uniswapV3FlashCallback 的回调
    /// @dev 可用于按比例向当前在区间内的流动性提供者捐赠底层代币，方法是
    /// 以为 0 的 amount{0,1} 调用本方法，并在回调中发送捐赠数量
    /// @param recipient 将接收 token0 和 token1 数量的地址
    /// @param amount0 要发送的 token0 数量
    /// @param amount1 要发送的 token1 数量
    /// @param data 需要透传给回调的任意数据
    function flash(
        address recipient,
        uint256 amount0,
        uint256 amount1,
        bytes calldata data
    ) external;

    /// @notice 增加本池子将存储的价格与流动性观测值的最大数量
    /// @dev 如果池子当前的 observationCardinalityNext 已大于或等于
    /// 传入的 observationCardinalityNext，则本方法不执行任何操作。
    /// @param observationCardinalityNext 期望池子存储的观测值的最小数量
    function increaseObservationCardinalityNext(uint16 observationCardinalityNext) external;
}
