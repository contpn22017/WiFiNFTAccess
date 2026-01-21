import { expect } from "chai";
import { ethers } from "hardhat";
import { WiFiAccessNFT } from "../typechain-types";
import { time } from "@nomicfoundation/hardhat-network-helpers";

describe("WiFiAccessNFT", function () {
  let wifiNFT: WiFiAccessNFT;
  let owner: any;
  let user1: any;
  let user2: any;

  before(async () => {
    [owner, user1, user2] = await ethers.getSigners();
    const WiFiAccessNFTFactory = await ethers.getContractFactory("WiFiAccessNFT");
    wifiNFT = (await WiFiAccessNFTFactory.deploy(owner.address)) as WiFiAccessNFT;
    await wifiNFT.waitForDeployment();
  });

  describe("Minting", function () {
    it("Should mint a new ticket with correct payment", async function () {
      const price = await wifiNFT.price();
      await wifiNFT.connect(user1).mint(1, { value: price });
      expect(await wifiNFT.balanceOf(user1.address)).to.equal(1);
    });

    it("Should fail if payment is insufficient", async function () {
      const price = await wifiNFT.price();
      await expect(wifiNFT.connect(user1).mint(1, { value: price - 1n })).to.be.revertedWith("Insufficient funds sent");
    });
  });

  describe("Activation & Validation", function () {
    let tokenId: any;

    it("Should activate the ticket", async function () {
      tokenId = await wifiNFT.tokenOfOwnerByIndex(user1.address, 0);
      await wifiNFT.connect(user1).activate(tokenId);

      const isValid = await wifiNFT.isValid(tokenId);
      expect(isValid).to.equal(true);
    });

    it("Should checkAccess correctly for valid ticket", async function () {
      expect(await wifiNFT.checkAccess(user1.address)).to.equal(true);
    });

    it("Should return false for user without tickets", async function () {
      expect(await wifiNFT.checkAccess(user2.address)).to.equal(false);
    });
  });

  describe("Expiration", function () {
    it("Should expire after duration", async function () {
      // Fast forward time
      const duration = await wifiNFT.defaultDuration();
      await time.increase(Number(duration) + 1);

      // Check specific token validity
      const tokenId = await wifiNFT.tokenOfOwnerByIndex(user1.address, 0);
      expect(await wifiNFT.isValid(tokenId)).to.equal(false);

      // Check general access
      expect(await wifiNFT.checkAccess(user1.address)).to.equal(false);
    });
  });
});
