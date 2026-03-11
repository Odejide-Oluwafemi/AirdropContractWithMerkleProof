// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";

contract MerkleAirdrop {
  using SafeERC20 for IERC20;

  // Errors
  error Airdrop__InvalidProof();
  error Airdrop_AlreadyClaimed();

  // Events
  event Airdrop_Claimed(address account, uint256 amount);

  IERC20 immutable i_token;
  bytes32 immutable i_merkleRoot;

  address[] claimers;
  mapping(address claimer => bool claimed) private hasClaimed;

  constructor(IERC20 _airdropToken, bytes32 _merkleRoot) {
    i_merkleRoot = _merkleRoot;
    i_token = _airdropToken;
  }

  function claim(address _account, uint256 _amount, bytes32[] calldata _merkleProof) external {
    bytes32 leaf = keccak256(bytes.concat(keccak256(abi.encode(_account, _amount))));

    if (!MerkleProof.verify(_merkleProof, i_merkleRoot, leaf)) revert Airdrop__InvalidProof();
    if (hasClaimed[msg.sender]) revert Airdrop_AlreadyClaimed();

    hasClaimed[msg.sender] = true;
 
    emit Airdrop_Claimed(_account, _amount);

    i_token.safeTransfer(_account, _amount);
  }

  function getMerkleRoot() external view returns (bytes32) {
    return i_merkleRoot;
  }

  function getAirdropToken() external view returns (IERC20) {
    return i_token;
  }

  function getClaimersArray() external view returns (address[] memory) {
    return claimers;
  }

  function hasUserClaimed(address _claimer) external view returns (bool) {
    return hasClaimed[_claimer];
  }
} 