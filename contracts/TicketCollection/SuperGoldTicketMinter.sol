//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import '../TicketMinterManager.sol';

contract SuperGoldTicketMinter is TicketMinterManager 
{
    constructor() TicketMinterManager("SuperGoldTicket", "SGTCK") 
    {
        addrSuperGoldNftContract = address(this);
    }
}