# GENESIS 47 — Registro di continuità del progetto

Ultimo aggiornamento: 25 novembre 2026.
Repository: https://github.com/kekko98kekko-dev/GENESIS-47
Ramo principale: main.

## Protocollo obbligatorio per ogni nuova sessione di lavoro

1. Leggere questo file, AGENTS.md, README.md e project.godot, verificare l'ultimo commit di main e lo stato reale di GitHub Actions. Non presumere che il riepilogo sia ancora aggiornato.
2. Riprendere dal codice esistente; non ricominciare il gioco da zero, non eliminare funzionalità già collaudate. Usare un ramo di lavoro per cambiamenti importanti e pubblicare solo modifiche deliberate.
3. Dopo ogni intervento significativo, aggiornare questo file nello stesso insieme di modifiche: funzionalità aggiunte/corrette, file, commit, test eseguiti/esiti effettivi, problemi aperti, prossimo passo. Distinguere codice scritto, test superato e prova umana. Se CI è in corso, registrare il run e segnare "in attesa"; verificarlo al successivo intervento.
4. Non chiamare "completato" ciò che è soltanto una base tecnica o una simulazione semplificata. Non dichiarare FPS reali sul PC senza rapporto benchmark reale.
5. Mantenere gioco offline, italiano, nessun LLM o servizio esterno obbligatorio, compatibilità dei salvataggi precedenti ove possibile, Godot 4.4.1 GL Compatibility e profili grafici.
6. Preferenza del proprietario: implementazioni sostanziali in una sessione, non solo roadmap; verificare e correggere gli errori trovati. Se la chat raggiunge il limite, nella nuova chat basta indicare il repository e chiedere di leggere questo file.

## Visione del prodotto
Gioco god-sim evolutivo in cui il mondo vive autonomamente e il Creatore osserva o interviene. Riferimenti di design, non copie: The Sims (vita individuale), WorldBox (poteri), RimWorld (eventi emergenti), Dwarf Fortress (profondità), Black & White (relazione col Creatore), Foundation (insediamenti), Spore (evoluzione), Fabledom (coerenza visiva), Thronglets (legame emotivo).
Modalità Eternità senza finale obbligatorio; tre scenari narrativi facoltativi. Non trasformare il progetto in una semplice demo statica.

## Stato attuale
- Versione del codice: 5.0.0 — Oceani e civiltà.
- Ultimo commit applicativo prima di questo registro: 5522778536c141624a6e5d52294337339a7f4401.
- Ultima versione interamente collaudata: 4.2 corretta, commit ccaa5ad461d028d15672bb4119ff8c78c0ca1da1, run https://github.com/kekko98kekko-dev/GENESIS-47/actions/runs/45580933044 (successo build e Windows).
- 5.0: run https://github.com/kekko98kekko-dev/GENESIS-47/actions/runs/45581769849. Al momento della stesura: importazione script, test simulazione/poteri e cattura grafica risultano superati; benchmark in corso, esportazione e test Windows non ancora confermati. Consultare il run per esito aggiornato.
- Distribuzione: artifact GENESIS-47-Windows nella pagina Actions. Estrarre lo ZIP e avviare GENESIS47.exe. Nessun modello AI esterno.

## Funzionalità consolidate fino alla 4.2
- Due popoli (Auralis, Nerith), sette ere, genetica, bisogni, salute, emozioni, età, famiglie, biografie, amicizie, lutto, dialoghi e apprendimento leggero.
- IA utility e pianificazione specifica offline, compiti spaziali, A*, prenotazioni, case assegnate, interni, raccolta, consegna, costruzione, utensili, cura, insegnamento, guardia e conflitti.
- 25 modalità/poteri incluso Osserva; catastrofi con danni, crateri, incendi, epidemie, tornado, tsunami e macerie; vento e pioggia influenzano alcuni pericoli.
- Civiltà: ricerca, progetti, diplomazia, carovane, elezioni, politiche, fondo comune, aiuti, feste ed eredità culturale.
- Isola classica e arcipelago con due isole collegate da ponti, scoperta, minimappa, turismo della telecamera.
- Tre slot, autosalvataggio e backup, migrazione dei vecchi salvataggi, impostazioni persistenti, profili grafici, modalità foto, tutorial e benchmark.
- Test 4.2: simulazione spaziale 35 giorni (28 -> 32 abitanti, 1.074 attività completate, 20 case nel run originale), simulazione aggregata 3.011 giorni, cultura, aiuti, percorsi, salvataggi, meteo e test del binario Windows. La correzione del nodo meadow ha eliminato l'errore di rimozione duplicata osservato nei log; restano da approfondire eventuali altri avvisi.

## Modifiche della 5.0
- scripts/ocean.gd: colonie aggregate indipendenti, spedizioni di due adulti reali rimossi dal censimento originario, risorse e popolazione proprie, crescita, danni, rotte A* acquatiche, flotte grafiche e mercato tra porti con quattro merci, prezzi dinamici, riserva di merce e pagamento, consegna/rimborso, ritardi meteo e acquisti locali.
- scripts/creature_rig.gd: Skeleton3D a 13 ossa, BoneAttachment3D, pose procedurali interpolate e dettaglio in base alla distanza.
- scripts/debris_physics.gd: RigidBody3D, massa, velocità, gravità, collisioni, attrito, rimbalzo, massimo 30 frammenti e pulizia temporizzata.
- scripts/world.gd: nuova modalità terre separate, integrazione del mercato e fisica, salvataggi, tab Mercato, comandi spedizione, test end-to-end, benchmark con simulazione attiva.
- scripts/minimap.gd, scripts/sim.gd, shaders/water.gdshader, shaders/terrain.gdshader: aggiornamenti geografici, disattivazione vecchie carovane gratuite nella modalità oceano, materiali e dettagli scalabili.
- project.godot / README.md: versione e documentazione.

## Backlog e limiti (ordine consigliato)
- P0: verificare esito finale CI 5.0, leggere i log e correggere eventuali errori. Verificare anche i log non fatali, il comportamento dei salvataggi, il rendering della nuova modalità e l'assenza di dipendenze AI.
- P0: test sul PC reale dell'utente. BENCHMARK.bat genera benchmark-genesis47.json in user://. Richiedere il rapporto, non indovinare FPS. Hardware di riferimento: Ryzen 5 3400G, GTX 1050 Ti 4 GB, RAM 32 GB. Nessun intervento BIOS/overclock necessario.
- P1: colonie con singoli agenti persistenti, familiari, attività, case e navigazione locale; oggi la colonia è aggregata con rappresentazione grafica semplificata. Migrazione e popolazione globale coerenti; colonizzazione di più regioni con più civiltà e limiti espliciti.
- P1: navigazione marittima più profonda (porti fisici, imbarco/sbarco, costi e manutenzione, flotta, blocchi, ritorno a porto, rotte intercontinentali estese, salvataggi robusti e test su più semi). Oggi tre masse terrestri nello stesso spazio di simulazione, due colonie possibili, non continenti su scala globale.
- P1: animazioni scheletriche professionali con mesh deformabili e pesi, blending/AnimationTree, eventualmente IK e animazioni create o licenziate con crediti; oggi ossa native con geometrie rigide, non mocap o qualità professionale certificata.
- P1: economia completa con produzione/consumo coerenti, professioni, contabilità e moneta consistente, lavoro e salari, mercati fisici, contratti e catene produttive, inventari, bilanci e test di conservazione risorse/denaro. Oggi mercato semplificato a quattro merci.
- P2: fisica dei fluidi, collisione con terreno reale, distruzione strutturale e interazione fisica più profonda. Oggi detriti limitati e piano di collisione locale, danni di gioco deterministici.
- P2: direzione artistica coerente, materiali, ambiente, animazioni, UI e ottimizzazione dopo misure reali; test umani e partite prolungate con salvataggi ripetuti.
- P2: evoluzione offline coerente con i sistemi spaziali e portuali; oggi l'assenza è aggregata.
- Non introdurre LLM locale da centinaia di MB: rimosso in 4.1. Preferire intelligenza di gioco leggera e verificabile.

## Mappa del codice e collaudo
- project.godot / main.tscn: avvio, configurazione, versione.
- scripts/sim.gd: modello di simulazione, bisogni, attività, evoluzione, relazioni, cultura, stato serializzato.
- scripts/world.gd: orchestrazione Godot, grafica, UI, navigazione, poteri, salvataggi, self_test e benchmark.
- scripts/ocean.gd, creature_rig.gd, debris_physics.gd: moduli nuovi sopra descritti.
- scripts/minimap.gd e shaders/: visualizzazione.
- tools/fetch_assets.py e ASSET-CREDITS.md: risorse e licenze.
- .github/workflows/build.yml: import Godot, self-test, screenshot reali, benchmark CI, export Windows x64, smoke test Windows, controllo offline.
- Comando test: godot --headless --path . -- --self-test. Esito richiesto: SELF_TEST PASS e nessun errore di script. Eseguire anche pipeline grafica e Windows.
- Benchmark reale: BENCHMARK.bat, tre profili, media e percentile del tempo frame; non confondere llvmpipe del runner con la GPU reale.

## Registro sessioni
- 25/11/2026 — 4.1: rimosso modello AI esterno, sostituito con cervello procedurale. CI riuscita.
- 25/11/2026 — 4.2: cultura, arcipelago, voto, cassa comune, feste, animazioni, meteo; CI riuscita. Correzione meadow e test ampliati; CI riuscita.
- 25/11/2026 — 5.0: oceano, colonie, mercato, scheletro, fisica e grafica; codice pubblicato in main, primi test superati, esito completo CI ancora da verificare al momento della stesura.
- 25/11/2026 — Continuità: istituito questo registro e AGENTS.md, da mantenere ad ogni sessione.

## Frase per riprendere in una nuova chat
"Alfred, riprendiamo GENESIS 47. Leggi AGENTS.md e PROJECT_STATUS.md nel repository kekko98kekko-dev/GENESIS-47, controlla gli ultimi commit e GitHub Actions, poi riparti dal backlog aggiornato senza rifare le cose già completate."
