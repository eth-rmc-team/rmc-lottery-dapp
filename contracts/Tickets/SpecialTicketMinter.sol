// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./TicketMinter.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

abstract contract SpecialTicketMinter is TicketMinter {
    using Counters for Counters.Counter;
    Counters.Counter private tokenId;

    string uri;

    constructor(
        string memory _name,
        string memory _symbol
    ) TicketMinter(_name, _symbol) {}

    function _setURI(string memory _uri) external onlyWhitelisted {
        uri = _uri;
    }

    function mintSpecial(
        address _to
    ) external onlyWhitelisted returns (uint256) {
        uint256 _tokenId;
        _tokenId = tokenId.current();
        tokenId.increment();

        _safeMint(_to, _tokenId);
        _setTokenURI(_tokenId, uri);

        ITicketRegistry(discoveryService.getTicketRegistryAddr()).addNewTicket(
            _tokenId,
            LotteryDef.TicketType.NORMAL,
            address(this),
            payable(_to),
            LotteryDef.TicketState.NODEAL,
            0
        );

        return _tokenId;
    }
}
