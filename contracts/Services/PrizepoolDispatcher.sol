// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import '@openzeppelin/contracts/utils/math/SafeMath.sol';

import "hardhat/console.sol";

import "./Whitelisted.sol";
import "./Interfaces/ITicketRegistry.sol";
import "../Tickets/Interfaces/ITicketMinter.sol";
import "./Interfaces/IDiscoveryService.sol";
import "../Lotteries/Interfaces/ILotteryGame.sol";

contract PrizepoolDispatcher is Whitelisted
{
    address public tokenAllowedForTrade;

    IDiscoveryService discoveryService;
    ILotteryGame lotteryGame;

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

    mapping (uint256 => uint256) public gHasClaimed;
    mapping (uint256 => uint256) public sgHasClaimed;
    mapping (uint256 => uint256) public mHasClaimed;    
    mapping (uint256 => uint256) public pHasClaimed;
    
    using SafeMath for uint256;
    using SafeMath for uint8;

    struct userInfo {
        address addrClaimer;
        uint256 [4] balanceOfNft;
        uint256 [5] userShare;
        uint256 [4] coefs;        
    }
    constructor() 
    {        
        winnerSharePrizepool = 33;
        advantagesSharePrizepool = 33;
        protocolSharePrizepool = 33;
        
        mulSuperGold = mulGold * 6;
        mulMythic = mulGold * 2;
        mulPlatin = mulGold * 2;    
     }

    modifier onlyLotteryGame 
    {
        require(
            msg.sender == discoveryService.getLotteryGameAddr(), 
            "ERROR :: Only LotteryGame contract can call this function"
        );
        _;
    }

    function setDiscoveryService(address _address) external onlyAdmin 
    {
        discoveryService = IDiscoveryService(_address);
    }

    function setLotteryGame(address _address) external onlyAdmin 
    {
        lotteryGame = ILotteryGame(_address);
    }

   //Function setting the share of the winner
    function setShareOfPricePoolForWinner (uint8 _share) public onlyAdmin 
    {
        require(_share + protocolSharePrizepool + 
                advantagesSharePrizepool
                < 100, 
                "WARNING :: the total share must be less than 100");

        require(_share > 15 && _share < 51, 
        "WARNING :: the share must be between 15 and 51");
        
        winnerSharePrizepool = _share;
    }

    //Same function but for the protocol
    function setShareOfPricePoolForProtocol(uint8 _share) public onlyAdmin 
    {
        require(_share + winnerSharePrizepool +
                advantagesSharePrizepool 
                < 100, 
                "WARNING :: the total share must be less than 100");
        
        require(_share > 15 && _share < 40, 
        "WARNING :: the share must be between 15 and 40");
        
        protocolSharePrizepool = _share;
    }

    function setShareOfPricePoolForAdvantages(uint8 _share) public onlyAdmin 
    {
        require(_share + winnerSharePrizepool +
                protocolSharePrizepool 
                < 100, 
                "WARNING :: the total share must be less than 100");
        
        require(_share > 15 && _share < 40, 
        "WARNING :: the share must be between 15 and 40");
        
        advantagesSharePrizepool = _share;
    }

    //Function get for the different shares
    function getShares() external view returns (
        uint8, 
        uint8, 
        uint8
    ) 
    {
        return (
            protocolSharePrizepool, 
            winnerSharePrizepool, 
            advantagesSharePrizepool
        );
    }

    //function setting the address of the token used for trade
    function setTokenAllowedForTrade(address _tokenAllowedForTrade) external onlyAdmin 
    {
        tokenAllowedForTrade = _tokenAllowedForTrade;
    }

    //Function called by LotteryGame contract to claim the rewards from "Marketplace" contract
    function claimFees() external onlyWhitelisted
    {
        //If there is money in the contract, we send it to the LotteryGame contract
        if(discoveryService.getRmcMarketplaceAddr().balance > 0){
            IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).transferFrom(
                discoveryService.getRmcMarketplaceAddr(), 
                discoveryService.getLotteryGameAddr(), 
                (discoveryService.getRmcMarketplaceAddr().balance)
            );
        }
    }

    //Function used to disable the claim ability of a NFT after the claim
    function disableClaim(uint _id, uint8 nft) private 
    {
        if (nft == 1)
            gHasClaimed[_id] = lotteryGame.getLotteryId();
        else if (nft == 2)
            sgHasClaimed[_id] = lotteryGame.getLotteryId();
        else if (nft == 3)
            mHasClaimed[_id] = lotteryGame.getLotteryId();
        else if (nft == 4)
            pHasClaimed[_id] = lotteryGame.getLotteryId();
    }

    function getRatioSupplySuperGoldvsGold(uint256 _balanceOfGold) external view returns(uint ratioSGG) 
    {
        uint24 multiplicateur = 1000000;
        ratioSGG = ITicketMinter(discoveryService.getSuperGoldTicketAddr()).totalSupply()
        .mul(multiplicateur).div(_balanceOfGold);
        return (ratioSGG);
    }

    function getRatioSupplyMythicvsGold(uint256 _balanceOfGold) external view returns(uint ratioMG) 
    {
        uint24 multiplicateur = 1000000;
        ratioMG = ITicketMinter(discoveryService.getMythicTicketAddr()).totalSupply().mul(multiplicateur)
        .div(_balanceOfGold);
        return (ratioMG);
    }

    function getRatioSupplyPlatinvsGold(uint256 _balanceOfGold) external view returns(uint ratioPG) 
    {
        uint24 multiplicateur = 1000000;
        ratioPG = ITicketMinter(discoveryService.getPlatiniumTicketAddr()).totalSupply().mul(multiplicateur)
        .div(_balanceOfGold);
        return (ratioPG);
    }

    function getAllCoefs () 
        public view returns (
        uint256 [4] memory _coefs
    )
    {
        uint24 multiplicateur = 1000000;
        uint256 balanceOfGold = ITicketMinter(discoveryService.getGoldTicketAddr()).totalSupply();
        if( balanceOfGold == 0)
        {
            balanceOfGold = 1;
        }
        _coefs[0] = uint256(mulGold.mul(multiplicateur));
        _coefs[1] = uint256(mulSuperGold.mul(this.getRatioSupplySuperGoldvsGold(balanceOfGold)));
        _coefs[2] = uint256(mulMythic.mul(this.getRatioSupplyMythicvsGold(balanceOfGold)));
        _coefs[3] = uint256(mulPlatin.mul(this.getRatioSupplyPlatinvsGold(balanceOfGold)));

        return (_coefs);
    }

    function setMul( 
        uint8 _mulSuperGold, 
        uint8 _mulMythic, 
        uint8 _mulPlatin
    ) public onlyAdmin 
    {
        mulSuperGold = _mulSuperGold;
        mulMythic = _mulMythic;
        mulPlatin = _mulPlatin;
    }

    function getSumCoefs () 
        public view returns (
        uint _sumCoefs
    )
    {
        uint [4] memory coefs = getAllCoefs();
        _sumCoefs = coefs[0] + coefs[1] + coefs[2] + coefs[3];
        return (_sumCoefs);
    }

    function setUserInfo(address _addrClaimer) 
    private view 
    returns(userInfo memory user) 
    {
        
        user.addrClaimer = _addrClaimer;
        user.balanceOfNft = [
            ITicketMinter(discoveryService.getGoldTicketAddr()).balanceOf(_addrClaimer),
            ITicketMinter(discoveryService.getSuperGoldTicketAddr()).balanceOf(_addrClaimer),
            ITicketMinter(discoveryService.getMythicTicketAddr()).balanceOf(_addrClaimer),
            ITicketMinter(discoveryService.getPlatiniumTicketAddr()).balanceOf(_addrClaimer)
        ];
        user.userShare = [
            uint256(0), 
            uint256(0), 
            uint256(0), 
            uint256(0), 
            uint256(0)
        ];

        user.coefs = getAllCoefs();
        //user.coefs[4] = getSumCoefs();

        return (user);
    }

    //Function calculating the share of the price pool for each NFT type owned by the user
    function calculateShare(
        uint256 _pricepool, 
        uint _totalSupply, 
        uint256 _balanceOfNft, 
        uint256 _coef,
        uint256 _sumCoef
        ) 
        private view 
        returns(uint256 _share) 
        {   
        if(_balanceOfNft > 0)
        {     
        //note: we don't need to divide by 1000000 as sumCoef is already multiplied by 1000000
        _share =_pricepool.mul(_balanceOfNft)
            .div(_totalSupply).mul(_coef).div(_sumCoef);
        }
        else
        {
            _share = 0;
        }
        
        return (_share);
    }

    //Function computing the gain for the owner of "Special NFT" and disabling the claim afterward
    function computeGainForAdvantages(
        address addrClaimer,
        uint256 _prizepool
    ) external onlyWhitelisted returns (uint _totalGain) 
    {
        // Set up user information
        userInfo memory user = setUserInfo(addrClaimer);

        uint256 totalSupply = 0;
        uint256 id = 0;
        uint256 balanceOfNft = 0;
        uint256 coef = 0;
        uint256 sumCoef = getSumCoefs();

        //Get the amount of NFT owned by the address and loop through them
        //Disable the claim ability of the NFT
        //Increase the counter for the NFT type
        //Calculate the gain knowing the share of the price pool for each type of NFT and the number of NFT owned
        
        balanceOfNft = user.balanceOfNft[0];
        if (balanceOfNft > 0 ) {
            coef = user.coefs[0];
            totalSupply = ITicketMinter(discoveryService.getGoldTicketAddr()).totalSupply();
            for (uint i = 0; i < balanceOfNft; i++) {
                id = ITicketMinter(discoveryService.getGoldTicketAddr()).tokenOfOwnerByIndex(addrClaimer, i);
                if(gHasClaimed[id] < lotteryGame.getLotteryId()) 
                {
                    disableClaim(id, 1);
                }
                else
                {
                    balanceOfNft = SafeMath.sub(balanceOfNft, 1);
                }

            }
            user.userShare[0] = calculateShare(_prizepool, totalSupply, balanceOfNft, coef, sumCoef);
        }

        balanceOfNft = user.balanceOfNft[1];
        if (balanceOfNft > 0 ) {
            coef = user.coefs[1];
            totalSupply = ITicketMinter(discoveryService.getSuperGoldTicketAddr()).totalSupply();
            for (uint i = 0; i < balanceOfNft; i++) {
                id = ITicketMinter(discoveryService.getSuperGoldTicketAddr()).tokenOfOwnerByIndex(addrClaimer, i);
                if(sgHasClaimed[id] < lotteryGame.getLotteryId()) 
                {
                    disableClaim(id, 2);
                }
                else
                {
                    balanceOfNft = SafeMath.sub(balanceOfNft, 1);
                }

            }
            user.userShare[1] = calculateShare(_prizepool, totalSupply, balanceOfNft, coef, sumCoef);
        }

        balanceOfNft = user.balanceOfNft[2];
        if (balanceOfNft > 0 ) {
            coef = user.coefs[2];
            totalSupply = ITicketMinter(discoveryService.getMythicTicketAddr()).totalSupply();
            for (uint i = 0; i < balanceOfNft; i++) {
                id = ITicketMinter(discoveryService.getMythicTicketAddr()).tokenOfOwnerByIndex(addrClaimer, i);
                if(sgHasClaimed[id] < lotteryGame.getLotteryId()) 
                {
                    disableClaim(id, 3);
                }
                else
                {
                    balanceOfNft = SafeMath.sub(balanceOfNft, 1);
                }

            }
            user.userShare[2] = calculateShare(_prizepool, totalSupply, balanceOfNft, coef, sumCoef);
        }


        balanceOfNft = user.balanceOfNft[2];
        if (balanceOfNft > 0 ) {
            coef = user.coefs[3];
            totalSupply = ITicketMinter(discoveryService.getPlatiniumTicketAddr()).totalSupply();
            for (uint i = 0; i < balanceOfNft; i++) {
                id = ITicketMinter(discoveryService.getPlatiniumTicketAddr()).tokenOfOwnerByIndex(addrClaimer, i);
                if(sgHasClaimed[id] < lotteryGame.getLotteryId()) 
                {
                    disableClaim(id, 4);
                }
                else
                {
                    balanceOfNft = SafeMath.sub(balanceOfNft, 1);
                }

            }
            user.userShare[3] = calculateShare(_prizepool, totalSupply, balanceOfNft, coef, sumCoef);
        }

        // Calculate the total gain for the user
        
        _totalGain = (user.userShare[0] + user.userShare[1] + user.userShare[2] + user.userShare[3]);
        _totalGain = _totalGain.mul(advantagesSharePrizepool).div(100);
        
        return (_totalGain);

    }

    //Function computin the gain for the winner
    function computeGainForWinner(
        uint _idWinner, 
        address _claimer
    ) external view onlyWhitelisted returns(uint)
    {
        address payable _winner = payable(ITicketMinter(discoveryService.getNormalTicketAddr()).ownerOf(_idWinner));
        require(
            payable(_claimer) == _winner, 
            "ERROR :: you don't have the winning ticket"
        ); 

        return protocolSharePrizepool * discoveryService.getLotteryGameAddr().balance / 100;
    }
} 