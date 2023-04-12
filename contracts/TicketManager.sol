// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
 
contract TicketManager {

    address private owner;

    //ERC721 address for the minting contract
    address public addrContractNft;
    address public addrMarketPlace;

    uint private feeByTrade;

    uint[] caracteristics;

    uint private mintPrice; //in Avax
    //Array of caracteristics picked during a cycle
    uint[] combinationPicked;

    //Mapping (nftAddress => ownerAdress)
    //Completed when a user uses the MarketPlace for a trade 
    //in order to know whose the NFT belongs to

    mapping(address => address) private nftOwners;
    mapping(address => int) private nftPrices;
    
    enum State { NoDeal, Dealing, Release }
    State private state;

    mapping (uint => uint) private dealingNftIDToPrice; 
    mapping (uint => State) private dealingNftiDToStateOfDeal; 

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
    function setAddrNftContract(address _addrContractNft) external onlyOwner {
        addrContractNft = _addrContractNft;
    }

    //Function setting fee by trade
    function setFeeByTrade(uint _feeByTrade) external onlyOwner {
        feeByTrade = _feeByTrade;
    }

    //Function setting the price for a mint
    function setMintPrice(uint _price) public onlyOwner {
        mintPrice = _price; //todo: voir pour prend en compte les float (import math, mul etc)
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
        return addrContractNft;
    }
        

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

    //Function getter returning the owner of NFT by IERC721
    function _ownerOft(address _addressNft, uint _tokenId) public view returns(address){
        return IERC721(_addressNft).ownerOf(_tokenId);
    }

    //Function getter returning the fee by trade
    function getFeeByTrade() internal view returns(uint){
        return feeByTrade;
    }

    //Function getter returning the state of a deal for MarketPlace.sol
    function getDealState(uint _nftID) public view returns(State){
        return dealingNftiDToStateOfDeal[_nftID];
    }

    //Function getter returning the price of a deal for MarketPlace.sol
    function getDealPrice(uint _nftID) public view returns(uint){
        return dealingNftIDToPrice[_nftID];
    }


    //Function setting the owner of NFT used in Marketplace.sol for a trade
    function setOwnerOfNft(address _addressNft, address _addressOwner) internal onlyOwner {
        nftOwners[_addressNft] = _addressOwner;
    }

    function _transferFrom(address _from, address _to, uint256 _tokenId) internal {
        IERC721(addrContractNft).transferFrom(_from, _to, _tokenId);
    }

}
