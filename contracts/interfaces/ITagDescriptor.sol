// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice 标签描述接口 — 每个模块/代币都必须实现
interface ITagDescriptor {
    function descriptor() external view returns (bytes8 tagId, string memory tag, string memory version);
}
