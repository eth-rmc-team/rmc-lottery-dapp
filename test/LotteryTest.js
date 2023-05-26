const { use, expect } = require('chai')
const { ethers, waffle, network } = require('hardhat')
const BigNumber = require('bignumber.js');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers')

const fs = require("fs")

//on déclare les hashs de la billeterie
//et la combinaison de couleurs associée
const hashes = {
    "Qmeh6PMdLqzpWc4go6wCh4zsNg8KU3oFRa4HkhFZuKiQm6": 111,
    "QmY5EzyFTq3bfEhGLBapXSTjaKt3kyn33rRDAUvMz4THp3": 112,
    "QmdihB4KCshv7HpzdTUDMjQwnpxjyZmkyE23aryX7Zou8U": 113,
    "QmVqcqUdYdGp55A5Bm8QBidzPTjjKcuyGmbhzsgMTLf8Ru": 121,
    "QmRC11NJTU56xfxxUxv6kLwQ6bMsCw7ML39xSZUsqpb4MS": 122,
    "QmW2bu7XD6ehicMAkecYETRJQQ4dnAk4v1p4jqYe4Czz1z": 123,
    "QmSreqtb195zXKg6Lb3pTizhQwiX7yzWxJja7PrArGadJo": 131,
    "QmVtm2hZDPiGjpF4XTcGP1JsQkWLDKsT8popXnzKv1VhWX": 132,
    "Qmee48ib5yJeTL5wKCG6svw2zKeTENyNyJ2519Wvac1hqG": 133,
    "QmNxVF8uTKCMYaTGCHa4xm4SH7ffRNMbykFnrS6Ud6vGZ5": 211,
    "Qme8Psvr3WWuKjbGMFeJEeMW7LyC1d4cVQzrYJrEP4tN2i": 212,
    "QmQwU74HdAXNxzXNW7gN5Y2eimoqwUHj9hoBZ83AooDrYn": 213,
    "QmWknX2P1kScqxhLgf7Gt3UipeEdxT2XMYJPqhADmUft5B": 221,
    "Qma5sM7W3HCgfCC1ipuUG4XbbccUhBT5zQajqhoDpaGxjH": 222,
    "QmTTaj49w17iqhkxfAo1hMUXTfZ3iCVq5asyyLq1VyzUYd": 223,
    "QmaksSvNeqQQuGx5NeUq7eSjGamh2Vs6K1xN4ao55coW7s": 231,
    "QmYtB93PFo2aLV7THeYmADQVStTp6XveBFt1VJmVjpVogx": 232,
    "QmQ2hyXaMTbaMq2RjauoSGgmp2WcHPP4fexRQFEQBkDgy7": 233,
    "QmfDEk7HSGAtG29tGKxCMGeyRtY42DpKzxA3DszgMRM2Td": 311,
    "QmdtTokQoSn8pH2DiAYGkyMgSenUNECTRC4zKYNuwqVK2L": 312,
    "QmZ1kUgs88apFaNxLYNp735n6aurnHJ4f4ky57MPcfidu8": 313,
    "QmNy3hUC3DBE8kvzc4zSy1GwmZS3ZzyN6U2fkGymNRpY7F": 321,
    "QmPZnCLCY6kC8dbEc7ynGg4HBrJCj2fx4gbxdU1g729VEF": 322,
    "QmRtTNJiyD6WNSvc5FsVRFrBzGTBZhquJfhekH2R5SduDj": 323,
    "QmVHCcm9Z6aJj4jCGpp5iucsXG3DLhnuqipwfcMytP8isx": 331,
    "Qmape3X7Nzs32spVtFCLt6zWmfkhgaHuBGy5r1bUWApTjb": 332,
    "QmZN9B4aMt3PQFcQ4AryBuhBcDDqKb8mnF7h3djzj6nJTg": 333
}

//représente le nombre de couleur
//disponible chaque jour (chaque index)
const featuresByDay = [3, 3, 3]


describe("Lottery test", function () {
    let normalTicketMinter
    let lotteryGame
    let feeManager
    let lotteryManager
    let marketplace
    let rmcToken
    let ticketFusion
    let ticketInformationController
    let ticketManager
    let goldTicketMinter
    let mythicTicketMinter
    let platinTicketMinter
    let superGoldTicketMinter
    let ticketMinterManager
    
    let users
    let tokenIds = []
    let owner

    before(async function deployContracts() {
        const u = await ethers.getSigners()
        //on considère le premier utiliateur comme le owner
        owner = u[0]
        //le reste comme des utilisateurs lambdas
        users = u.slice(1)

        const FeeManager = await ethers.getContractFactory("FeeManager")
        const LotteryGame = await ethers.getContractFactory("LotteryGame")
        const LotteryManager = await ethers.getContractFactory("LotteryManager")
        const Marketplace = await ethers.getContractFactory("Marketplace")
        const RmcToken = await ethers.getContractFactory("RmcToken")
        const TicketFusion = await ethers.getContractFactory("TicketFusion")
        const TicketInformationController = await ethers.getContractFactory("TicketInformationController")
        const TicketManager = await ethers.getContractFactory("TicketManager")
        const GoldTicketMinter = await ethers.getContractFactory("GoldTicketMinter")
        const MythicTicketMinter = await ethers.getContractFactory("MythicTicketMinter")
        const NormalTicketMinter = await ethers.getContractFactory("NormalTicketMinter")
        const PlatinTicketMinter = await ethers.getContractFactory("PlatinTicketMinter")
        const SuperGoldTicketMinter = await ethers.getContractFactory("SuperGoldTicketMinter")
        const TicketMinterManager = await ethers.getContractFactory("TicketMinterManager")

        feeManager = await FeeManager.deploy()
        lotteryManager = await LotteryManager.deploy()
        lotteryGame = await LotteryGame.deploy()
    
        marketplace = await Marketplace.deploy()
        rmcToken = await RmcToken.deploy("1000000000000000000", 10000)
        ticketFusion = await TicketFusion.deploy()
        ticketInformationController = await TicketInformationController.deploy()
        ticketManager = await TicketManager.deploy()
        goldTicketMinter = await GoldTicketMinter.deploy()
        mythicTicketMinter = await MythicTicketMinter.deploy()
        normalTicketMinter = await NormalTicketMinter.deploy()
        platinTicketMinter = await PlatinTicketMinter.deploy()
        superGoldTicketMinter = await SuperGoldTicketMinter.deploy()
        ticketMinterManager = await TicketMinterManager.deploy("ticketMinter", "name")

        await normalTicketMinter.setAddrLotteryGameContract(lotteryGame.address)
        await lotteryGame.setAddrNormalTicket(normalTicketMinter.address)
        await lotteryGame.setAddrFeeManager(feeManager.address)
        await feeManager.setAddrGame(lotteryGame.address, marketplace.address)
        await feeManager.setAddrTicketContract(
            normalTicketMinter.address, 
            goldTicketMinter.address, 
            superGoldTicketMinter.address, 
            platinTicketMinter.address, 
            mythicTicketMinter.address
        )


        return { 
            owner, 
            feeManager,
            lotteryManager,
            lotteryGame,
            marketplace,
            rmcToken,
            ticketFusion,
            ticketInformationController,
            ticketManager,
            goldTicketMinter,
            mythicTicketMinter,
            platinTicketMinter,
            superGoldTicketMinter,
            ticketMinterManager,
            normalTicketMinter
        }
    })

    describe("Deployment", async function () {
        it("Should initialize NFT URIs, featuresByDay and nbStep", async function () {            
            await normalTicketMinter.initializeBoxOffice(
                Object.keys(hashes), 
                Object.values(hashes),
                featuresByDay
            );
            await lotteryGame.setNbStep(3)

            const keyHashes = Object.keys(hashes)

            for(let i = 0; i < keyHashes.length; i++) {
                //on vérifie que chaque hash est bien associé à la bonne combinaison
                expect(await normalTicketMinter.getUriFeatures(keyHashes[i])).to.equal(hashes[keyHashes[i]])
                //on vérifie que chaque hash est bien considéré comme valide
                expect(await normalTicketMinter.isValidUri(keyHashes[i])).to.equal(true)
            }
        });

        it("Should buy tickets", async function () { 

            for(let i = 0; i < users.length; i++) {
                let boughtHashes;

                const keyHashes = Object.keys(hashes)

                //il y a 19 users pour 27 hashes
                //donc le dernier user va acheter 9 hashes au lieu de 1
                //pour compléter
                if(i === users.length - 1) {
                    boughtHashes = keyHashes.slice(i, keyHashes.length)
                    tokenIds[i] = []
                    for(let j = i; j < keyHashes.length; j++) {
                        //on concatène la combinaison avec 01, le lottery ID
                        tokenIds[i].push(parseInt(Object.values(hashes)[j]+"01"))
                    }
                } else {
                    boughtHashes = [keyHashes[i]] 
                    tokenIds[i] = [parseInt(Object.values(hashes)[i]+"01")]
                }

                const tx = await lotteryGame.connect(users[i]).buyTicket(
                    boughtHashes,
                {value: ethers.utils.parseEther("2.5").mul(boughtHashes.length)})
                
                const receipt = await tx.wait()
                const gasUsed = BigInt(receipt.cumulativeGasUsed) * BigInt(receipt.effectiveGasPrice);

                //on vérifie la nouvelle balance de l'utilisateur
                expect(await users[i].getBalance()).to.equal(
                    ethers.utils.parseEther("10000")
                    .sub(ethers.utils.parseEther("2.5").mul(boughtHashes.length))
                    .sub(gasUsed)
                )
                //on vérifie que l'utilisateur dispose bien du nombre
                //de hashes achetés
                expect(await normalTicketMinter.balanceOf(users[i].address)).to.equal(boughtHashes.length)
            }

            // await new Promise((resolve) => {
            //     normalTicketMinter.once("ItemMinted", (setter, ItemMinted, event) => {
            //         tokenIds[i] = tokenIds[i] ? [...tokenIds[i], setter] : [setter]
            //         resolve()
            //     })
            // })
        });
    });

    describe("Game Period", function() {
        it("Cycle should be started", async function() {
            expect(await lotteryGame.isCycleStarted()).to.equal(true)
            expect(await lotteryGame.isStartLotteryFunc()).to.equal(true)
        })
        
        it("Go to nextDay n days should end game period", async function () {
            const [ user2 ] = await ethers.getSigners()

            function sleep(time) {
                return new Promise(resolve => {
                    setTimeout(() => {
                        resolve()
                    }, time)
                });
            }

            for(let i = 0; i < featuresByDay.length; i++) {
                await sleep(1500)
                await lotteryGame.connect(user2).goToNextDay();
            }

            expect(await lotteryGame.getPeriod()).to.equal(1);
            //on vérifie que la combinaison gagnante est bien un nombre
            //composés d'autant de chiffre que de jours + 2 chiffres pour le lotterie ID
            expect(await lotteryGame.getWinningCombination() > 10**(featuresByDay.length+1) + 1)
            .to.equal(true)
        });
    })

    describe("Claim Period", function() {
        it("Claim period should be started", async function() {
            expect(await lotteryGame.getPeriod()).to.equal(1)
        })

        it("Winner should be able to claim", async function() {
            const winningCombination = parseInt(
                (await lotteryGame.getWinningCombination()).toString()
            )
            
            for(let i = 0; i < users.length; i++) {
                for(let j = 0; j < tokenIds[i].length; j++) {
                    const tokenId = tokenIds[i][j];
                    if(tokenId == winningCombination) {
                        const oldBalance = await users[i].getBalance()
                        await lotteryGame.connect(users[i]).claimRewardForWinner()
                        const newBalance = await users[i].getBalance()
                        //on vérifie la nouvelle balance de l'utilisateur
                        expect(Number(newBalance))
                        .to.be.greaterThan(Number(oldBalance))
                    }
                }
            }
        })

        it("Other users shouldn't be able to claim any reward", async function() {
            for(let i = 0; i < users.length; i++) {
                await expect(lotteryGame.connect(users[i]).claimRewardForAll())
                .to.be.revertedWith("ERROR :: You don't have any rewards to claim");
            }
        })
    })

    describe("Market place basics", function() {
        
    })

        // it("Should not buy tickets", async function () {
        //     const { normalTicketMinter, lotteryGame } = await loadFixture(deployContracts);
            
        //     await normalTicketMinter.initializeStrings(hashes);

        //     const [ user1, user2, user3 ] = await ethers.getSigners();

        //     const tx1 = await lotteryGame.connect(user1).buyTicket([hashes[0]]);
        //     const tx2 = await lotteryGame.connect(user2).buyTicket([hashes[0], hashes[1]]);
        //     const tx3 = await lotteryGame.connect(user3).buyTicket([hashes[0], hashes[1], hashes[2]]);

        //     expect(await normalTicketMinter.balanceOf(user1.address)).to.equal(1);
        //     expect(await normalTicketMinter.balanceOf(user2.address)).to.equal(0);
        //     expect(await normalTicketMinter.balanceOf(user3.address)).to.equal(0);
        
        // });

        // it("Should activate StartLottery() function", async function () {
        //     const { normalTicketMinter, lotteryGame } = await loadFixture(deployContracts);
            
        //     await normalTicketMinter.initializeStrings(hashes);

        //     const [ user1, user2, user3 ] = await ethers.getSigners();
        //     hashes.forEach(async (hash) => {
        //         await lotteryGame.connect(user1).buyTicket([hash]);

        //     });            
        //     // console.log("cycleStarted: ", await lotteryGame.isCycleStarted())
        //     // console.log("nbTicketsSold: ", await lotteryGame.getTicketsSold())
        //     // console.log("nbTicketsSalable: ", await lotteryGame.getTicketsSalable())
        //     expect(await lotteryGame.isCycleStarted()).to.equal(true);
        //     expect(await lotteryGame.isStartLotteryFunc()).to.equal(true);
        // });
});