# GENESIS 47 — Registro di continuità del progetto

Ultimo aggiornamento: 25 novembre 2026.
Repository: https://github.com/kekko98kekko-dev/GENESIS-47
Ramo principale: main.

## Protocollo obbligatorio per ogni nuova sessione di lavoro

1. Leggere questo file, AGENTS.md, README.md e project.godot, verificare l'ultimo commit di main e lo stato reale di GitHub Actions. Non presumere che il riepilogo sia ancora aggiornato.
2. Riprendere dal codice esistente; non ricominciare il gioco da zero, non eliminare funzionalità già collaudate. Usare un ramo di lavoro per cambiamenti importanti e pubblicare solo modifiche deliberate.
3. Dopo ogni intervento significativo, aggiornare questo file nello stesso insieme di modifiche: funzionalità aggiunte/corrette, file, commit, test eseguiti/esiti effettivi, problemi aperti, prossimo passo. Distinguere codice scritto, test superato e prova umana. Se CI è in corso, registrare il run e segnare "in attesa"; verificarlo al successivo intervento.
4. Non chiamare "completato" ciò che è soltanto una base tecnica o una simulazione semplificata. Non dichiarare FPS reali sul PC senza rapporto benchmark reale.
5. Mantenere gioco offline, italiano, nessun LLM o servizio esterno obbligatorio, compatibilità dei salvataggi precedenti facoltativa (autorizzato nuovo mondo da zero), Godot 4.4.1 GL Compatibility e profili grafici.
6. Preferenza del proprietario: implementazioni sostanziali in una sessione, non solo roadmap; verificare e correggere gli errori trovati. Se la chat raggiunge il limite, nella nuova chat basta indicare il repository e chiedere di leggere questo file.

## Visione del prodotto
Gioco god-sim evolutivo in cui il mondo vive autonomamente e il Creatore osserva o interviene. Riferimenti di design, non copie: The Sims (vita individuale), WorldBox (poteri), RimWorld (eventi emergenti), Dwarf Fortress (profondità), Black & White (relazione col Creatore), Foundation (insediamenti), Spore (evoluzione), Fabledom (coerenza visiva), Thronglets (legame emotivo).
Modalità Eternità senza finale obbligatorio; tre scenari narrativi facoltativi. Non trasformare il progetto in una semplice demo statica.

## Stato attuale
- Versione del codice: 11.0.0 — Eredità vivente.
- Ultimo commit applicativo prima di questo aggiornamento del registro: 207d993e07a246b8415fc1c66c7c344f764eed69.
- Ultima versione interamente collaudata: 11.0, commit bd3fba81e7a220ba3e5d0d186820853482189d61, run https://github.com/kekko98kekko-dev/GENESIS-47/actions/runs/45593274642 (build e Windows riusciti, SELF_TEST e QA_SUITE PASS).
- 9.0: run https://github.com/kekko98kekko-dev/GENESIS-47/actions/runs/45587563640 fallita durante importazione Godot: parola riservata signal in living_score.gd. Correzione nel ramo 10.0. Ultima versione collaudata rimane 8.1.
- 10.0: precedente errore di importazione corretto; pipeline interamente riuscita al run 45588892853. Artifact Windows: https://github.com/kekko98kekko-dev/GENESIS-47/actions/runs/45588892853/artifacts/15009933282.
- 10.1: pipeline interamente riuscita. Artifact Windows https://github.com/kekko98kekko-dev/GENESIS-47/actions/runs/45589975242/artifacts/15010636738.
- 11.0: pipeline interamente riuscita. LEGACY_TEST PASS; QA_LEGACY 120 giorni, 28→76 cittadini, 14 eventi, ok=true. Artifact Windows: https://github.com/kekko98kekko-dev/GENESIS-47/actions/runs/45593274642/artifacts/15012212401.
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

## Modifiche 6.0
- scripts/colony_life.gd: ogni colono è un agente persistente con posizione, percorso A*, compiti, risorse, bisogni, ricordi, parentele, figli, denaro, morte; visualizzazione individuale e selezione. I fondatori conservano l'identità, i vecchi salvataggi aggregati vengono migrati.
- scripts/finance.gd: capitale bancario, riserva, depositi/prelievi, prestiti con interesse e insolvenze, bilanci e registro; integrazione di stipendi finanziati dalle casse, tasse civiche e acquisti locali.
- scripts/mocap_walk.gd: ciclo di camminata da CMU 35_01 (32 campioni, fonte e licenza in ASSET-CREDITS.md). scripts/creature_rig.gd: mesh con pesi normalizzati e skinning, blend con movimento procedurale.
- scripts/hydrology.gd: acqua a celle, trasferimento conservativo, drenaggio, danni, rendering e persistenza; scripts/structure.gd: cedimento dei supporti e riparazioni. Detriti con collisione del terreno e limite 160.
- scripts/world.gd, ocean.gd, sim.gd e minimap.gd: integrazione, migrazione, test DEEP_TEST. Priorità qualità rispetto all'hardware attuale, come richiesto dall'utente.

## Modifiche 7.0
- scripts/mocap_library.gd: 11 nuove clip da registrazioni CMU, campionate e adattate in tre assi su 16 giunti; riferimento esatto in ASSET-CREDITS.md. La camminata 6.0 rimane. Clip analoghe condivise per i compiti senza capture dedicata.
- scripts/creature_rig.gd: 22 ossa, pesi su dieci superfici deformabili, bacino/torace/collo/testa, mani e piedi, posa procedurale più capture, accessori facciali ancorati. Non è una mesh unica né retarget professionale verificato.
- scripts/industry.gd: imprese pubbliche/private, dipendenti e salari, capitale, scorte, sette ricette produttive, contratti B2B, tasse, dividendi, vendita, liquidazione. scripts/finance.gd: credito alle imprese con riserve, interessi, rimborsi e insolvenze. scripts/ocean.gd e colony_life.gd: undici beni, lavori e consumo industriale.
- scripts/fluid_volume.gd: particelle 3D, densità, pressione, viscosità, collisioni, galleggiamento, trasferimento conservativo all'idrologia esistente, rendering e salvataggi. Limitato a effetti locali, non oceano globale con solver incomprimibile.
- scripts/world.gd: collegamento al potere Tsunami e salvataggi; test INDUSTRY_VOLUME_TEST e adeguamento delle aspettative dei test precedenti. Nessun vincolo di sviluppo imposto dall'hardware attuale.

## Modifiche 8.0
- scripts/continuous_skin.gd: isosuperficie anatomica connessa, marching tetrahedra, saldatura indici e skinning a 4 pesi; scripts/creature_rig.gd usa una sola mesh corporea. Accessori/indumenti restano separati.
- scripts/mocap_library.gd: 23 clip CMU + camminata già esistente, una clip distinta per ciascuno dei 15 compiti principali; fonti in ASSET-CREDITS.md. Compiti astratti usano adattamenti di gesti analoghi.
- scripts/industry.gd: job persistenti per singola unità, A*, ritiro input, lavorazione alla stazione, salario, ritiro output, consegna a magazzino o impresa e regolamento B2B all'arrivo; escrow e rimborso. Rimosso automatismo giornaliero dei lotti; funzioni di regressione esistenti conservate. scripts/world.gd, ocean.gd e colony_life.gd collegano cittadini e coloni.
- scripts/ocean_dynamics.gd: 53×53×8 celle allocate, correnti 3D, flussi conservativi, pressione idrostatica e correzione non idrostatica approssimata, diffusione verticale, vento, superficie deformata, navi e tsunami. Collegato a shader, idrologia e salvataggi. Campo oceanico della mappa giocabile, non CFD industriale a convergenza piena.
- CONTINUOUS_TEST: topologia connessa, copertura clip, produzione e consegna fisiche, cassa conservata, consegna B2B, volume oceanico e persistenza. Esito ancora da verificare.

## Modifiche 8.1
- Verificati i log e le immagini reali 8.0: corpo connesso in posa statica, aspetto stilizzato; nessuna certificazione della deformazione durante tutte le animazioni. Benchmark llvmpipe software 2,4 / 0,6 / 0,6 FPS (non misura un PC da gioco). Avvisi di risorse in uso all'uscita, audio del runner assente, e JSON corrotto intenzionale del test backup.
- scripts/ocean_dynamics.gd: conservazione dello spostamento relativo durante modifiche del fondale, drenaggio su celle costiere asciutte, diagnostica, vento disattivabile per test. Non equivale alla conservazione scientifica del volume assoluto con geometria mobile.
- scripts/industry.gd: audit inventari, cassa, incarichi e depositi; rimborso quando un'azienda chiude, gestione consegne e riassegnazioni.
- scripts/quality_assurance.gd: 30 pose con verifica numerica; 90 giorni di filiera controllata (domanda simulata, capitale iniziale, interruzione e salvataggio); 90 giorni di mondo autonomo; oceano a riposo, volume relativo, drenaggio, modifica terreno e riferimento di onda stazionaria. Soglia onda 15% ampiezza iniziale. Risultati da leggere nel nuovo qa-report.json.
- scripts/world.gd: modalità --qa-test, sei catture delle pose, migliore inquadratura arcipelago, rilascio dei riferimenti circolari. Workflow esporta rapporto e immagini. Nessuna AI esterna.

## Modifiche 9.0 — Esperienza del giocatore
- Decisione del proprietario: rispondere alle critiche da giocatore esterno; smettere di privilegiare complessità invisibile e rendere la simulazione leggibile, emotiva e riconoscibile.
- scripts/art_direction.gd: sei biomi cromatici, specie arboree, architetture di sette ere e due culture, copricapi, abbigliamento, accessori e proporzioni genetiche/età/ruolo. scripts/world.gd: illuminazione, HUD con pannelli su richiesta, mappa indipendente, nuovi luoghi esplorabili, cronaca e selezione rapida.
- scripts/legend.gd: sei capitoli facoltativi, eventi e coordinate, protagonisti, testimonianze, amore/timore, tradizioni, santuari con costo, percorsi di preghiera, lutto e memoriali, accesso a storie e luoghi. Salvataggio e caricamento.
- scripts/wildlife.gd: fauna autonoma, risorse, clima, tratti ereditabili e mutazioni, nascite/morti, stato RNG persistente. Fino a 72 organismi; non è evoluzione completa da vita primordiale a cittadino.
- scripts/living_score.gd: score originale procedurale, crisi e meteo. scripts/industry.gd: macchinari visibili in attività reale. Catastrofi con feedback camera. Nuove catture HUD e ispettore.
- EXPERIENCE_TEST: capitoli, fede, testimonianze, santuario, pellegrinaggio, memoriali, fauna e persistenza. Esito CI da verificare. Non dichiarare la grafica o il coinvolgimento "professionali" senza prove umane.


## 10.0 — Eredità del Creatore
- Corretto l'errore di compilazione 9.0 (identificatore riservato signal in living_score.gd); CI 9.0 fallita all'importazione, non considerata stabile.
- Grande frontiera opzionale e predefinita nel menu: dominio del terreno circa 192×192 rispetto a 106×106, A* 189×189, minimappa, camera, quattro regioni percorribili aggiuntive, flora e punti di interesse. Le regioni periferiche sono collegate via terra. Cascata, grotta (ingresso scenografico) e vulcano sono landmark visivi; il solver idrico/oceanico resta nel bacino centrale precedente, non nell'intera frontiera.
- Origini opzionale in Eternità: popolazioni primitive visibili, sopravvivenza e selezione climatica, mutazioni, due linee evolutive con capacità separate, passaggio a fondatori intelligenti quando le caratteristiche genetiche e generazionali soddisfano le soglie. È un modello accelerato e orientato al gioco, non una simulazione scientifica della speciazione. Il test forza linee mature per verificare la transizione, non garantisce evoluzione naturale su ogni seme.
- Quartieri civici persistenti con costo in legna e crescita per abitazioni/era; skyline e rovine. Non sono ancora metropoli di migliaia di abitanti né servizi urbani indipendenti per tutti gli edifici del distretto.
- Cultura con identità che pesa sulle scelte delle attività; dissenso religioso e dialoghi, aiuto prioritario ai familiari, conforto durante il lutto, cicatrici. Genealogie consultabili, cronaca ampliata e obiettivi registrati anche fuori ordine. Mercati con tende, suoni originali di natura/città e vocalizzazioni sintetiche durante interazioni reali. Non certificati artisticamente o mediante playtest umano.
- FRONTIER_TEST per percorso ampliato, quartieri, transizione evolutiva e genealogia; nuove catture preview-frontier.png e preview-city.png. I test standard e QA estesa restano attivi. Nessun modello AI esterno. Compatibilità dei vecchi salvataggi non è più un vincolo richiesto dal proprietario; nessuna cancellazione fisica di file personali, i nuovi mondi mantengono salvataggio/caricamento.


## 10.1 — Profondità del mondo
- Base 10.0 corretta (commit 3fc7b329a32b96c62d455dd20279686ce48a991f): run 45588892853 completata con successo, incluso avvio eseguibile Windows. SELF_TEST PASS, EXPERIENCE_TEST e FRONTIER_TEST superati, QA_SUITE PASS (30 pose; 90 giorni filiera, 157 unità/156 consegne; 90 giorni mondo autonomo, 228 unità/211 consegne; errore onda 3,74% dell'ampiezza iniziale). Artifact Windows: https://github.com/kekko98kekko-dev/GENESIS-47/actions/runs/45588892853/artifacts/15009933282. Benchmark software llvmpipe non rappresentativo di una GPU reale.
- Screenshot 10.0 realmente esaminati: personaggi riconoscibili, HUD meno invasivo; palette troppo chiara, panoramica sbiadita, continenti circolari, architettura ancora semplificata. 10.1 corregge esposizione, nebbia, palette, silhouette, materiali, rive, dettagli delle case e pelle. Qualità artistica comparabile a produzioni commerciali non dimostrata.
- Grande frontiera: C avvicina alla grotta, C entra; WASD nel livello sotterraneo separato, C/Esc esce. Collisioni, labirinto, cristallo unico persistente, ricompensa in energia/conoscenza e cronaca. Due corsi d'acqua con canali nel terreno, sezioni a volume conservativo, portata da sorgenti e meteo, trasferimenti da gradiente, deflusso contabilizzato e superfici 3D. Modello idraulico 1D lungo i canali, non CFD completo; deflusso periferico contabilizzato separatamente dal bacino centrale, non accoppiamento globale.
- Distretti con posti di servizio reali per pasti, ricerca, svago, artigianato e cure; collegati a prenotazioni A*, bisogni e azioni già presenti. Limite di capacità nella Grande frontiera aumentato da 160 a 640 cittadini individuali sulla terraferma, abitazioni da 25 a 100 per popolo. Questi sono limiti teorici, non prova di una metropoli pienamente popolata o di FPS sostenibili. Case e quartieri crescono in base ai sistemi reali.
- Fauna: quattro morfotipi (brucatore, saltatore, corazzato, predatore), differenze anatomiche, predazione e difesa, tratto corazza ereditabile, mutazioni, divergenza e registro estinzioni, fino a 180 animali. Modello semplificato, non speciazione scientificamente completa.
- WORLD_DEPTH_TEST: capacità, registrazione dei servizi, bilancio idrico, quattro specie iniziali, ricerca del percorso nella grotta e movimento con collisioni, scoperta, persistenza e serializzazione di 200 cittadini. Catture reali di grotta e fiumi richieste dalla CI. Esito 10.1 da verificare.
- PLAYTEST.md: protocollo di cinque ore per valutare l'esperienza, senza voti inventati; non è un playtest umano eseguito. Nessun modello AI esterno.


## 11.0 — Eredità vivente
- Base 10.1 completamente collaudata (run 45589975242, build e windows-smoke riusciti, WORLD_DEPTH_TEST e QA_SUITE PASS). Artifact: https://github.com/kekko98kekko-dev/GENESIS-47/actions/runs/45589975242/artifacts/15010636738. Bilancio dei fiumi: errore assoluto circa 7,55e-9 nel test; 4 stazioni civiche e quattro specie iniziali; serializzazione di 200 cittadini; capacità teorica 640.
- Immagini reali 10.1 esaminate: grotta troppo geometrica e luminosa, città ancora semplici, strade radiali, panoramiche troppo regolari, fiumi poco leggibili, HUD migliorabile. Modifiche: architettura con materiali procedurali, rete di strade locali collegata a case e distretti, piazze e fontane, nuvole meno invasive. Grotta con ambiente scuro separato, illuminazione locale, rocce e due reperti aggiuntivi. Queste non equivalgono ancora a una direzione artistica commerciale professionale.
- scripts/living_art.gd: quattro morfotipi ereditari (Silvano, Cornuto, Slanciato, Crestato), proporzioni, appendici, code animate. Rig e mesh di base ancora condivisi: non sono quattro specie intelligenti con anatomie scheletriche completamente diverse. scripts/portrait_widget.gd: ritratto 2D animato legato a genetica, età, umore e cicatrici. Icone originali dei poteri, schermata d'ingresso con logo e panoramica animata del mondo reale.
- scripts/legacy_society.gd: regimi, successione, elezioni, opposizione, rivolte, scontri civili localizzati, secessione e avamposti autonomisti. Membri rimangono nel clan originario per la simulazione economica e demografica: non terza civiltà sovrana. Legittimità e fede dipendono dagli abitanti, divieto del culto smantella il santuario e impedisce ricostruzione e preghiera, riconciliazione possibile. Osservatorio aumenta resistenza ai danni divini. Cinque invenzioni con costi e benefici effettivi; quattro reliquie regionali con ricompense e scopritore reale; tre scoperte sotterranee includendo il cristallo precedente. Cronaca storica separata con eventi importanti conservati, anno di gioco di 120 giorni. Nessuna prova di millenni simulati.
- Routine post-sonno con due fasi temporizzate e interrompibili (lavarsi e vestirsi), riutilizzano gesti della libreria esistente; non motion capture specifico né sistema di igiene completo. Catastrofi: vulcano con foschia/attenuazione della luce temporanea, protezione biologico-culturale tramite invenzioni; mantengono effetti, panico e distruzione già presenti. Nessuna guerra civile su vasta scala, sotterraneo abitato, linguaggio interamente simulato o nuovo motore evolutivo scientifico.
- LEGACY_TEST: invenzione a costo reale, elezione, rivolta, divieto culto, reliquia, routine e salvataggio; QA_LEGACY 120 giorni di simulazione aggregata con coerenza del leader, delle risorse e delle invenzioni. Nuova cattura preview-title.png. Esiti 11.0 da verificare. Playtest umano, audio e qualità artistica non certificati. Nessun modello AI esterno.

## Backlog e limiti (ordine consigliato)
- P0: verificare esito finale CI 11.0, leggere i log e correggere eventuali errori. Verificare anche i log non fatali, il comportamento dei salvataggi, il rendering della nuova modalità e l'assenza di dipendenze AI.
- P0: prova umana di gioco con la 11.0; osservare onboarding, scelta dei poteri, leggenda, lettura delle creature, ritmo, audio e leggibilità dell'interfaccia. Poi test sul PC reale dell'utente. BENCHMARK.bat genera benchmark-genesis47.json in user://. Richiedere il rapporto, non indovinare FPS. Il proprietario ha chiesto di non limitare lo sviluppo all’hardware attuale; nessun intervento BIOS/overclock necessario.
- P1: parità funzionale tra coloni individuali e cittadini originari (dialoghi, fede, istruzione, politica, stazioni, famiglie più profonde), interazioni fisiche avanzate, più regioni e test su più semi. Gli agenti individuali della 6.0 hanno superato CI.
- P1: navigazione marittima più profonda (porti fisici, imbarco/sbarco, costi e manutenzione, flotta, blocchi, ritorno a porto, rotte intercontinentali estese, salvataggi robusti e test su più semi). Oggi tre masse terrestri nello stesso spazio di simulazione, due colonie possibili, non continenti su scala globale.
- P1: verificare visivamente la mesh connessa 8.0 e le animazioni; retarget professionale, IK e motion capture originale per i gesti specifici non equivalenti a registrazioni umane analoghe.
- P1: verificare filiere fisiche 8.0, turni e bilanci globali; macchinari con componenti e animazioni operative, contratti avanzati, credito privato, mercati estesi.
- P2: validazione fisica del solver oceanico 8.0, convergenza della pressione e accuratezza su fondali complessi, oceano decorativo fuori mappa, erosione e accoppiamento bidirezionale con corpi rigidi.
- P2: direzione artistica coerente, materiali, ambiente, animazioni, UI e ottimizzazione dopo misure reali; test umani e partite prolungate con salvataggi ripetuti.
- P2: evoluzione offline coerente con i sistemi spaziali e portuali; oggi l'assenza è aggregata.
- Non introdurre LLM locale da centinaia di MB: rimosso in 4.1. Preferire intelligenza di gioco leggera e verificabile.

## Mappa del codice e collaudo
- 9.0: art_direction.gd, legend.gd, wildlife.gd, living_score.gd. EXPERIENCE_TEST nel self-test. Limiti residui specifici: estensione fisica della mappa, origine primordiale delle civiltà, qualità artistica da validare, vere metropoli e culture/sistemi completi, playtest umano e audio. Non confondere nuovi biomi con estensione della griglia.
- Collaudo esteso: godot --headless --path . -- --qa-test; qa-report.json, QA_SUITE PASS e sei immagini preview-pose-* nella pipeline. Non dichiarare superati questi controlli fino ai risultati reali.
- project.godot / main.tscn: avvio, configurazione, versione.
- scripts/sim.gd: modello di simulazione, bisogni, attività, evoluzione, relazioni, cultura, stato serializzato.
- scripts/world.gd: orchestrazione Godot, grafica, UI, navigazione, poteri, salvataggi, self_test e benchmark.
- scripts/ocean.gd, creature_rig.gd, debris_physics.gd, colony_life.gd, finance.gd, hydrology.gd, structure.gd, mocap_library.gd, industry.gd, fluid_volume.gd, continuous_skin.gd, ocean_dynamics.gd: moduli sopra descritti.
- scripts/minimap.gd e shaders/: visualizzazione.
- tools/fetch_assets.py e ASSET-CREDITS.md: risorse e licenze.
- .github/workflows/build.yml: import Godot, self-test, screenshot reali, benchmark CI, export Windows x64, smoke test Windows, controllo offline.
- Comando test: godot --headless --path . -- --self-test. Esito richiesto: SELF_TEST PASS e nessun errore di script. Eseguire anche pipeline grafica e Windows.
- Benchmark reale: BENCHMARK.bat, tre profili, media e percentile del tempo frame; non confondere llvmpipe del runner con la GPU reale.

## Registro sessioni
- 25/11/2026 — 4.1: rimosso modello AI esterno, sostituito con cervello procedurale. CI riuscita.
- 25/11/2026 — 4.2: cultura, arcipelago, voto, cassa comune, feste, animazioni, meteo; CI riuscita. Correzione meadow e test ampliati; CI riuscita.
- 25/11/2026 — 5.0: oceano, colonie, mercato, scheletro, fisica e grafica; CI completa riuscita, compreso Windows.
- 25/11/2026 — Continuità: istituito questo registro e AGENTS.md, da mantenere ad ogni sessione.

- 25/11/2026 — 6.0: cittadini individuali nelle colonie, banche, mocap camminata reale e skinning, idrologia e danni strutturali. CI completa riuscita.
- 25/11/2026 — 7.0: imprese e filiere, credito aziendale, clip CMU multiple, rig esteso e particelle fluidi 3D. CI completa riuscita.
- 25/11/2026 — 8.0: mesh continua, clip per tutti i compiti, filiere a unità, oceano multistrato. CI completa e Windows riusciti; immagini reali esaminate.
- 25/11/2026 — 8.1: collaudo esteso completato con successo, incluso Windows.
- 25/11/2026 — 9.0: direzione artistica, HUD, leggenda, religioni, memoriali, fauna evolutiva, musica e fabbriche visibili; test da verificare.

## Frase per riprendere in una nuova chat
"Alfred, riprendiamo GENESIS 47. Leggi AGENTS.md e PROJECT_STATUS.md nel repository kekko98kekko-dev/GENESIS-47, controlla gli ultimi commit e GitHub Actions, poi riparti dal backlog aggiornato senza rifare le cose già completate."

- Priorità residua 10.1: verificare pipeline, nuove catture e stabilità con popolazioni elevate; eseguire PLAYTEST.md. Limiti: bacino oceanico centrale separato, fiumi 1D, una grotta esplorabile, metropoli non ancora dimostrata, quattro morfotipi semplificati e qualità artistica/coinvolgimento non certificati.

- Priorità 11.0: benchmark artistico del proprietario in ART_DIRECTION.md. Catture 11.0 esaminate, divario evidente rispetto ai riferimenti: costruzioni geometriche, vegetazione rada, biologia con rig comune, scala divina modesta. Prossima iterazione: area verticale di qualità, kit originali o licenziati e verifiche visive; non aggiungere complessità invisibile. Playtest umano non eseguito.
