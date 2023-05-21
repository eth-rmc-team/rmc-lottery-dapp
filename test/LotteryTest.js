const { use, expect } = require('chai');
const { ethers, waffle, network } = require('hardhat');
const { loadFixture } = require('@nomicfoundation/hardhat-network-helpers');

const fs = require("fs");

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

const featuresByDay = [3, 3, 3]


describe("Lottery test", function () {
    let normalTicketMinter;
    let lotteryGame;
    let feeManager;
    let lotteryManager;
    let marketplace;
    let rmcToken;
    let ticketFusion;
    let ticketInformationController;
    let ticketManager;
    let goldTicketMinter;
    let mythicTicketMinter;
    let platinTicketMinter;
    let superGoldTicketMinter;
    let ticketMinterManager;
    
    let users;
    let owner;

    before(async function deployContracts() {
        const u = await ethers.getSigners();
        users = u.slice(1);
        owner = u[0];

        const FeeManager = await ethers.getContractFactory("FeeManager");
        const LotteryGame = await ethers.getContractFactory("LotteryGame");
        const LotteryManager = await ethers.getContractFactory("LotteryManager");
        const Marketplace = await ethers.getContractFactory("Marketplace");
        const RmcToken = await ethers.getContractFactory("RmcToken");
        const TicketFusion = await ethers.getContractFactory("TicketFusion");
        const TicketInformationController = await ethers.getContractFactory("TicketInformationController");
        const TicketManager = await ethers.getContractFactory("TicketManager");
        const GoldTicketMinter = await ethers.getContractFactory("GoldTicketMinter");
        const MythicTicketMinter = await ethers.getContractFactory("MythicTicketMinter");
        const NormalTicketMinter = await ethers.getContractFactory("NormalTicketMinter");
        const PlatinTicketMinter = await ethers.getContractFactory("PlatinTicketMinter");
        const SuperGoldTicketMinter = await ethers.getContractFactory("SuperGoldTicketMinter");
        const TicketMinterManager = await ethers.getContractFactory("TicketMinterManager");

        feeManager = await FeeManager.deploy();
        lotteryManager = await LotteryManager.deploy();
        lotteryGame = await LotteryGame.deploy();
    
        marketplace = await Marketplace.deploy();
        rmcToken = await RmcToken.deploy("1000000000000000000", 10000);
        ticketFusion = await TicketFusion.deploy();
        ticketInformationController = await TicketInformationController.deploy();
        ticketManager = await TicketManager.deploy();
        goldTicketMinter = await GoldTicketMinter.deploy();
        mythicTicketMinter = await MythicTicketMinter.deploy();
        normalTicketMinter = await NormalTicketMinter.deploy();
        platinTicketMinter = await PlatinTicketMinter.deploy();
        superGoldTicketMinter = await SuperGoldTicketMinter.deploy();
        ticketMinterManager = await TicketMinterManager.deploy("ticketMinter", "name      ");

        await normalTicketMinter.setAddrLotteryGameContract(lotteryGame.address);
        await lotteryGame.setAddrNormalTicket(normalTicketMinter.address);
        await lotteryGame.setAddrFeeManager(feeManager.address);
        await feeManager.setAddrGame(lotteryGame.address, marketplace.address);

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
        };
    })

    describe("Deployment", async function () {
        it("Should initialize NFT URIs, featuresByDay and nbStep", async function () {            
            await normalTicketMinter.initializeBoxOffice(
                Object.keys(hashes), 
                Object.values(hashes),
                featuresByDay
            );
            await lotteryGame.setNbStep(3);

            for(let i = 0; i < hashes.length; i++) {
                expect(await normalTicketMinter.getUriFeatures(hashes[i])).to.equal(features[i]);
                expect(await normalTicketMinter.isValidUri(hashes[i])).to.equal(true);
            }
        });

        it("Should buy tickets", async function () { 
            for(let i = 0; i < Object.keys(hashes).length; i++) {
                await lotteryGame.connect(users[i < users.length ? i : 0]).buyTicket([
                    Object.keys(hashes)[i]
                ]);
            }
            for(let i = 0; i < users.length; i++) {
                expect(await normalTicketMinter.balanceOf(users[i].address)).to.equal(
                    i == 0 ? 9 : 1
                );
            }
        });
    });

    describe("Game Period", function() {
        it("Cycle should be started", async function() {
            expect(await lotteryGame.isCycleStarted()).to.equal(true);
            expect(await lotteryGame.isStartLotteryFunc()).to.equal(true);
        })
        
        it("Go to nextDay n days should end game period", async function () {
            const [ user2 ] = await ethers.getSigners();

            function sleep(time) {
                return new Promise(resolve => {
                    setTimeout(() => {
                        resolve();
                    }, time);
                });
            }

            for(let i = 0; i < featuresByDay.length; i++) {
                await sleep(1500)
                await lotteryGame.connect(user2).goToNextDay();
            }

            expect(await lotteryGame.getPeriod()).to.equal(1);
            expect(await lotteryGame.getWinningCombination() > 10**(featuresByDay.length+1) + 1)
            .to.equal(true)
        });
    })

    describe("Claim Period", function() {
        it("Claim period should be started", async function() {
            expect(await lotteryGame.getPeriod()).to.equal(1);
        })
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