// contracts/MyTokenV2.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {MyTokenV1} from "./MyTokenV1.sol";

contract MyTokenV2 is MyTokenV1 {
    /// @notice Функция чеканки токенов (доступна только владельцу).
    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}
