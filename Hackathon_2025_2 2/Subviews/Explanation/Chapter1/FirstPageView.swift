//
//  SwiftUIView.swift
//  ChangeIt
//
//  Created by yatziri on 24/01/25.
//
import SwiftUI
import SpriteKit
import SwiftUI
import SpriteKit

struct FirstPageView: View {
    let textures = Textures()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("The city is expanding and")
                    .font(.title)
                    .foregroundColor(.white)
                + Text(" trees ")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                + Text("seem to be nothing more than ")
                    .font(.title)
                    .foregroundColor(.white)
                + Text("obstacles ")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                + Text("to some people.")
                    .font(.title)
                    .foregroundColor(.white)
            }
            .padding()
            .padding(.leading, 20.0)
            
            // Integrar la animación dentro de un SpriteView
            SpriteView(scene: TreeCuttingScene(size: CGSize(width: 300, height: 400)))
                .frame(width: UIScreen.main.bounds.width * 0.35, height: UIScreen.main.bounds.height * 0.50)
                .padding()
        }
    }
}

class TreeCuttingScene: SKScene {
    let textures = Textures()
    private var hasStartedAnimation = false
    
    override func didMove(to view: SKView) {
        if hasStartedAnimation { return } // Evita ejecutar la animación más de una vez
        hasStartedAnimation = true

        backgroundColor = UIColor(named: "Color_Back") ?? .black
        
        let treeNode = SKSpriteNode(texture: textures.Delete_tree_down.first)
        treeNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        treeNode.size = CGSize(width: textures.Delete_tree_down[0].size().width / 3,
                               height: textures.Delete_tree_down[0].size().height / 3)
        treeNode.zPosition = 1
        
        addChild(treeNode)
        
        let animation = SKAction.animate(with: textures.Delete_tree_down, timePerFrame: 0.2)
        let repeatAnimation = SKAction.repeatForever(animation)
        
        treeNode.run(repeatAnimation)
    }
}


#Preview {
    FirstPageView()
}


