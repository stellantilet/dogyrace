//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ERC721DogyRace is ERC721Enumerable, Ownable {
    using Strings for uint256;
    uint256 private __price;
    uint256 private __maxMintPerAddress;
    event Withdraw(address indexed to, uint256 indexed amount);

    using Counters for Counters.Counter;
    uint256 __tokenIncrement;
    uint256 private __maxSupply;
    uint256 __presaleAt;
    uint256 __periodInSeconds;
    string private __baseURI;
    mapping(address => bool) private __whiteList;

    constructor(
        uint256 maxSupply_,
        uint256 maxMintPerAddress_,
        string memory baseURI_
    ) ERC721("DogyRace", "DORD") {
        __maxSupply = maxSupply_;
        __maxMintPerAddress = maxMintPerAddress_;
        __presaleAt = 1642867200;
        __tokenIncrement = 500;
        __periodInSeconds = 0;
        setBaseURI(baseURI_);
        setPrice(0.15 ether);
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return __baseURI;
    }

    function setBaseURI(string memory baseURI_) public onlyOwner {
        __baseURI = baseURI_;
    }

    function maxSupply() public view returns (uint256) {
        return __maxSupply;
    }

    function tokenURI(uint256 tokenId)
        public
        view
        virtual
        override
        returns (string memory)
    {
        require(_exists(tokenId), "URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0
                ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json"))
                : "";
    }

    function setPrice(uint256 price_) public onlyOwner {
        require(price_ >= 0.01 ether, "Price is not valid");
        __price = price_;
    }

    function price() public view returns (uint256) {
        return __price;
    }

    function isWhiteListed(address address_) public view returns (bool) {
        return __whiteList[address_] == true;
    }

    function addToWhiteList(address address_) public onlyOwner {
        if (!isWhiteListed(address_)) {
            __whiteList[address_] = true;
        }
    }

    function removeFromWhiteList(address address_) public onlyOwner {
        if (isWhiteListed(address_)) {
            __whiteList[address_] = false;
        }
    }

    function isPresale() internal view returns (bool) {
        uint256 timestamp = block.timestamp;
        if (
            timestamp >= __presaleAt &&
            timestamp <= __presaleAt + __periodInSeconds
        ) {
            return true;
        }
        return false;
    }

    function isNotSale() internal view returns (bool) {
        uint256 timestamp = block.timestamp;
        if (timestamp < __presaleAt) {
            return true;
        }
        return false;
    }

    function addWhiteList(address[] memory addresses_) public onlyOwner {
        uint256 length = addresses_.length;
        for (uint256 i = 0; i < length; i++) {
            if (!isWhiteListed(addresses_[i])) {
                __whiteList[addresses_[i]] = true;
            }
        }
    }

    function nextToken() internal virtual returns (uint256) {
        uint256 tokenId = __tokenIncrement;
        __tokenIncrement = __tokenIncrement + 1;
        return tokenId;
    }

    function mint(uint256 amount) public payable {
        // require(!isNotSale(), "This is not sale period");
        // if (isPresale()) {
        //     require(
        //         isWhiteListed(_msgSender()),
        //         "Sender is not on whitelisted"
        //     );
        // }
        require(amount > 0, "Amount is not valid");
        require(msg.value == __price * amount, "Price is not correct");
        require(
            totalSupply() + amount <= maxSupply(),
            "Mint requested more than max supply"
        );
        require(
            balanceOf(_msgSender()) <= __maxMintPerAddress - amount,
            "No more tokens for this address"
        );
        for (uint256 i = 0; i < amount; i++) {
            uint256 id = nextToken();
            _safeMint(_msgSender(), id);
        }
    }

    function withdraw() public onlyOwner {
        uint256 balance = address(this).balance;
        require(balance > 0, "Balance is not available");
        (payable(msg.sender)).transfer(balance);
        emit Withdraw(msg.sender, balance);
    }
}
