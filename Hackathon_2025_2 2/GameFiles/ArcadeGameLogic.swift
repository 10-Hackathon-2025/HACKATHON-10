//
//  ArcadeGameLogic.swift
//  Hackathon_2025_2
//
//  Created by yatziri on 27/10/25.
//

import Foundation
import Combine

@MainActor
final class ArcadeGameLogic: ObservableObject {
    // MARK: - Singleton
    static let shared = ArcadeGameLogic()
    private init() {}

    // MARK: - Published HUD State
    @Published private(set) var score: Int = 0
    @Published private(set) var remainingTime: TimeInterval = 60
    @Published private(set) var isGameOver: Bool = false
    @Published private(set) var isRunning: Bool = false
    @Published var selectedChapter: Int = 0

    // MARK: - Configuration
    struct Config {
        var initialTime: TimeInterval = 60
        var tickInterval: TimeInterval = 1.0
        var goodWordPoints: Int = 1
        var badWordTimePenalty: TimeInterval = 3
    }
    var config = Config()

    // MARK: - Timer
    private var timerCancellable: AnyCancellable?

    // MARK: - Derived HUD text
    var timeText: String {
        let total = max(0, Int(remainingTime))
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Game Lifecycle
    func startNewGame(duration: TimeInterval? = nil) {
        stopTimer()
        score = 0
        remainingTime = duration ?? config.initialTime
        isGameOver = false
        isRunning = false
    }

    func start() {
        guard !isGameOver else { return }
        isRunning = true
        startTimer()
    }

    func pause() {
        isRunning = false
        stopTimer()
        // Notificar a quien lo necesite (p. ej. GameScene) que debe pausar
        NotificationCenter.default.post(name: .gameDidPause, object: nil)
    }

    func resume() {
        guard !isGameOver else { return }
        isRunning = true
        startTimer()
        // Notificar a quien lo necesite (p. ej. GameScene) que debe reanudar
        NotificationCenter.default.post(name: .gameDidResume, object: nil)
    }

    func endGame() {
        isRunning = false
        isGameOver = true
        stopTimer()
    }
    
    func restartGame() {
        startNewGame()
        start()
    }
    
    func togglePause() {
        if isRunning {
            pause()
        } else {
            resume()
        }
    }

    // MARK: - Events from GameScene
    func collectedGoodWord() {
        guard !isGameOver else { return }
        score += config.goodWordPoints
    }

    func hitBadWord() {
        guard !isGameOver else { return }
        remainingTime = max(0, remainingTime - config.badWordTimePenalty)
        if remainingTime <= 0 {
            remainingTime = 0
            endGame()
        }
    }

    func applyTimeBonus(_ seconds: TimeInterval) {
        guard !isGameOver else { return }
        remainingTime += max(0, seconds)
    }

    // MARK: - External State Updates (bridges from SpriteKit / Notifications)
    /// Safely set the current score from external sources (e.g., notifications)
    func setScore(_ value: Int) {
        score = value
    }

    /// Safely set remaining time from external sources
    func setRemainingTime(_ value: TimeInterval) {
        remainingTime = max(0, value)
        if remainingTime <= 0 {
            remainingTime = 0
            endGame()
        }
    }

    // MARK: - Timer internals
    private func startTimer() {
        stopTimer()
        timerCancellable = Timer.publish(every: config.tickInterval, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.tick()
            }
    }

    private func stopTimer() {
        timerCancellable?.cancel()
        timerCancellable = nil
    }

    private func tick() {
        guard isRunning, !isGameOver else { return }
        if remainingTime > 0 {
            remainingTime -= config.tickInterval
            if remainingTime <= 0 {
                remainingTime = 0
                endGame()
            }
        }
    }
}

extension Notification.Name {
    static let gameDidPause = Notification.Name("gameDidPause")
    static let gameDidResume = Notification.Name("gameDidResume")
}
