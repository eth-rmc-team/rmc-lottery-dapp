// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "../Services/Interfaces/IDiscoveryService.sol";
import "./Interfaces/ILotteryGame.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "../Services/Whitelisted.sol";

abstract contract ASideLotteryGame is
    Whitelisted,
    IERC721Receiver,
    ReentrancyGuard
{
    struct SideLotteryGame {
        address[] users;
        address[] winners;
        uint32 totalTicketsBurnt;
        bool isSideLotteryRunning;
        bool isWinnersDrawn;
    }
    struct SideLotteryParameters {
        LotteryDef.TicketType ticketType;
        uint256 prefix;
        uint32 nbTicketBurnable;
        uint32 denominator;
        uint8 lotteryId;
        uint8 nbDraw;
        bool isLotteryDependant;
        bool isPrefixDependant;
    }

    mapping(uint256 => SideLotteryGame) sideLotteries;
    mapping(uint256 => SideLotteryParameters) sideLotteriesParameters;

    IDiscoveryService discoveryService;

    event Received(address, uint);
    event winnersDrawn(address[] winners);
    event ClaimedPrizePool(address winner, uint256 prize);
    event claimedShareForSuperGold(address winner, uint256 prize);

    modifier onlyWhenLotteryRunning(uint256 _sideLotteryId) {
        require(
            sideLotteries[_sideLotteryId].isSideLotteryRunning = true,
            "Previous lottery is finished, please wait for the next one"
        );
        _;
    }

    modifier isWinnersBeenDrawn(uint256 _sideLotteryId) {
        require(
            sideLotteries[_sideLotteryId].isWinnersDrawn = true,
            "Winners are not drawn yet, please wait for the next one"
        );
        _;
    }

    //Function to allow this contract to reveive value from other contracts
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    // Fucntion from IERC721Receiver interface to allow this contract to receive NFTs
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function setDiscoveryService(address _address) external onlyAdmin {
        discoveryService = IDiscoveryService(_address);
    }

    function getLotteryId() internal view returns (uint8) {
        return
            ILotteryGame(discoveryService.getLotteryGameAddr()).getLotteryId();
    }

    function getRandomIndex(
        uint256 _sideLotteryId
    ) internal view returns (uint16) {
        bytes32 hash = keccak256(abi.encodePacked(block.timestamp, msg.sender));
        uint16 randomNumber = (uint16(bytes2(hash[0])) %
            uint16(sideLotteries[_sideLotteryId].users.length));
        return randomNumber;
    }

    function getWinnersAddr(
        uint8 nbDraws,
        uint256 _sideLotteryId
    ) internal returns (address[] memory) {
        uint16 index;
        for (uint i = 0; i < nbDraws; i++) {
            index = getRandomIndex(_sideLotteryId);
            sideLotteries[_sideLotteryId].winners.push(
                sideLotteries[_sideLotteryId].users[index]
            );
            sideLotteries[_sideLotteryId].users[index] = sideLotteries[
                _sideLotteryId
            ].users[sideLotteries[_sideLotteryId].users.length - 1];
            sideLotteries[_sideLotteryId].users.pop();
        }

        emit winnersDrawn(sideLotteries[_sideLotteryId].winners);

        return sideLotteries[_sideLotteryId].winners;
    }
}
