import SpriteKit
import Foundation

enum AlienDirection {
    case left, right
}

class GameScene: SKScene {

    private var ship: SKSpriteNode!
    private var aliens: [SKSpriteNode] = []
    private var rocks: [SKSpriteNode] = []
    private var lastAlienFireTime: TimeInterval = 0
    private var alienDirection: AlienDirection = .left
    private var alienOffset: CGFloat = 0
    private var bulletInFlight: SKSpriteNode? = nil
    private var isGameOver = false

    private let alienFireInterval: TimeInterval = 1.0
    private let bulletSpeed: CGFloat = 700
    private let alienBulletSpeed: CGFloat = 400

    private var backgroundNode: SKSpriteNode?
    private var titleNode: SKSpriteNode?
    private var gameOverNode: SKSpriteNode?

    override func didMove(to view: SKView) {
        setupBackground()
        setupTitle()
        setupShip()
        setupAliens()
        setupRocks()
        view.window?.makeFirstResponder(self)
    }

    // MARK: Setup

    private func setupBackground() {
        // Try loading with Bundle.main first, fallback to colored rectangle
        if let image = Bundle.main.image(forResource: "space") {
            let texture = SKTexture(image: image)
            let bg = SKSpriteNode(texture: texture)
            bg.position = CGPoint(x: size.width/2, y: size.height/2)
            bg.size = size
            bg.zPosition = -1
            backgroundNode = bg
            addChild(bg)
        } else {
            // Fallback to solid color
            let bg = SKSpriteNode(color: .black, size: size)
            bg.position = CGPoint(x: size.width/2, y: size.height/2)
            bg.zPosition = -1
            backgroundNode = bg
            addChild(bg)
        }
    }

    private func setupTitle() {
        if let image = Bundle.main.image(forResource: "title") {
            let texture = SKTexture(image: image)
            let title = SKSpriteNode(texture: texture)
            title.position = CGPoint(x: size.width * 0.5, y: size.height - 50)
            title.zPosition = 5
            title.name = "title"
            title.setScale(0.6)
            titleNode = title
            addChild(title)
        } else {
            // Fallback to text label
            let label = SKLabelNode(text: "SPACE INVADERS")
            label.fontName = "AvenirNext-Bold"
            label.fontSize = 24
            label.position = CGPoint(x: size.width * 0.5, y: size.height - 50)
            label.zPosition = 5
            addChild(label)
        }
    }

    private func setupShip() {
        if let image = Bundle.main.image(forResource: "ship") {
            let texture = SKTexture(image: image)
            ship = SKSpriteNode(texture: texture)
        } else {
            ship = SKSpriteNode(color: .white, size: CGSize(width: 40, height: 40))
        }
        ship.size = CGSize(width: 40, height: 40)
        ship.position = CGPoint(x: size.width/2, y: 80)
        ship.name = "ship"
        addChild(ship)
    }

    private func setupAliens() {
        let xPositions: [CGFloat] = [80, 180, 280, 380, 480]
        let yPositions: [CGFloat] = [size.height - 200, size.height - 280, size.height - 360]

        var mutatingX = xPositions
        for row in yPositions {
            for x in mutatingX {
                let alien: SKSpriteNode
                if let image = Bundle.main.image(forResource: "alien") {
                    let texture = SKTexture(image: image)
                    alien = SKSpriteNode(texture: texture)
                } else {
                    alien = SKSpriteNode(color: .green, size: CGSize(width: 30, height: 30))
                }
                alien.size = CGSize(width: 30, height: 30)
                alien.position = CGPoint(x: x, y: row)
                alien.name = "alien"
                addChild(alien)
                aliens.append(alien)
            }
            if !mutatingX.isEmpty { mutatingX.removeFirst() }
            if !mutatingX.isEmpty { mutatingX.removeLast() }
        }
    }

    private func setupRocks() {
        var x_r: [CGFloat] = Array(stride(from: 50, through: 170, by: 15))
        x_r += Array(stride(from: 235, through: 355, by: 15))
        x_r += Array(stride(from: 420, through: 540, by: 15))
        let y_r: [CGFloat] = [450, 435, 465, 420, 480]

        var temp = 1
        for y in y_r {
            for x in x_r {
                let rock: SKSpriteNode
                if let image = Bundle.main.image(forResource: "rock") {
                    let texture = SKTexture(image: image)
                    rock = SKSpriteNode(texture: texture)
                } else {
                    rock = SKSpriteNode(color: .red, size: CGSize(width: 15, height: 15))
                }
                rock.size = CGSize(width: 15, height: 15)
                rock.position = CGPoint(x: x, y: y)
                rock.name = "rock"
                addChild(rock)
                rocks.append(rock)
            }
            if temp == 1 || temp == 3 || temp == 5 {
                if x_r.count >= 4 {
                    x_r.removeFirst()
                    x_r.removeFirst()
                    x_r.removeLast()
                    x_r.removeLast()
                }
            }
            temp += 1
        }
    }

    // MARK: Shooting

    private func shootBullet() {
        guard bulletInFlight == nil else { return }
        let bullet: SKSpriteNode
        if let image = Bundle.main.image(forResource: "bullet") {
            let texture = SKTexture(image: image)
            bullet = SKSpriteNode(texture: texture)
        } else {
            bullet = SKSpriteNode(color: .yellow, size: CGSize(width: 10, height: 10))
        }
        bullet.size = CGSize(width: 10, height: 10)
        bullet.position = CGPoint(x: ship.position.x, y: ship.position.y + 30)
        bullet.name = "playerBullet"
        addChild(bullet)
        bulletInFlight = bullet
    }

    private func fireAlienBullets(currentTime: TimeInterval) {
        if currentTime - lastAlienFireTime < alienFireInterval { return }
        lastAlienFireTime = currentTime
        if aliens.isEmpty { return }

        let sampleCount = min(2, aliens.count)
        let randomAliens = aliens.shuffled().prefix(sampleCount)
        for alien in randomAliens {
            let ab: SKSpriteNode
            if let image = Bundle.main.image(forResource: "alienBullet") {
                let texture = SKTexture(image: image)
                ab = SKSpriteNode(texture: texture)
            } else {
                ab = SKSpriteNode(color: .orange, size: CGSize(width: 10, height: 30))
            }
            ab.size = CGSize(width: 10, height: 30)
            ab.position = CGPoint(x: alien.position.x, y: alien.position.y - 20)
            ab.name = "alienBullet"
            addChild(ab)
        }
    }

    // MARK: Game Loop

    override func update(_ currentTime: TimeInterval) {
        if isGameOver { return }
        moveAliens()
        fireAlienBullets(currentTime: currentTime)
        updateBullets(deltaTime: 1.0 / 60.0)
        checkCollisions()
    }

    private func moveAliens() {
        if alienOffset <= 0 {
            alienDirection = .right
        } else if alienOffset >= 100 {
            alienDirection = .left
        }

        let delta: CGFloat = (alienDirection == .left ? -2 : 2)
        alienOffset += (alienDirection == .left ? -2 : 2)

        for alien in aliens {
            alien.position.x += delta
        }
    }

    private func updateBullets(deltaTime: CGFloat) {
        if let blt = bulletInFlight {
            blt.position.y += bulletSpeed * deltaTime
            if blt.position.y > size.height {
                blt.removeFromParent()
                bulletInFlight = nil
            }
        }

        for node in children where node.name == "alienBullet" {
            node.position.y -= alienBulletSpeed * deltaTime
            if node.position.y < 0 {
                node.removeFromParent()
            }
        }
    }

    // MARK: Collisions

    private func checkCollisions() {
        if let blt = bulletInFlight {
            for (i, alien) in aliens.enumerated().reversed() {
                if blt.frame.intersects(alien.frame) {
                    alien.removeFromParent()
                    aliens.remove(at: i)
                    blt.removeFromParent()
                    bulletInFlight = nil
                    break
                }
            }
            for (i, rock) in rocks.enumerated().reversed() {
                if blt.frame.intersects(rock.frame) {
                    rock.removeFromParent()
                    rocks.remove(at: i)
                    blt.removeFromParent()
                    bulletInFlight = nil
                    break
                }
            }
        }

        for node in children where node.name == "alienBullet" {
            for (i, rock) in rocks.enumerated().reversed() {
                if node.frame.intersects(rock.frame) {
                    rock.removeFromParent()
                    rocks.remove(at: i)
                    node.removeFromParent()
                    break
                }
            }
        }

        for node in children where node.name == "alienBullet" {
            if node.frame.intersects(ship.frame) {
                node.removeFromParent()
                ship.removeFromParent()
                triggerGameOver()
                break
            }
        }
    }

    private func triggerGameOver() {
        isGameOver = true
        showGameOver()
    }

    private func showGameOver() {
        let overlay = SKSpriteNode(color: .black, size: size)
        overlay.alpha = 0.7
        overlay.position = CGPoint(x: size.width/2, y: size.height/2)
        overlay.zPosition = 100
        addChild(overlay)

        if let image = Bundle.main.image(forResource: "gameOver") {
            let texture = SKTexture(image: image)
            let go = SKSpriteNode(texture: texture)
            go.position = CGPoint(x: size.width/2, y: size.height/2)
            go.zPosition = 101
            addChild(go)
        } else {
            let label = SKLabelNode(text: "GAME OVER")
            label.fontName = "AvenirNext-Bold"
            label.fontSize = 44
            label.position = CGPoint(x: size.width/2, y: size.height/2)
            label.zPosition = 101
            addChild(label)
        }
    }

    // MARK: Keyboard control for macOS

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 123: // left arrow
            moveShipToward(x: ship.position.x - 40)
        case 124: // right arrow
            moveShipToward(x: ship.position.x + 40)
        case 49: // space
            shootBullet()
        default:
            break
        }
    }

    private func moveShipToward(x targetX: CGFloat) {
        let clampedX = min(max(targetX, 40), size.width - 40)
        ship.position.x = clampedX
    }
}