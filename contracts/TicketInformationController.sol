// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import './TicketManager.sol';

contract TicketInformationController is TicketManager {

    //Multiple functions setting information about a NFT
    function setNftType(NftType _nftType, uint _tokenId) internal {
        idNftToNftInfos[_tokenId].nftType = _nftType;
    }

    function setNftContractAddress(address _nftContractAddress, uint _tokenId) external onlyWhiteListedAddress {
        idNftToNftInfos[_tokenId].nftContractAddress = _nftContractAddress;
    }

    function setNftID(uint _tokenId) internal {
        idNftToNftInfos[_tokenId].nftID = _tokenId;
    }

    //Function setting informations about a NFT from the Marketplace contract (owner, state of deal, price)
    //todo: faire de meme avec tokenId, addresseCOntract et Type NFT depuis le Minter et Fusion
    function setNftInfo(uint _tokenId, 
                        address payable _nftOwner, 
                        State _nftState, 
                        uint _nftPrice ) external onlyWhiteListedAddress {
                            
        require(idNftToNftInfos[_tokenId].nftID == _tokenId, "ERROR :: NFT not found");
        idNftToNftInfos[_tokenId].nftOwner = _nftOwner;
        idNftToNftInfos[_tokenId].nftStateOfDeal = _nftState;
        idNftToNftInfos[_tokenId].nftPrice = _nftPrice;

    }

    function setPPClaimStatus(bool _statusPP, uint _tokenId) external onlyWhiteListedAddress {
        idNftToNftInfos[_tokenId].nftPricePoolClaimed = _statusPP;
    }

    function setFeeClaimStatus(bool _statusFee, uint _tokenId) external onlyWhiteListedAddress {
        idNftToNftInfos[_tokenId].nftFeeClaimed = _statusFee;
    }
    //End of functions

        //Function getter returning all the information about a NFT
    function getNftInfo(uint _tokenId) external view returns (NftType, 
                                                            address _addrContr, 
                                                            uint _id, 
                                                            address payable _owner, 
                                                            State _dealStatus, 
                                                            uint _price) {
        return (idNftToNftInfos[_tokenId].nftType, 
        idNftToNftInfos[_tokenId].nftContractAddress, 
        idNftToNftInfos[_tokenId].nftID, 
        idNftToNftInfos[_tokenId].nftOwner, 
        idNftToNftInfos[_tokenId].nftStateOfDeal, 
        idNftToNftInfos[_tokenId].nftPrice);
    }

    function getClaimedRewardStatus(uint _tokenId) external view returns(bool _pricePoolStatus, 
                                                                         bool _feeStatus) {
        return (idNftToNftInfos[_tokenId].nftPricePoolClaimed, 
                idNftToNftInfos[_tokenId].nftFeeClaimed);
    }

    //Function getter returning all the address of the NFT contracts
    function getAddrTicketContracts() external view returns(address _addrN, 
                                                            address _addrG, 
                                                            address _addrSG, 
                                                            address _addrM, 
                                                            address _addrP){
        return (addrNormalNftContract, 
                addrGoldNftContract, 
                addrSuperGoldNftContract, 
                addrMythicNftContract, 
                addrPlatinNftContract);
    }
}