//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import './Interfaces/IRMCLotteryInfo.sol';
import "./TicketInformationController.sol";
import "hardhat/console.sol";

//Contract minting NFT

contract TicketMinterManager is ERC721URIStorage, TicketInformationController 
{

    mapping(string => uint32) public validUris;

    uint8 lotteryId;

    event ItemMinted(uint256 tokenId, address creator, string uri, NftType nftType);
    
    constructor(string memory name , string memory symbol) ERC721(name, symbol) 
    {
        addrNftMinter = address(this);
    }

    function setLotteryId(uint8 _lotteryId) external onlyWhiteListedAddress 
    {
        lotteryId = _lotteryId;
    }

    //Take an string in parameter, return true if the string is a valid uri
    function isValidUri(string memory uri) external view returns(bool) 
    {
        return validUris[uri] > 0;
    }

    function getUriFeatures(string memory uri) external view returns(uint32) 
    {
        return validUris[uri];
    }

    function initializeBoxOffice(
        string[] calldata uris, 
        uint32[] calldata features,
        uint8[] calldata _featuresByDay
    ) 
    external onlyOwner 
    {
        require(
            uris.length == features.length, 
            "ERROR :: uris and features must have the same length."
        );
        require(
            uris.length > 0, 
            "ERROR :: uris and features must not be empty."
        );

        require(
            _featuresByDay.length > 0,
            "ERROR :: featuresByDay must not be empty."
        );

        for(uint256 i = 0; i < uris.length; i++) {
            validUris[uris[i]] = features[i];
        }
        for(uint8 i = 0; i < _featuresByDay.length; i++) {
            featuresByDay[i+1] = _featuresByDay[i];
        }
    }

    //Function getter returning the address of the NftMinter contract
    function getAddrNftMinterManager() public view returns(address) 
    {
        return address(this);
    }
    
    function createTicket(
        string memory uri, 
        address _addrMinter, 
        NftType _nftType
    ) external onlyWhiteListedAddress
    {
        require(
            validUris[uri] > 0,
            "ERROR :: This metadata has already been used to mint an NFT."
        );

        //uint _lotteryId = IRMCLotteryInfo(addrLotteryGame).getLotteryId();
        uint tokenId = (validUris[uri] * 100) + lotteryId;

        _safeMint(_addrMinter, tokenId);
        _setTokenURI(tokenId, uri);

        idNftToNftInfos[tokenId] = nftInfo(
            _nftType, 
            address(this), 
            payable(_addrMinter), 
            State.NODEAL, 
            0, 
            false, 
            false
        );
        validUris[uri] = 0;

        emit ItemMinted(tokenId, _addrMinter, uri, NftType.NORMAL);
    }

    function burn(uint tokenId) external onlyWhiteListedAddress 
    {
        require(_exists(tokenId), "Token does not exist.");
        _burn(tokenId);
    }
}