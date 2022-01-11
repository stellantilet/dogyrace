//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "./WithLimittedSupply.sol";

contract ERC721DogyRace is ERC721, WithLimittedSupply, Ownable {
    string private __baseURI;
    mapping(address => bool) private __whiteList;
    uint256 private __price;

    event Withdraw(address to, uint256 amount);

    constructor(
        uint256 maxSupply_,
        uint256 price_,
        string memory baseURI_
    ) ERC721("DogyRace", "DORD") WithLimittedSupply(maxSupply_) {
        _setBaseURI(baseURI_);
        __price = price_;
    }

    function _setBaseURI(string memory baseURI_) internal onlyOwner {
        __baseURI = baseURI_;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return __baseURI;
    }

    function baseURI() public view returns (string memory) {
        return _baseURI();
    }

    function setBaseURI(string memory baseURI_) public onlyOwner {
        _setBaseURI(baseURI_);
    }

    function isWhiteListed(address address_) public view returns (bool) {
        return __whiteList[address_] == true;
    }

    function addToWhiteList(address address_) public onlyOwner {
        if (!isWhiteListed(address_)) {
            __whiteList[address_] = true;
        }
    }

    function addWhiteList(address[] memory addresses_) public onlyOwner {
        uint256 length = addresses_.length;
        for (uint256 i = 0; i < length; i++) {
            if (!isWhiteListed(addresses_[i])) {
                __whiteList[addresses_[i]] = true;
            }
        }
    }

    function nextToken()
        internal
        override
        ensureAvailability
        returns (uint256)
    {
        uint256 tokenId = super.nextToken();
        return tokenId;
    }

    function mint() public payable {
        require(isWhiteListed(_msgSender()), "Not whitelisted");
        require(msg.value == __price, "Price is not correct");
        require(
            tokenCount() + 1 <= totalSupply(),
            "Minted more than max supply"
        );
        require(
            availableTokenCount() - 1 >= 0,
            "Minted more than available count"
        );
        require(
            balanceOf(_msgSender()) <= 1,
            "No more tokens for this address"
        );
        uint256 id = nextToken();
        _safeMint(_msgSender(), id);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "balance is not available");
        (payable(msg.sender)).transfer(balance);
        emit Withdraw(msg.sender, balance);
    }
}
