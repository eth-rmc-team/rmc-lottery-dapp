// contracts/MythicTicket.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./Ticket.sol";

contract MythicTicket is Ticket {
    constructor(string memory lottery_id, string memory _symbol) 
    Ticket(lottery_id, _symbol) {}
}