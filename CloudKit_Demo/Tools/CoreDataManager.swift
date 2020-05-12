//
//  CoreDataManager.swift
//  CloudKit_Demo
//
//  Created by Mac on 2020/5/8.
//  Copyright © 2020 Mac. All rights reserved.
//

import Foundation
import CoreData
import CloudKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    //MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
    
        let container = NSPersistentContainer(name: "CloudKit_Demo")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    static var managedContext: NSManagedObjectContext{
        let context = CoreDataManager.shared.persistentContainer.viewContext

        return context
    }

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}

extension CoreDataManager {
    static func saveBlogData(name: String?, des: String?) {
        let Blog = BlogData(context: managedContext)
        Blog.name = name
        Blog.des = des
        CoreDataManager.shared.saveContext()
        
    }
    
    static func saveCDRecords(record:CKRecord) {
        let archiver = NSKeyedArchiver.init(requiringSecureCoding: false)
        record.encode(with: archiver)
        archiver.finishEncoding()
        let Record = CDRecords(context: managedContext)
        Record.cd_record = archiver.encodedData
        Record.writeDate = record.creationDate!
        CoreDataManager.shared.saveContext()
    }
    
}
