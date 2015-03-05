//
//  LimCameraImagePickerViewController.swift
//
//  Created by super on 2/23/15.
//  Copyright (c) 2015 super. All rights reserved.
//

import Foundation
import UIKit
import MediaPlayer
import MobileCoreServices
import QuartzCore

class LimCameraImagePicker: UIViewController,
    UICollectionViewDelegateFlowLayout,
    UICollectionViewDataSource,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
{

    var pickerController:UIImagePickerController?
    var sourceType : UIImagePickerControllerSourceType?
    var loadedImages: [UIImage] = []
    
    var selectedIndex : Int = -1
    
//    var loadingNotification : MBProgressHUD?

    @IBOutlet var mainBgView: UIView!
    @IBOutlet var btnRemover: UIButton!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var bgView: UIView!
    @IBOutlet var collectionView: UICollectionView!
    
    weak var delegate: LimCameraImagePickerDelegate?
    
    //AWS UPLOAD
    var uploadFileURL: NSURL?
    var tempIndex : Int = 0
    var tempImage: UIImage?;
    
    var isuploading : Bool = false
    var loadedUrls : [String] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    
    }
    
    override func loadView() {
        super.loadView()
        
        collectionView.registerClass(LimCollectionViewCell.self, forCellWithReuseIdentifier: "Cell")
        self.automaticallyAdjustsScrollViewInsets = false
        
        var nav = self.navigationController?.navigationBar
        nav?.barStyle = UIBarStyle.Black
        
        let gradient : CAGradientLayer = CAGradientLayer()
        gradient.frame = bgView.bounds
        let cor1 = UIColor.lightGrayColor().CGColor
        let cor2 = UIColor.darkGrayColor().CGColor
        let arrayColors = [cor1, cor2]
        gradient.colors = arrayColors
        bgView.layer.insertSublayer(gradient, atIndex: 0)
        
        // Background view for images collection
        bgView.layer.shadowColor = UIColor.blackColor().CGColor;
        bgView.layer.shadowRadius = 3.0
        bgView.layer.shadowOpacity = 0.15
        
        // Customize default ImageView
        imageView.layer.masksToBounds = true;
        imageView.layer.shadowColor = UIColor.blackColor().CGColor;
        imageView.layer.shadowOpacity = 0.3;
        imageView.layer.shadowRadius = 6.0;
        
        if sourceType? == nil {
            // Picker Controller Init
            pickerController =  UIImagePickerController()
            pickerController!.delegate = self
            pickerController!.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
            sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        }
        
        // Btn Remover
        btnRemover.backgroundColor = UIColor.whiteColor()
        btnRemover.layer.cornerRadius = 15.0;

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Set buttons to navigation
        var cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: "cancelPicker")
        var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "donePicker")
        
        navigationController?.navigationBarHidden = false
        
        navigationItem.setLeftBarButtonItem(cancelButton, animated: true)
        navigationItem.setRightBarButtonItem(doneButton, animated: true)
        
        collectionView.reloadData()
        selectLastImage()
        setCurrentImage()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func removeImage(sender: AnyObject) {
        if isuploading {return }
        loadedImages.removeAtIndex(selectedIndex)
        collectionView.reloadData()
        
        if loadedImages.count > 0 {
            selectLastImage()
            setCurrentImage()
        } else {
            self.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: - uiCollectionView Datasource Methods
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return loadedImages.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as LimCollectionViewCell
        
        if indexPath.row == loadedImages.count {
            cell.styleAddButton()
            cell.imageView.image = nil;
        }else{
            cell.styleImage()
            cell.imageView.image =    loadedImages[indexPath.row] as UIImage
        }

        return cell
    }
    
    // MARK: - uiCollectionView Datasource Methods
    
    func collectionView(collectionView: UICollectionView,   didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.row == loadedImages.count {
            var dispatchTime: dispatch_time_t = dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC)))
                dispatch_after(dispatchTime, dispatch_get_main_queue(), {
                self.presentCameraView()
            })
        }else{
            selectedIndex = indexPath.row;
            setCurrentImage()
        }
    }
    
    func presentCameraView () {
        var newpicker =  UIImagePickerController()
        newpicker.delegate = self
        newpicker.sourceType = sourceType!
        newpicker.editing = false
        
        if (newpicker.sourceType == UIImagePickerControllerSourceType.Camera) {
            newpicker.showsCameraControls = true
        }
        
        self.presentViewController(newpicker, animated: true, completion: nil)
    }
    
    // MARK: - imagePickerController and actionsheet Delegate Methods
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        picker.dismissViewControllerAnimated(true, completion: {})
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingMediaWithInfo info:NSDictionary!) {
        
        let mediaType = info[UIImagePickerControllerMediaType] as String
        
        if mediaType == kUTTypeImage {
            
            var originalImage = info[UIImagePickerControllerOriginalImage] as UIImage
            var editedImage = info[UIImagePickerControllerEditedImage] as UIImage?
            var imageToUse = editedImage != nil ? editedImage : originalImage
            
            loadedImages.append(imageToUse!)
            picker.dismissViewControllerAnimated(true, nil)
            
        } else {
          /*  let tempImage = info[UIImagePickerControllerMediaURL] as NSURL!
            
            let pathString = tempImage.relativePath
            self.dismissViewControllerAnimated(true, completion: {})
            
            UISaveVideoAtPathToSavedPhotosAlbum(pathString, self, nil, nil)
            println("Video Taken!!!!"); */
            
            picker.dismissViewControllerAnimated(true, completion: {})
        }
    }
    
    // MARK:- UI navigation bar delegate
    
    func navigationController(navigationController: UINavigationController!,
        willShowViewController viewController: UIViewController,
        animated: Bool) {
            
        navigationController.navigationBar.barStyle = UIBarStyle.Black
    }
    
    
    //MARK: - Main Logic
    
    func cancelPicker () {
        if isuploading {return}
        loadedImages.removeAll()
        self.delegate?.cancelPicking(self)
    }
    
    func donePicker () {
        if isuploading {return}
        
        loadedUrls.removeAll()
        
/*        if loadingNotification == nil {
            loadingNotification = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            loadingNotification!.mode = MBProgressHUDModeIndeterminate
        }*/
        doUpload()
    }
    
    func doUpload () {

        isuploading = true
        
//        loadingNotification!.labelText = "Uploading \(tempIndex+1) of \(loadedImages.count)"
        
        let date = NSDate()
        let timestamp = NSInteger(date.timeIntervalSince1970)
        let S3UploadKeyName = String(timestamp)
        
        println(S3UploadKeyName)
        
        //Create a test file in the temporary directory
        self.uploadFileURL = NSURL.fileURLWithPath(NSTemporaryDirectory() + S3UploadKeyName)
        println(self.uploadFileURL)
        
        tempImage = loadedImages[tempIndex]
        let data = UIImageJPEGRepresentation(tempImage, 0.5)
        
        var error: NSError? = nil
        if NSFileManager.defaultManager().fileExistsAtPath(self.uploadFileURL!.path!) {
            NSFileManager.defaultManager().removeItemAtPath(self.uploadFileURL!.path!, error: &error)
        }
        
        data.writeToURL(self.uploadFileURL!, atomically: true)
        
/*        let uploadRequest1 : AWSS3TransferManagerUploadRequest = AWSS3TransferManagerUploadRequest()
        let transferManager = AWSS3TransferManager.defaultS3TransferManager()
        
        uploadRequest1.bucket = S3BucketName
        uploadRequest1.key =  "Uploads/" + S3UploadKeyName
        uploadRequest1.body = self.uploadFileURL
        uploadRequest1.ACL = AWSS3ObjectCannedACL.PublicRead
        
        let task = transferManager.upload(uploadRequest1)
        
        task.continueWithBlock { (task) -> AnyObject! in
            
            self.isuploading = false

            if task.error != nil {
                println("Error: \(task.error)")
                self.loadedImages.removeAll()
//                MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
                
                self.delegate?.cancelPicking(self)
            } else {
                ++self.tempIndex
                var url = "--your url - \(S3UploadKeyName)"
                self.loadedUrls.append(url)
                
                if self.tempIndex == self.loadedImages.count {
//                    MBProgressHUD.hideAllHUDsForView(self.view, animated: false)
//                    self.loadingNotification = nil
                    
                    self.loadedImages.removeAll()
                    println("Upload successful")
                    self.delegate?.donePicking(self, didPickedUrls: self.loadedUrls)
                } else {
                    println("Moving to next upload")
                    self.doUpload()
                }
                
            }
            return nil
        }

*/
        //remove this code when you activate above commented code
        self.delegate?.donePicking(self, didPickedUrls: self.loadedUrls)

    }
    
    internal func addImage (image:UIImage!)  {
        loadedImages.append(image)
    }
    
    func selectLastImage () {
        if loadedImages.count > 0  {
            selectedIndex = loadedImages.count-1 ;
            collectionView.selectItemAtIndexPath(NSIndexPath(forItem: selectedIndex, inSection: 0), animated: true, scrollPosition: UICollectionViewScrollPosition.Right)
        } else {
            selectedIndex = -1;
        }
        
    }
    
    func setCurrentImage () {
        if selectedIndex == -1 {  return }
        
        imageView.image = loadedImages[selectedIndex]
        var height = imageView.image!.size.height * imageView.frame.size.width / imageView.image!.size.width
        imageView.bounds = CGRectMake(imageView.bounds.origin.x, imageView.bounds.origin.y, imageView.bounds.size.width, height);
        
        // Positioning button x
        var btX = (imageView.center.x - (imageView.frame.size.width/2)) - 15;
        var btY = (imageView.center.y - (imageView.frame.size.height/2)) - 15;
        btnRemover.frame = CGRectMake(btX, btY, btnRemover.frame.size.width, btnRemover.frame.size.height);
        
        mainBgView.bringSubviewToFront(btnRemover)
    }
    
    internal func setSourceType (type: UIImagePickerControllerSourceType) {
        sourceType = type
        
        pickerController =  UIImagePickerController()
        pickerController!.delegate = self
        pickerController!.sourceType = type
        
        if type == UIImagePickerControllerSourceType.Camera {
            pickerController!.showsCameraControls = true
        }
    }
}

protocol LimCameraImagePickerDelegate: class {
    func donePicking(picker: LimCameraImagePicker, didPickedUrls: [String])
    func cancelPicking(picker: LimCameraImagePicker)
}