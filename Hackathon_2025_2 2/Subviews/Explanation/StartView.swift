//
//  SwiftUIView.swift
//  ChangeIt
//
//  Created by yatziri on 20/01/25.
//
import SwiftUI
import SpriteKit

struct StartView: View {
    @State private var pressbutton = false
    @State private var startButtonPressed = false
    @Binding var currentGameState: GameState
    @StateObject var gameLogic: ArcadeGameLogic = ArcadeGameLogic.shared
    @Binding var FirtsTime : Bool

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("StartColor")
                    .ignoresSafeArea()
//                    .onTapGesture { pressbutton = false }

                VStack {
                    if !pressbutton {
                        if !startButtonPressed && FirtsTime == true{
                            TitleView(startButtonPressed: $startButtonPressed)
                                
                        } else {
                            ChapterSelectionView(pressbutton: $pressbutton, gameLogic: gameLogic)
                        }
                    }
                    
                    // Mostrar la vista del capítulo seleccionado si no está bloqueado
                    if pressbutton, gameLogic.selectedChapter <= gameLogic.ChapterPass {
                        switch gameLogic.selectedChapter {
                        case 0: ExplanationGameView(currentGameState: $currentGameState, pressbutton: $pressbutton)
                        case 1: ExplanationsChapter2(currentGameState: $currentGameState, pressbutton: $pressbutton)
                        case 2: ExplanationsChapter3(currentGameState: $currentGameState, pressbutton: $pressbutton)
                        default:
                            ExplanationGameView(currentGameState: $currentGameState, pressbutton: $pressbutton)
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




// MARK: - Vista de selección de capítulos
struct ChapterSelectionView: View {
    @Binding var pressbutton: Bool
    @ObservedObject var gameLogic: ArcadeGameLogic

    let chapters = [
        ("Chapter 1", "chapter1"),
        ("Chapter 2", "chapter2"),
        ("Chapter 3", "chapter3")
    ]
    var progress: CGFloat {
        if gameLogic.ChapterPass == 0 { return 0 }
        if gameLogic.ChapterPass == 1 { return 0.333 }
        if gameLogic.ChapterPass == 2 { return 0.666 }
        else { return 1 }
//        CGFloat(gameLogic.ChapterPass - 1) / CGFloat(chapters.count)
    }
    
    @State private var scrollOffset: CGFloat = 0
    @State private var selectedIndex: Int = 0 // Índice del capítulo centrado
    

    var body: some View {
        VStack {
            ProgressView(value: progress , total: 1.0)
                .progressViewStyle(LinearProgressViewStyle(tint: .white))
                .frame(width: UIScreen.main.bounds.width * 0.8, height: 6)
                .background(Color.gray.opacity(0.3))
                .cornerRadius(3)
                .padding(.top, 10)
                .animation(.easeInOut(duration: 0.5), value: progress)
            // Título y subtítulo
            VStack {
                Text("Select a chapter")
                    .fontWeight(.heavy)
                    .font(.largeTitle)
                Text("To begin your journey.")
                    .font(.title2)
            }
            .foregroundColor(.white.opacity(0.9))
            .shadow(color: .white.opacity(0.3), radius: 3, x: 1, y: 2)
            .padding()

            GeometryReader { geometry in
                ScrollViewReader { scrollViewProxy in
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack() {
                            Spacer(minLength: geometry.size.width * 0.4)

                            ForEach(0..<chapters.count, id: \.self) { index in
                                let (title, imageName) = chapters[index]
                                let isLocked = gameLogic.ChapterPass < index
                                
                                GeometryReader { itemGeometry in
                                    let itemCenter = itemGeometry.frame(in: .global).midX
                                    let screenCenter = geometry.size.width * 0.5
                                    let distance = (itemCenter - screenCenter) / screenCenter
                                    
                                    // Ajustes dinámicos de escala y opacidad
                                    let scale = max(0.55, 1 - abs(distance) * 0.65)
                                    let rotationAngle = Angle(degrees: distance * 30)
                                    let opacity = max(0.6, 1.2 - abs(distance) * 0.5)

                                    ChapterButton(title: title, imageName: imageName, isLocked: isLocked) {
                                        if !isLocked {
                                            pressbutton = true
                                            gameLogic.selectedChapter = index
                                        }
                                    }
                                    .frame(height: geometry.size.height * 0.6)
                                    .scaleEffect(scale)
                                    .rotation3DEffect(rotationAngle, axis: (x: 0, y: 1, z: 0))
                                    .opacity(opacity)
                                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: scale)
                                    .animation(.easeInOut(duration: 0.4), value: opacity)
                                    .animation(.easeInOut(duration: 0.5), value: rotationAngle)
                                }
                                .frame(width: geometry.size.width * 0.3, height: geometry.size.height)
                                .id(index) // Asigna un ID para desplazamiento automático
                            }

                            Spacer(minLength: geometry.size.width * 0.4)
                        }
                    }
                    .onAppear {
                       
                        DispatchQueue.main.async {
                            if gameLogic.ChapterPass == 3 {
                                scrollViewProxy.scrollTo(1, anchor: .center)
                            }else{
                                scrollViewProxy.scrollTo(gameLogic.ChapterPass, anchor: .center)
                            }
                        }
                    }
                }
            }
            .frame(height: UIScreen.main.bounds.height )
            
        }
    }
}





// MARK: - Vista de selección de capítulos
//struct ChapterSelectionView: View {
//    @Binding var pressbutton: Bool
//    @ObservedObject var gameLogic: ArcadeGameLogic
//
//    let chapters = [
//        ("Chapter 1", "chapter1"),
//        ("Chapter 2", "chapter2"),
//        ("Chapter 3", "chapter3")
//    ]
//    
//    @State private var selectedIndex: Int = 0 // Índice del capítulo centrado
//
//    var body: some View {
//        VStack {
//            // Título y subtítulo
//            VStack {
//                Text("Select a chapter")
//                    .fontWeight(.heavy)
//                    .font(.largeTitle)
//                Text("To begin your journey.")
//                    .font(.title2)
//            }
//            .foregroundColor(.white.opacity(0.9))
//            .shadow(color: .white.opacity(0.3), radius: 3, x: 1, y: 2)
//            .padding()
//
//            // Distribuir capítulos uniformemente
//            HStack { // Ajusta `spacing` según necesidad
//                Spacer()
//                ForEach(0..<chapters.count, id: \.self) { index in
//                    let (title, imageName) = chapters[index]
//                    let isLocked = gameLogic.ChapterPass < index
//
//                    let scale: CGFloat = {
//                        if index == gameLogic.ChapterPass {
//                            return 0.9
//                        } else if index < gameLogic.ChapterPass {
//                            return index == gameLogic.ChapterPass - 1 ? 0.75 : 0.7
//                        } else {
//                            return index == gameLogic.ChapterPass + 1 ? 0.75 : 0.7
//                        }
//                    }()
//                    
//                    let opacity: CGFloat = (index == gameLogic.ChapterPass) ? 1.0 : 0.6
//                    
//                    let rotationAngle: Angle = {
//                        if index == gameLogic.ChapterPass {
//                            return .degrees(0)
//                        } else if index < gameLogic.ChapterPass {
//                            return .degrees(index == gameLogic.ChapterPass - 1 ? -5 : -4)
//                        } else {
//                            return .degrees(index == gameLogic.ChapterPass + 1 ? 5 : 4)
//                        }
//                    }()
//
//                    ChapterButton(title: title, imageName: imageName, isLocked: isLocked) {
//                        if !isLocked {
//                            pressbutton = true
//                            gameLogic.selectedChapter = index
//                        }
//                    }
//                    .scaleEffect(scale)
//                    .rotation3DEffect(rotationAngle, axis: (x: 0, y: 1, z: 0))
//                    .opacity(opacity)
//                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: scale)
//                    .animation(.easeInOut(duration: 0.4), value: opacity)
//                    .animation(.easeInOut(duration: 0.5), value: rotationAngle)
////                    .frame(width: 350) // Mantiene cada capítulo con el mismo ancho
//                    Spacer()
//                }
//                Spacer()
//            }
//            .padding(.horizontal, 20) // Padding lateral uniforme
//        }
//    }
//}




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
