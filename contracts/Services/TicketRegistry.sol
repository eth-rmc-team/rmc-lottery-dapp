// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../Librairies/LotteryDef.sol";

import "./Whitelisted.sol";

contract TicketRegistry is Whitelisted
{
    using LotteryDef for LotteryDef.TicketState;
    using LotteryDef for LotteryDef.TicketType;
    using LotteryDef for LotteryDef.TicketInfo;
    
    mapping(address => mapping(uint256 => LotteryDef.TicketInfo)) public ticketInfos;

    constructor() {}

    function addNewTicket(
        uint256 _tokenId,
        LotteryDef.TicketType _ticketType,           
        address _contractAddress,
        address payable _ticketOwner,         
        LotteryDef.TicketState _dealState,      
        uint256 _dealPrice
    ) external onlyWhitelisted
    {
        ticketInfos[_contractAddress][_tokenId] = LotteryDef.TicketInfo(
            _ticketType,
            _ticketOwner,
            _dealState,
            _dealPrice
        );
    }

    function putTicketOnSale(address _addressTicket, uint256 _tokenId, uint256 _dealPrice) external onlyWhitelisted
    {
        ticketInfos[_addressTicket][_tokenId].dealState = LotteryDef.TicketState.DEALING;
        ticketInfos[_addressTicket][_tokenId].dealPrice = _dealPrice;
    }

    function removeSalesTicket(address _addressTicket, uint256 _tokenId) external onlyWhitelisted
    {
        ticketInfos[_addressTicket][_tokenId].dealState = LotteryDef.TicketState.NODEAL;
        ticketInfos[_addressTicket][_tokenId].dealPrice = 0;
    }

    function transferTicketOwnership(address _addressTicket, uint256 _tokenId, address payable _newOwner) external onlyWhitelisted
    {
        ticketInfos[_addressTicket][_tokenId].ticketOwner = _newOwner;
        ticketInfos[_addressTicket][_tokenId].dealState = LotteryDef.TicketState.NODEAL;
        ticketInfos[_addressTicket][_tokenId].dealPrice = 0;
    }

    //End of functions

    function getTicketState(address _addressTicket, uint _tokenId) external view returns (LotteryDef.TicketInfo memory) 
    {
        return ticketInfos[_addressTicket][_tokenId];
    }

}