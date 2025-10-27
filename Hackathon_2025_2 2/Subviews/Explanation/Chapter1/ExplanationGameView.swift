//
//  SwiftUIView.swift
//  ChangeIt
//
//  Created by yatziri on 24/01/25.
//

import SwiftUI

struct ExplanationGameView: View {
    @Binding var currentGameState: GameState
    @Binding var pressbutton: Bool
    @State private var currentPage = 0
    private let totalPages = 3 // Asegúrate de que esto coincida con el número de vistas en TabView

    var body: some View {
        VStack {
            HStack {
                // Botón de regreso
                Button(action: {
                    withAnimation {
                        pressbutton = false // Regresa a la selección de capítulos
                    }
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                    .bold()
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal)
                }
                .padding(.leading)
                
                Spacer()
            }
            .padding(.top)
            ZStack {
                VStack {
                    // Contenedor superior con el botón Next
                    HStack {
                        Spacer()
                        Button(action: {
                            if currentPage < totalPages {
                                withAnimation {
                                    currentPage += 1
                                }
                            }else {
                                currentGameState = .playing
                            }
                            
                        }) {
                            HStack {
                                if currentPage < totalPages {
                                    Text("Next")
                                }else {
                                    Text("Play")
                                    Image(systemName: "play.fill")
                                }
                            }
                            .bold()
                            .foregroundColor(currentPage < totalPages ? Color("Butons") : Color("PlayButon"))
                            .padding(.horizontal)
                            .padding(.vertical, 10)
                            
                        }
                    }
                    .padding(.trailing)
                    .padding(.top)
                    
                    // Contenedor principal con TabView
                    TabView(selection: $currentPage) {
                        FirstPageView()
                            .tag(0)

                        SecondPageView()
                            .tag(1)
                        ThirdPageView()
                            .tag(2)
                        FourthPageView()
                            .tag(3)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
                    .frame(width: UIScreen.main.bounds.width * 0.75, height: UIScreen.main.bounds.height * 0.50)
                }
                .background(RoundedRectangle(cornerRadius: 20)
                                .fill(Color("Color_Back"))
                                .shadow(color: Color("Color_Back").opacity(0.3), radius: 5, x: 0, y: 5))
                .padding(.horizontal, 180)
                
            }
            
            // Botón Play
            Button(action: {
                withAnimation {
                    if currentPage == totalPages {
                        currentGameState = .playing
                    }
                }
            }) {
                Text("Play")
                    .bold()
                    .font(.title)
                    .padding(.horizontal, 70)
                    .padding(.vertical, 20)
                    .foregroundColor(currentPage == totalPages ? Color.black : Color(.systemGray).opacity(0.8))
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(currentPage == totalPages ? Color.white.opacity(0.7) : Color.gray.opacity(0.2))
                            .overlay(
                                RoundedRectangle(cornerRadius: 15)
                                    .stroke(currentPage == totalPages ? Color.black : Color.black.opacity(0), lineWidth: 2)
                            )
                            .shadow(
                                color: currentPage == totalPages ? Color.black.opacity(0.3) : Color.black.opacity(0),
                                radius: 5,
                                x: 0,
                                y: 5
                            )
                    )
                    .scaleEffect(currentGameState == .playing ? 0.8 : 1.0)
                    .animation(.spring(), value: currentGameState)
                    .disabled(currentPage != totalPages)
            }
            .padding(.top, 100)
        }
    }
}




