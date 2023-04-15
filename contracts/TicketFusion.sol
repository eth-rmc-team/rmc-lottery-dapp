// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import './IRMC.sol';


contract TicketFusion {

    address private owner;
    address public _addrContractLottery;
    address public _addrContractTicketManager;

    address public _addrNormalNftContract;
    address public _addrGoldNftContract;
    address public _addrSuperGoldNftContract;
        
    uint normalTicketFusionRequirement;
    uint goldTicketFusionRequirement;

    bool _chasePeriod;

    //a voir comment on goupile avec le contrat rmcToken
    uint _rmcFusionReward;

    IRMC irmc;
    
    constructor() {
        owner = msg.sender;
        
    }
    
    modifier onlyOwner {
        _;
    }

    //Function for the contract to claim reward from his gold NFTs
    function triggerClaim() external {
        //a faire
     }

    function setAddrTicketManager(address _addrTicketManager) external onlyOwner {
        _addrContractTicketManager = _addrTicketManager;
        irmc = IRMC(_addrContractTicketManager);
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
        //_chasePeriod = lotteryManager.chasePeriod();
        address _addrNormalTicketContract;
        address _addrGoldTicketContract;
        (_addrNormalNftContract,_addrGoldTicketContract,,,) = irmc.getAddrTicketContracts();
        uint256 balance = IERC721(_addrNormalNftContract).balanceOf(msg.sender);

        //require(_chasePeriod == true, "WARNING :: Fusion is not allowed while a lottery is live");
        require(balance >= normalTicketFusionRequirement, "WARNING :: Not enough Normal Tickets.");
        balance = 0;

        require(tokenIds.length == normalTicketFusionRequirement, "WARNING :: Incorrect number of presented tickets (must be 7 normal tickets).");
        for (uint i = 0; i < normalTicketFusionRequirement; i++) {
            require(IERC721(_addrNormalNftContract).ownerOf(tokenIds[i]) == msg.sender, "WARNING :: Token does not belong to user.");
            IERC721(_addrNormalNftContract).approve(address(this), tokenIds[i]);
            IERC721(_addrNormalNftContract).safeTransferFrom(msg.sender, address(0), tokenIds[i]);

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
        //_chasePeriod = lotteryManager.chasePeriod();

        address _addrGoldTicketContract;
        address _addrSuperGoldTicketContract;
        (,_addrGoldTicketContract,_addrSuperGoldTicketContract,,) = irmc.getAddrTicketContracts();

        uint256 balance = IERC721(_addrNormalNftContract).balanceOf(msg.sender);

        //require(_chasePeriod == true, "WARNING :: Fusion is not allowed while a lottery is live");
        require(balance >= goldTicketFusionRequirement, "Not enough Gold Tickets.");
        balance = 0;
        require(tokenIds.length == goldTicketFusionRequirement, "Incorrect number of tokens.");
        for (uint i = 0; i < goldTicketFusionRequirement; i++) {
            require(IERC721(_addrGoldTicketContract).ownerOf(tokenIds[i]) == msg.sender, "WARNING :: Token does not belong to user.");
            IERC721(_addrGoldTicketContract).approve(address(this), tokenIds[i]);
            IERC721(_addrGoldTicketContract).transferFrom(msg.sender, address(this), tokenIds[i]);
        }

        // mint des tokens RMC (peut etre x2 pour gold ?)
        //Todo: meme problème de mint que plus haut
        //superGoldTicketContract.mint(msg.sender);
    }

}