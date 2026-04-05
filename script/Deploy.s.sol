// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console2} from "forge-std/Script.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import {MyTokenV1} from "../src/MyTokenV1.sol";
import {VersionManager} from "../src/VersionManager.sol";

contract Deploy is Script {
    function run() external returns (address proxy, address versionManager, address implementation, address beacon) {
        uint256 deployerPk = vm.envUint("PRIVATE_KEY");

        vm.startBroadcast(deployerPk);

        MyTokenV1 impl = new MyTokenV1();
        VersionManager manager = new VersionManager(address(impl));

        bytes memory initData = abi.encodeCall(
            MyTokenV1.initialize,
            ("Beacon Token", "BKN")
        );

        BeaconProxy proxyContract = new BeaconProxy(address(manager.beacon()), initData);

        vm.stopBroadcast();

        console2.log("MyTokenV1:", address(impl));
        console2.log("VersionManager:", address(manager));
        console2.log("Beacon:", address(manager.beacon()));
        console2.log("Proxy:", address(proxyContract));

        return (address(proxyContract), address(manager), address(impl), address(manager.beacon()));
    }
}
