// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

interface IHonestFarmer is IERC721 {
    function nftPrice(uint256 tokenID) external view returns (uint256 price);
    function isNFTForSale(uint256 tokenID) external view returns (bool isNFTForSale);
}
