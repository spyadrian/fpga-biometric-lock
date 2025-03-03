// this variable will contains the configuration
#let conf(

  // Parameters
  title: none,
  authors: (),
  orientation: none,
  teachers: none,
  illustration: none,
  date: datetime.today(),

  doc,
) = {

  // --- GENERAL STYLE ---

  // Default Fonts and Styles
  set text(font: "Times New Roman", size: 12pt, lang: "fr")
  show raw: set text(font: "Courier New", size: 12pt, lang: "fr")


  // Document style
  set page(
    margin: 2.5cm,
    header: text(size: 8pt, fill: color.gray,
      authors + " – " + title + " – " + date.display("[month repr:long], [year]"))
  )


  // Paragraph style
  set par(
    justify: true,
    leading: 1.2em,
    spacing: 1.2em,
    first-line-indent: 2em,
  )


  // Grid Styles
  set grid(row-gutter: 1.5em)


  // Heading Styles
  show heading: {
    set text(weight: "bold")
    smallcaps
  }

  show heading.where(level: 1): set align(center)
  show heading.where(level: 1): set text(size: 16pt)
  show heading.where(level: 2): set text(size: 14pt)
  show heading.where(level: 3): set text(size: 12pt)

  show heading.where(level: 1): it => {
    pagebreak(weak: true)

    v(weak: true, 2em)
    block[#it.body]
    v(weak: true, 3em)
  }

  show heading.where(level: 2): it => {
    v(weak: true, 2em)
    block(counter(heading).display(it.numbering) + h(1em) + it.body)
    v(weak: true, 2em)
  }

  show heading.where(level: 3): it => {
    v(weak: true, 2em)
    block(counter(heading).display("1.1.a )").split(".").last() + h(1em) + it.body)
    v(weak: true, 1.5em)
  }


  // Outline Styles
  set outline(depth: 3, indent: auto)
  show outline.entry.where(level: 1): set text(weight: "bold")


  // Figure Style
  set figure(gap: 1.5em)
  show figure.caption: emph
  show figure: it => {
    v(weak: true, 1em)
    it.body
    it.caption
  }


  // Math style
  set math.equation(numbering: "(1)", supplement: [Eq.])


  // --- COVER PAGE ---

  {
    set align(center)
    set text(font: "Arial")
    set page(numbering: none, header: none)
    set par(justify: false, leading: 0.5em)

    // logos
    grid(
      columns: (1fr, 1fr),
      align: (left, right),
      {image("image/hepia_logo.png", width: 60%)},
      {image("image/hes-so_logo.png", width: 60%)}
    )

    // title
    v(4em)
    text(size: 16pt, weight: "bold", title)
    v(1em)

    // illustration
    if illustration == none {
      v(25em)
    } else {
      illustration
      v(2em)
    }

    // authors, orientation & date
    text(size: 14pt, "Cahier des charges du projet FPGA présenté par")
    v(1em)
    text(size: 16pt, weight: "bold", authors)
    v(2em)
    text(size: 14pt, weight: "bold", "Informatique et systèmes de communication avec orientation en " + orientation)
    v(1.5em)
    text(size: 14pt, weight: "bold", date.display("[month repr:long], [year]"))
    v(2em)

    // teachers and client
    text("Professeur-e HES responsable \n" + teachers)
  }

  // --- DOCUMENT ---
  doc
}

#let apply_intro_style(doc) = {
  set page(numbering: "I")

  doc
}

#let apply_chapter_style(doc) = {
  set page(numbering: "1")
  set heading(numbering: "1.1.a")

  show heading.where(level: 1): it => {
    pagebreak(weak: true)

    v(weak: true, 2em)
    if it.numbering != none {block[Chapitre #counter(heading).display("1. ")#h(0.5em)#it.body]}
    else {block[#it.body]}
    v(1.75em)
  }

  counter(page).update(1)
  pagebreak()

  doc
}

