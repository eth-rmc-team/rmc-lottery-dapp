//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './LotteryManager.sol';

contract TicketStaking is LotteryManager{

    uint [] public idTicketsStaked;
    mapping (address => uint[]) public addressToidTicketsStaked;

    constructor() {

    }

    

}