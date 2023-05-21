// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

interface IRMCFeeInfo {

    //Function from FeeManager.sol
    //gain_PP = gain for price pool; gain_D = gain for deal fees
    function computeGainForAdvantages(address _addrClaimer) external returns (uint _totalGain);
    function computeGainForWinner(uint _idWinner, 
                                  address _claimer) external returns(uint _gain);


    //Function getter returning the share of price pool for every part of the game
    function getShareOfPricePoolFor() external view returns(uint _shareProt, 
                                                            uint _shareWinner, 
                                                            uint shareSGG, 
                                                            uint _shareMyth, 
                                                            uint _sharePlat);

    //Function from Marketplace.sol
    function claimFees () external;

    function resetClaimStatus() external;
}