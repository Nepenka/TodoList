//
//  SecondViewController.swift
//  ToDoList
//
//  Created by 123 on 1.05.23.
//

import SnapKit
import UIKit
import CoreData


class SecondViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    let namedLabel: UILabel = .init()
    let tableView: UITableView = .init()
    let buttonAction: UIButton = .init()
    private var values: [Tasks] = []
    private var taskCompleted: [Bool] = []
    var selectedDates: [IndexPath: Date] = [:] {
        didSet {
            saveSelectedDates()
        }
    }
    
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let fetchRequset: NSFetchRequest<Tasks> = Tasks.fetchRequest()
        
        do {
            values = try context.fetch(fetchRequset)
            taskCompleted = values.map { _ in false }
        } catch let error as NSError {
            print(error.localizedDescription)
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        self.tableView.register(TableViewCell.self, forCellReuseIdentifier: "TableViewCell")
        taskCompleted = Array(repeating: false, count: values.count)
        loadSelectedDates()
        setupSettings()
       // namedLabel.text = "DailyDo"
        title = "DailyDo"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        
    }
    
    //MARK: - tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch tableView {
        case self.tableView:
            return self.values.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableViewCell", for: indexPath) as! TableViewCell
        let text = values[indexPath.row]
        cell.textLabel?.text = text.title
        let isCompleted = taskCompleted[indexPath.row]
        cell.configureCell(isCompleted: isCompleted)
        cell.textLabel?.textColor = isCompleted ? .gray : .systemGreen
        cell.backgroundColor = UIColor(red: 241/255, green: 238/255, blue: 228/255, alpha: 1)
        
        
        if let selectedDate = selectedDates[indexPath] {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd.MM.yyyy"
                let dateString = dateFormatter.string(from: selectedDate)
                cell.dateLabel.text = dateString
            } else {
                cell.dateLabel.text = nil
            }
       
        return cell
    }



    
    //MARK: - Удаление ячейки
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if indexPath.row < taskCompleted.count {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let task = values[indexPath.row]
            context.delete(task) //удаление записи из CoreData
            
            do{
              try context.save()
            }catch let error as NSError{
                print("Failed to delete task", error.localizedDescription)
            }
            
            values.remove(at: indexPath.row)
            taskCompleted.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .left) //это удаление ячейки из таблицы
        }else{
            print("Index out of range: \(indexPath.row)")
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row < taskCompleted.count {
            let selectedTask = values[indexPath.row]
            let selectedCompleted = taskCompleted[indexPath.row]
            
            if !selectedCompleted {
                values.remove(at: indexPath.row)
                taskCompleted.remove(at: indexPath.row)
                
                values.insert(selectedTask, at: 0)
                taskCompleted.insert(true, at: 0)
                
                let firstIndexPath = IndexPath(row: 0, section: indexPath.section)
                
                tableView.moveRow(at: indexPath, to: firstIndexPath)
                tableView.reloadRows(at: [firstIndexPath], with: .automatic)
                
                if let cell = tableView.cellForRow(at: firstIndexPath) as? TableViewCell {
                    cell.textLabel?.textColor = .gray
                }
                
                let datePicker = UIDatePicker()
                // Обновите значение выбранной даты для соответствующего IndexPath
                selectedDates.removeValue(forKey: indexPath)
                selectedDates[firstIndexPath] = datePicker.date
            }
        }
    }

private func setupSettings() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
     
        
        view.addSubview(namedLabel)
        namedLabel.font = UIFont.systemFont(ofSize: 25, weight: .bold)
        namedLabel.textColor = .black
        namedLabel.numberOfLines = 0
        namedLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(50)
            make.right.equalToSuperview().inset(150)
        }
        tableView.contentInset = UIEdgeInsets(top: 100, left: 0, bottom: 0, right: 0)
        tableView.backgroundColor = UIColor(red: 241/255, green: 238/255, blue: 228/255, alpha: 1)
        
        view.addSubview(buttonAction)
        buttonAction.backgroundColor = .systemGreen
        buttonAction.setBackgroundImage(UIImage(named: "plus"), for: .normal)
        buttonAction.layer.cornerRadius = 20
        buttonAction.layer.masksToBounds = true
        buttonAction.addTarget(self, action: #selector(buttonClick), for: .touchUpInside)
        buttonAction.snp.makeConstraints { make in
            make.height.equalTo(namedLabel.snp.height)
            make.left.equalToSuperview().inset(300)
            make.bottom.equalToSuperview().inset(150)
        }
        
    }
    @objc func buttonClick() {
        UIView.animate(withDuration: 0.1, animations: {
            self.buttonAction.backgroundColor = .clear
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                self.buttonAction.backgroundColor = .systemGreen
            }
            let alertController = UIAlertController(title: "Добавьте план на день!", message: nil, preferredStyle: .alert)

            alertController.addTextField { textField in
                textField.placeholder = "Вы уверены что сможете?"
            }

            let cancelAction = UIAlertAction(title: "Отмена", style: .default)
            alertController.addAction(cancelAction)

            let datePicker = UIDatePicker()
            let currentDate = Date()
            datePicker.calendar = .current
            datePicker.datePickerMode = .date
            datePicker.minimumDate = currentDate
            alertController.view.addSubview(datePicker)
            datePicker.translatesAutoresizingMaskIntoConstraints = false
            datePicker.layer.borderColor = UIColor.systemBlue.cgColor

            datePicker.snp.makeConstraints { make in
                make.height.equalToSuperview().inset(90)
                make.right.left.equalToSuperview().inset(80)
                make.top.equalToSuperview().inset(110)
            }
            let indexPath = self.tableView.indexPathForSelectedRow
            let saveAction = UIAlertAction(title: "Сохранить", style: .default) { _ in
                if let textField = alertController.textFields?.first,
                    let text = textField.text,
                    !text.isEmpty {
                    textField.textColor = .green
                    
                    self.saveTask(withTitle: text, datePicker: datePicker)
                    self.tableView.reloadData()
                    self.taskCompleted.append(false)
                    let selectedDate = datePicker.date
                    let firstIndexPath = IndexPath(row: self.values.count - 1, section: 0)
                    self.selectedDates[firstIndexPath] = selectedDate
                    self.saveSelectedDates()
                    self.tableView.reloadData()
                }
            }
            alertController.addAction(saveAction)

            self.present(alertController, animated: true)
        }
    }

    //MARK: - напишем метод которые будет нам позволять запиывать данные в coreData
    func saveTask(withTitle title: String, datePicker: UIDatePicker) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        guard let entity = NSEntityDescription.entity(forEntityName: "Tasks", in: context) else { return }
        
        let taskObject = Tasks(entity: entity, insertInto: context)
        taskObject.title = title
        
        
        do {
            try context.save()
            values.append(taskObject)
            
            let selectedDate = datePicker.date
            let firstIndexPath = IndexPath(row: self.values.count - 1, section: 0)
            self.selectedDates[firstIndexPath] = selectedDate
            self.saveSelectedDates() // Сохранить даты
            self.tableView.reloadData()
        } catch let error as NSError {
            print(error.localizedDescription)
        }
}
    
    private func saveSelectedDates() {
        let userDefaults = UserDefaults.standard
        let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: selectedDates, requiringSecureCoding: false)
        userDefaults.set(encodedData, forKey: "SelectedDatesKey")
        userDefaults.synchronize()
    }
    private func loadSelectedDates() {
        let userDefaults = UserDefaults.standard
        if let encodedData = userDefaults.object(forKey: "SelectedDatesKey"){
            if let decodeData = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(encodedData as! Data) as? [IndexPath: Date] {
                selectedDates = decodeData
            }
            
        }
        
    }
}


//MARK: - Для добавления checkMarkov ячейке и квадрата
class TableViewCell: UITableViewCell {
    var checkmarkImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "square")
        return imageView
    }()
    
    var dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .right
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        textLabel?.textAlignment = .center
        
        addSubview(checkmarkImageView)
        checkmarkImageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(8)
            make.leading.equalToSuperview().offset(15)
            make.width.equalTo(30)
            make.height.equalTo(30)
        }
        
        addSubview(dateLabel)
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(15)
            make.centerY.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureCell(isCompleted: Bool) {
        if isCompleted {
            checkmarkImageView.image = UIImage(named: "checkmark.fill")
        } else {
            checkmarkImageView.image = UIImage(named: "square")
        }
    }
}

    
    struct Task<T, E> {
        var isCompleted: Bool
        
        init(isCompleted: Bool) {
            self.isCompleted = isCompleted
            
        }
}
