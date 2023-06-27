//
//  VideoVC.swift
//  PjsipDemo
//
//  Created by Apple on 19/05/23.
//

import UIKit
import AVFoundation

class VideoVC: UIViewController {

    @IBOutlet var videoView : UIView!
    @IBOutlet var btnHangUp : UIButton!
    @IBOutlet var btnMute : UIButton!
    @IBOutlet var btnVideo : UIButton!
    @IBOutlet var cameraPreviewView : UIView!

    var customVideo : UIView =  UIView()
    var localVideo : UIView =  UIView()
    var dialPadView = DialPadRenderView(frame: CGRect(x: 0, y: 0, width: screenSize.width * 0.6, height: screenSize.height * 0.6))
    
    var  localPreviewWindowId : Int = 0;
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Frame: \(videoView.frame)")
    
        customVideo.frame = videoView.frame

        videoView.addSubview(customVideo)
        self.cameraPreviewView.backgroundColor =  UIColor.clear
        self.cameraPreviewView.isHidden = false
    }
    
    
    @IBAction func  btnHangup_Click(_ sender : UIButton) {
        DispatchQueue.global().async(execute: {
           NotificationCenter.default.post(Constant.NotificationName.HangUpCallBack)
        })
    }
    
    override func viewDidLayoutSubviews() {
        customVideo.frame = videoView.frame
    }
    
    override var shouldAutorotate: Bool {
      return true
    }
    
    @IBAction func btnMuteClick(_ sender : UIButton) {
        sender.isSelected =  !sender.isSelected
        if sender.isSelected {
             muteOugoingCall()
        } else {
            unMuteoutgoingCall()
        }
        
    }
    
    @IBAction func btnVideoOnOffClick( _ sender : UIButton){
        sender.isSelected =  !sender.isSelected
        if sender.isSelected {
            showRemoteVideoOnFullScreen()
        } else {
            showLocalVideoOnScreen()
        }
        
    }
    
    @IBAction func btnHoldClick(_ sender : UIButton) {
        sender.isSelected =  !sender.isSelected
        if sender.isSelected {
           holdCall()
        } else {
            unHoldCall()
        }
    }
  
    @IBAction func btnDialPad_Click(_ sender : UIButton) {
        sender.isSelected =  !sender.isSelected
        if sender.isSelected {
            self.dialPadView.center.x =  self.view.center.x
            self.dialPadView.center.y = self.view.center.y
            dialPadView.dialedNumberBlock = { number in
                print("Dial number pad: \(number)")
                sendDTMFDigit(number)
                
            }
            self.view.addSubview(self.dialPadView)
            self.view.addSubview(self.dialPadView)
        } else {
            self.dialPadView.removeFromSuperview()
        }
    }
    
    func startPreview(){

        var status : pj_status_t
        var previewWindow = pjsua_vid_preview_param()
        status = pjsua_vid_preview_start(PJMEDIA_VID_DEFAULT_CAPTURE_DEV.rawValue, nil)
        if (status != PJ_SUCCESS.rawValue) {
            print("Error starting video preview")
            return
        }
        let win_id =  pjsua_vid_preview_get_win(PJMEDIA_VID_DEFAULT_CAPTURE_DEV.rawValue);
        
        if (win_id == PJSUA_INVALID_ID.rawValue) {
            print("Error starting video preview")
            return
        }
        let slotID  = pjsua_vid_preview_get_vid_conf_port(PJMEDIA_VID_DEFAULT_CAPTURE_DEV.rawValue)
      //  status =  pjsua_conf_connect(pjsua_vid_win_get_slot(win_id), localPreviewWindowId);
        status = pjsua_conf_connect(slotID, pjsua_conf_port_id(localPreviewWindowId));
        if (status != PJ_SUCCESS.rawValue) {
            print("Error adding video preview to conf bridge");
             //  return;
           }

        var wi = pjsua_vid_win_info();
        if (pjsua_vid_win_get_info(win_id, &wi) == PJ_SUCCESS.rawValue) {
            print("video render")
            let vid_win:UIView =  Unmanaged<UIView>.fromOpaque(wi.hwnd.info.ios.window).takeUnretainedValue();
            self.cameraPreviewView.addSubview(vid_win)
        }
    }
    
    
  
    
}
