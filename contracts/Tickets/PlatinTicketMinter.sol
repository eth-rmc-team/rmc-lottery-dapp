// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./SpecialTicketMinter.sol";

contract PlatinTicketMinter is SpecialTicketMinter {
    bool public isPlatinTicketMinted = false;

    constructor() SpecialTicketMinter("PlatinTicket", "PTCK") {}

    function mintForProtocol() external onlyAdmin {
        require(
            isPlatinTicketMinted == false,
            "Platin ticket is already minted"
        );
        for (uint8 i = 0; i < 6; i++) {
            mintSpecial(msg.sender, LotteryDef.TicketType.PLATIN);
        }
        isPlatinTicketMinted = true;
    }
}
