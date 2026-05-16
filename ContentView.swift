//
//  ContentView.swift
//  Crown Pilot — Watch App
//
//  SwiftUI layer:
//   - Digital Crown rotation → velocity delta for the pilot
//   - Tap gesture → boost or start game
//   - SpriteView renders the game scene
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    // Large range to avoid frequent wrap-around jitter
    @State private var crownValue: Double = 0.0

    private static let scene: GameScene = {
        let s = GameScene(size: CGSize(width: 200, height: 250))
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        SpriteView(scene: Self.scene)
            .ignoresSafeArea()
            .focusable()
            .digitalCrownRotation(
                $crownValue,
                from: -500.0,
                through: 500.0,
                by: 0.1,
                sensitivity: .high,
                isContinuous: true,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: crownValue) { oldValue, newValue in
                var delta = newValue - oldValue
                // Handle wrap-around (range width = 1000)
                if delta > 500 { delta -= 1000 }
                if delta < -500 { delta += 1000 }
                Self.scene.applyCrownInput(delta)
            }
            .onTapGesture {
                Self.scene.handleTap()
            }
    }
}

#Preview {
    ContentView()
}
