// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IPrizepoolDispatcher
{

    //Function from FeeManager.sol
    //gain_PP = gain for price pool; gain_D = gain for deal fees
    function computeGainForAdvantages(
        address _addrClaimer,
        uint256 _prizepool
    ) external returns (uint _totalGain);

    function computeGainForWinner(
        uint _idWinner, 
        address _claimer,
        uint256 _prizepool
    ) external view returns(uint);


    //Function getter returning the share of price pool for every part of the game
    function getShareOfPricePoolFor() 
    external view returns(
        uint8 _shareProt, 
        uint8 _shareWinner, 
        uint8 _shareAdvantages
    );

    //Function from Marketplace.sol
    function transferFeesToLottery() external;

    function resetClaimStatus() external;
}