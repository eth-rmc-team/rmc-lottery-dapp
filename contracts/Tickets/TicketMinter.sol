//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "../Librairies/LotteryDef.sol";
import "../Services/Interfaces/IDiscoveryService.sol";

import "hardhat/console.sol";

//Contract minting NFT

abstract contract TicketMinter is ERC721URIStorage, IERC721Enumerable, Ownable
{
    using Counters for Counters.Counter;
    using LotteryDef for LotteryDef.TicketState;
    using LotteryDef for LotteryDef.TicketType;

    IDiscoveryService discoveryService;
    Counters.Counter internal _tokenIdCounter;

    event ItemMinted(uint256 tokenId, address creator, string uri, LotteryDef.TicketType nftType);
    
    constructor(string memory name , string memory symbol) ERC721(name, symbol) IERC721Enumerable() 
    {}

    function setDiscoveryService(address _address) external onlyOwner 
    {
        discoveryService = IDiscoveryService(_address);
    }

    function burn(uint tokenId) external 
    {
        require(_exists(tokenId), "Token does not exist.");
        _burn(tokenId);
    }

    function totalSupply() external view override returns (uint256) {
        return _tokenIdCounter.current();
    }

    function tokenByIndex(uint256 index) external view override returns (uint256) {
        require(index < _tokenIdCounter.current(), "ERC721Enumerable: Invalid index");
        return index;
    }

    function tokenOfOwnerByIndex(address owner, uint256 index) external view override returns (uint256) {
        require(index < balanceOf(owner), "ERC721Enumerable: Invalid index");
        return index;
    }
}