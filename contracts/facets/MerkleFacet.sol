// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/LibDiamond.sol";
import "./NFT721Facet.sol";

contract MerkleFacet {
    function setMerkleRoot(bytes32 _merkleRoot) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.merkleRoot = _merkleRoot;
    }

    function verifyProof(
        bytes32[] calldata proof,
        bytes32 root,
        bytes32 leaf
    ) internal pure returns (bool) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            bytes32 proofElement = proof[i];
            if (computedHash <= proofElement) {
                computedHash = keccak256(abi.encodePacked(computedHash, proofElement));
            } else {
                computedHash = keccak256(abi.encodePacked(proofElement, computedHash));
            }
        }
        return computedHash == root;
    }

    function claim(bytes32[] calldata proof, address account) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(!ds.hasClaimed[account], "Already claimed");
        require(verifyProof(proof, ds.merkleRoot, keccak256(abi.encodePacked(account))), "Invalid proof");
        
        ds.hasClaimed[account] = true;
        NFT721Facet(address(this))._mint(account, 0);
    }
}