//
//  GameScoreView.swift
//  Hackathon_2025_2
//
//  Created by yatziri on 27/10/25.
//



import SwiftUI

struct GameScoreView: View {
    @Binding var score: Int
    @Binding var chapter: Int
    
    var body: some View {
        ZStack{
//            RoundedRectangle(cornerRadius: 15)
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.4))
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
//
            HStack {
                if chapter == 0 {
                    Text("Saved: ")
                        .font(.title)
                        .foregroundColor(.white)
                }else if chapter == 1 {
                    Text("Drops: ")
                        .font(.title)
                        .foregroundColor(.white)
                }else if chapter == 2 {
                    Text("Trees: ")
                        .font(.title)
                        .foregroundColor(.white)
                        .bold()
                }
                Spacer()
                Text("\(score)")
                    .bold()
                    .font(.title)
                    .foregroundColor(.white)
                    .padding()
                if chapter == 0 {
                    Image("point_tree")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50)
                }else if chapter == 1 {
                    Image("point_water")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50)
                }else if chapter == 2 {
                    Image("Planta_point")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 50)
                }
            }.padding()
        }
        .frame(width: 330, height: 70)
        .padding(24)
            

//        .cornerRadius(10)
    }
}
