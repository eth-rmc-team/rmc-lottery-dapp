require("@nomiclabs/hardhat-waffle");
const { log } = require("console");
const fs = require("fs");
const { task } = require("hardhat/config");

// task("account_detail", "Prints all IERC721 from an account", async (taskArgs, hre) => {
//     const account = "0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266";

//     // Obtenir une instance du contrat ERC-721 à partir de son adresse
//     const contract = await ethers.getContractAt("TicketCollection", "0x5fbdb2315678afecb367f032d93f642f64180aa3");

//     console.log(contract)

//     // Obtenir le nombre total de tokens détenus par le compte
//     const tokenCount = await contract.balanceOf(account);

//     console.log(tokenCount)

//     // Créer un tableau pour stocker les identifiants des tokens détenus
//     const ownedTokens = [];

//     // Itérer à travers tous les tokens détenus par le compte et les stocker dans le tableau
//     for (let i = 0; i < tokenCount; i++) {
//         const tokenId = await contract.tokenOfOwnerByIndex(account, i);
//         ownedTokens.push(tokenId.toString());
//     }

//     // Retourner le tableau d'identifiants de tokens détenus
//     console.log(ownedTokens)
// });

// task("accounts", "Prints the list of accounts", async (taskArgs, hre) => {
//     const accounts = await hre.ethers.getSigners();
//     const provider = hre.ethers.provider;

//     for (const account of accounts) {
//         console.log(
//             "%s (%i ETH)",
//             account.address,
//             hre.ethers.utils.formatEther(
//                 // getBalance returns wei amount, format to ETH amount
//                 await provider.getBalance(account.address)
//             )
//         );
//     }
// });

// task("deploy-collection", "Load images and mint NTF for lottery tickets", async (taskArgs, hre) => {
//     // const jsonData = fs.readFileSync("collection/collection_lottery_5.json");
//     // const collection = JSON.parse(jsonData);

//     // const TicketCollection = await ethers.getContractFactory("TicketCollection");
//     // //RMCLT = RMC Lottery Ticket
//     // const ticketCollection = await TicketCollection.deploy("lottery_1", "RMCLT");
    
//     // try {
//     //     await ticketCollection.deployed();
//     //     console.log("ticketCollection deployed to: ", ticketCollection.address);
        
//     //     try {
//     //         for(let i = 0; i < collection.hashes.length; i++) {
//     //             const newItemId = await ticketCollection.mintTicket(collection.hashes[i]);
//     //             console.log("mintTicket success: ", newItemId);
//     //         }
//     //     } catch(err) {
//     //         console.error("mintTicket failed: ", err);
//     //     }
//     // } catch (error) {
//     //     console.error("ticketCollection deployment failed: ", error);
//     // }
// });

// task("deploy-lottery", "Deploy lottery contracts", async (taskArgs, hre) => {
//     const FeeManager = await ethers.getContractFactory("FeeManager");
//     const LotteryGame = await ethers.getContractFactory("LotteryGame");
//     const LotteryManager = await ethers.getContractFactory("LotteryManager");
//     const Marketplace = await ethers.getContractFactory("Marketplace");
//     const RmcToken = await ethers.getContractFactory("RmcToken");
//     const TicketFusion = await ethers.getContractFactory("TicketFusion");
//     const TicketInformationController = await ethers.getContractFactory("TicketInformationController");
//     const TicketManager = await ethers.getContractFactory("TicketManager");
//     const GoldTicketMinter = await ethers.getContractFactory("GoldTicketMinter");
//     const MythicTicketMinter = await ethers.getContractFactory("MythicTicketMinter");
//     const NormalTicketMinter = await ethers.getContractFactory("NormalTicketMinter");
//     const PlatinTicketMinter = await ethers.getContractFactory("PlatinTicketMinter");
//     const SuperGoldTicketMinter = await ethers.getContractFactory("SuperGoldTicketMinter");
//     const TicketMinterManager = await ethers.getContractFactory("TicketMinterManager");
    
//     const feeManager = await FeeManager.deploy();
//     const lotteryManager = await LotteryManager.deploy();
//     const lotteryGame = await LotteryGame.deploy(
//         "0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD",
//         "0xF8A0BF9cF54Bb92F17374d9e9A321E6a111a51bD", 
//         "0x474e34a077df58807dbe9c96d3c009b23b3c6d0cce433e59bbf5b34f823bc56c", 
//         111
//     );

//     const marketplace = await Marketplace.deploy();
//     const rmcToken = await RmcToken.deploy("1000000000000000000", 10000);
//     const ticketFusion = await TicketFusion.deploy();
//     const ticketInformationController = await TicketInformationController.deploy();
//     const ticketManager = await TicketManager.deploy();
//     const goldTicketMinter = await GoldTicketMinter.deploy();
//     const mythicTicketMinter = await MythicTicketMinter.deploy();
//     const normalTicketMinter = await NormalTicketMinter.deploy();
//     const platinTicketMinter = await PlatinTicketMinter.deploy();
//     const superGoldTicketMinter = await SuperGoldTicketMinter.deploy();
//     const ticketMinterManager = await TicketMinterManager.deploy("ticketMinter", "name      ");

//     const contractAddresses = {
//         "feeManager": feeManager.address,
//         "lotteryGame": lotteryGame.address,
//         "lotteryManager": lotteryManager.address,
//         "marketplace": marketplace.address,
//         "rmcToken": rmcToken.address,
//         "ticketFusion": ticketFusion.address,
//         "ticketInformationController": ticketInformationController.address,
//         "ticketManager": ticketManager.address,
//         "goldTicketMinter": goldTicketMinter.address,
//         "mythicTicketMinter": mythicTicketMinter.address,
//         "normalTicketMinter": normalTicketMinter.address,
//         "platinTicketMinter": platinTicketMinter.address,
//         "superGoldTicketMinter": superGoldTicketMinter.address,
//         "ticketMinterManager": ticketMinterManager.address
//     };

//     fs.writeFileSync("contract-addresses.json", JSON.stringify(contractAddresses, null, 2));

//     await normalTicketMinter.setAddrLotteryGameContract(lotteryGame.address);
//     await lotteryGame.setAddrNormalTicket(normalTicketMinter.address);

//     const jsonData = fs.readFileSync("collection/collection_lottery_5.json");
//     const collection = JSON.parse(jsonData);

//     await normalTicketMinter.initializeStrings(collection.hashes);

//     const [user1, user2, user3] = await ethers.getSigners();
//     const tx1 = await lotteryGame.connect(user1).buyTicket(["Qmeaw1BmZyvC7NLqeWXJJLnh6Zpix6yZe1tvLCk5jBMXbY"]);
//     const tx2 = await lotteryGame.connect(user2).buyTicket(["QmV2HohYfdu87akybDs3qSgjVso5yeCym2TDFsULMwPvty", "QmPdTbEGVqcC8BiKCWp2WvAqhV2RaMsf32816gstj9gXA7"]);

//     await tx1.wait();
//     await tx2.wait();
    
//     //wait 1500 ms
//     function sleep(time) {
//         return new Promise(resolve => {
//           setTimeout(() => {
//             resolve();
//           }, time);
//         });
//       }

//     await sleep(2000);
//     const tx3 = await lotteryGame.connect(user1).GoToNnextDay();
//     await tx3.wait();
//     //console.log(tx3)
//     await sleep(1500);

//     const nbrDays = 2;

//     for(let i = 0; i < nbrDays; i++) {
//         await sleep(1000);
//         console.log("I = ", i)
//         const tx4 = await lotteryGame.connect(user1).GoToNnextDay();
//         await tx4.wait();
//         console.log(`Next day ${i+1} done`)
//     }
// })




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
