//
//  ViewController.swift
//  LimPickerExample
//
//  Created by MyAdmin on 3/5/15.
//  Copyright (c) 2015 MyAdmin. All rights reserved.
//

import UIKit
import MediaPlayer
import MobileCoreServices
import AVFoundation


class ViewController: UIViewController ,UIImagePickerControllerDelegate, UINavigationControllerDelegate,  UIActionSheetDelegate,   LimCameraImagePickerDelegate {

    
    var limPicker:LimCameraImagePicker?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func OpenCamera(sender: AnyObject) {
        var actionSheet:UIActionSheet
        if(UIImagePickerController .isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)){
            actionSheet = UIActionSheet(title: nil, delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil,otherButtonTitles:"Select photo from library", "Take a picture", "Take a video")
        } else {
            actionSheet = UIActionSheet(title: nil , delegate: self, cancelButtonTitle: "Cancel", destructiveButtonTitle: nil,otherButtonTitles:"Select photo from library")
        }
        actionSheet.delegate = self
        actionSheet.showInView(self.view)
    }
    
    
    // MARK: - imagePickerController and actionsheet Delegate Methods
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info:NSDictionary!) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as String
        
        if mediaType == kUTTypeImage {
            limPicker = LimCameraImagePicker(nibName: "PickerView", bundle: NSBundle.mainBundle())
            limPicker!.setSourceType(picker.sourceType)
            var image = info[UIImagePickerControllerOriginalImage] as UIImage
            limPicker!.addImage(image)
            limPicker!.delegate = self
            
            self.navigationController!.pushViewController(limPicker!, animated: true)
            picker.dismissViewControllerAnimated(true, nil)
        } else {
            self.dismissViewControllerAnimated(true, completion: {})
            println("Video Taken!!!!");
        }
        
    }
    
    func actionSheet(actionSheet: UIActionSheet, clickedButtonAtIndex buttonIndex: Int) {
        println("Title : \(actionSheet.buttonTitleAtIndex(buttonIndex))")
        println("Button Index : \(buttonIndex)")
        
        if buttonIndex == 0 { return }
        
        let imageController = UIImagePickerController()
        imageController.editing = false
        imageController.delegate = self;
        
        if( buttonIndex == 1){
            imageController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        } else if(buttonIndex == 2){
            imageController.sourceType = UIImagePickerControllerSourceType.Camera
            imageController.showsCameraControls = true
        } else {
            imageController.sourceType = UIImagePickerControllerSourceType.Camera
            imageController.mediaTypes = [kUTTypeMovie!]
            imageController.allowsEditing = false
            imageController.showsCameraControls = true
        }
        
        self.presentViewController(imageController, animated: true, completion: nil)
    }

    // MARK: - LimCameraImagePickerDelegate Methods
    
    func donePicking(picker: LimCameraImagePicker, didPickedUrls: [String]) {
        
        dispatch_async(dispatch_get_main_queue(), {
            // update some UI
            self.cleanProcessOnPicking()
        })
        
        //Do something with uploaded urls
        
    }
    
    func cleanProcessOnPicking() {
        self.navigationController!.popViewControllerAnimated(true)
    }
    
    func cancelPicking(picker: LimCameraImagePicker) {
        self.navigationController!.popToViewController(self, animated: true)
    }

}

