//
//  ListViewController.swift
//  MapApp
//
//  Created by Berkan Gezgin on 9.11.2021.
//

import UIKit
import CoreData

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
        // Dizi tanımları
    var nameArray = [String]()
    var idArray = [UUID]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonClicked))
        
        giveData()
    }
    
    func giveData() {
            // DB bağlantısı
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
            // DB isteği
        let request = NSFetchRequest<NSFetchRequestResult> (entityName: "Place")
        request.returnsObjectsAsFaults = false
        
        do {
            // Any dizisi veriyor. Biz onu NSManagedObject dizisi haline getirmeye çalışıyoruz.
            let results = try context.fetch(request)
            if results.count > 0 {
                    // ForLoop girmeden diziyi boşaltıyoruz
                nameArray.removeAll(keepingCapacity: false)
                idArray.removeAll(keepingCapacity: false)
                
                    // Dizilerde dönerek bilgileri çekme ve tnaımlı dizileri doldurma
                for result in results as! [NSManagedObject] {
                    if let name = result.value(forKey: "placeName") as? String {
                        nameArray.append(name)
                    }
                    if let id = result.value(forKey: "id") as? UUID {
                        idArray.append(id)
                    }
                }
                tableView.reloadData()
            }
        } catch {
            print("false")
        }
    }
    
 
    @objc func addButtonClicked() {
        performSegue(withIdentifier: "toMapsVC", sender: nil)
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return idArray.count
    }

    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = nameArray[indexPath.row]
        return cell
    }
}
