//
//  ExplanationsChapter3.swift
//  ChangeIt1
//
//  Created by yatziri on 20/02/25.
//
import SwiftUI
import SpriteKit

struct ExplanationsChapter3: View {
    @Binding var currentGameState: GameState
    @Binding var pressbutton: Bool
    @State private var currentPage = 0
    private let totalPages = 1 // Two slides (index 0 and 1)

    var body: some View {
        VStack {
            HStack {
                // Botón de regreso
                Button(action: {
                    withAnimation {
                        pressbutton = false // Regresa a la selección de capítulos
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .bold()
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
                }
                .padding(.leading)
                
                Spacer()
            }
            ZStack {
                VStack {
                    // Next or Play button
                    HStack {
                        Spacer()
                        Button(action: {
                            if currentPage < totalPages {
                                withAnimation {
                                    currentPage += 1
                                }
                            } else {
                                currentGameState = .playing
                            }
                        }) {
                            HStack {
                                if currentPage < totalPages {
                                    Text("Next")
                                } else {
                                    Text("Play")
                                    Image(systemName: "play.fill")
                                }
                            }
                            .bold()
                            .foregroundColor(currentPage < totalPages ? Color("Butons") : Color("PlayButon"))
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                        }
                    }
                    .padding(.trailing)
                    .padding(.top)

                    // TabView for explanations
                    TabView(selection: $currentPage) {
                        FirstPageChapter3View()
                            .tag(0)

                        SecondPageChapter3View()
                            .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(width: UIScreen.main.bounds.width * 0.75, height: UIScreen.main.bounds.height * 0.50)
                }
                .background(RoundedRectangle(cornerRadius: 20)
                                .fill(Color("Color_Back"))
                                .shadow(color: Color("Color_Back").opacity(0.3), radius: 5, x: 0, y: 5))
                .padding(.horizontal, 180)
            }
            
            // Botón Play
            Button(action: {
                withAnimation {
                    if currentPage == totalPages {
                        currentGameState = .playing
                    }
                }
            }) {
                Text("Play")
                    .bold()
                    .font(.title)
                    .padding(.horizontal, 70)
                    .padding(.vertical, 20)
                    .foregroundColor(currentPage == totalPages ? Color.black : Color(.systemGray).opacity(0.8))
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(currentPage == totalPages ? Color.white.opacity(0.7) : Color.gray.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(currentPage == totalPages ? Color.black : Color.black.opacity(0), lineWidth: 2)
                            )
                            .shadow(
                                color: currentPage == totalPages ? Color.black.opacity(0.3) : Color.black.opacity(0),
                                radius: 5,
                                x: 0,
                                y: 5
                            )
                    )
                    .scaleEffect(currentGameState == .playing ? 0.8 : 1.0)
                    .animation(.spring(), value: currentGameState)
                    .disabled(currentPage != totalPages)
            }
            .padding(.top, 100)
        }
    }
}

struct FirstPageChapter3View: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("You’ve seen the harm.")
                    .font(.title)
                    .foregroundColor(.white)
                 Text(" Now, be the cure.")
                    .font(.title)
                    .foregroundColor(.white)
                + Text(" A single action")
                    .font(.title)
                    .foregroundColor(.white)
                + Text(" can be the change.")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
            }
            .padding()
            .padding(.leading, 20.0)
            
            SpriteView(scene: PlantManAnimationScene(size: CGSize(width: 300, height: 300)))
                .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.height * 0.45)
                .padding(.bottom, 150.0)
        }
    }
}

class PlantManAnimationScene: SKScene {
    let textures = Textures()
    private var hasStartedAnimation = false

    
    override func didMove(to view: SKView) {
        if hasStartedAnimation { return }
        hasStartedAnimation = true

        backgroundColor = UIColor(named: "Color_Back") ?? .black
        
        let treeNode = SKSpriteNode(texture: textures.Plant_man.first)
        treeNode.size = CGSize(width: textures.Plant_man[0].size().width/4, height:  textures.Plant_man[0].size().height/4)
        treeNode.position = CGPoint(x: size.width / 2, y: size.height / 3)
        treeNode.zPosition = 1
        
        addChild(treeNode)
        
        let animation = SKAction.animate(with: textures.Plant_man, timePerFrame: 0.2)
        let animationBack = SKAction.animate(with: textures.Plant_man.reversed(), timePerFrame: 0.2)

        // Secuencia de animaciones
        let sequence = SKAction.sequence([animation, animationBack])

        // Repetición infinita de la secuencia
        let repeatAnimation = SKAction.repeatForever(sequence)
        
        treeNode.run(repeatAnimation)
    }
}

struct SecondPageChapter3View: View {
    @State private var isAnimating = false

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Plant ")
                    .font(.title)
                    .foregroundColor(.white)
                + Text("5 trees")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                + Text(" and let life bloom again.")
                    .font(.title)
                    .foregroundColor(.white)

                Text(" Make the change.")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
            }
            .padding()
            .padding(.leading, 20.0)
            .padding(.trailing, 50.0)

            // Animación de semillas en zigzag
            ZStack {
                Image("Planta_point")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .offset(x: -40, y: -100) // Posición superior izquierda
                    .animation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                Image("Planta_point")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .offset(x: 40, y: 0) // Posición central más abajo
                    .animation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )

                Image("Planta_point")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 130)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .offset(x: -40, y: 100) // Posición inferior izquierda
                    .animation(
                        Animation.easeInOut(duration: 0.8)
                            .repeatForever(autoreverses: true),
                        value: isAnimating
                    )
            }
            .frame(width: UIScreen.main.bounds.width * 0.2, height: UIScreen.main.bounds.height * 0.2)
//            .padding()
            .onAppear {
                isAnimating = true
            }
        }
    }
}



