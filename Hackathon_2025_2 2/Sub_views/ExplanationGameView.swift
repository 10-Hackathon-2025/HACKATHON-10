//
//  ExplanationGameView.swift
//  Hackathon_2025_2
//
//  Created by yatziri on 27/10/25.
//


import SwiftUI
struct ExplanationGameView: View {
    @Binding var currentGameState: GameState
    @State private var currentPage = 0

    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 15)
                    .frame(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.height * 0.60)
                    .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)

                VStack {
                    
                }
            }
            ZStack {
                Button(action: {
                    withAnimation {
                        if currentPage == 3{
                            currentGameState = .playing
                        }
                    }
                }) {
                    Text("Play")
                        .bold()
                        .font(.title)
                        .padding(.horizontal, 70)
                        .padding(.vertical, 20)
                        .foregroundColor(Color.white) // Set the default color
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(currentPage == 3 ? Color.green : Color.gray.opacity(0.5)) // Change color based on currentPage
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
                        )
                        .scaleEffect(currentGameState == .playing ? 0.8 : 1.0)
                        .disabled(currentPage != 3) // Disable the button if not on the last page
                }
            }
            .padding(.top, 100.0)
        }
    }
}
//
//struct CarouselPageView: View {
//    var description: String
//    var images: [String]?
//
//    var body: some View {
//        HStack {
//            Text(description)
////                .bold()
//                .font(.title)
//                .foregroundColor(.white)
//                .padding()
//                .padding(.leading, 20.0)
////            Spacer()
//            if let images = images {
//                VStack{
//                    ForEach(images, id: \.self) { imageName in
//                        if images.count > 2 {
//                            Image(imageName)
//                                .resizable()
//                                .scaledToFit()
//                                .frame(width: UIScreen.main.bounds.width / (CGFloat(images.count) + 1.0), height: UIScreen.main.bounds.height / (CGFloat(images.count) + 6.0))
//                                .padding()
//                        }else{
//                            if images.count == 2 {
//                                Image(imageName)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: UIScreen.main.bounds.width / (CGFloat(images.count) + 1.0), height: UIScreen.main.bounds.height / (CGFloat(images.count) + 2.5))
//                                    .padding()
//                            }else{
//                                Image(imageName)
//                                    .resizable()
//                                    .scaledToFit()
//                                    .frame(width: UIScreen.main.bounds.width * 0.3, height: UIScreen.main.bounds.height * 0.40)
//                                    .padding()
//                            }
//                        }
//                    }
//                }
//            }
//            Spacer()
//           
//        }
//    }
//}
//let carouselData: [(String, [String]?)] = [
//    ("Help Ramon navigate a world threatened by deforestation and climate change.", ["arbol1"]),
//    ("In which he needs to avoid fires and lumberjacks jumping over them.", ["fuego2", "lenador1"]),
//    ("You would only have 3 lives, or Ramon will become one more tree in the history of deforestation.", ["vidas", "vidas", "vidas"]),
//]





#Preview {
    ExplanationGameView(currentGameState: .constant(.firstTime))
}
