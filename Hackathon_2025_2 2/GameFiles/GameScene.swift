//
//  GameScene.swift
//  Hackathon_2025_2
//
//  Redesigned for an educational mini-game with falling words.
//

import SpriteKit
import AVFoundation
import SwiftUI
import UIKit

// MARK: - Notifications to bridge GameScene -> SwiftUI
extension Notification.Name {
    static let gameScoreDidChange = Notification.Name("GameScoreDidChange")
    static let gameTimeDidChange  = Notification.Name("GameTimeDidChange")
    static let gameDidEnd         = Notification.Name("GameDidEnd")
}

// MARK: - Physics Categories
fileprivate struct PhysicsCategory {
    static let none: UInt32  = 0
    static let hero: UInt32  = 1 << 0
    static let good: UInt32  = 1 << 1
    static let bad:  UInt32  = 1 << 2
    static let ground: UInt32 = 1 << 3
}

// MARK: - Entities (factory helpers)
fileprivate enum HeroFactory {
    static func make(at position: CGPoint) -> SKSpriteNode {
        // CAMBIO: Aumentamos el tamaño del héroe para que sea más grande (antes 90x135)
        let node = SKSpriteNode(color: .clear, size: CGSize(width: 120, height: 180))
        node.name = "hero"
        node.position = position
        node.zPosition = 10
        node.anchorPoint = CGPoint(x: 0.5, y: 0.5)

        // Física: cuerpo rectangular, sin rotación, en el suelo
        node.physicsBody = SKPhysicsBody(rectangleOf: node.size)
        node.physicsBody?.isDynamic = true
        node.physicsBody?.allowsRotation = false
        node.physicsBody?.affectedByGravity = true
        node.physicsBody?.categoryBitMask = PhysicsCategory.hero
        node.physicsBody?.contactTestBitMask = PhysicsCategory.good | PhysicsCategory.bad | PhysicsCategory.ground
        node.physicsBody?.collisionBitMask = PhysicsCategory.ground
        node.physicsBody?.mass = 0.5
        return node
    }
}

fileprivate enum WordFactory {
    static func makeGood(text: String, at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.name = "goodWord"
        container.position = position
        container.zPosition = 5

        let label = SKLabelNode(fontNamed: "Avenir-Heavy")
        label.text = text
        label.fontSize = 26
        label.fontColor = .systemGreen
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 1

        // Fondo redondeado para dar aspecto de chip
        let bg = SKShapeNode(rectOf: CGSize(width: max(100, label.frame.width + 24), height: 40), cornerRadius: 12)
        bg.fillColor = .systemGreen.withAlphaComponent(0.15)
        bg.strokeColor = .systemGreen
        bg.lineWidth = 2
        bg.zPosition = 0

        // Física usando el tamaño del fondo
        container.physicsBody = SKPhysicsBody(rectangleOf: bg.frame.size)
        container.physicsBody?.isDynamic = true
        // CAMBIO: Desactivamos la gravedad y controlamos la caída manualmente
        container.physicsBody?.affectedByGravity = false
        // CAMBIO: Aseguramos caída constante sin freno aerodinámico
        container.physicsBody?.linearDamping = 0
        // CAMBIO: Sin rebote al tocar el suelo
        container.physicsBody?.restitution = 0
        container.physicsBody?.allowsRotation = false
        container.physicsBody?.categoryBitMask = PhysicsCategory.good
        container.physicsBody?.contactTestBitMask = PhysicsCategory.hero | PhysicsCategory.ground
        container.physicsBody?.collisionBitMask = PhysicsCategory.ground

        container.addChild(bg)
        container.addChild(label)
        return container
    }

    static func makeBad(text: String, at position: CGPoint) -> SKNode {
        let container = SKNode()
        container.name = "badWord"
        container.position = position
        container.zPosition = 5

        let label = SKLabelNode(fontNamed: "Avenir-Black")
        label.text = text
        label.fontSize = 26
        label.fontColor = .systemRed
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        label.zPosition = 1

        let bg = SKShapeNode(rectOf: CGSize(width: max(100, label.frame.width + 24), height: 40), cornerRadius: 12)
        bg.fillColor = .systemRed.withAlphaComponent(0.15)
        bg.strokeColor = .systemRed
        bg.lineWidth = 2
        bg.zPosition = 0

        // Física usando el tamaño del fondo
        container.physicsBody = SKPhysicsBody(rectangleOf: bg.frame.size)
        container.physicsBody?.isDynamic = true
        // CAMBIO: Desactivamos la gravedad y controlamos la caída manualmente
        container.physicsBody?.affectedByGravity = false
        // CAMBIO: Aseguramos caída constante sin freno aerodinámico
        container.physicsBody?.linearDamping = 0
        // CAMBIO: Sin rebote al tocar el suelo
        container.physicsBody?.restitution = 0
        container.physicsBody?.allowsRotation = false
        container.physicsBody?.categoryBitMask = PhysicsCategory.bad
        container.physicsBody?.contactTestBitMask = PhysicsCategory.hero | PhysicsCategory.ground
        container.physicsBody?.collisionBitMask = PhysicsCategory.ground

        container.addChild(bg)
        container.addChild(label)
        return container
    }
}

final class GameScene: SKScene, SKPhysicsContactDelegate {
    private let showsInSceneHUD: Bool = false

    private let textures = Textures()
    // CAMBIO: Velocidad de movimiento lateral del héroe (puntos por segundo)
    private let heroMoveSpeed: CGFloat = 300
    // CAMBIO: Velocidad de caída de las palabras (puntos por segundo)
    private let wordFallSpeed: CGFloat = 300
    // CAMBIO: Objetivo X para movimiento suave del héroe
    private var targetX: CGFloat? = nil
    // CAMBIO: Tiempo previo para calcular delta en update()
    private var lastUpdateTime: TimeInterval = 0

    // MARK: - Animation
    private var walkingFrames: [SKTexture] = []
    private var apngTimePerFrame: Double? = nil
    private var isWalking: Bool = false
    // Frames para animación al chocar con palabra mala (fut_balon)
    private var hitFrames: [SKTexture] = []

    // MARK: - Game State
    private var hero: SKSpriteNode!
    private var ground: SKSpriteNode!

    private var scoreLabel = SKLabelNode(fontNamed: "Avenir-Heavy")
    private var timeLabel = SKLabelNode(fontNamed: "Avenir-Heavy")

    private var score: Int = 0 { didSet { updateScoreLabel() } }
    private var timeRemaining: Int = 60 { didSet { updateTimeLabel() } }
    private var isGameOver: Bool = false

    private var spawnTimer: Timer?
    private var gameTimer: Timer?

    // MARK: - External Pause/Resume API
    func pauseScene() {
        isPaused = true
        spawnTimer?.invalidate()
        gameTimer?.invalidate()
    }

    func resumeScene() {
        guard !isGameOver else { return }
        isPaused = false
        // Reactivar timers si estaban detenidos
        spawnTimer?.invalidate()
        gameTimer?.invalidate()
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: true) { [weak self] _ in
            guard let self = self, !self.isGameOver else { return }
            self.spawnRandomWord()
        }
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.isGameOver { return }
            self.timeRemaining -= 1
            if self.timeRemaining <= 0 { self.endGame() }
        }
    }

    // Palabras de ejemplo; puedes personalizarlas o cargarlas de otro lugar
    private let goodWords = [
        "Poder","Fuerza","Valiente","Confía","Capaz","Resiliencia","Determinación","Inteligente"
    ]
    private let badWords = [
        "Insuficiente","Incapaz","Debil","No Puedes", "Para"
    ]

    // Sonidos simples (añade estos archivos al bundle si lo deseas)
    private let goodSound = "good.wav" // opcional
    private let badSound  = "bad.wav"  // opcional

    // MARK: - Lifecycle
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        configureWorld()
        createGround()
        createHero()
        createHUD()
        loadWalkingTextures()
        startGame()

        NotificationCenter.default.addObserver(forName: .gameDidPause, object: nil, queue: .main) { [weak self] _ in
            self?.pauseScene()
        }
        NotificationCenter.default.addObserver(forName: .gameDidResume, object: nil, queue: .main) { [weak self] _ in
            self?.resumeScene()
        }
    }

    // MARK: - World Setup
    private func configureWorld() {
        backgroundColor = UIColor(red: 0/255, green: 18/255, blue: 27/255, alpha: 1)
        physicsWorld.gravity = CGVector(dx: 0, dy: -9.8)
        physicsWorld.contactDelegate = self
    }

    private func createGround() {
        let height: CGFloat = 80
        ground = SKSpriteNode(color: .darkGray, size: CGSize(width: size.width * 2, height: height))
        ground.position = CGPoint(x: size.width / 2, y: height / 2)
        ground.zPosition = 1
        ground.name = "ground"
        ground.physicsBody = SKPhysicsBody(rectangleOf: ground.size)
        ground.physicsBody?.isDynamic = false
        ground.physicsBody?.categoryBitMask = PhysicsCategory.ground
        ground.physicsBody?.contactTestBitMask = PhysicsCategory.hero | PhysicsCategory.good | PhysicsCategory.bad
        ground.physicsBody?.collisionBitMask = PhysicsCategory.hero | PhysicsCategory.good | PhysicsCategory.bad
        addChild(ground)
    }

    private func createHero() {
        // CAMBIO: Posicionamos al héroe justo sobre el suelo según su altura real
        let provisionalStart = CGPoint(x: size.width / 2, y: ground.frame.maxY + 1)
        hero = HeroFactory.make(at: provisionalStart)
        addChild(hero)
        // Ajuste final de Y usando la mitad de la altura del héroe
        hero.position.y = ground.frame.maxY + hero.size.height / 2
    }

    // MARK: - Hero Animation
    private func loadWalkingTextures() {
        // Usar directamente las texturas definidas en Textures.arboldcaminar
        walkingFrames = textures.arboldcaminar
        // Cargar animación de golpe (fut_balon)
        hitFrames = textures.fut_balon
        apngTimePerFrame = 0.1 // como en el ejemplo solicitado

        // Aplicar primer frame al héroe si existe
        if let first = walkingFrames.first, hero != nil {
            hero.texture = first
            hero.color = .white
            hero.colorBlendFactor = 0.0
        }
    }

    private func startWalkingAnimation() {
        guard !isGameOver else { return }
        guard !walkingFrames.isEmpty else { return }
        // Evitar múltiples animaciones simultáneas
        guard hero.action(forKey: "walk") == nil else { return }
        isWalking = true
        if walkingFrames.count > 1 {
            let heroRunAnimation = SKAction.animate(with: walkingFrames, timePerFrame: apngTimePerFrame ?? 0.1)
            let heroRun = SKAction.repeatForever(heroRunAnimation)
            hero.run(heroRun, withKey: "walk")
        } else {
            hero.texture = walkingFrames[0]
        }
    }

    private func stopWalkingAnimation() {
        isWalking = false
        hero.removeAction(forKey: "walk")
        // Optionally set the first frame as idle
        if let first = walkingFrames.first {
            hero.texture = first
        }
    }

    // Animación al colisionar con palabra mala
    private func playHitAnimation() {
        guard !hitFrames.isEmpty else { return }
        // Evitar superponer múltiples animaciones de golpe
        guard hero.action(forKey: "hit") == nil else { return }

        // Pausar temporalmente la animación de caminar sin cambiar el estado isWalking
        hero.removeAction(forKey: "walk")

        let animate = SKAction.animate(with: hitFrames, timePerFrame: 0.08)
        let completion = SKAction.run { [weak self] in
            guard let self = self else { return }
            // Restaurar textura/animación según si estaba caminando
            if self.isWalking {
                self.startWalkingAnimation()
            } else if let first = self.walkingFrames.first {
                self.hero.texture = first
            }
        }
        let sequence = SKAction.sequence([animate, completion])
        hero.run(sequence, withKey: "hit")
    }

    private func createHUD() {
        // Configure labels (they may or may not be added to the scene depending on showsInSceneHUD)
        scoreLabel.fontSize = 22
        scoreLabel.fontColor = .white
        scoreLabel.horizontalAlignmentMode = .left
        scoreLabel.verticalAlignmentMode = .top
        scoreLabel.position = CGPoint(x: 16, y: size.height - 16)
        scoreLabel.zPosition = 100

        timeLabel.fontSize = 22
        timeLabel.fontColor = .white
        timeLabel.horizontalAlignmentMode = .right
        timeLabel.verticalAlignmentMode = .top
        timeLabel.position = CGPoint(x: size.width - 16, y: size.height - 16)
        timeLabel.zPosition = 100

        // Only add HUD labels to the SpriteKit scene if explicitly enabled
        if showsInSceneHUD {
            if scoreLabel.parent == nil { addChild(scoreLabel) }
            if timeLabel.parent == nil { addChild(timeLabel) }
        } else {
            // Ensure they are not in the scene if previously added (e.g., after a restart)
            scoreLabel.removeFromParent()
            timeLabel.removeFromParent()
        }

        updateScoreLabel()
        updateTimeLabel()
    }

    private func updateScoreLabel() {
        scoreLabel.text = "Puntos: \(score)"
        NotificationCenter.default.post(name: .gameScoreDidChange, object: nil, userInfo: ["score": score])
    }

    private func updateTimeLabel() {
        timeLabel.text = "Tiempo: \(timeRemaining)s"
        NotificationCenter.default.post(name: .gameTimeDidChange, object: nil, userInfo: ["time": timeRemaining])
    }

    // MARK: - Game Flow
    private func startGame() {
        isGameOver = false
        score = 0
        timeRemaining = 60

        spawnTimer?.invalidate()
        gameTimer?.invalidate()

        // Spawner de palabras (intervalo aleatorio)
        spawnTimer = Timer.scheduledTimer(withTimeInterval: 0.9, repeats: true) { [weak self] _ in
            guard let self = self, !self.isGameOver else { return }
            self.spawnRandomWord()
        }

        // Temporizador de juego (cuenta regresiva)
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            if self.isGameOver { return }
            self.timeRemaining -= 1
            if self.timeRemaining <= 0 { self.endGame() }
        }
    }

    private func endGame() {
        guard !isGameOver else { return }
        stopWalkingAnimation()
        isGameOver = true
        spawnTimer?.invalidate()
        gameTimer?.invalidate()
/*
        // Mostrar mensaje de fin
        let overlay = SKShapeNode(rectOf: CGSize(width: size.width * 0.8, height: 180), cornerRadius: 24)
        overlay.fillColor = .black.withAlphaComponent(0.7)
        overlay.strokeColor = .white.withAlphaComponent(0.3)
        overlay.lineWidth = 1
        overlay.position = CGPoint(x: size.width/2, y: size.height/2)
        overlay.zPosition = 200

        let title = SKLabelNode(fontNamed: "Avenir-Black")
        title.text = "¡Tiempo agotado!"
        title.fontSize = 28
        title.fontColor = .white
        title.position = CGPoint(x: 0, y: 40)
        title.zPosition = 201

        let subtitle = SKLabelNode(fontNamed: "Avenir-Heavy")
        subtitle.text = "Puntaje: \(score)"
        subtitle.fontSize = 22
        subtitle.fontColor = .white
        subtitle.position = CGPoint(x: 0, y: -10)
        subtitle.zPosition = 201

        let hint = SKLabelNode(fontNamed: "Avenir")
        hint.text = "Toca para reiniciar"
        hint.fontSize = 16
        hint.fontColor = .white.withAlphaComponent(0.9)
        hint.position = CGPoint(x: 0, y: -60)
        hint.zPosition = 201

        overlay.addChild(title)
        overlay.addChild(subtitle)
        overlay.addChild(hint)
        overlay.name = "gameOverOverlay"
        addChild(overlay)
*/
        NotificationCenter.default.post(name: .gameDidEnd, object: nil, userInfo: [
            "score": score,
            "time": timeRemaining
        ])
    }

    private func resetSceneForRestart() {
        // Eliminar palabras restantes
        enumerateChildNodes(withName: "goodWord") { node, _ in node.removeFromParent() }
        enumerateChildNodes(withName: "badWord") { node, _ in node.removeFromParent() }
        childNode(withName: "gameOverOverlay")?.removeFromParent()

        // Reposicionar heroína al centro
        hero.position.x = size.width / 2
        hero.physicsBody?.velocity = .zero

        startGame()
    }

    // MARK: - Spawning
    private func spawnRandomWord() {
        let isGood = Bool.random()
        let x = CGFloat.random(in: 40...(size.width - 40))
        let startY = size.height + 40
        let position = CGPoint(x: x, y: startY)

        let node: SKNode
        if isGood {
            let word = goodWords.randomElement() ?? "Apoyo"
            node = WordFactory.makeGood(text: word, at: position)
        } else {
            let word = badWords.randomElement() ?? "Violencia"
            node = WordFactory.makeBad(text: word, at: position)
        }

        addChild(node)

        // Pequeño empuje horizontal aleatorio para variedad
        let vx = CGFloat.random(in: -40...40)
        // CAMBIO: Establecemos velocidad de caída constante hacia abajo y sin gravedad
        node.physicsBody?.velocity = CGVector(dx: vx, dy: -wordFallSpeed)
    }

    // MARK: - Touch Controls (move hero horizontally)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else {
            resetSceneForRestart()
            return
        }
        moveHero(with: touches)
        startWalkingAnimation()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        moveHero(with: touches)
        startWalkingAnimation()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        stopWalkingAnimation()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard !isGameOver else { return }
        stopWalkingAnimation()
    }

    private func moveHero(with touches: Set<UITouch>) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        // Solo mover en X, clamped a los bordes
        let clamped = min(max(location.x, 40), size.width - 40)

        // CAMBIO: En lugar de mover instantáneamente o con acciones en cada touch,
        // guardamos un objetivo y nos desplazamos suavemente en update()
        targetX = clamped

        // CAMBIO: Ajustamos orientación según el objetivo
        if let current = hero?.position.x {
            let movingRight = clamped > current
            hero.xScale = abs(hero.xScale) * (movingRight ? 1.0 : -1.0)
        }
    }

    // MARK: - Contact Handling
    func didBegin(_ contact: SKPhysicsContact) {
        let a = contact.bodyA
        let b = contact.bodyB

        // Ordenar por categoría para simplificar
        let first: SKPhysicsBody
        let second: SKPhysicsBody
        if a.categoryBitMask < b.categoryBitMask {
            first = a; second = b
        } else {
            first = b; second = a
        }

        if first.categoryBitMask == PhysicsCategory.hero && second.categoryBitMask == PhysicsCategory.good {
            if let node = second.node { handleGoodCollision(node: node) }
        } else if first.categoryBitMask == PhysicsCategory.hero && second.categoryBitMask == PhysicsCategory.bad {
            if let node = second.node { handleBadCollision(node: node) }
        }
        // CAMBIO: Eliminar palabras al tocar el suelo (no afectan al héroe)
        else if (first.categoryBitMask == PhysicsCategory.good && second.categoryBitMask == PhysicsCategory.ground) {
            if let node = first.node { handleWordHitGround(node: node) }
        } else if (first.categoryBitMask == PhysicsCategory.bad && second.categoryBitMask == PhysicsCategory.ground) {
            if let node = first.node { handleWordHitGround(node: node) }
        } else if (first.categoryBitMask == PhysicsCategory.ground && second.categoryBitMask == PhysicsCategory.good) {
            if let node = second.node { handleWordHitGround(node: node) }
        } else if (first.categoryBitMask == PhysicsCategory.ground && second.categoryBitMask == PhysicsCategory.bad) {
            if let node = second.node { handleWordHitGround(node: node) }
        }
    }

    private func handleGoodCollision(node: SKNode) {
        // Sumar puntos y eliminar la palabra
        score += 1
        playSoundIfAvailable(named: goodSound)
        collectAnimation(on: node, tint: .systemGreen)
    }

    private func handleBadCollision(node: SKNode) {
        // Restar tiempo y eliminar la palabra
        timeRemaining = max(0, timeRemaining - 3)
        playSoundIfAvailable(named: badSound)
        collectAnimation(on: node, tint: .systemRed)
        // Reproducir animación de golpe (fut_balon)
        playHitAnimation()
        if timeRemaining == 0 { endGame() }
    }

    // CAMBIO: Manejo cuando una palabra toca el suelo
    private func handleWordHitGround(node: SKNode) {
        // Pequeño efecto y eliminación inmediata
        let fade = SKAction.fadeOut(withDuration: 0.05)
        node.run(SKAction.sequence([fade, .removeFromParent()]))
    }

    private func collectAnimation(on node: SKNode, tint: UIColor) {
        let fade = SKAction.fadeOut(withDuration: 0.15)
        let scale = SKAction.scale(to: 1.2, duration: 0.15)
        let colorize: SKAction
        if let shape = node.children.first(where: { $0 is SKShapeNode }) as? SKShapeNode {
            colorize = SKAction.run { shape.fillColor = tint.withAlphaComponent(0.35) }
        } else {
            colorize = SKAction.wait(forDuration: 0.01)
        }
        let group = SKAction.group([fade, scale, colorize])
        node.run(SKAction.sequence([group, .removeFromParent()]))
    }

    private func playSoundIfAvailable(named: String) {
        guard !named.isEmpty else { return }
        run(SKAction.playSoundFileNamed(named, waitForCompletion: false))
    }

    // MARK: - Housekeeping
    override func update(_ currentTime: TimeInterval) {
        guard !isGameOver else { return }

        // CAMBIO: Movimiento suave del héroe basado en delta de tiempo
        let dt: TimeInterval
        if lastUpdateTime == 0 {
            dt = 0
        } else {
            dt = currentTime - lastUpdateTime
        }
        lastUpdateTime = currentTime

        if let tx = targetX {
            let currentX = hero.position.x
            let dx = tx - currentX
            let absdx = abs(dx)
            // Avance máximo permitido este frame en función de la velocidad configurada
            let maxStep = heroMoveSpeed * CGFloat(dt)
            if absdx <= maxStep || maxStep == 0 {
                hero.position.x = tx
            } else {
                hero.position.x = currentX + (dx > 0 ? maxStep : -maxStep)
            }
        }

        // Eliminar palabras que ya pasaron la pantalla
        enumerateChildNodes(withName: "goodWord") { node, _ in
            if node.position.y < -60 { node.removeFromParent() }
        }
        enumerateChildNodes(withName: "badWord") { node, _ in
            if node.position.y < -60 { node.removeFromParent() }
        }
    }
}

