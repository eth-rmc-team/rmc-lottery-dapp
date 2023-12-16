// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "hardhat/console.sol";

import "@openzeppelin/contracts/utils/math/SafeMath.sol";

library Calculate {
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
}
