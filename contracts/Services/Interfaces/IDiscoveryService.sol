// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IDiscoveryService
{
    function getNormalTicketAddr() view external returns (address);

    function getGoldTicketAddr() view external returns (address);

    function getSuperGoldTicketAddr() view external returns (address);

    function getMythicTicketAddr() view external returns (address);

    function getPlatiniumTicketAddr() view external returns (address);

    function getPrizepoolDispatcherAddr() view external returns (address);

    function getLotteryGameAddr() view external returns (address);

    function getFusionHandlerAddr() view external returns (address);
    
    function getRmcMarketplaceAddr() view external returns (address);

    function getTicketRegistryAddr() view external returns (address);
}
