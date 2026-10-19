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
    
    var informacion_a_mostrar: String = ""
    
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
            // guard let entidad = try? await Entity(named: modelo.modelo, in: ar_realitykitBundle) else {
            guard let entidad = try? await ModelEntity(mesh: .generateBox(size: 0.1)) else {
                fatalError("Modelo \(modelo.modelo) no encontrado.")
            }
            
            /*
            entidad.generateCollisionShapes(recursive: true)
            entidad.components.set(InputTargetComponent())
             */ /// Seccion de depuracion. Tener cuidado
            
            entidad.nombre(modelo.modelo)
            
            switch(modelo.tipo){
                case .imagen(let nombre):
                    let imagen = AnchorEntity(.image(group: "ar", name: nombre)) // Pueden reemplazar AR con el nombre de su carpteta de imagenes o recurso de Realidad Aumentada
                    
                    imagen.addChild(entidad)
                    
                    anclas.append(imagen)
                    escenario.addChild(imagen)
                    
                case .pared(let tamaño):
                    let pared = AnchorEntity(.plane(.vertical, classification: .wall, minimumBounds: SIMD2(tamaño, tamaño)))
                    
                    pared.addChild(entidad)
                    
                    anclas.append(pared)
                    escenario.addChild(pared)
                
                case .suelo(let tamaño):
                    let suelo = AnchorEntity(.plane(.horizontal, classification: .floor, minimumBounds: SIMD2(tamaño, tamaño)))
                    
                    suelo.addChild(entidad)
                    
                    escenario.addChild(suelo)
                    anclas.append(suelo)
            }
        }
        
        // Aqui cargamos un modelo importante como el que tendra todas las cosas.
        // guard let modelo_importante = try? await Entity(named: "nombre del modelo", in: tu_bundleBundle) else {
        guard let modelo_importante = try? await ModelEntity(mesh: .generateSphere(radius: 0.1)) else {
            fatalError("Fallo al cargar el mdoelo mas importante")
        }
        self.modelo_importante = modelo_importante
        // Lo pegue al suelo
        let suelo = AnchorEntity(.plane(.horizontal, classification: .floor, minimumBounds: SIMD2(1, 1)))
        
        suelo.addChild(modelo_importante)
        
        escenario.addChild(suelo)
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
            
            if distancia < 0.2 {
                objeto_rastreado.enviar_notificacion("reproduce audio")
            }
        }
    }
    
    func apachurraron_a(_ entidad: Entity){// Este de aqui es llamado cada vez que pulsan o interactuan con una entidad.
        switch(entidad.nombre()){
            case "":
                fatalError("La entidad no tiene nombre")
                
            case "el nombre en especifico":
                estado = .mostrar_informacion
                informacion_a_mostrar = "Este es un texto de prueba"
            /*default:
                break;*/
                
        }
        entidad.enviar_notificacion("animacion")
    }
    
    func pulsaron_boton(_ nombre: String){
        // Podemos saber cual boton pulasron y que debemos de hacer cuando lo pulsan.
        estado = .descanso
    }
}


