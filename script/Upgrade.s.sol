// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";

import {MyTokenV2} from "../src/MyTokenV2.sol";
import {VersionManager} from "../src/VersionManager.sol";

contract Upgrade is Script {
    function run() external returns (address newImplementation) {
        uint256 deployerPk = vm.envUint("PRIVATE_KEY");
        address managerAddress = vm.envAddress("VERSION_MANAGER");

        vm.startBroadcast(deployerPk);

        MyTokenV2 impl = new MyTokenV2();
        VersionManager(managerAddress).upgradeTo(address(impl));

        vm.stopBroadcast();

        console2.log("MyTokenV2:", address(impl));
        console2.log("VersionManager:", managerAddress);

        return address(impl);
    }
}
