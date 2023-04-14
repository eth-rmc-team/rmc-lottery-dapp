// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './TicketManager.sol'; 

//Contract managing deals between players

contract Marketplace is TicketManager {

    address payable private owner;
    address public addrContractTicketManager;
    address payable public addrContractLottery;
    
    address public nftContract;
    address payable public nftOwner;
    uint public nftPrice;
    State public nftState;

    uint public feeByTrade;
    
    address payable public seller;
    address public buyer;

    TicketManager tick;

    constructor () payable  {

        owner = payable(msg.sender); 

    }

    function setAddrContract(address _addrContractTicketManager, address _addrContractLottery) external onlyOwner {
        addrContractTicketManager = _addrContractTicketManager;
        addrContractLottery = payable(_addrContractLottery);
        tick = TicketManager(addrContractTicketManager);
    }
    
    //Function setting fee by trade
    function setFeeByTrade(uint _feeByTrade) external onlyOwner {
        feeByTrade = _feeByTrade;
    }

    function _setNftInfoFromMarketPlace(uint _tokenId, address payable _nftOwner, State _nftState, uint _nftPrice) private {
        tick.setNftInfoFromMarketplace(_tokenId, _nftOwner, _nftState, _nftPrice);
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
        
        (, nftContract, , , nftState, ) = super.getNftInfo(_tokenId);
        nftOwner = payable(msg.sender);
        nftPrice = _price;

        require(nftState == State.NoDeal, 'WARNING :: Deal already in progress');
        require(nftOwner == super._ownerOf(nftContract, _tokenId), 'WARNING :: Not owner of this token');
        require(nftPrice > 0, 'WARNING :: Price zero not accepted');
        
        nftState = State.Dealing;
        _setNftInfoFromMarketPlace(_tokenId, nftOwner, nftState, nftPrice);
       
        nftOwner = payable(address(this));       
        nftPrice = 0;

        super._approuve(nftContract, _tokenId, address(this));
        super._transferFrom(msg.sender, address(this), nftContract, _tokenId);

    }

    function stopDeal(uint _tokenId) external {

        (, nftContract, , nftOwner, nftState, ) = super.getNftInfo(_tokenId);

        require(nftState == State.Dealing, 'WARNING :: Deal not in progress for this NFT');
        require(msg.sender == nftOwner, 'WARNING :: Not owner of this token');
        
        nftState = State.NoDeal;
        nftPrice = 0;
        _setNftInfoFromMarketPlace(_tokenId, nftOwner, nftState, nftPrice);
        nftOwner = payable(address(this));

        super._transferFrom(address(this), nftOwner, nftContract, _tokenId);

    }

    function confirmPurchase(uint _tokenId) external payable {
        
        uint _minusFeeByTrade = 100 - feeByTrade;

        ( , nftContract, , , nftState, nftPrice) = super.getNftInfo(_tokenId);

        require(nftState == State.Dealing, "WARNING :: Deal not in progress for this NFT");
        nftState = State.NoDeal;
        require(msg.value == nftPrice, "WARNING :: you don't pay the right price");
        require(msg.sender != nftOwner, "WARNING :: you can't buy your own NFT");
        nftOwner = payable(msg.sender);

        _setNftInfoFromMarketPlace(_tokenId, nftOwner, nftState, nftPrice);

        super._transferFrom(address(this), msg.sender, nftContract, _tokenId);

        seller.transfer(_minusFeeByTrade * msg.value / 100);
        addrContractLottery.transfer(feeByTrade* msg.value / 100);

    }

}