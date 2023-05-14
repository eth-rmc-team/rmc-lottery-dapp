// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface interfaceRmcToken {
    //function _mintPlayersReward(address payable _player, State _rewardState) external;
    
}

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";

//Contract managing RMC token and his minting

contract RmcToken is ERC20Capped, ERC20Burnable {
    
    address payable private owner;
    enum State { Fusion, Mint, Stacking, Deal, LiquidityPool }
    State private rewardState;
    uint public totalReward;
   
    constructor(uint cap, uint reward) ERC20("Royal Mountains Club", "RMC") ERC20Capped(cap * (10 ** decimals())) {

        owner = payable(msg.sender);
        _mint(owner, 7000000 * (10 ** decimals()));
        totalReward = reward * (10 ** decimals());
    }
    
    modifier onlyOwner {
        require(msg.sender == owner, "Seul le proprietaire du SC peut utiliser cette fonction");
        _;
    }

    //Function overriding the _mint function from ERC20Capped
    function _mint(address account, uint256 amount) internal virtual override(ERC20Capped, ERC20) {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }

    //Function permitting to mint token to the player depending on the type of claimer
    function _mintPlayersReward(address payable _player, State _rewardState) external{
        if (_player != address(0)){
            if (_rewardState == State.Fusion){
                uint fusionReward = totalReward / 6;
                _mint(_player, fusionReward);
            }
            else if (_rewardState == State.Mint){
                uint mintReward = totalReward / 6;
                _mint(_player, mintReward);
            }
            else if (_rewardState == State.Stacking){
                uint stackingReward = 0;
                _mint(_player, stackingReward);
            }
            else if (_rewardState == State.Deal){
                uint dealReward = totalReward / 6;
                _mint(_player, dealReward);
            }
            else if (_rewardState == State.LiquidityPool){
                uint liquidityPoolReward = totalReward / 2;
                _mint(_player, liquidityPoolReward);
            }
            else{
                revert("WARNING :: No token can be minted");
            }
        }
    }
    
    //Function setting the number of token to mint
    function settotalReward(uint reward) public onlyOwner {
        totalReward = reward * (10 ** decimals());
    }

    //Function getter returning the address of the contract
    function getAddrRmcToken() public view returns(address){
        return address(this);
    }

    //Function permitting to destroy the contract
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }

}