// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PresaleFacet {
    event PresaleStarted(uint256 price);
    event PresaleEnded();

    function startPresale(uint256 _price) external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.presaleActive = true;
        ds.presalePrice = _price;
        ds.maxPresaleMintsPerTx = 30; // 1 ETH = 30 NFTs
        emit PresaleStarted(_price);
    }

    function endPresale() external {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        ds.presaleActive = false;
        emit PresaleEnded();
    }

    function presaleMint(uint256 quantity) external payable {
        LibDiamond.DiamondStorage storage ds = LibDiamond.diamondStorage();
        require(ds.presaleActive, "Presale not active");
        require(quantity > 0 && quantity <= ds.maxPresaleMintsPerTx, "Invalid quantity");
        require(msg.value >= quantity * ds.presalePrice, "Insufficient payment");

        for (uint256 i = 0; i < quantity; i++) {
            ERC721Facet(address(this)).mint(msg.sender);
        }
    }
}