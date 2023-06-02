// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/AccessControl.sol";

contract Whitelisted is AccessControl {
    bytes32 public constant WHITELISTED_ROLE = keccak256("WHITELISTED_ROLE");

    modifier onlyWhitelisted() {
        require(hasRole(WHITELISTED_ROLE, msg.sender), "Only whitelisted addresses allowed");
        _;
    }

    modifier onlyAdmin() {
        require(hasRole(DEFAULT_ADMIN_ROLE, msg.sender), "Only admin addresses allowed");
        _;
    }

    constructor() {
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }

    function addToWhitelist(address addr) external onlyAdmin {
        grantRole(WHITELISTED_ROLE, addr);
    }

    function removeFromWhitelist(address addr) external onlyAdmin {
        revokeRole(WHITELISTED_ROLE, addr);
    }

    function addToAdminList(address addr) external onlyAdmin {
        grantRole(DEFAULT_ADMIN_ROLE, addr);
    }

    function removeFromAdminList(address addr) external onlyAdmin {
        revokeRole(DEFAULT_ADMIN_ROLE, addr);
    }
}