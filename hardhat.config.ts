import { HardhatUserConfig } from "hardhat/config";
import "@nomicfoundation/hardhat-toolbox";
import "hardhat-deploy";
import "hardhat-deploy-ethers";

const config: HardhatUserConfig = {
  solidity: "0.8.17",
  namedAccounts: {
    deployer: 0,
    user: 1
  },
  networks: {
    hardhat: {
      chainId: 1337
    }
  }
};

export default config;