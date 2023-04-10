require("@nomiclabs/hardhat-waffle");
const { log } = require("console");
const fs = require("fs");

task("account_detail", "Prints all IERC721 from an account", async (taskArgs, hre) => {
    const account = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

    // Obtenir une instance du contrat ERC-721 à partir de son adresse
    const contract = await ethers.getContractAt("TicketCollection", "0x5fbdb2315678afecb367f032d93f642f64180aa3");

    console.log(contract)

    // Obtenir le nombre total de tokens détenus par le compte
    const tokenCount = await contract.balanceOf(account);

    console.log(tokenCount)

    // Créer un tableau pour stocker les identifiants des tokens détenus
    const ownedTokens = [];

    // Itérer à travers tous les tokens détenus par le compte et les stocker dans le tableau
    for (let i = 0; i < tokenCount; i++) {
        const tokenId = await contract.tokenOfOwnerByIndex(account, i);
        ownedTokens.push(tokenId.toString());
    }

    // Retourner le tableau d'identifiants de tokens détenus
    console.log(ownedTokens)
});

task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
    const accounts = await hre.ethers.getSigners();
    const provider = hre.ethers.provider;

    for (const account of accounts) {
        console.log(
            "%s (%i ETH)",
            account.address,
            hre.ethers.utils.formatEther(
                // getBalance returns wei amount, format to ETH amount
                await provider.getBalance(account.address)
            )
        );
    }
});

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
        hardhat: {
            chainId: 1337
        },
    }
};
