//
//  pantalla_ar.swift
//  app_aumentada
//
//  Created by Jadzia Galletas on 15/10/26.
//
import RealityKit
import SwiftUI


struct VistaAR: View {
    @Environment(Controlador.self) var control
    
    
    var body: some View {
        switch(control.estado){
            case .inicializando:
                Text("Cargando")
                
            case .descanso:
                RealityView{ escenario in
                    escenario.camera = .spatialTracking
                    
                    escenario.add(control.escenario)
                    
                }
        }
        
        
    }
}

