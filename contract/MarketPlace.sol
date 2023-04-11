contract MarketPlace {
    // nft address => owner address
    mapping (address => address) public NftOwners;
    mapping (address => uint) public NftPrices;

    uint public fees;

    function setFees(uint newValue) onlyOwner {
        // permet de modifier les frais du marketplace
        // les frais doivent être supérieurs à 0
        // les frais doivent être inférieurs à 10% pour la confiance
    }

    function buyNFT(address NFT) {
        // permet d'acheter un NFT
        // le NFT doit être en vente
        // le prix doit être supérieur à 0
        // le vendeur doit être différent de l'acheteur
        // on vérifie que le msg.sender a assez de fonds
        // on transfère le NFT au msg.sender
        // on transfère les fonds au vendeur
        // on actualise NftOwners
        // on actualise NftPrices

        // on transfère les frais de trade au contrat Lottery
    }

    function setDeal(address NFT, uint price) {
        // permet de mettre en vente un NFT
        // le NFT doit être détenue par le vendeur
        // le prix doit être supérieur à 0
        // on vérifie que le NFT n'est pas déjà en vente
        // Le NFT change temporairement de propriétaire, le marketplace devient proprio 
        // pour lock
        // on actualise NftPrices avec le prix
    }

    function stopDeal(address NFT) {
        // permet de retirer un NFT de la vente
        // le NFT doit être en vente
        // On vérifie avec NftOwners que le msg.sender était propriétaire
        // Le NFT change de propriétaire, msg.sender redevient propriétaire
    }
}