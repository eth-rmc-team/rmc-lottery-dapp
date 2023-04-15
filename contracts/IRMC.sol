// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IRMC {
    
    //Structs from TicketManager.sol
    enum State { NoDeal, Dealing }
    enum NftType { Normal, Gold, SuperGold, Mythic, Platin }
    enum Period { Game, Claim, Chase, End }

    //Functions from TicketManager.sol
    function setNftInfo(uint _tokenId, 
                        address _nftOwner, 
                        State _nftState, 
                        uint _nftPrice) external;
   
    function setClaimRewardStatus(bool _status, uint _tokenId) external;


    function getNftInfo(uint _tokenId) external view returns (NftType, 
                        address _addrContr, 
                        uint _id, 
                        address payable _owner, 
                        State _dealStatus, 
                        uint _price, 
                        bool _rewardClaimed);
    
    function getClaimedRewardStatus(uint _tokenId) external view returns(bool);

    function getMintPrice() external view returns(uint);
    
    function getAddrTicketContracts() external view returns(address _addrN, 
                                                            address _addrG, 
                                                            address _addrSG, 
                                                            address _addrM, 
                                                            address _addrP);

    //Functions from LotteryManager.sol
    function setLotteryId (uint _id) external;
    
    function setPeriod(Period _period) external;
    
    function getPeriod() external view returns (Period);
    
    function getShareOfPricePoolFor() external view returns(uint _shareProt, 
                                                            uint _shareWinner, 
                                                            uint shareSGG, 
                                                            uint _shareMyth, 
                                                            uint _sharePlat);
    function getTotalDay() external view returns(uint _totalDay);
    
    function getTicketsSalable() external view returns(uint _nbOfTicketsSalable);
    
    function getLotteryId() external view returns(uint _lotteryId);

    //Function from Marketplace.sol
    function claimFees () external;

}