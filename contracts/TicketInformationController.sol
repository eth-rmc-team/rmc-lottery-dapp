// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import './TicketManager.sol';

contract TicketInformationController is TicketManager 
{

    enum State { NODEAL, DEALING }
    enum NftType { NORMAL, GOLD, SUPERGOLD, MYTHIC, PLATIN }    

    //Struct containing all the information about a NFT
    struct nftInfo {
        NftType nftType;            //from enum nfType from RmcNftMinter.sol
        address nftContractAddress; //from address___NftContract from RmcNftMinter.sol
        address payable nftOwner;   //from ownerOf(tokenId) from Marketplace.sol        
        State nftStateOfDeal;       //from State in Marketplace.sol
        uint nftPrice;              //from price in Marketplace.sol
        bool nftPricePoolClaimed;   //from bool in FeeManager.sol
        bool nftFeeClaimed;         //from bool in FeeManager.sol
    }
    
    //Creation of a mapping connecting each tokenId to its nftInfo struct
    mapping(uint256 => nftInfo) public idNftToNftInfos;

    constructor() 
    {

    }

    //Function setting informations about a NFT from the Marketplace contract 
    //(owner, state of deal, price)
    //todo: faire de meme avec tokenId, addresseCOntract et Type NFT depuis le Minter et Fusion
    function setNftInfo(
        uint _tokenId, 
        address payable _nftOwner, 
        State _nftState, 
        uint _nftPrice 
    ) external onlyWhiteListedAddress {             
        idNftToNftInfos[_tokenId].nftOwner = _nftOwner;
        idNftToNftInfos[_tokenId].nftStateOfDeal = _nftState;
        idNftToNftInfos[_tokenId].nftPrice = _nftPrice;
    }

    function setPPClaimStatus(bool _statusPP, uint _tokenId) external onlyWhiteListedAddress 
    {
        idNftToNftInfos[_tokenId].nftPricePoolClaimed = _statusPP;
    }

    function setFeeClaimStatus(bool _statusFee, uint _tokenId) external onlyWhiteListedAddress 
    {
        idNftToNftInfos[_tokenId].nftFeeClaimed = _statusFee;
    }
    //End of functions

        //Function getter returning all the information about a NFT
    function getNftInfo(uint _tokenId) 
    external view returns (
        NftType, 
        address _addrContr, 
        address payable _owner, 
        State _dealStatus, 
        uint _price
    ) {
        return (
            idNftToNftInfos[_tokenId].nftType, 
            idNftToNftInfos[_tokenId].nftContractAddress, 
            idNftToNftInfos[_tokenId].nftOwner, 
            idNftToNftInfos[_tokenId].nftStateOfDeal, 
            idNftToNftInfos[_tokenId].nftPrice
        );
    }

    function getClaimedRewardStatus(uint _tokenId) 
    external view returns(
        bool _pricePoolStatus, 
        bool _feeStatus
    ) {
        return (
            idNftToNftInfos[_tokenId].nftPricePoolClaimed, 
            idNftToNftInfos[_tokenId].nftFeeClaimed
        );
    }

    //Function getter returning all the address of the NFT contracts
    function getAddrTicketContracts() 
    external view returns(
        address _addrN, 
        address _addrG, 
        address _addrSG, 
        address _addrM, 
        address _addrP
    ){
        return (
            addrNormalNftContract, 
            addrGoldNftContract, 
            addrSuperGoldNftContract, 
            addrMythicNftContract, 
            addrPlatinNftContract
        );
    }

}