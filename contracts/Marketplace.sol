// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './Interfaces/IRMCTicketInfo.sol';
import '@openzeppelin/contracts/token/ERC20/IERC20.sol';

//Contract managing deals between players

//TODO: faire hériter TicketInformationController au lieu de l'interface ?
contract Marketplace {

    address payable private owner;
    address public addrContractTicketInformationController;
    address payable public addrContractLotteryGame;
    address public addrContractFeeManager;

    address private addrN;
    address private addrG;
    address private addrSG;
    address private addrM;
    address private addrP;

    address private nftContract;
    address payable private nftOwner;
    uint private nftPrice;
    IRMCTicketInfo.State private nftState;

    uint public feeByTrade;
    
    address payable public seller;
    address public buyer;

    IRMCTicketInfo irmcTI;

    constructor () payable  {

        owner = payable(msg.sender); 

    }

    modifier onlyOwner{
        require(msg.sender == owner, 'WARNING :: Only owner can call this function');
        _;
    }

    function setAddrContract(address _addrN,
                             address _addrG, 
                             address _addrSG, 
                             address _addrM, 
                             address _addrP, 
                             address _addrContractLotteryGame) external onlyOwner {
        addrN = _addrN;
        addrG = _addrG;
        addrSG = _addrSG;
        addrM = _addrM;
        addrP = _addrP;

        addrContractLotteryGame = payable(_addrContractLotteryGame);

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
    function setSellernbTicketsAndPrice(uint _price, uint _tokenId, address _addrNftContract) external {

        ( , , , nftState, ) = IRMCTicketInfo(_addrNftContract).getNftInfo(_tokenId);
        
        nftOwner = payable(msg.sender);
        nftPrice = _price;
        nftContract = _addrNftContract;

        require(nftState == IRMCTicketInfo.State.NoDeal, 'WARNING :: Deal already in progress');
        require(nftOwner == IERC721(nftContract).ownerOf(_tokenId), 'WARNING :: Not owner of this token');
        require(nftPrice > 0, 'WARNING :: Price zero not accepted');

        nftState = IRMCTicketInfo.State.Dealing;
        IRMCTicketInfo(_addrNftContract).setNftInfo(_tokenId, nftOwner, nftState, nftPrice);
        nftOwner = payable(address(this));       
        nftPrice = 0;

        IERC721(nftContract).approve(address(this), _tokenId);
        IERC721(nftContract).safeTransferFrom(msg.sender, address(this), _tokenId);

    }

    function stopDeal(uint _tokenId, address _addrNftContract) external {

        ( , , nftOwner, nftState, ) = IRMCTicketInfo(_addrNftContract).getNftInfo(_tokenId);
        nftContract = _addrNftContract;

        require(nftState == IRMCTicketInfo.State.Dealing, 'WARNING :: Deal not in progress for this NFT');
        require(payable(msg.sender) == nftOwner, 'WARNING :: Not owner of this token');
        
        nftState = IRMCTicketInfo.State.NoDeal;
        nftPrice = 0;
        IRMCTicketInfo(_addrNftContract).setNftInfo(_tokenId, nftOwner, nftState, nftPrice);
        nftOwner = payable(address(this));

        IERC721(nftContract).safeTransferFrom(address(this), nftOwner, _tokenId);

    }

    function confirmPurchase(uint _tokenId, address _addrNftContract) external payable {
        
        uint _minusFeeByTrade = 100 - feeByTrade;
        address payable newOwner = payable(msg.sender);

        (, nftContract, nftOwner, nftState, nftPrice) = IRMCTicketInfo(_addrNftContract).getNftInfo(_tokenId);
        seller = nftOwner;

        require(nftState == IRMCTicketInfo.State.Dealing, "WARNING :: Deal not in progress for this NFT");
        nftState = IRMCTicketInfo.State.NoDeal;
        require(msg.value == nftPrice, "WARNING :: you don't pay the right price");
        require(msg.sender != nftOwner, "WARNING :: you can't buy your own NFT");

        IRMCTicketInfo(_addrNftContract).setNftInfo(_tokenId, newOwner, nftState, nftPrice);

        payable(address(this)).transfer(msg.value);
        IERC721(nftContract).safeTransferFrom(address(this), msg.sender, _tokenId);

        seller.transfer(_minusFeeByTrade * msg.value / 100);

    }

    function approveFeeManager(address _addrFeeManager) public onlyOwner {
        addrContractFeeManager = _addrFeeManager;
        
        //To avoid a mix with old and new approved amount, we set the allowance to 0 before setting the new allowance
        IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).approve(_addrFeeManager, 0);
        IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).approve(_addrFeeManager, 1000);

    }

    function getAllowance() public onlyOwner view returns(uint)  {
        return IERC20(0xB31f66AA3C1e785363F0875A1B74E27b85FD66c7).allowance(address(this), addrContractFeeManager);
    }

}