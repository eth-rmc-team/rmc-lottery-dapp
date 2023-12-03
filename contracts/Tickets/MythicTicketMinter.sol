// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./SpecialTicketMinter.sol";

contract MythicTicketMinter is SpecialTicketMinter {
    constructor() SpecialTicketMinter("MythicTicket", "%TCK") {}
}
