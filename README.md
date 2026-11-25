# GENESIS 47 — PROJECT GOD

Gioco Godot 4 nativo, in italiano. Simulazione evolutiva autonoma, due civiltà, sette ere, quattro scenari e 20 interventi divini. Compatibilità OpenGL per hardware moderato.

## Avvio
Nella pagina Actions, scarica l'artifact GENESIS-47-Windows dopo il completamento dei test. Estrai tutto lo ZIP e apri GENESIS47.exe.
- WASD: movimento della telecamera; tasto destro trascinato: rotazione; rotella: zoom.
- Clicca una creatura in modalità Osserva; scegli un potere e clicca sul terreno.
- Spazio: pausa; F10: nascondi/mostra interfaccia.
- Tre slot di salvataggio; il gioco funziona interamente con il cervello comportamentale integrato.
- Nessun servizio a pagamento, chiave API o abbonamento richiesto.

## Build
GitHub Actions usa solo runner standard pubblici, scarica Godot ufficiale e modelli CC0, esegue test, esporta il binario Windows. La cattura renderizzata, se disponibile, si trova nell'artifact.
Il progetto resta in collaudo fino a verifica delle build e delle prestazioni reali. Non è una release commerciale certificata.
Crediti: ASSET-CREDITS.md.

## Aggiornamento 1.1
Atlante ricercabile, autosalvataggio separato e recupero copia precedente, impostazioni persistenti, nubi, effetti sonori originali, particelle e luce d'impatto. Il gioco funziona completamente offline.

## Eternità (modalità principale)
Nessun limite di giorni o generazioni. Raggiungere l’era finale non arresta il gioco; i cicli del futuro continuano. Se tutte le creature muoiono, il tempo continua e puoi creare nuovi abitanti con Vita. Le tre sfide narrative hanno epiloghi facoltativi. Il limite tecnico è 160 abitanti contemporanei, non la durata.

## 1.3 — Civiltà vive
Opere civili ricorrenti con costi, effetti permanenti, monumenti in 3D e una schermata dedicata. Statistiche di nascite e morti; nomi delle parentele, indicatori di salute ed energia. Gli archivi recenti dei defunti sono limitati a 3000 schede per contenere il salvataggio; i conteggi complessivi continuano. Compatibilità dei salvataggi precedenti mantenuta tramite valori predefiniti.

## 1.4 — Equilibrio dinamico
Dopo il giorno 300, Eternità alterna crisi e rinascite con conseguenze reali. Le opere civili attenuano alcuni effetti. Animazioni di cammino/riposo, sentieri con materiale procedurale, luce solare variabile, indicatori di salute leggibili. Salvataggio automatico alla chiusura se attivo. Il collaudo richiede anche tre schermate renderizzate e un breve avvio grafico senza errori di script.

## 1.6 — Vie del mondo
Strada commerciale 3D con ponti automatici su tratti allagati, carovane con merci in transito per cinque giorni, consegna o perdita in base alla situazione, persistenza dei viaggi. Minimappa con percorso, camera protetta dal terreno e trascinamento con tasto centrale, selezione più precisa, terreno più fitto. La rotta viene rigenerata dopo le modifiche del terreno. Il test verifica la consegna e il ripristino di una spedizione.

## 1.7 — Legami
Biografie individuali, personalità derivata dai geni, fiducia nel Creatore, dialoghi consultabili e salvati, nomi personalizzabili, navigazione dei legami e selezione con doppio clic. Mercatini 3D e segni per preferiti/malati. Limiti: 40 eventi biografici e 30 messaggi recenti per abitante.

## 1.8 — Natura e osservazione
Vegetazione animata in un MultiMesh (fino a 4.200 ciuffi), materiale del suolo e acqua migliorati, tour panoramico F6, contatore FPS, ripristino di tempo, energia infinita e selezione nei salvataggi. Il profilo Prestazioni nasconde la vegetazione extra; Bilanciata usa fino a 2.600 istanze. Grafica stilizzata, compatibilità GL.

## 1.9 — Identità
Creature procedurali originali con morfologia genetica, colori dei due popoli, animazioni di lavoro e riposo, monumenti e luci notturne. In Eternità gli abitanti cercano compagnia, aiutano chi è in difficoltà e contribuiscono alle opere. Tutorial in cinque passi, richiamabile con F2. Test automatici di comportamento e tutorial; non sostituiscono test con utenti reali.

## 2.0 — Qualità e verifica
Solidarietà per feriti, malati e affamati; test mirato di aiuto con persistenza. Materiali originali procedurali, occhi animati, geometrie condivise. BENCHMARK.bat avvia una simulazione isolata, misura FPS medi e il percentile 99 del tempo frame su tre profili, apre la cartella del rapporto benchmark-genesis47.json. Il test grafico CI verifica il funzionamento ma non rappresenta le prestazioni di un PC reale. In Opzioni, Scheda prova giocatore registra sei compiti e commenti senza inviare dati. Il collaudo umano richiede un giocatore effettivo.

## 2.1 — Autonomia intenzionale
Nella partita interattiva le creature valutano bisogni, tratti, scorte e intenzioni, scelgono un compito, percorrono una griglia A* e ne ricevono gli effetti solo dopo l'arrivo e una fase di esecuzione. I compiti persistono tra giorni e salvataggi. Le urgenze possono interromperli. A velocità 1x il giorno dura circa 8,5 secondi. La simulazione aggregata di assenza e i vecchi test demografici mantengono il modello giornaliero astratto; non sono una prova del movimento in tempo reale. Gli edifici e le celle allagate vengono evitati, salvo i ponti. Il test verifica scelta di cibo e riposo, persistenza e percorso.

Le relazioni nella partita interattiva crescono tramite incontri completati; unioni e nuove nascite dipendono da legami, salute, parentela, risorse e tempo. La raccolta di legna cerca alberi effettivi. Velocità massima 20x per mantenere proporzione tra navigazione e tempo. Test spaziale: percorso, attività persistente oltre un cambio di giorno, cibo consumato solamente al completamento. Le interazioni sono sequenziali, non il sistema proprietario di The Sims.

## 2.2 — Catastrofi fisiche
Meteoriti con danni al momento dell'impatto; tsunami, vulcano, fulmine e deformazioni colpiscono le abitazioni effettivamente comprese nel raggio. Perdita di risorse, vittime, macerie, vegetazione rimossa, terreni danneggiati temporaneamente. Posizioni delle case e macerie persistenti; ricostruzione con risorse e attesa. Test mirato di impatto, cratere, villaggio distante intatto e salvataggio. Le infrastrutture non residenziali non sono tutte distruttibili; non è una simulazione di fluidi o frattura fisica.

## 3.0 — Comunità funzionali
Architettura originale ispirata ai principi di FreeSO (MPL-2.0), Colony Sim Template (MIT) e Deepholm (MIT), senza importare il codice di tali motori. Registro di stazioni con capacità e prenotazioni, abitazioni assegnate, scorte alimentari prenotate, raccolta e consegna al magazzino, costruzione con consumo di legna, azioni con prop e segnali 3D. In modalità spaziale la produzione ordinaria deriva da azioni concluse; le crisi, i doni divini, le opere concluse e il commercio possono ancora modificare le risorse. Riposo presso ripari visibili, non interni arredati. Il modello offline aggregato resta distinto. Test di prenotazione, perdita di dimora e assenza di produzione passiva.

## 3.1 — Vita osservabile
Dimore modulari con quattro letti e vista degli interni quando si segue un residente da vicino; riposo nella dimora, espressioni, emozioni, lutto, routine individuali, gesti differenziati e dialoghi contestuali offline. Iniziative generative locali più frequenti con pensieri visibili e archiviati. Esplorazioni e luoghi di interesse, indicatori di raggio dei poteri, reazioni di fuga, notifiche 3D, etichette meno invasive, cronaca semplificata. Persistenza delle scoperte e delle prenotazioni valide durante la ricostruzione delle stazioni. Test di lutto, interni e scoperta. Non sono ancora presenti continenti aggiuntivi, animazioni scheletriche professionali o simulazione fisica completa delle catastrofi.

## 4.0 — Evoluzione
Nuove attività: utensili con usura, educazione dei figli, guardia, scontri spaziali; raccolto influenzato da clima e strumenti; risparmi personali (contatore, non mercato completo); rivalità; cantieri progressivi; avamposti produttivi; incendio, tornado, terremoto, epidemia e tsunami a impulsi; pericoli persistenti; contagio di prossimità; preavviso meteorite; corretta versione nei rapporti. Test di crafting, incendio e 1.200 passi spaziali (circa 35 giorni). Modelli e animazioni restano stilizzati; non è una simulazione fisica di fluidi né un mondo a continenti multipli. Nessun servizio a pagamento.

La consegna interrotta conserva il carico personale nei salvataggi; i dialoghi AI sono accodati solo dopo incontri realmente completati, con verifica del formato a due battute e ripiego sui dialoghi offline. La qualità delle battute dipende dal piccolo modello locale. Test di parsing e persistenza del carico.

## 4.1 — Cervello integrato
Rimossi HTTPRequest, Ollama, llama.cpp, Qwen e gli script di avvio AI. Avvio diretto con GENESIS47.exe. Dialoghi procedurali a due voci sensibili a bisogni, relazioni, stress, lutto e personalità; valori appresi dagli esiti delle attività; piano a prerequisiti per le abitazioni; priorità di consiglio adattate alle condizioni della comunità. Apprendimento leggero e pianificatore specifico, non un LLM o un motore GOAP generico. Il vecchio modello può essere eliminato manualmente da %LOCALAPPDATA%\\GENESIS47\\AI senza modificare i salvataggi. Le sezioni precedenti sono cronologia delle versioni, non istruzioni di avvio correnti.

## 4.2 — Culture e arcipelago
- Nuova partita: opzione Arcipelago (preselezionata) con due isole aggiuntive nello stesso mondo, ponti percorribili, minimappa, punti di scoperta e inquadrature dedicate. I vecchi salvataggi conservano la geografia originale. Non sono continenti indipendenti, né esistono navi, colonie autonome separate o simulazione oceanica.
- Scheda Cultura: voto degli adulti in base alle necessità, delegato scelto per merito, cinque politiche che modificano le priorità delle azioni. Una quota di 0,25 monete dal lavoro concluso finanzia il fondo comune; aiuti e feste consumano effettivamente denaro e cibo. Educazione e feste alimentano l'eredità culturale. Cronaca e bilanci persistono nei salvataggi. Voti e feste sono calcolati nella simulazione spaziale, non nella modalità aggregata d'assenza.
- Animazioni procedurali di studio, cura ed esplorazione, segnali 3D di consiglio e festa. Pioggia e neve attenuano gli incendi; il vento stagionale deterministico influenza i tornado. Non è un motore fisico completo né un'animazione scheletrica professionale.
- Test aggiunto: contributi, voto, festa con costi, round trip JSON, generazione delle due isole e percorso A* ai punti regionali. La pipeline Windows esistente resta obbligatoria; il codice non equivale a un eseguibile collaudato.

## 5.0 — Oceani e civiltà
- Nuova modalità Continenti (preselezionata), tre masse terrestri separate nello stesso spazio di simulazione, due colonie autonome possibili. Le modalità classica e arcipelago restano disponibili. Coloni reali partono dal censimento originario; le colonie simulano popolazione, crescita, risorse, abitazioni e danni da catastrofe in forma aggregata. Non sono ancora città con una IA individuale completa per ogni colono.
- Spedizioni manuali e autonome con prerequisiti, costo e due adulti. Navigazione navale A* su acqua, movimento grafico, ritardi meteorologici; le rotte sono aggiornate dopo cambiamenti del terreno. Mercato di cibo, legna, pietra e utensili tra porti, domanda/offerta e prezzi dinamici, bilanci, depositi, spedizione, consegna o rimborso; acquisto locale di utensili. Economia semplificata, non una simulazione finanziaria completa. Nessun servizio esterno.
- Rig Skeleton3D a 13 ossa, articolazioni e interpolazione delle pose, dettaglio animazioni in base alla distanza. Geometrie rigide agganciate alle ossa: non skinning deformabile, motion capture o animazioni professionali certificate.
- Detriti RigidBody3D con collisioni, massa, attrito e rimbalzo, massimo 30 frammenti; terreno locale approssimato da un piano di collisione. Non fluidodinamica o distruzione strutturale integrale. Danni di gioco deterministici e persistenti. Acqua e materiali migliorati, profili grafici scalabili.
- Test integrato: rig, separazione delle terre, percorso marittimo, emigrazione, fondazione, depositi, caricamento, consegna, rimborso e corpi rigidi. BENCHMARK.bat usa la nuova mappa e simulazione attiva e registra i tre profili, con popolazione e colonie. I risultati CI non misurano l'hardware dell'utente. L'evoluzione durante l'assenza resta aggregata e non simula tutte le operazioni portuali.

## 6.0 — Vita oltre il mare
- Le colonie hanno cittadini individuali persistenti (fondatori con identità e ricordi originali, figli, parentele, fame, energia, salute, abilità, denaro e memorie). Compiti di coltivazione, raccolta, estrazione, produzione, costruzione, pasti e interazioni richiedono percorsi A* e completamento; tutti gli abitanti hanno un modello animato e una scheda consultabile. Migrazione dei vecchi dati aggregati; non è ancora lo stesso motore completo di relazioni/ruoli delle due città originarie. Le colonie restano limitate a due, 48 cittadini ciascuna e 12 case.
- Contabilità bancaria per porto: capitale, riserva, depositi personali, prelievi, prestiti con interesse e rimborso, insolvenze, bilanci e registro delle operazioni. Salari finanziati dalle casse nel modo Oceano, acquisti e fondi civici. Non è un sistema finanziario universale: credito commerciale limitato, assenza di mercati azionari, imprese e valuta multipla; alcune sorgenti/sink di denaro della simulazione originaria restano.
- Quattro mesh continue con pesi normalizzati per ogni creatura, skinning nativo e camminata basata su 32 campioni retargettati dal motion capture CMU 35_01; altre attività restano procedurali. Non equivale a un set di animazioni professionali completo con retarget 3D e IK del corpo intero.
- Idrologia su griglia 53x53: trasferimento conservativo dell'acqua secondo gradiente di quota, drenaggio contabilizzato verso il mare, profondità persistente, superficie visibile e danni da alluvione. Quattro supporti e tetto con danni cumulativi, cedimento e riparazione mediante legna; detriti con collisione del terreno reale. Modello semplificato, non Navier–Stokes 3D né analisi agli elementi finiti. Test DEEP_TEST per pesi, cittadini, lavoro, banca, massa dell'acqua, danni e salvataggi.
- Obiettivo qualità prima dell'hardware attuale; nessun modello AI esterno. Pipeline Windows e benchmark rimangono obbligatori; FPS sul PC reale richiedono una prova locale.

## 7.0 — Industria e materia
- Rig a 22 ossa, con bacino, colonna, torace, collo, testa, dita aggregate e punte dei piedi. Dieci superfici deformabili pesate (quattro arti, tronco, testa, mani e piedi), accessori facciali vincolati alle ossa. Camminata CMU precedente e 11 nuove registrazioni reali di corsa, sollevamento, scavo, martellatura, trasporto, interazione, riposo, salto e atteggiamento di guardia. Le pose procedurali sono combinate con le clip. Azioni analoghe condividono clip adattate: non motion capture dedicato a ogni gesto, né mesh unica continua con dita indipendenti o retarget professionale verificato visivamente.
- Imprese pubbliche e private: mulino, forno, segheria, fornace, fucina, officina e meccanica. Dipendenti reali, credito di lavoro da compiti completati, salari pagati, capitale, inventari, ricette, prezzi, contratti B2B con merce e denaro riservati, vendita, imposte, dividendi, prestito bancario e insolvenza/liquidazione. Undici beni scambiabili. Pane consumato durante il pasto, materiali e macchinari impiegati in attività. La fabbricazione industriale è contabilizzata per lotti; non è ancora un trasporto fisico individuale di tutti gli input nella fabbrica. Economia monetaria completa del gioco non ancora auditata.
- Fluidi locali tridimensionali: fino a 2.400 particelle di volume discreto, densità, pressione repulsiva, viscosità, gravità, spatial hash, collisioni col terreno e volumi approssimati delle case, accoppiamento con detriti tramite galleggiamento e resistenza. Tsunami genera particelle, l'acqua depositata alimenta senza duplicazione il modello idrologico persistente 2D. Conservazione del volume verificabile; non solver incomprimibile Navier–Stokes industriale, né oceano globale 3D. Rendering particellare, non superficie libera ricostruita.
- Test INDUSTRY_VOLUME_TEST: capitale, salari, input/output, contratto, conservazione cassa, credito, pesi, moto 3D, trasferimento volume e persistenza. Compatibilità con salvataggi precedenti. Pipeline Windows obbligatoria e stato effettivo in PROJECT_STATUS.md.

## 8.0 — Mondo continuo
- Corpo anatomico generato come unica isosuperficie con unione morbida di volumi, marching tetrahedra e saldatura degli indici; una sola superficie di skinning con quattro pesi per vertice e 22 ossa. La topologia è condivisa fra creature; accessori facciali e indumenti restano nodi separati. Il test controlla la connettività di tutti i vertici. Non è una mesh modellata a mano da un character artist né una certificazione visiva delle deformazioni.
- 23 clip CMU nella libreria più il ciclo di camminata esistente; assegnazione distinta per tutti i 15 compiti principali, più miniera, trasporto, commercio, industria e riposo. Registrazioni reali di taglio legna, consumo del pasto, scavo, sega, martello, educazione, aiuto, cura, ricerca, esplorazione e altri movimenti; i compiti astratti sono adattamenti di gesti analoghi. Nessun motion capture originale registrato appositamente per le creature.
- Produzione industriale fisica: lavoratore assegnato a impresa, percorso A* verso magazzino, acquisto e ritiro input, trasporto a stazione, lavorazione temporizzata di una unità con consumo proporzionale, salario pagato, ritiro del prodotto, consegna a mercato o altra impresa e vendita/regolamento B2B all'arrivo. Job, merci in transito ed escrow persistono. I bisogni personali interrompono il lavoro; cancellazione restituisce carico e deposito. Non si generano più lotti automaticamente ogni giorno; le funzioni di produzione a lotti restano per regressioni/compatibilità. La consegna fisica dei beni avviene tramite percorso del cittadino e inventario discreto; non tramite simulazione di macchinari a componenti meccanici.
- Oceano giocabile intero (griglia orizzontale 53×53, 8 strati, 22.472 celle volumetriche allocate, celle attive solo in acqua). Correnti tridimensionali, flussi conservativi fra colonne, gravità, vento, diffusione verticale e correzione di pressione non idrostatica con quattro iterazioni, altezza della superficie trasmessa allo shader, navi che seguono elevazione/correnti e tsunami accoppiato a particelle locali e idrologia. Il drenaggio restituisce acqua all'oceano. Non è CFD industriale pienamente convergente: resta un modello multistrato discretizzato, non ogni goccia dell'intero mare decorativo fuori mappa.
- Test CONTINUOUS_TEST: mesh connessa, mappatura clip, produzione fisica, consegna, cassa conservata, consegna B2B, dinamica verticale, volume oceanico e persistenza. Pipeline Windows da verificare. Nessun modello AI esterno.

## 8.1 — Collaudo esteso
- La 8.0 ha completato build, SELF_TEST, rendering, benchmark ed eseguibile Windows; CONTINUOUS_TEST ha contato 7.634 vertici connessi. Il benchmark del runner software llvmpipe non certifica le prestazioni di un PC da gioco.
- Correzioni: conservazione dello spostamento dell'oceano al cambio del terreno e ricezione del drenaggio anche su celle asciutte, cancellazione e rimborso di consegne quando un'azienda chiude o il lavoratore cambia, rilascio dei riferimenti circolari al termine.
- Comando aggiuntivo: godot --headless --path . -- --qa-test. Produce qa-report.json con 30 pose e controllo numerico dello skinning, filiera controllata 90 giorni con interruzione e salvataggio, mondo autonomo 90 giorni, test dell'oceano a riposo, conservazione, drenaggio e confronto con un'onda stazionaria analitica (tolleranza 15% dell'ampiezza iniziale). Non è una certificazione artistica, economica o CFD scientifica. Sei immagini reali delle pose vengono aggiunte al collaudo grafico. Il nuovo collaudo deve risultare superato prima di considerare stabile la patch.
