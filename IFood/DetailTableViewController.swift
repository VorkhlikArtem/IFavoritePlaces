//
//  DetailTableViewController.swift
//  IFood
//
//  Created by Артём on 28.12.2022.
//

import UIKit

class DetailTableViewController: UITableViewController {
    
    var isImageChanged = false
    var currentPlace: Place?
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var ratingControl: RatingControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        DispatchQueue.main.async {
//            self.newPlace.savePlaces()
//        }
        
        
        saveButton.isEnabled = false
        nameTextField.addTarget(self, action: #selector(textFieldChanged) , for: .editingChanged)
        setupEditScreen()
        tableView.tableFooterView = UIView()
    }
    
    private func setupEditScreen() {
        
        
        guard let currentPlace = currentPlace else { return }
        guard let imageData = currentPlace.imageData,
              let image = UIImage(data: imageData) else {return}
        
        setupNavigationBar()
        isImageChanged = true
        
        placeImageView.image = image
        placeImageView.contentMode = .scaleAspectFill
        nameTextField.text = currentPlace.name
        typeTextField.text = currentPlace.type
        locationTextField.text = currentPlace.location
        ratingControl.rating = Int(currentPlace.rating)

    }
    
    private func setupNavigationBar() {
        if let topItem = navigationController?.navigationBar.topItem {
            topItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        }
        navigationItem.leftBarButtonItem = nil
        title = currentPlace?.name
        saveButton.isEnabled = true
    }
    
    func savePlace() {
        let image = isImageChanged ? placeImageView.image : UIImage(named: "imagePlaceholder")
        let imageData = image?.pngData()
        
        let newPlace = Place(name: nameTextField.text!, location: locationTextField.text, type: typeTextField.text, imageData: imageData, rating: Double(ratingControl.rating))
        
        if let currentPlace = currentPlace {
            try! StorageManager.realm.write {
                currentPlace.name = newPlace.name
                currentPlace.type = newPlace.type
                currentPlace.location = newPlace.location
                currentPlace.imageData = newPlace.imageData
                currentPlace.rating = newPlace.rating
            }
        } else {
            StorageManager.saveObject(newPlace)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cameraIcon = #imageLiteral(resourceName: "camera")
        let photoIcon = #imageLiteral(resourceName: "photo")
        
        if indexPath.row == 0 {
            
            let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let camera = UIAlertAction(title: "Camera", style: .default) { _ in
                self.chooseImagePicker(source: .camera)
            }
            camera.setValue(cameraIcon, forKey: "image")
            camera.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { _ in
                self.chooseImagePicker(source: .photoLibrary)
            }
            photoLibrary.setValue(photoIcon, forKey: "image")
            photoLibrary.setValue(CATextLayerAlignmentMode.left, forKey: "titleTextAlignment")
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            
            actionSheet.addAction(camera)
            actionSheet.addAction(photoLibrary)
            actionSheet.addAction(cancel)
            present(actionSheet, animated: true, completion: nil)
            
        } else {
            view.endEditing(true)
        }
    }
    
    // MARK: - Navigation
    
    @IBAction func cancel(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier,
              let mapVC = segue.destination as? MapViewController else {return}
        mapVC.incomeSegueIdentifier = identifier
        mapVC.delegate = self
        
        if identifier == "showPlace" {
            mapVC.place.name = nameTextField.text ?? ""
            mapVC.place.location = locationTextField.text
            mapVC.place.type = typeTextField.text
            mapVC.place.imageData = placeImageView.image?.pngData()
        }
        
    }
    
}

// MARK: - UITextFieldDelegate
extension DetailTableViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: - UIImagePickerController
extension DetailTableViewController {
    func chooseImagePicker(source: UIImagePickerController.SourceType) {
        if UIImagePickerController.isSourceTypeAvailable(source) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = source
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    @objc private func textFieldChanged() {
        saveButton.isEnabled = nameTextField.text?.isEmpty == false ? true : false
    }
}

// MARK: -  UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension DetailTableViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.editedImage] as? UIImage else {return}
        placeImageView.image = image
        placeImageView.contentMode = .scaleAspectFill
        placeImageView.clipsToBounds = true
        
        isImageChanged = true
    }
}

// MARK: -  MapViewControllerDelegate
extension DetailTableViewController: MapViewControllerDelegate {
    func getAddress(_ address: String?) {
        locationTextField.text = address
    }
  
}
