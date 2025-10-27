//
//  ExplanationsChapter2.swift
//  ChangeIt1
//
//  Created by yatziri on 15/02/25.
//


import SwiftUI
import SpriteKit


struct ExplanationsChapter2: View {
    @Binding var currentGameState: GameState
    @Binding var pressbutton: Bool
    @State private var currentPage = 0
    private let totalPages = 3 // Asegúrate de que esto coincida con el número de vistas en TabView

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
                    // Contenedor superior con el botón Next
                    HStack {
                        Spacer()
                        Button(action: {
                            if currentPage < totalPages {
                                withAnimation {
                                    currentPage += 1
                                }
                            }else {
                                currentGameState = .playing
                            }
                            
                        }) {
                            HStack {
                                if currentPage < totalPages {
                                    Text("Next")
                                }else {
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
                    
                    // Contenedor principal con TabView
                    TabView(selection: $currentPage) {
                        FirstPageChapter2View()
                            .tag(0)

                        SecondPageChapter2View()
                            .tag(1)
                        ThirdPageChapter2View()
                            .tag(2)
                        FourthPageChapter2View()
                            .tag(3)
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

struct FirstPageChapter2View: View {
    let textures = Textures()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("The earth is")
                    .font(.title)
                    .foregroundColor(.white)
                + Text(" thirsty")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                + Text(", the rivers have run dry ")
                    .font(.title)
                    .foregroundColor(.white)
                + Text(", and the ")
                    .font(.title)
                    .foregroundColor(.white)
                + Text("people")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                + Text(" desperately need")
                    .font(.title)
                    .foregroundColor(.white)
                + Text(" water.")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
            }
            .padding()
            .padding(.leading, 20.0)
            
            Image("World")
                .resizable()
                .scaledToFit()
                .frame(width: UIScreen.main.bounds.width * 0.2, height: UIScreen.main.bounds.height * 0.2)
                .padding()
        }
    }
}

struct SecondPageChapter2View: View {
    var body: some View {
        HStack {
            
            VStack(alignment: .leading) {
                Text("Help the ")
                    .font(.title)
                    .foregroundColor(.white)
                + Text("raindrop grow")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                + Text(" by collecting water in the sky.")
                    .font(.title)
                    .foregroundColor(.white)
               
                
            }
            .padding()
            .padding(.leading, 20.0)
            
            // Reemplazo de la imagen estática por la animación de texturas "cut"
            SpriteView(scene: Water_pop_AnimationScene(size: CGSize(width: 200, height: 350)))
                .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.height * 0.45)
//                .padding(.bottom, 150.0)
        }
    }
}

// Creación de la escena de SpriteKit para la animación de la tala de árboles
class Water_pop_AnimationScene: SKScene {
    let textures = Textures()
    private var hasStartedAnimation = false
    
    override func didMove(to view: SKView) {
        if hasStartedAnimation { return }
        hasStartedAnimation = true
        
        backgroundColor = UIColor(named: "Color_Back") ?? .black
        
        let treeNode = SKSpriteNode(texture: textures.water_move.first)
        treeNode.size = CGSize(width: textures.water_move[0].size().width/6, height:  textures.water_move[0].size().height/5)
        treeNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        treeNode.zPosition = 1
        
        addChild(treeNode)
        
        let animation = SKAction.animate(with: textures.water_move, timePerFrame: 0.3)
        let repeatAnimation = SKAction.repeatForever(animation)
        
        treeNode.run(repeatAnimation)
    }
}


struct ThirdPageChapter2View: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                
                Text("Dark clouds")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                + Text("  are filled with pollution.")
                    .font(.title)
                    .foregroundColor(.white)
                + Text(" Crashing ")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                + Text(" into them will make you ")
                    .font(.title)
                    .foregroundColor(.white)
                + Text("lose")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                + Text("  collected ")
                    .font(.title)
                    .foregroundColor(.white)
                + Text("water.")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
            }
            .padding()
            .padding(.leading, 20.0)
            
            // Reemplazo de la imagen estática por la animación de texturas "cut"
            SpriteView(scene: Water_Crash_AnimationScene(size: CGSize(width: 400, height: 400), backgroundColor: UIColor(named: "Color_Back") ?? .black))
                .frame(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.40)
//                .padding(.bottom, 100.0)
        }
    }
}



class Water_Crash_AnimationScene: SKScene {
    
    let textures = Textures()
    private var hasStartedAnimation = false
    private var customBackgroundColor: UIColor

    // Nuevo inicializador que recibe el color de fondo como parámetro
    init(size: CGSize, backgroundColor: UIColor) {
        self.customBackgroundColor = backgroundColor
        super.init(size: size)
    }

    required init?(coder aDecoder: NSCoder) {
        self.customBackgroundColor = .black // Valor por defecto
        super.init(coder: aDecoder)
    }
    
    override func didMove(to view: SKView) {
        if hasStartedAnimation { return }
        hasStartedAnimation = true
        
        backgroundColor = customBackgroundColor

        let treeNode = SKSpriteNode(texture: textures.Water_crash.first)
        treeNode.size = CGSize(width: textures.Water_crash[0].size().width / 6,
                               height: textures.Water_crash[0].size().height / 6)
        treeNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        treeNode.zPosition = 1
        
        addChild(treeNode)
        
        let cloudNode = SKSpriteNode(texture: textures.Cloud_obs.first)
        cloudNode.size = CGSize(width: textures.Cloud_obs[0].size().width / 5,
                               height: textures.Cloud_obs[0].size().height / 5)
        cloudNode.position = CGPoint(x: size.width / 2, y: size.height / 4)
        cloudNode.zPosition = 0
        
        addChild(cloudNode)
        
        let animation = SKAction.animate(with: textures.Water_crash, timePerFrame: 0.1)
        let repeatAnimation = SKAction.repeatForever(animation)
        treeNode.run(repeatAnimation)
        
        let animation2 = SKAction.animate(with: textures.Cloud_obs, timePerFrame: 0.1)
        let repeatAnimation2 = SKAction.repeatForever(animation2)
        cloudNode.run(repeatAnimation2)
        
        
        // Simulación de salto: impulso hacia arriba y caída
        let jumpUp = SKAction.moveBy(x: 0, y: 150, duration: 0.2) // Sube 100 puntos en 0.3s
        let fallDown = SKAction.moveBy(x: 0, y: -150, duration: 0.9) // Baja 100 puntos en 0.4s (más lento para simular gravedad)
        let jumpSequence = SKAction.sequence([jumpUp, fallDown])
        let repeatJump = SKAction.repeatForever(jumpSequence)
        
        treeNode.run(repeatJump)
    }
}


struct FourthPageChapter2View: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Collect ")
                    .font(.title)
                    .foregroundColor(.white)
                + Text(" 5 water drops  ")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                + Text("to complete the chapter!")
                    .font(.title)
                    .foregroundColor(.white)
                 + Text(" But be careful you only have ")
                    .font(.title)
                    .foregroundColor(.white)
                + Text("3 chances ")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
                
            }
            .padding()
            .padding(.leading, 20.0)
            .padding(.trailing, 50.0)
            
            VStack{
                Image("point_cloud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.height * 0.15)
                    .padding()
                Image("point_water")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.height * 0.15)
                    .padding()
            }
            
        }
    }
}
