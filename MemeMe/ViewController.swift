//
//  ViewController.swift
//  MemeMe
//
//  Created by Mochammad Alamsyah on 03/03/18.
//  Copyright © 2018 malamsyah.id. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var shareBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var cameraBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var albumBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var toolbar: UIToolbar!
    
    
    var keyboardIsHidden = true
    
    var meme:Meme!
    var memedImage = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let textStyles = [
            NSAttributedStringKey.strokeColor.rawValue : UIColor.black,
            NSAttributedStringKey.foregroundColor.rawValue : UIColor.white,
            NSAttributedStringKey.font.rawValue : UIFont(name: "impact", size: 40)!,
            NSAttributedStringKey.strokeWidth.rawValue : -3,
            ] as [String : Any]
       
        topTextField.defaultTextAttributes = textStyles
        topTextField.textAlignment = .center
        topTextField.text! = "TOP"
        topTextField.delegate = self
        
        bottomTextField.defaultTextAttributes = textStyles
        bottomTextField.textAlignment = .center
        bottomTextField.text! = "BOTTOM"
        bottomTextField.delegate = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraBarButtonItem.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        if(memeImageView.image == nil){
            self.shareBarButtonItem.isEnabled = false
        }else{
            self.shareBarButtonItem.isEnabled = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func shareAction(_ sender: Any) {
        share()
    }
    
    @IBAction func cancelButtonAction(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func getImageFromCamera(_: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        if (UIImagePickerController.isSourceTypeAvailable(.camera)){
            imagePicker.sourceType = .camera
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func getImageFromAlbum(_: AnyObject) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        self.present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.memeImageView.image = image
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM"{
            textField.text = ""
        }
        
        if textField.isEqual(bottomTextField) {
            self.subscribeToKeyboardNotifications()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.isEqual(bottomTextField){
            self.unsubscribeFromKeyboardNotifications()
        }
        return true
    }
    
    @objc func keyboardWillShow(_ notification:Notification) {
        self.view.frame.origin.y = 0 - getKeyboardHeight(notification)
        keyboardIsHidden = false
    }
    
    
    
    @objc func keyboardWillHide(_ notification: NSNotification) {
        if(!keyboardIsHidden){
            self.view.frame.origin.y = 0
            keyboardIsHidden = true
        }
    }
    
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    func hide(flag:Bool,animated:Bool){
        toolbar.isHidden = flag
    }
    
    
    func generateMemedImage() -> UIImage {
        hide(flag: true, animated: false)
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        hide(flag: false, animated: true)
        return memedImage
    }
    
    func save() {
        memedImage = generateMemedImage()
        let meme = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: memeImageView.image!, memedImage: memedImage)
        self.meme = meme
    }
    
    func share() {
        save()
        let activity = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        
        activity.completionWithItemsHandler = { (activity, success, items, error) in
            let applicationDelegate = (UIApplication.shared.delegate as! AppDelegate)
            applicationDelegate.meme = self.meme
            self.meme = Meme(topText: "TOP", bottomText: "BOTTOM", originalImage: UIImage(), memedImage: UIImage())
        }
        self.present(activity, animated: true, completion:nil)
    }
}

