# Crown Pilot — Setup Guide

This guide is written for beginners. Follow the steps in order, don't skip any.

---

## Overview

**Crown Pilot** — Use the Digital Crown to move a winged pilot up and down, auto-fire bullets at a shielded yellow boss in the sky. When the boss's shield drops, tap the screen to unleash a devastating big shot.

This repository contains 3 source files:
- `CrownPilotApp.swift` — App entry point
- `ContentView.swift` — Screen + Digital Crown + tap handling
- `GameScene.swift` — Game brain (player, boss, shield, bullets, collisions)

---

## 1) Install Xcode

1. On your Mac: **App Store** → search **Xcode** → **Get**.
2. It's a 10–15 GB download. Once installed, **open Xcode at least once** and click **Install** if prompted for additional components.
3. Xcode 15 or later is required (for watchOS 10+).

---

## 2) Set Up the Project

### Option A: Using XcodeGen (Recommended)

```bash
# Install XcodeGen
brew install xcodegen

# Clone the repository
git clone https://github.com/HakanIST/CrownPilot.git
cd CrownPilot

# Generate the Xcode project
xcodegen generate

# Open in Xcode
open CrownPilot.xcodeproj
```

Skip to **Step 3** below.

### Option B: Manual Xcode Setup

1. Open Xcode → **Create New Project...**
2. Select the **watchOS** tab at the top.
3. Choose **App** → **Next**.
4. Fill in the fields:
   - **Product Name:** `CrownPilot` (exactly like this — no spaces, capital C and P)
   - **Team:** "None" is fine for the simulator
   - **Organization Identifier:** `com.yourname` (e.g. `com.john`)
   - **Interface:** Make sure **SwiftUI** is selected
   - **Include Notification Scene:** ✗ unchecked
5. **Next** → Choose a save location → **Create**.

> ⚠️ If you don't write the Product Name exactly as `CrownPilot`, the auto-generated `@main` struct will conflict with the one provided. Keep the name identical.

#### Replace the files

**`CrownPilotApp.swift`:**
- Click the file in the left panel, select all (**Cmd+A**), delete, then paste the contents from the repo's `CrownPilotApp.swift`.

**`ContentView.swift`:**
- Same process: delete all → paste contents from the repo's `ContentView.swift`.

**Add `GameScene.swift`:**
1. Right-click the **CrownPilot Watch App** folder → **New File...**
2. Select **Swift File** → **Next**.
3. **Save As:** `GameScene`
4. Make sure **CrownPilot Watch App** is checked under **Targets**.
5. **Create** → paste the contents from the repo's `GameScene.swift`.

---

## 3) Run in Simulator

1. In the top-left of Xcode, click the device picker (next to the ▶ button).
2. Select an **Apple Watch** simulator (e.g. Apple Watch Series 10 46mm).
3. Press ▶ or **Cmd+R**.
4. First build may take 1–2 minutes.

### Simulator Controls

| Action | Method |
|--------|--------|
| Move character up | Click simulator for focus, then **Shift+Cmd+↑** (hold) |
| Move character down | **Shift+Cmd+↓** |
| Big Shot | Click on the simulator screen |

If you have a trackpad, two-finger scrolling over the simulator window also rotates the Digital Crown.

---

## 4) How the Game Works

- **Player** (pink circle, cyan wing): On the left, moves via Digital Crown. Auto-fires a cyan bullet every 0.3 seconds.
- **Boss** (yellow oval, angry face): On the right. **100 HP.**
- **Shield** (blue ring): Protects the boss. **5 seconds on, 3 seconds off** cycle.
  - Shield ON: Bullets bounce off. Shield flashes white on impact.
  - Shield OFF: Boss is vulnerable. Boss border blinks red as a warning.
- **Big Shot:** Tap the screen. When shield is down, fires a red/yellow heavy projectile (**20 damage**). When shield is up, it just shakes the shield.
- **Bombs** (brown, with fuse): Come from the right. Shoot them for +5 points.

**Scoring:**
- Normal bullet on boss (shield down): +1
- Bomb destroyed: +5
- Big Shot on boss: +25

Boss HP = 0 → "WIN!" → Tap to restart.

---

## 5) Deploy to Real Apple Watch (Optional)

### Free method (7-day temporary signing)

1. Xcode → **Settings** (Cmd+,) → **Accounts** → **+** → Sign in with **Apple ID**. No developer subscription needed.
2. Click the blue project icon in the left panel → **Signing & Capabilities** tab.
3. **Team:** Select your Apple ID's "(Personal Team)".
4. Connect your iPhone to Mac via USB. iPhone must be paired with Apple Watch.
5. **iPhone:** Settings → Privacy & Security → Developer Mode → ON (requires restart).
6. **Apple Watch:** Settings → Privacy & Security → Developer Mode → ON.
7. Select your Apple Watch from Xcode's device picker → ▶.

> Free signing expires after **7 days**. A $99/year Apple Developer membership removes this limitation and allows App Store distribution.

---

## 6) Troubleshooting

**"Cannot find 'GameScene' in scope"**
The file was added to the wrong target. Select `GameScene.swift` in Xcode → right panel **File Inspector** → **Target Membership** → check **CrownPilot Watch App**.

**"Invalid redeclaration of 'CrownPilotApp'"**
Product Name doesn't match. Either recreate the project with `CrownPilot` as the name, or rename the struct in `CrownPilotApp.swift` to match Xcode's auto-generated name.

**Build succeeds but simulator is black**
Xcode → **Product** → **Clean Build Folder** (Shift+Cmd+K) → run again.

**Digital Crown doesn't work in simulator**
Click the simulator window once (for focus), then try Shift+Cmd+↑/↓. Alternatively: Simulator → **Hardware** → **Apple Watch → Digital Crown → Rotate Up**.

**"Use of unresolved identifier 'SpriteView'"**
Make sure `import SpriteKit` is at the top of `ContentView.swift`.

**Yellow warnings**
Not a problem. Yellow = warning, red = error. Only fix red ones.

---

## 7) What's Next

Once the prototype is running, try:
- Replace shapes with PNG sprites: `SKSpriteNode(imageNamed: "pilot")` (add image to Assets.xcassets first)
- Sound effects: `SKAction.playSoundFileNamed("shoot.wav", waitForCompletion: false)`
- Different boss attack patterns, health system, levels
- Haptic feedback: `WKInterfaceDevice.current().play(.success)` (on big shot hit)
