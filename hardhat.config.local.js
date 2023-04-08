require("@nomiclabs/hardhat-waffle");
const fs = require("fs");


task("deploy-collection", "Load images and mint NTF for lottery tickets", async (taskArgs, hre) => {
    console.log("test")
    // const Greeter = await hre.ethers.getContractFactory("Greeter");
    // const greeter = await Greeter.deploy("Hello, Hardhat!");

    // await greeter.deployed();

    // const contractAddress = greeter.address;

    // fs.writeFileSync('./.contract', contractAddress);

    // const accounts = await hre.ethers.getSigners();

    // const walletAddress = accounts[0].address;

    // fs.writeFileSync('./.wallet', walletAddress);
});

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: "0.8.11",
    networks: {
        hardhat: {
            chainId: 1337
        },
    }
};
