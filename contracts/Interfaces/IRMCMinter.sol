//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import './IRMCTicketInfo.sol';

interface IRMCMinter is IRMCTicketInfo {
    //todo: issue de IRMCTicketInfo mais ne veut pas hériter
    //enum NftType { Normal, Gold, SuperGold, Mythic, Platin }


    //Functions from TicketMinterManager
    function createTicket(
        string memory metadata, 
        address _addrMinter, 
        NftType _nftType
    ) external;

    function setLotteryId(uint8 _lotteryId) external;
    
    function burn(uint tokenId) external;
}