#import "conf.typ": *

#show: conf.with(
  title: "Verrou biométrique",
  authors: "Valentin Bernillon & Adrian Spycher",
  orientation: "systèmes embarqué",
  teachers: "Laurent Gantel, Gabriel Da Silva Marques",
)

#show: apply_intro_style

#outline(title: "Table des matières")

#show: apply_chapter_style

// --------------------

= Verrou biométrique sur FPGA avec Microblaze et Interfaces AXI4-Lite


== Objectif

Concevoir et implémenter un système de déverrouillage biométrique utilisant un FPGA sur la carte Nexys Video.
Ce système utilise un processeur soft-core Microblaze pour la gestion générale et des interfaces AXI4-Lite pour la communication avec les périphériques.
Ce projet utilise une caméra ainsi que l'algorithme LBPH pour la reconnaissance faciale.


== Composants du Système

=== Capteur de Proximité

Un capteur de proximité est utilisé pour détecter l'approche d'un utilisateur.
Ce capteur génère une interruption sur le FPGA lorsqu'une proximité est détectée.

=== Caméra et Reconnaissance Faciale

Une caméra est intégrée au système pour capturer des images faciales.
L'algorithme de reconnaissance faciale LBPH est implémenté en VHDL pour analyser les images et identifier les visages autorisés.

=== Interfaces de Sortie

Un verrou utilisant un électro-aimant est activé pour déverrouiller physiquement une serrure.

=== Interface Personnalisée

Une interface personnalisée en VHDL est conçue pour faciliter la communication entre le FPGA et les périphériques spécifiques au projet, tels que le capteur de proximité et la caméra.

=== Interface Fonctionnant par Interruption

Une interface est configurée pour fonctionner par interruption, permettant au système de réagir en temps réel aux événements détectés par le capteur de proximité.


== Fonctionnement

Lorsqu'un utilisateur s'approche du capteur de proximité, celui-ci déclenche une interruption sur le FPGA.
La caméra capture alors une image faciale, que l'algorithme LBPH analyse pour reconnaître l'utilisateur.
Si l'utilisateur est autorisé, la LED de déverrouillage s'allume en vert et/ou le moteur de déverrouillage est activé, permettant ainsi l'accès au système sécurisé.


== Schéma global

#figure(
  image("image/fpga_biometric_lock_schema_global.drawio.png", width: 90%),
  caption: [Schéma global du projet de verrou biométrique]
)


== Matériel Utilisé :

=== FPGA - Nexys Video

La Nexys Video, basée sur un FPGA Xilinx Artix-7, est un choix pertinent pour ce projet, notamment parce que nous l’avons déjà utilisée en cours, ce qui facilite son intégration et son exploitation.

=== Caméra - OV7670

La caméra OV7670 est un capteur d'image CMOS à faible coût.
Elle fonctionne avec une résolution VGA (640x480) et un débit d'image de 30 FPS, elle est idéale pour les projets embarqués nécessitant une acquisition rapide d’images en temps réel.
Elle communique via une interface parallèle 8 bits et utilise I2C pour la configuration, ce qui la rend facilement interfaçable avec un FPGA comme la Nexys Video via un module AXI4-Stream.

- #link("https://www.voti.nl/docs/OV7670.pdf", "Datasheet")
- #link("https://www.fpga4student.com/2018/08/basys-3-fpga-ov7670-camera.html", "Tutoriel FPGA")

=== Capteur de proximité

Le VCNL4040 est un capteur de proximité à interface I²C, parfaitement adapté pour détecter la présence d’un utilisateur et générer une interruption vers le MicroBlaze.
Intégré à notre projet, il permettra de réveiller le système de reconnaissance faciale dès qu’une personne s’approche.

- #link("https://www.vishay.com/docs/84274/vcnl4040.pdf", "Datasheet")
- #link("https://www.mouser.ch/ProductDetail/Adafruit/4161?qs=d0WKAl%252BL4KYSXIse1Xv7Uw%3D%3D", "Mouser")
- #link("https://www.adafruit.com/product/4161", "Adafruit guide")

=== Verrou à solénoïde - ROB-15324

Un solénoïde électromagnétique est un actionneur qui fonctionne en utilisant un champ magnétique pour attirer ou repousser un piston métallique.
Alimenté en 5V ou 12V, il est contrôlé par le FPGA Nexys Video via MicroBlaze.

- #link("https://www.sparkfun.com/solenoid-12v-latch-lock.html", "Référence")
- Mouser No : 474-ROB-15324
- #link("https://digilent.com/reference/pmod/pmodhb3/start", "Pmod HB3")

=== Langages et Outils

VHDL pour la programmation des interfaces et des algorithmes, Xilinx Vivado pour la conception et la synthèse du FPGA.
