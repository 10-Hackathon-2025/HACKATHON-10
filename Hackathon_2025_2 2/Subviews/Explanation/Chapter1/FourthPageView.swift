//
//  FourthPageView.swift
//  ChangeIt
//
//  Created by yatziri on 24/01/25.
//


import SwiftUI

struct FourthPageView: View {
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Every tree counts!  ")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                Text("The number of trees you  ")
                    .font(.title)
                    .foregroundColor(.white)
                + Text("save")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                + Text(" and those that get")
                    .font(.title)
                    .foregroundColor(.white)
                + Text(" cut down")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                + Text(" will be")
                    .font(.title)
                    .foregroundColor(.white)
                + Text(" tracked.")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.white)
                
            }
            .padding()
            .padding(.leading, 20.0)
            .padding(.trailing, 50.0)
            
            VStack{
                Image("point_cut")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.height * 0.15)
                    .padding()
                Image("point_tree")
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIScreen.main.bounds.width * 0.15, height: UIScreen.main.bounds.height * 0.15)
                    .padding()
            }
            
        }
        
    }}

#Preview {
    FourthPageView()
}


