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



