// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import "../../Librairies/LotteryDef.sol";
import "../../Librairies/ILotteryDef.sol";

interface ITicketRegistry is IERC721Enumerable, ILotteryDef
{
    function addNewTicket(
        uint256 _tokenId,
        LotteryDef.TicketType _ticketType,           
        address _contractAddress,
        address payable _ticketOwner,         
        LotteryDef.TicketState _dealState,      
        uint256 _dealPrice,        
        bool _isPrizepoolClaimed, 
        bool _isFeesClaimed
    ) external;

    function setTicketState(
        uint _tokenId, 
        address _ticketOwner, 
        LotteryDef.TicketState _dealState, 
        uint _dealPrice
    ) external;
       
    function setPrizepoolClaimStatus(bool _statusPP, uint _tokenId) external;

    function setFeesClaimStatus(bool _statusFee, uint _tokenId) external;

    function getTicketState(uint _tokenId) 
    external view returns (
        LotteryDef.TicketType, 
        address, 
        address payable, 
        LotteryDef.TicketState, 
        uint
    );
    
    function getClaimedRewardStatus(uint _tokenId)
    external view returns(bool, bool);
}