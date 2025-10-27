//
//  menu_minijuegos.swift
//  proyectoia
//
//  Created by CEDAM06 on 27/10/25.
//

import SwiftUI

struct menu_minijuegos: View {
    var body: some View {
        VStack{
            
            Button(action: {},
                   label:{
                Rectangle()
                    .frame(width: 200, height: 200)
                    .cornerRadius(50)})
            
            Button(action: {},
                   label:{
                Rectangle()
                    .frame(width: 200, height: 200)
                    .cornerRadius(50)})
            
            Button(action: {},
                   label:{
                Rectangle()
                    .frame(width: 200, height: 200)
                    .cornerRadius(50)})
        }
    }
}

#Preview {
    menu_minijuegos()
}
