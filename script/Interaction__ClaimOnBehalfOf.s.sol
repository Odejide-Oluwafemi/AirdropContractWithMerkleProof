// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { Script, console2 } from "forge-std/Script.sol";
import { DevOpsTools } from "foundry-devops/src/DevOpsTools.sol";
import { MerkleAirdrop } from "src/MerkleAirdrop.sol";

contract Interaction__ClaimOnBehalfOf is Script {
  error Interactions__InvalidSignatureLength();

  address CLAIM_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
  uint256 CLAIM_AMOUNT = 25 * 1e18;
  bytes32[] PROOF = [bytes32(0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad), bytes32(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576)];
  bytes private SIGNATURE = hex"24bb5b6a23f2f5bbe483df3eee382641096be04c90d87ce237395a72088348bc0888d54b215b8db70e3c25bf757734fcd91151a0da4e303108d9e6812c7c15261b";

  function run() external {
    address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);

    claimAirdrop(mostRecentlyDeployed);
  }


  function claimAirdrop(address _airdropContract) public {
    vm.startBroadcast();

    (uint8 _v, bytes32 _r, bytes32 _s) = splitSignatureFromHash(SIGNATURE);

    MerkleAirdrop(_airdropContract).claimOnBehalfOf(CLAIM_ADDRESS, CLAIM_AMOUNT, PROOF, _v, _r, _s);

    vm.stopBroadcast();
  }

  function splitSignatureFromHash(bytes memory _signature) public pure returns (uint8 _v, bytes32 _r, bytes32 _s){
    if(_signature.length != 65) revert Interactions__InvalidSignatureLength();

    assembly {
      _r := mload(add(_signature, 32))
      _s := mload(add(_signature, 64))
      _v := byte(0, mload(add(_signature, 96)))
    }
  }
}