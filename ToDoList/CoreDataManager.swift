//
//  CoreDataManager.swift
//  ToDoList
//
//  Created by 123 on 19.05.23.
//

import Foundation
import CoreData

class CoreDataManager {
    static let shared = CoreDataManager()
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TodoModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                print("Ошибка при инициализации CoreData: \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    var managedContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    private init() {}
    
    func createTodoItem(withTitle title: String, isCompleted: Bool) {
        let context = managedContext
        let entity = NSEntityDescription.entity(forEntityName: "TodoItem", in: context)!
        let todoItem = NSManagedObject(entity: entity, insertInto: context) as! TodoItem
        
        todoItem.title = title
        todoItem.isCompleted = isCompleted
        
        do {
            try context.save()
            print("TodoItem сохранен в CoreData.")
        } catch let error as NSError {
            print("Не удалось сохранить TodoItem: \(error), \(error.userInfo)")
        }
    }
    
    func fetchTodoItems() -> [TodoItem] {
        let context = managedContext
        let fetchRequest: NSFetchRequest<TodoItem> = TodoItem.fetchRequest()
        
        do {
            let todoItems = try context.fetch(fetchRequest)
            return todoItems
        } catch let error as NSError {
            print("Не удалось извлечь TodoItems из CoreData: \(error), \(error.userInfo)")
            return []
        }
    }
    
    func updateTodoItem(todoItem: TodoItem, withTitle title: String, isCompleted: Bool) {
        let context = managedContext
        
        todoItem.title = title
        todoItem.isCompleted = isCompleted
        
        do {
            try context.save()
            print("TodoItem обновлен в CoreData.")
        } catch let error as NSError {
            print("Не удалось обновить TodoItem: \(error), \(error.userInfo)")
        }
    }
    
    func deleteTodoItem(todoItem: TodoItem) {
        let context = managedContext
        
        context.delete(todoItem)
        
        do {
            try context.save()
            print("TodoItem удален из CoreData.")
        } catch let error as NSError {
            print("Не удалось удалить TodoItem: \(error), \(error.userInfo)")
        }
    }
}
