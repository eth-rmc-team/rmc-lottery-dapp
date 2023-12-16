// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library Calculation {
    using SafeMath for *;

    function extractLotteryId(uint256 input) public pure returns (uint8) {
        uint8 _lotteryIdForGold;
        _lotteryIdForGold = uint8(input % 100);
        return _lotteryIdForGold;
    }

    function extractFeatures(
        uint256 input,
        uint16 mask
    ) public pure returns (uint16) {
        uint16 _featuresForGold;
        _featuresForGold = uint16(input.div(mask));
        return _featuresForGold;
    }

    function calculateRatio(
        uint256 a,
        uint256 b
    ) external pure returns (uint ratioPG) {
        uint24 multiplicateur = 1000000;
        ratioPG = a.mul(multiplicateur).div(b);
        return (ratioPG);
    }

    function calculateSum4uint(
        uint[4] memory input
    ) public pure returns (uint) {
        uint256 sumCoef = 0;
        sumCoef = input[0].add(input[1]).add(input[2]).add(input[3]);
        return (sumCoef);
    }

    //Function calculating the share of the price pool for each NFT type owned by the user
    function calculateShare(
        uint256 _pricepool,
        uint _totalSupply,
        uint256 _balanceOfNft,
        uint256 _coef,
        uint256 _sumCoef
    ) public pure returns (uint256) {
        uint256 _share;
        //note: we don't need to divide by 1000000 as sumCoef is already multiplied by 1000000
        _share = _pricepool.mul(_balanceOfNft).div(_totalSupply).mul(_coef).div(
                _sumCoef
            );

        return (_share);
    }
}
