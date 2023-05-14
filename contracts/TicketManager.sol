// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

//Contract managing NFTs for deal on Marketplace.sol and mint on RmcNftMinter.sol 

contract TicketManager {

    address private owner;
    address public whiteListedAddr;

    address public addrMarketPlace;
    address public addrTicketFusion;
    address public addrNftMinter;
    address public addrLotteryGame;
    address public addrFeeManager;
    
    //ERC721 address for the minting contract
    address public addrNormalNftContract;
    address public addrGoldNftContract;
    address public addrSuperGoldNftContract;
    address public addrMythicNftContract;
    address public addrPlatinNftContract;

    uint public normalTicketFusionRequirement; 
    uint public goldTicketFusionRequirement;

    uint[] caracteristics;

    uint public mintPrice; //in Avax
    //Array of caracteristics picked during a cycle
    uint[] combinationPicked;

    mapping(address => bool) public whiteListedAddresses;

    constructor() {
        owner = msg.sender;
        mintPrice = 25; //(todo: a mettre en float), actuellement il faudra multiplier par 10 ** 17

    }
    
    //todo: mettre à terme une whiteList, plutot qu'une adresse unique
    modifier onlyOwner {
         _;
    }

    modifier onlyWhiteListedAddress {
        bool status = whiteListedAddresses[msg.sender];
        require(status == true, "ERROR :: Only the Marketplace contract can call this function");
        _;
    }

    //function updateCaracteristic(uint _carac) public
    // A faire 

    //Function setting the address of the TicketFusion contract
    function setAddrTicketFusion(address _addrTicketFusion) external onlyOwner {
        addrTicketFusion = _addrTicketFusion;
        whiteListedAddresses[_addrTicketFusion] = true;
    }

    //Function setting the address of the MarketPlace contract
    function setAddrMarketPlace(address _addrMarketPlace) external onlyOwner {
        addrMarketPlace = _addrMarketPlace;
        whiteListedAddresses[_addrMarketPlace] = true;
    }

    //function setting the address of the NftMinter contract
    function setAddrNftMinter(address _addrNftMinter) external onlyOwner {
        addrNftMinter = _addrNftMinter;
        whiteListedAddresses[_addrNftMinter] = true;
    }

    function setAddrLotteryGameContract(address _addrLotteryGameContract) external onlyOwner {
        addrLotteryGame = _addrLotteryGameContract;
        whiteListedAddresses[_addrLotteryGameContract] = true;
    }

    function setAddrFeeManagerContract(address _addrFeeManagerContract) external onlyOwner {
        addrFeeManager = _addrFeeManagerContract;
        whiteListedAddresses[_addrFeeManagerContract] = true;
    }

    function deleteWhiteListedAddress(address _addr) external onlyOwner {
        whiteListedAddresses[_addr] = false;
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
    
    //Function getter returning the address of the TicketFusion contract
    function getAddrTicketFusionContract() public view returns(address) {
        return addrTicketFusion;
    }

    //Function getter returning de caracteristic of the day
    function getCaracteristicsForADay(uint _day) public view returns(uint){
        return caracteristics[_day];
    }

}
