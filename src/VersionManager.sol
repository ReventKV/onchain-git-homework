// contracts/VersionManager.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {UpgradeableBeacon} from "@openzeppelin/contracts/proxy/beacon/UpgradeableBeacon.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract VersionManager is Ownable {
    UpgradeableBeacon public beacon;        // Ссылка на текущий Beacon
    address[] public versionHistory;        // История адресов реализаций
    uint256 public currentVersionIndex;     // Индекс активной версии

    event Upgraded(address indexed implementation, uint256 newIndex);
    event RolledBack(address indexed implementation, uint256 toIndex);

constructor(address initialImplementation) Ownable(msg.sender) {
    beacon = new UpgradeableBeacon(initialImplementation, address(this));
    versionHistory.push(initialImplementation);
    currentVersionIndex = 0;
}
    /// @notice Апгрейд логики: добавляем версию в историю и меняем Beacon.
    function upgradeTo(address newImplementation) public onlyOwner {
        require(newImplementation.code.length > 0, "Not a contract");
        beacon.upgradeTo(newImplementation);
        versionHistory.push(newImplementation);
        currentVersionIndex = versionHistory.length - 1;
        emit Upgraded(newImplementation, currentVersionIndex);
    }

    /// @notice Откат к ранее сохранённой реализации.
    function rollbackTo(uint256 index) public onlyOwner {
        require(index < versionHistory.length, "Invalid index");
        address impl = versionHistory[index];
        beacon.upgradeTo(impl);
        currentVersionIndex = index;
        emit RolledBack(impl, index);
    }

    function versionsCount() external view returns (uint256) {
        return versionHistory.length;
    }
}
