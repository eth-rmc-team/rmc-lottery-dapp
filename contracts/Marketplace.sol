// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './TicketManager.sol'; 

//Contract managing deals between players
contract Marketplace {

    address payable private owner;
    address public addrContractTicketManager;
    address payable public addrContractLottery;

    uint public value;
    uint public nbTicketsToSell;
    
    address payable public seller;
    address public buyer;

    enum State { NoDeal, Dealing, Release }
    State public state;

    mapping (uint => uint) public dealingNftAddrToPrice; 
    mapping (uint => State) public dealingNftToStateOfDeal; 

    constructor () payable  {

        owner = payable(msg.sender); 

    }

    //Custom error functions

    ///La fonction ne peut être appelée en l'état actuel
    error InvalidState();

    ///Seul le propriétaire du contrat peut utiliser cette fonction
    error OnlyOwner();

    ///Seul le buyer peut utiliser cette fonction
    error OnlyBuyer();

    ///Seul le seller peut utiliser cette fonction
    error OnlySeller();

    modifier onlyOwner {
        if(msg.sender != owner){
            revert OnlyOwner();
        }
        _;
    }

    modifier onlyBuyer(){
        if(msg.sender != buyer){
            revert OnlyBuyer();
        }
        _;
    }

    modifier onlySeller(){
        if(msg.sender != seller){
            revert OnlySeller();
        }
        _;
    }

    modifier inState(State state_){
        if(state != state_){
            //Si l'état est différent de celui attendant en argument, on bascule dans la fonction d'érreur précédement écrite
            revert InvalidState();
        }
        _;

    }

    function setAddrContract(address _addrContractTicketManager, address _addrContractLottery) external onlyOwner {
        addrContractTicketManager = _addrContractTicketManager;
        addrContractLottery = payable(_addrContractLottery);
    }

    //Fonction de mise en place de la vente quand le SC est dans l'état "Created"
    function setSellernbTicketsAndPrice(uint _price, uint _tokenId) public {
        address _adrrITM = addrContractTicketManager;
        address contractNft = TicketManager(_adrrITM).getAddrNftContract();
        address nftOwner = TicketManager(_adrrITM).getOwnerOfNft(contractNft, _tokenId);

        require(dealingNftToStateOfDeal[_tokenId] == State.NoDeal, 'WARNING :: Deal already in progress');
        require(msg.sender == nftOwner, 'WARNING :: Not owner of this token');
        require(_price > 0, 'WARNING :: Price zero not accepted');
        

        dealingNftToStateOfDeal[_tokenId] = State.Dealing;
        dealingNftAddrToPrice[_tokenId] = _price;
        
        TicketManager(_adrrITM).setOwnerOfNft(nftOwner, msg.sender);
        TicketManager(_adrrITM)._transferFrom(msg.sender, address(this), _tokenId);

        seller = payable(msg.sender);

    }

    function stopDeal(uint _tokenId) external onlySeller {
        address _adrrITM = addrContractTicketManager;
        address contractNft = TicketManager(_adrrITM).getAddrNftContract();
        address nftOwner = TicketManager(_adrrITM).getOwnerOfNft(contractNft, _tokenId);
        
        require(dealingNftToStateOfDeal[_tokenId] == State.Dealing, 'WARNING :: Deal not in progress for this NFT');
        require(msg.sender == nftOwner, 'WARNING :: Not owner of this token');

        dealingNftToStateOfDeal[_tokenId] = State.NoDeal;
        dealingNftAddrToPrice[_tokenId] = 0;
        
        TicketManager(_adrrITM)._transferFrom(address(this), nftOwner, _tokenId);

    }

    function confirmPurchase(uint _tokenId) external payable {
        address _adrrITM = addrContractTicketManager;
        address contractNft = TicketManager(_adrrITM).getAddrNftContract();

        require(dealingNftToStateOfDeal[_tokenId] == State.Dealing, "WARNING :: Deal not in progress for this NFT");
        require(msg.value == dealingNftAddrToPrice[_tokenId], "WARNING :: you don't pay the right price");
        require(msg.sender != TicketManager(_adrrITM).getOwnerOfNft(contractNft, _tokenId), "WARNING :: you can't buy your own NFT");
        
        dealingNftToStateOfDeal[_tokenId] = State.Release;
        dealingNftAddrToPrice[_tokenId] = 0;

        TicketManager(_adrrITM)._transferFrom(address(this), msg.sender, _tokenId);

        seller.transfer(95 * msg.value / 100);
        addrContractLottery.transfer(5 * msg.value / 100);

        dealingNftToStateOfDeal[_tokenId] = State.NoDeal;

    }

}