// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import { Test, console2 } from "forge-std/Test.sol";
import { ZkSyncChainChecker } from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import { DeployMerkleAirdrop } from "script/DeployMerkleAirdrop.s.sol";
import { IERC20, SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import { MerkleAirdrop } from "src/MerkleAirdrop.sol";
import { FemiToken } from "src/FemiToken.sol";

contract MerkleAirdropTest is Test, ZkSyncChainChecker {
  MerkleAirdrop airdrop;
  FemiToken token;

  bytes32 root = 0xaa5d581231e596618465a56aa0f5870ba6e20785fe436d5bfb82b08662ccc7c4;
  bytes32[] PROOF = [bytes32(0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a), bytes32(0xe5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576)];

  address user;
  uint256 userPrivKey;
  
  uint256 MINT_AMOUNT =  25 * 1e18;
  uint256 CLAIM_AMOUNT = MINT_AMOUNT;
  uint256 AIRDROP_BALANCE = CLAIM_AMOUNT;

  function setUp() public {
    if (!isZkSyncChain()) {
      DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();

      (airdrop, token) = deployer.deployMerkleAirdrop(root);
    }
    else {
      token = new FemiToken();
      airdrop = new MerkleAirdrop(token, root);
      
      token.mint(token.owner(), MINT_AMOUNT);
      token.transfer(address(airdrop), AIRDROP_BALANCE);
    }

    (user, userPrivKey) = makeAddrAndKey("user");
  }

  function test__UserCanClaim() public {
    uint256 balanceBefore = token.balanceOf(user);

    vm.prank(user);
    airdrop.claim(user, CLAIM_AMOUNT, PROOF);

    uint256 balanceAfter = token.balanceOf(user);
    assertEq(balanceAfter, balanceBefore + CLAIM_AMOUNT);
  }
}