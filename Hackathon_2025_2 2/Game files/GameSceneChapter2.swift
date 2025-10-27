//
//  GameSceneChapter2.swift
//  ChangeIt
//
//  Created by yatziri on 07/02/25.
//



import SpriteKit
import GameplayKit
import AVFoundation
import SwiftUI

class GameSceneChapter2: SKScene {
    
    
    var gameLogic: ArcadeGameLogic = ArcadeGameLogic.shared
    
    
    var gameIsEnd = false {
        didSet {
            endGame()
        }
    }
    var backgroundMusicPlayer: AVAudioPlayer?
    var gameIsPaused = false
    var heroIsDead = false
    
    var touchLocation: CGPoint? // Guarda la posición del toque activo
    var moveSpeed: CGFloat = 450.0 // Velocidad del movimiento del héroe
    
    var timeInterval: TimeInterval = 4.0
    var fast: TimeInterval = 10.0
    
    var timer = Timer()
    
    
    let minSpawnInterval: TimeInterval = 1.5 // Intervalo mínimo permitido
    
    var heroNodeTexture = SKTexture(imageNamed: "Water_move-1")
    var heroSpriteNode = SKSpriteNode()
    var heroNode = SKNode()
    
    var swipeIndicator: SKSpriteNode?
    var firstTouch = false
    
    var backGroundNodeArray = [SKNode]()
    var enemyNodeArray = [SKNode]()
    var pointNodeArray = [SKNode]()
    
    var groundSpriteNode = SKSpriteNode()
    var groundNode = SKNode()
    
    var wallSpriteNode = SKSpriteNode()
    var wallNode = SKNode()
    
    var secondWallSpriteNode = SKSpriteNode()
    var secondWallNode = SKNode()
    
    let textures = Textures()
    
    
    
    var heroMask : UInt32 = 1
    var groundMask : UInt32 = 2
    var wallMask : UInt32 = 3
    var enemyMask : UInt32 = 4
    var pointMask : UInt32 = 5
    var bosqueMask : UInt32 = 6
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        initialSetUp()
        
    }
    
    func initialSetUp() {
        
        
        let backgroundNode = SKSpriteNode(color: UIColor(Color("BackgroundChapter2")), size: size)
        backgroundNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        backgroundNode.zPosition = -10
        addChild(backgroundNode)
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = CGVector(dx: -4, dy: -9.8)
        

        addBackgroundSky()
//        addBackground_Ground()
        createHero()
//        createGround()
        createWall()
        startSpawn()
        
        showSwipeIndicator()
        playBackgroundMusic()
        gameLogic.passLever2()
        
        addChild(heroNode)
        addChild(groundNode)
        addChild(wallNode)
        addChild(secondWallNode)
    }
    func playBackgroundMusic() {
        if let musicURL = Bundle.main.url(forResource: "Chapter11-Song", withExtension: "mp3") {
            do {
                backgroundMusicPlayer = try AVAudioPlayer(contentsOf: musicURL)
                backgroundMusicPlayer?.numberOfLoops = -1 // 🔄 Repetir infinitamente
                backgroundMusicPlayer?.volume = 0.7       // 🔊 Ajustar volumen
                backgroundMusicPlayer?.play()             // ▶️ Reproducir
            } catch {
                print("Error al reproducir la música: \(error.localizedDescription)")
            }
        } else {
            print("Archivo de música no encontrado")
        }
    }
    func stopBackgroundMusic() {
        backgroundMusicPlayer?.stop()
    }
    
    /// Muestra la imagen de gesto de deslizamiento para indicar el movimiento del héroe
    func showSwipeIndicator() {
        if let swipeImage = renderSFIcon(systemName: "hand.draw.fill", color: .white, size: CGSize(width: 120, height: 120)) {
            let texture = SKTexture(image: swipeImage)
            swipeIndicator = SKSpriteNode(texture: texture)
            
            swipeIndicator?.position = CGPoint(x: size.width / 2, y: size.height / 2 - 50)
            swipeIndicator?.zPosition = 10
            swipeIndicator?.setScale(1.5) // Ajustar tamaño más grande
            
            if let swipeIndicator = swipeIndicator {
                addChild(swipeIndicator)
                
                // Animación de izquierda a derecha para indicar deslizamiento
                let moveLeft = SKAction.moveBy(x: -50, y: 0, duration: 0.5)
                let moveRight = SKAction.moveBy(x: 50, y: 0, duration: 0.5)
                let sequence = SKAction.sequence([moveLeft, moveRight])
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
    
   
    func moveHeroTo(targetX: CGFloat) {
        let leftLimit = wallSpriteNode.position.x + (wallSpriteNode.frame.width / 2)
        let rightLimit = secondWallSpriteNode.position.x - (secondWallSpriteNode.frame.width / 2)

        let tolerance: CGFloat = 5.0 // Margen para considerar que el héroe ya llegó
        if !heroIsDead{
            // Si la distancia entre el héroe y el toque es menor a la tolerancia, no se mueve
            if abs(targetX - heroSpriteNode.position.x) < tolerance {
                return
            }
            
            var newPositionX = heroSpriteNode.position.x
            
            if targetX > heroSpriteNode.position.x {
                newPositionX += moveSpeed * CGFloat(1.0 / 60.0) // Movimiento a la derecha
            } else if targetX < heroSpriteNode.position.x {
                newPositionX -= moveSpeed * CGFloat(1.0 / 60.0) // Movimiento a la izquierda
            }
            
            // Limitar dentro de las paredes
            if newPositionX > leftLimit && newPositionX < rightLimit {
                heroSpriteNode.position.x = newPositionX
            }
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        if !heroIsDead{
            if let targetX = touchLocation?.x {
                moveHeroTo(targetX: targetX)
            }
        }
    }

    
    
    func addBackgroundSky() {
        let spawnRange = 0.5...1 // Rango de aparición
        timer = Timer.scheduledTimer(withTimeInterval: TimeInterval.random(in: spawnRange), repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.crateSky()
            }
        }
        
        
    }
    
    func crateSky() {
        let spawnRange = (size.width * 0.2)...(size.width ) // Rango de aparición
        let skyNode = SKSpriteNode(texture: textures.nubes.first)
        // Posición inicial en la parte inferior
        let startX = CGFloat.random(in: spawnRange)
        let startY = groundSpriteNode.position.y - 300
        skyNode.position = CGPoint(x: startX, y: startY)
        
        skyNode.zPosition = -2
        skyNode.setScale(1)

        let skyAnimation = SKAction.animate(with: textures.nubes, timePerFrame: 0.2)
        let repeatAnimation = SKAction.repeatForever(skyAnimation)

        skyNode.run(repeatAnimation)
        
        
        // 📌 Posición final en el centro de la pantalla
        let finalYPosition = size.height
        
        // 🔽 Movimiento descendente hasta el centro
        let moveUp = SKAction.moveTo(y: finalYPosition, duration: 4)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        let remove = SKAction.removeFromParent()
        let sequence = SKAction.sequence([moveUp, fadeOut, remove])

        skyNode.run(sequence)
        
        addChild(skyNode)
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
    
    func addHero(at position: CGPoint) {
        heroSpriteNode = SKSpriteNode(texture: heroNodeTexture)
        let heroRunAnimation = SKAction.animate(with: textures.water_move, timePerFrame: 0.2)
        let heroRun = SKAction.repeatForever(heroRunAnimation)
        heroSpriteNode.run(heroRun)
        
        heroSpriteNode.position = position
        heroSpriteNode.zPosition = 3
        heroSpriteNode.setScale(0.15)

        // Configuración de la física del héroe
        heroSpriteNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: heroNodeTexture.size().width * 0.1  , height: heroNodeTexture.size().height * 0.1 ))
        heroSpriteNode.physicsBody?.mass = 0.1
        heroSpriteNode.physicsBody?.categoryBitMask = heroMask
        heroSpriteNode.physicsBody?.contactTestBitMask = groundMask
        heroSpriteNode.physicsBody?.collisionBitMask = 0  // No choca con nada para mantener la ilusión
        heroSpriteNode.physicsBody?.isDynamic = true
        heroSpriteNode.physicsBody?.affectedByGravity = false // Desactivamos la gravedad
        
        // 📌 Posición final en el centro de la pantalla
        let finalYPosition = size.height / 2
        
        // 🔽 Movimiento descendente hasta el centro
        let moveDown = SKAction.moveTo(y: finalYPosition, duration: 1.5)
        
        // 🔼 Pequeño rebote después de llegar
        let moveUp = SKAction.moveBy(x: 0, y: 20, duration: 0.2)
        let moveDownAgain = SKAction.moveBy(x: 0, y: -20, duration: 0.2)
        
        // ⏳ Secuencia de caída y rebote
        let fallAndBounce = SKAction.sequence([moveDown, moveUp, moveDownAgain])
        
        heroSpriteNode.run(fallAndBounce)
        
        heroNode.addChild(heroSpriteNode)
    }

    func createHero() {
        addHero(at: CGPoint(x: size.width / 2, y: size.height - 100))
    }
    
    func createpoint() {
        if gameLogic.isGameOver == false && gameLogic.isGameWin == false{
            let pointNodeTexture = SKTexture(imageNamed: "point_water")
            
            let numberOfPoints = Int.random(in: 1...2) // Generar entre 1 y 3 gotas
            let spawnRange = (size.width * 0.2)...(size.width * 0.8) // Rango de aparición
            
            for _ in 0..<numberOfPoints {
                let pointSpriteNode = SKSpriteNode(texture: textures.point_water.first)
                pointSpriteNode.setScale(0.5) // Ajustar tamaño
                
                // Animación de la gota
                let pointAnimation = SKAction.animate(with: textures.point_water, timePerFrame: 0.1)
                let pointAnimationRepeat = SKAction.repeatForever(pointAnimation)
                pointSpriteNode.run(pointAnimationRepeat)
                
                // Posición inicial en la parte inferior
                let startX = CGFloat.random(in: spawnRange)
                let startY = groundSpriteNode.position.y - 300
                pointSpriteNode.position = CGPoint(x: startX, y: startY)
                pointSpriteNode.zPosition = 5
                
                // Configuración de la física
                pointSpriteNode.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pointNodeTexture.size().width * 0.2  , height: pointNodeTexture.size().height * 0.2 ))
                //            pointSpriteNode.physicsBody = SKPhysicsBody(rectangleOf: heroSpriteNode.size)
                pointSpriteNode.physicsBody?.categoryBitMask = pointMask
                pointSpriteNode.physicsBody?.contactTestBitMask = heroMask
                pointSpriteNode.physicsBody?.collisionBitMask = 0
                pointSpriteNode.physicsBody?.isDynamic = true
                pointSpriteNode.physicsBody?.affectedByGravity = false
                pointSpriteNode.physicsBody?.allowsRotation = false
                
                // Movimiento hacia arriba con variación en la velocidad
                let moveUp = SKAction.moveBy(x: 0, y: size.height * 2, duration: TimeInterval.random(in: 2.5...4.0))
                let fadeOut = SKAction.fadeOut(withDuration: 0.5)
                let remove = SKAction.removeFromParent()
                let sequence = SKAction.sequence([moveUp, fadeOut, remove])
                
                pointSpriteNode.run(sequence)
                
                // Agregar la gota a la escena
                pointNodeArray.append(pointSpriteNode)
                addChild(pointSpriteNode)
            }
        }
    }
    
    
    func create_tree_obstacle() {
        if gameLogic.isGameOver == false && gameLogic.isGameWin == false {
            let enemyNodeTexture = SKTexture(imageNamed: "Cloud_obs_1")
            
            // Nodo y Sprite para el enemigo
            let enemyNode_down = SKNode()
            let enemySpriteNode_down = SKSpriteNode(texture: textures.Cloud_obs[0])
            let enemyAnimation_down = SKAction.animate(with: textures.Cloud_obs, timePerFrame: 0.2)
            let enemy_down_AnimationRepeat = SKAction.repeatForever(enemyAnimation_down)
            enemySpriteNode_down.run(enemy_down_AnimationRepeat)
            
            // Posición aleatoria dentro del rango visible
            let randomX = CGFloat.random(in: -30...(size.width + 30)) // Aparece en diferentes alturas
            enemySpriteNode_down.position = CGPoint(x: randomX, y: -100)
            enemySpriteNode_down.zPosition = 1
            enemySpriteNode_down.setScale(0.5) // 🔹 Reducción del tamaño

            // Configuración de la física
            let originalSize = enemyNodeTexture.size()
            let physicsSize = CGSize(width: originalSize.width * 0.4,
                                     height: originalSize.height * 0.4) // 🔹 Ajuste por el escalado

            enemySpriteNode_down.physicsBody = SKPhysicsBody(rectangleOf: physicsSize)
            enemySpriteNode_down.physicsBody?.categoryBitMask = enemyMask
            enemySpriteNode_down.physicsBody?.contactTestBitMask = heroMask
            enemySpriteNode_down.physicsBody?.collisionBitMask = groundMask
            enemySpriteNode_down.physicsBody?.isDynamic = true
            enemySpriteNode_down.physicsBody?.affectedByGravity = false
            enemySpriteNode_down.physicsBody?.allowsRotation = false

            
            
            // Movimiento hacia arriba con variación en la velocidad
            let moveUp = SKAction.moveBy(x: 0, y: size.height, duration: TimeInterval.random(in: 1.5...4.0))
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([moveUp, fadeOut, remove])
            
            enemySpriteNode_down.run(sequence)
            
            // Agregar enemigo a la escena
            enemyNodeArray.append(enemyNode_down)
            enemyNode_down.addChild(enemySpriteNode_down)
            addChild(enemyNode_down)
        }
    }






    
    func heroDied() {
        let tristeAnimation = SKAction.animate(with: textures.Water_crash, timePerFrame: 0.07)
        heroSpriteNode.run(tristeAnimation)
        heroIsDead = true
        
    }
    
    func startSpawn() {
        let spawnInterval: TimeInterval = 6
        let spawnInterval2: TimeInterval = 4
        timer = Timer.scheduledTimer(withTimeInterval: spawnInterval2, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            Task {
                await self.createpoint()
            }
        }
        timer = Timer.scheduledTimer(withTimeInterval: spawnInterval, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            Task {
                await self.create_tree_obstacle()
            }
        }
        
    }

    
    
    private func restartGame() {
        self.gameLogic.restartGame()
        timeInterval = 4.0
        fast = 10.0
        gameIsEnd = true
    }
    
    func endGame() {
        gameLogic.ChapterPass = 2
//        print(" chapter2: \(gameLogic.ChapterPass)")
        if gameIsEnd == true {
            stopBackgroundMusic()
            timer.invalidate()
            children.forEach { node in
                node.removeAllActions()
                node.children.forEach { node in
                    node.removeAllActions()
                }
            }
            
            enemyNodeArray.forEach { node in
                node.removeFromParent()
            }
        
        }
        
    }
}

//var heroMask : UInt32 = 1
//var groundMask : UInt32 = 2
//var wallMask : UInt32 = 3
//var enemyMask : UInt32 = 4

extension GameSceneChapter2: @preconcurrency SKPhysicsContactDelegate {
    func didBegin(_ contact: SKPhysicsContact) {
        // MARK: - Si el héroe choca con el suelo
        if contact.bodyA.categoryBitMask == heroMask && contact.bodyB.categoryBitMask == groundMask {
            
        }

        // MARK: - Si el enemigo choca con el héroe
        if contact.bodyA.categoryBitMask == enemyMask && contact.bodyB.categoryBitMask == heroMask ||
           contact.bodyA.categoryBitMask == heroMask && contact.bodyB.categoryBitMask == enemyMask {
            
            // Animación del héroe al morir
            heroDied()
            
            
            if gameLogic.liveScore <= 0 {
//                self.restartGame()
                gameLogic.isGameOver = true
                
                
            }else{
                self.gameLogic.liveScore  -= 1
                self.gameLogic.currentScore  = 0
//                print("lives: \(self.gameLogic.liveScore)")
            }
            heroIsDead = false
            
        }

        // MARK: - Si el sol choca con el héroe
        if contact.bodyA.categoryBitMask == pointMask && contact.bodyB.categoryBitMask == heroMask ||
           contact.bodyA.categoryBitMask == heroMask && contact.bodyB.categoryBitMask == pointMask {

            let WaterPop = SKAction.animate(with: textures.Water_pop, timePerFrame: 0.07)
            
            heroSpriteNode.run(WaterPop)
            
            self.gameLogic.score(points: 1)
            
            if gameLogic.currentScore == 5 {
                gameLogic.isGameWin = true
                
//                print("WinState: \(gameLogic.isGameWin)")
                gameLogic.passLever2()
                print(" chapter2: \(gameLogic.ChapterPass)")
            }else{
                gameLogic.isGameWin = false
//                print("WinState: \(gameLogic.isGameWin)")
            }
            if contact.bodyA.categoryBitMask == pointMask {
                contact.bodyA.node?.removeFromParent()
            } else {
                contact.bodyB.node?.removeFromParent()
            }
        }

    }

}

extension GameSceneChapter2 {
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




