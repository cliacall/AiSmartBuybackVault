// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @notice 模块Schema接口 — 用于前端表单自动生成
interface IOpenFourModuleSchema {
    struct ParamDescriptor {
        string name;
        string title;
        string description;
        string typeName;
        bool isOptional;
        bytes32 defaultValue;
        bytes32 minValue;
        bytes32 maxValue;
    }

    struct ModuleEncodeSchema {
        uint8 moduleKind;      // 0=Token,1=Vault,2=Curve,3=Trade,4=Migrate,5=CustomData
        string moduleTag;
        ParamDescriptor[] initParamDescriptors;
    }

    function moduleEncodeSchema() external pure returns (ModuleEncodeSchema memory);
}
