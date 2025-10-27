//
//  StartView.swift
//  Hackathon_2025_2
//
//  Created by yatziri on 27/10/25.
//

import SwiftUI
import SpriteKit

struct StartView: View {
    @State private var pressbutton = false
    @State private var startButtonPressed = false
    @Binding var currentGameState: GameState
    @StateObject var gameLogic: ArcadeGameLogic = ArcadeGameLogic.shared
    @Binding var FirtsTime : Bool
    @State private var selectedCharacterName: String? = nil

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("StartColor")
                    .ignoresSafeArea()
//                    .onTapGesture { pressbutton = false }

                VStack {
                    if !pressbutton {
                        if !startButtonPressed && FirtsTime == true {
                            TitleView(startButtonPressed: $startButtonPressed)
                        } else {
                            if FirtsTime{
                                ExplanationsChapter2(currentGameState: $currentGameState, pressbutton: $pressbutton)
                            }else{
                                CharacterSelectionView(pressbutton: $pressbutton, gameLogic: gameLogic, currentGameState: $currentGameState)
                            }
                        }
                    } else {
                        // Mostrar selección de personaje y al elegir, comenzar a jugar
                        CharacterSelectionView(pressbutton: $pressbutton, gameLogic: gameLogic, currentGameState: $currentGameState)
                            .onChange(of: pressbutton) { oldValue, newValue in
                                if oldValue == true && newValue == false {
                                    // no-op: not used
                                }
                            }
                    }
                }
            }
        }
    }
}

// MARK: - Vista del título y botón de inicio
struct TitleView: View {
    @Binding var startButtonPressed: Bool

    var body: some View {
        VStack {
            SpriteView(scene: TitleAnimationScene(size: CGSize(width: 1249, height: 582)))
                .padding()

            Button(action: { startButtonPressed = true }) {
                Text("Start")
                    .bold()
                    .font(.title)
                    .padding(.horizontal, 70)
                    .padding(.vertical, 20)
                    .foregroundColor(.black)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white.opacity(0.7))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(Color.black, lineWidth: 2)
                            )
                            .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
                    )
                    .scaleEffect(startButtonPressed ? 0.8 : 1.0)
            }
            .padding()
            Spacer()
        }
    }
}



// Creación de la escena de SpriteKit para la animación de la tala de árboles
class TitleAnimationScene: SKScene {
    let textures = Textures()
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(named: "StartColor") ?? .black
        
        let treeNode = SKSpriteNode(texture: textures.título.first)
        treeNode.size = CGSize(width: 1249, height: 582) // Ajuste basado en tamaño promedio
        treeNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        treeNode.setScale(0.8)
        treeNode.zPosition = 1
        
        addChild(treeNode)
        
        let animation = SKAction.animate(with: textures.título, timePerFrame: 0.3)
        let repeatAnimation = SKAction.repeatForever(animation)
        
        treeNode.run(repeatAnimation)
        
        // Animación continua de hojas cayendo
        let spawnLeaves = SKAction.run {
            let hoja = SKSpriteNode(texture: self.textures.hojas.randomElement())
            hoja.size = CGSize(width: 80, height: 80) // Hojas más pequeñas
            hoja.position = CGPoint(x: CGFloat.random(in: 0...self.size.width), y: self.size.height + 50)
            hoja.zPosition = 0
            hoja.alpha = 0.8
            self.addChild(hoja)
            
            let fallDuration = TimeInterval.random(in: 4...7)
            let moveDown = SKAction.moveTo(y: -50, duration: fallDuration)
            let fadeOut = SKAction.fadeOut(withDuration: fallDuration * 0.2)
            let remove = SKAction.removeFromParent()
            let sequence = SKAction.sequence([moveDown, fadeOut, remove])
            
            hoja.run(sequence)
        }
        
        let spawnSequence = SKAction.sequence([spawnLeaves, SKAction.wait(forDuration: 0.5)])
        let spawnForever = SKAction.repeatForever(spawnSequence)
        run(spawnForever)
    }
}









// MARK: - Botón de capítulo con bloqueo y animación
struct ChapterButton: View {
    let title: String
    let imageName: String
    let isLocked: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                VStack {
                    ZStack {
                        // Efecto de bloqueo con candado
                        if isLocked {
                            Image(systemName: "lock.fill")
                                .foregroundColor(.white)
                                .font(.system(size: 100, weight: .bold)) // Candado más grande
                        }
                        
                        // Imagen del capítulo
                        Image(imageName)
                            .resizable()
                            .scaledToFill()
                            .frame(width: UIScreen.main.bounds.width * 0.2 * 1.5, height: UIScreen.main.bounds.height * 0.33 * 1.5)
                            .overlay(
                                isLocked ? Color.gray.opacity(0.4) : Color.clear // Oscurece solo si está bloqueado
                                
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(isLocked ?  Color.clear : Color.white.opacity(0.2), lineWidth: 3) // Contorno más visible si está bloqueado
                                
                            )
                    }
                    .frame(width: UIScreen.main.bounds.width * 0.2 * 1.5, height: UIScreen.main.bounds.height * 0.33 * 1.5)
                    HStack {
                        Text(title)
                            .foregroundColor(isLocked ? .gray : .white) // Texto en gris si está bloqueado
                        Spacer()
                    }
                }
            }
        }
        .padding()
        .disabled(isLocked) // Deshabilita si está bloqueado
        .opacity(isLocked ? 0.5 : 1.0) // Reduce la opacidad si está bloqueado
    }
}

