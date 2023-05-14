//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import '../Interfaces/IRMCLotteryInfo.sol';
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

    function createTicket(string memory metadata, address _addrMinter, NftType _nftType) external onlyWhiteListedAddress
    {
        require(
            !hasBeenMinted[metadata],
            "ERROR :: This metadata has already been used to mint an NFT."
        );

        uint _lotteryId = IRMCLotteryInfo(addrLotteryGame).getLotteryId();
        uint tokendId = _lotteryId; //todo: a changer, pour l'instant on utilise le lotteryId comme tokenId
        nftInfo memory newNftInfo = nftInfo(_nftType, address(this), payable(_addrMinter), State.NoDeal, 0, false, false);

        _safeMint(msg.sender, tokendId);
        _setTokenURI(tokendId, metadata);
        idNftToNftInfos[tokendId] = newNftInfo;
        hasBeenMinted[metadata] = true;
        emit ItemMinted(tokendId, msg.sender, metadata, NftType.Normal);
        
    }

    function burn(uint tokenId) external onlyWhiteListedAddress {
        require(_exists(tokenId), "Token does not exist.");
        _burn(tokenId);
    }
    
}