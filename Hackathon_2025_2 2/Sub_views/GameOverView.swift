//
//  GameOverView.swift
//  Hackathon_2025_2
//
//  Created by yatziri on 27/10/25.
//

import SwiftUI
import SpriteKit

struct GameOverView: View {
    
    @Binding var currentGameState: GameState
    @StateObject var gameLogic: ArcadeGameLogic = ArcadeGameLogic.shared
    
    var body: some View {
        ZStack {
            VStack(alignment: .center) {
                VStack{
                    GameOverTitleView(selectedChapter: gameLogic.selectedChapter)
                        .padding()
                    AnimationView(selectedChapter: gameLogic.selectedChapter)
                    GameOverMessageView(selectedChapter: gameLogic.selectedChapter)
                        .padding()
                }
                .background(RoundedRectangle(cornerRadius: 20)
                    .fill(Color("Back_start"))
                    .shadow(color: Color("Back_start").opacity(0.3), radius: 5, x: 0, y: 5))
                .padding()
                
                HStack(alignment: .center, spacing: 16) {
                    Button {
                        withAnimation { self.backToMainScreen() }
                    } label: {
                        HStack {
                            if gameLogic.selectedChapter == 0 {
                                Text("Chapter 2")
                                Image(systemName: "chevron.right")
                            } else if gameLogic.selectedChapter == 1 {
                                Text("Chapter 3")
                                Image(systemName: "chevron.right")
                            } else {
                                Image(systemName: "house.fill")
                                Text("Home")
                            }
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

// Subview para el título
struct GameOverTitleView: View {
    var selectedChapter: Int
    var body: some View {
        VStack(alignment:.center) {
            if selectedChapter == 0 {
                Text("Oh no! ")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .bold()
                
                + Text("The forest is gone. . .")
                    .foregroundColor(.white)
                    .font(.title)
            }else if selectedChapter ==  1{
                Text("Too much, too late ")
                    .foregroundColor(.white)
                    .font(.largeTitle)
                    .bold()
                Text("Despite everything, the storm intensified due to climate change")
                    .foregroundColor(.white)
                    .font(.title2)
                    
            }
        }
        
        .padding()
    }
}

// Subview para el mensaje dinámico según el capítulo
struct GameOverMessageView: View {
    var selectedChapter: Int

    var body: some View {
        VStack {
            if selectedChapter == 0 {
                Text("The last ")
                    .font(.title2)
                    .foregroundColor(.white)
                + Text("trees ")
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
                + Text("have been")
                    .font(.title2)
                    .foregroundColor(.white)
                + Text(" cut down, ")
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
                + Text("the city's future is uncertain.")
                    .font(.title2)
                    .foregroundColor(.white)
                Text("What will happen next?")
                    .font(.title3)
                    .foregroundColor(.white)
                    .bold()
            } else if selectedChapter == 1 {
                
                Text("Without trees")
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
                + Text(" to absorb the water,")
                    .font(.title2)
                    .foregroundColor(.white)
                
                Text("the ")
                    .font(.title2)
                    .foregroundColor(.white)
                + Text("streets")
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
                + Text(" turned into ")
                    .font(.title2)
                    .foregroundColor(.white)
                + Text("rivers.")
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
               
            } else {
                Text("Something went wrong.")
                    .font(.title2)
                    .foregroundColor(.white)
                    .bold()
            }
        }
        .padding()
    }
}

struct AnimationView : View {
    var selectedChapter: Int
    var body: some View {
        if selectedChapter == 0 {
            SpriteView(scene: TreeDeleteAnimationScene(size: CGSize(width: 400, height: 400)))
                .frame(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.40)
        }else if selectedChapter == 1 {
            SpriteView(scene: Water_Crash_AnimationScene(size: CGSize(width: 400, height: 400), backgroundColor: UIColor(named: "Back_start") ?? .black))
                .frame(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.40)
        }
    }
}



class TreeDeleteAnimationScene: SKScene {
    let textures = Textures()
    
    override func didMove(to view: SKView) {
        backgroundColor = UIColor(named: "Back_start") ?? .black
        
        let treeNode = SKSpriteNode(texture: textures.Cut_tree.first)
        treeNode.size = CGSize(width: textures.Cut_tree[0].size().width / 5,
                               height: textures.Cut_tree[0].size().height / 5)
        treeNode.position = CGPoint(x: size.width / 3, y: size.height / 2)
        treeNode.zPosition = 1
        
        addChild(treeNode)
        
        let cloudNode = SKSpriteNode(texture: textures.Delete_tree_down.first)
        cloudNode.size = CGSize(width: textures.Delete_tree_down[0].size().width / 3,
                               height: textures.Delete_tree_down[0].size().height / 3)
        cloudNode.position = CGPoint(x: size.width * 0.7, y: size.height / 2)
        cloudNode.zPosition = 0
        
        addChild(cloudNode)
        
        let animation = SKAction.animate(with: textures.Cut_tree, timePerFrame: 0.1)
        let repeatAnimation = SKAction.repeatForever(animation)
        treeNode.run(repeatAnimation)
        
        let animation2 = SKAction.animate(with: textures.Delete_tree_down, timePerFrame: 0.1)
        let repeatAnimation2 = SKAction.repeatForever(animation2)
        cloudNode.run(repeatAnimation2)
        
        

    }
}

#Preview {
    GameOverView( currentGameState: .constant(GameState.pause))
}

