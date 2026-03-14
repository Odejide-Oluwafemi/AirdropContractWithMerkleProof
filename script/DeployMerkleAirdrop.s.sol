// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { Script, console2 } from "forge-std/Script.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { MerkleAirdrop } from "src/MerkleAirdrop.sol";
import { FemiToken } from "src/FemiToken.sol";

contract DeployMerkleAirdrop is Script {
  // Error
  error DeployMerkleAirdrop__TokenTransferFailed();
  uint256 AIRDROP_BALANCE = 4 * 25 * 1e18;
  function run(bytes32 root) external returns (MerkleAirdrop, FemiToken) {
    return deployMerkleAirdrop(root);
  }

  function deployMerkleAirdrop(bytes32 root) public returns (MerkleAirdrop, FemiToken) {
    vm.startBroadcast();

    FemiToken token = new FemiToken();
    MerkleAirdrop airdrop = new MerkleAirdrop(token, root);

    token.mint(token.owner(), AIRDROP_BALANCE);
    
    bool success = token.transfer(address(airdrop), AIRDROP_BALANCE);

    if (!success) revert DeployMerkleAirdrop__TokenTransferFailed();

    vm.stopBroadcast();

    return (airdrop, token);
  }
}