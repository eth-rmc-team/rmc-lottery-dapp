//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import '../TicketMinterManager.sol';

contract PlatinTicketMinter is TicketMinterManager
{
    constructor() TicketMinterManager("PlatinTicket", "PTCK") 
    {
        addrPlatinNftContract = address(this);
    }
}