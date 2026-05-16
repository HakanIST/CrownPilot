//
//  GameScene.swift
//  Crown Pilot — Watch App
//
//  Bütün oyun mantığı burada.
//   - Oyuncu (pembe daire) sol tarafta, Digital Crown ile yukarı/aşağı.
//   - Oyuncu otomatik olarak her 0.3 saniyede bir mermi atar.
//   - Boss (sarı oval) sağ tarafta, kalkanı var.
//   - Kalkan 5 saniye açık, 3 saniye kapalı şeklinde döner.
//   - Kalkan KAPALI iken ekrana dokun = büyük ateş (20 hasar).
//   - Küçük bombalar (minion) sağdan sola doğru gelir; mermi ile vurulurlar.
//

import SpriteKit

class GameScene: SKScene {

    // MARK: - Sahnedeki düğümler
    private var player: SKShapeNode!
    private var boss: SKShapeNode!
    private var shield: SKShapeNode!
    private var hudLabel: SKLabelNode!

    // MARK: - Oyun durumu
    private let maxBossHP: Int = 100
    private var bossHP: Int = 100
    private var score: Int = 0
    private var shieldsUp: Bool = true
    private var gameOver: Bool = false

    // Zaman sayaçları
    private var shieldTimer: TimeInterval = 0
    private var lastFireTime: TimeInterval = 0
    private var lastMinionSpawn: TimeInterval = 0
    private var lastUpdate: TimeInterval = 0

    // Oyuncuyu yumuşak hareket ettirebilmek için hedef Y
    private var targetPlayerY: CGFloat = 0

    // Boss rengini değişimden sonra geri yüklemek için
    private let bossColor = SKColor(red: 1.0, green: 0.82, blue: 0.20, alpha: 1.0)
    private let shieldColor = SKColor(red: 0.45, green: 0.75, blue: 1.0, alpha: 0.75)

    // MARK: - Sahne başladığında
    override func sceneDidLoad() {
        super.sceneDidLoad()
        backgroundColor = SKColor(red: 0.06, green: 0.10, blue: 0.30, alpha: 1.0)
        setupBackground()
        setupPlayer()
        setupBoss()
        setupHUD()
    }

    // MARK: - Görsel kurulum
    private func setupBackground() {
        // Basit bir yıldız alanı
        for _ in 0..<25 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.5...1.5))
            star.position = CGPoint(
                x: CGFloat.random(in: 0...size.width),
                y: CGFloat.random(in: 0...size.height)
            )
            star.fillColor = .white
            star.strokeColor = .clear
            star.alpha = CGFloat.random(in: 0.3...0.9)
            star.zPosition = -10
            addChild(star)
        }
    }

    private func setupPlayer() {
        let p = SKShapeNode(circleOfRadius: 7)
        p.fillColor = SKColor(red: 1.0, green: 0.45, blue: 0.65, alpha: 1.0)
        p.strokeColor = .white
        p.lineWidth = 1
        p.position = CGPoint(x: size.width * 0.18, y: size.height * 0.5)
        p.zPosition = 5

        // Küçük kanat detayı
        let wing = SKShapeNode(rectOf: CGSize(width: 14, height: 2), cornerRadius: 1)
        wing.fillColor = SKColor.cyan
        wing.strokeColor = .clear
        wing.position = CGPoint(x: -3, y: -1)
        wing.zPosition = -1
        p.addChild(wing)

        addChild(p)
        player = p
        targetPlayerY = p.position.y
    }

    private func setupBoss() {
        let b = SKShapeNode(ellipseOf: CGSize(width: 55, height: 42))
        b.fillColor = bossColor
        b.strokeColor = SKColor.orange
        b.lineWidth = 2
        b.position = CGPoint(x: size.width * 0.80, y: size.height * 0.55)
        b.zPosition = 5

        // Göz
        let eye = SKShapeNode(circleOfRadius: 4)
        eye.fillColor = .black
        eye.strokeColor = .white
        eye.lineWidth = 0.8
        eye.position = CGPoint(x: -12, y: 4)
        b.addChild(eye)

        // Sinirli ağız
        let mouth = SKShapeNode(rectOf: CGSize(width: 16, height: 3), cornerRadius: 1)
        mouth.fillColor = SKColor(red: 0.8, green: 0.1, blue: 0.1, alpha: 1.0)
        mouth.strokeColor = .clear
        mouth.position = CGPoint(x: -8, y: -8)
        b.addChild(mouth)

        addChild(b)
        boss = b

        // Kalkan halkası
        let s = SKShapeNode(ellipseOf: CGSize(width: 72, height: 58))
        s.fillColor = .clear
        s.strokeColor = shieldColor
        s.lineWidth = 2.5
        s.position = boss.position
        s.zPosition = 6
        addChild(s)
        shield = s

        // Hafif sallanma animasyonu
        let bob = SKAction.sequence([
            SKAction.moveBy(x: 0, y: 6, duration: 1.4),
            SKAction.moveBy(x: 0, y: -6, duration: 1.4)
        ])
        boss.run(SKAction.repeatForever(bob))
        shield.run(SKAction.repeatForever(bob))
    }

    private func setupHUD() {
        let label = SKLabelNode(fontNamed: "AvenirNext-Bold")
        label.fontSize = 10
        label.fontColor = .white
        label.horizontalAlignmentMode = .center
        label.position = CGPoint(x: size.width / 2, y: size.height - 14)
        label.zPosition = 100
        addChild(label)
        hudLabel = label
        updateHUD()
    }

    private func updateHUD() {
        hudLabel.text = "BOSS \(bossHP)   ★ \(score)"
    }

    // MARK: - Dış dünyadan gelen girdiler (ContentView çağırır)
    func setPlayerNormalizedY(_ value: Double) {
        // value: 0 = en alt, 1 = en üst
        let y = size.height * CGFloat(value)
        targetPlayerY = max(15, min(size.height - 25, y))
    }

    func tryBigShot() {
        if gameOver {
            restart()
            return
        }
        if !shieldsUp {
            fireBigShot()
        } else {
            // Kalkan kapalı değilse — küçük bir geri bildirim animasyonu
            let shake = SKAction.sequence([
                SKAction.moveBy(x: 3, y: 0, duration: 0.04),
                SKAction.moveBy(x: -6, y: 0, duration: 0.08),
                SKAction.moveBy(x: 3, y: 0, duration: 0.04)
            ])
            shield.run(shake)
        }
    }

    // MARK: - Mermi & düşman üretimi
    private func fireBullet() {
        let bullet = SKShapeNode(circleOfRadius: 2.5)
        bullet.fillColor = SKColor.cyan
        bullet.strokeColor = .white
        bullet.lineWidth = 0.5
        bullet.position = player.position
        bullet.name = "bullet"
        bullet.zPosition = 3
        addChild(bullet)

        let move = SKAction.moveBy(x: size.width, y: 0, duration: 1.1)
        bullet.run(SKAction.sequence([move, SKAction.removeFromParent()]))
    }

    private func fireBigShot() {
        let shot = SKShapeNode(circleOfRadius: 8)
        shot.fillColor = SKColor.red
        shot.strokeColor = SKColor.yellow
        shot.lineWidth = 2
        shot.position = player.position
        shot.name = "bigshot"
        shot.zPosition = 4
        addChild(shot)

        let pulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.scale(to: 1.3, duration: 0.1),
            SKAction.scale(to: 1.0, duration: 0.1)
        ]))
        shot.run(pulse)

        let move = SKAction.moveBy(x: size.width, y: 0, duration: 0.7)
        shot.run(SKAction.sequence([move, SKAction.removeFromParent()]))
    }

    private func spawnMinion() {
        let minion = SKShapeNode(circleOfRadius: 6)
        minion.fillColor = SKColor(red: 0.55, green: 0.35, blue: 0.15, alpha: 1.0)
        minion.strokeColor = SKColor(red: 0.85, green: 0.65, blue: 0.30, alpha: 1.0)
        minion.lineWidth = 1
        minion.position = CGPoint(
            x: size.width + 10,
            y: CGFloat.random(in: 20...(size.height - 25))
        )
        minion.name = "minion"
        minion.zPosition = 4

        // Fitil ve kıvılcım
        let fuse = SKShapeNode(rectOf: CGSize(width: 1.5, height: 5))
        fuse.fillColor = .gray
        fuse.strokeColor = .clear
        fuse.position = CGPoint(x: 0, y: 7)
        minion.addChild(fuse)

        let spark = SKShapeNode(circleOfRadius: 1.5)
        spark.fillColor = .orange
        spark.strokeColor = .clear
        spark.position = CGPoint(x: 0, y: 10)
        let blink = SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.3, duration: 0.2),
            SKAction.fadeAlpha(to: 1.0, duration: 0.2)
        ]))
        spark.run(blink)
        minion.addChild(spark)

        addChild(minion)

        let move = SKAction.moveTo(x: -20, duration: 4.0)
        minion.run(SKAction.sequence([move, SKAction.removeFromParent()]))
    }

    // MARK: - Kalkan döngüsü
    private func toggleShields() {
        shieldsUp.toggle()
        if shieldsUp {
            shield.isHidden = false
            shield.alpha = 0
            shield.run(SKAction.fadeIn(withDuration: 0.3))
        } else {
            shield.run(SKAction.fadeOut(withDuration: 0.3))
            // Kalkan düştü uyarısı - boss biraz parlar
            let blink = SKAction.sequence([
                SKAction.run { [weak self] in self?.boss.strokeColor = .red },
                SKAction.wait(forDuration: 0.15),
                SKAction.run { [weak self] in self?.boss.strokeColor = .orange }
            ])
            boss.run(SKAction.repeat(blink, count: 3))
        }
    }

    // MARK: - Ana döngü (her frame'de çağrılır)
    override func update(_ currentTime: TimeInterval) {
        if lastUpdate == 0 {
            lastUpdate = currentTime
            return
        }
        let dt = currentTime - lastUpdate
        lastUpdate = currentTime

        if gameOver { return }

        // Oyuncuyu yumuşakça hedef Y'ye yaklaştır
        let dy = targetPlayerY - player.position.y
        player.position.y += dy * 0.25

        // Otomatik ateş
        if currentTime - lastFireTime > 0.3 {
            fireBullet()
            lastFireTime = currentTime
        }

        // Düşman üretimi
        if currentTime - lastMinionSpawn > 1.8 {
            spawnMinion()
            lastMinionSpawn = currentTime
        }

        // Kalkan döngüsü: açık 5sn, kapalı 3sn
        shieldTimer += dt
        if shieldsUp && shieldTimer > 5.0 {
            toggleShields()
            shieldTimer = 0
        } else if !shieldsUp && shieldTimer > 3.0 {
            toggleShields()
            shieldTimer = 0
        }

        handleCollisions()
    }

    // MARK: - Çarpışmalar
    private func handleCollisions() {
        var toRemove: [SKNode] = []

        enumerateChildNodes(withName: "bullet") { node, _ in
            // Boss ile çarpıştı mı?
            if self.distance(node.position, self.boss.position) < 28 {
                toRemove.append(node)
                if self.shieldsUp {
                    self.flashShield()
                } else {
                    self.damageBoss(by: 1)
                    self.score += 1
                    self.updateHUD()
                }
                return
            }
            // Minion ile çarpıştı mı?
            var hitMinion: SKNode? = nil
            self.enumerateChildNodes(withName: "minion") { minion, stop in
                if self.distance(node.position, minion.position) < 9 {
                    hitMinion = minion
                    stop.pointee = true
                }
            }
            if let m = hitMinion {
                toRemove.append(node)
                toRemove.append(m)
                self.score += 5
                self.updateHUD()
                self.explosion(at: m.position, color: .orange)
            }
        }

        enumerateChildNodes(withName: "bigshot") { node, _ in
            if self.distance(node.position, self.boss.position) < 35 {
                toRemove.append(node)
                if self.shieldsUp {
                    self.flashShield()
                } else {
                    self.damageBoss(by: 20)
                    self.score += 25
                    self.updateHUD()
                    self.explosion(at: self.boss.position, color: .yellow)
                }
            }
        }

        for n in toRemove { n.removeFromParent() }
    }

    private func distance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let dx = a.x - b.x
        let dy = a.y - b.y
        return sqrt(dx*dx + dy*dy)
    }

    // MARK: - Efektler
    private func flashShield() {
        shield.removeAction(forKey: "flash")
        let flash = SKAction.sequence([
            SKAction.run { [weak self] in self?.shield.strokeColor = .white },
            SKAction.wait(forDuration: 0.05),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                self.shield.strokeColor = self.shieldColor
            }
        ])
        shield.run(flash, withKey: "flash")
    }

    private func explosion(at point: CGPoint, color: SKColor) {
        let burst = SKShapeNode(circleOfRadius: 4)
        burst.fillColor = color
        burst.strokeColor = .white
        burst.position = point
        burst.zPosition = 8
        addChild(burst)
        let grow = SKAction.scale(to: 3.0, duration: 0.25)
        let fade = SKAction.fadeOut(withDuration: 0.25)
        burst.run(SKAction.sequence([
            SKAction.group([grow, fade]),
            SKAction.removeFromParent()
        ]))
    }

    private func damageBoss(by amount: Int) {
        bossHP = max(0, bossHP - amount)
        updateHUD()
        let flash = SKAction.sequence([
            SKAction.run { [weak self] in self?.boss.fillColor = .white },
            SKAction.wait(forDuration: 0.08),
            SKAction.run { [weak self] in
                guard let self = self else { return }
                self.boss.fillColor = self.bossColor
            }
        ])
        boss.run(flash)
        if bossHP <= 0 { winSequence() }
    }

    // MARK: - Kazanma & yeniden başlama
    private func winSequence() {
        gameOver = true

        // Büyük patlama
        let bigBoom = SKShapeNode(circleOfRadius: 30)
        bigBoom.fillColor = .yellow
        bigBoom.strokeColor = .red
        bigBoom.lineWidth = 3
        bigBoom.position = boss.position
        bigBoom.zPosition = 9
        addChild(bigBoom)
        bigBoom.run(SKAction.sequence([
            SKAction.group([
                SKAction.scale(to: 4.0, duration: 0.6),
                SKAction.fadeOut(withDuration: 0.6)
            ]),
            SKAction.removeFromParent()
        ]))

        boss.removeFromParent()
        shield.removeFromParent()

        let win = SKLabelNode(fontNamed: "AvenirNext-Bold")
        win.fontSize = 22
        win.fontColor = .yellow
        win.text = "WIN!"
        win.position = CGPoint(x: size.width / 2, y: size.height / 2)
        win.zPosition = 200
        addChild(win)
        win.setScale(0)
        win.run(SKAction.scale(to: 1.0, duration: 0.4))

        let tap = SKLabelNode(fontNamed: "AvenirNext")
        tap.fontSize = 9
        tap.fontColor = .white
        tap.text = "Tekrar oynamak için dokun"
        tap.position = CGPoint(x: size.width / 2, y: size.height / 2 - 22)
        tap.zPosition = 200
        addChild(tap)
    }

    private func restart() {
        gameOver = false
        bossHP = maxBossHP
        score = 0
        shieldsUp = true
        shieldTimer = 0
        lastFireTime = 0
        lastMinionSpawn = 0
        lastUpdate = 0
        removeAllChildren()
        removeAllActions()
        setupBackground()
        setupPlayer()
        setupBoss()
        setupHUD()
    }
}
