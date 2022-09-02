// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./IHonestFarmer.sol";

contract HFMarket is Ownable {

    address hf;

    constructor(address _hf) {
        hf = _hf;
    }

    function onERC721Received(address operator, address from, uint256 tokenId, bytes calldata data) public virtual returns (bytes4) {
        return this.onERC721Received.selector;
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    //ToDo fill up
    fallback() external payable {}

    //ToDo add nonReentrant modifier
    //ToDo buyer must be approved
    //ToDo price could be stored in marketplace, not nft
    function buyNFT(uint256 tokenId) public payable{
        require(IHonestFarmer(hf).isNFTForSale(tokenId), "NFT not for sale");
        uint256 price = IHonestFarmer(hf).nftPrice(tokenId);
        require(msg.value >= price*51/50, "Not enough Ether");
        address payable oldOwner = payable(IHonestFarmer(hf).ownerOf(tokenId));
        //create modifier that sets not for sale
        //see modifier "timedTransactions()"
        //https://docs.soliditylang.org/en/v0.8.12/common-patterns.html#example
        IHonestFarmer(hf).safeTransferFrom(address(this), msg.sender, tokenId);
        (bool sent, ) = payable(oldOwner).call{value: price}("");
        require(sent, "ETH transfer failed.");
    }
    
    // function setNFTForSale(uint256 tokenId, uint256 price)
    // external
    // //whenNotPaused
    // onlyNFTOwner(tokenId){
    //     isNFTForSale[tokenId] = true;
    //     nftPrice[tokenId] = price;
    //     ERC721.approve(address(this), tokenId);
    // }

    // modifier onlyNFTOwner(uint256 tokenId) {
    //     require(_isOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner");
    //     _;
    // }

    // function _isOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
    //     require(ERC721._exists(tokenId), "ERC721: operator query for nonexistent token");
    //     address owner = ERC721.ownerOf(tokenId);
    //     return (spender == owner);
    // }

    function withdrawFees() public onlyOwner {
        (bool sent, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(sent, "ETH transfer failed.");
    }
}
