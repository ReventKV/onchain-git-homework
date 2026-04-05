// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

import "./OnchainGitStorage.sol";

contract OnchainTokenV1 is UUPSUpgradeable, OwnableUpgradeable {
    using OnchainGitStorage for OnchainGitStorage.MainStorage;

    event Transfer(address indexed from, address indexed to, uint256 value);

    // ===== Initialize =====
    function initialize(string memory name_, string memory symbol_)
        public
        initializer
    {
        __Ownable_init(msg.sender);

        OnchainGitStorage.MainStorage storage ds = OnchainGitStorage.layout();
        ds.name = name;
        ds.symbol = symbol;

        // сохраняем первую implementation
        ds.versionHistory.push(_getImplementation());
        ds.currentVersionIndex = 0;
    }

    // ===== ERC20-like =====

    function name() public view returns (string memory) {
        return OnchainGitStorage.layout().name;
    }

    function symbol() public view returns (string memory) {
        return OnchainGitStorage.layout().symbol;
    }

    function totalSupply() public view returns (uint256) {
        return OnchainGitStorage.layout().totalSupply;
    }

    function balanceOf(address account) public view returns (uint256) {
        return OnchainGitStorage.layout().balances[account];
    }

    function transfer(address to, uint256 amount) public returns (bool) {
        OnchainGitStorage.MainStorage storage ds = OnchainGitStorage.layout();

        require(ds.balances[msg.sender] >= amount, "Insufficient balance");

        ds.balances[msg.sender] -= amount;
        ds.balances[to] += amount;

        emit Transfer(msg.sender, to, amount);
        return true;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        OnchainGitStorage.MainStorage storage ds = OnchainGitStorage.layout();

        ds.totalSupply += amount;
        ds.balances[to] += amount;

        emit Transfer(address(0), to, amount);
    }

    // ===== Versioning =====

    function getVersionHistory() public view returns (address[] memory) {
        return OnchainGitStorage.layout().versionHistory;
    }

    function rollbackTo(uint256 index) public onlyOwner {
        OnchainGitStorage.MainStorage storage ds = OnchainGitStorage.layout();

        require(index < ds.versionHistory.length, "Index out of bounds");

        address target = ds.versionHistory[index];
        ds.currentVersionIndex = index;

        upgradeTo(target);
    }

    // ===== UUPS =====

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {
        OnchainGitStorage.MainStorage storage ds = OnchainGitStorage.layout();

        ds.versionHistory.push(newImplementation);
        ds.currentVersionIndex = ds.versionHistory.length - 1;
    }

    // ===== Helper =====

    function _getImplementation() internal view returns (address impl) {
        bytes32 slot = 0x360894A13BA1A3210667C828492DB98DCA3E2076CC3735A920A3CA505D382BBC;
        assembly {
            impl := sload(slot)
        }
    }

    function upgradeTo(address newImplementation)
    public
    override
    onlyOwner
{
    _authorizeUpgrade(newImplementation);
    _upgradeToAndCallUUPS(newImplementation, bytes(""), false);
}
}