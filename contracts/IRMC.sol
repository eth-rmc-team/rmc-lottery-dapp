// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface IRMC {
    
    //Structs from TicketManager.sol
    enum State { NoDeal, Dealing }
    enum NftType { Normal, Gold, SuperGold, Mythic, Platin }
    enum Period { Game, Claim, Chase, End }

    //Functions from TicketManager.sol
    function setNftInfo(uint _tokenId, address _nftOwner, State _nftState, uint _nftPrice) external;
    function getNftInfo(uint _tokenId) external view returns (NftType, address, uint, address payable, State, uint);
    function getMintPrice() external view returns(uint);

    //Functions from LotteryManager.sol
    function setLotteryId (uint _id) external;
    function setPeriod(Period _period) external;
    function getPeriod() external view returns (Period);
    function getShareOfPricePoolFor() external view returns(uint _shareProt, uint _shareWinner, uint shareSGG, uint _shareMyth, uint _sharePlat);
    function getTotalDay() external view returns(uint _totalDay);
    function getTicketsSalable() external view returns(uint _nbOfTicketsSalable);
    function getLotteryId() external view returns(uint _lotteryId);

}