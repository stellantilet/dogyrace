//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract ERC721DogyRace is ERC721Enumerable, Ownable {
    using Strings for uint256;
    string private __baseURI;
    uint256 private __price;
    uint256 private __maxMintPerAddress;
    event Withdraw(address indexed to, uint256 indexed amount);

    using Counters for Counters.Counter;
    Counters.Counter private __tokenIncrement;
    uint256 private __maxSupply;

    constructor(
        uint256 maxSupply_,
        uint256 maxMintPerAddress_,
        string memory baseURI_
    ) ERC721("DogyRace", "DORD") {
        __maxSupply = maxSupply_;
        __maxMintPerAddress = maxMintPerAddress_;
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

    function nextToken() internal virtual returns (uint256) {
        uint256 tokenId = __tokenIncrement.current();
        __tokenIncrement.increment();
        return tokenId;
    }

    function mint(uint256 amount) public payable {
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
