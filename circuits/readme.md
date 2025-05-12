Les deux designs utilisés pour le développement des différents modules du projet sont disponibles dans le répertoire `scripts`.

- `design_GPIO.tcl` : contient l'architecture qui a permis le fonctionnement du capteur de distance ainsi que le verrou solénoïde
- `design_vga.tcl` : contient l'architecture qui a servi au développement du contrôleur VGA ainsi que la configuration de la caméra

Pour importer un design, il suffit de `source` celui-ci dans la console TCL du projet.

Les fichiers des différents programmes Vitis sont mis dans `vitis_src`. (`main_int-GPIO.c` contient le programme de démo pour le verrou et le capteur de distance)

