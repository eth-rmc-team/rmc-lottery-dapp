// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../../Services/Interfaces/IDiscoveryService.sol";

import "../../Services/Whitelisted.sol";
import "../../Tickets/Interfaces/ISpecialTicketMinter.sol";
import "../ASideLotteryGame.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

contract Season1SilverLottery is ASideLotteryGame {
    uint256[] public platinTokenIds;
    uint256[] public goldTokenIds;

    uint16 public totalNormalTicketsBurnt;

    using SafeMath for uint256;
    using SafeMath for uint16;

    constructor() payable {
        isSideLotteryRunning = false;
        isWinnersDrawn = false;
    }

    function setSideLottery(
        LotteryDef.TicketType _type,
        uint256 _prefix,
        uint8 _denominator
    ) external onlyAdmin {
        ticketType = _type;
        prefix = _prefix;
        denominator = _denominator;

        lotteryId = super.getLotteryId();
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function burnTicket(
        uint256[] memory tokenIds
    ) external override nonReentrant {
        for (uint i = 0; i < tokenIds.length; i++) {
            uint256 prefixToken = tokenIds[i];
            prefixToken = prefixToken.div(denominator);
            uint8 lotteryIdToken = uint8(tokenIds[i] % 100);

            if (lotteryIdToken != lotteryId) {
                revert("ERROR :: Wrong lotteryId");
            }

            if (prefixToken != prefix) {
                revert("ERROR :: Wrong prefix");
            }

            require(
                ISpecialTicketMinter(discoveryService.getGoldTicketAddr())
                    .ownerOf(tokenIds[i]) == msg.sender,
                "You are not the owner of this ticket"
            );

            ISpecialTicketMinter(discoveryService.getNormalTicketAddr()).burn(
                tokenIds[i]
            );

            totalNormalTicketsBurnt++;
            users.push(msg.sender);
        }
    }

    function getWinners(
        uint8 nbDraws
    )
        external
        override
        onlyWhenLotteryRunning
        onlyAdmin
        returns (address[] memory _winners)
    {
        _winners = super.getWinnersAddr(nbDraws);
        isWinnersDrawn = true;

        return _winners;
    }

    function claimReward() external override isWinnersBeenDrawn nonReentrant {
        if (ticketType == LotteryDef.TicketType.PLATIN) {
            claimPlatin();
        } else if (ticketType == LotteryDef.TicketType.GOLD) {
            claimGold();
        } else {
            revert("ERROR :: No prizepool set");
        }
    }

    function claimPlatin() internal {
        address winner;

        for (uint i = 0; i < winners.length; i++) {
            if (winners[i] == msg.sender) {
                winner = winners[i];
                winners[i] = address(0);
                ISpecialTicketMinter(discoveryService.getPlatiniumTicketAddr())
                    .safeTransferFrom(
                        discoveryService.getLotteryGameAddr(),
                        winner,
                        platinTokenIds[i]
                    );
                emit ClaimedPrizePool(winner, platinTokenIds[i]);
            }
        }
    }

    function claimGold() internal {
        address winner;

        for (uint i = 0; i < winners.length; i++) {
            if (winners[i] == msg.sender) {
                winner = winners[i];
                winners[i] = address(0);
                ISpecialTicketMinter(discoveryService.getGoldTicketAddr())
                    .safeTransferFrom(
                        discoveryService.getLotteryGameAddr(),
                        winner,
                        goldTokenIds[i]
                    );
                emit ClaimedPrizePool(winner, goldTokenIds[i]);
            }
        }
    }

    function getPlatinTokenIds() internal {
        for (
            uint i = 0;
            i <
            ISpecialTicketMinter(discoveryService.getPlatiniumTicketAddr())
                .balanceOf(discoveryService.getLotteryGameAddr());
            i++
        ) {
            platinTokenIds[i] = ISpecialTicketMinter(
                discoveryService.getPlatiniumTicketAddr()
            ).tokenOfOwnerByIndex(discoveryService.getLotteryGameAddr(), i);
        }
    }

    function getGoldTokenIds() internal {
        for (
            uint i = 0;
            i <
            ISpecialTicketMinter(discoveryService.getGoldTicketAddr())
                .balanceOf(discoveryService.getLotteryGameAddr());
            i++
        ) {
            goldTokenIds[i] = ISpecialTicketMinter(
                discoveryService.getGoldTicketAddr()
            ).tokenOfOwnerByIndex(discoveryService.getLotteryGameAddr(), i);
        }
    }

    function endLottery()
        external
        override
        onlyWhenLotteryRunning
        isWinnersBeenDrawn
        onlyAdmin
    {
        isSideLotteryRunning = false;
        isWinnersDrawn = false;
        users = new address[](0);
        winners = new address[](0);
        platinTokenIds = new uint256[](0);
        goldTokenIds = new uint256[](0);
    }
}
