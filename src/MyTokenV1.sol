// contracts/MyTokenV1.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20Upgradeable} from "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MyTokenV1 is ERC20Upgradeable, OwnableUpgradeable {
    /// @notice Инициализация (вместо конструктора).
    function initialize(string memory name, string memory symbol) public initializer {
        __ERC20_init(name, symbol);
        __Ownable_init(msg.sender); // Устанавливает msg.sender как владельца
    }

    // В V1 нет функции mint – будет добавлена в V2.
}
