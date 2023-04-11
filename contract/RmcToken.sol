// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface interfaceRmcToken {
    function _mintPlayersReward(address payable _player) external;
    
}

//Contrat générant le token RMC

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
//Contrat pour mettre une supply maximale
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
//Contrat pour permettre le burn de token
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";


//ERC20Capped hérite de ERC20, donc on a juste à garder ERC20Capped
contract RmcToken is ERC20Capped, ERC20Burnable {
    
    address payable private owner;
    
    uint public playerReward;
   
    constructor(uint cap, uint reward) ERC20("Royal Mountains Club", "RMC") ERC20Capped(cap * (10 ** decimals())) {//Nom du token et son trigramme

        owner = payable(msg.sender);
        _mint(owner, 7000000 * (10 ** decimals()));
        playerReward = reward * (10 ** decimals());
    }
    
    modifier onlyOwner {
        require(msg.sender == owner, "Seul le proprietaire du SC peut utiliser cette fonction");
        _;
    }

    function _mint(address account, uint256 amount) internal virtual override(ERC20Capped, ERC20) {
        require(ERC20.totalSupply() + amount <= cap(), "ERC20Capped: cap exceeded");
        super._mint(account, amount);
    }

    //Fonction de mint pour les joueurs de la lotterie achetant des tickets
    //Internal: utilisable que dans le SC, non appelable depuis l'extérieur
    function _mintPlayersReward(address payable _player) external{
        if (_player != address(0)){
            _mint(_player, playerReward);
        }
    }

    //Fonction permettant de régler l'emission de nouveau token
    function setplayerReward(uint reward) public onlyOwner {
        playerReward = reward * (10 ** decimals());
    }

    function getAddrRmcToken() public view returns(address){
        return address(this);
    }

    //Fonction permettant de détruire le SC si on veut
    function destroy() public onlyOwner {
        selfdestruct(owner);
    }

}