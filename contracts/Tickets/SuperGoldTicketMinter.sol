// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import './TicketMinter.sol';

contract SuperGoldTicketMinter is TicketMinter 
{
    constructor() TicketMinter("SuperGoldTicket", "SGTCK") 
    {
    }
}