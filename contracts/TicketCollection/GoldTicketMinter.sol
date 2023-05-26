//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import '../TicketMinterManager.sol';

contract GoldTicketMinter is TicketMinterManager 
{
    constructor() TicketMinterManager("GoldTicket", "GTCK") 
    {
        addrGoldNftContract = address(this);
    }
}