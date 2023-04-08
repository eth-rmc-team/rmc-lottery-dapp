
const { ethers } = require("hardhat");
const fs = require("fs");


async function main() {
    console.log("test")
    // const TicketCollection = await ethers.getContractFactory("TicketCollection");
    // const ticketCollection = await TicketCollection.deploy("lottery_1", "CBEET");
    
    // try {
    //     await ticketCollection.deployed();
    //     console.log("ticketCollection deployed to: ", ticketCollection.address);
    //     mintNFT();
    // } catch (error) {
    //     console.error("ticketCollection deployment failed: ", error);
    // }

    // const mintNFT = async () => {
    //     try {
    //         const newItemId = await ticketCollection.mintTicket("   ");
    //         console.log("mintTicket success: ", newItemId)
    //     } catch(err) {
    //         console.error("mintTicket failed: ", err);
    //     }
    // }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
