import { SignerWithAddress } from "@nomiclabs/hardhat-ethers/signers";
import { expect } from "chai";
import { BigNumber, Contract, ContractReceipt, ContractTransaction } from "ethers";
import { ethers } from "hardhat";
import whitelist from "../configs/whitelist";

describe("ERC721DogyRace", () => {
  let accounts: SignerWithAddress[];
  let ERC721DogyRace;
  let erc721DogyRace: Contract;
  it("whitelist", async () => {
    accounts = await ethers.getSigners()
    ERC721DogyRace = await ethers.getContractFactory("ERC721DogyRace")
    erc721DogyRace = await ERC721DogyRace.deploy(10, 2, BigNumber.from("120000000000000000"), "https://localhost:3000/")
    await erc721DogyRace.deployed()
    const [owner, addr1] = accounts
    await erc721DogyRace.addToWhiteList(owner.address)
    await erc721DogyRace.addToWhiteList(addr1.address)
    await erc721DogyRace.addWhiteList(whitelist)
    expect(await erc721DogyRace.baseURI()).to.equal("https://localhost:3000/")
    expect(await erc721DogyRace.isWhiteListed(owner.address)).to.equal(true)
    expect(await erc721DogyRace.isWhiteListed(whitelist[249])).to.equal(true)
  })

  it("mint", async () => {
    const [owner, addr1] = accounts
    await erc721DogyRace.addToWhiteList(owner.address)
    await erc721DogyRace.addToWhiteList(addr1.address)
    let tx: ContractTransaction = await erc721DogyRace.connect(addr1).mintWithAmount(2, {
      value: BigNumber.from("240000000000000000")
    })
    expect((await erc721DogyRace.balanceOf(addr1.address)).toString()).to.equal("2")
    let receipt: ContractReceipt = await tx.wait()
    const events = receipt.events?.filter((x) => { return x.event == "TransferWithAmount" })
    if (events && events.length > 0) {
      const e = events[0];
      expect((e.args && e.args[2]).toString()).to.equal("0,1");
    }
    await erc721DogyRace.connect(owner).mint({
      value: BigNumber.from("120000000000000000")
    })
    expect((await erc721DogyRace.tokenCount()).toString()).to.equal("3")
    expect((await erc721DogyRace.balanceOf(owner.address)).toString()).to.equal("1")
    expect((await erc721DogyRace.balanceOf(addr1.address)).toString()).to.equal("2")
    expect((await erc721DogyRace.totalSupply()).toString()).to.equal("10")
  })

  it("tokens", async () => {
    expect((await erc721DogyRace.tokenURI(1))).to.equal("https://localhost:3000/1")
  })

  it("withdraw", async () => {
    const [owner] = accounts
    let tx: ContractTransaction = await erc721DogyRace.connect(owner).withdraw()
    let receipt: ContractReceipt = await tx.wait()
    const events = receipt.events?.filter((x) => { return x.event == "Withdraw" });
    if (events && events.length > 0) {
      const e = events[0];
      expect((e.args && e.args[1]).toString()).to.equal("360000000000000000");
    }
  })
})
