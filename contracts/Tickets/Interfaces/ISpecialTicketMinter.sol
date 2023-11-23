// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "./ITicketMinter.sol";

interface ISpecialTicketMinter is ITicketMinter
{
    function mintSpecial(address _to) external returns(uint256);

}