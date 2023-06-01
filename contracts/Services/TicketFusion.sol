// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.11;


// contract TicketFusion is TicketManager 
// {

//     address private owner;

//     bool _chasePeriod;

//     //a voir comment on goupile avec le contrat rmcToken
//     uint _rmcFusionReward;

//     constructor() 
//     {
//         owner = msg.sender;
        
//     }
    

//     //Function for the contract to claim reward from his gold NFTs
//     function triggerClaim() external
//     {
//         //a faire
//     }
    
     
//     // 
//     // @dev This function allows the owner of normal tickets to fuse them into a gold ticket.
//     // @param tokenIds An array of uint values representing the token IDs of the normal tickets to be fused.
//     // @return None.
//     // Requirements:
//     //   The user must have at least normalTicketFusionRequirement normal tickets.
//     //   The tokenIds array must have a length of normalTicketFusionRequirement.
//     //   Each token in the tokenIds array must belong to the calling user.
//     // Effects:
//     //   The normal tickets with the specified token IDs are burned (destroyed).
//     //   The calling user is awarded a new gold ticket.
//     //
//     function fusionNormalTickets(uint[] memory tokenIds) public 
//     {
//         require(
//             IRMCLotteryInfo(addrLotteryGame).getPeriod() == IRMCLotteryInfo.Period.CHASE, 
//             "ERROR :: Fusion is not allowed while a lottery is live"
//         );
        
//         uint256 balance = IERC721(addrNormalNftContract).balanceOf(msg.sender);

//         //require(_chasePeriod == true, "WARNING :: Fusion is not allowed while a lottery is live");
//         require(
//             balance >= normalTicketFusionRequirement, 
//             "WARNING :: Not enough Normal Tickets."
//         );
//         balance = 0;

//         require(
//             tokenIds.length == normalTicketFusionRequirement, 
//             "WARNING :: Incorrect number of presented tickets (must be 7 normal tickets)."
//         );
//         for(uint i = 0; i < normalTicketFusionRequirement; i++) {
//             require(IERC721(addrNormalNftContract).ownerOf(tokenIds[i]) == msg.sender, 
//             "WARNING :: Token does not belong to user.");
//             IERC721(addrNormalNftContract).approve(address(0), tokenIds[i]);
//             IRMCMinter(addrNormalNftContract).burn(tokenIds[i]);

//             //Pas de fonction burn avec IERC721, que dans ERC721. Mais ça revient à envoyer à l'adresse 0 ?
//             //ERC721(_addrNormalTicketCOntract).burn(tokenIds[i]);  ne fonctionne pas
//         }

//         // mint des tokens RMC

//         // Ne compile pas:
//         //ERC721(addrGoldNftContract).createNormalTicket(msg.sender);
//         IRMCMinter(addrGoldNftContract).createTicket("todo", msg.sender, IRMCTicketInfo.NftType.GOLD);

//     }


//     //
//     // @dev This function allows the owner of gold tickets to fuse them into a super gold ticket.
//     // @param tokenIds An array of uint values representing the token IDs of the gold tickets to be fused.
//     // @return None.
//     // Requirements:
//     //   The user must have at least goldTicketFusionRequirement gold tickets.
//     //   The tokenIds array must have a length of goldTicketFusionRequirement.
//     //   Each token in the tokenIds array must belong to the calling user.
//     // Effects:
//     //   The gold tickets with the specified token IDs are transferred from the calling user to this contract.
//     //   The calling user is awarded a new super gold ticket.
//     //
//     function fusionGoldTickets(uint[] memory tokenIds) public 
//     {
//         require(
//             IRMCLotteryInfo(addrLotteryGame).getPeriod() == IRMCLotteryInfo.Period.CHASE, 
//             "ERROR :: Fusion is not allowed while a lottery is live"
//         );

//         uint256 balance = IERC721(addrGoldNftContract).balanceOf(msg.sender);

//         //require(_chasePeriod == true, "WARNING :: Fusion is not allowed while a lottery is live");
//         require(
//             balance >= goldTicketFusionRequirement, 
//             "Not enough Gold Tickets."
//         );
//         balance = 0;
//         require(
//             tokenIds.length == goldTicketFusionRequirement, 
//             "Incorrect number of tokens."
//         );
//         for(uint i = 0; i < goldTicketFusionRequirement; i++) {
//             require(
//                 IERC721(addrGoldNftContract).ownerOf(tokenIds[i]) == msg.sender, 
//                 "WARNING :: Token does not belong to user."
//             );
//             IERC721(addrGoldNftContract).approve(address(this), tokenIds[i]);
//             IRMCMinter(addrGoldNftContract).burn(tokenIds[i]);
//         }

//         // mint des tokens RMC (peut etre x2 pour gold ?)
//         //Todo: meme problème de mint que plus haut
//         //superGoldTicketContract.mint(msg.sender);
//         IRMCMinter(addrSuperGoldNftContract).createTicket(
//             "todo",
//             msg.sender, 
//             IRMCTicketInfo.NftType.SUPERGOLD
//         );
//     }
// }