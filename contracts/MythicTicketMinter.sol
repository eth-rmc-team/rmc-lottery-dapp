//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import './TicketMinterManager.sol';

contract MythicTicketMinter is TicketMinterManager 
{    
    constructor() TicketMinterManager("MythicTicket", "MTCK") 
    {
        addrMythicNftContract = address(this);
    }
}