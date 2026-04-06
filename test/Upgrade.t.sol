// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {BeaconProxy} from "@openzeppelin/contracts/proxy/beacon/BeaconProxy.sol";

import {MyTokenV1} from "../src/MyTokenV1.sol";
import {MyTokenV2} from "../src/MyTokenV2.sol";
import {VersionManager} from "../src/VersionManager.sol";

contract UpgradeTest is Test {
    MyTokenV1 internal proxyToken;
    VersionManager internal manager;
    MyTokenV1 internal implV1;
    MyTokenV2 internal implV2;

    address internal owner = address(this);
    address internal alice = address(0xA11CE);

    function setUp() public {
        implV1 = new MyTokenV1();

        manager = new VersionManager(address(implV1));

        bytes memory initData = abi.encodeCall(MyTokenV1.initialize, ("Beacon Token", "BKN"));

        proxyToken = MyTokenV1(address(new BeaconProxy(address(manager.beacon()), initData)));
    }

    // =========================
    // BASIC REVERT TESTS
    // =========================

    function testUpgradeUnauthorizedReverts() public {
        implV2 = new MyTokenV2();

        vm.prank(alice);
        vm.expectRevert();
        manager.upgradeTo(address(implV2));
    }

    function testRollbackUnauthorizedReverts() public {
        vm.prank(alice);
        vm.expectRevert();
        manager.rollbackTo(0);
    }

    function testRollbackInvalidIndexReverts() public {
        vm.expectRevert(bytes("VersionManager: invalid index"));
        manager.rollbackTo(999);
    }

    function testUpgradeZeroAddressReverts() public {
        vm.expectRevert(bytes("VersionManager: zero implementation"));
        manager.upgradeTo(address(0));
    }

    // =========================
    // CORE FUNCTIONAL TESTS
    // =========================

    function testUpgradeWorks() public {
        implV2 = new MyTokenV2();

        manager.upgradeTo(address(implV2));

        assertEq(manager.currentVersionIndex(), 1);
        assertEq(manager.currentImplementation(), address(implV2));
        assertEq(manager.beacon().implementation(), address(implV2));
    }

    function testRollbackWorks() public {
        implV2 = new MyTokenV2();

        manager.upgradeTo(address(implV2));
        manager.rollbackTo(0);

        assertEq(manager.currentVersionIndex(), 0);
        assertEq(manager.currentImplementation(), address(implV1));
    }

    // =========================
    // OTHER TESTS
    // =========================

    // 1. STATE MUST PERSIST
    function testStatePersistsAcrossUpgradeAndRollback() public {
        implV2 = new MyTokenV2();

        manager.upgradeTo(address(implV2));

        MyTokenV2(address(proxyToken)).mint(alice, 100);

        manager.rollbackTo(0);

        // состояние не должно исчезнуть
        assertEq(proxyToken.balanceOf(alice), 100);
    }

    // 2. BEACON: ALL PROXIES UPDATE TOGETHER
    function testAllProxiesUpgradeTogether() public {
        bytes memory initData = abi.encodeCall(MyTokenV1.initialize, ("Token2", "T2"));

        MyTokenV1 secondProxy = MyTokenV1(address(new BeaconProxy(address(manager.beacon()), initData)));

        implV2 = new MyTokenV2();
        manager.upgradeTo(address(implV2));

        MyTokenV2(address(proxyToken)).mint(alice, 10);
        MyTokenV2(address(secondProxy)).mint(alice, 5);

        assertEq(proxyToken.balanceOf(alice), 10);
        assertEq(secondProxy.balanceOf(alice), 5);
    }

    // 3. FUNCTION DISAPPEARS AFTER ROLLBACK
    function testFunctionDisappearsAfterRollback() public {
        implV2 = new MyTokenV2();

        manager.upgradeTo(address(implV2));
        manager.rollbackTo(0);

        vm.expectRevert();
        MyTokenV2(address(proxyToken)).mint(alice, 1);
    }
}
