# GENESIS 47 — PROJECT GOD

Gioco Godot 4 nativo, in italiano. Simulazione evolutiva autonoma, due civiltà, sette ere, quattro scenari e 20 interventi divini. Compatibilità OpenGL per hardware moderato.

## Avvio
Nella pagina Actions, scarica l'artifact GENESIS-47-Windows dopo il completamento dei test. Estrai tutto lo ZIP e apri GENESIS47.exe.
- WASD: movimento della telecamera; tasto destro trascinato: rotazione; rotella: zoom.
- Clicca una creatura in modalità Osserva; scegli un potere e clicca sul terreno.
- Spazio: pausa; F10: nascondi/mostra interfaccia.
- Tre slot di salvataggio; il gioco continua autonomamente anche senza AI.
- L'opzione generativa usa Ollama sulla macchina locale (qwen2.5:1.5b consigliato). LLM e Ollama non inclusi; il dialogo procedurale offline è sempre disponibile.
- Nessun servizio a pagamento, chiave API o abbonamento richiesto.

## Build
GitHub Actions usa solo runner standard pubblici, scarica Godot ufficiale e modelli CC0, esegue test, esporta il binario Windows. La cattura renderizzata, se disponibile, si trova nell'artifact.
Il progetto resta in collaudo fino a verifica delle build e delle prestazioni reali. Non è una release commerciale certificata.
Crediti: ASSET-CREDITS.md.

## Aggiornamento 1.1
Atlante ricercabile, autosalvataggio separato e recupero copia precedente, impostazioni persistenti, nubi, effetti sonori originali, particelle e luce d'impatto. Il gioco è completamente offline senza il modello generativo; per l'opzione AI installare Ollama e il modello locale separatamente.

## Gioco con AI portatile
Apri GENESIS47.exe per giocare subito offline. Per il modello linguistico reale, avvia GIOCA-CON-AI.bat: al primo avvio scarica 491 MB del modello Qwen2.5-0.5B-Instruct-GGUF (Apache-2.0), verifica SHA256 e avvia llama.cpp b6000 (MIT), incluso nel pacchetto. Nessun account o servizio a pagamento; non richiede amministratore o Ollama. Il server ascolta soltanto su 127.0.0.1 ed è terminato alla chiusura del gioco. Il modello piccolo può produrre risposte imperfette. La simulazione offline non dipende dall’AI.

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
