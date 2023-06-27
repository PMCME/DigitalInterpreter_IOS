//
//  localVideoRenderView.swift
//  PjsipDemo
//
//  Created by Apple on 26/05/23.
//

import UIKit
import AVFoundation

class localVideoRenderView: UIView , AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var cameraView: UIView!
    var session: AVCaptureSession?
    var input: AVCaptureDeviceInput?
    var output: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    @IBOutlet var containerView: UIView!

    
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("localVideoRenderView", owner: self, options: nil)
        self.containerView.frame = frame
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]

        addSubview(self.containerView)
        self.cameraView.frame =  frame
        self.displayFrontCamera()
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    func displayFrontCamera(){
        //Initialize session an output variables this is necessary
           session = AVCaptureSession()
           output = AVCapturePhotoOutput()
        if  let camera = getDevice(position: .front) {
           do {
              input = try AVCaptureDeviceInput(device: camera)
           } catch let error as NSError {
              print(error)
              input = nil
           }
            if(session?.canAddInput(input!) == true){
              session?.addInput(input!)
             // output?.outputSettings = [AVVideoCodecKey : AVVideoCodecJPEG]
                if(session?.canAddOutput(output!) == true){
                    session?.addOutput(output!)
                    
                    previewLayer = AVCaptureVideoPreviewLayer(session: session!)
                    previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                    previewLayer?.connection!.videoOrientation = AVCaptureVideoOrientation.portrait
                    
                    previewLayer?.frame = cameraView.bounds
                  cameraView.layer.addSublayer(previewLayer!)
                 session?.startRunning()
              }
           }
        }
    }
    
    func getDevice(position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devices() as NSArray;
        for de in devices {
            let deviceConverted = de as! AVCaptureDevice
            if(deviceConverted.position == position){
               return deviceConverted
            }
        }
       return nil
    }
    
    override func layoutSubviews() {
        self.cameraView.frame
        print("camera view frame : \(cameraView.frame)")
        print("containerView : \(containerView.frame)")
    }

}
