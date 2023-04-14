//SPDX-Licence-I// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

//Contract minting NFT

contract RmcNftMinter {
    constructor() {
        //a faire
    }
        //Function getter returning the address of the NftMinter contract
    function getAddrNftMinter() public view returns(address) {
        return address(this);
    }
}