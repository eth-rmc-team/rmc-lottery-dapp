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
    
    // address private nftContract;
    // address payable private nftOwner;
    // uint private nftPrice;
    // TicketRegistry.State private nftState;

    // uint public feeByTrade;
    
    // address payable public seller;

    constructor() payable  
    {
    }

    function setDiscoveryService(address _address) external onlyAdmin 
    {
        discoveryService = IDiscoveryService(_address);
    }
    
    // //Function setting fee by trade
    // function setFeeByTrade(uint _feeByTrade) external onlyOwner 
    // {
    //     feeByTrade = _feeByTrade;
    // }

    // //Function getter returning the address of the MarketPlace contract
    // function getAddrMarketplaceContract() public view returns(address) 
    // {
    //     return address(this);
    // }

    // //Function getter returning the fee by trade
    // function getFeeByTrade() public view returns(uint)
    // {
    //     return feeByTrade;
    // }

    // //Function used to put in sale a NFT for a desired price
    // //The NFT is transfered to the Marketplace contract
    // function setSellernbTicketsAndPrice(
    //     uint _price, 
    //     uint _tokenId, 
    //     address _addrNftContract
    // ) external 
    // {
    //     //get the actual state of the selected NFT
    //     ( , , , nftState, ) = IRMCTicketInfo(_addrNftContract).getNftInfo(_tokenId);
        
    //     nftOwner = payable(msg.sender);
    //     nftPrice = _price;
    //     nftContract = _addrNftContract;

    //     //Check if the NFT is not already in sale, if the msg.sender is the owner of the NFT and if the price is not zero
    //     require(
    //         nftState == IRMCTicketInfo.State.NODEAL, 
    //         'WARNING :: Deal already in progress'
    //     );
    //     require(
    //         nftOwner == IERC721(nftContract).ownerOf(_tokenId), 
    //         'WARNING :: Not owner of this token'
    //     );
    //     require(
    //         nftPrice > 0, 
    //         'WARNING :: Price zero not accepted'
    //     );

    //     //CHange the state of the NFT to "Dealing", set the price and the owner of the NFT and transfer the NFT to the Marketplace contract
    //     nftState = IRMCTicketInfo.State.DEALING;
    //     IRMCTicketInfo(_addrNftContract).setNftInfo(_tokenId, nftOwner, nftState, nftPrice);
    //     nftOwner = payable(address(this));       
    //     nftPrice = 0;

    //     IERC721(nftContract).approve(address(this), _tokenId);
    //     IERC721(nftContract).safeTransferFrom(msg.sender, address(this), _tokenId);
    // }

    // //Function used to send out a NFT previously in sale
    // //The NFT is transfered back to the owner
    // function stopDeal(uint _tokenId, address _addrNftContract) external 
    // {
    //     //Get the owner and state of the selected NFT
    //     ( , , nftOwner, nftState, ) = IRMCTicketInfo(_addrNftContract).getNftInfo(_tokenId);
    //     nftContract = _addrNftContract;

    //     //Check if the NFT is in sale and if the msg.sender is the owner of the NFT
    //     require(
    //         nftState == IRMCTicketInfo.State.DEALING, 
    //         'WARNING :: Deal not in progress for this NFT'
    //     );
    //     require(
    //         payable(msg.sender) == nftOwner, 
    //         'WARNING :: Not owner of this token'
    //     );
        
    //     //Change the state of the NFT to "NoDeal", reset to price and transfer the NFT to the owner
    //     nftState = IRMCTicketInfo.State.NODEAL;
    //     nftPrice = 0;
    //     IRMCTicketInfo(_addrNftContract).setNftInfo(_tokenId, nftOwner, nftState, nftPrice);
    //     nftOwner = payable(address(this));

    //     IERC721(nftContract).safeTransferFrom(address(this), nftOwner, _tokenId);
    // }

    // //Function used to buy a NFT in sale
    // //Funds are transfered to the seller (minus fees) and the NFT is transfered to the buyer
    // function confirmPurchase(uint _tokenId, address _addrNftContract) external payable 
    // {
        
    //     //Calculate the fees
    //     uint _minusFeeByTrade = 100 - feeByTrade;
    //     address payable newOwner = payable(msg.sender);

    //     //Get the owner, state and price of the selected NFT
    //     (, , nftOwner, nftState, nftPrice) = IRMCTicketInfo(_addrNftContract).getNftInfo(_tokenId);
    //     seller = nftOwner;
    //     nftContract = _addrNftContract;

    //     //Check that the NFT is in sale, that the buyer pays the right price and that the buyer is not the owner of the NFT
    //     require(
    //         nftState == IRMCTicketInfo.State.DEALING, 
    //         "WARNING :: Deal not in progress for this NFT"
    //     );
    //     nftState = IRMCTicketInfo.State.NODEAL;
    //     require(
    //         msg.value == nftPrice, 
    //         "WARNING :: you don't pay the right price"
    //     );
    //     require(
    //         msg.sender != nftOwner, 
    //         "WARNING :: you can't buy your own NFT"
    //     );

    //     //Change the state of the NFT to "NoDeal" and reset the price
    //     IRMCTicketInfo(_addrNftContract).setNftInfo(_tokenId, newOwner, nftState, nftPrice);

    //     //Transfer the NFT to the buyer and the funds to the seller (minus fees)
    //     payable(address(this)).transfer(msg.value);
    //     IERC721(nftContract).safeTransferFrom(address(this), msg.sender, _tokenId);

    //     seller.transfer(_minusFeeByTrade * msg.value / 100);
    // }

    //Function used by owner to approve FeeManger contract
    // function approveFeeManager(address _addrFeeManager) public onlyOwner 
    // {
    //     addrContractFeeManager = _addrFeeManager;
        
    //     //To avoid a mix with old and new approved amount, we set the allowance to 0 before setting the new allowance
    //     IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).approve(_addrFeeManager, 0);
    //     IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).approve(_addrFeeManager, 1000);

    // }

    // //Function returning the allowance of the Marketplace contract for the FeeManager contract
    // function getAllowance() public onlyOwner view returns(uint)  {
    //     return IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).allowance(
    //         address(this), 
    //         addrContractFeeManager
    //     );
    // }
}