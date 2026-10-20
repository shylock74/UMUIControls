# Task: gradiente (accentColor + secondary) per tutti i pulsanti UMUIControls

- [✅] 1. Modifiche ai colori ed Environment
  - [✅] Aggiungere `UMSecondaryColorKey`, `EnvironmentValues.umSecondaryColor`, `View.umSecondaryColor(_:)`, `View.umAccentColor(_:secondary:)` in `UMUIColorExtensions.swift`
  - [✅] Aggiungere utility di calcolo contrasto per gradiente `Color.umContrastingTextColor(secondary:in:)`
- [✅] 2. Implementazione pulsanti
  - [✅] `UMUICapsuleButton`: sfondo a gradiente verticale per `.accent`, testo a contrasto, aggiornamento `UMUICapsuleGlow`
  - [✅] `UMUIMiniButton`: sfondo a gradiente verticale per `.accent`, testo a contrasto
  - [✅] `UMUIIconButton`: sfondo hover a gradiente se presente colore secondario
  - [✅] `UMUIIconToggle`: sfondo attivo a gradiente se presente colore secondario, testo a contrasto
- [✅] 3. Previews
  - [✅] Aggiornare preview in `UMUICapsuleButton.swift` con demo gradiente
  - [✅] Aggiornare preview in `UMUIMiniButton.swift` con demo gradiente
  - [✅] Aggiornare preview in `UMUIIconButton.swift` con demo gradiente
- [✅] 4. Build e validazione
  - [✅] `swift build`
- [✅] 5. Git
  - [✅] Commit e push su origin/main
