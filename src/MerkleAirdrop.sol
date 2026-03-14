// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleProof } from "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import { EIP712 } from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import { ECDSA } from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";

contract MerkleAirdrop is EIP712{
  using SafeERC20 for IERC20;

  // Errors
  error Airdrop__InvalidProof();
  error Airdrop__InvalidSignature();
  error Airdrop_AlreadyClaimed();

  // Events
  event Airdrop_Claimed(address account, uint256 amount);

  struct AirdropClaim {
    address account;
    uint256 amount;
  }

  bytes32 public constant MESSAGE_TYPEHASH = keccak256("AirdropClaim(address account,uint256 amount)");

  IERC20 immutable i_token;
  bytes32 immutable i_merkleRoot;

  address[] claimers;
  mapping(address claimer => bool claimed) private hasClaimed;

  constructor(IERC20 _airdropToken, bytes32 _merkleRoot) EIP712("Merkle Airdrop", "1") {
    i_merkleRoot = _merkleRoot;
    i_token = _airdropToken;
  }

  function claim(uint256 _amount, bytes32[] calldata _merkleProof) external {
    if (hasClaimed[msg.sender]) revert Airdrop_AlreadyClaimed();

    bytes32 _leaf = keccak256(bytes.concat(keccak256(abi.encode(msg.sender, _amount))));

    if(!MerkleProof.verify(_merkleProof, i_merkleRoot, _leaf)) revert Airdrop__InvalidProof();

    hasClaimed[msg.sender] = true;

    emit Airdrop_Claimed(msg.sender, _amount);

    i_token.safeTransfer(msg.sender, _amount);
  }

  function claimOnBehalfOf(address _account, uint256 _amount, bytes32[] calldata _merkleProof, uint8 _v, bytes32 _r, bytes32 _s) external {
    if (hasClaimed[msg.sender]) revert Airdrop_AlreadyClaimed();
    if (!_isValidSignature(_account, getMessageDigest(_account, _amount), _v, _r, _s))  revert Airdrop__InvalidSignature();

    bytes32 _leaf = keccak256(bytes.concat(keccak256(abi.encode(_account, _amount))));

    if (!MerkleProof.verify(_merkleProof, i_merkleRoot, _leaf)) revert Airdrop__InvalidProof();

    hasClaimed[_account] = true;
 
    emit Airdrop_Claimed(_account, _amount);

    i_token.safeTransfer(_account, _amount);
  }

  function _isValidSignature(address _account, bytes32 _digest, uint8 _v, bytes32 _r, bytes32 _s) internal pure returns (bool) {
    (address actualSigner, ,) = ECDSA.tryRecover(_digest, _v, _r, _s);
    return _account == actualSigner;
  }

  function getMessageDigest(address _account, uint256 _amount) public view returns (bytes32) {
    return _hashTypedDataV4(keccak256(abi.encode(MESSAGE_TYPEHASH, AirdropClaim({ account: _account, amount: _amount}))));
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