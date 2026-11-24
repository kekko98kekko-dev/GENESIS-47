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
