//
//  extension_entidad.swift
//  app_aumentada
//
//  Integra caracteristicas nuevas a Entity para poder enviar notificaciones.
//
//  Created by Jadzia Galletas on 15/10/26.
//
import RealityKit
import Foundation


extension Entity{
    func enviar_notificacion(_ notificacion: String) -> Bool{ // Este fragmento de codigo es regalo, no entra dentro del tema asi que pueden usarlo como les plazca
        if let escena = self.scene {
            NotificationCenter.default.post(
                name: Notification.Name("RealityKit.NotificationTrigger"),
                object: nil,
                userInfo: [
                    "RealityKit.NotificationTrigger.Scene": escena,
                    "RealityKit.NotificationTrigger.Identifier": notificacion
                ]
            )
            
            return true
        }
        
        return false
    }
    
    func nombre() -> String{
        return self.name
    }
    
    func nombre(_ nombre: String){
        self.name = nombre
    }
}

