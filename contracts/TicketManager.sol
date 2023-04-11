// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
 
contract TicketManager {

    address private owner;

    //ERC721 address for the minting contract
    address public addrContractNft;
    address public addrMarketPlace;

    uint feeByTrade;

    uint[] caracteristics;

    uint private mintPrice; //in Avax
    //Array of caracteristics picked during a cycle
    uint[] combinationPicked;

    //Mapping (nftAddress => ownerAdress)
    //Completed when a user uses the MarketPlace for a trade 
    //in order to know whose the NFT belongs to

    mapping(address => address) private nftOwners;
    mapping(address => int) private nftPrices;

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

    function setAddrNftContract(address _addrContractNft) external onlyOwner {
        addrContractNft = _addrContractNft;
    }

    function  getAddrNftContract() public view returns(address){
        return addrContractNft;
    }
        
    //Function setting the price for a mint
    function setMintPrice(uint _price) public onlyOwner {
        mintPrice = _price; //todo: voir pour prend en compte les float (import math, mul etc)
    }

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
    function getOwnerOfNft(address _addressNft, uint _tokenId) public view returns(address){
        return IERC721(_addressNft).ownerOf(_tokenId);
    }

    //Function setting the owner of NFT todo: pour l'instant que pour Marketplace.sol
    function setOwnerOfNft(address _addressNft, address _addressOwner) public onlyOwner {
        nftOwners[_addressNft] = _addressOwner;
    }

    //todo: update 20230411 20h41 => surement à supprimer
    //Function used by MarketPlace.sol to update the ownership and price (if on sale) of NFT
    function updateNftRecordings(address _addrNft, uint _priceToSell, uint mode) internal {
        //If freshly minted, we set nftOwners and nftPrices
        if( mode == 0 ){
            nftOwners[_addrNft] = msg.sender;
            nftPrices[_addrNft] = -1;
        }
        //Trade is live, seller gives protocol ownership on NFT
        else if( mode == 1 ){
            require(nftPrices[_addrNft] == -1, "WARNING :: NFT already on sale");
            //Here, msg.sender = seller
            nftOwners[_addrNft] = msg.sender;
            nftPrices[_addrNft] = int(_priceToSell);
        }
        //Trade is finished, protocol gives buyer ownership of NFT
        else {
            //Here, msg.sender = buyer if the deal is succeeded, or seller if he stopped it
            nftOwners[_addrNft] = msg.sender;
            nftPrices[_addrNft] = -1;
        }
    }

    function _transferFrom(address _from, address _to, uint256 _tokenId) external {
        IERC721(addrContractNft).transferFrom(_from, _to, _tokenId);
    }

}