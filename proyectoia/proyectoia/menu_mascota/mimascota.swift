//
//  mimascota.swift
//  proyectoia
//
//  Created by CEDAM06 on 27/10/25.
//

import SwiftUI

struct mimascota: View {
    var body: some View {

        VStack{
            Rectangle()
                .frame(width: 300, height: 300)
                .cornerRadius(50)
                .padding(40)
            VStack{
                HStack{
                    Rectangle()
                        .frame(width: 100, height: 100)
                        .cornerRadius(20)
                    Rectangle()
                        .frame(width: 100, height: 100)
                        .cornerRadius(20)
                    Rectangle()
                        .frame(width: 100, height: 100)
                        .cornerRadius(20)
                }
                HStack{
                    Rectangle()
                        .frame(width: 100, height: 100)
                        .cornerRadius(20)
                    Rectangle()
                        .frame(width: 100, height: 100)
                        .cornerRadius(20)
                    Rectangle()
                        .frame(width: 100, height: 100)
                        .cornerRadius(20)
                }
            }
        }
    }
}

#Preview {
    mimascota()
}
