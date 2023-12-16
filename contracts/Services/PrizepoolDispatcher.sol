// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "hardhat/console.sol";

import "./Whitelisted.sol";
import "./Interfaces/ITicketRegistry.sol";
import "../Tickets/Interfaces/ITicketMinter.sol";
import "./Interfaces/IDiscoveryService.sol";
import "../Lotteries/Interfaces/ILotteryGame.sol";

import "../Librairies/Calculation.sol";

contract PrizepoolDispatcher is Whitelisted {
    address public tokenAllowedForTrade;

    IDiscoveryService discoveryService;

    bool private _claimed;

    uint8 immutable mulGold = 1;
    uint8 mulSuperGold;
    uint8 mulMythic;
    uint8 mulPlatin;

    //To be divided by 100 in the appropriated compute function
    //Every rewards are claim WHEN a game period is done (triggered by the winner claiming his gain
    //or the protocole after a delay).
    //It remains claimable UNTIL a new cycle begins.
    //NFT merged during chase period can't received rewards from previous cycles.

    uint8 winnerSharePrizepool;
    uint8 advantagesSharePrizepool;
    uint8 protocolSharePrizepool;

    mapping(uint256 => uint256) public gHasClaimed;
    mapping(uint256 => uint256) public sgHasClaimed;
    mapping(uint256 => uint256) public mHasClaimed;
    mapping(uint256 => uint256) public pHasClaimed;

    using SafeMath for uint256;
    using SafeMath for uint8;
    using Calculation for *;

    struct userInfo {
        address addrClaimer;
        uint256[4] balanceOfNft;
        uint256[4] userShare;
        uint256[4] coefs;
    }

    constructor() {
        winnerSharePrizepool = 33;
        advantagesSharePrizepool = 33;
        protocolSharePrizepool = 33;

        mulSuperGold = mulGold * 6;
        mulMythic = mulGold * 2;
        mulPlatin = mulGold * 2;
    }

    modifier onlyLotteryGame() {
        require(
            msg.sender == discoveryService.getLotteryGameAddr(),
            "ERROR :: Only LotteryGame contract can call this function"
        );
        _;
    }

    function setDiscoveryService(address _address) external onlyAdmin {
        discoveryService = IDiscoveryService(_address);
    }

    function setMul(
        uint8 _mulSuperGold,
        uint8 _mulMythic,
        uint8 _mulPlatin
    ) public onlyAdmin {
        mulSuperGold = _mulSuperGold;
        mulMythic = _mulMythic;
        mulPlatin = _mulPlatin;
    }

    //Function setting the share of the winner
    function setShareOfPricePoolForWinner(uint8 _share) public onlyAdmin {
        require(
            _share + protocolSharePrizepool + advantagesSharePrizepool < 100,
            "WARNING :: the total share must be less than 100"
        );

        require(
            _share > 15 && _share < 51,
            "WARNING :: the share must be between 15 and 51"
        );

        winnerSharePrizepool = _share;
    }

    //Same function but for the protocol
    function setShareOfPricePoolForProtocol(uint8 _share) public onlyAdmin {
        require(
            _share + winnerSharePrizepool + advantagesSharePrizepool < 100,
            "WARNING :: the total share must be less than 100"
        );

        require(
            _share > 15 && _share < 40,
            "WARNING :: the share must be between 15 and 40"
        );

        protocolSharePrizepool = _share;
    }

    function setShareOfPricePoolForAdvantages(uint8 _share) public onlyAdmin {
        require(
            _share + winnerSharePrizepool + protocolSharePrizepool < 100,
            "WARNING :: the total share must be less than 100"
        );

        require(
            _share > 15 && _share < 40,
            "WARNING :: the share must be between 15 and 40"
        );

        advantagesSharePrizepool = _share;
    }

    //Function get for the different shares
    function getShareOfPricePoolFor()
        external
        view
        returns (uint8, uint8, uint8)
    {
        return (
            protocolSharePrizepool,
            winnerSharePrizepool,
            advantagesSharePrizepool
        );
    }

    //Function used to disable the claim ability of a NFT after the claim
    function disableClaim(uint _id, uint8 nft) private {
        if (nft == 1)
            gHasClaimed[_id] = ILotteryGame(
                discoveryService.getLotteryGameAddr()
            ).getLotteryId();
        else if (nft == 2)
            sgHasClaimed[_id] = ILotteryGame(
                discoveryService.getLotteryGameAddr()
            ).getLotteryId();
        else if (nft == 3)
            mHasClaimed[_id] = ILotteryGame(
                discoveryService.getLotteryGameAddr()
            ).getLotteryId();
        else if (nft == 4)
            pHasClaimed[_id] = ILotteryGame(
                discoveryService.getLotteryGameAddr()
            ).getLotteryId();
    }

    function getAllCoefs() public view returns (uint256[4] memory _coefs) {
        uint24 multiplicateur = 1000000;
        uint256 balanceOfGold = ITicketMinter(
            discoveryService.getGoldTicketAddr()
        ).totalSupply();
        uint256 balanceOfSupergold = ITicketMinter(
            discoveryService.getSuperGoldTicketAddr()
        ).totalSupply();
        uint256 balanceOfMythic = ITicketMinter(
            discoveryService.getMythicTicketAddr()
        ).totalSupply();
        uint256 balanceOfPlatin = ITicketMinter(
            discoveryService.getPlatiniumTicketAddr()
        ).totalSupply();

        _coefs[0] = uint256(mulGold.mul(multiplicateur));
        _coefs[1] = uint256(
            mulSuperGold.mul(
                Calculation.calculateRatio(balanceOfSupergold, balanceOfGold)
            )
        );
        _coefs[2] = uint256(
            mulMythic.mul(
                Calculation.calculateRatio(balanceOfMythic, balanceOfGold)
            )
        );
        _coefs[3] = uint256(
            mulPlatin.mul(
                Calculation.calculateRatio(balanceOfPlatin, balanceOfGold)
            )
        );

        return (_coefs);
    }

    function getSumCoefs() public view returns (uint _sumCoefs) {
        uint[4] memory coefs = getAllCoefs();
        _sumCoefs = Calculation.calculateSum4uint(coefs);
        return (_sumCoefs);
    }

    function setUserInfo(
        address _addrClaimer
    ) private view returns (userInfo memory user) {
        user.addrClaimer = _addrClaimer;
        user.balanceOfNft = [
            ITicketMinter(discoveryService.getGoldTicketAddr()).balanceOf(
                _addrClaimer
            ),
            ITicketMinter(discoveryService.getSuperGoldTicketAddr()).balanceOf(
                _addrClaimer
            ),
            ITicketMinter(discoveryService.getMythicTicketAddr()).balanceOf(
                _addrClaimer
            ),
            ITicketMinter(discoveryService.getPlatiniumTicketAddr()).balanceOf(
                _addrClaimer
            )
        ];
        user.userShare = [uint256(0), uint256(0), uint256(0), uint256(0)];
        user.coefs = getAllCoefs();
        return (user);
    }

    //Function computing the gain for the owner of "Special NFT" and disabling the claim afterward
    function computeGainForAdvantages(
        address addrClaimer,
        uint256 _prizepool
    ) external onlyWhitelisted returns (uint _totalGain) {
        // Set up user information
        userInfo memory user = setUserInfo(addrClaimer);

        uint256 totalSupply = 0;
        uint256 id = 0;
        uint256 balanceOfNft = 0;
        uint256 coef = 0;
        uint256 sumCoef = getSumCoefs();
        uint256 ticketClaimable;
        _prizepool = _prizepool.mul(advantagesSharePrizepool).div(100);

        //Get the amount of NFT owned by the address and loop through them
        //Disable the claim ability of the NFT
        //Increase the counter for the NFT type
        //Calculate the gain knowing the share of the price pool for each type of NFT and the number of NFT owned

        // For Gold
        balanceOfNft = user.balanceOfNft[0];
        if (balanceOfNft > 0) {
            ticketClaimable = 0;
            coef = user.coefs[0];
            totalSupply = ITicketMinter(discoveryService.getGoldTicketAddr())
                .totalSupply();
            for (uint i = balanceOfNft; i > 0; i--) {
                id = ITicketMinter(discoveryService.getGoldTicketAddr())
                    .tokenOfOwnerByIndex(addrClaimer, i - 1);
                if (
                    gHasClaimed[id] <
                    ILotteryGame(discoveryService.getLotteryGameAddr())
                        .getLotteryId()
                ) {
                    disableClaim(id, 1);
                    ticketClaimable = SafeMath.add(ticketClaimable, 1);
                }
            }

            user.userShare[0] = Calculation.calculateShare(
                _prizepool,
                totalSupply,
                ticketClaimable,
                coef,
                sumCoef
            );
        }

        //For Supergold
        balanceOfNft = user.balanceOfNft[1];
        if (balanceOfNft > 0) {
            ticketClaimable = 0;
            coef = user.coefs[1];
            totalSupply = ITicketMinter(
                discoveryService.getSuperGoldTicketAddr()
            ).totalSupply();
            for (uint i = balanceOfNft; i > 0; i--) {
                id = ITicketMinter(discoveryService.getSuperGoldTicketAddr())
                    .tokenOfOwnerByIndex(addrClaimer, i - 1);
                if (
                    sgHasClaimed[id] <
                    ILotteryGame(discoveryService.getLotteryGameAddr())
                        .getLotteryId()
                ) {
                    disableClaim(id, 2);
                    ticketClaimable = SafeMath.add(ticketClaimable, 1);
                }
            }
            user.userShare[1] = Calculation.calculateShare(
                _prizepool,
                totalSupply,
                ticketClaimable,
                coef,
                sumCoef
            );
        }

        //For Mythic
        balanceOfNft = user.balanceOfNft[2];
        if (balanceOfNft > 0) {
            ticketClaimable = 0;
            coef = user.coefs[2];
            totalSupply = ITicketMinter(discoveryService.getMythicTicketAddr())
                .totalSupply();
            for (uint i = balanceOfNft; i > 0; i--) {
                id = ITicketMinter(discoveryService.getMythicTicketAddr())
                    .tokenOfOwnerByIndex(addrClaimer, i - 1);
                if (
                    mHasClaimed[id] <
                    ILotteryGame(discoveryService.getLotteryGameAddr())
                        .getLotteryId()
                ) {
                    disableClaim(id, 3);
                    ticketClaimable = SafeMath.add(ticketClaimable, 1);
                }
            }
            user.userShare[2] = Calculation.calculateShare(
                _prizepool,
                totalSupply,
                ticketClaimable,
                coef,
                sumCoef
            );
        }

        // For Platin
        balanceOfNft = user.balanceOfNft[3];
        if (balanceOfNft > 0) {
            ticketClaimable = 0;
            coef = user.coefs[3];
            totalSupply = ITicketMinter(
                discoveryService.getPlatiniumTicketAddr()
            ).totalSupply();
            for (uint i = balanceOfNft; i > 0; i--) {
                id = ITicketMinter(discoveryService.getPlatiniumTicketAddr())
                    .tokenOfOwnerByIndex(addrClaimer, i - 1);
                if (
                    pHasClaimed[id] <
                    ILotteryGame(discoveryService.getLotteryGameAddr())
                        .getLotteryId()
                ) {
                    disableClaim(id, 4);
                    ticketClaimable = SafeMath.add(ticketClaimable, 1);
                }
            }
            user.userShare[3] = Calculation.calculateShare(
                _prizepool,
                totalSupply,
                ticketClaimable,
                coef,
                sumCoef
            );
        }

        // Calculate the total gain for the user
        _totalGain = Calculation.calculateSum4uint(user.userShare);

        //DEBUG :: check the good maths
        /*if (_totalGain > 0) {
        console.log("prizepool = ", _prizepool);
        console.log("totalGain = ", _totalGain);
        console.log("sumCoef = ", sumCoef);
        console.log("user.userShare[0] = ", user.userShare[0]);
        console.log("user.userShare[1] = ", user.userShare[1]);
        console.log("user.userShare[2] = ", user.userShare[2]);
        console.log("user.userShare[3] = ", user.userShare[3]);

        console.log("user.coefs[0] = ", user.coefs[0]);
        console.log("user.coefs[1] = ", user.coefs[1]);
        console.log("user.coefs[2] = ", user.coefs[2]);
        console.log("user.coefs[3] = ", user.coefs[3]);
        }*/

        return (_totalGain);
    }

    //Function computin the gain for the winner
    function computeGainForWinner(
        uint _idWinner,
        address _claimer,
        uint256 _prizepool
    ) external view onlyWhitelisted returns (uint) {
        address _winner = ITicketMinter(discoveryService.getNormalTicketAddr())
            .ownerOf(_idWinner);
        require(
            _claimer == _winner,
            "ERROR :: you don't have the winning ticket"
        );

        return winnerSharePrizepool.mul(_prizepool).div(100);
    }
}
