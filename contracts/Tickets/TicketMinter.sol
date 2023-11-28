// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

import "../Services/Whitelisted.sol";

import "../Librairies/LotteryDef.sol";
import "../Services/Interfaces/IDiscoveryService.sol";

import "../Services/Interfaces/ITicketRegistry.sol";

import "hardhat/console.sol";

abstract contract TicketMinter is ERC721URIStorage, ERC721Enumerable, Whitelisted {
    using LotteryDef for LotteryDef.TicketState;
    using LotteryDef for LotteryDef.TicketType;

    IDiscoveryService discoveryService;

    event ItemMinted(uint256 tokenId, address creator, string uri, LotteryDef.TicketType nftType);
    
    constructor(string memory name , string memory symbol) ERC721(name, symbol) {}

    
    function _beforeTokenTransfer(address from, address to, uint256 firstTokenId, uint256 batchSize) internal override(ERC721, ERC721Enumerable) {
        ERC721Enumerable._beforeTokenTransfer(from, to, firstTokenId, batchSize);
    }

    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        ERC721URIStorage._burn(tokenId);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) 
    {
        return ERC721URIStorage.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    function transferFrom(
        address from, 
        address to, 
        uint256 tokenId
    ) public override(ERC721) onlyWhitelisted {
        super.transferFrom(from, to, tokenId);
    }

    function safeTransferFrom(
        address from, 
        address to, 
        uint256 tokenId,
        bytes memory _data
    ) public override(ERC721) onlyWhitelisted {
        super.safeTransferFrom(from, to, tokenId, _data);
    }

    function setDiscoveryService(address _address) external onlyAdmin {
        discoveryService = IDiscoveryService(_address);
    }

    function burn(uint tokenId) external onlyWhitelisted {
        require(_exists(tokenId), "Token does not exist.");
        _burn(tokenId);
    }

}
