//
//  camara.swift
//  proyectoia
//
//  Created by CEDAM06 on 27/10/25.
//

import SwiftUI

struct camara: View {
    var body: some View {
        
        VStack{
            ZStack{
                RoundedRectangle(cornerRadius: 60)
                    .frame(width: 300, height: 550)
                    .foregroundStyle(.tint)
                Text("camara").colorInvert()
            }
            
            HStack{
                
                Button(action: {},
                        label: {
                            Rectangle()
                                .frame(width: 75,height: 75)
                                .cornerRadius(25)
                        })
                
                Button(action: {},
                       label: {
                            ZStack{
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: 75)
                        
                                Image(systemName: "camera.fill")
                            }
                        })
                
                Button(action: {},
                        label: {
                            ZStack{
                                Rectangle()
                                    .frame(width: 75,height: 75)
                                    .cornerRadius(25)
                                
                                Image(systemName: "flashlight.on.fill")
                            }
                            
                        })
            }
        }
    }
}

#Preview {
    camara()
}
