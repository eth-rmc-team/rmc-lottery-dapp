// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../../Services/Interfaces/IDiscoveryService.sol";

import "../../Services/Whitelisted.sol";
import "../../Tickets/Interfaces/ISpecialTicketMinter.sol";
import "../ASideLotteryGame.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

contract Season1SilverLottery is ASideLotteryGame {
    uint256 public prizePool;
    uint256 public prize;
    uint256 public time;
    uint16 public totalGoldTicketsBurnt;
    uint8 public shareForSuperGold;

    using SafeMath for uint256;
    using SafeMath for uint16;

    constructor() payable {
        shareForSuperGold = 10;
        isSideLotteryRunning = false;
        isWinnersDrawn = false;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function burnTicket(
        uint256[] memory tokenIds
    ) external override nonReentrant {
        for (uint i = 0; i < tokenIds.length; i++) {
            require(
                ISpecialTicketMinter(discoveryService.getGoldTicketAddr())
                    .ownerOf(tokenIds[i]) == msg.sender,
                "You are not the owner of this ticket"
            );

            ISpecialTicketMinter(discoveryService.getGoldTicketAddr()).burn(
                tokenIds[i]
            );

            totalGoldTicketsBurnt++;
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

    function claimReward() external override nonReentrant {
        address winner;
        for (uint i = 0; i < winners.length; i++) {
            if (winners[i] == msg.sender) {
                winner = winners[i];
                winners[i] = address(0);

                emit ClaimedPrizePool(winner, prize);
            }
        }
    }

    function endLottery()
        external
        override
        onlyWhenLotteryRunning
        isWinnersBeenDrawn
        onlyAdmin
    {
        require(users.length > 0, "No tickets burnt, lottery can't be ended");
        isSideLotteryRunning = false;
        isWinnersDrawn = false;
        users = new address[](0);
        winners = new address[](0);
    }
}
