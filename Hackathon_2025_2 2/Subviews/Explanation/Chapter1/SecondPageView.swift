//
//  SecondPageView.swift
//  ChangeIt
//
//  Created by yatziri on 24/01/25.
//

import SwiftUI
import SpriteKit

struct SecondPageView: View {
    var body: some View {
        HStack {
            
            VStack(alignment: .leading) {
                Text("Help ")
                    .font(.title)
                    .foregroundColor(.white)
                + Text("protect trees")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                + Text(" by preventing their destruction by")
                    .font(.title)
                    .foregroundColor(.white)
                + Text(" humans.")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
            }
            .padding()
            .padding(.leading, 20.0)
            
            // Reemplazo de la imagen estática por la animación de texturas "cut"
            SpriteView(scene: TreeCutAnimationScene(size: CGSize(width: 300, height: 300)))
                .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.height * 0.45)
                .padding(.bottom, 150.0)
        }
    }
}

// Creación de la escena de SpriteKit para la animación de la tala de árboles
class TreeCutAnimationScene: SKScene {
    let textures = Textures()
    private var hasStartedAnimation = false
    
    override func didMove(to view: SKView) {
        if hasStartedAnimation { return } // Evita ejecutar la animación más de una vez
        hasStartedAnimation = true

        backgroundColor = UIColor(named: "Color_Back") ?? .black
        
        let treeNode = SKSpriteNode(texture: textures.Cut_tree.first)
        treeNode.size = CGSize(width: textures.Cut_tree[0].size().width / 4, height: textures.Cut_tree[0].size().height / 4)
        treeNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        treeNode.zPosition = 1
        
        addChild(treeNode)
        
        let animation = SKAction.animate(with: textures.Cut_tree, timePerFrame: 0.2)
        let repeatAnimation = SKAction.repeatForever(animation)
        
        treeNode.run(repeatAnimation)
    }
}


#Preview {
    SecondPageView()
}


