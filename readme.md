# Projet de Déverrouillage Biométrique sur FPGA avec Microblaze et Interfaces AXI4-Lite

## Objectif : 
Concevoir et implémenter un système de déverrouillage biométrique utilisant un FPGA sur la carte Nexys Video. Ce système utilise un processeur soft-core Microblaze pour la gestion générale et des interfaces AXI4-Lite pour la communication avec les périphériques.

## Composants du Système :

### Capteur de Proximité : 
Un capteur de proximité est utilisé pour détecter l'approche d'un utilisateur. Ce capteur génère une interruption sur le FPGA lorsqu'une proximité est détectée.

### Caméra et Reconnaissance Faciale :
Une caméra est intégrée au système pour capturer des images faciales. L'algorithme de reconnaissance faciale LBPH est implémenté en VHDL pour analyser les images et identifier les visages autorisés.

### Interfaces de Sortie : 
Un verrou utilisant un électro-aimant est activé pour déverrouiller physiquement une serrure.

### Interface Personnalisée : 
Une interface personnalisée en VHDL est conçue pour faciliter la communication entre le FPGA et les périphériques spécifiques au projet, tels que le capteur de proximité et la caméra.

### Interface Fonctionnant par Interruption : 
Une interface est configurée pour fonctionner par interruption, permettant au système de réagir en temps réel aux événements détectés par le capteur de proximité.

## Fonctionnement : 
Lorsqu'un utilisateur s'approche du capteur de proximité, celui-ci déclenche une interruption sur le FPGA. La caméra capture alors une image faciale, que l'algorithme LBPH analyse pour reconnaître l'utilisateur. Si l'utilisateur est autorisé, la LED de déverrouillage s'allume en vert et/ou le moteur de déverrouillage est activé, permettant ainsi l'accès au système sécurisé.

## Matériel Utilisé :

- FPGA sur la carte Nexys Video
- Processeur soft-core Microblaze
- Capteur de proximité
- LED(s) et moteur pour les sorties de déverrouillage
- Langages et Outils : VHDL pour la programmation des interfaces et des algorithmes, Xilinx Vivado pour la conception et la synthèse du FPGA.

### Caméra pour la capture d'images faciales (OV7670)

Datasheet : https://www.voti.nl/docs/OV7670.pdf

Tutoriel FPGA : https://www.fpga4student.com/2018/08/basys-3-fpga-ov7670-camera.html

### Verrou à solénoïde

Référence : https://www.sparkfun.com/solenoid-12v-latch-lock.html

Mouser No : 474-ROB-15324

Pmod HB3 : https://digilent.com/reference/pmod/pmodhb3/start
