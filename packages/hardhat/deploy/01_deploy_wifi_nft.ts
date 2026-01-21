import { HardhatRuntimeEnvironment } from "hardhat/types";
import { DeployFunction } from "hardhat-deploy/types";
import { Contract } from "ethers";

/**
 * Deploys the WiFiAccessNFT contract
 *
 * @param hre HardhatRuntimeEnvironment object.
 */
const deployWiFiNFT: DeployFunction = async function (hre: HardhatRuntimeEnvironment) {
  const { deployer } = await hre.getNamedAccounts();
  const { deploy } = hre.deployments;

  await deploy("WiFiAccessNFT", {
    from: deployer,
    // Contract constructor arguments
    args: [deployer],
    log: true,
    // autoMine: can be passed to the deploy function to make the deployment process faster on local networks by
    // automatically mining the contract deployment transaction. There is no effect on live networks.
    autoMine: true,
  });

  // Get the deployed contract to interact with it after deploying.
  const wifiNFT = await hre.ethers.getContract<Contract>("WiFiAccessNFT", deployer);
  console.log("👋 WiFiAccessNFT deployed to:", await wifiNFT.getAddress());
};

export default deployWiFiNFT;

// Tags are useful if you have multiple deploy files and only want to run one of them.
// e.g. yarn deploy --tags WiFiAccessNFT
deployWiFiNFT.tags = ["WiFiAccessNFT"];
