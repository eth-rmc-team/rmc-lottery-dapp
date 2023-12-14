// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "./Whitelisted.sol";
import "./Interfaces/IDiscoveryService.sol";
import "./Interfaces/IRandomizer.sol";

contract Randomizer is VRFConsumerBase, Whitelisted {
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;

    IDiscoveryService private discoveryService;

    mapping(bytes32 => uint256) public randomResults;
    mapping(bytes32 => address) public requestIdToAddr;

    constructor()
        VRFConsumerBase(
            0x2eD832Ba664535e5886b75D64C46EB9a228C2610, // VRF Coordinator for Avalanche Fuji Testnet
            0x0b9d5D9136855f6FEc3c0993feE6E9CE8a297846 // LINK Token for Avalanche Fuji Testnet
        )
    {
        keyHash = 0x354d2f95da55398f44b7cff77da56283d9c6c829a4bdf1bbcaf2ad6a4d081f61; // keyhash for Avalanche Fuji Testnet
        fee = 0.005 * 10 ** 18; // 0.005 LINK (for Avalanche Fuji Testnet)
    }

    function setDiscoveryService(address _address) external onlyAdmin {
        discoveryService = IDiscoveryService(_address);
    }

    function getRandomNumber()
        external
        onlyWhitelisted
        returns (bytes32 requestId)
    {
        requestId = _getRandomNumber();
        requestIdToAddr[requestId] = msg.sender;

        return requestId;
    }

    // Request randomness
    function _getRandomNumber() internal returns (bytes32 requestId) {
        require(
            LINK.balanceOf(address(this)) >= fee,
            "Not enough LINK - fill contract with faucet"
        );
        return requestRandomness(keyHash, fee);
    }

    // Callback function used by VRF Coordinator
    function fulfillRandomness(
        bytes32 requestId,
        uint256 randomness
    ) internal override {
        randomResults[requestId] = randomness;
        //Sending the random number to the contract that requested it
        IRandomizer(requestIdToAddr[requestId]).setRandomDigit(randomness);
    }
}
