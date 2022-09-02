// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./IHonestFarmer.sol";

contract HonestFarmer is ERC721URIStorage, Pausable, Ownable, IHonestFarmer { //ERC721Burnable
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    mapping(uint256 => uint256) _erc20OwnedByNFT;
    mapping(uint256 => bool) _isNFTForSale;
    mapping(uint256 => uint256) private _nftPrice;

    function balanceOfNFT(uint256 tokenId) view public returns(uint256 balance) {
        return(_erc20OwnedByNFT[tokenId]);
    }

    function nftPrice(uint256 tokenId) override external view returns(uint256 price) {
        return _nftPrice[tokenId];
    }

    function isNFTForSale(uint256 tokenId) override external view returns(bool) {
        return _isNFTForSale[tokenId];
    }

    constructor() ERC721("HonestFarmer", "HF") {}

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    //CHAINLINK address:
    //kovan:
    //0xa36085F69e2889c224210F603D836748e7dC0088
    //rinkeby:
    //0x01BE23585060835E02B77ef475b0Cc51aA1e0709
    address internal constant ERC20_UNDERLYING = 0x01BE23585060835E02B77ef475b0Cc51aA1e0709;

    function safeMint(address to, uint256 erc20Amount, uint256 price, string memory tokenURI) public onlyOwner {
        IERC20(ERC20_UNDERLYING).transferFrom(msg.sender, address(this), erc20Amount);
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _erc20OwnedByNFT[tokenId] = erc20Amount;
        _isNFTForSale[tokenId] = true;
        _nftPrice[tokenId] = price;
        _setTokenURI(tokenId, tokenURI);
    }

    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    modifier onlyNFTOwner(uint256 tokenId) {
        require(_isOwner(_msgSender(), tokenId), "ERC721: transfer caller is not owner");
        _;
    }


    //ToDo add nonReentrant modifier
    function liquidateNFT(address erc20TokenAddress, address to, uint256 tokenId)
    external
    whenNotPaused 
    onlyNFTOwner(tokenId)
    {
        uint256 _erc20TokensToPay = _erc20OwnedByNFT[tokenId];
        _erc20OwnedByNFT[tokenId] = 0;
        IERC20(erc20TokenAddress).transfer(to, _erc20TokensToPay);
        _burn(tokenId);
        //ToDo delete values from mappings OR use a struct and delete it
    }

    function _isOwner(address spender, uint256 tokenId) internal view virtual returns (bool) {
        require(ERC721._exists(tokenId), "ERC721: operator query for nonexistent token");
        address owner = ERC721.ownerOf(tokenId);
        return (spender == owner);
    }
}

