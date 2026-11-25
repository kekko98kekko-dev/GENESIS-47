# Direzione artistica — standard qualitativi di GENESIS 47

Riferimenti indicati dal proprietario il 25 novembre 2026: quattro schermate di Fabledom, Foundation, Spore e Black & White. Sono obiettivi di qualità e non asset da copiare. Nessuna riproduzione di modelli, personaggi, texture, interfacce o altri asset proprietari dei giochi citati. Mantenere l'identità originale di GENESIS 47 e l'utilizzo offline.

## 1. Insediamenti e ambiente (Fabledom)
- Riferimento visivo: scena ravvicinata, foreste stratificate e fitte, colture visibili, edifici con tetti e materiali leggibili, recinzioni, depositi, percorsi sinuosi, colori caldi e naturali.
- Problema osservato nella cattura reale 11.0: case geometriche, prato uniforme e alberi dalla chioma semplice; eccessivi spazi vuoti e dettagli ripetitivi.
- Obiettivo: kit 3D originale/modulare con tetti, finestre, travi, porte, fondamenta, props e materiali coerenti; vegetazione per strati e biomi, transizioni terreno/sentieri, variazioni non casuali prive di senso.
- Accettazione: cattura ravvicinata dal gioco reale, senza compositing promozionale, in cui case, vegetazione, campi e materiali siano leggibili e visivamente coerenti.

## 2. Urbanistica (Foundation)
- Riferimento visivo: strade organiche, densità variabile, gerarchia dei monumenti, castelli e mura, edifici su pendii, foreste intorno alla città.
- Problema 11.0: strade e piazze esistono ma gli edifici sono sparsi, con skyline generico e geometrie ripetute.
- Obiettivo: quartieri realmente generati dalla crescita, edifici funzionali integrati nella rete, parcelizzazione, piazze, giardini, monumentalità e crescita verticale, orientamento case verso le strade.
- Accettazione: catture di una stessa città in almeno tre ere, mostrando crescita reale e leggibilità di funzioni urbane; niente edifici fittizi usati per simulare popolazioni inesistenti.

## 3. Biologia (Spore)
- Riferimento visivo: corpi, arti, teste, occhi e appendici di silhouette radicalmente diverse, non solo palette/accessori.
- Problema 11.0: quattro morfotipi condividono scheletro e mesh; differenze limitate a proporzioni e accessori anatomici.
- Obiettivo: famiglie anatomiche originali con topologie e rig distinti, locomozione appropriata, ereditarietà delle strutture e costi adattativi reali. Non solo nuove skin.
- Accettazione: almeno tre anatomie chiaramente distinguibili senza abiti, in movimento e nelle azioni essenziali; verificare deformazioni, locomozione, interazioni e ereditarietà.

## 4. Divinità (Black & White)
- Riferimento visivo: prospettiva ravvicinata, scala del gigante, mano del Creatore e contrasto tra ambiente e miracoli.
- Problema 11.0: i poteri cambiano realmente il mondo ma la rappresentazione e il senso della scala restano modesti.
- Obiettivo: gesti originali, VFX stratificati, suoni riconoscibili, illuminazione temporanea, reazioni visibili delle creature, modalità camera ravvicinata, eventuali avatar colossali con funzioni reali e identità propria.
- Accettazione: sequenze di gameplay prima/durante/dopo almeno un potere benevolo e una catastrofe, con conseguenze fisiche e sociali coerenti.

## Criterio di avanzamento
Non considerare l'aumento del numero di moduli/versioni come miglioramento grafico. Dare priorità a un'area verticale piccola e realmente giocabile con qualità omogenea, poi estendere il kit al resto del mondo senza rimuovere simulazione o sistemi preesistenti. Usare asset originali o con licenza verificata, materiali coerenti, profili grafici e verifiche dei costi di rendering. Non attribuire voti commerciali o dichiarare parità con i riferimenti senza nuove catture reali, video e playtest umano. La 11.0 ha superato la CI; la qualità visiva non raggiunge ancora i riferimenti.

## Implementazione 12.0
Il kit artigianale, le chiome stratificate, le colture, i distretti e le tre anatomie con mesh e rig distinti sono implementati nel codice. I nuovi effetti visivi sono collegati a poteri effettivi. La CI richiede dieci immagini aggiuntive. Le tre ere sono fixture controllate, non dimostrazione di crescita naturale; le catture delle creature e dei poteri sono scene del gioco. Prima di dichiarare accettati i quattro standard controllare le nuove immagini e il rapporto QA; serve un playtest umano. La 11.0 è l'ultima versione sicuramente collaudata.


## 13.0 — Orion, il Custode
- 12.0 verificata integralmente: run 45595814860, import/test standard/QA/render/benchmark/export e Windows riusciti; 90 pose delle tre famiglie ok. Artifact Windows https://github.com/kekko98kekko-dev/GENESIS-47/actions/runs/45595814860/artifacts/15012529864. Catture reali esaminate: case avanzate ancora squadrate, un ritratto coperto da edificio e meteorite fotografato troppo presto. 
- Orion (scripts/colossus.gd): avatar originale articolato alto circa 6,5 m, evocabile/congedabile con G (25 energia alla chiamata); H o pulsante Orion apre rapporto, addestramento tramite incentivi a misericordia/severità, camera di inseguimento. Sceglie automaticamente bersagli in base a salute, fame, fede e distanza; usa navigazione A*, cure/rifornimenti/ammonimenti con effetti reali, costo 8 energia, cooldown, contatori, memoria storica e persistenza. Non è un LLM, non impara modelli, non replica il gigante di Black & White. Limiti: ingombro fisico del gigante non rappresentato nella griglia A*; modello originale stilizzato, non animazione cinematografica professionale.
- Rig: arti extra riutilizzano i campioni mocap esistenti con retargeting e offset di fase; correzione CCD a due giunti per presa di oggetti e contatto zampe posteriori con terreno. Non è una nuova registrazione motion capture fisica di arti non umani; le traiettorie sono sintetizzate, non una soluzione biomeccanica completa. QA_CONTACT verifica riduzione errore di raggiungimento su entrambe le anatomie.
- Crescita: catture era 0/2/4 ottenute da una sola simulazione giornaliera aggregata, senza impostare artificialmente era, case, abitanti o risorse. growth-evidence.json registra giorni, popolazione, case, legna; QA_NATURAL_GROWTH testa sviluppo indipendente. Non equivale a partita spaziale prolungata con ogni lavoratore osservato. Ritratti isolati in piattaforma temporanea e posizione restaurata; meteorite ripreso in volo e impatto su una casa vera. Cattura aggiuntiva Orion. Case avanzate con tetti sovrapposti, balconi e finestre. Qualità commerciale non dimostrata finché nuove catture e playtest non sono valutati.
- COLOSSUS_TEST verifica scelta autonoma, cura, costo, cooldown, modifica indole e salvataggio. CI 13.0 da verificare.
