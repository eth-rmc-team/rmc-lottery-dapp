// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./SpecialTicketMinter.sol";

contract SuperGoldTicketMinter is SpecialTicketMinter {
    constructor() SpecialTicketMinter("SuperGoldTicket", "SGTCK") {}
}
