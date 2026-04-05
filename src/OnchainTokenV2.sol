// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./OnchainTokenV1.sol";
import "./OnchainGitStorage.sol";

contract OnchainTokenV2 is OnchainTokenV1 {
    using OnchainGitStorage for OnchainGitStorage.MainStorage;

    // ===== Новая логика =====
    function burn(uint256 amount) public {
        OnchainGitStorage.MainStorage storage ds = OnchainGitStorage.layout();

        require(ds.balances[msg.sender] >= amount, "Not enough tokens");

        ds.balances[msg.sender] -= amount;
        ds.totalSupply -= amount;

        emit Transfer(msg.sender, address(0), amount);
    }

    function version() public pure returns (string memory) {
        return "V2.0.0";
    }
}