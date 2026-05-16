//
//  ContentView.swift
//  Crown Pilot — Watch App
//
//  Bu View:
//   - SpriteKit sahnesini ekrana basar (SpriteView)
//   - Digital Crown dönüşünü yakalar ve karakteri yukarı/aşağı taşır
//   - Ekrana dokunmayı yakalar ve "büyük ateş" tetikler
//

import SwiftUI
import SpriteKit

struct ContentView: View {
    // Digital Crown'un mevcut değeri. 0.0 (en alt) ile 1.0 (en üst) arası.
    @State private var crownValue: Double = 0.5

    // Oyun sahnesini sadece BİR KEZ oluşturuyoruz. View her render olduğunda
    // sıfırdan oluşturursak oyun her seferinde sıfırlanır.
    private static let scene: GameScene = {
        let s = GameScene(size: CGSize(width: 200, height: 250))
        s.scaleMode = .resizeFill // Apple Watch ekranına otomatik uyar
        return s
    }()

    var body: some View {
        SpriteView(scene: Self.scene)
            .ignoresSafeArea()
            .focusable()
            .digitalCrownRotation(
                $crownValue,
                from: 0.0,
                through: 1.0,
                by: 0.005,
                sensitivity: .medium,
                isContinuous: false,
                isHapticFeedbackEnabled: true
            )
            .onChange(of: crownValue) { _, newValue in
                Self.scene.setPlayerNormalizedY(newValue)
            }
            .onTapGesture {
                Self.scene.tryBigShot()
            }
    }
}

#Preview {
    ContentView()
}
