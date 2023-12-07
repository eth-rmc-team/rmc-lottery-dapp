// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./Whitelisted.sol";
import "./Interfaces/IPrizepoolDispatcher.sol";
import "./Interfaces/IDiscoveryService.sol";
import "../Lotteries/Interfaces/ILotteryGame.sol";
import "../Tickets/Interfaces/ISpecialTicketMinter.sol";
import "../Librairies/LotteryDef.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

contract TicketFusion is Whitelisted, ReentrancyGuard {
    address private owner;

    address private addrFeeManager;
    address private addrLotteryGame;

    uint8 public normalTicketFusionRequirement = 7;
    uint8 public goldTicketFusionRequirement = 5;

    IDiscoveryService private discoveryService;
    ILotteryGame private lotteryGame;

    using SafeMath for uint256;
    using LotteryDef for LotteryDef.Period;

    constructor() {
        owner = msg.sender;
    }

    function setDiscoveryService(address _address) external onlyAdmin {
        discoveryService = IDiscoveryService(_address);
    }

    function setLotteryGame() external onlyAdmin {
        lotteryGame = ILotteryGame(discoveryService.getLotteryGameAddr());
    }

    //Function setting the normal ticket fusion requirement
    function setNormalTicketFusionRequirement(
        uint8 _normalTicketFusionRequirement
    ) external onlyAdmin {
        normalTicketFusionRequirement = _normalTicketFusionRequirement;
    }

    //function setting the gold ticket fusion requirement
    function setGoldTicketFusionRequirement(
        uint8 _goldTicketFusionRequirement
    ) external onlyAdmin {
        goldTicketFusionRequirement = _goldTicketFusionRequirement;
    }

    //
    // @dev This function allows the owner of normal tickets to fuse them into a gold ticket.
    // @param tokenIds An array of uint values representing the token IDs of the normal tickets to be fused.
    // @return None.
    // Requirements:
    //   The user must have at least normalTicketFusionRequirement normal tickets.
    //   The tokenIds array must have a length of normalTicketFusionRequirement.
    //   Each token in the tokenIds array must belong to the calling user.
    // Effects:
    //   The normal tickets with the specified token IDs are burned (destroyed).
    //   The calling user is awarded a new gold ticket.
    //
    function fusionNormalTickets(uint[] memory tokenIds) external nonReentrant {
        require(
            lotteryGame.getCurrentPeriod() == LotteryDef.Period.CHASE,
            "ERROR :: Fusion is not allowed while a lottery is live or ended"
        );

        uint256 balance = ISpecialTicketMinter(
            discoveryService.getNormalTicketAddr()
        ).balanceOf(msg.sender);

        require(
            balance >= normalTicketFusionRequirement,
            "WARNING :: Not enough Normal Tickets."
        );

        require(
            tokenIds.length == normalTicketFusionRequirement,
            "WARNING :: Incorrect number of presented tickets (must be 7 normal tickets)."
        );

        // Check ownership of the normal tickets
        for (uint i = 0; i < normalTicketFusionRequirement; i++) {
            require(
                ISpecialTicketMinter(discoveryService.getNormalTicketAddr())
                    .ownerOf(tokenIds[i]) == msg.sender,
                "WARNING :: Token does not belong to user."
            );
        }

        // Burn the normal tickets
        for (uint i = 0; i < normalTicketFusionRequirement; i++) {
            if (tokenIds[i].mod(100) != 0)
                ISpecialTicketMinter(discoveryService.getNormalTicketAddr())
                    .burn(tokenIds[i]);
        }

        // mint of gold ticket
        if (
            ISpecialTicketMinter(discoveryService.getNormalTicketAddr())
                .balanceOf(msg.sender) ==
            balance.sub(normalTicketFusionRequirement)
        )
            ISpecialTicketMinter(discoveryService.getGoldTicketAddr())
                .mintSpecial(msg.sender, LotteryDef.TicketType.GOLD);
        else revert("TicketFusion :: Error while minting gold ticket");
    }

    function fusionGoldTickets(uint[] memory tokenIds) external nonReentrant {
        require(
            ISpecialTicketMinter(discoveryService.getGoldTicketAddr())
                .totalSupply() > goldTicketFusionRequirement,
            "ERROR :: Enable to fuse when there is just one gold ticket left"
        );

        require(
            lotteryGame.getCurrentPeriod() == LotteryDef.Period.CHASE,
            "ERROR :: Fusion is not allowed while a lottery is live or ended"
        );

        uint256 balance = ISpecialTicketMinter(
            discoveryService.getGoldTicketAddr()
        ).balanceOf(msg.sender);

        require(
            balance >= goldTicketFusionRequirement,
            "WARNING :: Not enough Gold Tickets."
        );

        require(
            tokenIds.length == goldTicketFusionRequirement,
            "WARNING :: Incorrect number of presented tickets (must be 5 Gold tickets)."
        );

        // Check ownership of the normal tickets
        for (uint i = 0; i < goldTicketFusionRequirement; i++) {
            require(
                ISpecialTicketMinter(discoveryService.getGoldTicketAddr())
                    .ownerOf(tokenIds[i]) == msg.sender,
                "WARNING :: Ticket does not belong to user."
            );
        }

        // Burn the normal tickets
        for (uint i = 0; i < goldTicketFusionRequirement; i++) {
            ISpecialTicketMinter(discoveryService.getGoldTicketAddr()).burn(
                tokenIds[i]
            );
        }

        //console.log("DEBUG :: nonce = %s", nonce);

        // mint of supergold ticket
        if (
            ISpecialTicketMinter(discoveryService.getGoldTicketAddr())
                .balanceOf(msg.sender) ==
            balance.sub(goldTicketFusionRequirement)
        )
            ISpecialTicketMinter(discoveryService.getSuperGoldTicketAddr())
                .mintSpecial(msg.sender, LotteryDef.TicketType.SUPERGOLD);
        else revert("TicketFusion :: Error while minting supergold ticket");
    }
}
