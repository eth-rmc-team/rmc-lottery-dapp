// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

interface IDiscoveryService {
    function getNormalTicketAddr() external view returns (address);

    function getGoldTicketAddr() external view returns (address);

    function getSuperGoldTicketAddr() external view returns (address);

    function getMythicTicketAddr() external view returns (address);

    function getPlatiniumTicketAddr() external view returns (address);

    function getPrizepoolDispatcherAddr() external view returns (address);

    function getLotteryGameAddr() external view returns (address);

    function getFusionHandlerAddr() external view returns (address);

    function getRmcMarketplaceAddr() external view returns (address);

    function getTicketRegistryAddr() external view returns (address);

    function getRandomizerAddr() external view returns (address);
}
