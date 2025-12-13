# 🔥 CONFIGURAZIONE FIREBASE PER ROADGUARDIAN

## ⚠️ IMPORTANTE: Configurazione Google Services

Per far funzionare le notifiche push, devi configurare Firebase per il tuo progetto Android.

---

## 📋 PASSAGGI PER CONFIGURARE FIREBASE

### 1. Crea un progetto Firebase
1. Vai su [Firebase Console](https://console.firebase.google.com/)
2. Clicca su "Aggiungi progetto"
3. Inserisci il nome: **RoadGuardian**
4. Segui i passaggi guidati

### 2. Aggiungi l'app Android al progetto Firebase
1. Nella console Firebase, clicca sull'icona Android
2. Inserisci il **Package Name**: `com.example.roadguardian_client`
   - ⚠️ Deve corrispondere all'`applicationId` in `android/app/build.gradle.kts`
3. Inserisci un nickname (opzionale): "RoadGuardian Client"
4. Lascia vuoto il campo SHA-1 per ora (necessario solo per alcune funzionalità)
5. Clicca su "Registra app"

### 3. Scarica il file google-services.json
1. Firebase genererà il file `google-services.json`
2. Clicca su "Scarica google-services.json"
3. **COPIA** il file in questa posizione:
   ```
   roadguardian_client/android/app/google-services.json
   ```
   ⚠️ IMPORTANTE: Il file deve essere nella cartella `app`, non in `android`!

### 4. Verifica la struttura dei file
```
roadguardian_client/
├── android/
│   ├── app/
│   │   ├── google-services.json  ← QUI!
│   │   ├── build.gradle.kts
│   │   └── src/
│   └── build.gradle.kts
├── lib/
└── pubspec.yaml
```

---

## 🧪 TEST SENZA FIREBASE (Modalità sviluppo)

Se vuoi testare l'app **senza** configurare Firebase subito:

1. L'app partirà comunque (con un warning nel log)
2. Le notifiche **NON** funzioneranno
3. Vedrai nei log: `❌ Errore inizializzazione Firebase`
4. Il resto dell'app funzionerà normalmente

---

## 📱 COME FUNZIONA IL SISTEMA

### 1. All'avvio dell'app
- ✅ Firebase si inizializza
- ✅ Viene richiesto il permesso per le notifiche
- ✅ Viene generato il token FCM (Firebase Cloud Messaging)
- ✅ Il timer parte automaticamente

### 2. Ogni 30 secondi
- 📍 L'app invia la posizione corrente al server
- 🔍 Il server controlla se ci sono incidenti entro 3 km
- 🔔 Se sì, invia una notifica push tramite Firebase
- 📱 L'utente riceve la notifica sul dispositivo

### 3. Quando arriva una notifica
- 🔔 Viene mostrata automaticamente (anche con app in background)
- 👆 Cliccando sulla notifica si apre l'app
- 📊 I dati dell'incidente sono disponibili in `message.data`

---

## 🛠️ COMANDI UTILI

### Installa le dipendenze
```bash
cd roadguardian_client
flutter pub get
```

### Pulisci la build (se hai problemi)
```bash
flutter clean
cd android
./gradlew clean
cd ..
flutter pub get
```

### Avvia l'app su emulatore
```bash
flutter run
```

### Controlla i log per le notifiche
```bash
flutter logs | grep -E "FCM|Notifica|Posizione|Firebase"
```

---

## 🐛 TROUBLESHOOTING

### Errore: "google-services.json is missing"
- ✅ Assicurati che il file sia in `android/app/google-services.json`
- ✅ Verifica che il package name corrisponda

### Errore: "Default FirebaseApp is not initialized"
- ✅ Verifica che `Firebase.initializeApp()` sia chiamato in `main()`
- ✅ Controlla che google-services.json sia presente

### Le notifiche non arrivano
- ✅ Verifica che il token FCM sia stato generato (guarda i log)
- ✅ Verifica che il server sia in esecuzione su `http://10.0.2.2:8000`
- ✅ Controlla che i permessi notifiche siano stati concessi
- ✅ Su Android 13+, i permessi notifiche devono essere esplicitamente richiesti

### Il timer non parte
- ✅ Controlla i log per `⏱️ Timer aggiornamento posizione avviato`
- ✅ Verifica che `_startPositionUpdateTimer()` sia chiamato in `initState()`

---

## 📊 LOG UTILI DA CERCARE

Durante l'esecuzione vedrai questi log:

```
🔥 Firebase inizializzato
✅ Permessi notifiche concessi
📱 Token FCM: eyJhbGciOiJSUzI1NiIsInR...
⏱️ Timer aggiornamento posizione avviato (ogni 30 secondi)
📍 Invio posizione al server: lat=40.8522, lon=14.2681
✅ Posizione inviata al server
📬 Notifica ricevuta in foreground
👆 Notifica cliccata
```

---

## 🚀 PROSSIMI STEP

1. **Configura Firebase** seguendo i passaggi sopra
2. **Avvia il server** Python su `http://127.0.0.1:8000`
3. **Avvia l'app** su emulatore Android
4. **Controlla i log** per vedere se tutto funziona
5. **Crea una segnalazione** entro 3 km dalla tua posizione
6. **Aspetta 30 secondi** e dovresti ricevere una notifica!

---

## 📞 SUPPORTO

In caso di problemi:
1. Controlla prima i log dell'app
2. Controlla i log del server
3. Verifica che tutte le configurazioni siano corrette
4. Ricompila l'app dopo aver aggiunto google-services.json

---

**Buon sviluppo! 🚀**
