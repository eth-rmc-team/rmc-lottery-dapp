// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './TicketManager.sol'; 

//Contract managing NFTs for deal on Marketplace.sol and mint on RmcNftMinter.sol 

contract Marketplace is TicketManager {

    address payable private owner;
    address public addrContractTicketManager;
    address payable public addrContractLottery;
    
    address public _nftContract;
    address public _nftOwner;
    uint public _nftPrice;
    State public _nftState;

    uint private _feeByTrade;
    
    address payable public seller;
    address public buyer;

    struct nftInfoFromMarketplace {
        address __nftOwner;
        State __nftState;
        uint __nftPrice;
    }

    //Creation of a mapping connecting each tokenId to its nftInfo struct
    mapping(uint => nftInfoFromMarketplace) public idNftToNftInfosFromMarketplace;

    constructor () payable  {

        owner = payable(msg.sender); 

    }

    function setAddrContract(address _addrContractTicketManager, address _addrContractLottery) external onlyOwner {
        addrContractTicketManager = _addrContractTicketManager;
        addrContractLottery = payable(_addrContractLottery);
    }

    //Fonction de mise en place de la vente quand le SC est dans l'état "Created"
    function setSellernbTicketsAndPrice(uint _price, uint _tokenId) external {
        
        (, _nftContract, , , _nftState, ) = super.getNftInfo(_tokenId);
        _nftOwner = msg.sender;

        require(_nftState == State.NoDeal, 'WARNING :: Deal already in progress');
        _nftState = State.Dealing;
        idNftToNftInfosFromMarketplace[_tokenId].__nftState = _nftState;
        require(_nftOwner == super._ownerOf(_nftContract, _tokenId), 'WARNING :: Not owner of this token');
        _nftOwner = address(0);
        idNftToNftInfosFromMarketplace[_tokenId].__nftOwner = _nftOwner;
        require(_price > 0, 'WARNING :: Price zero not accepted');
        idNftToNftInfosFromMarketplace[_tokenId].__nftPrice = _price;

        super.setNftInfoFromMarketplace(_tokenId);
        super._approuve(_nftContract, _tokenId, address(this));
        super._transferFrom(msg.sender, address(this), _nftContract, _tokenId);

        seller = payable(msg.sender);

    }

    function stopDeal(uint _tokenId) external {

        (, _nftContract, , _nftOwner, _nftState, ) = super.getNftInfo(_tokenId);

        require(_nftState == State.Dealing, 'WARNING :: Deal not in progress for this NFT');
        _nftState = State.NoDeal;
        idNftToNftInfosFromMarketplace[_tokenId].__nftState = _nftState;
        require(msg.sender == _nftOwner, 'WARNING :: Not owner of this token');
        _nftOwner = address(0);

        idNftToNftInfosFromMarketplace[_tokenId].__nftPrice = 0;
        super.setNftInfoFromMarketplace(_tokenId);
        super._transferFrom(address(this), _nftOwner, _nftContract, _tokenId);

    }

    function confirmPurchase(uint _tokenId) external payable {
        
        _feeByTrade = super.getFeeByTrade();
        uint _minusFeeByTrade = 100 - _feeByTrade;

        ( , _nftContract, , , _nftState, _nftPrice) = super.getNftInfo(_tokenId);

        require(_nftState == State.Dealing, "WARNING :: Deal not in progress for this NFT");
        _nftState = State.Release;
        idNftToNftInfosFromMarketplace[_tokenId].__nftState = _nftState;
        require(msg.value == _nftPrice, "WARNING :: you don't pay the right price");
        _nftPrice = 0;
        idNftToNftInfosFromMarketplace[_tokenId].__nftPrice = 0;
        require(msg.sender != _nftOwner, "WARNING :: you can't buy your own NFT");
        _nftOwner = msg.sender;
        
        idNftToNftInfosFromMarketplace[_tokenId].__nftOwner = _nftOwner;
        idNftToNftInfosFromMarketplace[_tokenId].__nftState = State.NoDeal;

        super.setNftInfoFromMarketplace(_tokenId);
        super._transferFrom(address(this), msg.sender, _nftContract, _tokenId);

        seller.transfer(_minusFeeByTrade * msg.value / 100);
        addrContractLottery.transfer(_feeByTrade* msg.value / 100);

    }

}