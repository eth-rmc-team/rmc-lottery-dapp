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


describe("Lottery test", function () {
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
        goldenLotteryGame = await (await ethers.getContractFactory("Season1GoldenLottery")).deploy()
        silverLotteryGame = await (await ethers.getContractFactory("Season1SilverLottery")).deploy()
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
        discoveryService.setGoldenLotteryAddr(goldenLotteryGame.address)
        discoveryService.setFusionHandlerAddr(ticketFusion.address);
        discoveryService.setRmcMarketplaceAddr(marketPlace.address);
        discoveryService.setTicketRegistryAddr(ticketRegistry.address);

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

        // Configure whitelists
        normalTicketMinter.addToWhitelist(lotteryGame.address);
        normalTicketMinter.addToWhitelist(ticketFusion.address);
        normalTicketMinter.addToWhitelist(marketPlace.address);
        normalTicketMinter.addToWhitelist(silverLotteryGame.address);
        goldTicketMinter.addToWhitelist(ticketFusion.address);
        goldTicketMinter.addToWhitelist(lotteryGame.address);
        goldTicketMinter.addToWhitelist(goldenLotteryGame.address);
        goldTicketMinter.addToWhitelist(silverLotteryGame.address);
        superGoldTicketMinter.addToWhitelist(ticketFusion.address);
        superGoldTicketMinter.addToWhitelist(lotteryGame.address);
        mythicTicketMinter.addToWhitelist(lotteryGame.address);
        mythicTicketMinter.addToWhitelist(ticketFusion.address);
        platinTicketMinter.addToWhitelist(lotteryGame.address);
        platinTicketMinter.addToWhitelist(silverLotteryGame.address);
        platinTicketMinter.addToWhitelist(owner.address);
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
        it("Should receive Platin tickets for Protocol", async function () {
            let oldBalanceOfProtocol = Number(await platinTicketMinter.balanceOf(owner.address))
            await platinTicketMinter.connect(owner).mintForProtocol()

            let newBalanceOfProtocol = Number(await platinTicketMinter.balanceOf(owner.address))

            expect(oldBalanceOfProtocol).to.equal(0)
            expect(newBalanceOfProtocol).to.equal(6)

        })
        it("Should initialize NFT URIs, featuresByDay, minimumTimeStep and nbStep", async function () {
            await lotteryGame.initializeBoxOffice(
                Object.keys(hashes),
                Object.values(hashes),
                featuresByDay,
                8
            )
            await lotteryGame.setTicketPrice("250000000000000000000")
            await lotteryGame.setTotalSteps(3)
            await lotteryGame.setMinimumTimeStep(1)

            const keyHashes = Object.keys(hashes)

            for (let i = 0; i < keyHashes.length; i++) {
                //on vérifie que chaque hash est bien associé à la bonne combinaison
                expect(await normalTicketMinter.getUriFeatures(keyHashes[i])).to.equal(hashes[keyHashes[i]])
                //on vérifie que chaque hash est bien considéré comme valide
                expect(await normalTicketMinter.isValidUri(keyHashes[i])).to.equal(true)
            }

            expect(Number(await lotteryGame.getMinimumTimeStep())).to.equal(1)
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
                        expect(Number(await mythicTicketMinter.balanceOf(mythicHolder.address))).to.equal(1)
                        expect(Number(newBalanceNormal)).to.equal(oldBalanceNormal - 1)
                    }
                }
            }
        })

        it("Should be able to claim Gold tickets for the seconds", async function () {
            let gold = 0
            for (let i = 0; i < users.length; i++) {
                for (let j = 0; j < tokenIds[i].length; j++) {
                    const tokenId = tokenIds[i][j]

                    await lotteryGame.connect(users[i]).claimGoldTicket(tokenId)
                }
                gold += Number(await goldTicketMinter.balanceOf(users[i].address))
            }

            expect(gold).to.equal(8)
            expect(Number(await goldTicketMinter.balanceOf(lotteryGame.address))).to.equal(0)
            // 9 normal tickets have been burn (1 for the mythic and 8 for the golds)
            expect(Number(await normalTicketMinter.totalSupply())).to.equal(18)
        })

        it("should be able to claim advantages reward", async function () {

            for (let i = 0; i < users.length; i++) {
                let balanceOfGold = Number(await goldTicketMinter.balanceOf(users[i].address))
                let balanceOfMythic = Number(await mythicTicketMinter.balanceOf(users[i].address))
                if (balanceOfGold > 0 || balanceOfMythic > 0) {
                    await lotteryGame.connect(users[i]).claimAdvantagesReward()
                    //console.log("balanceOfGoldTicket", Number(await goldTicketMinter.balanceOf(users[i].address)))
                    //console.log("balanceOfMythicTicket", Number(await mythicTicketMinter.balanceOf(users[i].address)))
                }
            }

        })

        it("Should be able to claim protocol reward", async function () {
            const oldBalanceOfProtocol = Number(await owner.getBalance())
            await lotteryGame.connect(owner).claimProtocolReward()
            const newBalanceOfProtocol = Number(await owner.getBalance())

            expect(newBalanceOfProtocol).to.be.greaterThan(oldBalanceOfProtocol)
        })

        it("Other or already claimed users shouldn't be able to claim any reward", async function () {
            for (let i = 0; i < users.length; i++) {
                let oldBalance = Math.round(Number(await users[i].getBalance()))
                //console.log("user", i, "balance", oldBalance)
                await lotteryGame.connect(users[i]).claimAdvantagesReward()
                let newBalance = Math.round(Number(await users[i].getBalance()))
                expect(newBalance).to.be.lessThan(oldBalance)
            }
        })

        it("Should go to CHASE period", async function () {
            await lotteryGame.connect(owner).endClaimPeriod()
            expect(await lotteryGame.getCurrentPeriod()).to.equal(4)
        })
    })

})