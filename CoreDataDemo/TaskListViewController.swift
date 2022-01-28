//
//  ViewController.swift
//  CoreDataDemo
//
//  Created by Snow Lukin on 26.01.2022.
//

import UIKit
import CoreData

class TaskListViewController: UITableViewController {
    
    private var taskList: [Task] = []
    private let cellID = "task"

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }
    
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
        showAlert()
    }
}

// MARK: - Data
extension TaskListViewController {
    private func fetchData() {
        StorageManager.shared.fetchData { result in
            switch result {
            case .success(let tasks):
                self.taskList = tasks
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func create(taskName: String) {
        StorageManager.shared.createTask(taskName) { task in
            self.taskList.append(task)
            self.tableView.insertRows(
                at: [IndexPath(row: self.taskList.count - 1, section: 0)],
                with: .automatic
            )
        }
    }
}

// MARK: - AlertController
extension TaskListViewController {
    private func showAlert(task: Task? = nil, completion: (() -> Void)? = nil) {
        
        let title = task != nil ? "Edit Task" : "New Task"
        let alert = UIAlertController.createAlertController(withTitle: title)
        
        alert.action(task: task) { taskName in
            if let task = task, let completion = completion {
                StorageManager.shared.editTask(task: task, taskName)
                completion()
            } else {
                self.create(taskName: taskName)
            }
        }
        
        present(alert, animated: true)
    }
}

// MARK: - Swipe Actions
extension TaskListViewController {
    private func deleteSwipeAction(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .destructive, title: "Delete") { [self] _, _, _ in
            StorageManager.shared.deleteTask(task: self.taskList[indexPath.row])
            taskList.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .fade)
        }
        
        return action
    }
    
    private func editSwipeAction(rowIndexPathAt indexPath: IndexPath) -> UIContextualAction {
        let action = UIContextualAction(style: .normal, title: "Edit") { _, _, _ in
            self.showAlert(task: self.taskList[indexPath.row]) {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
        
        return action
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
        cell.backgroundColor = .clear
        var content = cell.defaultContentConfiguration()
        content.text = task.name
        content.textProperties.color = .black
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let edit = self.editSwipeAction(rowIndexPathAt: indexPath)
        let delete = self.deleteSwipeAction(rowIndexPathAt: indexPath)
        let swipe = UISwipeActionsConfiguration(actions: [delete, edit])
        
        return swipe
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
