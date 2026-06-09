// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice Vault模块接口 — 资产托管和税分配
interface IOpenFourVault {
    /// @notice 初始化vault
    function init(address token, address fourCore, bytes calldata params, string calldata moduleVersion) external;

    /// @notice 买入时调用（接收买入时扣除的税）
    function onBuy(address payer, uint256 amount, uint256 payment, uint256 share, bytes calldata extraData) external;

    /// @notice 卖出时调用（接收卖出时扣除的税）
    function onSell(address seller, uint256 amount, uint256 payment, uint256 share, bytes calldata extraData) external;

    /// @notice 查询vault余额
    function vaultBalance() external view returns (uint256);

    /// @notice 获取初始化参数
    function getInitParams() external view returns (bytes memory);
}
