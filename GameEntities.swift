import SpriteKit

// MARK: - Colors
struct GameColors {
    static let skin = SKColor(red: 0.96, green: 0.78, blue: 0.64, alpha: 1.0)
    static let headSkin = SKColor(red: 0.98, green: 0.83, blue: 0.68, alpha: 1.0)
    static let headband = SKColor(red: 0.85, green: 0.23, blue: 0.23, alpha: 1.0)
    static let headbandLight = SKColor(red: 0.93, green: 0.32, blue: 0.32, alpha: 1.0)
    static let gold = SKColor(red: 0.94, green: 0.70, blue: 0.22, alpha: 1.0)
    static let darkGold = SKColor(red: 0.78, green: 0.50, blue: 0.06, alpha: 1.0)
    static let dark = SKColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 1.0)
    static let shoe = SKColor(red: 0.23, green: 0.16, blue: 0.13, alpha: 1.0)
    static let grassGreen = SKColor(red: 0.49, green: 0.83, blue: 0.32, alpha: 1.0)
    static let grassDark = SKColor(red: 0.23, green: 0.54, blue: 0.20, alpha: 1.0)
    static let woodBrown = SKColor(red: 0.79, green: 0.57, blue: 0.36, alpha: 1.0)
    static let woodDark = SKColor(red: 0.43, green: 0.27, blue: 0.13, alpha: 1.0)
    static let airshipGold = SKColor(red: 0.94, green: 0.75, blue: 0.38, alpha: 1.0)
    static let stormGray = SKColor(red: 0.27, green: 0.29, blue: 0.40, alpha: 1.0)
    static let stormLight = SKColor(red: 0.32, green: 0.35, blue: 0.46, alpha: 1.0)
    static let ringGold = SKColor(red: 0.94, green: 0.70, blue: 0.22, alpha: 1.0)
    static let skyTop = SKColor(red: 0.37, green: 0.66, blue: 0.88, alpha: 1.0)
    static let skyBottom = SKColor(red: 0.99, green: 0.90, blue: 0.76, alpha: 1.0)
}

// MARK: - Pilot Factory
func createPilot() -> SKNode {
    let root = SKNode()
    root.name = "pilotRoot"

    // Headband trailing flaps
    let flap1 = SKShapeNode()
    let fp1 = CGMutablePath()
    fp1.move(to: CGPoint(x: -9, y: 7))
    fp1.addQuadCurve(to: CGPoint(x: -21, y: 1), control: CGPoint(x: -16, y: 4))
    fp1.addQuadCurve(to: CGPoint(x: -9, y: 7), control: CGPoint(x: -18, y: 5))
    flap1.path = fp1
    flap1.fillColor = GameColors.headband
    flap1.strokeColor = .clear
    root.addChild(flap1)

    let flap2 = SKShapeNode()
    let fp2 = CGMutablePath()
    fp2.move(to: CGPoint(x: -8, y: 4))
    fp2.addQuadCurve(to: CGPoint(x: -19, y: -2), control: CGPoint(x: -15, y: 1))
    fp2.addQuadCurve(to: CGPoint(x: -8, y: 4), control: CGPoint(x: -16, y: 2))
    flap2.path = fp2
    flap2.fillColor = SKColor(red: 0.61, green: 0.12, blue: 0.12, alpha: 1.0)
    flap2.strokeColor = .clear
    root.addChild(flap2)

    // Body
    let body = SKShapeNode(ellipseOf: CGSize(width: 18, height: 16))
    body.fillColor = GameColors.skin
    body.strokeColor = .clear
    body.position = CGPoint(x: 0, y: -1)
    root.addChild(body)

    // Head
    let head = SKShapeNode(ellipseOf: CGSize(width: 14, height: 11))
    head.fillColor = GameColors.headSkin
    head.strokeColor = .clear
    head.position = CGPoint(x: 0, y: 1)
    root.addChild(head)

    // Headband
    let band = SKShapeNode(rectOf: CGSize(width: 15, height: 3), cornerRadius: 1)
    band.fillColor = GameColors.headband
    band.strokeColor = .clear
    band.position = CGPoint(x: 0, y: 4)
    root.addChild(band)

    let bandHighlight = SKShapeNode(rectOf: CGSize(width: 15, height: 1.5), cornerRadius: 0.5)
    bandHighlight.fillColor = GameColors.headbandLight
    bandHighlight.strokeColor = .clear
    bandHighlight.position = CGPoint(x: 0, y: 5)
    root.addChild(bandHighlight)

    // Goggles
    for (gx, px, py) in [(-2.5, -2.2, 0.3), (3.2, 3.5, 0.3)] as [(CGFloat, CGFloat, CGFloat)] {
        let lens = SKShapeNode(circleOfRadius: 2.0)
        lens.fillColor = .white
        lens.strokeColor = .clear
        lens.position = CGPoint(x: gx, y: 0)
        root.addChild(lens)
        let pupil = SKShapeNode(circleOfRadius: 0.9)
        pupil.fillColor = GameColors.dark
        pupil.strokeColor = .clear
        pupil.position = CGPoint(x: px, y: py)
        root.addChild(pupil)
    }

    // Smile
    let smile = SKShapeNode()
    let sp = CGMutablePath()
    sp.move(to: CGPoint(x: -1.5, y: -4))
    sp.addQuadCurve(to: CGPoint(x: 1.5, y: -4), control: CGPoint(x: 0, y: -6))
    smile.path = sp
    smile.strokeColor = SKColor(red: 0.48, green: 0.23, blue: 0.17, alpha: 1.0)
    smile.lineWidth = 0.8
    smile.fillColor = .clear
    root.addChild(smile)

    // Floating hands
    for hx in [9.0, -9.0] as [CGFloat] {
        let hand = SKShapeNode(circleOfRadius: 3.0)
        hand.fillColor = .white
        hand.strokeColor = SKColor(white: 0.85, alpha: 1.0)
        hand.lineWidth = 0.3
        hand.position = CGPoint(x: hx, y: hx > 0 ? -4 : -5)
        root.addChild(hand)
    }

    // Feet
    for fx in [-3.0, 3.0] as [CGFloat] {
        let foot = SKShapeNode(ellipseOf: CGSize(width: 5, height: 3.5))
        foot.fillColor = GameColors.shoe
        foot.strokeColor = .clear
        foot.position = CGPoint(x: fx, y: -10)
        root.addChild(foot)
    }

    // Wing-pack
    let wing = SKShapeNode()
    let wp = CGMutablePath()
    wp.move(to: CGPoint(x: 5, y: 2))
    wp.addQuadCurve(to: CGPoint(x: 14, y: 4), control: CGPoint(x: 10, y: 6))
    wp.addQuadCurve(to: CGPoint(x: 5, y: 2), control: CGPoint(x: 11, y: 1))
    wing.path = wp
    wing.fillColor = GameColors.gold
    wing.strokeColor = .clear
    root.addChild(wing)

    root.setScale(0.8)
    return root
}

// MARK: - Obstacle Factories
func createIsland(width w: CGFloat) -> SKNode {
    let root = SKNode()
    root.name = "island"

    let grassH = w * 0.28
    let grass = SKShapeNode(ellipseOf: CGSize(width: w, height: grassH * 2))
    grass.fillColor = GameColors.grassGreen
    grass.strokeColor = .clear
    root.addChild(grass)

    let rockPath = CGMutablePath()
    rockPath.move(to: CGPoint(x: -w/2, y: 0))
    rockPath.addQuadCurve(to: CGPoint(x: 0, y: -w * 0.45),
                          control: CGPoint(x: -w/2.5, y: -w * 0.25))
    rockPath.addQuadCurve(to: CGPoint(x: w/2, y: 0),
                          control: CGPoint(x: w/2.5, y: -w * 0.25))
    let rock = SKShapeNode(path: rockPath)
    rock.fillColor = GameColors.woodBrown
    rock.strokeColor = .clear
    root.addChild(rock)

    // Grass highlight
    let highlight = SKShapeNode(ellipseOf: CGSize(width: w * 0.55, height: 4))
    highlight.fillColor = SKColor(red: 0.66, green: 0.88, blue: 0.48, alpha: 0.7)
    highlight.strokeColor = .clear
    highlight.position = CGPoint(x: -3, y: 2)
    root.addChild(highlight)

    return root
}

func createAirship() -> SKNode {
    let root = SKNode()
    root.name = "airship"

    // Balloon
    let balloon = SKShapeNode(ellipseOf: CGSize(width: 36, height: 22))
    balloon.fillColor = GameColors.airshipGold
    balloon.strokeColor = .clear
    root.addChild(balloon)

    // Red stripe
    let stripe = SKShapeNode(rectOf: CGSize(width: 28, height: 2))
    stripe.fillColor = GameColors.headband
    stripe.strokeColor = .clear
    stripe.position = CGPoint(x: 0, y: 2)
    root.addChild(stripe)

    // Basket
    let basket = SKShapeNode(rectOf: CGSize(width: 10, height: 6), cornerRadius: 1)
    basket.fillColor = SKColor(red: 0.52, green: 0.32, blue: 0.16, alpha: 1.0)
    basket.strokeColor = .clear
    basket.position = CGPoint(x: 0, y: -14)
    root.addChild(basket)

    // Ropes
    for rx in [-4.0, 4.0] as [CGFloat] {
        let rope = SKShapeNode(rectOf: CGSize(width: 0.6, height: 6))
        rope.fillColor = GameColors.shoe
        rope.strokeColor = .clear
        rope.position = CGPoint(x: rx, y: -8)
        root.addChild(rope)
    }

    root.setScale(0.6)
    return root
}

func createStormCloud() -> SKNode {
    let root = SKNode()
    root.name = "storm"

    let main = SKShapeNode(ellipseOf: CGSize(width: 42, height: 22))
    main.fillColor = GameColors.stormGray
    main.strokeColor = .clear
    root.addChild(main)

    let top1 = SKShapeNode(ellipseOf: CGSize(width: 22, height: 16))
    top1.fillColor = GameColors.stormLight
    top1.strokeColor = .clear
    top1.position = CGPoint(x: -9, y: 3)
    root.addChild(top1)

    let top2 = SKShapeNode(ellipseOf: CGSize(width: 20, height: 15))
    top2.fillColor = GameColors.stormLight
    top2.strokeColor = .clear
    top2.position = CGPoint(x: 7, y: 2)
    root.addChild(top2)

    let bottom = SKShapeNode(ellipseOf: CGSize(width: 28, height: 10))
    bottom.fillColor = SKColor(red: 0.18, green: 0.20, blue: 0.31, alpha: 1.0)
    bottom.strokeColor = .clear
    bottom.position = CGPoint(x: 0, y: -3)
    root.addChild(bottom)

    // Lightning bolt
    let bolt = SKShapeNode()
    let bp = CGMutablePath()
    bp.move(to: CGPoint(x: -2, y: -9))
    bp.addLine(to: CGPoint(x: 1, y: -13))
    bp.addLine(to: CGPoint(x: -1, y: -12))
    bp.addLine(to: CGPoint(x: 3, y: -18))
    bolt.path = bp
    bolt.strokeColor = SKColor(red: 1.0, green: 0.96, blue: 0.54, alpha: 1.0)
    bolt.lineWidth = 1.2
    bolt.fillColor = .clear
    bolt.name = "lightning"
    bolt.alpha = 0
    root.addChild(bolt)

    root.setScale(0.55)
    return root
}

func createRing() -> SKNode {
    let root = SKNode()
    root.name = "ring"

    let ring = SKShapeNode(ellipseOf: CGSize(width: 18, height: 22))
    ring.fillColor = .clear
    ring.strokeColor = GameColors.ringGold
    ring.lineWidth = 2.5
    ring.glowWidth = 1.0
    root.addChild(ring)

    let shine = SKShapeNode(ellipseOf: CGSize(width: 2, height: 3))
    shine.fillColor = SKColor(red: 1.0, green: 0.97, blue: 0.82, alpha: 0.9)
    shine.strokeColor = .clear
    shine.position = CGPoint(x: -6, y: 0)
    root.addChild(shine)

    root.setScale(0.55)
    return root
}

func createCloud(radius: CGFloat) -> SKNode {
    let root = SKNode()
    let main = SKShapeNode(ellipseOf: CGSize(width: radius * 2, height: radius))
    main.fillColor = .white
    main.strokeColor = .clear
    main.alpha = 0.8
    root.addChild(main)
    let bump1 = SKShapeNode(ellipseOf: CGSize(width: radius * 1.2, height: radius * 0.8))
    bump1.fillColor = .white
    bump1.strokeColor = .clear
    bump1.alpha = 0.8
    bump1.position = CGPoint(x: radius * 0.4, y: radius * 0.15)
    root.addChild(bump1)
    let bump2 = SKShapeNode(ellipseOf: CGSize(width: radius, height: radius * 0.7))
    bump2.fillColor = .white
    bump2.strokeColor = .clear
    bump2.alpha = 0.8
    bump2.position = CGPoint(x: -radius * 0.4, y: -radius * 0.1)
    root.addChild(bump2)
    return root
}
