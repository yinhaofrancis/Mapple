//
//  Route.swift
//  Mapple
//
//  Created by hao yin on 2021/7/14.
//

import Foundation

public struct Route<T>{
    public var name:String
    public var creator:(Dictionary<String,String>)->T
    public init(name:String,creator:@escaping (Dictionary<String,String>)->T){
        self.name = name
        self.creator = creator
    }
}


public class ConfigrationRoute<T>{

    private var keyPath:Dictionary<String,Route<T>>
    public init(@RouteBuilder<T> create:()->Dictionary<String,Route<T>>) {
        self.keyPath = create()
    }
    
    public func route(route:String,param:Dictionary<String,String> = [:])->T?{
        self.keyPath[route]?.creator(param)
    }
    
    
    @resultBuilder
    public enum RouteBuilder<T>{
        public static func buildBlock(_ components: Route<T>...) -> Dictionary<String,Route<T>> {
            components.reduce(into: [:]) { r, o in
                r[o.name] = o
            }
        }
        
    }
}
