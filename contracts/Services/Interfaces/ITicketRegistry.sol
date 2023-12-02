// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import "../../Librairies/LotteryDef.sol";
import "../../Librairies/ILotteryDef.sol";

interface ITicketRegistry is IERC721Enumerable, ILotteryDef {
    function addNewTicket(
        uint256 _tokenId,
        LotteryDef.TicketType _ticketType,
        address _contractAddress,
        address payable _ticketOwner,
        LotteryDef.TicketState _dealState,
        uint256 _dealPrice
    ) external;

    function putTicketOnSale(
        address _addressTicket,
        uint256 _tokenId,
        uint256 _dealPrice
    ) external;

    function removeSalesTicket(address _ticketAddress, uint _tokenId) external;

    function transferTicketOwnership(
        address _ticketAddress,
        uint256 _tokenId,
        address _newOwner
    ) external;

    function getTicketState(
        address _ticketAddress,
        uint _tokenId
    ) external view returns (LotteryDef.TicketInfo memory);

    function setTicketDealState(
        uint _tokenId,
        LotteryDef.TicketState _dealState
    ) external;
}
