//
//  ViewController.swift
//  DailyTodo
//
//  Created by chamlingdibyarai on 05/07/21.
//

import UIKit
import CoreData
import MobileCoreServices

class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate{
    
    @IBOutlet weak var addNewItemButton: UIButton!
    @IBOutlet weak var listDeleteButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    
    var managedObjectContext : NSManagedObjectContext!
    
    var listArray = [List]()
    
    var numberOfSelectedRows = 0
    
    var okAction = UIAlertAction()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Fetch Data From CoreData
        
        
        // Register Nib
        let nib = UINib(nibName: "ListCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "ListCell")
        
        //Set left Navigation BarButtonItem
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.leftBarButtonItem?.isEnabled = false
        navigationItem.leftBarButtonItem?.tintColor = .white
        listDeleteButton.isEnabled = false
        
        fetchData()
        
        //UITableViewCell separator full width
        tableView.separatorInset = .zero
        tableView.layoutMargins = .zero
        
        //Add Button Layout
        addNewItemButton.translatesAutoresizingMaskIntoConstraints = false
        let horizontalConstraint = addNewItemButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        let verticalConstraint = addNewItemButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: view.frame.size.height / 3 )
        let widthConstraint = addNewItemButton.widthAnchor.constraint(equalToConstant: 70)
        let heightConstraint = addNewItemButton.heightAnchor.constraint(equalToConstant: 70)
        NSLayoutConstraint.activate([horizontalConstraint, verticalConstraint, widthConstraint, heightConstraint])
        addNewItemButton.layer.cornerRadius = 35
        
        //UITableView Footer View
        tableView.tableFooterView = UIView()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: true)
        if !editing{
            listDeleteButton.isEnabled = false
        }
    }
    
    //MARK: - UITableViewDatasource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell" , for: indexPath) as! ListCellTableViewCell
        let list = listArray[ indexPath.row ]
        cell.configure(list: list)
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        numberOfSelectedRows += 1
        listDeleteButton.isEnabled = true
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        numberOfSelectedRows -= 1
        if numberOfSelectedRows <= 0{
            listDeleteButton.isEnabled = false
        }
    }
    
    //MARK: - Delete Button Action
    @IBAction func deleteLists(_ sender: UIBarButtonItem) {
        let indexPathForSelectedRows = tableView.indexPathsForSelectedRows
        tableView.beginUpdates()
        tableView.deleteRows(at: indexPathForSelectedRows!, with: .automatic)
        for indexPath in indexPathForSelectedRows!  {
            managedObjectContext.delete(listArray[ indexPath.row ])
            do {
                try managedObjectContext.save()
                numberOfSelectedRows = 0
            } catch {
                print( "Error Deleting Data", error.localizedDescription )
            }
            listArray.remove(at: indexPath.row)
            if listArray.count <= 0{
                navigationItem.leftBarButtonItem?.isEnabled = false
            }
        }
        tableView.endUpdates()
        setEditing(false, animated: true)
        listDeleteButton.isEnabled = false
    }
    
    //MARK: - Fetch Data From CoreData
    func fetchData(){
        let fetchRequest : NSFetchRequest<List> = List.fetchRequest()
        do{
            listArray = try managedObjectContext.fetch(fetchRequest)
            if listArray.count > 0{
                navigationItem.leftBarButtonItem?.isEnabled = true
            }
            tableView.reloadData()
        }catch{
            print( "Error Fetching data", error.localizedDescription)
        }
    }
    
    func toggleEditButton(){
        if listArray.count > 0{
            navigationItem.leftBarButtonItem?.isEnabled = true
        }
    }
    
    @IBAction func addNewListItem(_ sender: UIButton) {
        setEditing(false, animated: true)
        let alert = UIAlertController(title: "Enter New Item", message: "", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.delegate = self
            textField.addTarget(self, action: #selector(self.textdidChange), for: .editingChanged)
        }
        okAction = UIAlertAction(title: "Add", style: .default) { [self] _ in
            let textFiled = alert.textFields?.first
            let newList = List(context: managedObjectContext)
            newList.title = textFiled?.text
            newList.startDate = Date()
            do{
                try managedObjectContext.save()
                listArray.append(newList)
                if listArray.count >= 0{
                    navigationItem.leftBarButtonItem?.isEnabled = true
                }
                let indexPath = IndexPath(row: self.listArray.count - 1, section: 0)
                tableView.beginUpdates()
                tableView.insertRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }catch{
                print( "Error Saving Data", error.localizedDescription )
            }
        }
        okAction.isEnabled = false
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - UITextFieldDelegate
    @objc func textdidChange(textField : UITextField){
        if !textField.text!.isEmpty{
            okAction.isEnabled = true
        }else{
            okAction.isEnabled = false
        }
    }
    
    //MARK: - UITableViewCell Swipe Left Action
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: "Delete") { [self] (action, view, completion) in
            managedObjectContext.delete(listArray[ indexPath.row ])
            do{
                try managedObjectContext.save()
            }catch{
                print( "Error Deleting Item", error.localizedDescription )
            }
            listArray.remove(at: indexPath.row)
            if listArray.count <= 0{
                navigationItem.leftBarButtonItem?.isEnabled = false
            }
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            completion(true)
        }
        deleteAction.image = UIImage(systemName: "trash.fill")
        deleteAction.backgroundColor = UIColor.red
        let editAction = UIContextualAction(style: .normal, title: "Edit") { [self] action, view, completion in
            let alertView = UIAlertController(title: "Edit Item", message: " ", preferredStyle: .alert)
            alertView.addTextField { textField in
                textField.text = listArray[indexPath.row].title
                textField.delegate = self
                textField.addTarget(self, action: #selector(self.textdidChange), for: .editingChanged)
            }
            okAction = UIAlertAction(title: "Done", style: .default) { [self] _ in
                let textFiled = alertView.textFields?.first
                let newList = listArray[indexPath.row]
                newList.title = textFiled?.text
                do{
                    try managedObjectContext.save()
                    tableView.beginUpdates()
                    tableView.reloadRows(at: [indexPath], with: .automatic)
                    tableView.endUpdates()
                }catch{
                    print( "Error Saving Item", error.localizedDescription )
                }
            }
            okAction.isEnabled = false
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertView.addAction(okAction)
            alertView.addAction(cancelAction)
            present(alertView, animated: true, completion: nil)
            completion(true)
        }
        editAction.image = UIImage(systemName: "pencil")
        editAction.backgroundColor = #colorLiteral(red: 0.1764705926, green: 0.4980392158, blue: 0.7568627596, alpha: 1)
        let configuration = UISwipeActionsConfiguration(actions: [editAction, deleteAction])
        configuration.performsFirstActionWithFullSwipe = false
        return configuration
    }
    
}

