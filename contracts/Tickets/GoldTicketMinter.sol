// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./SpecialTicketMinter.sol";

contract GoldTicketMinter is SpecialTicketMinter {
    constructor() SpecialTicketMinter("GoldTicket", "GTCK") {}
}
