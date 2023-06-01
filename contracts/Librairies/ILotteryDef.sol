// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ILotteryDef 
{
    enum TicketType { NORMAL, GOLD, SUPERGOLD, MYTHIC, PLATIN }
    enum Period { OFF, SALES, GAME, CLAIM, CHASE }
    enum TicketState { NODEAL, DEALING }

    //Struct containing all the information about a NFT
    struct TicketInfo {
        TicketType ticketType;            
        address contractAddress; 
        address payable ticketOwner;           
        TicketState dealState;       
        uint256 dealPrice;              
        bool isPrizepoolClaimed;   
        bool isFeesClaimed;         
    }
}
