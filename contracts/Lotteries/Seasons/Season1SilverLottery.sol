// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../../Services/Interfaces/IDiscoveryService.sol";

import "../../Services/Whitelisted.sol";
import "../../Tickets/Interfaces/ISpecialTicketMinter.sol";
import "../ASideLotteryGame.sol";

import "hardhat/console.sol";

contract Season1SilverLottery is ASideLotteryGame {
    uint256 public sideLotteryId;

    struct SideLotteryGame {
        address[] users;
        address[] winners;
        uint32 totalTicketsBurnt;
        bool isSideLotteryRunning;
        bool isWinnersDrawn;
    }
    struct SideLotteryParameters {
        LotteryDef.TicketType ticketType;
        uint256 prefix;
        uint32 nbTicketBurnable;
        uint8 denominator;
        uint8 lotteryId;
        uint8 nbDraw;
        bool isLotteryDependant;
        bool isPrefixDependant;
    }

    mapping(uint256 => SideLotteryGame) sideLotteries;
    mapping(uint256 => SideLotteryParameters) sideLotteriesParameters;

    using SafeMath for uint16;
    using SafeMath for uint256;
    using SafeMath for uint32;

    constructor() payable {
        isSideLotteryRunning = false;
        isWinnersDrawn = false;
        sideLotteryId = 1;
    }

    function setSideLotteryParameters(
        LotteryDef.TicketType _type,
        uint256 _prefix,
        uint32 _nbTicketBurnable,
        uint8 _denominator,
        uint8 _lotteryId,
        uint8 nbDraw,
        bool _isLotteryDependant,
        bool _isPrefixDependant
    ) external onlyAdmin {
        sideLotteriesParameters[sideLotteryId].ticketType = _type;
        sideLotteriesParameters[sideLotteryId].prefix = _prefix;
        sideLotteriesParameters[sideLotteryId].denominator = _denominator;
        sideLotteriesParameters[sideLotteryId]
            .nbTicketBurnable = _nbTicketBurnable;
        sideLotteriesParameters[sideLotteryId].lotteryId = _lotteryId;
        if (_lotteryId == 0)
            sideLotteriesParameters[sideLotteryId].lotteryId = super
                .getLotteryId();
        sideLotteriesParameters[sideLotteryId].nbDraw = nbDraw;
        sideLotteriesParameters[sideLotteryId]
            .isLotteryDependant = _isLotteryDependant;
        sideLotteriesParameters[sideLotteryId]
            .isPrefixDependant = _isPrefixDependant;
        sideLotteryId.add(1);
    }

    function getSideLotteryParameters(
        uint _sideLotteryId
    ) external view returns (SideLotteryParameters memory) {
        return sideLotteriesParameters[_sideLotteryId];
    }

    function decreaseNbTicketBurnable(
        uint8 _sideLotteryId,
        uint32 _nbTicketBurnable
    ) external onlyAdmin {
        require(
            _nbTicketBurnable <= nbTicketBurnable,
            "ERROR :: New nbTicketBurnable must be lower than the previous one"
        );
        sideLotteriesParameters[_sideLotteryId]
            .nbTicketBurnable = _nbTicketBurnable;
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function burnTicket(
        uint256 _sideLotteryId,
        uint256[] memory tokenIds
    ) external nonReentrant {
        for (uint i = 0; i < tokenIds.length; i++) {
            uint256 prefixToken = tokenIds[i];
            prefixToken = prefixToken.div(denominator);
            uint8 lotteryIdToken = uint8(tokenIds[i].mod(100));

            if (
                lotteryIdToken !=
                sideLotteriesParameters[_sideLotteryId].lotteryId &&
                sideLotteriesParameters[_sideLotteryId].isLotteryDependant
            ) {
                revert("ERROR :: Wrong lotteryId");
            }

            if (
                prefixToken != sideLotteriesParameters[_sideLotteryId].prefix &&
                sideLotteriesParameters[_sideLotteryId].isPrefixDependant
            ) {
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

            sideLotteries[_sideLotteryId].totalTicketsBurnt++;
            sideLotteries[_sideLotteryId].users.push(msg.sender);

            if (
                sideLotteries[_sideLotteryId].totalTicketsBurnt ==
                sideLotteriesParameters[_sideLotteryId].nbTicketBurnable
            ) {
                sideLotteries[_sideLotteryId].isSideLotteryRunning = true;
                break;
            }
        }
    }

    function getWinners(uint256 _sideLotteryId) external nonReentrant {
        require(
            sideLotteries[_sideLotteryId].isSideLotteryRunning,
            "ERROR :: Side lottery is not running"
        );

        sideLotteries[_sideLotteryId].winners = super.getWinnersAddr(
            sideLotteriesParameters[_sideLotteryId].nbDraw
        );
        sideLotteries[_sideLotteryId].isWinnersDrawn = true;
    }

    function claimReward(uint256 _sideLotteryId) external nonReentrant {
        require(
            sideLotteries[sideLotteryId].isWinnersDrawn,
            "ERROR :: Winners are not drawn yet, please wait for the next one"
        );

        if (
            sideLotteriesParameters[_sideLotteryId].ticketType ==
            LotteryDef.TicketType.PLATIN
        ) {
            claimPlatin(_sideLotteryId);
        } else if (
            sideLotteriesParameters[_sideLotteryId].ticketType ==
            LotteryDef.TicketType.GOLD
        ) {
            claimGold(_sideLotteryId);
        } else {
            revert("ERROR :: No prizepool set");
        }
    }

    function claimPlatin(uint256 _sideLotteryId) internal {
        address winner;
        uint256 tokenId;
        for (
            uint i = 0;
            i < sideLotteries[_sideLotteryId].winners.length;
            i++
        ) {
            winner = sideLotteries[_sideLotteryId].winners[i];
            sideLotteries[_sideLotteryId].winners[i] = address(0);
            tokenId = ISpecialTicketMinter(
                discoveryService.getPlatiniumTicketAddr()
            ).mintSpecial(winner, LotteryDef.TicketType.PLATIN);
            emit ClaimedPrizePool(winner, tokenId);
        }
    }

    function claimGold(uint256 _sideLotteryId) internal {
        address winner;
        uint256 tokenId;
        for (
            uint i = 0;
            i < sideLotteries[_sideLotteryId].winners.length;
            i++
        ) {
            winner = sideLotteries[_sideLotteryId].winners[i];
            sideLotteries[_sideLotteryId].winners[i] = address(0);
            tokenId = ISpecialTicketMinter(discoveryService.getGoldTicketAddr())
                .mintSpecial(winner, LotteryDef.TicketType.GOLD);
            emit ClaimedPrizePool(winner, tokenId);
        }
    }
}
