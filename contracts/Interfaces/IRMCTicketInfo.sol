// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/extensions/IERC721Enumerable.sol";

interface IRMCTicketInfo is IERC721Enumerable {
    //Structs from TicketManager.sol
    enum State { NoDeal, Dealing }
    enum NftType { Normal, Gold, SuperGold, Mythic, Platin }

    //Functions from TicketManager.sol
    function setNftInfo(uint _tokenId, 
                        address _nftOwner, 
                        State _nftState, 
                        uint _nftPrice) external;
       
    function setPPClaimStatus(bool _statusPP, uint _tokenId) external;

    function setFeeClaimStatus(bool _statusFee, uint _tokenId) external;

    function getNftInfo(uint _tokenId) external view returns (NftType, 
                        address _addrContr, 
                        uint _id, 
                        address payable _owner, 
                        State _dealStatus, 
                        uint _price, 
                        bool _rewardClaimed);
    
    function getClaimedRewardStatus(uint _tokenId) external view returns(bool _pricePoolStatus, bool _feeStatus);

    function getMintPrice() external view returns(uint);
    
    function getAddrTicketContracts() external view returns(address _addrN, 
                                                            address _addrG, 
                                                            address _addrSG, 
                                                            address _addrM, 
                                                            address _addrP);


}