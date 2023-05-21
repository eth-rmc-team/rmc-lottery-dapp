# RMC Games - Lottery

## Requirements

- NVM or NodeJS `v14.17.6`
- Docker `v20.10.8`
- Npm `v1.22.10`

## Local Setup

1. Make sure you have the correct version of NodeJS

```bash
$ nvm install;
```

Following is DEPRECATED
<!-- 2. In dependencies

```bash
$ npm install;
```

3. Compile contract

```bash
$ npm run compile:local; # build client/node.js file
``` -->
End

4. Build and launch docker

```bash
$ docker-compose up -d
```

6. Verify that container is running

```bash
$ docker-compose logs
# Should see an output of wallet addresses and private keys
```

7. Enter inside docker container

```bash
$ docker exec -it rmc-lottery-dapp_app_1 sh;
```

8. Compile local contract within Docker

```bash
$ yarn compile:local;
```

9. Deploy local contract within Docker with custom task

```bash
$ yarn deploy:local;
```

10. Create `.env` file used for out `client/node.js` file

```bash
# Ugly version
$ echo "CONTRACT_ADDRESS=$(docker exec -it myhd cat .contract)\nWALLET_ADDRESS=$(docker exec -it myhd cat .wallet;)" > .env.test;

# Prettier version
# export CONTRACT_ADDRESS="$(docker exec -it myhd cat .contract)";
# export WALLET_ADDRESS="$(docker exec -it myhd cat .wallet)";
# echo "CONTRACT_ADDRESS=$CONTRACT_ADDRESS\nWALLET_ADDRESS=$WALLET_ADDRESS" > .env;
# unset CONTRACT_ADDRESS;
# unset WALLET_ADDRESS;
```

11. Run our client

```bash
$ node client/node.js;
```

Voilà!

Don't forget to delete your container when you're done.

```bash
$ docker-compose stop;
```

## Running Tests

Main test files can be found in `/test`.

```bash
$ npm run test:local;
```

## Useful commands

Show local accounts addresses & balances (from inside docker container)

```bash

```bash
$ yarn accounts:local;
```
# Lottery Game from Royal Mountain's Club

DESCRIPTION OF THE PROJECT

This project is lottery game using NFTs as entry tickets.
Each ticket has a set of 5 caracteristics and there is no 2 NFTs with the same 5 in a row.

Every day, one winning caracteristic is randomly picked via Chainlink, until fifth day. Thus, the winning NFT is known and players (winner and "Special Tickets" holders) can claim their rewards.

At any time, players can trade their tickets on our "Marketplace". A fee (5%) is applied on each trade to pay holders of "Special Tickets" and the protocol.

People can buy and/or create "Gold Ticket" using our "Fusion". However, "Fusion" is accessible only during a specific period of time (not during a running lottery).

DESCRIPTION OF OUR SMART-CONTRACTS

LotteryManager.sol: contract mainly used by protocol setting principal variable ruling a lottery game.

LotteryGame.sol: contract used by players to buy ticket, randomly pick a caracteristic, and claim reward.

Marketplace.sol: contract used by players to trade their tickets.

FeeManager.sol: contract centralizing the value and transfer of the fee from Marketplace.sol, and also calculating the reward claimable on LotteryGame.sol

TicketManager.sol: contract centralizing information about tickets (type, contract address, owner, price etc).

TicketFusion.sol: contract used by players to merge "Normal Tickets" and "Gold Tickets". Communicate with "TicketMinter.sol" afterwards.



