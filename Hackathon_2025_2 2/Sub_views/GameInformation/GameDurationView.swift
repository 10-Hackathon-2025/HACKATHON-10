//
//  GameDurationView.swift
//  Hackathon_2025_2
//
//  Created by yatziri on 27/10/25.
//




import SwiftUI


struct GameDurationView: View {
    @Binding var lives: Int
    @Binding var chapter: Int
    
    var body: some View {
        
        ZStack{
            RoundedRectangle(cornerRadius: 15)
                .fill(Color.black.opacity(0.4))
                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 0, y: 5)
            HStack {
                ForEach(0..<lives, id: \.self) { index in
                    if chapter == 0 {
                        Image("point_cut")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50)
                    }else if chapter == 1 {
                        Image("point_cloud")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 50)
                    }
                    
                }
                .padding()
            }
        }
            .frame(width: 330, height: 70)
            .padding(24)
                

        
    }
    
}


extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        Scanner(string: hexSanitized).scanHexInt64(&rgb)

        self.init(
            red: Double((rgb & 0xFF0000) >> 16) / 255.0,
            green: Double((rgb & 0x00FF00) >> 8) / 255.0,
            blue: Double(rgb & 0x0000FF) / 255.0
        )
    }
}


