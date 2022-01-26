//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Snow Lukin on 26.01.2022.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
    private let context = StorageManager.shared.context
    
    private let cellID = "task"
    private var taskList: [Task] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchData()
        tableView.reloadData()
    }
 
    // MARK: Private Methods
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearence = UINavigationBarAppearance()
        navBarAppearence.configureWithOpaqueBackground()
        navBarAppearence.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearence.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        navBarAppearence.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        
        navigationController?.navigationBar.standardAppearance = navBarAppearence
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearence
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        
        navigationController?.navigationBar.tintColor = .white
        
    }
    
    @objc private func addNewTask() {
        showAlert(with: "New Task", and: "What do you want to do?")
    }
    
    private func fetchData() {
        let fetchRequest = Task.fetchRequest()
        
        do {
            taskList = try context.fetch(fetchRequest)
        } catch {
           print("Faild to fetch data", error)
        }
    }
    
    private func showAlert(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Create", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            StorageManager.shared.createTask(task)
            self.fetchData()
            let cellIndex = IndexPath(row: self.taskList.count - 1, section: 0)
            self.tableView.insertRows(at: [cellIndex], with: .automatic)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
        }
        present(alert, animated: true)
    }
}

// MARK: - Table View
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = self.editSwipeAction(rowIndexPathAt: indexPath)
        let delete = self.deleteSwipeAction(rowIndexPathAt: indexPath)
        let swipe = UISwipeActionsConfiguration(actions: [delete, edit])
        
        return swipe
    }
    
    private func deleteSwipeAction(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [self] _, _, _ in
            StorageManager.shared.deleteTask(task: self.taskList[indexPath.row])
            self.fetchData()
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        return action
    }
    
    private func editSwipeAction(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { _, _, _ in
            let alert = UIAlertController(title: "Edit task", message: "", preferredStyle: .alert)
            let saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
                StorageManager.shared.editTask(task: self.taskList[indexPath.row], task)
                self.tableView.reloadData()
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
            
            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            alert.addTextField { textField in
                textField.placeholder = self.taskList[indexPath.row].name
            }
            self.present(alert, animated: true)
        }
        
        return action
    }
}
