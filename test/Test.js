const { expect } = require('chai')
const { ethers } = require('hardhat')

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
    let lotteryGame
    let discoveryService
    let marketPlace
    let prizepoolDispatcher
    let rmcToken
    let ticketFusion
    let ticketRegistry
    let goldTicketMinter
    let mythicTicketMinter
    let platinTicketMinter
    let superGoldTicketMinter
    let normalTicketMinter

    let users
    let tokenIds = []
    let owner

    before(async function deployContracts() {
        const u = await ethers.getSigners()
        //on considère le premier utiliateur comme le owner
        owner = u[0]
        //le reste comme des utilisateurs lambdas
        users = u.slice(1)

        lotteryGame = await (await ethers.getContractFactory("Season1LotteryGame")).deploy()
        discoveryService = await (await ethers.getContractFactory("DiscoveryService")).deploy()
        marketPlace = await (await ethers.getContractFactory("Marketplace")).deploy()
        prizepoolDispatcher = await (await ethers.getContractFactory("PrizepoolDispatcher")).deploy()
        rmcToken = await (await ethers.getContractFactory("RmcToken")).deploy("1000000000000000000", 10000)
        ticketFusion = await (await ethers.getContractFactory("TicketFusion")).deploy()
        ticketRegistry = await (await ethers.getContractFactory("TicketRegistry")).deploy()
        goldTicketMinter = await (await ethers.getContractFactory("GoldTicketMinter")).deploy()
        mythicTicketMinter = await (await ethers.getContractFactory("MythicTicketMinter")).deploy()
        platinTicketMinter = await (await ethers.getContractFactory("PlatinTicketMinter")).deploy()
        superGoldTicketMinter = await (await ethers.getContractFactory("SuperGoldTicketMinter")).deploy()
        normalTicketMinter = await (await ethers.getContractFactory("NormalTicketMinter")).deploy()

        //DiscoveryService initialization
        discoveryService.setFusionHandlerAddr(ticketFusion.address)
        discoveryService.setNormalTicketAddr(normalTicketMinter.address);
        discoveryService.setGoldTicketAddr(goldTicketMinter.address);
        discoveryService.setSuperGoldTicketAddr(superGoldTicketMinter.address);
        discoveryService.setMythicTicketAddr(mythicTicketMinter.address);
        discoveryService.setPlatiniumTicketAddr(platinTicketMinter.address);
        discoveryService.setPrizepoolDispatcherAddr(prizepoolDispatcher.address);
        discoveryService.setLotteryGameAddr(lotteryGame.address);
        discoveryService.setFusionHandlerAddr(ticketFusion.address);
        discoveryService.setRmcMarketplaceAddr(marketPlace.address);
        discoveryService.setTicketRegistryAddr(ticketRegistry.address);

        lotteryGame.setDiscoveryService(discoveryService.address);
        marketPlace.setDiscoveryService(discoveryService.address);
        prizepoolDispatcher.setDiscoveryService(discoveryService.address);
        ticketFusion.setDiscoveryService(discoveryService.address);
        normalTicketMinter.setDiscoveryService(discoveryService.address);
        goldTicketMinter.setDiscoveryService(discoveryService.address);
        superGoldTicketMinter.setDiscoveryService(discoveryService.address);
        mythicTicketMinter.setDiscoveryService(discoveryService.address);
        platinTicketMinter.setDiscoveryService(discoveryService.address);

        // Configure whitelists
        normalTicketMinter.addToWhitelist(lotteryGame.address);
        normalTicketMinter.addToWhitelist(ticketFusion.address);
        normalTicketMinter.addToWhitelist(marketPlace.address);
        goldTicketMinter.addToWhitelist(ticketFusion.address);
        goldTicketMinter.addToWhitelist(lotteryGame.address);
        superGoldTicketMinter.addToWhitelist(ticketFusion.address);
        superGoldTicketMinter.addToWhitelist(lotteryGame.address);
        mythicTicketMinter.addToWhitelist(lotteryGame.address);
        mythicTicketMinter.addToWhitelist(ticketFusion.address);
        prizepoolDispatcher.addToWhitelist(lotteryGame.address);
        prizepoolDispatcher.addToWhitelist(ticketFusion.address);
        ticketRegistry.addToWhitelist(normalTicketMinter.address);
        ticketRegistry.addToWhitelist(goldTicketMinter.address);
        ticketRegistry.addToWhitelist(superGoldTicketMinter.address);
        ticketRegistry.addToWhitelist(mythicTicketMinter.address);
        ticketRegistry.addToWhitelist(platinTicketMinter.address);
        ticketRegistry.addToWhitelist(marketPlace.address);
        marketPlace.addToWhitelist(lotteryGame.address);



        return {
            owner,
            lotteryGame,
            discoveryService,
            marketPlace,
            prizepoolDispatcher,
            rmcToken,
            ticketFusion,
            ticketRegistry,
            goldTicketMinter,
            mythicTicketMinter,
            platinTicketMinter,
            superGoldTicketMinter,
            normalTicketMinter
        }
    })

    describe("Deployment", async function () {
        it("Should initialize NFT URIs, featuresByDay and nbStep", async function () {
            await lotteryGame.initializeBoxOffice(
                Object.keys(hashes),
                Object.values(hashes),
                featuresByDay
            );
            await lotteryGame.setTicketPrice("250000000000000000000");
            await lotteryGame.setTotalSteps(3)

            const keyHashes = Object.keys(hashes)

            for (let i = 0; i < keyHashes.length; i++) {
                //on vérifie que chaque hash est bien associé à la bonne combinaison
                expect(await normalTicketMinter.getUriFeatures(keyHashes[i])).to.equal(hashes[keyHashes[i]])
                //on vérifie que chaque hash est bien considéré comme valide
                expect(await normalTicketMinter.isValidUri(keyHashes[i])).to.equal(true)
            }
        })

        it("Should reset Cycle", async function () {
            await lotteryGame.resetCycle()

            expect(await lotteryGame.getCurrentPeriod()).to.equal(1)
        })

        it("Should buy tickets", async function () {
            for (let i = 0; i < users.length; i++) {
                let boughtHashes;

                const keyHashes = Object.keys(hashes)

                //il y a 19 users pour 27 hashes
                //donc le dernier user va acheter 9 hashes au lieu de 1
                //pour compléter
                if (i === users.length - 1) {
                    boughtHashes = keyHashes.slice(i, keyHashes.length)
                    tokenIds[i] = []
                    for (let j = i; j < keyHashes.length; j++) {
                        //on concatène la combinaison avec 01, le lottery ID
                        tokenIds[i].push(parseInt(Object.values(hashes)[j] + "01"))
                    }
                } else {
                    boughtHashes = [keyHashes[i]]
                    tokenIds[i] = [parseInt(Object.values(hashes)[i] + "01")]
                }

                const tx = await lotteryGame.connect(users[i]).buyTicket(
                    boughtHashes,
                    { value: ethers.utils.parseEther("250").mul(boughtHashes.length) })

                const receipt = await tx.wait()
                const gasUsed = BigInt(receipt.cumulativeGasUsed) * BigInt(receipt.effectiveGasPrice);

                //on vérifie la nouvelle balance de l'utilisateur
                expect(await users[i].getBalance()).to.equal(
                    ethers.utils.parseEther("10000")
                        .sub(ethers.utils.parseEther("250").mul(boughtHashes.length))
                        .sub(gasUsed)
                )

                //on vérifie que l'utilisateur dispose bien du nombre
                //de hashes achetés
                expect(await normalTicketMinter.balanceOf(users[i].address)).to.equal(boughtHashes.length)

            }
        });

        it("Shouldn't be able to transfer tickets between non-RMC contracts", async function () {
            for (let i = 0; i < users.length; i++) {
                await expect(normalTicketMinter.connect(users[i]).transferFrom(users[i].address, users[0].address, tokenIds[i][0]))
                    .to.be.revertedWith("Only whitelisted addresses allowed");
                /* Todo: erreur du terminal: "is not a function" pourquoi ?
                await expect(normalTicketMinter.connect(users[i]).safeTransferFrom(users[i].address, users[0].address, tokenIds[i][0]))
                    .to.be.revertedWith("Only whitelisted addresses allowed"); */
            }
        });
    })

    describe("Game Period", function () {
        it("We should be in GAME Period", async function () {
            expect(await lotteryGame.getCurrentPeriod()).to.equal(2)
        })

        it("Should have no fees yet to claim by Marketplace", async function () {
            let marketplaceBalance = Number(await marketPlace.connect(owner).getTotalFees())
            expect(marketplaceBalance).to.equal(0)

        })

        it("User should be able to create a deal", async function () {
            let balanceBeforPutOnTrade = Number(await normalTicketMinter.balanceOf(users[0].address))
            await normalTicketMinter.connect(users[0]).setApprovalForAll(marketPlace.address, true)
            await marketPlace.connect(users[0]).putNftOnSale(
                normalTicketMinter.address,
                tokenIds[0][0],
                "4"
            );
            let balanceAfterPutOnTrade = Number(await normalTicketMinter.balanceOf(users[0].address))
            expect(balanceAfterPutOnTrade).to.equal(balanceBeforPutOnTrade - 1)

        })

        it("should buy a ticket on sale", async function () {
            let oldBbalanceOfBuyer = Number(await users[1].getBalance())
            let balanceBeforeTrade = Number(await normalTicketMinter.balanceOf(users[1].address))
            const price = 4000000000000000000 * 1.3
            await marketPlace.connect(users[1]).purchaseNft(
                normalTicketMinter.address,
                tokenIds[0][0],
                { value: ethers.utils.parseUnits(price.toString(), "wei") })
            let balanceAfterTrade = Number(await normalTicketMinter.balanceOf(users[1].address))

            let newBbalanceOfBuyer = Number(await users[1].getBalance())

            expect(balanceAfterTrade).to.equal(balanceBeforeTrade + 1)
            expect(newBbalanceOfBuyer).to.be.lessThan(oldBbalanceOfBuyer)

        })

        it("Should claim fees for user", async function () {
            let oldBalanceOfSeller = Number(await users[0].getBalance())

            await marketPlace.connect(users[0]).claimsFeesForSeller()

            let balanceOfMarketplace = Number(await marketPlace.connect(owner).getTotalFees())
            let newBalanceOfSeller = Number(await users[0].getBalance())

            expect(balanceOfMarketplace).to.equal(1200000000000000000)
            expect(newBalanceOfSeller).to.be.greaterThan(oldBalanceOfSeller)

        })

        it("Go to nextDay n days should end game period and pick winning combinaison", async function () {
            const [user2] = await ethers.getSigners()
            function sleep(time) {
                return new Promise(resolve => {
                    setTimeout(() => {
                        resolve()
                    }, time)
                });
            }

            for (let i = 0; i < featuresByDay.length; i++) {
                await sleep(1500)
                await lotteryGame.connect(user2).nextStep();
            }

            expect(await lotteryGame.getCurrentPeriod()).to.equal(3);
            //on vérifie que la combinaison gagnante est bien un nombre
            //composés d'autant de chiffre que de jours + 2 chiffres pour le lotterie ID
            expect(await lotteryGame.getWinningCombination() > 10 ** (featuresByDay.length + 1) + 1)
                .to.equal(true)
        });
    })

    describe("Claim Period", function () {
        let mythicHolder

        it("Claim period should be started", async function () {
            expect(await lotteryGame.getCurrentPeriod()).to.equal(3)
        })

        it("Should have transfer fees from Marketplace to LotteryGame", async function () {
            let marketplaceBalance = Number(await marketPlace.connect(owner).getTotalFees())
            expect(marketplaceBalance).to.equal(0)
        })

        it("Winner should be able to claim", async function () {
            const winningCombination = parseInt(
                (await lotteryGame.getWinningCombination()).toString()
            )

            for (let i = 0; i < users.length; i++) {
                for (let j = 0; j < tokenIds[i].length; j++) {
                    const tokenId = tokenIds[i][j];
                    if (tokenId == winningCombination) {
                        mythicHolder = users[i]

                        await normalTicketMinter.connect(users[i]).setApprovalForAll(lotteryGame.address, true)
                        const oldBalanceNormal = await normalTicketMinter.balanceOf(users[i].address)
                        const oldBalance = await users[i].getBalance()
                        await lotteryGame.connect(users[i]).claimReward()
                        const newBalance = await users[i].getBalance()
                        const newBalanceNormal = await normalTicketMinter.balanceOf(users[i].address)
                        //on vérifie la nouvelle balance de l'utilisateur
                        expect(Number(newBalance))
                            .to.be.greaterThan(Number(oldBalance))
                        expect(Number(await mythicTicketMinter.balanceOf(users[i].address))).to.equal(1)
                        expect(Number(newBalanceNormal)).to.equal(oldBalanceNormal - 1)
                    }
                }
            }
        })

        it("should be able to claim advantages reward", async function () {
            const oldBalanceOfMythicHolder = Number(await mythicHolder.getBalance())
            await lotteryGame.connect(mythicHolder).claimAdvantagesReward()
            const newBalanceOfMythicHolder = Number(await mythicHolder.getBalance())

            expect(newBalanceOfMythicHolder).to.be.greaterThan(oldBalanceOfMythicHolder)

        })

        it("Should be able to clam protocol reward", async function () {
            const oldBalanceOfProtocol = Number(await owner.getBalance())
            await lotteryGame.connect(owner).claimProtocolReward()
            const newBalanceOfProtocol = Number(await owner.getBalance())

            expect(newBalanceOfProtocol).to.be.greaterThan(oldBalanceOfProtocol)
        })

        it("Other or already claimed users shouldn't be able to claim any reward", async function () {
            for (let i = 0; i < users.length; i++) {
                await expect(lotteryGame.connect(users[i]).claimAdvantagesReward())
                    .to.be.revertedWith("ERROR :: You don't have any rewards to claim");
            }
        })

        it("Should go to CHASE period", async function () {
            await lotteryGame.connect(owner).endClaimPeriod()
            expect(await lotteryGame.getCurrentPeriod()).to.equal(4)
        })
    })

    describe("Fusion", function () {

        let tokenIdToBurn = []

        it("User should fuse 4 normal tickets for 2 Gold", async function () {

            await ticketFusion.connect(owner).setDiscoveryService(discoveryService.address)
            await ticketFusion.connect(owner).setLotteryGame(lotteryGame.address)
            let balanceOfNormalTicketUser18 = Number(await normalTicketMinter.connect(users[18]).balanceOf(users[18].address))

            await ticketFusion.connect(owner).setNormalTicketFusionRequirement(2)
            for (let i = 0; i < balanceOfNormalTicketUser18; i++) {
                tokenIdToBurn[i] = Number(await normalTicketMinter.connect(users[18]).tokenOfOwnerByIndex(users[18].address, i))

            }

            await ticketFusion.connect(users[18]).fusionNormalTickets([tokenIdToBurn[0], tokenIdToBurn[1]])
            await ticketFusion.connect(users[18]).fusionNormalTickets([tokenIdToBurn[2], tokenIdToBurn[3]])

            let newBalanceOfNormalTicketUser18 = Number(await normalTicketMinter.connect(users[18]).balanceOf(users[18].address))

            expect(newBalanceOfNormalTicketUser18).to.equal(balanceOfNormalTicketUser18 - 4)

            let balanceOfGoldTicketUser18 = Number(await goldTicketMinter.connect(users[18]).balanceOf(users[18].address))

            expect(balanceOfGoldTicketUser18).to.equal(2)

        })

        it("Should fuse 2 gold tickets for 1 super gold", async function () {
            await ticketFusion.connect(owner).setGoldTicketFusionRequirement(2)
            let balanceOfGoldTicketUser18 = Number(await goldTicketMinter.connect(users[18]).balanceOf(users[18].address))

            let tokenIdToBurn = []
            for (let i = 0; i < balanceOfGoldTicketUser18; i++) {
                tokenIdToBurn[i] = Number(await goldTicketMinter.connect(users[18]).tokenOfOwnerByIndex(users[18].address, i))
            }

            await ticketFusion.connect(users[18]).fusionGoldTickets([tokenIdToBurn[0], tokenIdToBurn[1]])

            let newBalanceOfGoldTicketUser18 = Number(await goldTicketMinter.connect(users[18]).balanceOf(users[18].address))

            expect(newBalanceOfGoldTicketUser18).to.equal(balanceOfGoldTicketUser18 - 2)

            let balanceOfSuperGoldTicketUser18 = Number(await superGoldTicketMinter.connect(users[18]).balanceOf(users[18].address))

            expect(balanceOfSuperGoldTicketUser18).to.equal(1)
        })

        it("Shouldn't be able to fuse anymore", async function () {
            await lotteryGame.connect(owner).endCycle()

            await expect(ticketFusion.connect(users[18]).fusionNormalTickets([tokenIdToBurn[4], tokenIdToBurn[5]]))
                .to.be.revertedWith("ERROR :: Fusion is not allowed while a lottery is live or ended");


        })
    })

})