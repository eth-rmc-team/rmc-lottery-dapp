//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./TicketMinter.sol";
import "../Services/Interfaces/ITicketRegistry.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NormalTicketMinter is TicketMinter
{
    using Counters for Counters.Counter;

    mapping(string => uint32) public validUris;

    constructor() TicketMinter("NormalTicket", "NTCK") {}

    function addABatchOfMintableTickets(
        string[] calldata uris, 
        uint32[] calldata features
    ) external onlyWhitelisted 
    {
        require(
            uris.length == features.length, 
            "ERROR :: uris and features must have the same length."
        );
        require(
            uris.length > 0, 
            "ERROR :: uris and features must not be empty."
        );

        for(uint256 i = 0; i < uris.length; i++) {
            validUris[uris[i]] = features[i];
        }
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
    
    function mintTicket(
        string memory uri, 
        address _addrMinter,
        uint8 suffix
    ) external onlyWhitelisted returns(uint256)
    {
        require(
            validUris[uri] > 0,
            "ERROR :: This metadata has already been used to mint an NFT."
        );

        uint tokenId = (validUris[uri] * 100) + suffix;

        _safeMint(_addrMinter, tokenId);
        _setTokenURI(tokenId, uri);

        ITicketRegistry(discoveryService.getTicketRegistryAddr()).addNewTicket(
            tokenId,
            LotteryDef.TicketType.NORMAL, 
            address(this), 
            payable(_addrMinter), 
            LotteryDef.TicketState.NODEAL, 
            0, 
            false, 
            false
        );

        validUris[uri] = 0;
        _tokenIdCounter.increment();
        
        emit ItemMinted(tokenId, _addrMinter, uri, LotteryDef.TicketType.NORMAL);

        return tokenId;
    }
}