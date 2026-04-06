// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

library OnchainGitStorage {
    bytes32 internal constant STORAGE_SLOT = keccak256("onchaingit.storage.erc20.versioning");

    struct MainStorage {
        // ERC20-like
        string name;
        string symbol;
        uint256 totalSupply;
        mapping(address => uint256) balances;

        // Versioning
        address[] versionHistory;
        uint256 currentVersionIndex;
    }

    function layout() internal pure returns (MainStorage storage ds) {
        bytes32 slot = STORAGE_SLOT;
        assembly {
            ds.slot := slot
        }
    }
}
