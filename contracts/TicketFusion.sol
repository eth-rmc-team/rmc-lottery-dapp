// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './TicketManager.sol';
import './LotteryManager.sol';

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


contract TicketFusion is TicketManager {

    address private owner;
    address public _addrContractLottery;
    address public _addrNormalNftContract;
    address public _addrGoldNftContract;
    address public _addrSuperGoldNftContract;
    
    LotteryManager lotteryManager;
    
    uint normalTicketFusionRequirement;
    uint goldTicketFusionRequirement;

    bool _chasePeriod;

    //a voir comment on goupile avec le contrat rmcToken
    uint _rmcFusionReward;
    
    constructor() {
        owner = msg.sender;
        
    }

    //Function for the contract to claim reward from his gold NFTs
    function triggerClaim() external {
        //a faire
     }

    //Function setting the requirement for a fusion of normal tickets for a Gold ticket
    function setNormalTicketFusionRequirement(uint _normalTicketFusionRequirement) external onlyOwner {
        normalTicketFusionRequirement = _normalTicketFusionRequirement;
    }

    function setGoldTicketFusionRequirement(uint _goldTicketFusionRequirement) external onlyOwner {
        goldTicketFusionRequirement = _goldTicketFusionRequirement;
    }


    //Fucntion getter returning the requirement for a fusion of normal tickets for a Gold ticket
    function getNormalTicketFusionRequirement() public view returns(uint){
        return normalTicketFusionRequirement;
    }

    //Function getter returning the requirement for a fusion of Gold tickets for a SuperGold ticket
    function getGoldTicketFusionRequirement() public view returns(uint){
        return goldTicketFusionRequirement;
    }
    
     
    // 
    // @dev This function allows the owner of normal tickets to fuse them into a gold ticket.
    // @param tokenIds An array of uint values representing the token IDs of the normal tickets to be fused.
    // @return None.
    // Requirements:
    //   The user must have at least normalTicketFusionRequirement normal tickets.
    //   The tokenIds array must have a length of normalTicketFusionRequirement.
    //   Each token in the tokenIds array must belong to the calling user.
    // Effects:
    //   The normal tickets with the specified token IDs are burned (destroyed).
    //   The calling user is awarded a new gold ticket.
    //
    function fusionNormalTickets(uint[] memory tokenIds) public {
        _chasePeriod = lotteryManager.chasePeriod();
        address _addrNormalTicketContract = super.getAddrNormalNftContract();
        address _addrGoldTicketContract = super.getAddrGoldNftContract();
        uint256 balance = super._balanceOf(_addrNormalTicketContract,msg.sender);

        require(_chasePeriod == true, "WARNING :: Fusion is not allowed while a lottery is live");
        require(balance >= normalTicketFusionRequirement, "WARNING :: Not enough Normal Tickets.");
        balance = 0;

        require(tokenIds.length == normalTicketFusionRequirement, "WARNING :: Incorrect number of presented tickets (must be 7 normal tickets).");
        for (uint i = 0; i < normalTicketFusionRequirement; i++) {
            require(super._ownerOf(_addrNormalTicketContract,tokenIds[i]) == msg.sender, "WARNING :: Token does not belong to user.");
            super._approuve(_addrNormalTicketContract, tokenIds[i], address(this));
            super._transferFrom(msg.sender, address(0), _addrNormalTicketContract, tokenIds[i]);

            //Pas de fonction burn avec IERC721, que dans ERC721. Mais ça revient à envoyer à l'adresse 0 ?
            //ERC721(_addrNormalTicketCOntract).burn(tokenIds[i]);  ne fonctionne pas
        }

        // mint des tokens RMC

        // Ne compile pas:
        //ERC721(_addrGoldTicketContract)._mint(msg.sender);
    }


    //
    // @dev This function allows the owner of gold tickets to fuse them into a super gold ticket.
    // @param tokenIds An array of uint values representing the token IDs of the gold tickets to be fused.
    // @return None.
    // Requirements:
    //   The user must have at least goldTicketFusionRequirement gold tickets.
    //   The tokenIds array must have a length of goldTicketFusionRequirement.
    //   Each token in the tokenIds array must belong to the calling user.
    // Effects:
    //   The gold tickets with the specified token IDs are transferred from the calling user to this contract.
    //   The calling user is awarded a new super gold ticket.
    //
    function fusionGoldTickets(uint[] memory tokenIds) public {
        _chasePeriod = lotteryManager.chasePeriod();
        address _addrGoldTicketContract = super.getAddrGoldNftContract();
        address _addrSuperGoldTicketContract = super.getAddrSuperGoldNftContract();
        uint256 balance = super._balanceOf(_addrGoldTicketContract,msg.sender);

        require(_chasePeriod == true, "WARNING :: Fusion is not allowed while a lottery is live");
        require(balance >= goldTicketFusionRequirement, "Not enough Gold Tickets.");
        balance = 0;
        require(tokenIds.length == goldTicketFusionRequirement, "Incorrect number of tokens.");
        for (uint i = 0; i < goldTicketFusionRequirement; i++) {
            require(super._ownerOf(_addrGoldTicketContract,tokenIds[i]) == msg.sender, "WARNING :: Token does not belong to user.");
            super._approuve(_addrGoldTicketContract, tokenIds[i], address(this));
            super._transferFrom(msg.sender, address(this), _addrSuperGoldTicketContract, tokenIds[i]);
        }

        // mint des tokens RMC (peut etre x2 pour gold ?)
        //Todo: meme problème de mint que plus haut
        //superGoldTicketContract.mint(msg.sender);
    }

}