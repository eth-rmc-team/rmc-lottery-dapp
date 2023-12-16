// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../Lotteries/Interfaces/ILotteryGame.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library LotteryDef {
    using SafeMath for uint256;

    enum TicketType {
        NORMAL,
        GOLD,
        SUPERGOLD,
        MYTHIC,
        PLATIN
    }
    enum Period {
        OFF,
        SALES,
        GAME,
        CLAIM,
        CHASE
    }
    enum TicketState {
        NODEAL,
        DEALING
    }

    //Struct containing all the information about a NFT
    struct TicketInfo {
        TicketType ticketType;
        address payable ticketOwner;
        TicketState dealState;
        uint256 dealPrice;
    }
}
