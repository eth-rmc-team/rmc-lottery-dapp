// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//Contract managing deals between players

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
    
    enum State { NoDeal, Dealing, Release }
    State private state;

    enum NftType { Normal, Gold, SuperGold, Mythic, Platin }
    NftType private nftType;

    //Struct containing all the information about a NFT
    struct nftInfo {
        NftType nftType;            //from enum nfType from RmcNftMinter.sol
        address nftContractAddress; //from address___NftContract from RmcNftMinter.sol
        uint nftID;                 //from tokenId from RmcNftMinter.sol
        address nftOwner;           //from ownerOf(tokenId) from Marketplace.sol        
        State stateOfDeal;          //from State in Marketplace.sol
        uint price;                 //from price in Marketplace.sol
    }
    
    //Creation of a mapping connecting each tokenId to its nftInfo struct
    mapping(uint => nftInfo) private idNftToNftInfos;

    constructor() {
        owner = msg.sender;
        mintPrice = 25; //(todo: a mettre en float), actuellement il faudra multiplier par 10 ** 17

    }
    
    //todo: mettre à terme une whiteList, plutot qu'une adresse unique
    modifier onlyOwner {
        require(msg.sender == owner, "WARNING :: only the owner can have access");
        _;
    }

    modifier onlyMarketplaceContract {
        require(msg.sender == addrMarketPlace, "WARNING :: only the MarketPlace contract can have access");
        _;
        
    }

    modifier onlyTicketFusionContract {
        require(msg.sender == addrTicketFusion, "WARNING :: only the TicketFusion contract can have access");
        _;
    }

    modifier onlyNftMinterContract {
        require(msg.sender == addrNftMinter, "WARNING :: only the NftMinter contract can have access");
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
    function setNftType(NftType _nftType, uint _tokenId) internal onlyNftMinterContract {
        idNftToNftInfos[_tokenId].nftType = _nftType;
    }

    function setNftContractAddress(address _nftContractAddress, uint _tokenId) internal onlyNftMinterContract {
        idNftToNftInfos[_tokenId].nftContractAddress = _nftContractAddress;
    }

    function setNftID(uint _tokenId) internal onlyNftMinterContract {
        idNftToNftInfos[_tokenId].nftID = _tokenId;
    }

    function setOwnerOfSellingNft(address _owner, uint _tokenId) internal onlyMarketplaceContract {
        idNftToNftInfos[_tokenId].nftOwner = _owner;
    }

    function setStateOfDeal(State _state, uint _tokenId) internal onlyMarketplaceContract {
        idNftToNftInfos[_tokenId].stateOfDeal = _state;
    }

    function setPriceOfSellingNft(uint _price, uint _tokenId) internal onlyMarketplaceContract {
        idNftToNftInfos[_tokenId].price = _price;
    }

    //End of functions

    //Function setting fee by trade
    function setFeeByTrade(uint _feeByTrade) external onlyOwner {
        feeByTrade = _feeByTrade;
    }

    //Function setting the requirement for a fusion of normal tickets for a Gold ticket
    function setNormalTicketFusionRequirement(uint _normalTicketFusionRequirement) external onlyOwner {
        normalTicketFusionRequirement = _normalTicketFusionRequirement;
    }

    function setGoldTicketFusionRequirement(uint _goldTicketFusionRequirement) external onlyOwner {
        goldTicketFusionRequirement = _goldTicketFusionRequirement;
    }

    //Function setting the price for a mint
    function setMintPrice(uint _price) public onlyOwner {
        mintPrice = _price; //todo: voir pour prend en compte les float (import math, mul etc)
    }
    
    //Function getter returning the address of the TicketFusion contract
    function getAddrTicketFusionContract() public view returns(address) {
        return addrTicketFusion;
    }

    //Function getter returning the address of the MarketPlace contract
    function getAddrMarketplaceContract() public view returns(address) {
        return addrMarketPlace;
    }

    //Function getter returning the address of the NftMinter contract
    function getAddrNftMinter() public view returns(address) {
        return addrNftMinter;
    }

    //Multiple functions getter returning the address of all king of NFTs contracts
    function getAddrNormalNftContract() internal view returns(address){
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

    //Function getter returning the fee by trade
    function getFeeByTrade() internal view returns(uint){
        return feeByTrade;
    }

    //Function getter returning all the information about a NFT
    function getNftInfo(uint _tokenId) public view returns (NftType, address, uint, address, State, uint) {
        return (idNftToNftInfos[_tokenId].nftType, idNftToNftInfos[_tokenId].nftContractAddress, idNftToNftInfos[_tokenId].nftID, idNftToNftInfos[_tokenId].nftOwner, idNftToNftInfos[_tokenId].stateOfDeal, idNftToNftInfos[_tokenId].price);
    }

    //Fucntion getter returning the requirement for a fusion of normal tickets for a Gold ticket
    function getNormalTicketFusionRequirement() public view returns(uint){
        return normalTicketFusionRequirement;
    }

    //Function getter returning the requirement for a fusion of Gold tickets for a SuperGold ticket
    function getGoldTicketFusionRequirement() public view returns(uint){
        return goldTicketFusionRequirement;
    }

    //IERS721 functions
    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {
        IERC721(addrNormalNftContract).transferFrom(_from, _to, _tokenId);
    }
    //Function getter returning the owner of NFT by IERC721
    function _ownerOf(address _addressNft, uint _tokenId) internal view returns(address){
        return IERC721(_addressNft).ownerOf(_tokenId);
    }

    function _balanceOf(address _addressNft, address _addressOwner) internal view returns(uint){
        return IERC721(_addressNft).balanceOf(_addressOwner);
    }

    function _approuve(address _addressNft, uint _tokenId, address _addressTo) internal {
        IERC721(_addressNft).approve(_addressTo, _tokenId);
    }

    //End of IERS721 functions

}
