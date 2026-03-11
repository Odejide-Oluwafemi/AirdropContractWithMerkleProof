// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
  using SafeERC20 for IERC20;

  // Errors
  error Airdrop__InvalidProof();

  // Events
  event Airdrop_Claimed(address account, uint256 amount);

  IERC20 immutable i_token;
  bytes32 immutable i_merkleRoot;

  address[] claimers;

  constructor(IERC20 _airdropToken, bytes32 _merkleRoot) {
    i_merkleRoot = _merkleRoot;
    i_token = _airdropToken;
  }

  function claim(address _account, uint256 _amount, bytes32[] calldata _merkleProof) external {
    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account, _amount))));

    if (!MerkleProof.verify(_merkleProof, i_merkleRoot, leaf)) revert Airdrop__InvalidProof();

    emit Airdrop_Claimed(_account, _amount);

    i_token.safeTransfer(_account, _amount);
  }
}