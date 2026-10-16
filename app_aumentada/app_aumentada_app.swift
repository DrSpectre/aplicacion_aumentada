//
//  app_aumentadaApp.swift
//  app_aumentada
//
//  Created by Jadzia Galletas on 15/10/26.
//

import SwiftUI

@main
struct app_aumentadaApp: App {
    @State var controlador = Controlador()
    
    var body: some Scene {
        WindowGroup {
            VistaAR()
                .environment(controlador)
        }
    }
}
