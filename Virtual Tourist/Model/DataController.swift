//
//  DataController.swift
//  Virtual Tourist
//
//  Created by Courtney Torres on 8/26/20.
//  Copyright © 2020 Courtney Torres. All rights reserved.
//

import Foundation
import CoreData

class DataController {
    
    let persistentContainer : NSPersistentContainer
    
    var viewContext : NSManagedObjectContext{
        return persistentContainer.viewContext
    }
    
    init(modelName:String) {
        persistentContainer = NSPersistentContainer(name: modelName)
    }
    
    func load(completion:(()->Void)? = nil){
        persistentContainer.loadPersistentStores{ storeDescription, error in
            guard error == nil else {
                fatalError(error!.localizedDescription)
            }
            self.autoSaveContext()
            completion?()
        }
    }
    
    func autoSaveContext(interval: TimeInterval = 30){
        guard interval > 0 else {
            print("cannot set negative autosave interval")
            return
        }
        
        if viewContext.hasChanges {
            try? viewContext.save()
        }
        DispatchQueue.main.asyncAfter(deadline: .now()+interval) {
            self.autoSaveContext(interval: interval)
        }
        
    }
}
