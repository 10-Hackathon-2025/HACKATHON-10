//
//  winview.swift
//  Hackathon_2025_2
//
//  Created by yatziri on 27/10/25.
//



import SwiftUI
import UIKit
import SpriteKit

struct winview: View {
    
    @Binding var currentGameState: GameState
    @StateObject var gameLogic: ArcadeGameLogic = ArcadeGameLogic.shared
    
    var body: some View {
        ZStack {
            VStack() {
                Spacer()
                VStack(spacing: 16) {
                    Text("¡Tiempo agotado!")
                        .foregroundColor(.black)
                        .font(.system(size: 42, weight: .heavy))
                        .multilineTextAlignment(.center)
                    
                    Text("Palabras buenas: \(gameLogic.score)")
                        .foregroundColor(.black)
                        .font(.system(size: 28, weight: .bold))
                        .padding(.top, 4)
                    
                    Text("¡Buen trabajo! Puedes intentar de nuevo para mejorar tu puntaje.")
                        .foregroundColor(.black)
                        .font(.title3)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                }
                //.padding(.top,10)
                .padding()
                .background(RoundedRectangle(cornerRadius: 20)
                    .fill(Color("win_Back"))
                    .shadow(color: Color("win_Back").opacity(0.3), radius: 5, x: 0, y: 5))
                .padding()
                
                HStack(alignment: .center, spacing: 16) {
                    Button {
                        withAnimation { self.backToMainScreen() }
                    } label: {
                        HStack {
                            
                            Image(systemName: "house.fill")
                            Text("Home")
                            
                        }
                        .bold()
                        .font(.title2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
                        )
                    }
                    
                    Button {
                        withAnimation { self.restartGame() }
                        Task {
                            let gameLogic = ArcadeGameLogic.shared
                            gameLogic.restartGame()
                        }
                    } label: {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Restart")
                        }
                        .bold()
                        .font(.title2)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, minHeight: 64)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(Color.white.opacity(0.7))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
                        )
                    }
                }
                .padding(.horizontal)
                Spacer()
            }
        }
    }
    
    private func backToMainScreen() {
        self.currentGameState = .home
    }
    
    private func restartGame() {
        self.currentGameState = .playing
    }
}

// 📌 Subview para el título
struct WinTitleView: View {
    var selectedChapter: Int
    var body: some View {
        VStack(alignment:.center) {
            Text("Well done ! ! !")
                .foregroundColor(.black)
                .font(.system(size: 50, weight: .heavy))
                .bold()
            
            if selectedChapter == 0 {
                Text("You saved many trees")
                    .foregroundColor(.black)
                    .font(.title)
            } else if selectedChapter == 1 {
                Text("You gathered enough water, and the rain finally returned")
                    .foregroundColor(.black)
                    .font(.title)
            } else if selectedChapter == 2 {
                Text("One tree may be small, but together they build a forest.")
                    .foregroundColor(.black)
                    .font(.title2)
            }
        }
        .padding()
    }
}

// 📌 Subview para el mensaje según el capítulo
struct WinMessageView: View {
    var selectedChapter: Int

    var body: some View {
        VStack(alignment:.center) {
            if selectedChapter == 0 {
                Text("But in the end the ")
                    .font(.title2)
                    .foregroundColor(.black)
                + Text("selfishness of some people")
                    .font(.title2)
                    .foregroundColor(.black)
                    .bold()
                + Text(" took them all.")
                    .font(.title2)
                    .foregroundColor(.black)
            } else if selectedChapter == 1 {
                Text("But nature is unpredictable, ")
                    .font(.title2)
                    .foregroundColor(.black)
                + Text("rainfall has doubled")
                    .font(.title2)
                    .foregroundColor(.black)
                    .bold()
                + Text(" and now the ")
                    .font(.title2)
                    .foregroundColor(.black)
                + Text("city is drowning.")
                    .font(.title2)
                    .foregroundColor(.black)
                    .bold()
            } else if selectedChapter == 2 {
                Text("Every seed you plant helps restore the world. ")
                    .font(.title2)
                    .foregroundColor(.black)
                Text("Being aware is the first step, ")
                    .font(.title2)
                    .foregroundColor(.black)
                    .fontWeight(.bold)
                + Text("Make the Change.")
                    .font(.title2)
                    .foregroundColor(.black)
                    .fontWeight(.heavy)
            } else {
                Text("Something went wrong.")
                    .font(.title2)
                    .foregroundColor(.black)
                    .bold()
            }
        }
        .padding()
    }
}

// 📌 Subview para la animación según el capítulo
struct WinAnimationView : View {
    var selectedChapter: Int
    var body: some View {
        if selectedChapter == 0 {
            SpriteView(scene: TreeAnimationScene(size: CGSize(width: 400, height: 400)))
                .frame(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.40)
        } else if selectedChapter == 1 {
            SpriteView(scene: RainAnimationScene(size: CGSize(width: 400, height: 400)))
                .frame(width: UIScreen.main.bounds.width * 0.6, height: UIScreen.main.bounds.height * 0.40)
        } else if selectedChapter == 2 {
            SpriteView(scene: FireAnimationScene(size: CGSize(width: 400, height: 300)))
                .frame(width: UIScreen.main.bounds.width * 0.4, height: UIScreen.main.bounds.height * 0.40)
        }
    }
}

// 📌 Nueva escena de animación para Chapter 3
class FireAnimationScene: SKScene {
    let textures = Textures()
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(named: "win_Back") ?? .black
        
        let fireNode = SKSpriteNode(texture: textures.Planta.first)
        fireNode.size = CGSize(width: textures.Planta[0].size().width * 0.7 ,
                               height: textures.Planta[0].size().height )
        fireNode.position = CGPoint(x: size.width / 2, y: (size.height * 3 ) / 4)
        fireNode.zPosition = 1
        
        addChild(fireNode)

        let fireAnimation = SKAction.animate(with: textures.Planta, timePerFrame: 0.2)
        let repeatFire = SKAction.repeatForever(fireAnimation)
        
        fireNode.run(repeatFire)
    }
}

class RainAnimationScene: SKScene {
    let textures = Textures()
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(named: "win_Back") ?? .black
        
        // Iniciar la generación continua de gotas
        let spawnAction = SKAction.run { [weak self] in
            self?.spawnRaindrop()
        }
        let delay = SKAction.wait(forDuration: 0.2) // Intervalo entre gotas
        let rainSequence = SKAction.sequence([spawnAction, delay])
        let repeatRain = SKAction.repeatForever(rainSequence)
        
        run(repeatRain)
    }
    
    func spawnRaindrop() {
        let raindrop = SKSpriteNode(texture: textures.point_water.first)
        
        raindrop.size = CGSize(
            width: textures.point_water[0].size().width / 3,
            height: textures.point_water[0].size().height / 2
        )
        
        // Posición aleatoria en la parte superior
        let randomX = CGFloat.random(in: 20...size.width - 20 )
        raindrop.position = CGPoint(x: randomX, y: size.height - 20 )
        raindrop.zPosition = 1
        
        addChild(raindrop)
        
        // Animación de caída
        let fallDuration = TimeInterval.random(in: 2.0...3.5) // Velocidad variable
        let fallAction = SKAction.moveBy(x: 0, y: -size.height, duration: fallDuration)
        
        // Acción para remover la gota al tocar el suelo
        let removeAction = SKAction.removeFromParent()
        
        let sequence = SKAction.sequence([fallAction, removeAction])
        
        raindrop.run(sequence)
    }
}



class TreeAnimationScene: SKScene {
    let textures = Textures()
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(named: "win_Back") ?? .black
        
        let treeNode = SKSpriteNode(texture: textures.arbolsalto.first)
        treeNode.size = CGSize(width: textures.arbolsalto[0].size().width / 5,
                               height: textures.arbolsalto[0].size().height / 5)
        treeNode.position = CGPoint(x: size.width / 3, y: size.height / 2)
        treeNode.zPosition = 1
        
        addChild(treeNode)
        
        let cloudNode = SKSpriteNode(texture: textures.tree_down_walk.first)
        cloudNode.size = CGSize(width: textures.tree_down_walk[0].size().width / 2,
                                height: textures.tree_down_walk[0].size().height / 2.5)
        cloudNode.position = CGPoint(x: size.width * 0.75, y: size.height / 2)
        cloudNode.zPosition = 0
        
        addChild(cloudNode)
        
        let animation = SKAction.animate(with: textures.arbolsalto, timePerFrame: 0.2)
        let repeatAnimation = SKAction.repeatForever(animation)
        treeNode.run(repeatAnimation)
        
        let animation2 = SKAction.animate(with: textures.tree_down_walk, timePerFrame: 0.3)
        let repeatAnimation2 = SKAction.repeatForever(animation2)
        
        cloudNode.run(repeatAnimation2)
        // Simulación de salto: impulso hacia arriba y caída
        let jumpUp = SKAction.moveBy(x: 0, y: 100, duration: 0.8) // Sube 100 puntos en 0.3s
        let fallDown = SKAction.moveBy(x: 0, y: -100, duration: 0.4) // Baja 100 puntos en 0.4s (más lento para simular gravedad)
        let jumpSequence = SKAction.sequence([jumpUp, fallDown])
        let repeatJump = SKAction.repeatForever(jumpSequence)
        
        treeNode.run(repeatJump)
        

    }
}

#Preview {
    winview(currentGameState: .constant(GameState.playing))
}

