//
//  GameSceneChapter3.swift
//  ChangeIt1
//
//  Created by yatziri on 17/02/25.
//
import SpriteKit
import GameplayKit
import AVFoundation
import SwiftUI

class GameSceneChapter3: SKScene {
    
    var gameLogic: ArcadeGameLogic = ArcadeGameLogic.shared
    
    var gameIsEnd = false {
        didSet {
            endGame()
        }
    }
    var isplants: Bool = false
    var backgroundMusicPlayer: AVAudioPlayer?
    var gameIsPaused = false
    var heroIsDead = false
    var isHeroAnimating = false
    
    var heroSpriteNode = SKSpriteNode()
    var heroNode = SKNode()
    var holesArray = [SKSpriteNode]()
    var plantedPoints = 0
    var timer = Timer()
    
    let textures = Textures()
    var lastPointPosition: CGPoint?
    
    var swipeIndicator: SKSpriteNode?
    var firstTouch = false
    
    var touchLocation: CGPoint?
    var moveSpeed: CGFloat = 300.0 // Velocidad de movimiento
//    var firstTouch = false
    
    var wallSpriteNode = SKSpriteNode()
    var wallNode = SKNode()
    
    var secondWallSpriteNode = SKSpriteNode()
    var secondWallNode = SKNode()
    
    var groundSpriteNode = SKSpriteNode()
    var groundNode = SKNode()
    
    var heroMask: UInt32 = 1
    var pointMask: UInt32 = 5
    var wallMask: UInt32 = 3
    var groundMask : UInt32 = 2
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        physicsWorld.contactDelegate = self
        initialSetUp()
        
        showSwipeIndicator()
    }
    
    func initialSetUp() {
        let backgroundNode = SKSpriteNode(texture: SKTexture(imageNamed: "Planta_Ground"), size: size)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.zPosition = -10
        addChild(backgroundNode)
        
        createHero()
        createHoles()
        createWall()
        createGround()
        startSpawningPoints()
        
        playBackgroundMusic()
        gameLogic.passLever3()
    }
    
    /// Muestra la imagen de gesto de deslizamiento para indicar el movimiento del héroe en todas las direcciones
    func showSwipeIndicator() {
        if let swipeImage = renderSFIcon(systemName: "hand.draw.fill", color: .white, size: CGSize(width: 90, height: 90)) {
            let texture = SKTexture(image: swipeImage)
            swipeIndicator = SKSpriteNode(texture: texture)
            
            swipeIndicator?.position = CGPoint(x: size.width / 2, y: size.height / 4)
            swipeIndicator?.zPosition = 10
            swipeIndicator?.setScale(1.5)

            if let swipeIndicator = swipeIndicator {
                addChild(swipeIndicator)
                
                // Animación en cuatro direcciones (arriba, abajo, izquierda, derecha)
                let moveUp = SKAction.moveBy(x: 0, y: 50, duration: 0.5)
                let moveDown = SKAction.moveBy(x: 0, y: -50, duration: 0.5)
                let moveLeft = SKAction.moveBy(x: -50, y: 0, duration: 0.5)
                let moveRight = SKAction.moveBy(x: 50, y: 0, duration: 0.5)

                let sequence = SKAction.sequence([moveUp, moveDown, moveLeft, moveRight])
                let repeatAnimation = SKAction.repeatForever(sequence)

                swipeIndicator.run(repeatAnimation)
            }
        }
    }
    
    /// Función para convertir un SF Symbol en una textura con color y tamaño personalizados
    func renderSFIcon(systemName: String, color: UIColor, size: CGSize) -> UIImage? {
        let config = UIImage.SymbolConfiguration(pointSize: size.width, weight: .bold)
        let symbol = UIImage(systemName: systemName, withConfiguration: config)?
            .withTintColor(color, renderingMode: .alwaysOriginal)
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        symbol?.draw(in: CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image
    }

    func createGround() {
        groundSpriteNode.position = CGPoint.zero
        groundSpriteNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: size.width * 2, height: 60))
        groundSpriteNode.physicsBody?.isDynamic = false
        groundSpriteNode.physicsBody?.categoryBitMask = groundMask
        groundSpriteNode.zPosition = 1
        
        groundNode.addChild(groundSpriteNode)
    }
    
    func createWall() {
        
        wallSpriteNode.position = CGPoint.zero
        wallSpriteNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 100, height: size.height * 2))
        wallSpriteNode.physicsBody?.isDynamic = false
        wallSpriteNode.physicsBody?.categoryBitMask = wallMask
        wallSpriteNode.zPosition = 1
        
        secondWallSpriteNode.position = CGPoint(x: size.width + 100, y: 0)
        secondWallSpriteNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: 60, height: size.height * 2))
        secondWallSpriteNode.physicsBody?.isDynamic = false
        secondWallSpriteNode.physicsBody?.categoryBitMask = wallMask
        secondWallSpriteNode.zPosition = 1
        
        secondWallNode.addChild(secondWallSpriteNode)
        wallNode.addChild(wallSpriteNode)
    }
    
    func playBackgroundMusic() {
        if let musicURL = Bundle.main.url(forResource: "Chapter333-Song", withExtension: "mp3") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                backgroundMusicPlayer?.numberOfLoops = -1
                backgroundMusicPlayer?.volume = 0.7
                backgroundMusicPlayer?.play()
            } catch {
                print("Error al reproducir la música: \(error.localizedDescription)")
            }
        } else {
            print("Archivo de música no encontrado")
        }
    }
    
    func createHero() {
        heroSpriteNode = SKSpriteNode(texture: SKTexture(imageNamed: "walk-1"))
        let heroRunAnimation = SKAction.animate(with: textures.arboldcaminar, timePerFrame: 0.16)
        let heroRun = SKAction.repeatForever(heroRunAnimation)
        heroSpriteNode.run(heroRun)
        
        heroSpriteNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        heroSpriteNode.zPosition = 3
        heroSpriteNode.setScale(0.2)
        
        heroSpriteNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: heroSpriteNode.size.width * 0.4, height: heroSpriteNode.size.height * 0.4))
        heroSpriteNode.physicsBody?.categoryBitMask = heroMask
        heroSpriteNode.physicsBody?.collisionBitMask = wallMask // Solo colisiona con paredes
        heroSpriteNode.physicsBody?.contactTestBitMask = pointMask // Detecta contacto con puntos
        heroSpriteNode.physicsBody?.isDynamic = true
        heroSpriteNode.physicsBody?.affectedByGravity = false
        heroSpriteNode.physicsBody?.allowsRotation = false
        
        addChild(heroSpriteNode)
    }
    
    func createHoles() {
        let positions: [CGPoint] = [
            CGPoint(x: size.width * 0.2, y: size.height * 0.65),
            CGPoint(x: size.width * 0.5, y: size.height * 0.65),
            CGPoint(x: size.width * 0.8, y: size.height * 0.65),
            CGPoint(x: size.width * 0.2, y: size.height * 0.23),
            CGPoint(x: size.width * 0.5, y: size.height * 0.23),
            CGPoint(x: size.width * 0.8, y: size.height * 0.23)
        ]
        
        for position in positions {
            let hole = SKSpriteNode(texture: SKTexture(imageNamed: "hole_planta"))
            hole.position = position
            hole.zPosition = 2
            hole.setScale(0.5)
            
            holesArray.append(hole)
            addChild(hole)
        }
    }
    
    func startSpawningPoints() {
       
            let spawnAction = SKAction.run {
                self.spawnPoint()
            }
            let waitAction = SKAction.wait(forDuration: 2.7)
            let sequence = SKAction.sequence([spawnAction, waitAction])
            run(SKAction.repeatForever(sequence))
            isplants = false
        
    }
    
    
    func spawnPoint() {
        if gameLogic.isGameWin == false {
            guard let hole = holesArray.randomElement() else { return }
            
            // Verificar si el nuevo punto es el mismo que el último
            if let lastPosition = lastPointPosition, lastPosition == hole.position {
                return // 🔴 Si es igual, no generamos un nuevo punto
            }
            
            lastPointPosition = hole.position // 🔴 Actualizar la última posición generada
            
            let point = SKSpriteNode(texture: SKTexture(imageNamed: "Planta_point"))
            point.position = hole.position
            point.zPosition = 3
            point.setScale(0.5)
            
            point.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: point.size.width * 0.5, height: point.size.height * 0.5))
            point.physicsBody?.categoryBitMask = pointMask
            point.physicsBody?.contactTestBitMask = heroMask
            point.physicsBody?.collisionBitMask = 0 // No colisiona con nada
            point.physicsBody?.isDynamic = false
            
            addChild(point)
            
            let disappearAction = SKAction.sequence([SKAction.wait(forDuration: 1.5), SKAction.removeFromParent()])
            point.run(disappearAction)
        }
    }
    
    
    func plantSeed(at position: CGPoint) {
        plantedPoints += 1
        let plantTextureName = "Planta\(plantedPoints)"
        let plant = SKSpriteNode(texture: SKTexture(imageNamed: plantTextureName))
        plant.position = position
        plant.zPosition = 4
        plant.setScale(1.0)
        
        addChild(plant)
        
        if plantedPoints >= 4 {
            winGame()
        }
    }
    
    func winGame() {
        gameLogic.isGameWin = true
        print("¡Ganaste!")
    }
    
    private func restartGame() {
        self.gameLogic.restartGame()
        gameIsEnd = true
    }
    
    func endGame() {
        if gameIsEnd == true {
            stopBackgroundMusic()
            timer.invalidate() // 🔴 Esto evita que procesos sigan corriendo después del final del juego
            children.forEach { node in
                node.removeAllActions()
                node.children.forEach { node in
                    node.removeAllActions()
                }
            }
        }
    }
    
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
   
    
    func animateHeroWithPlantMan(pointPosition: CGPoint) {
        guard !isHeroAnimating else { return } // Evita que se llame dos veces si ya está animando

        isHeroAnimating = true // Bloquea el movimiento del héroe temporalmente

        let originalScaleX = heroSpriteNode.xScale // Guardamos la escala original en X
        let originalScaleY = heroSpriteNode.yScale // Guardamos la escala original en Y

        //  Asegurar que la escala Y no se modifique (Evita volteo de cabeza)
        heroSpriteNode.yScale = abs(originalScaleY)

        // Reducimos temporalmente la escala del héroe para la animación (Solo en X)
        let shrinkAction = SKAction.scaleX(to: 0.2, duration: 0.1)

        // Declaramos la variable antes del if
        let heroPlantAnimation: SKAction

        if pointPosition.x > heroSpriteNode.position.x {
            heroPlantAnimation = SKAction.animate(with: textures.Plant_man, timePerFrame: 0.1)
        } else {
            heroPlantAnimation = SKAction.animate(with: textures.Plant_man_derecha, timePerFrame: 0.1)
        }

        // Restauramos la escala original después de la animación y permitimos el movimiento de nuevo
        let restoreAction = SKAction.sequence([
            SKAction.scaleX(to: originalScaleX, duration: 0.1),
            SKAction.run {
                self.isHeroAnimating = false //  Permitir que el héroe se mueva de nuevo
                self.heroSpriteNode.yScale = abs(originalScaleY) //  Asegurar que Y nunca se invierta
            }
        ])

        // Secuencia: reducir -> animar -> restaurar
        let heroAnimationSequence = SKAction.sequence([shrinkAction, heroPlantAnimation, restoreAction])
        
        heroSpriteNode.run(heroAnimationSequence)
    }





    
    
    func moveHeroTo(targetX: CGFloat, targetY: CGFloat) {
        let leftLimit = wallSpriteNode.position.x + (wallSpriteNode.frame.width / 2)
        let rightLimit = secondWallSpriteNode.position.x - (secondWallSpriteNode.frame.width / 2)
        
        let bottomLimit: CGFloat = 50
        let topLimit: CGFloat = size.height - 50

        let tolerance: CGFloat = 5.0

        if !heroIsDead {
            let deltaX = targetX - heroSpriteNode.position.x
            let deltaY = targetY - heroSpriteNode.position.y
            let distance = sqrt(deltaX * deltaX + deltaY * deltaY)

            if distance < tolerance { return }

            let directionX = deltaX / distance
            let directionY = deltaY / distance

            var newPositionX = heroSpriteNode.position.x + directionX * moveSpeed * (1.0 / 60.0)
            var newPositionY = heroSpriteNode.position.y + directionY * moveSpeed * (1.0 / 60.0)

            newPositionX = max(leftLimit, min(newPositionX, rightLimit))
            newPositionY = max(bottomLimit, min(newPositionY, topLimit))

            heroSpriteNode.position = CGPoint(x: newPositionX, y: newPositionY)

            // 🔴 Evitar que el héroe se voltee boca abajo en cualquier circunstancia
            heroSpriteNode.xScale = (targetX > heroSpriteNode.position.x) ? abs(heroSpriteNode.xScale) : -abs(heroSpriteNode.xScale)
            heroSpriteNode.yScale = abs(heroSpriteNode.yScale) // 🔴 Asegurar que siempre sea positivo
        }
    }



    override func update(_ currentTime: TimeInterval) {
        if !heroIsDead, !isHeroAnimating, let target = touchLocation {
            moveHeroTo(targetX: target.x, targetY: target.y)
        }
    }
    
    
}

extension GameSceneChapter3: @preconcurrency SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        let firstBody = contact.bodyA
        let secondBody = contact.bodyB

        // Verificar colisión entre héroe y point
        if (firstBody.categoryBitMask == heroMask && secondBody.categoryBitMask == pointMask) ||
           (firstBody.categoryBitMask == pointMask && secondBody.categoryBitMask == heroMask) {
            
            isplants = true
            
            
            // Determinar cuál es el pointNode
            let pointNode: SKSpriteNode? = firstBody.categoryBitMask == pointMask ? firstBody.node as? SKSpriteNode : secondBody.node as? SKSpriteNode
            

            guard let point = pointNode else { return }
            point.physicsBody = nil
            
            // 🔴 Aplicar la animación del héroe con Plant_man a una escala menor
            if let point = pointNode {
                animateHeroWithPlantMan(pointPosition: point.position)
            }

            
            // Crear un nodo temporal más grande para la animación
            let explosionNode = SKSpriteNode(texture: textures.Planta.first)
            explosionNode.position = CGPoint(x: point.position.x, y: point.position.y + 50)
            explosionNode.zPosition = 5
            explosionNode.setScale(0.4) // Agrandar solo la animación

            addChild(explosionNode)

            // Crear animación de plantación en explosionNode
            let plantAnimation = SKAction.animate(with: textures.Planta, timePerFrame: 0.4)
            let plantAction = SKAction.sequence([
                plantAnimation,
                SKAction.removeFromParent() // Remover la animación después
            ])

            explosionNode.run(plantAction)

            // Eliminar el nodo point original sin afectar la animación
            point.removeFromParent()
            
            
            if gameLogic.currentScore < 5 {
                gameLogic.score(points: 1)
            }else{
                gameLogic.isGameWin = true
            }
        }
    }
    override func willMove(from view: SKView) {
        print("Escena está cambiando, deteniendo música...")
        stopBackgroundMusic()
    }
}




extension GameSceneChapter3 {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)

        if !firstTouch {
            firstTouch = true
            swipeIndicator?.removeFromParent() // Oculta el gesto de movimiento en el primer toque
        }

        guard let touch = touches.first else { return }
        touchLocation = touch.location(in: self)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)

        guard let touch = touches.first else { return }
        touchLocation = touch.location(in: self) // Actualizar la posición objetivo
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        touchLocation = nil // Detener el movimiento cuando el usuario suelta el dedo
    }
}
