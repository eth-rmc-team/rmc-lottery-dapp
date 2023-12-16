// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./Whitelisted.sol";
import "../Lotteries/Interfaces/ILotteryGame.sol";
import "./Interfaces/IDiscoveryService.sol";
import "./Interfaces/IPrizepoolDispatcher.sol";
import "../Tickets/Interfaces/ISpecialTicketMinter.sol";
import "../Tickets/Interfaces/INormalTicketMinter.sol";
import "../Librairies/LotteryDef.sol";
import "../Librairies/Calculation.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

contract Claimizer is Whitelisted, ReentrancyGuard {
    bool public isWinnerClaimed;
    IDiscoveryService discoveryService;

    using Calculation for *;
    using LotteryDef for LotteryDef.Period;
    using SafeMath for *;

    constructor(address _discoveryService) {
        discoveryService = IDiscoveryService(_discoveryService);
    }

    modifier onlyWhenCycleNotRunning() {
        require(
            ILotteryGame(discoveryService.getLotteryGameAddr())
                .getIsCycleRunning() == false,
            "Claimizer : The owner cannot perform this action when a game is in progress"
        );
        _;
    }

    function setDiscoveryService(
        address _address
    ) external onlyAdmin onlyWhenCycleNotRunning {
        discoveryService = IDiscoveryService(_address);
    }

    function checkWinner(
        uint256 _winningCombination,
        uint256 _prizepool,
        bool _isWinnerClaimed,
        address caller,
        LotteryDef.Period _currentPeriod
    ) external onlyWhitelisted nonReentrant returns (uint256) {
        // Check that the game is in claim period, that the winner hasn't claimed the price pool yet
        require(
            _currentPeriod == LotteryDef.Period.CLAIM,
            "Claimizer :: You can't claim the winner if the game is not over"
        );
        require(
            _isWinnerClaimed == false,
            "Claimizer :: You can't claim twice the price pool"
        );

        //"FeeManager" contract compute the gain of the winner and check his NFT
        uint gainWinner = IPrizepoolDispatcher(
            discoveryService.getPrizepoolDispatcherAddr()
        ).computeGainForWinner(_winningCombination, caller, _prizepool);

        return gainWinner;
    }

    function checkGoldTicket(
        uint256 _winningCombination,
        uint256 tokenId,
        uint256 balanceOfGold,
        uint16 _mask,
        uint8 lotteryId,
        address caller,
        LotteryDef.Period _currentPeriod
    ) external onlyWhitelisted nonReentrant {
        require(
            _currentPeriod == LotteryDef.Period.CLAIM,
            "ERROR :: You can't claim the gold if the game is not over"
        );
        uint16 featuresAvailable = uint16(_winningCombination.div(10000));
        uint8 lotteryIdForGold = Calculation.extractLotteryId(tokenId);
        uint16 featuresForGold = Calculation.extractFeatures(tokenId, _mask);

        if (
            lotteryIdForGold == lotteryId &&
            featuresForGold == featuresAvailable &&
            tokenId != _winningCombination &&
            balanceOfGold > 0
        ) {
            uint256 goldTokenId = ISpecialTicketMinter(
                discoveryService.getGoldTicketAddr()
            ).tokenOfOwnerByIndex(
                    discoveryService.getLotteryGameAddr(),
                    balanceOfGold - 1
                );
            INormalTicketMinter(discoveryService.getNormalTicketAddr()).burn(
                tokenId
            );
            ISpecialTicketMinter(discoveryService.getGoldTicketAddr())
                .safeTransferFrom(
                    discoveryService.getLotteryGameAddr(),
                    caller,
                    goldTokenId
                );
        }
    }

    function checkAdvantages(
        uint256 _prizepool,
        address caller,
        LotteryDef.Period _currentPeriod
    ) external onlyWhitelisted nonReentrant returns (uint256) {
        require(
            _currentPeriod == LotteryDef.Period.CLAIM,
            "ERROR :: You can't claim the rewards if the game is not over"
        );

        uint _totalGain;
        _totalGain = IPrizepoolDispatcher(
            discoveryService.getPrizepoolDispatcherAddr()
        ).computeGainForAdvantages(caller, _prizepool);

        return _totalGain;
    }

    function checkProtocol(
        uint256 _prizepool,
        LotteryDef.Period _currentPeriod
    ) external onlyWhitelisted nonReentrant returns (uint256) {
        require(
            _currentPeriod == LotteryDef.Period.CLAIM,
            "ERROR :: You can't claim the rewards if the game is not over"
        );

        uint8 shareProt;
        (shareProt, , ) = IPrizepoolDispatcher(
            discoveryService.getPrizepoolDispatcherAddr()
        ).getShareOfPricePoolFor();
        uint256 _totalGain = (_prizepool * shareProt) / 100;
        return _totalGain;
    }
}
