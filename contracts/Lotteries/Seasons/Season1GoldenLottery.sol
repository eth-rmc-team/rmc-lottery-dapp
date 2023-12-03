// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../../Services/Interfaces/IDiscoveryService.sol";

import "../../Services/Whitelisted.sol";
import "../../Tickets/Interfaces/ISpecialTicketMinter.sol";
import "../ASideLotteryGame.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

contract Season1GoldenLottery is ASideLotteryGame {
    uint256 public prizePool;
    uint256 public prize;
    uint256 public time;
    uint16 public threshold;
    uint16 public totalGoldTicketsBurnt;
    uint8 public shareForSuperGold;

    using SafeMath for uint256;
    using SafeMath for uint16;

    constructor() payable {
        threshold = 10;
        shareForSuperGold = 10;
        isSideLotteryRunning = false;
        isWinnersDrawn = false;
    }

    function setShareForSuperGold(uint8 _share) external onlyAdmin {
        require(_share <= 50, "Share can't be more than 50%");
        shareForSuperGold = _share;
    }

    function setThresholdToActivateLottery(
        uint16 _threshold
    ) external onlyAdmin {
        threshold = _threshold;
    }

    function getThresholdToActivateLottery() external view returns (uint16) {
        return threshold;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function burnTicket(
        uint256[] memory tokenIds
    ) external override nonReentrant {
        require(
            totalGoldTicketsBurnt.add(tokenIds.length) <= threshold,
            "Threshold reached, lottery is already running"
        );

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

            if (totalGoldTicketsBurnt == threshold) {
                prizePool = address(this).balance;
                isSideLotteryRunning = true;
            }
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
        prize = prizePool.sub(prizePool.mul(shareForSuperGold).div(100)).div(
            nbDraws
        );

        _winners = super.getWinnersAddr(nbDraws);
        isWinnersDrawn = true;

        return _winners;
    }

    function claimReward() external override nonReentrant {
        address winner;
        for (uint i = 0; i < winners.length; i++) {
            if (winners[i] == msg.sender) {
                winner = winners[i];

                (bool sent, ) = payable(winners[i]).call{value: prize}("");
                require(sent, "Failed to transfer funds to the contract");
                winners[i] = address(0);

                emit ClaimedPrizePool(winner, prize);
            }
        }
    }

    function claimShareForSuperGold() external {
        require(
            ITicketMinter(discoveryService.getSuperGoldTicketAddr()).balanceOf(
                msg.sender
            ) > 0,
            "You don't have any super gold tickets"
        );
        uint256 _prizePool = prizePool.mul(shareForSuperGold).div(100);
        uint256 claim = _prizePool
            .mul(
                ISpecialTicketMinter(discoveryService.getSuperGoldTicketAddr())
                    .balanceOf(msg.sender)
            )
            .div(
                ITicketMinter(discoveryService.getSuperGoldTicketAddr())
                    .totalSupply()
            );

        (bool sent, ) = payable(msg.sender).call{value: claim}("");
        require(sent, "Failed to transfer funds to the contract");

        emit claimedShareForSuperGold(msg.sender, claim);
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
        totalGoldTicketsBurnt = 0;
        users = new address[](0);
        winners = new address[](0);
    }
}
