// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './TicketManager.sol'; 

//Contract managing NFTs for deal on Marketplace.sol and mint on RmcNftMinter.sol 

contract Marketplace is TicketManager {

    address payable private owner;
    address public addrContractTicketManager;
    address payable public addrContractLottery;
    
    address private contractNft;
    address private nftOwner;
    uint private nftPrice;

    State private nftState;

    uint private _feeByTrade;
    
    address payable public seller;
    address public buyer;

    constructor () payable  {

        owner = payable(msg.sender); 

    }

    function setAddrContract(address _addrContractTicketManager, address _addrContractLottery) external onlyOwner {
        addrContractTicketManager = _addrContractTicketManager;
        addrContractLottery = payable(_addrContractLottery);
    }

    function getNftInfo(uint _tokenId) external returns (address, address, uint, State) {
        contractNft = super.getAddrNftContract();
        nftOwner = super._ownerOf(contractNft, _tokenId);
        nftPrice = super.getDealPrice(_tokenId);
        nftState = super.getDealState(_tokenId);
        return (contractNft, nftOwner, nftPrice, nftState);
    }

    //Fonction de mise en place de la vente quand le SC est dans l'état "Created"
    function setSellernbTicketsAndPrice(uint _price, uint _tokenId) external {
        
        (, nftOwner, nftPrice, nftState) = this.getNftInfo(_tokenId);

        require(nftState == State.NoDeal, 'WARNING :: Deal already in progress');
        super.setDealState(_tokenId, State.Dealing);
        require(msg.sender == nftOwner, 'WARNING :: Not owner of this token');
        require(_price > 0, 'WARNING :: Price zero not accepted');
        
        nftPrice = _price;
        super.setDealPrice(_tokenId, nftPrice);
        
        super.setOwnerOfNft(nftOwner, msg.sender);
        super._transferFrom(msg.sender, address(this), _tokenId);

        seller = payable(msg.sender);

    }

    function stopDeal(uint _tokenId) external {
        (, nftOwner,, nftState) = this.getNftInfo(_tokenId);
        
        require(nftState == State.Dealing, 'WARNING :: Deal not in progress for this NFT');
        require(msg.sender == nftOwner, 'WARNING :: Not owner of this token');

        super.setDealState(_tokenId, State.NoDeal);
        super.setDealPrice(_tokenId, 0);
        
        super._transferFrom(address(this), nftOwner, _tokenId);

    }

    function confirmPurchase(uint _tokenId) external payable {
        
        _feeByTrade = super.getFeeByTrade();
        uint _minusFeeByTrade = 100 - _feeByTrade;

        (contractNft,, nftPrice, nftState) = this.getNftInfo(_tokenId);

        require(nftState == State.Dealing, "WARNING :: Deal not in progress for this NFT");
        super.setDealState(_tokenId, State.Release);
        require(msg.value == nftPrice, "WARNING :: you don't pay the right price");
        super.setDealPrice(_tokenId, 0);
        require(msg.sender != super._ownerOf(contractNft, _tokenId), "WARNING :: you can't buy your own NFT");
        
        super._transferFrom(address(this), msg.sender, _tokenId);

        seller.transfer(_minusFeeByTrade * msg.value / 100);
        addrContractLottery.transfer(_feeByTrade* msg.value / 100);

        super.setDealState(_tokenId, State.NoDeal);

    }

}