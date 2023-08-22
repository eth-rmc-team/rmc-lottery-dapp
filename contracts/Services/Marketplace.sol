// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

import "./Interfaces/ITicketRegistry.sol";
import "./Interfaces/IDiscoveryService.sol";
import "./TicketRegistry.sol";
import "./Whitelisted.sol";

//Contract managing deals between players

//TODO: faire hériter TicketInformationController au lieu de l'interface ?
contract Marketplace is Whitelisted
{
    IDiscoveryService discoveryService;

    uint public feeByTrade;
    
    constructor() payable  
    {
    }

    function setDiscoveryService(address _address) external onlyAdmin 
    {
        discoveryService = IDiscoveryService(_address);
    }
    
    function setFeeByTrade(uint _feeByTrade) external onlyAdmin 
    {
        feeByTrade = _feeByTrade;
    }

    function getFeeByTrade() public view returns(uint)
    {
        return feeByTrade;
    }

    //Function used to put in sale a NFT for a desired price
    //The NFT is transfered to the Marketplace contract
    function putNftOnSale(
        uint256 _price, 
        uint256 _tokenId
    ) external 
    {
        LotteryDef.TicketInfo memory ticketInfo = ITicketRegistry(discoveryService.getTicketRegistryAddr())
        .getTicketState(_tokenId);
        
        //Check if the NFT is not already in sale, if the msg.sender is the owner of the NFT and if the price is not zero
        require(
            ticketInfo.dealState == LotteryDef.TicketState.NODEAL, 
            'WARNING :: Deal already in progress'
        );
        require(
            payable(msg.sender) == IERC721(ticketInfo.contractAddress).ownerOf(_tokenId), 
            'WARNING :: Not owner of this token'
        );
        require(
            _price > 0, 
            'WARNING :: Price zero not accepted'
        );

        //Change the state of the NFT to "Dealing", set the price and the owner of the NFT 
        ITicketRegistry(discoveryService.getTicketRegistryAddr())
        .putTicketOnSale(_tokenId, _price);

        //and transfer the NFT to the Marketplace contract
        IERC721(ticketInfo.contractAddress).approve(address(this), _tokenId);
        //IERC721(ticketInfo.contractAddress).safeTransferFrom(msg.sender, address(this), _tokenId);
    }
    
    //Function used to send out a NFT previously in sale
    //The NFT is transfered back to the owner
    function removeSalesNft(uint _tokenId) external 
    {
        //Get the owner and state of the selected NFT
        LotteryDef.TicketInfo memory ticketInfo = ITicketRegistry(discoveryService.getTicketRegistryAddr())
        .getTicketState(_tokenId);

        //Check if the NFT is in sale and if the msg.sender is the owner of the NFT
        require(
            ticketInfo.dealState == LotteryDef.TicketState.DEALING, 
            'WARNING :: Deal not in progress for this NFT'
        );
        require(
            payable(msg.sender) == ticketInfo.ticketOwner, 
            'WARNING :: Not owner of this token'
        );
        
        //Change the state of the NFT to "NoDeal", reset to price
        ITicketRegistry(discoveryService.getTicketRegistryAddr())
        .removeSalesTicket( _tokenId);

        //and transfer the NFT to the owner
        IERC721(ticketInfo.contractAddress).safeTransferFrom(address(this), ticketInfo.ticketOwner, _tokenId);
    }

    //Function used to purchase a NFT in sale
    //Funds are transfered to the seller (minus fees) and the NFT is transfered to the buyer
    function purchaseNft(uint _tokenId) external payable 
    {
        //Calculate the fees
        uint256 _minusFeeByTrade = 100 - feeByTrade;

        //Get the owner, state and price of the selected NFT
        LotteryDef.TicketInfo memory ticketInfo = ITicketRegistry(discoveryService.getTicketRegistryAddr())
        .getTicketState(_tokenId);

        address payable seller = ticketInfo.ticketOwner;

        //Check that the NFT is in sale, that the buyer pays the right price and that the buyer is not the owner of the NFT
        require(
            ticketInfo.dealState == LotteryDef.TicketState.DEALING,
            "WARNING :: Deal not in progress for this NFT"
        );
        require(
            msg.value == ticketInfo.dealPrice, 
            "WARNING :: you don't pay the right price"
        );
        require(
            msg.sender != ticketInfo.ticketOwner, 
            "WARNING :: you can't buy your own NFT"
        );

        //Buyer pay the marketplace
        (bool sent,) = payable(address(this)).call{value: msg.value}("");
        require(sent, "Failed to transfer funds to the contract");

        //Change the state of the NFT to "NoDeal", reset the price and transfer ownership
        ITicketRegistry(discoveryService.getTicketRegistryAddr())
        .transferTicketOwnership( _tokenId, payable(msg.sender));

        //Transfer the NFT to the buyer
        IERC721(ticketInfo.contractAddress).safeTransferFrom(address(this), msg.sender, _tokenId);

        //and the funds to the seller (minus fees)
        seller.transfer(_minusFeeByTrade * msg.value / 100);
    }

    // //Function used by owner to approve FeeManger contract
    // function approveFeeManager(address _addrFeeManager) public onlyOwner 
    // {
    //     addrContractFeeManager = _addrFeeManager;
        
    //     //To avoid a mix with old and new approved amount, we set the allowance to 0 before setting the new allowance
    //     IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).approve(_addrFeeManager, 0);
    //     IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).approve(_addrFeeManager, 1000);

    // }

    // // //Function returning the allowance of the Marketplace contract for the FeeManager contract
    // function getAllowance() public onlyOwner view returns(uint)  {
    //     return IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).allowance(
    //         address(this), 
    //         addrContractFeeManager
    //     );
    // }
}