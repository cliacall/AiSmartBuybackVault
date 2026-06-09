// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./interfaces/IOpenFourVault.sol";
import "./interfaces/IOpenFourModuleSchema.sol";
import "./interfaces/ITagDescriptor.sol";

/// @title AiSmartBuybackVault — AI智能回购金库
/// @notice AI监控市场交易活动，智能决策何时回购代币。回购后全部销毁，从不持有
contract AiSmartBuybackVault is IOpenFourVault, IOpenFourModuleSchema, ITagDescriptor {
    struct BuybackConfig {
        address aiOracle;          // AI预言机地址（决定何时回购）
        uint256 minPriceDrop;      // 最低价格跌幅触发阈值(bps)
        uint256 maxBuybackPerTx;   // 单次最大回购金额
        uint256 cooldownPeriod;    // 回购冷却时间
    }

    mapping(address => BuybackConfig) internal _configs;
    mapping(address => uint256) internal _accumulated;
    mapping(address => uint256) internal _totalBurned;
    mapping(address => uint256) internal _lastBuybackTime;
    address internal _fourCore;

    modifier onlyCore() { require(msg.sender == _fourCore, "!core"); _; }
    error AlreadyInitialized();

    function init(address token, address fourCore, bytes calldata params, string calldata) external {
        if (address(_fourCore) != address(0)) revert AlreadyInitialized();
        _fourCore = fourCore;
        _configs[token] = abi.decode(params, (BuybackConfig));
    }

    function onBuy(address, uint256, uint256 payment, uint256, bytes calldata) external onlyCore {
        _accumulated[msg.sender] += payment;
    }

    function onSell(address, uint256, uint256 payment, uint256, bytes calldata) external onlyCore {
        _accumulated[msg.sender] += payment;
    }

    function vaultBalance() external view returns (uint256) {
        return _accumulated[msg.sender];
    }

    /// @notice 执行AI驱动的回购（由AI预言机触发）
    function executeBuyback(address token, uint256 amount) external {
        BuybackConfig storage cfg = _configs[token];
        require(msg.sender == cfg.aiOracle || msg.sender == _fourCore, "!oracle");
        require(block.timestamp >= _lastBuybackTime[token] + cfg.cooldownPeriod, "cooldown");
        require(amount <= cfg.maxBuybackPerTx, "exceeds max");
        require(amount <= _accumulated[token], "insufficient BNB");
        _accumulated[token] -= amount;
        _lastBuybackTime[token] = block.timestamp;
        // In production: swap BNB for tokens on DEX, then burn them
        // For OpenFour: Core handles the swap and calls back to burn
    }

    /// @notice 记录销毁（Core在回购后调用）
    function recordBurn(address token, uint256 burnAmount) external onlyCore {
        _totalBurned[token] += burnAmount;
    }

    function getInitParams() external pure returns (bytes memory) {
        return abi.encode(BuybackConfig({aiOracle: address(0), minPriceDrop: 500, maxBuybackPerTx: 1 ether, cooldownPeriod: 1 hours}));
    }

    function moduleEncodeSchema() external pure returns (ModuleEncodeSchema memory) {
        ParamDescriptor[] memory params = new ParamDescriptor[](4);
        params[0] = ParamDescriptor("aiOracle", "AI预言机地址", "AI决策合约地址", "address", false, bytes32(0), bytes32(0), bytes32(type(uint160).max));
        params[1] = ParamDescriptor("minPriceDrop", "最低价格跌幅(bps)", "触发回购的最低跌幅,5%=500", "uint256", false, bytes32(uint256(500)), bytes32(uint256(0)), bytes32(uint256(10000)));
        params[2] = ParamDescriptor("maxBuybackPerTx", "单次最大回购(wei)", "单笔最大回购BNB数量", "uint256", false, bytes32(uint256(1 ether)), bytes32(uint256(0)), bytes32(type(uint256).max));
        params[3] = ParamDescriptor("cooldownPeriod", "回购冷却(秒)", "两次回购之间的最小间隔", "uint256", false, bytes32(uint256(1 hours)), bytes32(uint256(0)), bytes32(uint256(7 days)));
        return ModuleEncodeSchema(1, "module.vault.ai-buyback", params);
    }

    function descriptor() external pure returns (bytes8 tagId, string memory tag, string memory version) {
        tagId = bytes8(keccak256(bytes("module.vault.ai-buyback")));
        tag = "module.vault.ai-buyback";
        version = "v1.0.0";
    }
}
