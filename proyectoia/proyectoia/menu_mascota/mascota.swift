//
//  mascota.swift
//  proyectoia
//
//  Created by CEDAM06 on 27/10/25.
//

import SwiftUI

struct mascota : View {
    var body: some View {
        TabView{
            mimascota()
                .tabItem{
                    Image(systemName: "house.fill")
                    Text("my mascota")
                }
            menu_minijuegos()
                .tabItem{
                    Image(systemName: "house.fill")
                    Text("juegos")
                }
            Text("hola")
                .tabItem{
                    Image(systemName: "house.fill")
                    Text("repaso")
                }
        }
    }
}

#Preview {
    mascota()
}
