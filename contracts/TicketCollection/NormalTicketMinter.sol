//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import '../TicketMinterManager.sol';

contract NormalTicketMinter is TicketMinterManager
{
    constructor() TicketMinterManager("NormalTicket", "NTCK")
    {
        addrNormalNftContract = address(this);
    }
}