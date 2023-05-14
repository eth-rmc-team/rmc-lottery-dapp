// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './IRMCFeeInfo.sol';
import './IRMCTicketInfo.sol';
import './IRMCLotteryInfo.sol';

interface IRMCFull is IRMCFeeInfo, IRMCTicketInfo, IRMCLotteryInfo  {

}