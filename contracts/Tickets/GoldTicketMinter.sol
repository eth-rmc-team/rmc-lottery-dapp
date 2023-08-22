// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import './TicketMinter.sol';

contract GoldTicketMinter is TicketMinter 
{
    constructor() TicketMinter("GoldTicket", "GTCK") 
    {
    }
}