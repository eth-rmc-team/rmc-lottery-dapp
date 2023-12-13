// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

import "../../Services/TicketRegistry.sol";
import "../../Librairies/LotteryDef.sol";
import "../../Librairies/ILotteryDef.sol";

interface ITicketMinter is IERC721Enumerable, ILotteryDef {
    function burn(uint tokenId) external;

    function totalSupply() external view returns (uint256);

    function tokenByIndex(uint256 index) external view returns (uint256);

    function isValidUri(string memory uri) external view returns (bool);

    function tokenOfOwnerByIndex(
        address owner,
        uint256 index
    ) external view returns (uint256);

    event ItemMinted(
        uint256 tokenId,
        address creator,
        string uri,
        LotteryDef.TicketType _ticketType
    );
}
