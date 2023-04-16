//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "../TicketInformationController.sol";

//Contract minting NFT

contract TicketMinterManager is ERC721URIStorage, TicketInformationController {

    mapping(string => bool) public hasBeenMinted;

    event ItemMinted(uint256 tokenId, address creator, string metadata, NftType nftType);
    
    constructor(string memory name , string memory symbol ) ERC721(name, symbol) {
        addrNftMinter = address(this);

    }

    //Function getter returning the address of the NftMinter contract
    function getAddrNftMinterManager() public view returns(address) {
        return address(this);
    }

    function createNormalTicket(string memory metadata, address _addrMinter, NftType _nftType) public returns (uint256)
    {
        require(
            !hasBeenMinted[metadata],
            "ERROR :: This metadata has already been used to mint an NFT."
        );

        nftInfo memory newNftInfo = nftInfo(_nftType, address(this), 0, payable(_addrMinter), State.NoDeal, 0, false, false);

        uint256 newItemId = 0;

        _safeMint(msg.sender, newItemId);
        _setTokenURI(newItemId, metadata);
        idNftToNftInfos[newItemId] = newNftInfo;
        hasBeenMinted[metadata] = true;
        emit ItemMinted(newItemId, msg.sender, metadata, NftType.Normal);
        
        return newItemId;
    }

    function burn(uint tokenId) public onlyOwner {
        require(_exists(tokenId), "Token does not exist.");
        _burn(tokenId);
    }
    
}