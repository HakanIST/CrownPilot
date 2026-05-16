<p align="center">
  <img src="banner.png" alt="Crown Pilot Banner" width="100%">
</p>

<h1 align="center">👑 Crown Pilot</h1>

<p align="center">
  <b>A side-scrolling boss-fight game built entirely for Apple Watch using SpriteKit and SwiftUI.</b>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-watchOS%2010+-blue?logo=apple" alt="Platform">
  <img src="https://img.shields.io/badge/swift-5.0+-orange?logo=swift" alt="Swift">
  <img src="https://img.shields.io/badge/framework-SpriteKit-purple" alt="SpriteKit">
  <img src="https://img.shields.io/badge/UI-SwiftUI-green" alt="SwiftUI">
  <img src="https://img.shields.io/github/license/HakanIST/CrownPilot" alt="License">
</p>

---

## 🎮 About

**Crown Pilot** is a fast-paced action game designed from the ground up for Apple Watch. Use the **Digital Crown** to pilot a winged character up and down, dodge incoming bombs, and take down a shield-protected boss — all on your wrist.

### Features

- 🕹️ **Digital Crown controls** — Precise analog movement via the watch's crown
- 🔫 **Auto-fire** — Your pilot shoots projectiles automatically every 0.3 seconds
- 🛡️ **Shield mechanic** — Boss shield cycles on (5s) and off (3s); time your attacks
- 💥 **Big Shot** — Tap the screen when shields are down to unleash a heavy attack (20 damage)
- 💣 **Bomb dodging** — Destroy incoming bombs for bonus points
- ⭐ **Scoring system** — Earn points for hits, bomb kills, and big shots
- 🎨 **Pure SpriteKit** — No external assets needed; all visuals are procedurally generated

---

## 🏗️ Architecture

The project is intentionally minimal — just **3 Swift files**, no dependencies:

```
CrownPilot/
├── CrownPilotApp.swift    # @main entry point
├── ContentView.swift      # SwiftUI layer: Digital Crown + tap input + SpriteView
├── GameScene.swift        # All game logic: player, boss, shield, bullets, collisions
└── SETUP.md               # Step-by-step setup guide
```

| Layer | Responsibility |
|-------|---------------|
| `CrownPilotApp` | App lifecycle, launches `ContentView` |
| `ContentView` | Captures Digital Crown rotation (0.0–1.0) and tap gestures, renders `SpriteView` |
| `GameScene` | SpriteKit scene — player movement, auto-fire, boss AI, shield cycle, collision detection, scoring, win/restart flow |

---

## 🚀 Quick Start

### Prerequisites

- **macOS** with **Xcode 15+** installed
- watchOS 10+ Simulator (included with Xcode)

### Option A: XcodeGen (Recommended)

```bash
# Install XcodeGen if you don't have it
brew install xcodegen

# Clone and generate
git clone https://github.com/HakanIST/CrownPilot.git
cd CrownPilot
xcodegen generate

# Open in Xcode
open CrownPilot.xcodeproj
```

Select an **Apple Watch simulator** from the device picker and hit **⌘R**.

### Option B: Manual Xcode Setup

1. Create a new **watchOS → App** project in Xcode named `CrownPilot`
2. Replace the contents of `CrownPilotApp.swift` and `ContentView.swift` with the files from this repo
3. Add a new Swift file named `GameScene.swift` and paste the contents
4. Select a Watch simulator and run

> 📖 For a detailed walkthrough, see [SETUP.md](SETUP.md).

---

## 🎯 How to Play

| Action | Simulator | Real Watch |
|--------|-----------|------------|
| Move up/down | `⇧⌘↑` / `⇧⌘↓` or trackpad scroll | Rotate Digital Crown |
| Big Shot | Click on the watch screen | Tap the screen |

### Game Mechanics

- **Player** (pink circle with cyan wings): Auto-fires cyan bullets every 0.3s
- **Boss** (yellow oval, 100 HP): Protected by a cycling energy shield
- **Shield cycle**: 5 seconds ON → 3 seconds OFF → repeat
  - Shield ON: bullets bounce off, boss is invulnerable
  - Shield OFF: boss glows red — attack now!
- **Big Shot**: Tap to fire a powerful red/yellow projectile (20 damage). Only effective when shields are down
- **Bombs**: Brown bombs drift from right to left. Shoot them for +5 points

### Scoring

| Event | Points |
|-------|--------|
| Normal hit on boss | +1 |
| Bomb destroyed | +5 |
| Big Shot hit on boss | +25 |

Boss HP reaches 0 → **WIN!** → Tap to restart.

---

## ⌚ Deploy to Real Apple Watch

1. **Xcode → Settings → Accounts** → Sign in with your Apple ID
2. Select your **Personal Team** under Signing & Capabilities
3. Connect your iPhone (paired with Apple Watch) via USB
4. Enable **Developer Mode** on both iPhone and Apple Watch (Settings → Privacy & Security)
5. Select your Apple Watch from the device picker → **⌘R**

> ⚠️ Free provisioning expires after 7 days. A $99/year Apple Developer membership removes this limitation.

---

## 🛠️ Customization Ideas

- Replace shapes with sprite images: `SKSpriteNode(imageNamed: "pilot")`
- Add sound effects: `SKAction.playSoundFileNamed("shoot.wav", waitForCompletion: false)`
- Add haptic feedback: `WKInterfaceDevice.current().play(.success)`
- Multiple boss phases with different attack patterns
- Player health system and game-over screen
- Level progression with increasing difficulty

---

## 📄 License

This project is open source and available under the [MIT License](LICENSE).
