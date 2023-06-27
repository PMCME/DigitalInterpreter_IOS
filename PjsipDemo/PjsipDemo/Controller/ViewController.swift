//
//  ViewController.swift
//  PjsipDemo
//
//  Created by Apple on 17/05/23.
//

import UIKit
import SDWebImage

struct nativeView {
    var view = UIView()
}

class PjsipVars: ObservableObject {
    @Published var calling = false
    var dest: String = ""//"sip:1002@fs.dics.se:6443;transport=tcp"
    var call_id: pjsua_call_id = PJSUA_INVALID_ID.rawValue
}


class ViewController: UIViewController {
    // Status Label
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet var loginInfoView : UIView!
    @IBOutlet var callInfoView : UIView!
    @IBOutlet var btnLogout : UIButton!
    
    // Sip settings Text Fields
    @IBOutlet weak var sipUsernameTField: UITextField!
    @IBOutlet weak var sipPasswordTField: UITextField!
    
    //Destination Uri to Making outgoing call
    @IBOutlet weak var sipDestinationUriTField: UITextField!
    @IBOutlet var imgCall : SDAnimatedImageView!
    
    var status: pj_status_t = 0;
    var objPjSip =  PjsipVars()
    var acc_id :pjsua_acc_id = -1;

    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("screen size: Width \(screenSize.width)------Height \(screenSize.height)")
       //Add Notification Observer
        NotificationCenter.default.addObserver(forName: Constant.NotificationName.HangUpCallBack.name, object: nil, queue: OperationQueue.main) { (notification) in
            self.hangupCall()
        }
        
        NotificationCenter.default.addObserver(forName: Constant.NotificationName.GetRegisterUserCallBack.name, object: nil, queue: OperationQueue.main) { (notification) in
            let isSuccess = notification.userInfo?["success"] as? Bool ?? false
             self.getUserRegisterCallback(isSuccess)
        }
       self.btnLogout.isHidden = true
        let animatedImage = SDAnimatedImage(named: "AnimatedCallNow.gif")
        imgCall.image = animatedImage

        
        self.callInfoView.isHidden = true

        
        //Done button to the keyboard
        sipUsernameTField.addDoneButtonOnKeyboard()
        sipPasswordTField.addDoneButtonOnKeyboard()
        sipDestinationUriTField.addDoneButtonOnKeyboard()
        sipUsernameTField.text = "1001"
        sipPasswordTField.text = "Demo User"
        sipDestinationUriTField.text =  "1006"
        sipDestinationUriTField.isHidden = false
        status = pjsua_create();
        if (status != PJ_SUCCESS.rawValue) {
            NSLog("Failed creating pjsua");
        }

        /* Init configs */
        var cfg = pjsua_config();
        cfg.stun_srv_cnt =  2
        //cfg.stun_srv.0 = pj_str(strdup("stun:u2.xirsys.com"))
        
        cfg.stun_srv.0 = pj_str(strdup("stun:stun.l.google.com:19302"))
        cfg.stun_srv.1 = pj_str(strdup("stun:global.stun.twilio.com:3478"))
        
        var log_cfg = pjsua_logging_config();
        var media_cfg = pjsua_media_config();
        pjsua_config_default(&cfg);
        pjsua_logging_config_default(&log_cfg);
        media_cfg.vid_preview_enable_native = pj_bool_t(PJ_TRUE.rawValue);
        pjsua_media_config_default(&media_cfg);
        
       

        /* Initialize application callbacks */
        
        //cfg.cb.on_call_state =
         cfg.cb.on_call_state = on_call_state;
         cfg.cb.on_call_media_state = on_call_media_state;
         cfg.cb.on_incoming_call = on_incoming_call;
         cfg.cb.on_reg_state2 = on_reg_state2

        /* Init pjsua */
        status = pjsua_init(&cfg, &log_cfg, &media_cfg);
        
        /* Create transport */
        var transport_id = pjsua_transport_id();
        var tcp_cfg = pjsua_transport_config();
//        var tcp_Info = pjsua_transport_info();
//        tcp_Info.type_name  = pj_str(strdup("RFC2833"))
//        tcp_Info.id = transport_id
//        tcp_Info.type = PJSIP_TRANSPORT_UDP
        
        //pjsua_transport_info
        //pjsua_transport_config_default(&tcp_cfg);
        tcp_cfg.port = 5060;
        status = pjsua_transport_create(PJSIP_TRANSPORT_TCP,
                                        &tcp_cfg, &transport_id);
        
        
        status = pjsua_start();
        
      //  status = pjsua_transport_get_info(transport_id,&tcp_Info )
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
      //  AppDelegate.AppUtility.lockOrientation(UIInterfaceOrientationMask.portrait, andRotateTo: UIInterfaceOrientation.portrait)

    }
    
    
    //Refresh Button
    @IBAction func refreshStatus(_ sender: UIButton) {
//        if (CPPWrapper().registerStateInfoWrapper()){
//            statusLabel.text = "Sip Status: REGISTERED"
//        }else {
//            statusLabel.text = "Sip Status: NOT REGISTERED"
//        }
    }
    
    
    //Login Button
    @IBAction func loginClick(_ sender: UIButton) {
    
    
        
        if self.sipUsernameTField.text == "" || self.sipPasswordTField.text == "" {
            let alert = UIAlertController(title: "SIP SETTINGS ERROR", message: "Please fill the form details", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                switch action.style{
                    case .default:
                    print("default")
                    
                    case .cancel:
                    print("cancel")
                    
                    case .destructive:
                    print("destructive")
                    
                @unknown default:
                    fatalError()
                }
            }))
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let uName = self.sipUsernameTField.text ?? ""
        let pwd = strdup("123345");//self.sipPasswordTField.text ?? ""//123345
        let id = strdup("sip:\(uName)@fs.dics.se:12004");
        let username = strdup(uName);
        let passwd = strdup(pwd);
        let realm = strdup("fs.dics.se");//fs.dics.se
        let registrar = strdup("sip:fs.dics.se");
        let proxy = strdup("sip:fs.dics.se:12004;transport=tcp");

        var opt = pjsua_call_setting();
        opt.aud_cnt = 1;
        opt.vid_cnt = 1;
        
        pjsua_call_setting_default(&opt);
        
        var acc_cfg = pjsua_acc_config();
        pjsua_acc_config_default(&acc_cfg);
        acc_cfg.reg_timeout = 600;
        acc_cfg.sip_stun_use = PJSUA_STUN_RETRY_ON_FAILURE;
        acc_cfg.media_stun_use = PJSUA_STUN_RETRY_ON_FAILURE;
        acc_cfg.id = pj_str(id);
        acc_cfg.cred_count = 1;
        acc_cfg.cred_info.0.username = pj_str(username);
        acc_cfg.cred_info.0.realm = pj_str(realm);
        acc_cfg.cred_info.0.data = pj_str(passwd);
        acc_cfg.reg_uri = pj_str(registrar);
        
        acc_cfg.proxy_cnt = 1;
        acc_cfg.proxy.0 = pj_str(proxy);
        acc_cfg.vid_out_auto_transmit = pj_bool_t(PJ_TRUE.rawValue);
        acc_cfg.vid_in_auto_show = pj_bool_t(PJ_TRUE.rawValue);
        acc_cfg.vid_cap_dev = PJMEDIA_VID_DEFAULT_CAPTURE_DEV.rawValue;
        acc_cfg.vid_rend_dev = PJMEDIA_VID_DEFAULT_RENDER_DEV.rawValue;
        acc_cfg.vid_wnd_flags = PJMEDIA_VID_DEV_WND_RESIZABLE.rawValue;
        acc_cfg.reg_retry_interval = 300;
        acc_cfg.reg_first_retry_interval = 30;
        acc_cfg.turn_cfg_use = PJSUA_TURN_CONFIG_USE_CUSTOM;
        
        var turn_cfg = pjsua_turn_config()
        turn_cfg.enable_turn = pj_bool_t(PJ_TRUE.rawValue);
        turn_cfg.turn_conn_type = pj_turn_tp_type(PJ_TURN_TP_TCP.rawValue);
        turn_cfg.turn_server =  pj_str(strdup("turn:u2.xirsys.com:3478?transport=tcp"));
        
        var stunAuthCred = pj_stun_auth_cred()
        stunAuthCred.type = pj_stun_auth_cred_type(PJ_STUN_AUTH_CRED_STATIC.rawValue)
        stunAuthCred.data.static_cred.realm = pj_str(strdup("fs.dics.se"))
        stunAuthCred.data.static_cred.username = pj_str(strdup("bbe4fa8c-27c1-11e8-b16e-4bde959dd7c3"))
        stunAuthCred.data.static_cred.data = pj_str(strdup("bbe4fb04-27c1-11e8-ab22-148c78a95c7e"))
        turn_cfg.turn_auth_cred = stunAuthCred
        acc_cfg.turn_cfg = turn_cfg
        
        
        /* Add account */
        let accountAddStaus = pjsua_acc_add(&acc_cfg, pj_bool_t(PJ_TRUE.rawValue), &acc_id);

        
        /* Free strings */
        free(id); free(username); free(passwd); free(realm);
        free(registrar); free(proxy);
        
//        var orient = pjmedia_orient(PJMEDIA_ORIENT_ROTATE_90DEG.rawValue)
//        pjsua_vid_dev_set_setting(PJMEDIA_VID_DEFAULT_CAPTURE_DEV.rawValue,
//                                  PJMEDIA_VID_DEV_CAP_OUTPUT_WINDOW, &orient, pj_bool_t(PJ_TRUE.rawValue));
        
       
      /*  var param =  pjmedia_vid_dev_param()
        var format = pjmedia_format()
        format.type = pjmedia_type(PJMEDIA_TYPE_VIDEO.rawValue)
        param.fmt = format
        var vid = pjmedia_video_format_detail()
        vid.size.h = 640
        vid.size.w = 1280
        format.det.vid = vid
       // pjmedia_vid_dev_cap
        
        pjmedia_vid_dev_param_set_cap(&param, pjmedia_vid_dev_cap(PJMEDIA_VID_DEV_CAP_OUTPUT_WINDOW.rawValue), nil)*/
        
        

        var codec_id = pj_str(strdup("H264"))
        var param = pjmedia_vid_codec_param()
        
        pjsua_vid_codec_get_param(&codec_id, &param);
        param.enc_fmt.det.vid.size.w = 720;
        param.enc_fmt.det.vid.size.h = 480;
        pjsua_vid_codec_set_param(&codec_id, &param)
        
       
        
    }
    
    //Logout Button
    @IBAction func logoutClick(_ sender: UIButton) {
        let accountAddStaus = pjsua_acc_del(acc_id)
        
        if accountAddStaus == PJ_SUCCESS.rawValue {
            statusLabel.text = "Sign in to DCS"
            self.loginInfoView.isHidden = false
            self.callInfoView.isHidden = true
            self.btnLogout.isHidden = true
        } else {
            statusLabel.text = "USER REGISTERED"
        }
        
    }

    //Call Button
    @IBAction func callClick(_ sender: UIButton) {
        if isCallingPhone {
            print("return call")
            return
        }
        isCallingPhone = true
        self.view.endEditing(true)
        let destination = self.sipDestinationUriTField.text ?? ""//4500
        objPjSip.dest  = "sip:\(destination)@fs.dics.se:12004;transport=tcp"//:6443;transport=tcp"
        let user_data = UnsafeMutableRawPointer(Unmanaged.passUnretained(objPjSip).toOpaque())
        
        //call_func(user_data: user_data, account_id: acc_id)
        pjsua_schedule_timer2_dbg(call_func, user_data, 0, "swift", 0)
    }
    
    func hangupCall(){
        
        if (self.objPjSip.call_id != PJSUA_INVALID_ID.rawValue) {
            //DispatchQueue.main.sync {
                self.objPjSip.calling = false;
           // }
//            pjsua_call_hangup(self.objPjSip.call_id, 200, nil, nil);
            self.objPjSip.call_id = PJSUA_INVALID_ID.rawValue;
            if (incomingCallID != PJSUA_INVALID_ID.rawValue) {
                hangup_allCall()
            } else  {
              let status = pjsua_call_hangup(self.objPjSip.call_id, 200, nil, nil);
                if status == PJ_SUCCESS.rawValue {
                    isCallingPhone = false
                    print("Hangup call ============== 267")
                }
            }
        } else {
            if (incomingCallID != PJSUA_INVALID_ID.rawValue) {
                hangup_allCall()
            }
        }
    }
    
    func getUserRegisterCallback( _ isSuccess : Bool) {
        
    
       if !isSuccess {
           statusLabel.text = "USER NOT REGISTERED"
       } else {
           statusLabel.text = "USER REGISTERED"
           self.loginInfoView.isHidden = true
           self.callInfoView.isHidden = false
           self.btnLogout.isHidden = false
       }
        
    }
    
  
    override var shouldAutorotate: Bool {
        return true
    }



    
}


