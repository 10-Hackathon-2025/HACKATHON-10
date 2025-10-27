import SwiftUI

struct Constants{
    static let appLenguageKey = "appLanguage"
}

struct configuracion: View {
    
    @State var opt1: Bool = false
    @State var opt2: Bool = false
    @State var opt3: Bool = false
    @State var opt4: Bool = true
    @State var opt5: Bool = true
    @State private var opt6: Bool = true
    @State private var reminderTime: Date = Date()
    @State private var textSize: String = "Mediano"
    
    @AppStorage(Constants.appLenguageKey)
    
    private var selectedLanguage: String = "es"
    
    var body: some View {
        
        NavigationView {
            List{
                Section(header:Text("Notificaciónes")){
                    HStack{ Text("Recordatorio de Lección")
                        Image(systemName: "iphone.gen1")
                        Image(systemName: "mail.fill")
                        Image(systemName: "bell.fill")
                    }
                    
                    Toggle("Tiempo Restante",isOn: $opt5)
                    Toggle("Repaso",isOn: $opt6)
                    
                    if opt6{DatePicker("Hora de Repaso", selection: $reminderTime, displayedComponents: . hourAndMinute)
                        .datePickerStyle(.compact)}
                }
                
                Section(header: Text("Vista")){
                    Toggle("modo oscuro",isOn: $opt1)
                    Toggle("invertir colores",isOn: $opt2)
                    Toggle("modo daltonico",isOn: $opt3)
                    
                }
                Section(header:Text("Apariencia")){
                    Picker("Tamaño de texto",selection: $textSize){
                        Text("Pequeño").tag("pequeño")
                        Text("Mediano").tag("mediano")
                        Text("Grande").tag("grande")
                    }
                    }
                Section(header:Text("GENERAL")){
                    Picker("Idioma", selection: $selectedLanguage){
                        Text("Español").tag("es")
                        Text("Ingles").tag("en")
                        Text("Seguir Sistema").tag("system")
                    }
                }
                
            }.navigationTitle("Configuración")
            
        }.id(selectedLanguage)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View{
        configuracion()
    }
}
