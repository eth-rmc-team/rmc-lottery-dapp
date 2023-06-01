//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../../Services/TicketRegistry.sol";  
import "../../Librairies/LotteryDef.sol";
import "./ITicketMinter.sol";

interface INormalTicketMinter is ITicketMinter
{    
    function addABatchOfMintableTickets(
        string[] calldata uris, 
        uint32[] calldata features
    ) external;
    
    function mintTicket(
        string memory uri,
        address _addrMinter,
        uint8 suffix
    ) external returns (uint256);

    function isValidUri(string memory uri) external view returns (bool);

    function getUriFeatures(string memory uri) external view returns (uint32);
}