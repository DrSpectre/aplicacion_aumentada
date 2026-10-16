//
//  modelos_cargar.swift
//  app_aumentada
//
//  Created by Jadzia Galletas on 16/10/26.
//
enum TiposDeAR{
    case imagen(nombre: String)
    case suelo
    case pared
}

struct Modelo{
    let modelo: String
    let tipo: TiposDeAR
}

