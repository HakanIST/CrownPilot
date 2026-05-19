//
//  ContentView.swift
//  Crown Pilot
//
//  SwiftUI layer:
//   - watchOS: Digital Crown rotation → velocity delta for the pilot
//   - iOS: Touch drag → velocity delta for the pilot
//   - Tap gesture → boost or start game
//   - SpriteView renders the game scene
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    #if os(watchOS)
    // Large range to avoid frequent wrap-around jitter
    @State private var crownValue: Double = 0.0
    #endif

    #if os(iOS)
    @State private var lastDragY: CGFloat? = nil
    #endif

    private static let scene: GameScene = {
        #if os(watchOS)
        let s = GameScene(size: CGSize(width: 200, height: 250))
        #else
        let s = GameScene(size: CGSize(width: 400, height: 700))
        #endif
        s.scaleMode = .resizeFill
        return s
    }()

    var body: some View {
        #if os(watchOS)
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
        #else
        ZStack {
            Color(red: 0.37, green: 0.66, blue: 0.88)
                .ignoresSafeArea()
            SpriteView(scene: Self.scene)
                .ignoresSafeArea()
        }
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    if let lastY = lastDragY {
                        let delta = -(value.location.y - lastY)
                        Self.scene.applyCrownInput(Double(delta) * 0.08)
                    }
                    lastDragY = value.location.y
                }
                .onEnded { _ in
                    lastDragY = nil
                }
        )
        .onTapGesture {
            Self.scene.handleTap()
        }
        #endif
    }
}

#Preview {
    ContentView()
}
