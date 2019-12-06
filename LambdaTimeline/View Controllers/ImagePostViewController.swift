//
//  ImagePostViewController.swift
//  LambdaTimeline
//
//  Created by Spencer Curtis on 10/12/18.
//  Copyright © 2018 Lambda School. All rights reserved.
//

import UIKit
import Photos
import CoreImage

class ImagePostViewController: ShiftableViewController {
    
    // MARK: Properties
    var postController: PostController!
    var post: Post?
    var imageData: Data?
    
    var originalImage: UIImage?
    
    var geotag: CLLocationCoordinate2D? // TODO: actually try to get the geotag from a button or something
    
    private let context = CIContext(options: nil)
    private var vibranceFilter = CIFilter(name: "CIVibrance")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setImageViewHeight(with: 1.0)
        
        updateViews()
    }
    
    func updateViews() {
        
        guard let imageData = imageData,
            let image = UIImage(data: imageData) else {
                title = "New Post"
                return
        }
        
        title = post?.title
        
        setImageViewHeight(with: image.ratio)
        
//        imageView.image = image
        imageView.image = filterImage(image)
        chooseImageButton.setTitle("", for: [])
        
    }
    
    private func presentImagePickerController() {
        
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
            presentInformationalAlertController(title: "Error", message: "The photo library is unavailable")
            return
        }
        
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        
        imagePicker.sourceType = .photoLibrary

        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func createPost(_ sender: Any) {
        
        view.endEditing(true)
        
        guard let imageData = imageView.image?.jpegData(compressionQuality: 0.1),
            let title = titleTextField.text, title != "" else {
            presentInformationalAlertController(title: "Uh-oh", message: "Make sure that you add a photo and a caption before posting.")
            return
        }
        
        postController.createPost(with: title, ofType: .image, mediaData: imageData, ratio: imageView.image?.ratio, geotag: geotag ?? nil) { (success) in
            guard success else {
                DispatchQueue.main.async {
                    self.presentInformationalAlertController(title: "Error", message: "Unable to create post. Try again.")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func chooseImage(_ sender: Any) {
        
        let authorizationStatus = PHPhotoLibrary.authorizationStatus()
        
        switch authorizationStatus {
        case .authorized:
            presentImagePickerController()
        case .notDetermined:
            
            PHPhotoLibrary.requestAuthorization { (status) in
                
                guard status == .authorized else {
                    NSLog("User did not authorize access to the photo library")
                    self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
                    return
                }
                
                self.presentImagePickerController()
            }
            
        case .denied:
            self.presentInformationalAlertController(title: "Error", message: "In order to access the photo library, you must allow this application access to it.")
        case .restricted:
            self.presentInformationalAlertController(title: "Error", message: "Unable to access the photo library. Your device's restrictions do not allow access.")
            
        }
        presentImagePickerController()
    }
    
    func setImageViewHeight(with aspectRatio: CGFloat) {
        
        imageHeightConstraint.constant = imageView.frame.size.width * aspectRatio
        
        view.layoutSubviews()
    }
    
    // MARK: Outlets
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var chooseImageButton: UIButton!
    @IBOutlet weak var imageHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var postButton: UIBarButtonItem!
    
    @IBOutlet weak var vibranceSlider: UISlider!
    
    // MARK: Sliders
    @IBAction func vibranceChanged(_ sender: UISlider) {
        updateViews()
//        imageView.image = filterImage(originalImage)
    }
    
    
    
    private func filterImage(_ image: UIImage) -> UIImage {

        guard let cgImage = image.cgImage else { return image }

        let ciImage = CIImage(cgImage: cgImage)

        // MARK: Set the filtere values
        // You can use this for any filter you want to use
        vibranceFilter.setValue(ciImage, forKey: "inputImage")
        vibranceFilter.setValue(vibranceSlider.value, forKey: "inputAmount")


        guard let outputCIImage = vibranceFilter.outputImage else { return image }

        let bounds = CGRect(origin: CGPoint.zero, size: image.size)
        guard let outputCGImage = context.createCGImage(outputCIImage, from: bounds) else { return image }

        return UIImage(cgImage: outputCGImage)
    }
    
    private func savePhoto() {
        guard let originalImage = originalImage else {
            return //TODO: Warn the user that there is no image to save?

        }
        
        let processedImage = filterImage(originalImage)
        
        // save to photo library
        
        PHPhotoLibrary.requestAuthorization { (status) in
            guard status == .authorized else {
                return //TODO: Display to the user how to enable photos
                // Instructions: Go to settings, photos, pick app that you are refering to...
            }
            
            // Make a photo library change
            
            PHPhotoLibrary.shared().performChanges({
                
                PHAssetCreationRequest.creationRequestForAsset(from: processedImage)
                
            }) { (success, error) in
                if let error = error {
                    print("Error saving photo to library: \(error)")
                    return
                }
                
                //Display alert
                print("Saved photo successfully")
            }
        }
    }
}

extension ImagePostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        chooseImageButton.setTitle("", for: [])
        
        picker.dismiss(animated: true, completion: nil)
        
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        imageView.image = image
        
        setImageViewHeight(with: image.ratio)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
