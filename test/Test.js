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
        normalTicketMinter.setDiscoveryService(discoveryService.address);

        normalTicketMinter.addToWhitelist(lotteryGame.address);

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
            await lotteryGame.setTotalSteps(3)

            const keyHashes = Object.keys(hashes)

            for(let i = 0; i < keyHashes.length; i++) {
                //on vérifie que chaque hash est bien associé à la bonne combinaison
                expect(await lotteryGame.getUriFeatures(keyHashes[i])).to.equal(hashes[keyHashes[i]])
                //on vérifie que chaque hash est bien considéré comme valide
                expect(await normalTicketMinter.isValidUri(keyHashes[i])).to.equal(true)
            }
        });
    });
});