// contracts/Ticket.sol
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";

contract Ticket is ERC721Enumerable {
    address private owner;
    
    constructor(string memory lottery_id, string memory _symbol) 
    ERC721(lottery_id, _symbol) {
        owner = msg.sender;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }
    
    function mint(address to) public onlyOwner {
        _mint(to, totalSupply() + 1);
    }
    
    function burn(uint tokenId) public onlyOwner {
        require(_exists(tokenId), "Token does not exist.");
        _burn(tokenId);
    }
}