//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './LotteryManager.sol';
import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";
import './Interfaces/IRMCLotteryInfo.sol';

contract TicketStaking is LotteryManager{

    address private addrContractMiniNormalTicket;        
    address public winnerStaked;

    uint public stakingDiviser;
    uint public stakingReward;

    bool getStakingBalance;

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

    function setAddrContractMiniNormalTicket (address _addrContractMiniNormalTicket) public onlyOwner {
        addrContractMiniNormalTicket = _addrContractMiniNormalTicket;
    }

    function setStakingDiviser(uint _stakingDiviser) public onlyOwner {
        stakingDiviser = _stakingDiviser;
    }

    function setTicketStaked(address _addrStaked, uint _tokenId) external onlyLotteryGameContract {
        IERC721Enumerable(addrNormalNftContract).tokenOfOwnerByIndex(_addrStaked, _tokenId);
        idTicketToAddressStaked[_tokenId] = _addrStaked;
    }

    function stake(uint _amount, address _addrStaked) external payable {
        require(IRMCLotteryInfo(addrLotteryGame).getPeriod() == IRMCLotteryInfo.Period.Game, "ERROR :: You can only stake during the game period");
        uint price = _amount * IRMCLotteryInfo(addrLotteryGame).getMintPrice() / stakingDiviser;
        require(msg.value == price, "ERROR :: You must pay the correct amount");
        address staker = msg.sender;

        payable(address(this)).transfer(msg.value);
        addressStakedToNbStaker[_addrStaked] += _amount;
        addressStakerToStakerInfo[staker].addrStaked = _addrStaked;
        addressStakerToStakerInfo[staker].nbTicketStaked += _amount;

        for (uint i = 0; i < _amount; i++) {
            uint miniTokenId;
            miniTokenId = IRMCMinter(addrContractMiniNormalTicket).createTicket("MiniTicket", staker, IRMCTicketInfo.NftType.Mini);
            addressStakerToStakerInfo[staker].tokenIdTicketStaked.push(miniTokenId);
        }

    }

    function claimForStaker() external {

        require(IRMCLotteryInfo(addrLotteryGame).getPeriod() == IRMCLotteryInfo.Period.Claim, "ERROR :: You can only claim during the claim period");
        if(getStakingBalance == false){
            getStakingBalance = true;
            stakingReward = address(this).balance;
        }

        uint _idTokenWinner = IRMCLotteryInfo(addrLotteryGame).getIdTokenWinner();
        uint cpt = 0;
        winnerStaked = idTicketToAddressStaked[_idTokenWinner];

        require(addressStakerToStakerInfo[msg.sender].addrStaked == winnerStaked, "ERROR :: you haven't stacked this bag");
        for(uint i = 0; i < addressStakerToStakerInfo[msg.sender].tokenIdTicketStaked.length; i++){
            if(IERC721Enumerable(addrContractMiniNormalTicket).ownerOf(addressStakerToStakerInfo[msg.sender].tokenIdTicketStaked[i]) == msg.sender){
                cpt ++;
            }
        }

        addressStakerToStakerInfo[msg.sender].nbTicketStaked = 0;
        addressStakerToStakerInfo[msg.sender].addrStaked = address(0);

        uint gain = cpt / addressStakedToNbStaker[winnerStaked] * stakingReward;
        payable(msg.sender).transfer(gain * (10 ** 18));

    }

}