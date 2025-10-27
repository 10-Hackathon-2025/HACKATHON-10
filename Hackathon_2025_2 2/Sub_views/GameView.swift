//
//  GameView.swift
//  Hackathon_2025_2
//
//  Created by yatziri on 27/10/25.
//

import SwiftUI
import SpriteKit
import Combine

struct GameView: View {

    // Si tu app usa estados de navegación superiores, mantenlo:
    @Binding var currentGameState: GameState

    // Lógica central del juego (singleton)
    @StateObject private var gameLogic = ArcadeGameLogic.shared

    // Reglas de partida
    private let targetScore: Int = 15   // <- gana al alcanzar este puntaje
    private let sceneScale: SKSceneScaleMode = .resizeFill

    // Presentación de overlays
    @State private var isWinViewPresented = false
    @State private var isPauseViewPresented = false

    // Tamaño de pantalla
    private var screenSize: CGSize {
        UIScreen.main.bounds.size
    }

    // Inyección de lógica en la escena SpriteKit (instancia viva para poder pausar/reiniciar)
    @State private var arcadeGameScene = GameScene()

    // MARK: - Pause/Resume helpers
    private func pauseGame() {
        gameLogic.pause()
        arcadeGameScene.pauseScene()
        isPauseViewPresented = true
    }

    private func resumeGame() {
        gameLogic.resume()
        arcadeGameScene.resumeScene()
        withAnimation { isPauseViewPresented = false }
    }

    var body: some View {
        ZStack(alignment: .top) {

            // 1) Juego (SpriteKit)
            SpriteView(scene: arcadeGameScene, options: [.ignoresSiblingOrder])
                .ignoresSafeArea()
                .statusBar(hidden: true)

            // 2) HUD (Score + Timer + Controles básicos)
            VStack(spacing: 12) {
                HStack {
                    // Puntaje
                    Text("⭐️ \(gameLogic.score)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())

                    Spacer()

                    // Tiempo
                    Text("⏱ \(gameLogic.timeText)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(.ultraThinMaterial, in: Capsule())
                }

                // Controles de partida
                HStack(spacing: 10) {
                    /*Button {
                        gameLogic.startNewGame()   // resetea score/tiempo/flags
                        isWinViewPresented = false
                        gameLogic.start()          // arranca el temporizador
                    } label: {
                        Label("Nuevo", systemImage: "arrow.clockwise.circle.fill")
                    }*/

                    Button {
                        if gameLogic.isRunning {
                            pauseGame()
                        } else {
                            resumeGame()
                        }
                    } label: {
                        Label(gameLogic.isRunning ? "Pausa" : "Reanudar",
                              systemImage: gameLogic.isRunning ? "pause.circle.fill" : "play.circle.fill")
                    }
                    .disabled(gameLogic.isGameOver)

                    /*
                    Button(role: .destructive) {
                        gameLogic.endGame()
                    } label: {
                        Label("Terminar", systemImage: "stop.circle.fill")
                    }*/
                }
                .labelStyle(.titleAndIcon)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
            }
            .padding()
            .padding(.top, 40)

            // 3) Overlay cuando se agota el tiempo: mostrar resumen con palabras buenas
            if isWinViewPresented {
                winview(currentGameState: $currentGameState)
                    .transition(.opacity)
            }
            // 3b) Overlay de Pausa
            if isPauseViewPresented {
                PauseOverlay(
                    onResume: {
                        resumeGame()
                    },
                    onRestart: {
                        // Reinicia lógica y escena desde cero
                        isWinViewPresented = false
                        arcadeGameScene.pauseScene()

                        gameLogic.startNewGame()

                        let newScene = GameScene()
                        newScene.size = UIScreen.main.bounds.size
                        newScene.scaleMode = .resizeFill
                        newScene.isPaused = false
                        arcadeGameScene = newScene

                        gameLogic.start()
                        withAnimation { isPauseViewPresented = false }
                    },
                    onEnd: {
                        gameLogic.endGame()
                        arcadeGameScene.isPaused = true
                        withAnimation {
                            isPauseViewPresented = false
                            isWinViewPresented = true
                        }
                    }
                )
                .transition(.opacity)
            }
        }
        .onAppear {
            // Preparar una partida al entrar
            gameLogic.startNewGame() // limpia estado, deja listo
            gameLogic.start()        // arranca el timer de una vez; quítalo si prefieres esperar al botón
            
            arcadeGameScene.size = screenSize
            arcadeGameScene.scaleMode = sceneScale
            arcadeGameScene.isPaused = false
        }
        .onDisappear {
            // Evita timers corriendo en segundo plano
            gameLogic.endGame()
            arcadeGameScene.isPaused = true
        }
        // Reglas de victoria/derrota basadas en la lógica
        .onChange(of: gameLogic.score) { newScore in
            if newScore >= targetScore && !gameLogic.isGameOver {
                isWinViewPresented = true
                gameLogic.endGame()
            }
        }
        .onChange(of: gameLogic.remainingTime) { timeLeft in
            if timeLeft <= 0 {
                isWinViewPresented = true
            }
        }
        // Bridge: listen to SpriteKit scene updates
        .onReceive(NotificationCenter.default.publisher(for: .gameScoreDidChange)) { note in
            if let value = note.userInfo?["score"] as? Int {
                gameLogic.setScore(value)
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .gameTimeDidChange)) { note in
            if let value = note.userInfo?["time"] as? Int {
                gameLogic.setRemainingTime(TimeInterval(value))
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .gameDidEnd)) { _ in
            // Ensure logic reflects end-of-game and present overlay
            gameLogic.endGame()
            arcadeGameScene.isPaused = true
            isWinViewPresented = true
        }
    }
}

private struct PauseOverlay: View {
    var onResume: () -> Void
    var onRestart: () -> Void
    var onEnd: () -> Void

    var body: some View {
        ZStack {
            // Fondo atenuado detrás del cuadro
            Color.black.opacity(0.45)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text("¡Juego en pausa!")
                        .font(.system(size: 32, weight: .heavy, design: .rounded))
                        .multilineTextAlignment(.center)
                    Text("Puedes reanudar, reiniciar o terminar la partida.")
                        .font(.system(size: 17, weight: .regular, design: .rounded))
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                VStack(spacing: 10) {
                    Button(action: onResume) {
                        Label("Reanudar", systemImage: "play.fill")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.borderedProminent)

                    /*Button(action: onRestart) {
                        Label("Reiniciar", systemImage: "arrow.clockwise")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(.bordered)*/

                    
                }
            }
            .padding(20)
            .frame(maxWidth: 360)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(.ultraThinMaterial)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .strokeBorder(.white.opacity(0.12))
            )
            .shadow(color: .black.opacity(0.25), radius: 24, x: 0, y: 12)
            .padding()
        }
    }
}

