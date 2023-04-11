contract Lottery {

    // balance des fees
    uint numberOfTicketsSalable;
    uint ticketSolds;
    uint lotteryId;
    float partDuVainqueur;
    float partDuProtocole;
    float partDesAvantages;

    uint tokenBuyReward;


    uint[] combinationPicked;

    bool chasePeriod;
    bool cycleStarted;
    bool winnerClaimed;

    uint ticketFusionClaimedGains;

    currentDay;
    totalDay;

    mapping (address => bool) public claimedNftAddress;

    constructor() {
        ticketSolds = 0;
        lotteryId = 0;
        totalDay = 5;
        currentDay = 0;
        chasePeriod = false;
        ticketFusionClaimedGains = 0;
    }
 

    function isChasePeriod() {
        return chasePeriod;
    }

    //prévoir une fonction permettant de récupérer les NFTs encore en jeu
    //pour un filtre de marketplace


    function setPartDuVainqueur(newValue) isOwner {
        require(newValue > 0.20)
    }

    function setPartDesAvantages(newValue) isOwner {
        require(newValue > 0.20)
    }

    function setPartDuProtocole(newValue) isOwner {
        require(newValue < 0.33)
    }

    function setPriceTicket() isOwner {}

    function totalDay() isOwner {
        // le cycle ne doit pas avoir commencer
    }

    function buyTicket() {
        // mint ticket
        ticketSolds++;

        // mint RMC reward

        //si tous les tickets sont vendus, on démarre le cycle.
        if (ticketSolds == numberOfTicketsSalable) {
            startCycle();
        }
    }

    function startCycle() {
        // on vérifie qu'on est au premier jour
        // on vérifie qu'on est pas en période de chasse
        // on vérifie qu'on a assez de tickets vendus
        lotteryId++;
        claimedNftAddress = [];
        cycleStarted = true;
        ticketFusionClaimedGains = 0;
        nextDay();
    }


    function setTokenBuyReward() {
        // mettre à jour le nombre de RMC token en reward pour un achat de ticket
    }


    //trigger toutes les 24h
    function nextDay() {
        // on vérifie si cycleStarted
        // on vérifie si currentDay == totalDay
        // si oui, on appelle endCycle()
        
        // on pick un nombre aléatoire pour désigner une caractéristique
        // uint[] range = TicketManager.getCaracteristicsForADay();
        // uint intPicked = randomAvecChainlink();
        // combinationPicked.push(intPicked);
        // incrementer currentDay

        nextDay()
    }
    
    function endCycle() {
        // définir le vainqueur
        cycleStarted = false;
    }

    function claimWinner() {
        // require cycleStarted == false ET currentDay == totalDay
        // require winnerClaimed == false

        // on vérifie si le NFT donné est le NFT gagant
        // combinationPicked == TicketManager.getCaracteristicsForAnNft()

        // si gagnant
        // burn le NFT
        // mint Mythic NFT
        // transferer les gains au gagnant en utilisant computeGainsWinner()

        TicketFusion.triggerClaim();

        startAvantageClaims();
    }

    function ticketFusionTransferAdvantage() {
        //check if msg.sender == TicketFusion
        //check if ticketFusionClaimedGains > 0

        ticketFusionClaimedGains += msg.value;
    }

    // receive

    function claimAdvantageGains(uint[] tokens) {
        // tokens.address = msg.sender
        // uint countGold = 0
        // uint countSuperGold = 0
        // uint countPlatinum = 0
        // uint countSuperPlatinum = 0
        // uint countMythic = 0

        //foreach(tokens) {
            // require token address not int claimedNftAddress
            // require token is owned by msg.sender

            // claimedNftAddress[token.address] = true;

            // if (token == TicketManager.isGold(token)) {
            //     countGold++;
            // } etc pour les autres types

            // pour le cas du mythic, on vérifie que le NFT 
            // n'est pas le gagnant du cycle courant 
            // en comparant l'id de la loterie actuelle avec
            // TicketManager.getAttachedLotteryForNft(token)
        //}

        // goldGains = computeGoldGains(countGold)
        // superGoldGains = computeSuperGoldGains(countSuperGold)
        // platinumGains = computePlatinumGains(countPlatinum)
        // mythicGains = computeMythicGains(countMythic)^

        // transferer les gains
        // goldGains + superGoldGains + platinumGains + mythicGains
        // vers le msg.sender
    }

    function claimOwner() {
        //computeGainsProtocol()
    }

    function computeGainsWinner() {
        //calculer la récompense du vainqueur.
        //partDuVainque * computeTicketRevenues()
    }

    function computeGainsProtocol() {
        //calculer la part du protocole.
        //partDuProtocole * computeTicketRevenues()

        // 1% de computeFeesMarketPlace()

        // il réclame ses gains pour les golds détenus
        // numberOfSuperGold * 20% de ticketFusionClaimedGains / totalSupplySuperGold
    }

    function computeGoldGains(uint numberOfGold) {
        // calculer la part pour les avantages
        // partAvantageGold * computeTicketRevenues() * numberOfGold 
        //        / TicketManager.getGoldTotalSupply()

        // 7% de computeTicketRevenues()
        // 1% de computeFeesMarketPlace()
    }

    function computeSuperGoldGains(uint numberOfSuperGold) {
        // calculer la part pour les avantages
        // partAvantageGold * computeTicketRevenues() * numberOfGold 
        //        / TicketManager.getSuperGoldTotalSupply()

        // 7% de computeTicketRevenues()
        // 1% de computeFeesMarketPlace()
        // numberOfSuperGold * 80% de ticketFusionClaimedGains / totalSupplySuperGold
    }

    function computePlatinumGains(uint numberOfPlatinum) {
        // 5% de computeTicketRevenues()
        // 1% de computeFeesMarketPlace()
    }

    function computeMythicGains(uint numberOfMythic) {
        // 3% de computeTicketRevenues()
    }

    function computeGainsAdvantages() {
        //calculer la part pour les avantages
        //partDesAvantages * computeTicketRevenues()
    }

    //offset = ce qui il y a dans la balance du contrat avant le démarrage du cycle

    function computeFeesMarketPlace() {
        //offset = montant de départ de la balance pour le cycle
        //revenus par les échanges de la marketplace.
        //balance - computeTicketRevenues() - offset - ticketFusionClaimedGains
    }

    function computeTicketRevenues() {
        // revenus par l'achat de tickets.
        // ticketRevenu = (ticketSolds * prixTicket)
    }
}