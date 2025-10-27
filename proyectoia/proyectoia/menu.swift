import SwiftUI

struct menu: View {
    var body: some View {
        
        TabView{
            inicio()
                .tabItem{
                    Image(systemName: "house.fill")
                    Text("incio")
                }
            mascota()
                .tabItem{
                    Image(systemName: "cat.fill")
                    Text("mascota")
                }
            camara()
                .tabItem{
                    Image(systemName: "camera.fill")
                    Text("camara")
                }
            chat()
                .tabItem{
                    Image(systemName: "menucard.fill")
                    Text("chats")
                }
            configuracion()
                .tabItem{
                    Image(systemName: "person.fill")
                    Text("configuración")
                }
        }.toolbarBackgroundVisibility(.visible, for: .tabBar)
    }
}

#Preview {
    menu()
}
