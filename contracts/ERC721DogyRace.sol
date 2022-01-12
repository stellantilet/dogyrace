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
    uint256 private __maxMintPerAddress;
    event TransferWithAmount(
        address indexed from,
        address indexed to,
        uint256[] tokenIds,
        uint256 indexed amount
    );
    event Withdraw(address indexed to, uint256 indexed amount);

    constructor(
        uint256 maxSupply_,
        uint256 maxMintPerAddress_,
        uint256 price_,
        string memory baseURI_
    ) ERC721("DogyRace", "DORD") WithLimittedSupply(maxSupply_) {
        __maxMintPerAddress = maxMintPerAddress_;
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

    function setPrice(uint256 price_) public onlyOwner {
        require(price_ > 10000000000000000, "Price is not valid");
        __price = price_;
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
            "Mint requested more than max supply"
        );
        require(
            availableTokenCount() - 1 >= 0,
            "Mint requested more than available count"
        );
        require(
            balanceOf(_msgSender()) <= __maxMintPerAddress - 1,
            "No more tokens for this address"
        );
        uint256 id = nextToken();
        _safeMint(_msgSender(), id);
    }

    function mintWithAmount(uint256 amount) public payable {
        require(isWhiteListed(_msgSender()), "Not whitelisted");
        require(amount > 0, "Amount is not valid");
        require(msg.value == __price * amount, "Price is not correct");
        require(
            tokenCount() + amount < totalSupply(),
            "Mint requested more than max supply"
        );
        require(
            availableTokenCount() - amount >= 0,
            "Mint requested more than available count"
        );
        require(
            balanceOf(_msgSender()) <= __maxMintPerAddress - amount,
            "No more tokens for this address"
        );
        uint256[] memory tokenIds = new uint256[](amount);
        for (uint256 i = 0; i < amount; i++) {
            uint256 id = nextToken();
            _safeMint(_msgSender(), id);
            tokenIds[i] = id;
        }
        emit TransferWithAmount(address(0), _msgSender(), tokenIds, amount);
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "balance is not available");
        (payable(msg.sender)).transfer(balance);
        emit Withdraw(msg.sender, balance);
    }
}
