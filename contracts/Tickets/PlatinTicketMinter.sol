// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./SpecialTicketMinter.sol";

contract PlatinTicketMinter is SpecialTicketMinter {
    constructor() SpecialTicketMinter("PlatinTicket", "PTCK") {}
}
