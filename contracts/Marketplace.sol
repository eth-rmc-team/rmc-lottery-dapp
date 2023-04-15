// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import './IRMC.sol';

//Contract managing deals between players

contract Marketplace {

    address payable private owner;
    address public addrContractTicketManager;
    address payable public addrContractLottery;
    
    address public nftContract;
    address payable public nftOwner;
    uint public nftPrice;
    IRMC.State public nftState;

    uint public feeByTrade;
    
    address payable public seller;
    address public buyer;

    IRMC irmc;

    constructor () payable  {

        owner = payable(msg.sender); 

    }

    modifier onlyOwner{
        require(msg.sender == owner, 'WARNING :: Only owner can call this function');
        _;
    }

    function setAddrContract(address _addrContractTicketManager, address _addrContractLottery) external onlyOwner {
        addrContractTicketManager = _addrContractTicketManager;
        addrContractLottery = payable(_addrContractLottery);

        irmc = IRMC(addrContractTicketManager);

    }
    
    //Function setting fee by trade
    function setFeeByTrade(uint _feeByTrade) external onlyOwner {
        feeByTrade = _feeByTrade;
    }

    //Function getter returning the address of the MarketPlace contract
    function getAddrMarketplaceContract() public view returns(address) {
        return address(this);
    }

    //Function getter returning the fee by trade
    function getFeeByTrade() public view returns(uint){
        return feeByTrade;
    }

    //Fonction de mise en place de la vente quand le SC est dans l'état "Created"
    function setSellernbTicketsAndPrice(uint _price, uint _tokenId) external {

        (, nftContract, , , nftState, ) = irmc.getNftInfo(_tokenId);
        nftOwner = payable(msg.sender);

        nftPrice = _price;

        require(nftState == IRMC.State.NoDeal, 'WARNING :: Deal already in progress');
        require(nftOwner == IERC721(nftContract).ownerOf(_tokenId), 'WARNING :: Not owner of this token');
        require(nftPrice > 0, 'WARNING :: Price zero not accepted');

        nftState = IRMC.State.Dealing;
        irmc.setNftInfo(_tokenId, nftOwner, nftState, nftPrice);
        nftOwner = payable(address(this));       
        nftPrice = 0;

        IERC721(nftContract).approve(address(this), _tokenId);
        IERC721(nftContract).safeTransferFrom(msg.sender, address(this), _tokenId);

    }

    function stopDeal(uint _tokenId) external {

        (, nftContract, , nftOwner, nftState, ) = irmc.getNftInfo(_tokenId);

        require(nftState == IRMC.State.Dealing, 'WARNING :: Deal not in progress for this NFT');
        require(msg.sender == nftOwner, 'WARNING :: Not owner of this token');
        
        nftState = IRMC.State.NoDeal;
        nftPrice = 0;
        irmc.setNftInfo(_tokenId, nftOwner, nftState, nftPrice);
        nftOwner = payable(address(this));

        IERC721(nftContract).safeTransferFrom(address(this), nftOwner, _tokenId);

    }

    function confirmPurchase(uint _tokenId) external payable {
        
        uint _minusFeeByTrade = 100 - feeByTrade;

        ( , nftContract, , , nftState, nftPrice) = irmc.getNftInfo(_tokenId);

        require(nftState == IRMC.State.Dealing, "WARNING :: Deal not in progress for this NFT");
        nftState = IRMC.State.NoDeal;
        require(msg.value == nftPrice, "WARNING :: you don't pay the right price");
        require(msg.sender != nftOwner, "WARNING :: you can't buy your own NFT");
        nftOwner = payable(msg.sender);

        irmc.setNftInfo(_tokenId, nftOwner, nftState, nftPrice);

        payable(address(this)).transfer(msg.value);
        IERC721(nftContract).safeTransferFrom(address(this), msg.sender, _tokenId);

        seller.transfer(_minusFeeByTrade * msg.value / 100);
        addrContractLottery.transfer(feeByTrade* msg.value / 100);

    }

}