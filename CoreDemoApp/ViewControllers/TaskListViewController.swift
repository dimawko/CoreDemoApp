//
//  TaskListViewController.swift
//  CoreDemoApp
//
//  Created by Alexey Efimov on 18.04.2022.
//

import UIKit

class TaskListViewController: UITableViewController {

    // MARK: - Private properties
    private let cellID = "task"
    private let viewContext = CoreDataManager.shared.viewContext
    private var taskList: [Task] = []
    private var saveAction: UIAlertAction!

    // MARK: - viewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }

    // MARK: - NavBar and Alert Controller
    private func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(
            red: 21/255,
            green: 101/255,
            blue: 192/255,
            alpha: 194/255
        )
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewTask)
        )
        navigationController?.navigationBar.tintColor = .white
    }

    @objc private func addNewTask() {
        showAlert(with: "New task", and: "What do you want to do?") { newTask in
            self.saveTask(newTask)
        }
    }

    private func showAlert(
        with title: String,
        and message: String,
        textFieldText: String? = nil,
        closure: @escaping(_ newTask: String) -> Void) {

            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
            saveAction = UIAlertAction(title: "Save", style: .default) { _ in
                guard let task = alert.textFields?.first?.text else { return }
                closure(task)
            }

            saveAction.isEnabled = false

            alert.addAction(saveAction)
            alert.addAction(cancelAction)
            alert.addTextField { textField in
                textField.placeholder = "New Task"
                textField.text = textFieldText
                textField.addTarget(
                    self,
                    action: #selector(self.textFieldDidChange),
                    for: .allEditingEvents
                )
            }
            present(alert, animated: true)
        }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        saveAction.isEnabled = textField.text?.count ?? 0 > 0
    }

    // MARK: Fetching and saving data
    private func fetchData() {
        taskList = CoreDataManager.shared.fetchData()
    }

    private func saveTask(_ taskName: String) {
        let task = CoreDataManager.shared.saveTask(taskName)
        taskList.append(task)
        let cellIndex = IndexPath(row: taskList.count - 1, section: 0)
        tableView.insertRows(at: [cellIndex], with: .automatic)
    }
}

// MARK: - TableView methods
extension TaskListViewController {

    override func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        taskList.count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {

        let task = taskList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        var content = cell.defaultContentConfiguration()

        content.text = task.title
        cell.contentConfiguration = content

        return cell
    }

    // MARK: - Deleting task
    override func tableView(
        _ tableView: UITableView,
        trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {

        let task = taskList[indexPath.row]

        let deleteAction = UIContextualAction(
            style: .destructive,
            title: "Delete"
        ) { _, _, completion in
            CoreDataManager.shared.deleteTask(currentTask: task)
            self.taskList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

    // MARK: - Editing task
    override func tableView(
        _ tableView: UITableView,
        leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath
    ) -> UISwipeActionsConfiguration? {
        let editAction = UIContextualAction(
            style: .normal,
            title: "Edit"
        ) { _, _, completion in
            self.editTableView(indexPath: indexPath)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [editAction])
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        editTableView(indexPath: indexPath)
    }

    private func editTableView(indexPath: IndexPath) {
        let task = taskList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID)

        showAlert(
            with: "Edit task",
            and: "What do you want to do?",
            textFieldText: task.title) { newTask in
                CoreDataManager.shared.editTask(currentTask: task, newTask)
                cell?.textLabel?.text = newTask
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
    }
}
