//
//  ThirdPageView.swift
//  ChangeIt
//
//  Created by yatziri on 24/01/25.
//


import SwiftUI
import SpriteKit

struct ThirdPageView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Make the man ")
                    .font(.title)
                    .foregroundColor(.white)
                + Text("jump")
                    .font(.largeTitle).bold()
                    .foregroundColor(.white)
                + Text(" to avoid hitting and destroying the trees.")
                    .font(.title)
                    .foregroundColor(.white)
            }
            .padding()
            .padding(.leading, 20.0)
            
            // Reemplazo de la imagen estática por la animación de texturas "cut"
            SpriteView(scene: ManJumpAnimationScene(size: CGSize(width: 300, height: 400)))
                .frame(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.40)
//                .padding(.bottom, 100.0)
        }
    }
}

// Creación de la escena de SpriteKit para la animación de la tala de árboles
import SpriteKit

class ManJumpAnimationScene: SKScene {
    let textures = Textures()
    private var hasStartedAnimation = false

    
    override func didMove(to view: SKView) {
        if hasStartedAnimation { return }
        hasStartedAnimation = true

        backgroundColor = UIColor(named: "Color_Back") ?? .black
        
        let treeNode = SKSpriteNode(texture: textures.arbolsalto.first)
        treeNode.size = CGSize(width: textures.arbolsalto[0].size().width / 4,
                               height: textures.arbolsalto[0].size().height / 4)
        treeNode.position = CGPoint(x: size.width / 2, y: size.height / 2)
        treeNode.zPosition = 1
        
        addChild(treeNode)
        
        let animation = SKAction.animate(with: textures.arbolsalto, timePerFrame: 0.2)
        let repeatAnimation = SKAction.repeatForever(animation)
        treeNode.run(repeatAnimation)
        
        // Simulación de salto: impulso hacia arriba y caída
        let jumpUp = SKAction.moveBy(x: 0, y: 100, duration: 0.8) // Sube 100 puntos en 0.3s
        let fallDown = SKAction.moveBy(x: 0, y: -100, duration: 0.4) // Baja 100 puntos en 0.4s (más lento para simular gravedad)
        let jumpSequence = SKAction.sequence([jumpUp, fallDown])
        let repeatJump = SKAction.repeatForever(jumpSequence)
        
        treeNode.run(repeatJump)
    }
}


#Preview {
    ThirdPageView()
}
