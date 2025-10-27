//
//  CharacterSelectionView.swift
//  Hackathon_2025_2
//
//  Created by yatziri on 27/10/25.
//

import SwiftUI
import SpriteKit



// MARK: - Vista de selección de personajes
struct CharacterSelectionView: View {
    @Binding var pressbutton: Bool
    @ObservedObject var gameLogic: ArcadeGameLogic
    @Binding var currentGameState: GameState
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedIndex: Int = 0 // Índice del personaje centrado
    
    // private let characters: [(name: String, imageName: String)] = [
    //     ("Ayla", "character_ayla"),
    //     ("Borin", "character_borin"),
    //     ("Cyra", "character_cyra")
    // ]
    private let itemCount: Int = 3

    var body: some View {
        VStack {
            /*ProgressView(value: progress , total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .white))
                .frame(width: UIScreen.main.bounds.width * 0.8, height: 6)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(3)
                .padding(.top, 10)
                .animation(.easeInOut(duration: 0.5), value: progress)*/
            // Título y subtítulo
            VStack {
                Text("Select a character")
                    .fontWeight(.heavy)
                    .font(.largeTitle)
                Text("Choose who you want to play as.")
                    .font(.title2)
            }
            .foregroundColor(.black.opacity(0.9))
            .shadow(color: .black.opacity(0.3), radius: 3, x: 1, y: 2)
            .padding()

            GeometryReader { geometry in
                ScrollViewReader { scrollViewProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack() {
                            Spacer(minLength: geometry.size.width * 0.4)

                            ForEach(0..<itemCount, id: \.self) { index in
                                GeometryReader { itemGeometry in
                                    let itemCenter = itemGeometry.frame(in: .global).midX
                                    let screenCenter = geometry.size.width * 0.5
                                    let distance = (itemCenter - screenCenter) / screenCenter

                                    // Ajustes dinámicos de escala y opacidad
                                    let scale = max(0.55, 1 - abs(distance) * 0.65)
                                    let rotationAngle = Angle(degrees: distance * 30)
                                    let opacity = max(0.6, 1.2 - abs(distance) * 0.5)

                                    ZStack {
                                        SpriteView(scene: FutBalonScene(size: CGSize(width: geometry.size.width * 0.3, height: geometry.size.height * 0.8)), options: [.allowsTransparency])
                                            .frame(height: geometry.size.height * 0.8)
                                            .scaleEffect(scale)
                                            .rotation3DEffect(rotationAngle, axis: (x: 0, y: 1, z: 0))
                                            .opacity(opacity)
                                            .animation(.spring(response: 0.5, dampingFraction: 0.8), value: scale)
                                            .animation(.easeInOut(duration: 0.4), value: opacity)
                                            .animation(.easeInOut(duration: 0.5), value: rotationAngle)
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        // Al tocar, comenzar el juego
                                        pressbutton = false
                                        currentGameState = .playing
                                    }
                                }
                                .frame(width: geometry.size.width * 0.3, height: geometry.size.height)
                                .id(index)
                            }

                            Spacer(minLength: geometry.size.width * 0.4)
                        }
                    }
                    .onAppear {
                        DispatchQueue.main.async {
                            scrollViewProxy.scrollTo(0, anchor: .center)
                        }
                    }
                }
            }
            .frame(height: UIScreen.main.bounds.height )
            
        }
    }
}


// MARK: - SpriteKit Scene para la animación de fut balon
class FutBalonScene: SKScene {
    private let textures = Textures()
    private var hasStartedAnimation = false

    override func didMove(to view: SKView) {
        guard !hasStartedAnimation else { return }
        hasStartedAnimation = true

        backgroundColor = .clear

        guard let first = textures.fut_balon.first else { return }
        let sprite = SKSpriteNode(texture: first)

        // Escalar el sprite para que quepa correctamente en la escena
        // Ajusta el factor si necesitas un tamaño diferente
        let baseWidth = size.width * 0.6
        let aspect = first.size().height / first.size().width
        let enlargedWidth = baseWidth * 4
        sprite.size = CGSize(width: enlargedWidth, height: enlargedWidth * aspect)
        sprite.position = CGPoint(x: size.width / 2, y: size.height / 2)
        sprite.zPosition = 1
        addChild(sprite)

        let animation = SKAction.animate(with: textures.fut_balon, timePerFrame: 0.08)
        let repeatAnimation = SKAction.repeatForever(animation)
        sprite.run(repeatAnimation)
    }
}

