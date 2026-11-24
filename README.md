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
