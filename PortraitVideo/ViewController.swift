//
//  ViewController.swift
//  PortraitVideo
//
//  Created by Shbli on 2018-06-11.
//  Copyright © 2018 Shbli. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCapturePhotoCaptureDelegate, AVCaptureDataOutputSynchronizerDelegate, AVCaptureDepthDataOutputDelegate {
    
    @IBOutlet var previewView: UIView!
    
    var session: AVCaptureSession?
    var stillImageOutput: AVCapturePhotoOutput?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    
    let dataOutputQueue = DispatchQueue(label: "data queue", qos: .userInitiated, attributes: [], autoreleaseFrequency: .workItem)

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Setup your camera here...
        session = AVCaptureSession()
        session!.beginConfiguration()
        session!.sessionPreset = .photo
        
        let device = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back)
        
        var error: NSError?
        var input: AVCaptureDeviceInput!
        do {
            input = try AVCaptureDeviceInput(device: device!)
        } catch let error1 as NSError {
            error = error1
            input = nil
            print(error!.localizedDescription)
        }
        
        if error == nil && session!.canAddInput(input) {
            session!.addInput(input)
            // ...
            // The remainder of the session setup will go here...
            stillImageOutput = AVCapturePhotoOutput()
            
            if session!.canAddOutput(stillImageOutput!) {
                session!.addOutput(stillImageOutput!)
                
                //configure depth delivery for portrait mode
                if stillImageOutput!.isDepthDataDeliverySupported {
                    print("stillImageOutput?.isDepthDataDeliverySupported == true")
                    let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
                    settings.isDepthDataDeliveryEnabled = true
                    stillImageOutput?.isDepthDataDeliveryEnabled = true;
                    stillImageOutput?.capturePhoto(with: settings, delegate: self as AVCapturePhotoCaptureDelegate)
                } else {
                    print("stillImageOutput?.isDepthDataDeliverySupported == false")
                }

                // ...
                // Configure the Live Preview here...
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: session!)
                videoPreviewLayer!.videoGravity = AVLayerVideoGravity.resizeAspect
                videoPreviewLayer!.connection?.videoOrientation = AVCaptureVideoOrientation.portrait
                previewView.layer.addSublayer(videoPreviewLayer!)
                session?.commitConfiguration()
                
                
                if stillImageOutput!.isDepthDataDeliverySupported {
                    let depthDataOutput = AVCaptureDepthDataOutput()
                    depthDataOutput.setDelegate(self, callbackQueue: DispatchQueue(label: "depth queue"))
                    let connection = depthDataOutput.connection(with: .depthData)
                    connection!.isEnabled = true
                    depthDataOutput.isFilteringEnabled = true
                    let outputSynchronizer = AVCaptureDataOutputSynchronizer(dataOutputs: [stillImageOutput!, depthDataOutput])
                    outputSynchronizer.setDelegate(self, queue: self.dataOutputQueue)
                }

                session!.startRunning()
            }
        }
        
        videoPreviewLayer!.frame = previewView.bounds
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        //must be available otherwise the app crash
    }
    
    func dataOutputSynchronizer(_ synchronizer: AVCaptureDataOutputSynchronizer, didOutput synchronizedDataCollection: AVCaptureSynchronizedDataCollection) {
        //must be available otherwise the app won't build
    }
}

