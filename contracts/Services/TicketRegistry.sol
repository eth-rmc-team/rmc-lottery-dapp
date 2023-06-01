// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../Librairies/LotteryDef.sol";

contract TicketRegistry 
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
    ) external
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

    //Function setting informations about a NFT from the Marketplace contract 
    //(owner, state of deal, price)
    //todo: faire de meme avec tokenId, addresseCOntract et Type NFT depuis le Minter et Fusion
    function setTicketInfo(
        uint _tokenId, 
        address payable _ticketOwner, 
        LotteryDef.TicketState _dealState, 
        uint256 _dealPrice 
    ) external 
    {             
        ticketInfos[_tokenId].ticketOwner = _ticketOwner;
        ticketInfos[_tokenId].dealState = _dealState;
        ticketInfos[_tokenId].dealPrice = _dealPrice;
    }

    function setPrizepoolClaimStatus(bool _status, uint _tokenId) external 
    {
        ticketInfos[_tokenId].isPrizepoolClaimed = _status;
    }

    function setFeesClaimStatus(bool _status, uint _tokenId) external 
    {
        ticketInfos[_tokenId].isFeesClaimed = _status;
    }
    //End of functions

    function getTicketState(uint _tokenId) 
    external view returns (
        LotteryDef.TicketType, 
        address, 
        address payable, 
        LotteryDef.TicketState, 
        uint
    ) 
    {
        return (
            ticketInfos[_tokenId].ticketType, 
            ticketInfos[_tokenId].contractAddress, 
            ticketInfos[_tokenId].ticketOwner, 
            ticketInfos[_tokenId].dealState, 
            ticketInfos[_tokenId].dealPrice
        );
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