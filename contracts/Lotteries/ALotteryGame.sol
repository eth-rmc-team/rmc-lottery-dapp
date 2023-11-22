// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../Services/Interfaces/IDiscoveryService.sol";
import "../Services/Whitelisted.sol";

abstract contract ALotteryGame is Whitelisted
{    
    IDiscoveryService discoveryService;
    uint256 winningCombination;

    uint256 lastStepAt;
    uint256 minimumTimeStep;

    uint16 ticketCapacity;
    uint16 ticketsSold;
    uint8 lotteryId;
    uint8 totalSteps;
    uint8 currentStep;
    bool isCycleRunning;

    event Received(address, uint);

    modifier onlyWhenCycleNotRunning() {
        require(
            !isCycleRunning, 
            "The owner cannot perform this action when a game is in progress"
        );
        _;
    }

    //Function to allow this contract to reveive value from other contracts
    receive() external payable  
    {
        emit Received(msg.sender, msg.value);
    }

    function setDiscoveryService(address _address) external onlyAdmin onlyWhenCycleNotRunning 
    {
        discoveryService = IDiscoveryService(_address);
    }

    function setTicketCapacity(uint16 _ticketCapacity) external onlyAdmin onlyWhenCycleNotRunning
    {
        ticketCapacity = _ticketCapacity;
    }

    function setMinimumTimeStep(uint256 _minimumTimeStep) external onlyAdmin onlyWhenCycleNotRunning
    {
        minimumTimeStep = _minimumTimeStep;
    }

    function setTotalSteps(uint8 _totalSteps) external onlyAdmin onlyWhenCycleNotRunning
    {       
        totalSteps = _totalSteps;
    }

    function getLotteryId() external view returns(uint8) 
    {
        return lotteryId;
    }

    function getMinimumTimeStep() external view returns(uint256) 
    {
        return minimumTimeStep;
    }

    function getTicketsSold() external view returns(uint16) 
    {
        return ticketsSold;
    }

    function getCurrentStep() public view returns(uint256) 
    {
        return currentStep;
    }
        
    function getWinningCombination() public view returns(uint256) 
    {
        return winningCombination;
    }

    function getIsCycleRunning() public view returns(bool)
    {
        return isCycleRunning;
    }


    /** 
        ABSTRACT FUNCTIONS
     */
    function resetCycle() virtual external;

    function buyTicket(string[] memory uris) payable virtual external;

    function nextStep() virtual public;

    function claimReward() external virtual payable;

    function endCycle() external virtual;
}