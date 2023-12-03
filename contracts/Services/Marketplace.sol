// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";

import "./Interfaces/ITicketRegistry.sol";
import "./Interfaces/IDiscoveryService.sol";
import "./TicketRegistry.sol";
import "../Librairies/LotteryDef.sol";
import "./Whitelisted.sol";

import "hardhat/console.sol";

//Contract managing deals between players

//TODO: faire hériter TicketInformationController au lieu de l'interface ?
contract Marketplace is Whitelisted, IERC721Receiver {
    IDiscoveryService discoveryService;

    uint256 public totalFees;
    uint8 public feeByTrade;

    mapping(address => uint256) public feesByAddress;

    using SafeMath for uint256;
    using SafeMath for uint8;

    using LotteryDef for LotteryDef.TicketType;

    event Received(address, uint);
    event putOnSale(address, uint256, uint256, address);
    event removeOnSale(address, uint256, address);
    event purchase(address, uint256, uint256, address);

    constructor() payable {
        feeByTrade = 30;
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

    //Function to allow this contract to reveive value from other addresses
    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    function setDiscoveryService(address _address) external onlyAdmin {
        discoveryService = IDiscoveryService(_address);
    }

    function setFeeByTrade(uint8 _feeByTrade) external onlyAdmin {
        feeByTrade = _feeByTrade;
    }

    function getFeeByTrade() public view returns (uint) {
        return feeByTrade;
    }

    //Function used to put in sale a NFT for a desired price
    //The NFT is transfered to the Marketplace contract
    function putNftOnSale(
        address ticketAddress,
        uint256 tokenId,
        uint256 price
    ) external payable {
        price = price.mul(10 ** 18);
        LotteryDef.TicketInfo memory ticketInfo = ITicketRegistry(
            discoveryService.getTicketRegistryAddr()
        ).getTicketState(ticketAddress, tokenId);

        //Check if the NFT is not already in sale, if the msg.sender is the owner of the NFT and if the price is not zero
        require(
            ticketInfo.dealState == LotteryDef.TicketState.NODEAL,
            "WARNING :: Deal already in progress"
        );
        require(
            msg.sender == IERC721(ticketAddress).ownerOf(tokenId),
            "WARNING :: Not owner of this token"
        );
        require(price > 0, "WARNING :: Price zero not accepted");

        //Adding fees on the price
        price = price.mul(feeByTrade.add(100)).div(100);

        //Change the state of the NFT to "Dealing", set the price and the owner of the NFT
        ITicketRegistry(discoveryService.getTicketRegistryAddr())
            .putTicketOnSale(ticketAddress, tokenId, price);

        //Transfer the NFT to the Marketplace contract
        IERC721(ticketAddress).safeTransferFrom(
            msg.sender,
            address(this),
            tokenId
        );

        emit putOnSale(ticketAddress, tokenId, price, msg.sender);
    }

    //Function used to send out a NFT previously in sale
    //The NFT is transfered back to the owner
    function removeSalesNft(address _ticketAddress, uint _tokenId) external {
        //Get the owner and state of the selected NFT
        LotteryDef.TicketInfo memory ticketInfo = ITicketRegistry(
            discoveryService.getTicketRegistryAddr()
        ).getTicketState(_ticketAddress, _tokenId);
        //Check if the NFT is in sale and if the msg.sender is the owner of the NFT
        require(
            ticketInfo.dealState == LotteryDef.TicketState.DEALING,
            "ERROR :: Deal not in progress for this NFT"
        );
        require(
            payable(msg.sender) == ticketInfo.ticketOwner,
            "ERROR :: Not owner of this token"
        );

        //Change the state of the NFT to "NoDeal", reset to price
        ITicketRegistry(discoveryService.getTicketRegistryAddr())
            .removeSalesTicket(_ticketAddress, _tokenId);

        //and transfer the NFT to the owner
        IERC721(_ticketAddress).safeTransferFrom(
            address(this),
            ticketInfo.ticketOwner,
            _tokenId
        );

        emit removeOnSale(_ticketAddress, _tokenId, msg.sender);
    }

    //Function used to purchase a NFT in sale
    //Funds are transfered to the seller (minus fees) and the NFT is transfered to the buyer
    function purchaseNft(
        address _ticketAddress,
        uint _tokenId
    ) external payable {
        //Calculate the fees
        //Get the owner, state and price of the selected NFT
        LotteryDef.TicketInfo memory ticketInfo = ITicketRegistry(
            discoveryService.getTicketRegistryAddr()
        ).getTicketState(_ticketAddress, _tokenId);

        address payable seller = ticketInfo.ticketOwner;
        //Check that the NFT is in sale, that the buyer pays the right price and that the buyer is not the owner of the NFT
        require(
            ticketInfo.dealState == LotteryDef.TicketState.DEALING,
            "WARNING :: Deal not in progress for this NFT"
        );
        require(
            msg.value >= ticketInfo.dealPrice,
            "WARNING :: you don't pay the right price"
        );
        require(
            msg.sender != ticketInfo.ticketOwner,
            "WARNING :: you can't buy your own NFT"
        );

        uint256 priceToSeller = ticketInfo.dealPrice.mul(100).div(
            feeByTrade.add(100)
        );

        //Buyer pay the marketplace
        (bool sentToMarketplace, ) = payable(address(this)).call{
            value: msg.value
        }("");
        require(
            sentToMarketplace,
            "Failed to transfer funds to the Marketplace"
        );

        //Change the state of the NFT to "NoDeal", reset the price and transfer ownership
        ITicketRegistry(discoveryService.getTicketRegistryAddr())
            .transferTicketOwnership(_ticketAddress, _tokenId, msg.sender);

        //Transfer the NFT to the buyer
        IERC721(_ticketAddress).safeTransferFrom(
            address(this),
            msg.sender,
            _tokenId
        );

        //and the funds to the seller (minus fees)
        feesByAddress[seller] = feesByAddress[seller].add(priceToSeller);
        totalFees = totalFees.add(ticketInfo.dealPrice.sub(priceToSeller));

        emit purchase(
            _ticketAddress,
            _tokenId,
            ticketInfo.dealPrice,
            msg.sender
        );
    }

    function transferFeesToLottery() external onlyWhitelisted {
        if (totalFees > 1) {
            (bool sent, ) = payable(msg.sender).call{value: totalFees}("");
            require(
                sent,
                "Failed to transfer fees from Marketplace to the Lottery Prizepool"
            );
            totalFees = 0;
        }
    }

    function claimsFeesForSeller() external {
        require(
            feesByAddress[msg.sender] > 0,
            "WARNING :: You don't have any fees to claim"
        );

        (bool sent, ) = payable(msg.sender).call{
            value: feesByAddress[msg.sender]
        }("");
        require(sent, "Failed to transfer fees from Marketplace to the user");
        feesByAddress[msg.sender] = 0;
    }

    function getTotalFees() public view returns (uint) {
        return totalFees;
    }
}
