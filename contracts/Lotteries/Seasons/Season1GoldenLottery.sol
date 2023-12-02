// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../../Services/Interfaces/IDiscoveryService.sol";

import "../../Services/Whitelisted.sol";
import "../../Tickets/Interfaces/ISpecialTicketMinter.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

import "hardhat/console.sol";

contract Season1GoldenLottery is Whitelisted, ReentrancyGuard {
    IDiscoveryService discoveryService;
    address[] public users;
    address[] public winners;

    uint256 public prizePool;
    uint256 public prize;
    uint256 public time;
    uint16 public threshold;
    uint16 public totalGoldTicketsBurnt;
    uint8 public shareForSuperGold;

    bool public isLotteryRunning;
    bool public isWinnersDrawn;

    using SafeMath for uint256;
    using SafeMath for uint16;

    event winnersDrawn(address[] winners);
    event ClaimedPrizePool(address winner, uint256 prize);
    event claimedShareForSuperGold(address winner, uint256 prize);

    constructor() payable {
        threshold = 10;
        shareForSuperGold = 10;
        isLotteryRunning = false;
        isWinnersDrawn = false;
    }

    modifier onlyWhenLotteryRunning() {
        require(
            isLotteryRunning = true,
            "Previous lottery is finished, please wait for the next one"
        );
        _;
    }

    modifier isWinnersBeenDrawn() {
        require(
            isWinnersDrawn = true,
            "Winners are not drawn yet, please wait for the next one"
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

    function burnGoldTickets(uint256[] memory tokenIds) external nonReentrant {
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
                isLotteryRunning = true;
            }
        }
    }

    function getWinners(
        uint8 nbDraws
    )
        external
        onlyWhenLotteryRunning
        onlyAdmin
        returns (address[] memory _winners)
    {
        uint16 index;
        prize = prizePool.sub(prizePool.mul(shareForSuperGold).div(100)).div(
            nbDraws
        );

        for (uint i = 0; i < nbDraws; i++) {
            index = getRandomIndex();
            winners.push(users[index]);
            users[index] = users[users.length - 1];
            users.pop();
        }

        isWinnersDrawn = true;

        _winners = winners;
        emit winnersDrawn(winners);
        return _winners;
    }

    function claimPrizePool() external nonReentrant {
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

    function getRandomIndex() internal view returns (uint16) {
        bytes32 hash = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        uint16 randomNumber = (uint16(bytes2(hash[0])) % uint16(users.length));
        return randomNumber;
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
        onlyWhenLotteryRunning
        isWinnersBeenDrawn
        onlyAdmin
    {
        require(users.length > 0, "No tickets burnt, lottery can't be ended");
        isLotteryRunning = false;
        isWinnersDrawn = false;
        totalGoldTicketsBurnt = 0;
        users = new address[](0);
        winners = new address[](0);
    }
}
