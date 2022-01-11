// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { BigNumber } from "ethers";
import { ethers } from "hardhat";
// import whitelist from "../configs/whitelist";

async function main() {
  const ERC721DogyRace = await ethers.getContractFactory("ERC721DogyRace")
  const erc721DogyRace = await ERC721DogyRace.deploy(500, BigNumber.from("120000000000000000"), "https://localhost/")

  await erc721DogyRace.deployed();

  console.log(`ERC721DogyRace deployed to: https://rinkeby.etherscan.io/address/${erc721DogyRace.address}#code}`);
  // const [owner] = await ethers.getSigners();
  // erc721DogyRace.connect(owner)
  // await erc721DogyRace.addWhiteList(whitelist);
  // console.log(await erc721DogyRace.whiteList());
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
