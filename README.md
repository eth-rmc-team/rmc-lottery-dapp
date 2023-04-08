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

2. In dependencies

```bash
$ npm install;
```

3. Compile contract

```bash
$ npm run compile:local; # build client/node.js file
```

4. Build and launch docker

```bash
$ docker-compose up -d
```

6. Verify that container is running

```bash
$ docker-compose logs;
# Should see an output of wallet addresses and private keys
```

7. Enter inside docker container

```bash
$ docker exec -it rmc-lottery-dapp_app_1 sh;
```

7. Compile local contract within Docker

```bash
$ yarn compile:local;
```

8. Deploy local contract within Docker with custom task

```bash
$ yarn deploy:local;
```

9. Create `.env` file used for out `client/node.js` file

```bash
# Ugly version
$ echo "CONTRACT_ADDRESS=$(docker exec -it myhd cat .contract)\nWALLET_ADDRESS=$(docker exec -it myhd cat .wallet;)" > .env;

# Prettier version
# export CONTRACT_ADDRESS="$(docker exec -it myhd cat .contract)";
# export WALLET_ADDRESS="$(docker exec -it myhd cat .wallet)";
# echo "CONTRACT_ADDRESS=$CONTRACT_ADDRESS\nWALLET_ADDRESS=$WALLET_ADDRESS" > .env;
# unset CONTRACT_ADDRESS;
# unset WALLET_ADDRESS;
```

10. Run our client

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
