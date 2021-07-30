//
//  DetailsVC.swift
//  CertificateBook
//
//  Created by Sarp Ünsal on 14.07.2021.
//

import UIKit
import CoreData

class DetailsVC: UIViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate{

    @IBOutlet weak var CertificateImageView: UIImageView!
    @IBOutlet weak var updateButton: UIButton!
    
    @IBOutlet weak var CertificateNameText: UITextField!
    @IBOutlet weak var CertificateProviderText: UITextField!
    @IBOutlet weak var CertificateIDText: UITextField!
    @IBOutlet weak var GivingDateText: UITextField!
    @IBOutlet weak var ProtectedSwitch: UISwitch!
    
    @IBOutlet weak var saveButton: UIButton!
    
    var selectedID: UUID?
    var selectedTitle = ""
    var certificateLoaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        appearanceControl()
        print("View Loading")
        if selectedTitle != ""{
            saveButton.isHidden = true
            updateButton.isHidden = false
            certificateLoaded = true
            let delegate = UIApplication.shared.delegate as! AppDelegate
            let context = delegate.persistentContainer.viewContext
            print("context ok")
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Certificates")
            request.returnsObjectsAsFaults = false
            let strid = selectedID!.uuidString
            request.predicate = NSPredicate(format: "uuid = %@",strid)
            print("parameters ok")
            do {
                let results = try context.fetch(request)
                if results.count > 0 {
                    print("counting")
                    for result in results as! [NSManagedObject] {
                        if let getitle = result.value(forKey: "name") as? String {
                            CertificateNameText.text = getitle
                        }
                        if let geprovider = result.value(forKey: "provider") as? String {
                            CertificateProviderText.text = geprovider
                        }
                        if let gecid = result.value(forKey: "cid") as? String {
                            CertificateIDText.text = gecid
                        }
                        if let imgdata = result.value(forKey: "image") as? Data {
                            let img = UIImage(data: imgdata)
                            CertificateImageView.image = img
                        }
                        if let protectstate = result.value(forKey: "protected") as? Bool {
                            ProtectedSwitch.setOn(protectstate, animated: true)
                        }
                        if let givingdate = result.value(forKey: "date") as? String {
                            GivingDateText.text = givingdate
                        }
                    }
                }
            } catch {
                print("error")
            }
        } else {
            saveButton.isHidden = false
            saveButton.isEnabled = false
            updateButton.isHidden = true
            CertificateProviderText.text = ""
            CertificateNameText.text = ""
            CertificateIDText.text = ""
            GivingDateText.text = ""
            ProtectedSwitch.setOn(false, animated: true)
        }
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecognizer)
        CertificateImageView.isUserInteractionEnabled = true
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        CertificateImageView.addGestureRecognizer(imageTapRecognizer)
        // Do any additional setup after loading the view.
    }
    func appearanceControl(){
        let style = traitCollection.userInterfaceStyle
        if style == .dark {
            if certificateLoaded == false {
                CertificateImageView.image = UIImage(named: "270pBelgeForDark")
            }
            saveButton.tintColor = UIColor.white
        }
        else {
            if certificateLoaded == false {
                CertificateImageView.image = UIImage(named: "270pBelge")
            }
            saveButton.tintColor = UIColor.blue
        }
    }
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        appearanceControl()
    }
    @objc func selectImage() {
         
         let picker = UIImagePickerController()
         picker.delegate = self
         picker.sourceType = .photoLibrary
         picker.allowsEditing = true
         present(picker, animated: true, completion: nil)
         
     }
     
     func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
         CertificateImageView.image = info[.editedImage] as? UIImage
         saveButton.isEnabled = true
         self.dismiss(animated: true, completion: nil)
         certificateLoaded = true
     }
    @objc func hideKeyboard() {
        view.endEditing(true)
    }
    @IBAction func saveButtonClicked(_ sender: Any) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let newCertificate = NSEntityDescription.insertNewObject(forEntityName: "Certificates", into: context)
        
        newCertificate.setValue(CertificateNameText.text, forKey: "name")
        newCertificate.setValue(CertificateProviderText.text, forKey: "provider")
        newCertificate.setValue(CertificateIDText.text, forKey: "cid")
        newCertificate.setValue(UUID(), forKey: "uuid")
        newCertificate.setValue(ProtectedSwitch.isOn, forKey: "protected")
        newCertificate.setValue(GivingDateText.text, forKey: "date")
        let imdata = CertificateImageView.image!.jpegData(compressionQuality: 0.5)
        newCertificate.setValue(imdata, forKey: "image")
        do {
            try context.save()
            print("saved successfully")
        }catch{
            print("An error occured.")
        }
        NotificationCenter.default.post(name: NSNotification.Name("newCertificate"), object: nil)
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func updateButtonClicked(_ sender: Any) {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "Certificates")
        request.returnsObjectsAsFaults = false
        let strid = selectedID!.uuidString
        request.predicate = NSPredicate(format: "uuid = %@",strid)
        do {
            let results = try context.fetch(request)
            if results.count > 0 {
                for result in results as! [NSManagedObject] {
                    result.setValue(CertificateNameText.text, forKey: "name")
                    result.setValue(CertificateProviderText.text, forKey: "provider")
                    result.setValue(CertificateIDText.text, forKey: "cid")
                    result.setValue(selectedID, forKey: "uuid")
                    result.setValue(ProtectedSwitch.isOn, forKey: "protected")
                    result.setValue(GivingDateText.text, forKey: "date")
                    let imgdataa = CertificateImageView.image!.jpegData(compressionQuality: 0.5)
                    result.setValue(imgdataa, forKey: "image")
                    do {
                        try context.save()
                         print("saved successfully")
                    }catch{
                        print("An error occured.")
                    }
                    NotificationCenter.default.post(name: NSNotification.Name("newCertificate"), object: nil)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
        } catch {
            print("Errored")
        }
        
    }
    
}
