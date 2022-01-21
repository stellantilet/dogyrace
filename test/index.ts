import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { BigNumber, Contract, ContractReceipt, ContractTransaction } from "ethers";
import { ethers } from "hardhat";

describe("ERC721DogyRace", () => {
  let accounts: SignerWithAddress[];
  let ERC721DogyRace;
  let erc721DogyRace: Contract;
  it("whitelist", async () => {
    accounts = await ethers.getSigners()
    ERC721DogyRace = await ethers.getContractFactory("ERC721DogyRace")
    erc721DogyRace = await ERC721DogyRace.deploy(10, 2, "https://gateway.pinata.cloud/ipfs/QmWQgjq53fjTmhrDgQY7xq4uzhFoZThh7ashZbJJ9sd68P/")
    await erc721DogyRace.deployed()
    const [owner, addr1, addr2] = accounts
    await erc721DogyRace.addToWhiteList(owner.address)
    await erc721DogyRace.addToWhiteList(addr1.address)
    await erc721DogyRace.addToWhiteList(addr2.address)
    expect(await erc721DogyRace.isWhiteListed(owner.address)).to.equal(true)
    expect((await erc721DogyRace.price()).toString()).to.equal("150000000000000000")
  })

  it("mint", async () => {
    const [owner, addr1, addr2] = accounts
    let tx: ContractTransaction = await erc721DogyRace.connect(addr1).mint(2, {
      value: BigNumber.from("300000000000000000")
    })
    expect((await erc721DogyRace.balanceOf(addr1.address)).toString()).to.equal("2")
    let receipt: ContractReceipt = await tx.wait()
    const events = receipt.events?.filter((x) => { return x.event == "TransferWithAmount" })
    if (events && events.length > 0) {
      const e = events[0];
      expect((e.args && e.args[2]).toString()).to.equal("501,502");
    }
    await erc721DogyRace.connect(owner).mint(1, {
      value: BigNumber.from("150000000000000000")
    })
    expect((await erc721DogyRace.totalSupply()).toString()).to.equal("3")
    expect((await erc721DogyRace.balanceOf(owner.address)).toString()).to.equal("1")
    expect((await erc721DogyRace.balanceOf(addr1.address)).toString()).to.equal("2")
    expect((await erc721DogyRace.maxSupply()).toString()).to.equal("10")
    expect((await erc721DogyRace.tokenByIndex(0)).toString()).to.equal("500")
    expect((await erc721DogyRace.tokenByIndex(1)).toString()).to.equal("501")

    erc721DogyRace.connect(addr2).mint(1, {
      value: BigNumber.from("150000000000000000")
    })
  })

  it("tokens", async () => {
    expect((await erc721DogyRace.tokenURI(await erc721DogyRace.tokenByIndex(0)))).to.equal("https://gateway.pinata.cloud/ipfs/QmWQgjq53fjTmhrDgQY7xq4uzhFoZThh7ashZbJJ9sd68P/500.json")
    expect((await erc721DogyRace.tokenURI(await erc721DogyRace.tokenByIndex(1)))).to.equal("https://gateway.pinata.cloud/ipfs/QmWQgjq53fjTmhrDgQY7xq4uzhFoZThh7ashZbJJ9sd68P/501.json")
  })

  it("withdraw", async () => {
    const [owner] = accounts
    let tx: ContractTransaction = await erc721DogyRace.connect(owner).withdraw()
    let receipt: ContractReceipt = await tx.wait()
    const events = receipt.events?.filter((x) => { return x.event == "Withdraw" });
    if (events && events.length > 0) {
      const e = events[0];
      expect((e.args && e.args[1]).toString()).to.equal("600000000000000000");
    }
  })
})
