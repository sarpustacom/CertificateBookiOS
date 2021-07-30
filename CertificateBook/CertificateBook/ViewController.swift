//
//  ViewController.swift
//  CertificateBook
//
//  Created by Sarp Ünsal on 14.07.2021.
//

import UIKit
import CoreData
import LocalAuthentication

class ViewController: UIViewController,UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var TableView: UITableView!
    var chosenCertificateName = ""
    var certificateNameArray = [String]()
    var certificateIdentifierArray=[String]()
    var certificateUUIDArray = [UUID]()
    var certificateProtectedArray = [Bool]()
    var certificateProviderArray = [String]()
    var chosenCertificateUUID: UUID?
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        TableView.delegate = self
        TableView.dataSource = self
        
        navigationController?.navigationBar.topItem?.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(addCertificate))
        
        getData()
    }
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(getData), name: NSNotification.Name("newCertificate"), object: nil)
    }
    
    @objc func addCertificate(){
        chosenCertificateName = ""
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if certificateProtectedArray[indexPath.row] == true {
            let laContext = LAContext()
            var error: NSError?
            if laContext.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                laContext.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: "Access to Certificate") { success, err in
                    if success == true {
                        DispatchQueue.main.async {
                            self.chosenCertificateUUID = self.certificateUUIDArray[indexPath.row]
                            self.chosenCertificateName = self.certificateNameArray[indexPath.row]
                            print("Chosen")
                            self.performSegue(withIdentifier: "toDetailsVC", sender: nil)
                        }
                    }
                    else {
                        DispatchQueue.main.async {
                            self.alert(title: "Error", msg: "You haven't got permission to access this certificate", btn: "Cancel", btnstyle: UIAlertAction.Style.destructive)
                        }
                    }
                }
            }
        } else {
            chosenCertificateUUID = certificateUUIDArray[indexPath.row]
            chosenCertificateName = certificateNameArray[indexPath.row]
            print("Chosen")
            performSegue(withIdentifier: "toDetailsVC", sender: nil)
        }
    }
    func alert(title: String, msg: String, btn: String, btnstyle: UIAlertAction.Style){
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertController.Style.alert)
        let actbutton = UIAlertAction(title: btn, style: btnstyle, handler: nil)
        alert.addAction(actbutton)
        self.present(alert, animated: true, completion: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDetailsVC" {
            let destination = segue.destination as! DetailsVC
            destination.selectedTitle = chosenCertificateName
            destination.selectedID = chosenCertificateUUID
            print("PASS")
        }
    }
    
    @objc func getData(){
        certificateNameArray.removeAll(keepingCapacity: false)
        certificateIdentifierArray.removeAll(keepingCapacity: false)
        certificateUUIDArray.removeAll(keepingCapacity: false)
        certificateProtectedArray.removeAll(keepingCapacity: false)
        certificateProviderArray.removeAll(keepingCapacity: false)
        
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Certificates")
        request.returnsObjectsAsFaults = false
        do {
            let results = try context.fetch(request)
            
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    if let title = result.value(forKey: "name") as? String {
                        self.certificateNameArray.append(title)
                        if let cerid = result.value(forKey: "cid") as? String {
                            self.certificateIdentifierArray.append(cerid)
                            if let protectstate = result.value(forKey: "protected") as? Bool {
                                self.certificateProtectedArray.append(protectstate)
                                if let uuid = result.value(forKey: "uuid") as? UUID {
                                    self.certificateUUIDArray.append(uuid)
                                    if let provider = result.value(forKey: "provider") as? String {
                                        self.certificateProviderArray.append(provider)
                                    }
                                }
                            }
                           
                        }
                    }
                }
                self.TableView.reloadData()
            }
        } catch {
            print("An Error Occured")
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return certificateUUIDArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CustomizedCell", for: indexPath) as! CertificateCell
        cell.certificateNameText.text = certificateNameArray[indexPath.row]
        cell.certificateFromText.text = "from \(certificateProviderArray[indexPath.row])"
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            let idString = certificateUUIDArray[indexPath.row].uuidString
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Certificates")
            request.predicate = NSPredicate(format: "uuid = %@",idString)
            request.returnsObjectsAsFaults = false
            print("Context Created")
            do {
                let results = try context.fetch(request)
                
                if results.count > 0 {
                    print("List Pulled")
                    for result in results as! [NSManagedObject] {
                        if let id = result.value(forKey: "uuid") as? UUID {
                            if id == certificateUUIDArray[indexPath.row] {
                                print("OK Delete")
                                context.delete(result)
                                certificateNameArray.remove(at: indexPath.row)
                                certificateIdentifierArray.remove(at: indexPath.row)
                                certificateUUIDArray.remove(at: indexPath.row)
                                certificateProtectedArray.remove(at: indexPath.row)
                                certificateProviderArray.remove(at: indexPath.row)
                                TableView.reloadData()
                                do {
                                    try context.save()
                                    print("Saved")
                                    getData()
                                } catch {
                                    print("An Error Occured")
                                }
                                break
                            }
                        }
                    }
                }
            } catch {
                print("An Error Occured")
            }
        }
    }


}

