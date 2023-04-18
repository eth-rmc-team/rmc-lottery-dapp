//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './LotteryManager.sol';
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import './Interfaces/IRMCLotteryInfo.sol';

contract TicketStaking is LotteryManager{

    address private addrContractMiniNormalTicket;        
    address private winnerStaked;

    uint private stakingDiviser;
    uint private stakingReward;

    bool private getStakingBalance;

    struct StakerInfo {
        address addrStaked;
        uint nbTicketStaked;
        uint[] tokenIdTicketStaked;
        
    }

    mapping (address => uint) public addressStakedToNbStaker;
    mapping (uint => address) public idTicketToAddressStaked;
    mapping (address => StakerInfo) public addressStakerToStakerInfo;

    constructor(address _addrMiniTicket) payable {
        setAddrContractMiniNormalTicket(_addrMiniTicket);
        getStakingBalance = false;

    }

    //Function setting the contract address of the "MiniTicket"
    function setAddrContractMiniNormalTicket (address _addrContractMiniNormalTicket) public onlyOwner {
        addrContractMiniNormalTicket = _addrContractMiniNormalTicket;
    }

    //Function setting by how much the staking price is divided
    function setStakingDiviser(uint _stakingDiviser) public onlyOwner {
        stakingDiviser = _stakingDiviser;
    }

    //Function called by LotteryGame whenever a player buy (and so mint) ticket(s)
    function setTicketStaked(address _addrStaked, uint _tokenId) external onlyLotteryGameContract {
        //Add token ID of recently minted ticket to the map of ticket ID of stakable addresses
        idTicketToAddressStaked[_tokenId] = _addrStaked;
    }

    //Function used to stake a stakable address
    function stake(uint _amount, address _addrStaked) external payable {
        address staker = msg.sender;
        //Check that the lottery is running
        require(IRMCLotteryInfo(addrLotteryGame).getPeriod() == IRMCLotteryInfo.Period.Game, "ERROR :: You can only stake during the game period");
        //Calculate the price to pay for the wanted amount of "Mini-tickets"
        uint price = _amount * IRMCLotteryInfo(addrLotteryGame).getMintPrice() / stakingDiviser;
        //Check that the player has paid the correct amount
        require(msg.value == price, "ERROR :: You must pay the correct amount");
        
        //Transfer the amount paid to the contract
        payable(address(this)).transfer(msg.value);
        //Add the new amount of "Mini-tickets" minted for a stakable address
        addressStakedToNbStaker[_addrStaked] += _amount;
        //Add the address who is staked, to the mapping of the staker
        addressStakerToStakerInfo[staker].addrStaked = _addrStaked;
        //Add the next amount of "Mini-tickets" minted for a stakable address, to the mapping of the staker
        addressStakerToStakerInfo[staker].nbTicketStaked += _amount;

        //Add the token ID of the minted "Mini-tickets" to the mapping of the staker
        for (uint i = 0; i < _amount; i++) {
            uint miniTokenId;
            miniTokenId = IRMCMinter(addrContractMiniNormalTicket).createTicket("MiniTicket", staker, IRMCTicketInfo.NftType.Mini);
            addressStakerToStakerInfo[staker].tokenIdTicketStaked.push(miniTokenId);
        }

    }

    //Function used to claim rewards for stakers
    function claimForStaker() external {

        //Check that the lottery is in the claim period
        require(IRMCLotteryInfo(addrLotteryGame).getPeriod() == IRMCLotteryInfo.Period.Claim, "ERROR :: You can only claim during the claim period");
        //Get the total amount of rewards (balance of the contract)
        //Bool "getStakingBalance" is used to avoid calling the balanceOf function multiple times
        if(getStakingBalance == false){
            getStakingBalance = true;
            stakingReward = address(this).balance;
        }

        uint _idTokenWinner = IRMCLotteryInfo(addrLotteryGame).getIdTokenWinner();
        uint cpt = 0;
        winnerStaked = idTicketToAddressStaked[_idTokenWinner];

        //Check that the staker has staked the address of the winning ticket
        require(addressStakerToStakerInfo[msg.sender].addrStaked == winnerStaked, "ERROR :: you haven't stacked this bag");
        //Loop through the tokens ID of the "Mini-tickets" minted by the staker
        for(uint i = 0; i < addressStakerToStakerInfo[msg.sender].tokenIdTicketStaked.length; i++){
            //Check that the staker owns the "Mini-tickets" minted by him
            if(IERC721Enumerable(addrContractMiniNormalTicket).ownerOf(addressStakerToStakerInfo[msg.sender].tokenIdTicketStaked[i]) == msg.sender){
                cpt ++;
            }
        }

        //Reset the mapping of the staker
        addressStakerToStakerInfo[msg.sender].nbTicketStaked = 0;
        addressStakerToStakerInfo[msg.sender].addrStaked = address(0);

        //Calculate and send the amount of rewards to the staker
        uint gain = cpt / addressStakedToNbStaker[winnerStaked] * stakingReward;
        payable(msg.sender).transfer(gain * (10 ** 18));

    }

}