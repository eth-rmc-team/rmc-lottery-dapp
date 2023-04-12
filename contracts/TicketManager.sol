// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//Contract managing deals between players

contract TicketManager {

    address private owner;

    //ERC721 address for the minting contract
    address public addrNormalNftContract;
    address public addrMarketPlace;

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

    //Mapping (nftAddress => ownerAdress)
    //Completed when a user uses the MarketPlace for a trade 
    //in ordder to who is the seller of the NFT
    //Don't confuse it with the owner returning by IERC721.ownerOf()

    mapping(address => address) private nftOwners;
    mapping(address => int) private nftPrices;
    
    enum State { NoDeal, Dealing, Release }
    State private state;

    mapping (uint => uint) private dealingNftIDToPrice; 
    mapping (uint => State) private dealingNftiDToStateOfDeal; 

    //a voir: surement à supprimer
    mapping (uint => address) private goldIdNftToOwner;
    mapping (uint => address) private superGoldIdNftToOwner;
    mapping (uint => address) private mythicIdNftToOwner;
    mapping (uint => address) private platinIdNftToOwner;

    constructor() {
        owner = msg.sender;
        mintPrice = 25; //(todo: a mettre en float), actuellement il faudra multiplier par 10 ** 17

    }
    
    //todo: mettre à terme une whiteList, plutot qu'une adresse unique
    modifier onlyOwner {
        require(msg.sender == owner, "WARNING :: only the owner can have access");
        _;
    }

    //function updateCaracteristic(uint _carac) public
    // A faire 

    //Function setting the address of the NFT contract
    function setAddrNftContract(address _addrNormalNftContract) external onlyOwner {
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
    
    //Function setting the owner of NFT used in Marketplace.sol for a trade
    function setOwnerOfNft(address _addressNft, address _addressOwner) internal onlyOwner {
        nftOwners[_addressNft] = _addressOwner;
    }

    //Function setting the state of a deal in Marketplace.sol
    function setDealState(uint _nftID, State _state) internal {
        dealingNftiDToStateOfDeal[_nftID] = _state;
    }

    //Function setting the price of a deal in Marketplace.sol
    function setDealPrice(uint _nftID, uint _price) internal {
        dealingNftIDToPrice[_nftID] = _price;
    }

    //Function getter returning the address of the NFT contract
    function  getAddrNftContract() public view returns(address){
        return addrNormalNftContract;
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

    //Fucntion getter returning the requirement for a fusion of normal tickets for a Gold ticket
    function getNormalTicketFusionRequirement() public view returns(uint){
        return normalTicketFusionRequirement;
    }

    //Function getter returning the requirement for a fusion of Gold tickets for a SuperGold ticket
    function getGoldTicketFusionRequirement() public view returns(uint){
        return goldTicketFusionRequirement;
    }

    //Function getter returning the state of a deal for MarketPlace.sol
    function getDealState(uint _nftID) public view returns(State){
        return dealingNftiDToStateOfDeal[_nftID];
    }

    //Function getter returning the price of a deal for MarketPlace.sol
    function getDealPrice(uint _nftID) public view returns(uint){
        return dealingNftIDToPrice[_nftID];
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
