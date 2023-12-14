// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./Whitelisted.sol";

/** 
    This service hold all contrats addresses 
    composing the lotterygame
 */
contract DiscoveryService is Whitelisted {
    address private normalTicketAddr;
    address private goldTicketAddr;
    address private superGoldTicketAddr;
    address private mythicTicketAddr;
    address private platinumTicketAddr;

    address private ticketRegistryAddr;
    address private prizepoolDispatcherAddr;
    address private lotteryGameAddr;
    address private goldenLotteryAddr;
    address private silverLotteryAddr;
    address private fusionHandlerAddr;
    address private rmcMarketplaceAddr;
    address private randomizerAddr;

    //external getter for normalTicketAddr
    function getNormalTicketAddr() external view returns (address) {
        return normalTicketAddr;
    }

    function getGoldTicketAddr() external view returns (address) {
        return goldTicketAddr;
    }

    function getSuperGoldTicketAddr() external view returns (address) {
        return superGoldTicketAddr;
    }

    function getMythicTicketAddr() external view returns (address) {
        return mythicTicketAddr;
    }

    function getPlatiniumTicketAddr() external view returns (address) {
        return platinumTicketAddr;
    }

    function getPrizepoolDispatcherAddr() external view returns (address) {
        return prizepoolDispatcherAddr;
    }

    function getLotteryGameAddr() external view returns (address) {
        return lotteryGameAddr;
    }

    function getGoldenLotteryAddr() external view returns (address) {
        return goldenLotteryAddr;
    }

    function getSilverLotteryAddr() external view returns (address) {
        return silverLotteryAddr;
    }

    function getFusionHandlerAddr() external view returns (address) {
        return fusionHandlerAddr;
    }

    function getRmcMarketplaceAddr() external view returns (address) {
        return rmcMarketplaceAddr;
    }

    function getTicketRegistryAddr() external view returns (address) {
        return ticketRegistryAddr;
    }

    function getRandomizerAddr() external view returns (address) {
        return randomizerAddr;
    }

    function setNormalTicketAddr(address _normalTicketAddr) external onlyAdmin {
        normalTicketAddr = _normalTicketAddr;
    }

    function setGoldTicketAddr(address _goldTicketAddr) external onlyAdmin {
        goldTicketAddr = _goldTicketAddr;
    }

    function setSuperGoldTicketAddr(
        address _superGoldTicketAddr
    ) external onlyAdmin {
        superGoldTicketAddr = _superGoldTicketAddr;
    }

    function setMythicTicketAddr(address _mythicTicketAddr) external onlyAdmin {
        mythicTicketAddr = _mythicTicketAddr;
    }

    function setPlatiniumTicketAddr(
        address _platinumTicketAddr
    ) external onlyAdmin {
        platinumTicketAddr = _platinumTicketAddr;
    }

    function setPrizepoolDispatcherAddr(
        address _prizepoolDispatcherAddr
    ) external onlyAdmin {
        prizepoolDispatcherAddr = _prizepoolDispatcherAddr;
    }

    function setLotteryGameAddr(address _lotteryGameAddr) external onlyAdmin {
        lotteryGameAddr = _lotteryGameAddr;
    }

    function setGoldenLotteryAddr(
        address _goldenLotteryAddr
    ) external onlyAdmin {
        goldenLotteryAddr = _goldenLotteryAddr;
    }

    function setSilverLotteryAddr(
        address _silverLotteryAddr
    ) external onlyAdmin {
        silverLotteryAddr = _silverLotteryAddr;
    }

    function setFusionHandlerAddr(
        address _fusionHandlerAddr
    ) external onlyAdmin {
        fusionHandlerAddr = _fusionHandlerAddr;
    }

    function setRmcMarketplaceAddr(
        address _rmcMarketplaceAddr
    ) external onlyAdmin {
        rmcMarketplaceAddr = _rmcMarketplaceAddr;
    }

    function setTicketRegistryAddr(
        address _ticketRegistryAddr
    ) external onlyAdmin {
        ticketRegistryAddr = _ticketRegistryAddr;
    }

    function setRandomizerAddr(address _randomizerAddr) external onlyAdmin {
        randomizerAddr = _randomizerAddr;
    }
}
