//
//  KPhotoCamViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 9/24/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Firebase
import SDWebImage

class KPhotoCamViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {

    // Outlets
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var profilePic: UIImageView!
    
    // Constants
    let captureSession = AVCaptureSession()
    
    // Variables
    var previewLayer:CALayer!
    var captureDevice:AVCaptureDevice!
    var photoOutput: AVCapturePhotoOutput?
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var image = UIImage()
    var photoSetting = AVCapturePhotoSettings()
    
    // Data
    var posts = [Post]()
    var users = [User]()
    var notifications = [Notifications]()
    var recentconvos = [RecentConvo]()
    
    // Take Photo
    var takePhoto = false
    
    // Camera Flash
    var flash_status = false
    
    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.image

        // Initialize
        banCheck()
        setupProPic()
        prepareCamera()
        setupCorrectFramerate(currentCamera: currentCamera!)        
    }
    
    
    // Check if user is banned
    func banCheck() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).child("rank").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            let rank = snapshot.value as? String
            if rank == "banned" {
                let banAlert = self.storyboard?.instantiateViewController(withIdentifier: "banAlertVC")
                self.present(banAlert!, animated: false, completion: nil)
            }
            if rank != "banned" {
                print("Not banned")
            }
        })
    }
    
    // Setup Profile Picture
    fileprivate func setupProPic() {
        let uid = Auth.auth().currentUser?.uid
        Database.database().reference().child("users").child(uid!).child("propicref").observeSingleEvent(of: .value, with: { (snapshot) in
            print(snapshot)
            let proPicRefe = snapshot.value as? String
            let proPicUrlRefe:NSURL? = NSURL(string: proPicRefe!)
            if let proPicUrl = proPicUrlRefe as URL? {
                self.profilePic.sd_setImage(with: proPicUrl)
                self.profilePic.layer.cornerRadius = 20.0
                self.profilePic.clipsToBounds = true
            }
        })
    }
    
    // Prepare Device
    func prepareCamera() {
        photoSetting.isAutoStillImageStabilizationEnabled = true
        photoSetting.isHighResolutionPhotoEnabled = true
        photoSetting.isAutoDualCameraFusionEnabled = true
        photoSetting.isDualCameraDualPhotoDeliveryEnabled = true
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        captureDevice = availableDevices.first
        if (captureDevice!.isFocusModeSupported(.continuousAutoFocus)) {
            try! captureDevice!.lockForConfiguration()
            captureDevice!.focusMode = .continuousAutoFocus
            captureDevice!.unlockForConfiguration()
        } else {
            print("AUTO-FOCUS ERROR!")
        }
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera], mediaType: AVMediaType.video, position: AVCaptureDevice.Position.unspecified)
        let devices = deviceDiscoverySession.devices
        
        for device in devices {
            if device.position == AVCaptureDevice.Position.back {
                backCamera = device
            } else if device.position == AVCaptureDevice.Position.front {
                frontCamera = device
            }
        }
        currentCamera = backCamera
        beginSession()
    }
    
    // Begin Camera Session
    func beginSession() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            captureSession.addInput(captureDeviceInput)
            
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
            
        } catch {
            print(error.localizedDescription)
        }
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer
        self.view.layer.insertSublayer(previewLayer, at: 0)
        previewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        self.previewLayer.frame = self.view.layer.frame
        captureSession.startRunning()
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString):NSNumber(value:kCVPixelFormatType_32BGRA)] as [String : Any]
        dataOutput.alwaysDiscardsLateVideoFrames = true
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        captureSession.commitConfiguration()
        let queue = DispatchQueue(label: "captureQueue")
        dataOutput.setSampleBufferDelegate(self, queue: queue)
    }
    
    // Camera Frame Rate
    func setupCorrectFramerate(currentCamera: AVCaptureDevice) {
        for vFormat in currentCamera.formats {
            //see available types
            //print("\(vFormat) \n")
            
            let ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
            let frameRates = ranges[0]
            
            do {
                //set to 240fps - available types are: 30, 60, 120 and 240 and custom
                // lower framerates cause major stuttering
                if frameRates.maxFrameRate == 240 {
                    try currentCamera.lockForConfiguration()
                    currentCamera.activeFormat = vFormat as AVCaptureDevice.Format
                    //for custom framerate set min max activeVideoFrameDuration to whatever you like, e.g. 1 and 180
                    currentCamera.activeVideoMinFrameDuration = frameRates.minFrameDuration
                    currentCamera.activeVideoMaxFrameDuration = frameRates.maxFrameDuration
                }
            }
            catch {
                print("Could not set active format")
                print(error)
            }
        }
    }
    
    // Camera Flash
    @IBAction func didTouchFlashButton(_ sender: Any) {
        if let avDevice = AVCaptureDevice.default(for: AVMediaType.video) {
            if (avDevice.hasTorch) {
                do {
                    try avDevice.lockForConfiguration()
                } catch {
                    print("aaaa")
                }
                
                if avDevice.isTorchActive {
                    avDevice.torchMode = AVCaptureDevice.TorchMode.off
                } else {
                    avDevice.torchMode = AVCaptureDevice.TorchMode.on
                }
            }
            // unlock your device
            avDevice.unlockForConfiguration()
        }
    }
    
    // Take Photo
    @IBAction func takePhoto(_ sender: Any) {
        takePhoto = true
    }
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if takePhoto {
            takePhoto = false
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                let photoVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "KPhotoPrevVC") as! KPhotoPrevViewController
                photoVC.takenPhoto = image
                photoVC.image = image
                DispatchQueue.main.async {
                    self.present(photoVC, animated: false, completion: nil)
                }
            }
            
        }
    }
    func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
        }
        return nil
    }
    
    // GOTO: Messages
    @IBAction func messagesTabButtonTapped(_ sender: Any) {
        // Pass to next
        let passToVC = self.storyboard?.instantiateViewController(withIdentifier: "MessagesVC") as? MessagesViewController
        passToVC?.posts = posts
        passToVC?.users = users
        passToVC?.notifications = notifications
        passToVC?.recentconvos = recentconvos
        // Go to next
        let showMessagesVC = self.storyboard?.instantiateViewController(withIdentifier: "MessagesVC")
        self.present(showMessagesVC!, animated: false, completion: nil)
    }
    
    // GOTO: People
    @IBAction func peopleTabButtonTapped(_ sender: Any) {
        // Pass to next
        let passToVC = self.storyboard?.instantiateViewController(withIdentifier: "PeopleVC") as? PeopleViewController
        passToVC?.posts = posts
        passToVC?.users = users
        passToVC?.notifications = notifications
        passToVC?.recentconvos = recentconvos
        // Go to next
        let showPeopleVC = self.storyboard?.instantiateViewController(withIdentifier: "PeopleVC")
        self.present(showPeopleVC!, animated: false, completion: nil)
    }
    
    // GOTO: Feed
    @IBAction func feedTabButtonTapped(_ sender: Any) {
        // Pass to next
        let passToVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedVC") as? FeedViewController
        passToVC?.posts = posts
        passToVC?.users = users
        passToVC?.notifications = notifications
        passToVC?.recentconvos = recentconvos
        // Go to next
        let showFeedVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedVC")
        self.present(showFeedVC!, animated: false, completion: nil)
    }
    
    // GOTO: Notifications
    @IBAction func notificationsTabButtonTapped(_ sender: Any) {
        // Pass to next
        let passToVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsVC") as? NotificationsViewController
        passToVC?.posts = posts
        passToVC?.users = users
        passToVC?.notifications = notifications
        passToVC?.recentconvos = recentconvos
        // Go to next
        let showNotificationsVC = self.storyboard?.instantiateViewController(withIdentifier: "NotificationsVC")
        self.present(showNotificationsVC!, animated: false, completion: nil)
    }
    
    // GOTO: Profile
    @IBAction func profileTabButtonTapped(_ sender: Any) {
        let showProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC")
        self.present(showProfileVC!, animated: false, completion: nil)
    }
    

}

