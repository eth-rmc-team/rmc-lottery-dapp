// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './TicketManager.sol';
import './LotteryManager.sol';

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";


contract TicketFusion is TicketManager {

    address private owner;
    address public addrContractLottery;
    
    LotteryManager lotteryManager;
    
    uint _normalTicketFusionRequirement;

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
        _normalTicketFusionRequirement = super.getNormalTicketFusionRequirement();
        address _addrNormalTicketCOntract = super.getAddrNormalNftContract();
        address _addrGoldTicketContract = super.getAddrGoldNftContract();

        require(_chasePeriod == true, "WARNING :: Fusion is not allowed while a lottery is live");
        uint256 balance = super._balanceOf(_addrNormalTicketCOntract,msg.sender);

        require(balance >= _normalTicketFusionRequirement, "WARNING :: Not enough Normal Tickets.");
        balance = 0;

        require(tokenIds.length == _normalTicketFusionRequirement, "WARNING :: Incorrect number of presented tickets (must be 7 normal tickets).");
        for (uint i = 0; i < _normalTicketFusionRequirement; i++) {
            require(super._ownerOf(_addrNormalTicketCOntract,tokenIds[i]) == msg.sender, "WARNING :: Token does not belong to user.");
            super._approuve(_addrNormalTicketCOntract, tokenIds[i], address(this));
            super._transferFrom(msg.sender, address(0), tokenIds[i]);

            //Pas de fonction burn avec IERC721, que dans ERC721. Mais ça revient à envoyer à l'adresse 0 ?
            //ERC721(_addrNormalTicketCOntract).burn(tokenIds[i]);  ne fonctionne pas
        }

        // mint des tokens RMC

        // Ne compile pas:
        //ERC721(_addrGoldTicketContract)._mint(msg.sender);
    }


}