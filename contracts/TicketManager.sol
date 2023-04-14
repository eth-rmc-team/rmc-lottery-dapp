// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import './Marketplace.sol';

//Contract managing NFTs for deal on Marketplace.sol and mint on RmcNftMinter.sol 

contract TicketManager {

    address private owner;

    address public addrMarketPlace;
    address public addrTicketFusion;
    address public addrNftMinter;
    
    //ERC721 address for the minting contract
    address public addrNormalNftContract;
    address public addrGoldNftContract;
    address public addrSuperGoldNftContract;
    address public addrMythicNftContract;
    address public addrPlatinNftContract;

    uint private feeByTrade;
    uint private normalTicketFusionRequirement; 
    uint private goldTicketFusionRequirement;

    uint[] caracteristics;

    uint private mintPrice; //in Avax
    //Array of caracteristics picked during a cycle
    uint[] combinationPicked;
    
    enum State { NoDeal, Dealing }
    State private state;

    enum NftType { Normal, Gold, SuperGold, Mythic, Platin }
    NftType private nftType;
    

    //Struct containing all the information about a NFT
    struct nftInfo {
        NftType nftType;            //from enum nfType from RmcNftMinter.sol
        address nftContractAddress; //from address___NftContract from RmcNftMinter.sol
        uint nftID;                 //from tokenId from RmcNftMinter.sol
        address payable nftOwner;   //from ownerOf(tokenId) from Marketplace.sol        
        State nftStateOfDeal;       //from State in Marketplace.sol
        uint nftPrice;              //from price in Marketplace.sol
    }

    Marketplace marketplace;
    
    //Creation of a mapping connecting each tokenId to its nftInfo struct
    mapping(uint => nftInfo) private idNftToNftInfos;

    constructor() {
        owner = msg.sender;
        mintPrice = 25; //(todo: a mettre en float), actuellement il faudra multiplier par 10 ** 17

    }
    
    //todo: mettre à terme une whiteList, plutot qu'une adresse unique
    modifier onlyOwner {
         _;
    }

    modifier onlyContractMarketplace {
        require(msg.sender == addrMarketPlace, "ERROR :: Only the Marketplace contract can call this function");
        _;
    }

    //function updateCaracteristic(uint _carac) public
    // A faire 

    //Function setting the address of the TicketFusion contract
    function setAddrTicketFusion(address _addrTicketFusion) external onlyOwner {
        addrTicketFusion = _addrTicketFusion;
    }

    //Function setting the address of the MarketPlace contract
    function setAddrMarketPlace(address _addrMarketPlace) external onlyOwner {
        addrMarketPlace = _addrMarketPlace;
        marketplace = Marketplace(_addrMarketPlace);
    }

    //function setting the address of the NftMinter contract
    function setAddrNftMinter(address _addrNftMinter) external onlyOwner {
        addrNftMinter = _addrNftMinter;
    }

    //Function setting the address of the NFT contract
    function setAddrNormalNftContract(address _addrNormalNftContract) external onlyOwner {
        addrNormalNftContract = _addrNormalNftContract;
    }

    //Multiple functions to set address of all king of NFTs contracts
    function setAddrGoldNftContract(address _addrGoldNftContract) external onlyOwner {
        addrGoldNftContract = _addrGoldNftContract;
    }

    function setAddrSuperGoldNftContract(address _addrSuperGoldNftContract) external onlyOwner {
        addrSuperGoldNftContract = _addrSuperGoldNftContract;
    }

    function setAddrMythicNftContract(address _addrMythicNftContract) external onlyOwner {
        addrMythicNftContract = _addrMythicNftContract;
    }

    function setAddrPlatinNftContract(address _addrPlatinNftContract) external onlyOwner {
        addrPlatinNftContract = _addrPlatinNftContract;
    }

    //End of functions

    //Multiple functions setting information about a NFT
    function setNftType(NftType _nftType, uint _tokenId) internal {
        idNftToNftInfos[_tokenId].nftType = _nftType;
    }

    function setNftContractAddress(address _nftContractAddress, uint _tokenId) internal {
        idNftToNftInfos[_tokenId].nftContractAddress = _nftContractAddress;
    }

    function setNftID(uint _tokenId) internal {
        idNftToNftInfos[_tokenId].nftID = _tokenId;
    }

    //Function setting informations about a NFT from the Marketplace contract (owner, state of deal, price)
    //todo: faire de meme avec tokenId, addresseCOntract et Type NFT depuis le Minter et Fusion
    function setNftInfoFromMarketplace(uint _tokenId, address payable _nftOwner, State _nftState, uint _nftPrice ) external onlyContractMarketplace {
        require(idNftToNftInfos[_tokenId].nftID == _tokenId, "ERROR :: NFT not found");
        idNftToNftInfos[_tokenId].nftOwner = _nftOwner;
        idNftToNftInfos[_tokenId].nftStateOfDeal = _nftState;
        idNftToNftInfos[_tokenId].nftPrice = _nftPrice;

    }
    //End of functions

    //Function setting the price for a mint
    function setMintPrice(uint _price) public onlyOwner {
        mintPrice = _price; //todo: voir pour prend en compte les float (import math, mul etc)
    }
    
    //Function getter returning the address of the TicketFusion contract
    function getAddrTicketFusionContract() public view returns(address) {
        return addrTicketFusion;
    }

    //Multiple functions getter returning the address of all king of NFTs contracts
    function getAddrNormalNftContract() external view returns(address){
        return addrNormalNftContract;
    }

    function getAddrGoldNftContract() internal view returns(address){
        return addrGoldNftContract;
    }

    function getAddrSuperGoldNftContract() internal view returns(address){
        return addrSuperGoldNftContract;
    }

    function getAddrMythicNftContract() internal view returns(address){
        return addrMythicNftContract;
    }

    function getAddrPlatinNftContract() internal view returns(address){
        return addrPlatinNftContract;
    }

    //End of functions
        
    //Function getter returning the price for a mint
    function getMintPrice() public view returns(uint){
        return mintPrice;
    }

    //Function getter returning de caracteristic of the day
    function getCaracteristicsForADay(uint _day) public view returns(uint){
        return caracteristics[_day];
    }

    //Function getter returning lotteryId for NFT
    function getIdLotteryForNft(address _addrNft) public pure returns(uint _lotteryId) {
        //todo: A FAIRE, code allant chercher lotteryId dans le NFT
        return _lotteryId;
    }

    //Function getter returning all the information about a NFT
    function getNftInfo(uint _tokenId) public view returns (NftType, address, uint, address payable, State, uint) {
        return (idNftToNftInfos[_tokenId].nftType, idNftToNftInfos[_tokenId].nftContractAddress, idNftToNftInfos[_tokenId].nftID, idNftToNftInfos[_tokenId].nftOwner, idNftToNftInfos[_tokenId].nftStateOfDeal, idNftToNftInfos[_tokenId].nftPrice);
    }

    //IERS721 functions
    function _transferFrom(address _from, address _to, address _addrNftContract, uint256 _tokenId) internal {
        IERC721(_addrNftContract).transferFrom(_from, _to, _tokenId);
    }
    //Function getter returning the owner of NFT by IERC721
    function _ownerOf(address _addrNftContract, uint _tokenId) internal view returns(address){
        return IERC721(_addrNftContract).ownerOf(_tokenId);
    }

    function _balanceOf(address _addrNftContract, address _addressOwner) internal view returns(uint){
        return IERC721(_addrNftContract).balanceOf(_addressOwner);
    }

    function _approuve(address _addrNftContract, uint _tokenId, address _addressTo) internal {
        IERC721(_addrNftContract).approve(_addressTo, _tokenId);
    }

    //End of IERS721 functions

}
