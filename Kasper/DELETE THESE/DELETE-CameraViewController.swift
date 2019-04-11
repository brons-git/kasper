//
//  CameraViewController.swift
//  Kasper
//
//  Created by Bronson Berwald on 4/6/18.
//  Copyright © 2018 Bronson Berwald. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Firebase
import SDWebImage

class CameraViewController: UIViewController {
    
    // Outlets
    @IBOutlet weak var photo: UIImageView!
    @IBOutlet weak var profilePic: UIImageView!
    var flashButton: UIButton!
    var captureSession = AVCaptureSession()
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var photoSetting = AVCapturePhotoSettings()
    var devicePhotoSet = AVCapturePhotoSettings()
    var image = UIImage()
    var captureDevice: AVCaptureDevice?

    // View Did Load
    override func viewDidLoad() {
        super.viewDidLoad()
        photo.image = self.image
        
        // Initialize
        setupCaptureSession()
        setupDevice()
        setupProPic()
        setupInputOutput()
        setupCorrectFramerate(currentCamera: currentCamera!)
        setupPreviewLayer()
        startRunningCaptureSession()
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
    
    
    // Capture Session
    func setupCaptureSession() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
    }
    
    // Device
    func setupDevice() {
        photoSetting.isAutoStillImageStabilizationEnabled = true
        photoSetting.isHighResolutionPhotoEnabled = true
        photoSetting.isAutoDualCameraFusionEnabled = true
        photoSetting.isDualCameraDualPhotoDeliveryEnabled = true
        //LIVE --> photoSetting.livePhotoMovieFileURL = URL
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
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
    }

    // Input and Output
    func setupInputOutput() {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentCamera!)
            captureSession.addInput(captureDeviceInput)
            photoOutput = AVCapturePhotoOutput()
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])], completionHandler: nil)
            captureSession.addOutput(photoOutput!)
            
        } catch {
            print(error)
        }
    }
    
    // Camera Frame Rate
    func setupCorrectFramerate(currentCamera: AVCaptureDevice) {
        for vFormat in currentCamera.formats {
            //see available types
            //print("\(vFormat) \n")
            
            var ranges = vFormat.videoSupportedFrameRateRanges as [AVFrameRateRange]
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
    
    // Preview Layer
    func setupPreviewLayer() {
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
        cameraPreviewLayer?.frame = self.view.frame
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    // Capture Session
    func startRunningCaptureSession() {
        captureSession.startRunning()
        backCamera?.unlockForConfiguration()
    }
    
    // Capture Output
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, fromConnection connection: AVCaptureConnection!) {
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.setSampleBufferDelegate(self as? AVCaptureVideoDataOutputSampleBufferDelegate, queue: DispatchQueue.main)
        
        let comicEffect = CIFilter(name: "CIComicEffect")
        
        let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
        let cameraImage = CIImage(cvImageBuffer: pixelBuffer!)
        
        comicEffect!.setValue(cameraImage, forKey: kCIInputImageKey)
        
        let photo = UIImage(ciImage: (comicEffect!.value(forKey: kCIOutputImageKey) as! CIImage?)!)
        
        print("made it here")
        
        
        DispatchQueue.main.async {
            self.photo.image = photo
        }
    }
    
    // Take Picture
    @IBAction func takePicButtonTapped(_ sender: Any) {
        let settings = AVCapturePhotoSettings()
        photoOutput?.capturePhoto(with: settings, delegate: self)
        let camPrevVC = self.storyboard?.instantiateViewController(withIdentifier: "CameraPreviewMediaVC")
        self.present(camPrevVC!, animated: false, completion: nil)
    }
    
    // Flip Camera
    @IBAction func flipCam(_ sender: Any) {
        print("CAMERA FLIP")
    }
    
    // Touch to Focus
    //
    //
    
    // Flash On/Off !ERROR!
    @IBAction func flashButtonTapped(_ sender: Any, device:AVCaptureDevice) {
        if device.torchMode == .off {
            do {
                if (device.hasTorch){
                    try device.lockForConfiguration()
                    self.flashButton.isHighlighted = true
                    device.torchMode = .on
                    devicePhotoSet.flashMode = .on
                    device.unlockForConfiguration()
                    }
            } catch {
                print("Error w/ CameraFlash OFF!")
            }
        } else {
            if device.torchMode == .on {
                do {
                    if (device.hasTorch){
                        try device.lockForConfiguration()
                        self.flashButton.isHighlighted = false
                        device.torchMode = .off
                        devicePhotoSet.flashMode = .off
                        device.unlockForConfiguration()
                        }
                } catch {
                    print("Error w/ CameraFlash ON!")
                }
            }
        }
    }
    
    // GOTO: Messages
    @IBAction func messagesTabButtonTapped(_ sender: Any) {
        let showMessagesVC = self.storyboard?.instantiateViewController(withIdentifier: "MessagesVC")
        self.present(showMessagesVC!, animated: false, completion: nil)
    }
    
    // GOTO: People
    @IBAction func peopleTabButtonTapped(_ sender: Any) {
        let showPeopleVC = self.storyboard?.instantiateViewController(withIdentifier: "PeopleVC")
        self.present(showPeopleVC!, animated: false, completion: nil)
    }
    
    // GOTO: Feed
    @IBAction func feedTabButtonTapped(_ sender: Any) {
        let showFeedVC = self.storyboard?.instantiateViewController(withIdentifier: "FeedVC")
        self.present(showFeedVC!, animated: false, completion: nil)
    }
    
    // GOTO: Global Chat
    @IBAction func notificationsTabButtonTapped(_ sender: Any) {
        let showGlobalChatVC = self.storyboard?.instantiateViewController(withIdentifier: "GlobalChatVC")
        self.present(showGlobalChatVC!, animated: false, completion: nil)
    }
    
    // GOTO: Profile
    @IBAction func profileTabButtonTapped(_ sender: Any) {
        let showProfileVC = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC")
        self.present(showProfileVC!, animated: false, completion: nil)
    }
    
    // Prepare Storyboard Segue for Preview Media
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCameraPreviewMediaSegue" {
            let previewVC = segue.destination as! CameraPreviewMediaViewController
            previewVC.image = self.image
        }
    }
    
}

// Preview Media
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let imageData = photo.fileDataRepresentation() {
            print(imageData)
            image = UIImage(data: imageData)!
            performSegue(withIdentifier: "goToCameraPreviewMediaSegue", sender: nil)
        }
    }
}
