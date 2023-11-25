// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import './TicketMinter.sol';
import "@openzeppelin/contracts/utils/Counters.sol";

contract MythicTicketMinter is TicketMinter 
{    
    using Counters for Counters.Counter;
    Counters.Counter private tokenId;

    string uri;
    constructor() TicketMinter("MythicTicket", "%TCK") 
    {
    }

    function _setURI(string memory _uri) external onlyWhitelisted 
    {
        uri = _uri;
    }

    function mintSpecial(address _to) external onlyWhitelisted returns(uint256)
    {
        uint256 _tokenId;
        _tokenId = tokenId.current();
        tokenId.increment();

        _safeMint(_to, _tokenId);
        _setTokenURI(_tokenId, uri);
        return _tokenId;

    }
}