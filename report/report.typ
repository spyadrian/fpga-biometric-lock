#import "conf.typ": *

#show: conf.with(
  title: "Biometric Lock",
  authors: "Valentin Bernillon & Adrian Spycher",
  orientation: "systèmes embarqué",
  teachers: "Laurent Gantel, Gabriel Da Silva Marques",
)

#show: apply_intro_style

#outline(title: "Table des matières")

// #outline(title: "Liste des figures", target: figure.where(kind: image))

// #outline(title: "Liste des tableaux", target: figure.where(kind: table))

#show: apply_chapter_style

// #include "chapter/01_introduction.typ"

#include "chapter/02_specification.typ"
