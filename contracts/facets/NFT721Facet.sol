// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../libraries/LibDiamond.sol";

contract NFT721Facet {
    event Transfer(address indexed from, address indexed to, uint indexed id);

    function _mint(address to,uint tokenId) internal {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(to != address(0), "to is zero address");
        require(ds._ownerOf[tokenId] == address(0), "token already exists");

        ds._balanceOf[to]++;
        ds._ownerOf[tokenId] = to;
        
        emit Transfer(address(0), to, tokenId);
    }

    // Standard ERC721 functions implementation
    function balanceOf(address owner) external view returns (uint balance) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(owner != address(0), "invalid address");
        return ds._balanceOf[owner];
    }

    function ownerOf(uint tokenId) external view returns (address owner) {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        owner = ds._ownerOf[tokenId];
        require(owner != address(0), "invalid address");
    }
}