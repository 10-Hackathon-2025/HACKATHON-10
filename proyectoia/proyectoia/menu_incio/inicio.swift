//
//  Welcome Page.swift
//  proyecto_ia
//
//  Created by DEVELOP04 on 27/10/25.
//
import SwiftUI

struct inicio: View {
    var body: some View {
        VStack{
            ZStack{
                RoundedRectangle(cornerRadius: 30)
                    .frame(width: 300, height: 150)
                    .foregroundStyle(.tint)
                Image(systemName:"cat.fill")
                    .font(.system(size: 70))
                    .foregroundStyle(.white)
            }
            Text("Dytective")
                .font(.title)
                .fontWeight(.semibold)
                .padding(.top)
            
            Text("")
                .font(.title2)
        }
    
    }
}
#Preview {
    inicio()
}
