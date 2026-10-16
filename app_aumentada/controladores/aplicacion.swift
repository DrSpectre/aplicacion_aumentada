//
//  aplicacion.swift
//  app_aumentada
//
//  Created by Jadzia Galletas on 15/10/26.
//
import SwiftUI
import RealityKit
// import ar_realitykit
import Combine


@Observable
class Controlador{
    public private(set) var estado: EstadosControlador = .inicializando
    // Aqui hacemos la tecnica del _var privado y variable publica para cosnutlar. SOlo que mas facil al parecer.
    
    private(set) var escenario: Entity = Entity() // Este va a servir para guardar las cosas aqui directamente y no tener que avisarle a las vistas que deben de refrescar o agregar nuevos modelos. Practicidad.
    
    
    private var anclas: [AnchorEntity] = [] // Aqui voy a guardar las anclas de imagenes
    private(set) var distancias: [AnchorEntity: Float] = [:]
    private var modelo_importante: Entity? = nil
    
    private(set) var modelos: [Entity] = [] // Aqui guardare los modelos para hacer cosas
    
    private var temporizador: AnyCancellable? = nil
    
    init(){
        // Aqui vamos a cargar las cosas que se requieren, como modelos de imagenes o cosas similares.
        escenario.name = "raiz"
        Task.detached(priority: .high){ // Este nos sirve para crear hilos de ejeccuion independientes para realizar tareas de forma paralela.
            await self.cargar_modelos() // Esta funcion es de tipo asincrona, para ejecutarse mientras el hilo principal hace cosas.
            // Asi que lo mandamos a hacer cosas, lo que tenga en su interior y pasamos a hacer mas cosas.
        }
    }
    
    
    func cargar_modelos() async {
        defer{ // Usamos esta palabra para indicar que cuando finalizce todo lo asincrono vamos a ejectura lo que este dentro de su bloque de codigo.
            temporizador = Timer.publish(every: 0.3, on: .main, in: .common)
            ///      EN every va la cantidad de segundos que se debe de autoactivar el reloj. Colocare cada tercio de segundo para que se sienta muy resposivo.
                .autoconnect()
                .sink{ [weak self] _ in self?.actualizar_distancias()}
            
            estado = .descanso // Utilizare este estado para idnicar que ya todo esta cargado
        }
        
        for modelo in modelos_disponibles{
            guard let entidad = try? await Entity(named: modelo.modelo, in: ar_realitykitBundle) else {
                fatalError("Modelo \(modelo.modelo) no encontrado.")
            }
            
            switch(modelo.tipo){
                case .imagen(let nombre):
                    let imagen = AnchorEntity(.image(group: "ar", name: nombre))
                    
                    imagen.addChild(entidad)
                    
                    anclas.append(imagen)
                    escenario.addChild(imagen)
                    
                case .pared:
                    let pared = AnchorEntity(.plane(.vertical, classification: .wall, minimumBounds: SIMD2(0.1, 0.1)))
                    
                    pared.addChild(entidad)
                    
                    anclas.append(pared)
                    escenario.addChild(pared)
                
                case .suelo:
                    let suelo = AnchorEntity(.plane(.horizontal, classification: .floor, minimumBounds: SIMD2(0.1, 0.1)))
                    
                    suelo.addChild(entidad)
                    
                    escenario.addChild(suelo)
                    anclas.append(suelo)
            }
        }
        
        // Aqui cargamos un modelo importante como el que tendra todas las cosas.
        guard let modelo_importante = try? await Entity(named: "nombre", in: tu_realityKitBundle) else {
            fatalError("Fallo al cargar el mdoelo mas importante")
        }
        // Lo pegue al suelo
        let suelo = AnchorEntity(.plane(.horizontal, classification: .floor, minimumBounds: SIMD2(0.1, 0.1)))
        
        suelo.addChild(modelo_importante)
        
        escenario.addChild(modelo_importante)
    }
    
    
    func actualizar_distancias(){
        guard let posicion_modelo_importante = modelo_importante?.position(relativeTo: nil) else {
            fatalError("Escenario principal no existe")
        }
        
        for objeto_rastreado in anclas{
            let posicion_objeto = objeto_rastreado.position(relativeTo: nil)
            
            let distancia: Float
            
            if posicion_objeto == simd_float3(0.0, 0.0, 0.0){
                distancia = 0
            }
            
            else {
                distancia = simd_distance(posicion_objeto, posicion_modelo_importante)
            }
            
            distancias[objeto_rastreado] = distancia
        }
    }
}


