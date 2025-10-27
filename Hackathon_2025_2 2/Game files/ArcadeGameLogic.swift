//
//  ArcadeGameLogic 2.swift
//  ChangeIt
//
//  Created by yatziri on 20/01/25.
//

import Foundation
import Combine

@MainActor
class ArcadeGameLogic: ObservableObject {
    static let shared = ArcadeGameLogic() // Instancia única (Singleton)

    private init() {
        setUpGame()
    }

    @Published var currentScore: Int = 0
    @Published var sessionDuration: TimeInterval = 0
    @Published var isGameOver: Bool = false
    @Published var isGameWin: Bool = false
    @Published var liveScore: Int = 3
    @Published var ChapterPass: Int = 0
    @Published var selectedChapter: Int = 0
    

    func setUpGame() {
        currentScore = 0
        sessionDuration = 0
        liveScore = 3
        isGameOver = false
        isGameWin = false
    }

    func score(points: Int) {
        currentScore += points
        if currentScore == 5 {
            isGameWin = true
        }else {
            isGameWin = false
        }
    }

    func increaseSessionTime(by timeIncrement: TimeInterval) {
        sessionDuration += timeIncrement
    }

    func restartGame() {
        setUpGame()
    }

    func finishGame() {
        isGameOver = true
    }

    func loseLife(points: Int) {
        liveScore -= points
        if liveScore <= 0 {
            finishGame()
        }
    }
    func passLever1() {
        ChapterPass = 1
    }
    func passLever2() {
        ChapterPass = 2
    }
    func passLever3() {
        ChapterPass = 3
    }
}

