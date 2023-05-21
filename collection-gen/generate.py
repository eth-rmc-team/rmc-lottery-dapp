import base64
import json
from PIL import Image, ImageDraw
import itertools
import argparse
import os
import requests
from dotenv import load_dotenv



load_dotenv()

PINATA_API_KEY = os.environ.get("PINATA_API_KEY")
PINATA_API_SECRET = os.environ.get("PINATA_API_SECRET")
PINATA_JWT = os.environ.get("PINATA_JWT")


output_dir = '../collection'
if not os.path.exists(output_dir):
    os.makedirs(output_dir)


# Fonction pour envoyer les images à Pinata
def send_to_pinata(file_name, api_key, api_secret):

    local_path = f'{output_dir}/{file_name}'

    url = "https://api.pinata.cloud/pinning/pinFileToIPFS"
    headers = {
        "pinata_api_key": api_key,
        "pinata_secret_api_key": api_secret,
    }

    # Ouverture du fichier en mode binaire
    with open(local_path, "rb") as fichier:
        fichier_bytes = fichier.read()

    # Préparation des données de la requête
    fichiers = {"file": (file_name, fichier_bytes)}

    # Envoi de la requête POST avec les fichiers et les en-têtes
    reponse = requests.post(url, headers=headers, files=fichiers)

    # Vérification de la réponse de l'API
    if reponse.status_code == 200:
        return reponse.json()
    else:
        print("Erreur lors de l'envoi du fichier à Pinata.")
        print(reponse.json())
        print("Code d'erreur:", reponse.status_code)


# MAIN

# Analyse des arguments de commande
parser = argparse.ArgumentParser(description='Generate images with colored bands')
parser.add_argument('lottery_id', type=int, help='Lottery ID')
parser.add_argument('nb_bandeaux', type=int, help='Number of bands')
parser.add_argument('couleurs', nargs='+', help='List of colors available for the bands')
args = parser.parse_args()

# ID de la loterie
lottery_id = args.lottery_id

# Nombre de bandeaux
nb_bandeaux = args.nb_bandeaux

# Liste de couleurs disponibles
couleurs = args.couleurs
nb_images = len(list(itertools.product(couleurs, repeat=nb_bandeaux)))

# Créer un dictionnaire pour mapper chaque couleur à un entier positif
couleur_map = {}
for i, couleur in enumerate(couleurs):
    couleur_map[couleur] = i + 1

# Créer une liste pour contenir toutes les URLs
urls = []

# Ensemble pour stocker les combinaisons déjà générées
combinaisons_generees = set()

# Boucle pour générer chaque image
for i, combinaison in enumerate(itertools.product(couleurs, repeat=nb_bandeaux)):
    # Vérifier si la combinaison a déjà été générée
    if combinaison in combinaisons_generees:
        continue
    else:
        combinaisons_generees.add(combinaison)

    # Créer une nouvelle image
    image = Image.new('RGB', (200, 200))

    # Créer une liste des couleurs de chaque bandeau
    couleurs_bandeaux = []

    # Ajouter les bandeaux à l'image
    for j, couleur in enumerate(combinaison):
        couleurs_bandeaux.append(couleur_map[couleur])

        # Calculer les dimensions du bandeau
        largeur_bandeau = image.width // nb_bandeaux
        x0 = j * largeur_bandeau
        x1 = (j + 1) * largeur_bandeau

        # Dessiner le bandeau sur l'image
        draw = ImageDraw.Draw(image)
        draw.rectangle((x0, 0, x1, image.height), fill=couleur)

    # Enregistrer l'image
    image_file_name = f'image_{i}.png'
    image.save(f'{output_dir}/{image_file_name}')
    
    response = send_to_pinata(image_file_name, PINATA_API_KEY, PINATA_API_SECRET)

    # Enregistrer les couleurs de chaque bandeau dans un fichier JSON
    data = {
        'name': f'image_{i}',
        'description': 'Image generee avec des bandeaux de couleurs',
        "image": response["IpfsHash"],
        'attributes': [
            {
                'trait_type': 'caracteristics',
                "value": couleurs_bandeaux
            },
            {
                'trait_type': 'lottery_id',
                "value": lottery_id
            }
        ]
    }

    json_file_name = f'image_{i}.json'

    with open(f'{output_dir}/{json_file_name}', 'w') as f:
        json.dump(data, f)


    response = send_to_pinata(json_file_name, PINATA_API_KEY, PINATA_API_SECRET)

    urls.append(response["IpfsHash"])

result = {
    "couleur_map": couleur_map, 
    'nb_colors': len(couleurs),
    "nb_days": nb_bandeaux,
    "hashes": urls
}


# Enregistrer le dictionnaire dans un fichier JSON
with open(f'{output_dir}/collection_lottery_{lottery_id}.json', 'w') as f:
    json.dump(result, f)


# afficher le nombre total d'images générées
print(f'{len(combinaisons_generees)} images générées.')
