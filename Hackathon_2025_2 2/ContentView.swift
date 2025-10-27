import SwiftUI

struct ContentView: View {
    
    // El estado actual del juego determina qué vista se muestra en la aplicación.
    @State private var currentGameState: GameState = .firstTime

    // La lógica del juego es un singleton compartido entre todas las vistas.
    @StateObject private var gameLogic = ArcadeGameLogic.shared
    
    @State private var FirtsTime: Bool = true
    
    
    var body: some View {
        Group {
            switch currentGameState {
            case .firstTime:
                StartView(currentGameState: $currentGameState, FirtsTime: $FirtsTime)
                
            case .home:
                StartView(currentGameState: $currentGameState, FirtsTime: .constant(false))
                
            case .playing:
                GameView(currentGameState: $currentGameState)
                    .environmentObject(gameLogic)
                
            case .pause:
                PauseView(currentGameState: $currentGameState)
                    .environmentObject(gameLogic)
            
//            case .gameOver:
//                GameOverView(currentGameState: $currentGameState)
//                    .environmentObject(gameLogic)
                
//            case .win:
//                winview(currentGameState: $currentGameState)
//                    .environmentObject(gameLogic)
            }
        }
        .onAppear {
            Task {
                gameLogic.restartGame()
            }
        }
    }
}


#Preview {
    ContentView()
}

