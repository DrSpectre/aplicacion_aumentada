//
//  ventana_lateral.swift
//  app_aumentada
//
//  Created by Jadzia Galletas on 19/10/26.
//
import SwiftUI


struct VentanaLateral: View {
    @Environment(Controlador.self) var control
    
    
    var body: some View {
        switch(control.estado){
            case .mostrar_informacion:
                VStack{
                    Text(control.informacion_a_mostrar)
                    Button{
                        control.pulsaron_boton("cancelar")
                    }
                    label: {
                        Text("Entendido, salir")
                    }
                }
                
            default:
                VStack{}
        }
    }
}


