const { expect, use } = require('chai')
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


describe("Marketplace test", function () {
    let lotteryGame
    let goldenLotteryGame
    let silverLotteryGame
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
    let claimizer

    let users
    let tokenIds = []
    let owner

    before(async function deployContracts() {
        const u = await ethers.getSigners()
        //on considère le premier utiliateur comme le owner
        owner = u[0]
        //le reste comme des utilisateurs lambdas
        users = u.slice(1)

        const calculation = await (await ethers.getContractFactory("Calculation")).deploy()

        lotteryGame = await (await ethers.getContractFactory("Season1LotteryGame")).deploy()
        goldenLotteryGame = await (await ethers.getContractFactory("Season1GoldenLottery")).deploy()
        silverLotteryGame = await (await ethers.getContractFactory("Season1SilverLottery")).deploy()
        discoveryService = await (await ethers.getContractFactory("DiscoveryService")).deploy(lotteryGame.address)
        marketPlace = await (await ethers.getContractFactory("Marketplace")).deploy()
        prizepoolDispatcher = await (await ethers.getContractFactory("PrizepoolDispatcher", {
            libraries: {
                Calculation: calculation.address,
            },
        })).deploy()
        rmcToken = await (await ethers.getContractFactory("RmcToken")).deploy("1000000000000000000", 10000)
        ticketFusion = await (await ethers.getContractFactory("TicketFusion")).deploy()
        ticketRegistry = await (await ethers.getContractFactory("TicketRegistry")).deploy()
        goldTicketMinter = await (await ethers.getContractFactory("GoldTicketMinter")).deploy()
        mythicTicketMinter = await (await ethers.getContractFactory("MythicTicketMinter")).deploy()
        platinTicketMinter = await (await ethers.getContractFactory("PlatinTicketMinter")).deploy()
        superGoldTicketMinter = await (await ethers.getContractFactory("SuperGoldTicketMinter")).deploy()
        normalTicketMinter = await (await ethers.getContractFactory("NormalTicketMinter")).deploy()
        claimizer = await (await ethers.getContractFactory("Claimizer", {
            libraries: {
                Calculation: calculation.address,
            },
        })).deploy(discoveryService.address)

        //DiscoveryService initialization
        discoveryService.setFusionHandlerAddr(ticketFusion.address)
        discoveryService.setNormalTicketAddr(normalTicketMinter.address);
        discoveryService.setGoldTicketAddr(goldTicketMinter.address);
        discoveryService.setSuperGoldTicketAddr(superGoldTicketMinter.address);
        discoveryService.setMythicTicketAddr(mythicTicketMinter.address);
        discoveryService.setPlatiniumTicketAddr(platinTicketMinter.address);
        discoveryService.setPrizepoolDispatcherAddr(prizepoolDispatcher.address);
        discoveryService.setLotteryGameAddr(lotteryGame.address);
        discoveryService.setGoldenLotteryAddr(goldenLotteryGame.address)
        discoveryService.setFusionHandlerAddr(ticketFusion.address);
        discoveryService.setRmcMarketplaceAddr(marketPlace.address);
        discoveryService.setTicketRegistryAddr(ticketRegistry.address);
        discoveryService.setClaimizerAddr(claimizer.address);

        lotteryGame.setDiscoveryService(discoveryService.address);
        goldenLotteryGame.setDiscoveryService(discoveryService.address);
        silverLotteryGame.setDiscoveryService(discoveryService.address);
        marketPlace.setDiscoveryService(discoveryService.address);
        prizepoolDispatcher.setDiscoveryService(discoveryService.address);
        ticketFusion.setDiscoveryService(discoveryService.address);
        normalTicketMinter.setDiscoveryService(discoveryService.address);
        goldTicketMinter.setDiscoveryService(discoveryService.address);
        superGoldTicketMinter.setDiscoveryService(discoveryService.address);
        mythicTicketMinter.setDiscoveryService(discoveryService.address);
        platinTicketMinter.setDiscoveryService(discoveryService.address);
        claimizer.setDiscoveryService(discoveryService.address);

        // Configure whitelists
        normalTicketMinter.addToWhitelist(lotteryGame.address);
        normalTicketMinter.addToWhitelist(ticketFusion.address);
        normalTicketMinter.addToWhitelist(marketPlace.address);
        normalTicketMinter.addToWhitelist(silverLotteryGame.address);
        normalTicketMinter.addToWhitelist(claimizer.address)
        goldTicketMinter.addToWhitelist(ticketFusion.address);
        goldTicketMinter.addToWhitelist(lotteryGame.address);
        goldTicketMinter.addToWhitelist(goldenLotteryGame.address);
        goldTicketMinter.addToWhitelist(silverLotteryGame.address);
        goldTicketMinter.addToWhitelist(claimizer.address)
        superGoldTicketMinter.addToWhitelist(ticketFusion.address);
        superGoldTicketMinter.addToWhitelist(lotteryGame.address);
        mythicTicketMinter.addToWhitelist(lotteryGame.address);
        mythicTicketMinter.addToWhitelist(ticketFusion.address);
        platinTicketMinter.addToWhitelist(lotteryGame.address);
        platinTicketMinter.addToWhitelist(silverLotteryGame.address);
        platinTicketMinter.addToWhitelist(owner.address);
        prizepoolDispatcher.addToWhitelist(claimizer.address);
        ticketRegistry.addToWhitelist(normalTicketMinter.address);
        ticketRegistry.addToWhitelist(goldTicketMinter.address);
        ticketRegistry.addToWhitelist(superGoldTicketMinter.address);
        ticketRegistry.addToWhitelist(mythicTicketMinter.address);
        ticketRegistry.addToWhitelist(platinTicketMinter.address);
        ticketRegistry.addToWhitelist(marketPlace.address);
        marketPlace.addToWhitelist(lotteryGame.address);
        claimizer.addToWhitelist(lotteryGame.address);

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
            normalTicketMinter,
            claimizer
        }
    })

    describe("Deployment", async function () {
        it("Should receive Platin tickets for Protocol", async function () {
            let oldBalanceOfProtocol = Number(await platinTicketMinter.balanceOf(owner.address))
            await platinTicketMinter.connect(owner).mintForProtocol()

            let newBalanceOfProtocol = Number(await platinTicketMinter.balanceOf(owner.address))

            expect(oldBalanceOfProtocol).to.equal(0)
            expect(newBalanceOfProtocol).to.equal(6)

        })
        it("Should initialize NFT URIs, featuresByDay and nbStep", async function () {
            await lotteryGame.initializeBoxOffice(
                Object.keys(hashes),
                Object.values(hashes),
                featuresByDay,
                8
            )
            await lotteryGame.setTicketPrice("250000000000000000000")
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

        it("Should set the gold tickets for the seconds", async function () {
            let numberOfGoldTickets = Number(await goldTicketMinter.balanceOf(lotteryGame.address))
            expect(numberOfGoldTickets).to.equal(8)
            expect(Number(await goldTicketMinter.totalSupply())).to.equal(numberOfGoldTickets)
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

        it("Ticket shouldn't be on sale", async function () {
            let ticketInfoU0 = await ticketRegistry.getTicketState(normalTicketMinter.address, tokenIds[0][0])
            expect(ticketInfoU0.ticketOwner).to.equal(users[0].address)
            expect(ticketInfoU0.dealState).to.equal(0)
            expect(ticketInfoU0.dealPrice).to.equal(0)

        })

        it("User should be able to create a deal", async function () {
            let balanceBeforPutOnTrade = Number(await normalTicketMinter.balanceOf(users[0].address))
            await normalTicketMinter.connect(users[0]).setApprovalForAll(marketPlace.address, true)
            await marketPlace.connect(users[0]).putNftOnSale(
                normalTicketMinter.address,
                tokenIds[0][0],
                "5000000000000000000"
            );
            let balanceAfterPutOnTrade = Number(await normalTicketMinter.balanceOf(users[0].address))
            expect(balanceAfterPutOnTrade).to.equal(balanceBeforPutOnTrade - 1)

            let ticketInfoU0 = await ticketRegistry.getTicketState(normalTicketMinter.address, tokenIds[0][0])
            expect(ticketInfoU0.ticketOwner).to.equal(users[0].address)
            expect(ticketInfoU0.dealState).to.equal(1)
            expect(ticketInfoU0.dealPrice).to.equal(BigInt(5000000000000000000 * 1.3))

            await normalTicketMinter.connect(users[1]).setApprovalForAll(marketPlace.address, true)
            await marketPlace.connect(users[1]).putNftOnSale(
                normalTicketMinter.address,
                tokenIds[1][0],
                "4000000000000000000"
            );

            let ticketInfoU1 = await ticketRegistry.getTicketState(normalTicketMinter.address, tokenIds[1][0])
            expect(ticketInfoU1.ticketOwner).to.equal(users[1].address)
            expect(ticketInfoU1.dealState).to.equal(1)
            expect(ticketInfoU1.dealPrice).to.equal(BigInt(4000000000000000000 * 1.3))

        })

        it("Should change the price of a deal", async function () {
            await marketPlace.connect(users[0]).changeNftPriceOnSale(normalTicketMinter.address, tokenIds[0][0], "4000000000000000000")
            ticketInfo = await ticketRegistry.getTicketState(normalTicketMinter.address, tokenIds[0][0])
            // price with 30% fees
            let price = 4000000000000000000 * 1.3
            expect(ticketInfo.ticketOwner).to.equal(users[0].address)
            expect(ticketInfo.dealState).to.equal(1)
            expect(ticketInfo.dealPrice).to.equal(BigInt(price))
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

            let ticketInfo = await ticketRegistry.getTicketState(normalTicketMinter.address, tokenIds[0][0])
            expect(ticketInfo.ticketOwner).to.equal(users[1].address)
            expect(ticketInfo.dealState).to.equal(0)
            expect(ticketInfo.dealPrice).to.equal(0)

        })

        it("Should be able to remove a deal", async function () {
            let balanceBeforeRemoveOnTrade = Number(await normalTicketMinter.balanceOf(users[1].address))
            await expect(marketPlace.connect(users[2]).removeSalesNft(
                normalTicketMinter.address,
                tokenIds[1][0]
            )).to.be.revertedWith("ERROR :: Not owner of this token")

            await marketPlace.connect(users[1]).removeSalesNft(
                normalTicketMinter.address,
                tokenIds[1][0]
            );
            let balanceAfterRemoveOnTrade = Number(await normalTicketMinter.balanceOf(users[1].address))
            expect(balanceAfterRemoveOnTrade).to.equal(balanceBeforeRemoveOnTrade + 1)

            let ticketInfo = await ticketRegistry.getTicketState(normalTicketMinter.address, tokenIds[1][0])
            expect(ticketInfo.ticketOwner).to.equal(users[1].address)
            expect(ticketInfo.dealState).to.equal(0)
            expect(ticketInfo.dealPrice).to.equal(0)

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

    })

})