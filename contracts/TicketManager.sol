// contracts/TicketManager.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./NormalTicket.sol";
import "./GoldTicket.sol";
import "./SuperGoldTicket.sol";
import "./MythicTicket.sol";


contract TicketManager {
    address private owner;
    NormalTicket private normalTicketContract;
    GoldTicket private goldTicketContract;
    SuperGoldTicket private superGoldTicketContract;
    MythicTicket private mythicTicketContract;

    // Nombre de Normal Tickets nécessaires pour fusionner en un Gold Ticket
    uint256 public normalTicketFusionRequirement;
    // Nombre de Gold Tickets nécessaires pour fusionner en un Super Gold Ticket
    uint256 public goldTicketFusionRequirement;

    constructor(
        address _normalTicketContract,
        address _goldTicketContract,
        address _superGoldTicketContract,
        address _mythicTicketContract,
        uint256 _normalTicketFusionRequirement,
        uint256 _goldTicketFusionRequirement
    ) {
        owner = msg.sender;
        normalTicketContract = NormalTicket(_normalTicketContract);
        goldTicketContract = GoldTicket(_goldTicketContract);
        superGoldTicketContract = SuperGoldTicket(_superGoldTicketContract);
        mythicTicketContract = MythicTicket(_mythicTicketContract);

        normalTicketFusionRequirement = _normalTicketFusionRequirement;
        goldTicketFusionRequirement = _goldTicketFusionRequirement;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }

    function setNormalTicketFusionRequirement(uint256 newRequirement) public onlyOwner {
        normalTicketFusionRequirement = newRequirement;
    }

    function getNormalTicketFusionRequirement() public view returns (uint256) {
        return normalTicketFusionRequirement;
    }

    function setGoldTicketFusionRequirement(uint256 newRequirement) public onlyOwner {
        goldTicketFusionRequirement = newRequirement;
    }

    function getGoldTicketFusionRequirement() public view returns (uint256) {
        return goldTicketFusionRequirement;
    }
    
    /** 
    * @dev This function allows the owner of normal tickets to fuse them into a gold ticket.
    * @param tokenIds An array of uint values representing the token IDs of the normal tickets to be fused.
    * @return None.
    * Requirements:
    *   The user must have at least normalTicketFusionRequirement normal tickets.
    *   The tokenIds array must have a length of normalTicketFusionRequirement.
    *   Each token in the tokenIds array must belong to the calling user.
    * Effects:
    *   The normal tickets with the specified token IDs are burned (destroyed).
    *   The calling user is awarded a new gold ticket.
    */
    function fusionNormalTickets(uint[] memory tokenIds) public {
        uint256 balance = goldTicketContract.balanceOf(msg.sender);
        require(balance >= normalTicketFusionRequirement, "Not enough Normal Tickets.");
        require(tokenIds.length == normalTicketFusionRequirement, "Incorrect number of tokens.");
        for (uint i = 0; i < normalTicketFusionRequirement; i++) {
            require(normalTicketContract.ownerOf(tokenIds[i]) == msg.sender, "Token does not belong to user.");
            normalTicketContract.burn(normalTicketContract.tokenOfOwnerByIndex(msg.sender, i));
        }
        goldTicketContract.mint(msg.sender);
    }

    /**
    * @dev This function allows the owner of gold tickets to fuse them into a super gold ticket.
    * @param tokenIds An array of uint values representing the token IDs of the gold tickets to be fused.
    * @return None.
    * Requirements:
    *   The user must have at least goldTicketFusionRequirement gold tickets.
    *   The tokenIds array must have a length of goldTicketFusionRequirement.
    *   Each token in the tokenIds array must belong to the calling user.
    * Effects:
    *   The gold tickets with the specified token IDs are transferred from the calling user to this contract.
    *   The calling user is awarded a new super gold ticket.
    */
    function fusionGoldTickets(uint[] memory tokenIds) public {
        uint256 balance = goldTicketContract.balanceOf(msg.sender);
        require(balance >= goldTicketFusionRequirement, "Not enough Gold Tickets.");
        require(tokenIds.length == goldTicketFusionRequirement, "Incorrect number of tokens.");
        for (uint i = 0; i < goldTicketFusionRequirement; i++) {
            require(goldTicketContract.ownerOf(tokenIds[i]) == msg.sender, "Token does not belong to user.");
            goldTicketContract.safeTransferFrom(msg.sender, address(this), tokenIds[i]);
        }
        superGoldTicketContract.mint(msg.sender);
    }

    function getNumberOfNormalTickets() public view returns (uint) {
        return normalTicketContract.totalSupply();
    }

    function getNumberOfGoldTickets() public view returns (uint) {
        return goldTicketContract.totalSupply();
    }

    function getNumberOfSuperGoldTickets() public view returns (uint) {
        return superGoldTicketContract.totalSupply();
    }

    function getNumberOfMythicTickets() public view returns (uint) {
        return mythicTicketContract.totalSupply();
    }
}