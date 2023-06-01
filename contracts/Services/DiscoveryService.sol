pragma solidity ^0.8.11;

import "@openzeppelin/contracts/access/Ownable.sol";

/** 
    This service hold all contrats addresses 
    composing the lotterygame
 */
contract DiscoveryService is Ownable
{
    address private normalTicketAddr;
    address private goldTicketAddr;
    address private superGoldTicketAddr;
    address private mythicTicketAddr;
    address private platinumTicketAddr;

    address private ticketRegistryAddr;
    address private prizepoolDispatcherAddr;
    address private lotteryGameAddr;
    address private fusionHandlerAddr;
    address private rmcMarketplaceAddr;

    //external getter for normalTicketAddr
    function getNormalTicketAddr() view external returns (address)
    {
        return normalTicketAddr;
    }

    function getGoldTicketAddr() view external returns (address) 
    {
        return goldTicketAddr;
    }

    function getSuperGoldTicketAddr() view external returns (address)
    {
        return superGoldTicketAddr;
    }

    function getMythicTicketAddr() view external returns (address)
    {
        return mythicTicketAddr;
    }

    function getPlatiniumTicketAddr() view external returns (address)
    {
        return platinumTicketAddr;
    }

    function getPrizepoolDispatcherAddr() view external returns (address)
    {
        return prizepoolDispatcherAddr;
    }
    function getLotteryGameAddr() view external returns (address)
    {
        return lotteryGameAddr;
    }

    function getFusionHandlerAddr() view external returns (address)
    {
        return fusionHandlerAddr;
    }
    
    function getRmcMarketplaceAddr() view external returns (address)
    {
        return rmcMarketplaceAddr;
    }

    function setNormalTicketAddr(address _normalTicketAddr) external onlyOwner
    {
        normalTicketAddr = _normalTicketAddr;
    }

    function setGoldTicketAddr(address _goldTicketAddr) external onlyOwner
    {
        goldTicketAddr = _goldTicketAddr;
    }

    function setSuperGoldTicketAddr(address _superGoldTicketAddr) external onlyOwner
    {
        superGoldTicketAddr = _superGoldTicketAddr;
    }

    function setMythicTicketAddr(address _mythicTicketAddr) external onlyOwner
    {
        mythicTicketAddr = _mythicTicketAddr;
    }

    function setPlatiniumTicketAddr(address _platinumTicketAddr) external onlyOwner
    {
        platinumTicketAddr = _platinumTicketAddr;
    }

    function setPrizepoolDispatcherAddr(address _prizepoolDispatcherAddr) external onlyOwner
    {
        prizepoolDispatcherAddr = _prizepoolDispatcherAddr;
    }

    function setLotteryGameAddr(address _lotteryGameAddr) external onlyOwner
    {
        lotteryGameAddr = _lotteryGameAddr;
    }

    function setFusionHandlerAddr(address _fusionHandlerAddr) external onlyOwner
    {
        fusionHandlerAddr = _fusionHandlerAddr;
    }
    
    function setRmcMarketplaceAddr(address _rmcMarketplaceAddr) external onlyOwner
    {
        rmcMarketplaceAddr = _rmcMarketplaceAddr;
    }
    
    function setTicketRegistryAddr(address _ticketRegistryAddr) external onlyOwner
    {
        ticketRegistryAddr = _ticketRegistryAddr;
    }
}
