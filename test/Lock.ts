import { expect } from "chai";
import { ethers, deployments, getNamedAccounts } from "hardhat";
import { NToken } from "../typechain-types"

describe("NToken", function () {
  let token: NToken;
  let deployer: string;
  let user: string;

  beforeEach(async function() {
    ({deployer, user}) = await getNamedAccounts());

    await deployments.fixture(["NToken"]);
    token = await ethers.getContract<NToken>("NToken");
  });

  it("works", async function() {
    const tokenId = "";
    const mintTx = await token.safeMint(user, tokenId);
    await mintTx.wait();
    expect(await tokenId.tokenURI(0)).to.eq(`ipfs://${tokenId}`);

    const tokenId2 = "";
    const mintTx2 = await token.safeMint(user, tokenId2);
    await mintTx2.wait();

    const tokenId3 = "";
    const mintTx3 = await token.safeMint(deployer, tokenId3);
    await mintTx3.wait();
    expect(await token.totalSupply()).to.eq(3);

    const deployerTokenId = await token.tokenOf
  })
