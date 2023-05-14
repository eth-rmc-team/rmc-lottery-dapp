//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './TicketMinterManager.sol';

contract NormalTicketMinter is TicketMinterManager {
    
    constructor() TicketMinterManager("NormalTicket", "NTCK") {
        addrNormalNftContract = address(this);
    }
    
}