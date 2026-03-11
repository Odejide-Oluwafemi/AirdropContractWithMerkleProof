// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { ERC20 } from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract FemiToken is ERC20 ("Femi Token", "FMT"), Ownable(msg.sender) {
  function mint(address _to, uint256 _amount) external onlyOwner {
    _mint(_to, _amount);
  }
}