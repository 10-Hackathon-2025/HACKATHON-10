//
//  PauseView.swift
//  Hackathon_2025_2
//
//  Created by yatziri on 27/10/25.
//



import SwiftUI

struct PauseView: View {
    
    @Binding var currentGameState: GameState
    
    var body: some View {
        VStack{
            Image("lose")
            Text("Pause")
                .font(.custom("Atlantis Headline",
                              size: 40, relativeTo: .headline))
                .foregroundStyle(Color.white)
            Button(action: {
                currentGameState = .pause
            }, label: {
                Image("pauseButton")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 100)
            })
        }
        .ignoresSafeArea()
        .background(
            Color(red: 122/255, green: 184/255, blue: 229/255)
            .ignoresSafeArea()
            .aspectRatio(contentMode: .fill)
        )
    }
}

#Preview {
    PauseView(currentGameState: .constant(.pause))
}

