// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import './TicketMinter.sol';

contract PlatinTicketMinter is TicketMinter
{
    constructor() TicketMinter("PlatinTicket", "PTCK") 
    {
    }
}