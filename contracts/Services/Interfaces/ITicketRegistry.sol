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

    function putTicketOnSale(uint _tokenId, uint256 _dealPrice) external;
       
    function removeSalesTicket(uint _tokenId) external;

    function transferTicketOwnership(uint256 _tokenId, address payable _newOwner) external;

    function setPrizepoolClaimStatus(bool _statusPP, uint _tokenId) external;

    function setFeesClaimStatus(bool _statusFee, uint _tokenId) external;

    function getTicketState(uint _tokenId) external view returns (LotteryDef.TicketInfo memory);
    
    function setTicketDealState(uint _tokenId, LotteryDef.TicketState _dealState) external;

    function getClaimedRewardStatus(uint _tokenId)
    external view returns(bool, bool);
}