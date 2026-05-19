import SpriteKit

class GameScene: SKScene {

    // MARK: - State
    enum Phase { case title, playing, gameOver }
    private var phase: Phase = .title

    private var pilotY: CGFloat = 125
    private var pilotVy: CGFloat = 0
    private var crownAccum: CGFloat = 0
    private var distance: CGFloat = 0
    private var gameSpeed: CGFloat = 1.0
    private var boostEnd: TimeInterval = 0
    private var spawnAccum: CGFloat = 0
    private var lastTime: TimeInterval = 0
    private var animTime: CGFloat = 0
    private var best: Int = 0
    private var isNewBest = false
    private var score: Int { Int(distance) }

    // MARK: - Layers & nodes
    private var pilotNode: SKNode!
    private var entityLayer: SKNode!
    private var hudLayer: SKNode!
    private var screenLayer: SKNode!  // title / gameover overlay
    private var scoreLabel: SKLabelNode!
    private var metresLabel: SKLabelNode!
    private var tapLabel: SKLabelNode!
    private var cloudLayerBack: SKNode!
    private var cloudLayerMid: SKNode!

    // MARK: - Scale factor (1.0 on watchOS 200pt, ~2.0 on iPhone 400pt)
    private var sf: CGFloat { size.width / 200.0 }

    // MARK: - Constants
    private var pilotX: CGFloat { 40 * sf }
    private var margin: CGFloat { 15 * sf }

    // MARK: - Scene setup
    override func sceneDidLoad() {
        super.sceneDidLoad()
        backgroundColor = SKColor(red: 0.37, green: 0.66, blue: 0.88, alpha: 1.0)
        best = UserDefaults.standard.integer(forKey: "cp-best")
        setupSky()
        setupClouds()
        setupSun()

        entityLayer = SKNode()
        entityLayer.zPosition = 5
        addChild(entityLayer)

        setupPilotNode()
        setupHUD()

        screenLayer = SKNode()
        screenLayer.zPosition = 50
        addChild(screenLayer)

        showTitle()
    }

    // MARK: - Sky gradient (strips)
    private func setupSky() {
        let n = 20
        let h = size.height / CGFloat(n)
        for i in 0..<n {
            let t = CGFloat(i) / CGFloat(n - 1)
            let r = lerp(0.99, 0.37, t)
            let g = lerp(0.90, 0.66, t)
            let b = lerp(0.76, 0.88, t)
            let strip = SKSpriteNode(color: SKColor(red: r, green: g, blue: b, alpha: 1), size: CGSize(width: size.width, height: h + 1))
            strip.position = CGPoint(x: size.width / 2, y: h * CGFloat(i) + h / 2)
            strip.zPosition = -100
            addChild(strip)
        }
    }

    private func setupSun() {
        let glow = SKShapeNode(circleOfRadius: 35)
        glow.fillColor = SKColor(red: 1, green: 0.96, blue: 0.85, alpha: 0.35)
        glow.strokeColor = .clear
        glow.position = CGPoint(x: size.width * 0.78, y: size.height * 0.72)
        glow.zPosition = -90
        addChild(glow)

        let sun = SKShapeNode(circleOfRadius: 10)
        sun.fillColor = SKColor(red: 1, green: 0.97, blue: 0.88, alpha: 0.95)
        sun.strokeColor = .clear
        sun.position = glow.position
        sun.zPosition = -89
        addChild(sun)
    }

    // MARK: - Parallax clouds
    private func setupClouds() {
        cloudLayerBack = SKNode()
        cloudLayerBack.zPosition = -80
        addChild(cloudLayerBack)
        for i in 0..<4 {
            let c = createCloud(radius: CGFloat.random(in: 18...28))
            c.position = CGPoint(x: CGFloat(i) * 60 + 20, y: size.height * CGFloat.random(in: 0.55...0.85))
            c.alpha = 0.5
            c.setScale(0.8)
            cloudLayerBack.addChild(c)
        }

        cloudLayerMid = SKNode()
        cloudLayerMid.zPosition = -70
        addChild(cloudLayerMid)
        for i in 0..<3 {
            let c = createCloud(radius: CGFloat.random(in: 16...24))
            c.position = CGPoint(x: CGFloat(i) * 80 + 30, y: size.height * CGFloat.random(in: 0.35...0.65))
            c.alpha = 0.85
            cloudLayerMid.addChild(c)
        }
    }

    private func scrollClouds(_ dt: CGFloat) {
        let backSpeed: CGFloat = 0.15 * gameSpeed
        let midSpeed: CGFloat = 0.4 * gameSpeed
        for c in cloudLayerBack.children {
            c.position.x -= backSpeed * dt * 60
            if c.position.x < -40 { c.position.x += size.width + 80 }
        }
        for c in cloudLayerMid.children {
            c.position.x -= midSpeed * dt * 60
            if c.position.x < -40 { c.position.x += size.width + 80 }
        }
    }

    // MARK: - Pilot
    private func setupPilotNode() {
        pilotNode = createPilot()
        pilotNode.position = CGPoint(x: pilotX, y: pilotY)
        pilotNode.zPosition = 10
        addChild(pilotNode)
    }

    // MARK: - HUD
    private func setupHUD() {
        hudLayer = SKNode()
        hudLayer.zPosition = 40
        addChild(hudLayer)

        // Score pill
        let pill = SKShapeNode(rectOf: CGSize(width: 56, height: 16), cornerRadius: 8)
        pill.fillColor = SKColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 0.7)
        pill.strokeColor = .clear
        pill.position = CGPoint(x: size.width / 2, y: size.height - 14)
        hudLayer.addChild(pill)

        metresLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        metresLabel.fontSize = 5
        metresLabel.fontColor = GameColors.gold
        metresLabel.text = "METRES"
        metresLabel.position = CGPoint(x: size.width / 2 - 18, y: size.height - 12)
        metresLabel.horizontalAlignmentMode = .left
        hudLayer.addChild(metresLabel)

        scoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        scoreLabel.fontSize = 9
        scoreLabel.fontColor = .white
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: size.width / 2 - 18, y: size.height - 22)
        scoreLabel.horizontalAlignmentMode = .left
        hudLayer.addChild(scoreLabel)

        // TAP indicator
        let tapPill = SKShapeNode(rectOf: CGSize(width: 28, height: 14), cornerRadius: 7)
        tapPill.fillColor = SKColor(white: 1, alpha: 0.85)
        tapPill.strokeColor = .clear
        tapPill.position = CGPoint(x: 22, y: 14)
        tapPill.name = "tapPill"
        hudLayer.addChild(tapPill)

        tapLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        tapLabel.fontSize = 6
        tapLabel.fontColor = GameColors.dark
        tapLabel.text = "TAP"
        tapLabel.position = CGPoint(x: 22, y: 11)
        hudLayer.addChild(tapLabel)

        hudLayer.isHidden = true
    }

    // MARK: - Title screen
    private func showTitle() {
        phase = .title
        hudLayer.isHidden = true
        pilotNode.isHidden = false
        pilotNode.position = CGPoint(x: size.width / 2, y: size.height * 0.42)
        pilotNode.setScale(1.1)
        entityLayer.removeAllChildren()
        screenLayer.removeAllChildren()

        // Title text
        let crown = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        crown.fontSize = 24
        crown.fontColor = .white
        crown.text = "CROWN"
        crown.position = CGPoint(x: size.width / 2, y: size.height * 0.72)
        screenLayer.addChild(crown)

        let pilot = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        pilot.fontSize = 24
        pilot.fontColor = GameColors.gold
        pilot.text = "PILOT"
        pilot.position = CGPoint(x: size.width / 2, y: size.height * 0.62)
        screenLayer.addChild(pilot)

        // Crown icon
        let crownIcon = SKShapeNode()
        let cp = CGMutablePath()
        cp.move(to: CGPoint(x: -8, y: 0)); cp.addLine(to: CGPoint(x: -8, y: 3))
        cp.addLine(to: CGPoint(x: -4, y: -1)); cp.addLine(to: CGPoint(x: 0, y: 5))
        cp.addLine(to: CGPoint(x: 4, y: -1)); cp.addLine(to: CGPoint(x: 8, y: 3))
        cp.addLine(to: CGPoint(x: 8, y: 0)); cp.closeSubpath()
        crownIcon.path = cp
        crownIcon.fillColor = GameColors.gold
        crownIcon.strokeColor = GameColors.dark
        crownIcon.lineWidth = 0.8
        crownIcon.position = CGPoint(x: size.width / 2, y: size.height * 0.57)
        screenLayer.addChild(crownIcon)

        // Best score
        if best > 0 {
            let bestBg = SKShapeNode(rectOf: CGSize(width: 52, height: 16), cornerRadius: 8)
            bestBg.fillColor = SKColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 0.75)
            bestBg.strokeColor = .clear
            bestBg.position = CGPoint(x: 42, y: size.height - 14)
            screenLayer.addChild(bestBg)
            let bestL = SKLabelNode(fontNamed: "AvenirNext-Bold")
            bestL.fontSize = 5; bestL.fontColor = GameColors.gold; bestL.text = "BEST"
            bestL.position = CGPoint(x: 24, y: size.height - 10)
            bestL.horizontalAlignmentMode = .left
            screenLayer.addChild(bestL)
            let bestV = SKLabelNode(fontNamed: "AvenirNext-Bold")
            bestV.fontSize = 8; bestV.fontColor = .white; bestV.text = "\(best)"
            bestV.position = CGPoint(x: 24, y: size.height - 20)
            bestV.horizontalAlignmentMode = .left
            screenLayer.addChild(bestV)
        }

        // TAP TO FLY
        let tapBg = SKShapeNode(rectOf: CGSize(width: 80, height: 18), cornerRadius: 9)
        tapBg.fillColor = SKColor(white: 1, alpha: 0.85)
        tapBg.strokeColor = .clear
        tapBg.position = CGPoint(x: size.width / 2, y: size.height * 0.15)
        tapBg.name = "tapToFly"
        screenLayer.addChild(tapBg)
        let tapBgPulse = SKAction.repeatForever(SKAction.sequence([
            SKAction.fadeAlpha(to: 0.6, duration: 0.8),
            SKAction.fadeAlpha(to: 1.0, duration: 0.8)
        ]))
        tapBg.run(tapBgPulse)

        let tapFly = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        tapFly.fontSize = 9; tapFly.fontColor = GameColors.dark; tapFly.text = "TAP TO FLY"
        tapFly.position = CGPoint(x: size.width / 2, y: size.height * 0.15 - 3)
        screenLayer.addChild(tapFly)

        // Dedication
        let dedication = SKLabelNode(fontNamed: "AvenirNext-MediumItalic")
        dedication.fontSize = 7 * sf
        dedication.fontColor = SKColor(white: 1, alpha: 0.7)
        dedication.text = "For Ahmet Cemil Özdemir"
        dedication.position = CGPoint(x: size.width / 2, y: size.height * 0.28)
        screenLayer.addChild(dedication)

        // Decorative island
        let island = createIsland(width: 100)
        island.position = CGPoint(x: size.width / 2, y: 20 * sf)
        island.setScale(0.5 * sf)
        screenLayer.addChild(island)

        // Bob animation
        let bob = SKAction.repeatForever(SKAction.sequence([
            SKAction.moveBy(x: 0, y: 5, duration: 1.2),
            SKAction.moveBy(x: 0, y: -5, duration: 1.2)
        ]))
        pilotNode.run(bob, withKey: "bob")
    }

    // MARK: - Game Over screen
    private func showGameOver() {
        phase = .gameOver
        hudLayer.isHidden = true
        screenLayer.removeAllChildren()

        // Save best
        if score > best { best = score; isNewBest = true; UserDefaults.standard.set(best, forKey: "cp-best") }
        else { isNewBest = false }

        // Dark overlay
        let overlay = SKSpriteNode(color: SKColor(red: 0.05, green: 0.08, blue: 0.22, alpha: 0.5), size: size)
        overlay.position = CGPoint(x: size.width / 2, y: size.height / 2)
        screenLayer.addChild(overlay)

        // Tilt pilot
        pilotNode.zRotation = 0.3
        pilotNode.removeAction(forKey: "bob")

        // SKY DOWN
        let skyDown = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        skyDown.fontSize = 16; skyDown.fontColor = .white; skyDown.text = "SKY DOWN"
        skyDown.position = CGPoint(x: size.width / 2, y: size.height * 0.65)
        screenLayer.addChild(skyDown)

        // Score card
        let card = SKShapeNode(rectOf: CGSize(width: 140, height: 55), cornerRadius: 10)
        card.fillColor = SKColor(white: 1, alpha: 0.95)
        card.strokeColor = GameColors.dark
        card.lineWidth = 1
        card.position = CGPoint(x: size.width / 2, y: size.height * 0.45)
        screenLayer.addChild(card)

        let distL = SKLabelNode(fontNamed: "AvenirNext-Bold")
        distL.fontSize = 6; distL.fontColor = SKColor.gray; distL.text = "DISTANCE"
        distL.position = CGPoint(x: size.width / 2 - 30, y: size.height * 0.45 + 16)
        distL.horizontalAlignmentMode = .left
        screenLayer.addChild(distL)

        let scoreL = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        scoreL.fontSize = 18; scoreL.fontColor = GameColors.dark; scoreL.text = "\(score)"
        scoreL.position = CGPoint(x: size.width / 2 - 30, y: size.height * 0.45 - 2)
        scoreL.horizontalAlignmentMode = .left
        screenLayer.addChild(scoreL)

        let mL = SKLabelNode(fontNamed: "AvenirNext-Bold")
        mL.fontSize = 6; mL.fontColor = SKColor.gray; mL.text = "METRES"
        mL.position = CGPoint(x: size.width / 2 - 30, y: size.height * 0.45 - 14)
        mL.horizontalAlignmentMode = .left
        screenLayer.addChild(mL)

        // Best side
        let bestL = SKLabelNode(fontNamed: "AvenirNext-Bold")
        bestL.fontSize = 6; bestL.fontColor = SKColor.gray; bestL.text = "BEST"
        bestL.position = CGPoint(x: size.width / 2 + 20, y: size.height * 0.45 + 16)
        bestL.horizontalAlignmentMode = .left
        screenLayer.addChild(bestL)

        let bestV = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        bestV.fontSize = 12; bestV.fontColor = isNewBest ? GameColors.headband : GameColors.dark
        bestV.text = "\(best)"
        bestV.position = CGPoint(x: size.width / 2 + 20, y: size.height * 0.45 + 2)
        bestV.horizontalAlignmentMode = .left
        screenLayer.addChild(bestV)

        if isNewBest {
            let badge = SKShapeNode(rectOf: CGSize(width: 36, height: 10), cornerRadius: 5)
            badge.fillColor = GameColors.headband; badge.strokeColor = .clear
            badge.position = CGPoint(x: size.width / 2 + 38, y: size.height * 0.45 - 10)
            screenLayer.addChild(badge)
            let nbL = SKLabelNode(fontNamed: "AvenirNext-Bold")
            nbL.fontSize = 5; nbL.fontColor = .white; nbL.text = "NEW BEST"
            nbL.position = CGPoint(x: size.width / 2 + 38, y: size.height * 0.45 - 13)
            screenLayer.addChild(nbL)
        }

        // FLY AGAIN button
        let btn = SKShapeNode(rectOf: CGSize(width: 80, height: 20), cornerRadius: 10)
        btn.fillColor = GameColors.gold; btn.strokeColor = GameColors.dark; btn.lineWidth = 1
        btn.position = CGPoint(x: size.width / 2, y: size.height * 0.18)
        screenLayer.addChild(btn)
        let btnL = SKLabelNode(fontNamed: "AvenirNext-Heavy")
        btnL.fontSize = 8; btnL.fontColor = GameColors.dark; btnL.text = "FLY AGAIN"
        btnL.position = CGPoint(x: size.width / 2, y: size.height * 0.18 - 3)
        screenLayer.addChild(btnL)
    }

    // MARK: - Start game
    private func startGame() {
        phase = .playing
        pilotY = size.height / 2
        pilotVy = 0
        crownAccum = 0
        distance = 0
        gameSpeed = 1.0
        spawnAccum = 0
        lastTime = 0
        boostEnd = 0

        pilotNode.removeAction(forKey: "bob")
        pilotNode.setScale(0.8)
        pilotNode.zRotation = 0
        pilotNode.position = CGPoint(x: pilotX, y: pilotY)
        pilotNode.isHidden = false

        entityLayer.removeAllChildren()
        screenLayer.removeAllChildren()
        hudLayer.isHidden = false
        updateHUD()
    }

    // MARK: - Input
    func applyCrownInput(_ delta: Double) {
        guard phase == .playing else { return }
        // Accumulate crown input — applied smoothly in update()
        crownAccum += CGFloat(delta) * 18
    }

    func handleTap() {
        switch phase {
        case .title: startGame()
        case .playing: boostEnd = lastTime + 0.7
        case .gameOver: showTitle()
        }
    }

    // MARK: - Game loop
    override func update(_ currentTime: TimeInterval) {
        if lastTime == 0 { lastTime = currentTime; return }
        let dt = min(CGFloat(currentTime - lastTime), 0.05)
        lastTime = currentTime
        animTime += dt

        scrollClouds(dt)

        guard phase == .playing else {
            // Title bob handled by action
            return
        }

        let boosting = currentTime < boostEnd
        let baseSpeed: CGFloat = 1.0 + distance / 8000
        gameSpeed = boosting ? baseSpeed * 2.2 : baseSpeed

        // Apply accumulated crown input smoothly
        pilotVy += crownAccum * 0.4
        crownAccum *= 0.75  // decay accumulator

        // Physics
        pilotVy -= 0.05 * dt * 60   // gravity pulls DOWN (negative Y)
        pilotVy *= pow(0.94, dt * 60) // air drag
        pilotVy = max(-7, min(7, pilotVy)) // clamp max velocity
        pilotY += pilotVy * dt * 60
        pilotY = max(margin, min(size.height - margin, pilotY))
        if pilotY <= margin { pilotVy = max(0, pilotVy) }
        if pilotY >= size.height - margin { pilotVy = min(0, pilotVy) }

        pilotNode.position.y = pilotY
        let tilt = max(-0.35, min(0.35, pilotVy * 0.06))
        pilotNode.zRotation = tilt

        // Boost visual
        updateBoostVisual(boosting)

        // Move entities
        entityLayer.children.forEach { $0.position.x -= gameSpeed * 2.0 * dt * 60 }
        entityLayer.children.filter { $0.position.x < -50 }.forEach { $0.removeFromParent() }

        // Spawn
        spawnAccum += dt * 60
        if spawnAccum > 80 {
            spawnEntity()
            spawnAccum = 0
        }

        // Distance
        distance += gameSpeed * 0.5 * dt * 60
        updateHUD()

        // Collisions
        checkCollisions()

        // Lightning flicker on storms
        entityLayer.enumerateChildNodes(withName: "storm") { node, _ in
            if let bolt = node.childNode(withName: "lightning") {
                bolt.alpha = (Int(self.animTime * 20) % 48 < 3) ? 1.0 : 0.0
            }
        }
    }

    // MARK: - Spawning
    private func spawnEntity() {
        let kinds = ["island", "ring", "airship", "ring", "storm", "ring"]
        let kind = kinds[Int.random(in: 0..<kinds.count)]
        let y = CGFloat.random(in: 30...(size.height - 30))

        switch kind {
        case "island":
            let w = CGFloat.random(in: 35...55)
            let node = createIsland(width: w)
            node.setScale(0.45)
            let anchorBottom = Bool.random()
            node.position = CGPoint(x: size.width + 40, y: anchorBottom ? 15 : size.height - 15)
            if !anchorBottom { node.yScale = -node.yScale }
            entityLayer.addChild(node)
        case "ring":
            let node = createRing()
            node.position = CGPoint(x: size.width + 20, y: y)
            node.userData = NSMutableDictionary()
            node.userData?["collected"] = false
            entityLayer.addChild(node)
        case "airship":
            let node = createAirship()
            node.position = CGPoint(x: size.width + 30, y: y)
            entityLayer.addChild(node)
        case "storm":
            let node = createStormCloud()
            node.position = CGPoint(x: size.width + 30, y: y)
            entityLayer.addChild(node)
        default: break
        }
    }

    // MARK: - Collisions
    private func checkCollisions() {
        let px = pilotX, py = pilotY, pr: CGFloat = 10

        for entity in entityLayer.children {
            let ex = entity.position.x, ey = entity.position.y
            guard let name = entity.name else { continue }

            switch name {
            case "ring":
                let collected = entity.userData?["collected"] as? Bool ?? false
                if !collected && abs(ex - px) < 14 && abs(ey - py) < 16 {
                    entity.userData?["collected"] = true
                    distance += 30
                    // Collect animation
                    entity.run(SKAction.sequence([
                        SKAction.group([
                            SKAction.scale(to: 1.5, duration: 0.15),
                            SKAction.fadeOut(withDuration: 0.15)
                        ]),
                        SKAction.removeFromParent()
                    ]))
                }
            case "island":
                let iw = (entity.xScale > 0 ? entity.xScale : -entity.xScale) * 50
                if abs(ex - px) < iw * 0.4 + pr && abs(ey - py) < 18 {
                    crash()
                    return
                }
            case "airship":
                if abs(ex - px) < 18 && abs(ey - py) < 12 {
                    crash()
                    return
                }
            case "storm":
                if abs(ex - px) < 16 && abs(ey - py) < 10 {
                    crash()
                    return
                }
            default: break
            }
        }
    }

    private func crash() {
        // Flash effect
        let flash = SKSpriteNode(color: .white, size: size)
        flash.position = CGPoint(x: size.width / 2, y: size.height / 2)
        flash.zPosition = 45
        addChild(flash)
        flash.run(SKAction.sequence([
            SKAction.fadeOut(withDuration: 0.3),
            SKAction.removeFromParent()
        ]))

        showGameOver()
    }

    // MARK: - HUD updates
    private func updateHUD() {
        scoreLabel.text = "\(score)"
    }

    private func updateBoostVisual(_ boosting: Bool) {
        tapLabel.text = boosting ? "BOOST" : "TAP"
        if let pill = hudLayer.childNode(withName: "tapPill") as? SKShapeNode {
            pill.fillColor = boosting ? GameColors.gold : SKColor(white: 1, alpha: 0.85)
        }
    }

    // MARK: - Utility
    private func lerp(_ a: CGFloat, _ b: CGFloat, _ t: CGFloat) -> CGFloat {
        a + (b - a) * t
    }
}
