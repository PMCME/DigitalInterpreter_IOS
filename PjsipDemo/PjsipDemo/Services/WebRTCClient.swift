//
//  WebRTCClient.swift
//  PjsipDemo
//
//  Created by Apple on 24/05/23.
//

import UIKit


var incomingCallID = pjsua_call_id()
//var desc = pj_thread_desc()
//var thread: pj_thread_t?

//MARK: Private Function
func on_call_state(call_id: pjsua_call_id, e: UnsafeMutablePointer<pjsip_event>?) {
    
    var ci = pjsua_call_info();
    pjsua_call_get_info(call_id, &ci);
    print("on call state: \(ci.state.rawValue)")
    if (ci.state == PJSIP_INV_STATE_DISCONNECTED) {
        /* UIView update must be done in the main thread */
       // DispatchQueue.main.sync {
            dismissVideoViewController()
            isCallingPhone = false
            print("Coming in On Call State")
       // }
    }
}

 func on_reg_state2(acc_id: pjsua_acc_id, info: UnsafeMutablePointer<pjsua_reg_info>?) {
    
     var accinfo =  pjsua_acc_info()
     pjsua_acc_get_info(acc_id, &accinfo)
     print("registration text: \(accinfo.status_text)")
     var success = true
    if accinfo.status.rawValue !=  200 {
       success = false
    }
     print("print: \(success)--\(accinfo.status.rawValue)")
     NotificationCenter.default.post(name: Constant.NotificationName.GetRegisterUserCallBack.name, object: nil , userInfo: ["success" : success])
}


 func tupleToArray<Tuple, Value>(tuple: Tuple) -> [Value] {
    let tupleMirror = Mirror(reflecting: tuple)
    return tupleMirror.children.compactMap { (child: Mirror.Child) -> Value? in
        return child.value as? Value
    }
}

 func on_call_media_state(call_id: pjsua_call_id) {
    var ci = pjsua_call_info();
    pjsua_call_get_info(call_id, &ci);

    for mi in 0...ci.media_cnt {
        let media: [pjsua_call_media_info] = tupleToArray(tuple: ci.media);
        print("media type : \(media[Int(mi)].status.rawValue)")
       
        if (media[Int(mi)].status == PJSUA_CALL_MEDIA_ACTIVE ||
            media[Int(mi)].status == PJSUA_CALL_MEDIA_REMOTE_HOLD || media[Int(mi)].status == PJSUA_CALL_MEDIA_LOCAL_HOLD)
        {
            switch (media[Int(mi)].type) {
            case PJMEDIA_TYPE_AUDIO:
                var call_conf_slot: pjsua_conf_port_id;
                call_conf_slot = media[Int(mi)].stream.aud.conf_slot;
                print("Port Number: \(call_conf_slot)")
                pjsua_conf_connect(call_conf_slot, 0);
                pjsua_conf_connect(0, call_conf_slot);
                break;
        
            case PJMEDIA_TYPE_VIDEO:
                let wid = media[Int(mi)].stream.vid.win_in;
   
                 /* var param =  pjmedia_vid_dev_param()
                  pjmedia_vid_dev_default_param(nil, wid, &param)
                  var format = pjmedia_format()
                  format.type = pjmedia_type(PJMEDIA_TYPE_VIDEO.rawValue)
                  param.fmt = format
                  var vid = pjmedia_video_format_detail()
                  vid.size.h = 640
                  vid.size.w = 1280
                  format.det.vid = vid
                  
                 pjmedia_vid_dev_param_set_cap(&param, pjmedia_vid_dev_cap(PJMEDIA_VID_DEV_CAP_OUTPUT_WINDOW.rawValue), nil)*/
                
                var wi = pjsua_vid_win_info();
                var previewWindow = pjsua_vid_preview_param()
                previewWindow.wnd_flags = PJMEDIA_VID_DEV_WND_RESIZABLE.rawValue ;


                pjsua_vid_preview_param_default(&previewWindow)
                
                
                
              //let nativeVideoAdded =  pjsua_vid_preview_has_native(media[Int(mi)].stream.vid.cap_dev)
              //   _ = pjsua_vid_preview_start(media[Int(mi)].stream.vid.cap_dev, &previewWindow)
              // let status = pjsua_vid_preview_stop(media[Int(mi)].stream.vid.cap_dev)
              //pjsua_vid_preview_stop
//                let windowLocalID  = pjsua_vid_preview_get_win(media[Int(mi)].stream.vid.win_in)
//                var localVideoSize = pjmedia_rect_size()
//                localVideoSize.h = 1280
//                localVideoSize.w = 640
//                let statusWinSizeLocal =  pjsua_vid_win_set_size(wid, &localVideoSize)
               // pjsua_vid_win_rotate(wid, 90)
                
//                var localVideo = pjsua_vid_win_info();
//                localVideo.show = pj_bool_t(PJ_Fa.rawValue);
                pjsua_vid_win_set_fullscreen(wid, pjmedia_vid_dev_fullscreen_flag(PJMEDIA_VID_DEV_FULLSCREEN.rawValue)) //full screen
                
           // let previewID  = pjsua_vid_preview_get_win(media[Int(mi)].stream.vid.cap_dev)
//
//                print("j value \(previewID)")
           
                //param.fmt.det.vid.size.w
                var windowID  = [pjsua_vid_win_id](repeating: 0, count: 64)
                var countOFWindow : UInt32 = 64
                pjsua_vid_enum_wins(&windowID, &countOFWindow)
                
                
                
                print("windows : \(windowID) ----- \(countOFWindow)")
                let i1  =  (wid == PJSUA_INVALID_ID.rawValue) ? 0 : Int(wid);
                let last1  =  (wid == PJSUA_INVALID_ID.rawValue) ? Int(PJSUA_MAX_VID_WINS): Int(wid + 1);
                for j in i1...last1 {
                    print("j value \(j)")
                    var wi =  pjsua_vid_win_info()
                    if (pjsua_vid_win_get_info(pjsua_vid_win_id(j), &wi) == PJ_SUCCESS.rawValue) {
                        let vid_win:UIView =  Unmanaged<UIView>.fromOpaque(wi.hwnd.info.ios.window).takeUnretainedValue();
                      
                        DispatchQueue.main.async {
//                            displayVideoView(nil, nil)
                            let topVC = topMostController()

                            if ((wi.is_native == 0)) {
                                print("size of vid_win 111: \(vid_win.frame)--- \(wi.show)")
                                
                                //displayVideoView(vid_win, nil)
                                if let vc = topVC as? VideoVC {
                                    vid_win.frame = vc.videoView.frame
                                    vc.videoView.addSubview(vid_win)

                                } else {
                                     displayVideoView(vid_win, nil)
                                }
                            } else  {
                                
                                //DISPLAY SELF PREVIEW
                                if let vc = topVC as? VideoVC {
                                    vid_win.frame =  CGRect(x: 0, y: 0, width: 320, height: 320)
                                    //vid_win.frame = vc.cameraPreviewView.frame
                                  //  vid_win.center = vc.cameraPreviewView.center
                                    vc.cameraPreviewView.addSubview(vid_win)
                                } else {
                                     displayVideoView(nil, vid_win)
                                }
                                print("size of vid_win 2222: \(vid_win.frame)---- \(wi.show)")
                               
                            }
                        }
                    }
                    
                }
                
                
                break;
            
            default:
                break;
            }
        }
    }
}

/*MARK: On incoming call*/
 func on_incoming_call(acc_id: pjsua_acc_id, call_id: pjsua_call_id, rdata: UnsafeMutablePointer<pjsip_rx_data>?) {
     if isCallingPhone {
         return
     }
     registerThread()
     print("Incoming call is received-- \(acc_id)")
     var ci: pjsua_call_info = pjsua_call_info()
     var opt: pjsua_call_setting = pjsua_call_setting()
     pjsua_call_setting_default(&opt)
     var pParam: pjsua_vid_preview_param = pjsua_vid_preview_param()
     pjsua_vid_preview_param_default(&pParam)
     pParam.show = pj_bool_t(PJ_TRUE.rawValue);
     opt.aud_cnt = 1
     opt.vid_cnt = 1
     pjsua_call_get_info(call_id, &ci)
     incomingCallID = call_id
     
     DispatchQueue.main.async {

         let incomingCallVC =  incomingCallView(frame: CGRect(x: 0, y: 0, width: screenSize.width * 0.5, height: screenSize.height * 0.5))
         let vc = topMostController()
         vc.view.addSubview(incomingCallVC)
         incomingCallVC.center.x =  vc.view.center.x
         incomingCallVC.center.y = vc.view.center.y
         incomingCallVC.isReceiveCallBack = { isReceive in
             if isReceive {
                 pjsua_call_answer2(call_id, &opt, 200, nil, nil)
             } else  {
                 hangup_allCall()
             }
             incomingCallVC.removeFromSuperview()
         }
         
//         let dialogMessage = UIAlertController(title: "Incoming Call", message: "", preferredStyle: .alert)
//
//         let ok = UIAlertAction(title: "Accept", style: .default, handler: { (action) -> Void in
//             pjsua_call_answer2(call_id, &opt, 200, nil, nil)
//          })
//
//         let HangupCall = UIAlertAction(title: "Hangup", style: .default, handler: { (action) -> Void in
//             hangup_allCall()
//
//          })
//
//         dialogMessage.addAction(ok)
//         dialogMessage.addAction(HangupCall)
//         let vc = topMostController()
//         vc.present(dialogMessage, animated: true, completion: nil)
     }
      //openIncomingView()
   //  pjsua_call_answer2(call_id, &opt, 200, nil, nil)
}


func receiveCall() {
   var opt: pjsua_call_setting = pjsua_call_setting()
    opt.aud_cnt = 1 // number of simultaneous audio calls
    opt.vid_cnt = 1 // number of simultaneous video calls
    pjsua_call_answer2(incomingCallID, &opt, 200, nil, nil)
}

func hangup_allCall(){
    
    let ci = pjsua_call_info();
    if (ci.id != PJSUA_INVALID_ID.rawValue) {
        let status = pjsua_call_hangup(ci.id, 200, nil, nil);
        if status == PJ_SUCCESS.rawValue {
          
            print("Hangup call ==============")
        } else {
            pjsua_call_hangup_all()
        }
    } else {
        pjsua_call_hangup_all()
    }
    isCallingPhone = false
}


func registerThread() {
    var status: pj_status_t
    let desc: UnsafeMutablePointer<Int>? = nil
       if (pj_thread_is_registered() == 0) {
            var pjThread  = pj_thread_this()
            status = pj_thread_register(nil, desc, &pjThread)
            if status != PJ_SUCCESS.rawValue {
                let errorMsg = "Error registering thread at PJSUA"
                print(errorMsg)
            }
        }
}


 func call_func(user_data: UnsafeMutableRawPointer? ) {//, account_id : pjsua_acc_id
    print("Going in call function")
    let pjsip_vars = Unmanaged<PjsipVars>.fromOpaque(user_data!).takeUnretainedValue()
    if (!pjsip_vars.calling) {
        var status: pj_status_t;
        var opt = pjsua_call_setting();

        pjsua_call_setting_default(&opt);
        opt.aud_cnt = 1;
        opt.vid_cnt = 1;

         print("Destinlation URL:\(pjsip_vars.dest)")
        let dest_str = strdup(pjsip_vars.dest);
        var dest:pj_str_t = pj_str(dest_str);
        status = pjsua_call_make_call(0, &dest, &opt, nil, nil, &pjsip_vars.call_id);//&pjsip_vars.call_id
        if (status != PJ_SUCCESS.rawValue)
        {
            print("error making in call")
            isCallingPhone =  false
           //pjsua_perror(THIS_FILE, "Error making call", status);
        }
//        var param = pjsua_call_vid_strm_op_param()
//        let op = pjsua_call_vid_strm_op(PJSUA_CALL_VID_STRM_STOP_TRANSMIT.rawValue)
//        var streamStatus = pjsua_call_set_vid_strm(pjsip_vars.call_id, op, &param)
        
//        DispatchQueue.main.sync {
//            pjsip_vars.calling = (status == PJ_SUCCESS.rawValue);
//        }
        free(dest_str);
    } else {
        if (pjsip_vars.call_id != PJSUA_INVALID_ID.rawValue) {
            DispatchQueue.main.sync {
                pjsip_vars.calling = false;
                isCallingPhone =  false

            }
            pjsua_call_hangup(pjsip_vars.call_id, 200, nil, nil);
            pjsip_vars.call_id = PJSUA_INVALID_ID.rawValue;
        }
    }

}


func showRemoteVideoOnFullScreen(){
    var vi = pjsua_call_vid_strm_op_param()
    pjsua_call_vid_strm_op_param_default(&vi)
    print("Capture Device ID 298: \(vi.cap_dev)")

   // let nativeVideoAdded =  pjsua_vid_preview_has_native(vi.cap_dev)
    //let windowID  = pjsua_vid_preview_get_win(vi.cap_dev)

    //pjsua_vid_win_set_show(windowID, pj_bool_t(PJ_FALSE.rawValue))
    let status = pjsua_vid_preview_stop(vi.cap_dev)
    if status == PJ_SUCCESS.rawValue {
        print("showRemoteVideoOnFullScreen  -\(vi.cap_dev)")
    }
    
}

func showLocalVideoOnScreen() {
    var previewWindow = pjsua_vid_preview_param()
    var vi = pjsua_call_vid_strm_op_param()
    pjsua_call_vid_strm_op_param_default(&vi)
    let status = pjsua_vid_preview_start(vi.cap_dev , &previewWindow)
    if status == PJ_SUCCESS.rawValue {
         print("showLocalVideoOnScreen")
    }
}



func unMuteoutgoingCall() {
    
    let status = pjsua_conf_adjust_tx_level (0,1);
    if status == PJ_SUCCESS.rawValue {
            print("success Unmute video")
        }
}

func muteOugoingCall() {
    let status = pjsua_conf_adjust_tx_level (0,0);
    if status == PJ_SUCCESS.rawValue {
            print("success mute video")
        }
}


//Hold and Unhold Call Method

func holdCall() {
    let ci = pjsua_call_info();
    var opt = pjsua_call_setting();
    opt.aud_cnt = 0;
    opt.vid_cnt = 0;
   // let success = pjsua_call_set_hold(ci.id, nil)
    let success =  pjsua_call_reinvite2(ci.id, &opt, nil)
    if success == PJ_SUCCESS.rawValue {
        print("Hold Call")
    }
}


func unHoldCall() {
    let ci = pjsua_call_info();
    var opt = pjsua_call_setting();
    opt.aud_cnt = 1;
    opt.vid_cnt = 1;
    let success =  pjsua_call_reinvite2(ci.id, &opt, nil)
    if success == PJ_SUCCESS.rawValue {
        print("Hold Call")
    }
}

//MARK: Send DTMF Digit
func sendDTMFDigit( _ number : String) {
    let ci = pjsua_call_info();
    var param = pjsua_call_send_dtmf_param()
    pjsua_call_send_dtmf_param_default(&param)
    param.digits = pj_str(strdup(number));
    pjsua_call_send_dtmf(ci.id, &param)
  
}
