//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import './TicketMinter.sol';

contract MythicTicketMinter is TicketMinter 
{    
    constructor() TicketMinter("MythicTicket", "%TCK") 
    {
    }
}