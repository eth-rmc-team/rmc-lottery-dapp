require("@nomiclabs/hardhat-waffle");
require("dotenv").config();
const fs = require("fs");


task("deploy-collection", "Load images and mint NTF for lottery tickets", async (taskArgs, hre) => {
    const jsonData = fs.readFileSync("collection/collection_lottery_5.json");
    const collection = JSON.parse(jsonData);

    const TicketCollection = await ethers.getContractFactory("TicketCollection");
    //RMCLT = RMC Lottery Ticket
    const ticketCollection = await TicketCollection.deploy("lottery_1", "RMCLT");
    
    try {
        await ticketCollection.deployed();
        console.log("ticketCollection deployed to: ", ticketCollection.address);
        
        try {
            for(let i = 0; i < collection.hashes.length; i++) {
                const newItemId = await ticketCollection.mintTicket(collection.hashes[i]);
                console.log("mintTicket success: ", newItemId);
            }
        } catch(err) {
            console.error("mintTicket failed: ", err);
        }
    } catch (error) {
        console.error("ticketCollection deployment failed: ", error);
    }
});

/**
 * @type import('hardhat/config').HardhatUserConfig
 */
module.exports = {
    solidity: "0.8.11",
    networks: {
        rinkeby: {
            url: process.env.RINKEBY_URL,
            accounts: [process.env.METAMASK_WALLET_PRIVATE_KEY]
        }
    }
};
