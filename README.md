# AiSmartBuybackVault

AI智能回购金库 — AI监控市场交易活动，智能决策回购时机

## OpenFour 模块

直接集成到 four.meme OpenFour 发射引擎中。

## 合约架构

```
contracts/
├── AiSmartBuybackVault.sol              # 主合约
├── interfaces/
│   ├── IOpenFourVault.sol   # OpenFour Vault 接口
│   ├── ITagDescriptor.sol   # 模块标签接口
│   └── IOpenFourModuleSchema.sol  # 前端表单Schema接口
```

## 部署

1. 访问 https://four.meme/zh-TW/contract/create
2. 上传合约文件
3. 填写信息并提交审核
