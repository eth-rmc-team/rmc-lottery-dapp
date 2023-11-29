// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../../Services/Interfaces/IDiscoveryService.sol";

import "../../Services/Whitelisted.sol";
import "../../Tickets/Interfaces/ISpecialTicketMinter.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

contract Season1GoldenLottery is Whitelisted {
    IDiscoveryService discoveryService;
    mapping(address => uint16) public goldTicketsBurntByAddr;

    uint256 public prizePool;
    uint256 public time;
    uint16 public threshold;
    uint16 public totalGoldTicketsBurnt;
    uint8 public shareForSuperGold;

    bool public isLotteryRunning;

    using SafeMath for uint256;
    using SafeMath for uint16;

    constructor() payable {
        threshold = 10;
        shareForSuperGold = 10;
    }

    modifier onlyWhenLotteryRunning() {
        require(
            isLotteryRunning = true,
            "Previous lottery is finished, please wait for the next one"
        );
        _;
    }

    receive() external payable {}

    function setShareForSuperGold(uint8 _share) external onlyAdmin {
        require(_share <= 50, "Share can't be more than 50%");
        shareForSuperGold = _share;
    }

    function setDiscoveryService(address _address) external onlyAdmin {
        discoveryService = IDiscoveryService(_address);
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

    function burnGoldTickets(uint256[] memory tokenIds) external {
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

            goldTicketsBurntByAddr[msg.sender]++;
            totalGoldTicketsBurnt++;

            if (totalGoldTicketsBurnt == threshold) {
                prizePool = address(this).balance;
                isLotteryRunning = true;
                time = (block.timestamp) * 1 days;
            }
        }
    }

    function claimPrizePool() external onlyWhenLotteryRunning {
        uint256 _prizePool = prizePool;
        _prizePool = prizePool.sub(prizePool.mul(shareForSuperGold).div(100));

        if (goldTicketsBurntByAddr[msg.sender] > 0) {
            uint256 prize = _prizePool
                .mul(goldTicketsBurntByAddr[msg.sender])
                .div(totalGoldTicketsBurnt);

            (bool sent, ) = payable(msg.sender).call{value: prize}("");
            require(sent, "Failed to transfer funds to the contract");
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
        uint256 prize = _prizePool
            .mul(
                ISpecialTicketMinter(discoveryService.getSuperGoldTicketAddr())
                    .balanceOf(msg.sender)
            )
            .div(
                ITicketMinter(discoveryService.getSuperGoldTicketAddr())
                    .totalSupply()
            );

        (bool sent, ) = payable(msg.sender).call{value: prize}("");
        require(sent, "Failed to transfer funds to the contract");
    }

    function endLottery() external onlyAdmin {
        require(
            time + 5 seconds > block.timestamp,
            "Lottery is not finished yet"
        );
        isLotteryRunning = false;
        totalGoldTicketsBurnt = 0;
    }
}
