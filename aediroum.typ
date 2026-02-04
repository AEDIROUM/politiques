// Chemin vers les documents sur le site web
#let docs-root = "https://aediroum.ca/documents"

#let registre-positions = state("registre-positions", (:))

// Déclare une nouvelle position
// - numéro: Identifiant unique de la position, déclenche une erreur en cas de doublon
// - libellé: Texte complet de la position
// - adoptée: Date et instance d’adoption, si connue
// - amendée: Dates et instances d’amendement
// - abrogée: Date et instance d’abrogation, si applicable
#let position(
  numéro,
  libellé,
  adoptée: none,
  amendée: (),
  abrogée: none,
) = context {
  if numéro in registre-positions.get() {
    panic("La position n°" + numéro + " est définie en double")
  }

  registre-positions.update(old => old + ((numéro): true))

  let parties = ([Adoptée: #adoptée],)

  for action in amendée {
    parties.push([Amendée: #action])
  }

  if (abrogée == none) {
    parties.push([Abrogée: #abrogée])
  }

  if target() == "html" {
    let anchor = "position-" + str(numéro)

    html.blockquote(id: anchor, class: "position", par({
      html.a(class: "anchor", href: "#" + anchor)[n° #numéro]
      libellé
    }))
  } else {
    block(
      fill: luma(245),
      stroke: (left: 2pt + luma(100)),
      inset: (x: 1.4em, y: 1em),
      width: 100%,
      above: 1.5em,
      below: 1.5em,
      {
        block(sticky: true, {
          place(
            dx: -6.25em,
            box(
              width: 4em,
              align(right, text(luma(60), smallcaps[n° #numéro]))
            ),
          )

          if (abrogée == none) {
            libellé
          } else {
            strike(libellé)
          }
        })

        align(right, emph(parties.join[#h(.25em) · #h(.25em)]))
      }
    )
  }
}

// En-tête du document
// - nom: Titre principal du document
// - date: Date de dernière révision
// - path: Chemin vers le document (sans extension) sur le site web
#let titre(nom: [], date: [], path: "") = context {
  let metadata = [
    #emph[En date du: #date]\
    #emph[Obtenir la dernière version:]#h(.1em)
    #link(docs-root + path + ".pdf")[PDF] ·
    #link(docs-root + path)[Web]
  ]

  if target() == "html" {
    html.elem("header", {
      html.elem("img", attrs: (src: "https://aediroum.ca/images/aediroum.svg"))
      html.elem("div", {
        html.elem("h1", nom)
        html.elem("p", metadata)
      })
    })
  } else {
    grid(
      columns: (1.25in, 1fr),
      align: horizon,
      column-gutter: .25in,
      image("logo.svg", width: 100%),
      [
        #text(1.8em, nom)

        #v(-1.2em)
        #text(1.2em, metadata)
      ],
    )
    v(1em)
  }
}

#let document(body, nom: [], date: [], path: "") = context {
  set heading(numbering: "1.1.1.1")
  set text(font: "Libertinus Serif", size: 11pt)
  set par(justify: true)

  if target() == "html" {
    // Style CSS pour la version HTML des documents
    html.elem("style", "
:root {
  --background: #FEFEFE;
  --background-highlight: #DEDEDE;
  --foreground: #1E1E1E;
  --foreground-muted: #8A8A8A;

  --menu-background: #EAEAEA;
  --menu-background-hover: #DADADA;
  --menu-active: #1E1E1E;
  --menu-inactive: #333333;

  --button-background: #272727;
  --button-background-hover: #373737;
  --button-background-active: #474747;
  --button-foreground: #FEFEFE;

  --link-color: #0D6EFD;
  --link-hover-color: #0A58CA;
  --border-radius: 0.2rem;
  --border-color: #DEE2E6;
}

@media (prefers-color-scheme: dark) {
  :root {
    --background: #1E1E1E;
    --background-highlight: #2B2B2B;
    --foreground: #FAFAFA;
    --foreground-muted: #A0A0A0;

    --menu-background: #323232;
    --menu-background-hover: #424242;
    --menu-active: #FAFAFA;
    --menu-inactive: #C9C9C9;

    --button-background: #E5E5E5;
    --button-background-hover: #D5D5D5;
    --button-background-active: #C5C5C5;
    --button-foreground: #1E1E1E;

    --link-color: #87B8FF;
    --link-hover-color: #5395F5;
    --border-color: #3D4043;
  }
}

*, *:before, *:after {
  box-sizing: border-box;
}

html, body {
  width: 100%;
  height: 100%;
  padding: 0;
  margin: 0;

  font-size: 18px;
  font-family: sans-serif;

  color: var(--foreground);
  background-color: var(--background);
}

body {
  max-width: 800px;
  margin: auto;
}

header {
  display: flex;
  margin: 2em 0;
}

header h1 {
  margin-bottom: 0.1em;
}

header p {
  margin-top: 0;
}

header img {
  width: 10em;
  margin-right: 2em;
}

h2 {
  border-top: 1px solid currentColor;
  padding-top: 1em;
  margin-top: 2em;
}

a {
  color: var(--link-color);
  text-decoration: none;
}

a:hover {
  color: var(--link-hover-color);
}

.position {
  position: relative;

  background-color: var(--background-highlight);
  border-left: 4px solid var(--foreground-muted);

  margin: 1em 0;
  padding: .5em 1em;
}

.position p {
  margin: 0;
}

.position .anchor {
  display: inline-block;
  position: absolute;
  left: -11em;
  width: 10em;
  text-align: right;

  text-transform: uppercase;
}
")
    titre(nom: nom, date: date, path: path)
    body
  } else {
    // Style Typst pour la version PDF des documents
    show heading: it => context {
      let number = counter(heading).at(here())
      block(
        above: if it.level == 1 { 2em } else { 1em },
        below: 1em,
        stroke: if it.level == 1 { (top: .5pt) } else { (:) },
        inset: if it.level == 1 { (top: .66em) } else { (:) },
        width: 100%,
        text(features: ("smcp", "onum"), weight: "regular", {
          if (it.numbering != none) {  
            counter(heading).display()
            h(1em)
          }
          lower[#it.body]
        })
      )
    }

    show link: set text(blue)

    set page(
      paper: "us-letter",
      margin: (x: 1.5in, y: 1.7in),
      footer: [
        #grid(columns: (1.5fr, 3fr, 1.5fr))[
          #align(left)[#date]
        ][
          #align(center)[#text(style: "italic")[#nom]]
        ][
          #context {
            align(right)[Page #counter(page).display("1 de 1", both: true)]
          }
        ]
      ]
    )

    titre(nom: nom, date: date, path: path)
    body
  }
}
