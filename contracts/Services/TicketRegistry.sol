// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../Librairies/LotteryDef.sol";

import "./Whitelisted.sol";

contract TicketRegistry is Whitelisted
{
    using LotteryDef for LotteryDef.TicketState;
    using LotteryDef for LotteryDef.TicketType;
    using LotteryDef for LotteryDef.TicketInfo;
    
    mapping(uint256 => LotteryDef.TicketInfo) public ticketInfos;

    constructor() {}

    function addNewTicket(
        uint256 _tokenId,
        LotteryDef.TicketType _ticketType,           
        address _contractAddress,
        address payable _ticketOwner,         
        LotteryDef.TicketState _dealState,      
        uint256 _dealPrice,        
        bool _isPrizepoolClaimed, 
        bool _isFeesClaimed
    ) external onlyWhitelisted
    {
        ticketInfos[_tokenId] = LotteryDef.TicketInfo(
            _ticketType,
            _contractAddress,
            _ticketOwner,
            _dealState,
            _dealPrice,
            _isPrizepoolClaimed,
            _isFeesClaimed
        );
    }

    function putTicketOnSale(uint256 _tokenId, uint256 _dealPrice) external onlyWhitelisted
    {
        ticketInfos[_tokenId].dealState = LotteryDef.TicketState.DEALING;
        ticketInfos[_tokenId].dealPrice = _dealPrice;
    }

    function removeSalesTicket(uint256 _tokenId) external onlyWhitelisted
    {
        ticketInfos[_tokenId].dealState = LotteryDef.TicketState.NODEAL;
        ticketInfos[_tokenId].dealPrice = 0;
    }

    function transferTicketOwnership(uint256 _tokenId, address payable _newOwner) external onlyWhitelisted
    {
        ticketInfos[_tokenId].ticketOwner = _newOwner;
        ticketInfos[_tokenId].dealState = LotteryDef.TicketState.NODEAL;
        ticketInfos[_tokenId].dealPrice = 0;
    }

    function setPrizepoolClaimStatus(bool _status, uint _tokenId) external onlyWhitelisted
    {
        ticketInfos[_tokenId].isPrizepoolClaimed = _status;
    }

    function setFeesClaimStatus(bool _status, uint _tokenId) external onlyWhitelisted
    {
        ticketInfos[_tokenId].isFeesClaimed = _status;
    }
    //End of functions

    function getTicketState(uint _tokenId) external view returns (LotteryDef.TicketInfo memory) 
    {
        return ticketInfos[_tokenId];
    }

    function getClaimedRewardStatus(uint _tokenId) 
    external view returns(
        bool, 
        bool 
    ) 
    {
        return (
            ticketInfos[_tokenId].isPrizepoolClaimed, 
            ticketInfos[_tokenId].isFeesClaimed
        );
    }
}