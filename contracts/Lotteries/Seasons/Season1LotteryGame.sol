// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "hardhat/console.sol";

import "../../Services/Interfaces/IPrizepoolDispatcher.sol";
import "../../Services/TicketRegistry.sol";
import "../../Tickets/Interfaces/ITicketMinter.sol";
import "../../Tickets/Interfaces/INormalTicketMinter.sol";
import "../../Tickets/Interfaces/ISpecialTicketMinter.sol";
import "../ALotteryGame.sol";
import "../../Librairies/LotteryDef.sol";

import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

contract Season1LotteryGame is ALotteryGame, ReentrancyGuard {
    using LotteryDef for LotteryDef.Period;

    mapping(uint8 => uint8) public featuresByDay;

    uint256 public prizepool;
    uint256 public ticketPrice;

    uint256 private nonce;

    //Amount of RMC reward for minting NFTs
    uint256 tokenBuyReward;
    uint256 ticketsFusionClaimedGains;

    LotteryDef.Period public currentPeriod;

    bool public isWinnerClaimed;

    using SafeMath for uint256;
    using SafeMath for uint8;

    constructor() payable {
        currentPeriod = LotteryDef.Period.OFF;
        lotteryId = 0;
    }

    function setTicketPrice(
        uint256 _ticketPrice
    ) external onlyAdmin onlyWhenCycleNotRunning {
        ticketPrice = _ticketPrice;
    }

    //Prévoir fonction récupérant les nft encore en jeu durant le cycle courrant (dans TicketsManager)
    function getTicketPrice() external view returns (uint256) {
        return ticketPrice;
    }

    function getCurrentPeriod() external view returns (LotteryDef.Period) {
        return currentPeriod;
    }

    /**
        ALotteryGame Implementation
     */

    function resetCycle() external override onlyAdmin onlyWhenCycleNotRunning {
        currentPeriod = LotteryDef.Period.SALES;
        isCycleRunning = true;
        currentStep = 1;
        lotteryId += 1;
        winningCombination = lotteryId;
        isWinnerClaimed = false;
        prizepool = address(this).balance;
    }

    function buyTicket(
        string[] calldata uris
    ) external payable override nonReentrant {
        require(
            uris.length > 0,
            "ERROR :: You must provide a list of nft hash to buy"
        );
        require(
            currentPeriod == LotteryDef.Period.SALES,
            "ERROR :: You can only buy ticket in sales period"
        );
        require(
            uris.length <= ticketCapacity - ticketsSold,
            "ERROR :: Not enough tickets left for your order"
        );

        require(
            msg.value >= uris.length * ticketPrice,
            "ERROR :: You must pay the right price for your order"
        );

        ticketsSold += uint16(uris.length);
        (bool sent, ) = payable(address(this)).call{value: msg.value}("");

        require(sent, "Failed to transfer funds to the contract");

        for (uint i = 0; i < uris.length; i++) {
            INormalTicketMinter(discoveryService.getNormalTicketAddr())
                .mintTicket(uris[i], msg.sender, lotteryId);
        }

        if (ticketsSold == ticketCapacity) startLottery();
    }

    function startLottery() private {
        require(
            currentPeriod == LotteryDef.Period.SALES,
            "ERROR :: You can't start a game during this period"
        );
        require(
            ticketsSold == ticketCapacity,
            "ERROR :: A game can't start if all tickets haven't been sold"
        );

        currentPeriod = LotteryDef.Period.GAME;
        lastStepAt = block.timestamp;
    }

    function nextStep() public override {
        require(
            currentPeriod == LotteryDef.Period.GAME,
            "ERROR :: You can't go to the next day if not in a running game"
        );

        require(
            block.timestamp >= lastStepAt + minimumTimeStep,
            "WARNING :: You can't go to the next step if it's not the right time"
        );

        unchecked {
            winningCombination +=
                getRandomDigit(featuresByDay[currentStep]) *
                (10 ** (currentStep + 1));
        }

        if (currentStep < totalSteps) {
            currentStep++;
            lastStepAt = block.timestamp;
        } else {
            endLottery();
        }
    }

    function endLottery() private {
        require(
            currentPeriod == LotteryDef.Period.GAME,
            "ERROR :: You can't stop a game that's not in progress"
        );
        require(
            currentStep >= totalSteps,
            "ERROR :: You can't end the game if it's not over"
        );

        currentPeriod = LotteryDef.Period.CLAIM;
        prizepool = address(this).balance;

        IPrizepoolDispatcher(discoveryService.getRmcMarketplaceAddr())
            .transferFeesToLottery();
    }

    function initializeBoxOffice(
        string[] calldata uris,
        uint32[] calldata features,
        uint8[] calldata _featuresByDay,
        uint256 nbGoldTickets
    ) external onlyAdmin onlyWhenCycleNotRunning {
        INormalTicketMinter(discoveryService.getNormalTicketAddr())
            .addABatchOfMintableTickets(uris, features);

        for (uint8 i = 0; i < _featuresByDay.length; i++) {
            featuresByDay[i + 1] = _featuresByDay[i];
        }
        ticketCapacity = uint16(uris.length);

        for (uint256 i = 0; i < nbGoldTickets; i++) {
            ISpecialTicketMinter(discoveryService.getGoldTicketAddr())
                .mintSpecial(address(this));
        }
    }

    function getRandomDigit(uint256 max) private returns (uint8) {
        require(
            max > 0 && max < 10,
            "ERROR :: You must provide a number between 1 and 9"
        );
        nonce++;
        uint256 randomNumber = uint256(
            keccak256(
                abi.encodePacked(
                    block.timestamp,
                    block.difficulty,
                    msg.sender,
                    nonce
                )
            )
        );
        return uint8((randomNumber % max) + 1);
    }

    function claimReward() external payable override nonReentrant {
        //Check that the game is in claim period, that the game is over, that the winner hasn't claimed the price pool yet
        require(
            currentPeriod == LotteryDef.Period.CLAIM,
            "ERROR :: You can't claim the winner if the game is not over"
        );
        require(
            isWinnerClaimed == false,
            "ERROR :: You can't claim twice the price pool"
        );

        //"FeeManager" contract compute the gain of the winner and check his NFT
        uint gainWinner = IPrizepoolDispatcher(
            discoveryService.getPrizepoolDispatcherAddr()
        ).computeGainForWinner(winningCombination, msg.sender, prizepool);

        //transfer gains to the owner of the winningCombination

        (bool sent, ) = payable(
            INormalTicketMinter(discoveryService.getNormalTicketAddr()).ownerOf(
                winningCombination
            )
        ).call{value: gainWinner}("");
        require(sent, "Failed to transfer funds");

        //Burn the NFT of the winner
        INormalTicketMinter(discoveryService.getNormalTicketAddr()).burn(
            winningCombination
        );
        ISpecialTicketMinter(discoveryService.getMythicTicketAddr())
            .mintSpecial(msg.sender);

        isWinnerClaimed = true;
    }

    function claimGoldTicket(uint256 tokenId) external nonReentrant {
        require(
            currentPeriod == LotteryDef.Period.CLAIM,
            "ERROR :: You can't claim the gold if the game is not over"
        );
        uint16 featuresAvailable = uint16(winningCombination.div(10000));
        uint8 lotteryIdForGold = extractLotteryId(tokenId);
        uint16 featuresForGold = extractFeatures(tokenId);
        uint256 balanceOfGold = ISpecialTicketMinter(
            discoveryService.getGoldTicketAddr()
        ).balanceOf(address(this));

        if (
            lotteryIdForGold == lotteryId &&
            featuresForGold == featuresAvailable &&
            tokenId != winningCombination &&
            balanceOfGold > 0
        ) {
            uint256 goldTokenId = ISpecialTicketMinter(
                discoveryService.getGoldTicketAddr()
            ).tokenOfOwnerByIndex(address(this), balanceOfGold - 1);
            INormalTicketMinter(discoveryService.getNormalTicketAddr()).burn(
                tokenId
            );
            ISpecialTicketMinter(discoveryService.getGoldTicketAddr())
                .safeTransferFrom(address(this), msg.sender, goldTokenId);
        }
    }

    function extractLotteryId(uint256 input) private pure returns (uint8) {
        uint8 _lotteryIdForGold;
        _lotteryIdForGold = uint8(input % 100);
        return _lotteryIdForGold;
    }

    function extractFeatures(uint256 input) private pure returns (uint16) {
        uint16 _featuresForGold;
        _featuresForGold = uint16(input.div(10000));
        return _featuresForGold;
    }

    function claimAdvantagesReward() external nonReentrant {
        require(
            currentPeriod == LotteryDef.Period.CLAIM,
            "ERROR :: You can't claim the rewards if the game is not over"
        );

        uint _totalGain;
        _totalGain = IPrizepoolDispatcher(
            discoveryService.getPrizepoolDispatcherAddr()
        ).computeGainForAdvantages(msg.sender, prizepool);

        //Check that the gain is more than before transfer
        if (_totalGain > 0) {
            (bool sent, ) = payable(msg.sender).call{value: _totalGain}("");
            require(sent, "Failed to transfer funds");
        }
    }

    function claimProtocolReward() external onlyAdmin nonReentrant {
        require(
            currentPeriod == LotteryDef.Period.CLAIM,
            "ERROR :: You can't claim the rewards if the game is not over"
        );

        uint8 shareProt;
        (shareProt, , ) = IPrizepoolDispatcher(
            discoveryService.getPrizepoolDispatcherAddr()
        ).getShareOfPricePoolFor();
        uint256 _totalGain = (prizepool * shareProt) / 100;

        //Check that the gain is more than before transfer
        require(_totalGain > 0, "ERROR :: You don't have any rewards to claim");
        (bool sent, ) = payable(msg.sender).call{value: _totalGain}("");
        require(sent, "Failed to transfer funds to protocol");
    }

    function endClaimPeriod() external onlyAdmin {
        //@todo require something to limit admin power

        require(
            currentPeriod == LotteryDef.Period.CLAIM,
            "ERROR :: You can't end the claim period if it's not started"
        );

        currentPeriod = LotteryDef.Period.CHASE;
    }

    function endCycle() external override onlyAdmin {
        currentPeriod = LotteryDef.Period.OFF;
        isCycleRunning = false;
    }
}
