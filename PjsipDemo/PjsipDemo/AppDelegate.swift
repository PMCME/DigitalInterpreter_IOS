//
//  AppDelegate.swift
//  PjsipDemo
//
//  Created by Apple on 17/05/23.
//

import UIKit
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

   /* var orientationLock = UIInterfaceOrientationMask.all

    struct AppUtility {
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask) {
            if let delegate = UIApplication.shared.delegate as? AppDelegate {
                delegate.orientationLock = orientation
            }
        }
            
        static func lockOrientation(_ orientation: UIInterfaceOrientationMask, andRotateTo rotateOrientation:UIInterfaceOrientation) {
            self.lockOrientation(orientation)
            UIDevice.current.setValue(rotateOrientation.rawValue, forKey: "orientation")
        }
    }*/

    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        IQKeyboardManager.shared.enable = true
        NotificationCenter.default.addObserver(self, selector: #selector(AppDelegate.rotated), name: UIDevice.orientationDidChangeNotification, object: nil)
        window?.makeKeyAndVisible()
        
        return true
    }

    // MARK: UISceneSession Lifecycle


//    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
//        return .all
//    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        self.performSelector(onMainThread: #selector(keepAlive), with: nil, waitUntilDone: true)
    }
    
    
    @objc func keepAlive() {
        var status: pj_status_t
        let desc: UnsafeMutablePointer<Int>? = nil
           if (pj_thread_is_registered() == 0) {
                var pjThread  = pj_thread_this()
                status = pj_thread_register("ipjsua", desc, &pjThread)
                if status != PJ_SUCCESS.rawValue {
                    let errorMsg = "Error registering thread at PJSUA"
                    print(errorMsg)
                }
            }
        let count = pjsua_acc_get_count()
        print("Total Active Account: \(count)")
        let accID = pjsua_acc_get_default()
        if ((pjsua_acc_is_valid(accID)) != 0) {
            pjsua_acc_set_registration(accID, pj_bool_t(PJ_TRUE.rawValue));
        }
//        for i in 0..<count {
//
//
//        }
    }
    

    //MARK : Rotate device
    @objc func rotated() {
        /*
         const pjmedia_orient pj_ori[4] =
         {
             PJMEDIA_ORIENT_ROTATE_90DEG,  /* UIDeviceOrientationPortrait */
             PJMEDIA_ORIENT_ROTATE_270DEG, /* UIDeviceOrientationPortraitUpsideDown */
             PJMEDIA_ORIENT_ROTATE_180DEG, /* UIDeviceOrientationLandscapeLeft,
                                              home button on the right side */
             PJMEDIA_ORIENT_NATURAL        /* UIDeviceOrientationLandscapeRight,
                                              home button on the left side */
         };
         */
        var status: pj_status_t
        let desc: UnsafeMutablePointer<Int>? = nil
           if (pj_thread_is_registered() == 0) {
                var pjThread  = pj_thread_this()
                status = pj_thread_register("ipjsua", desc, &pjThread)
                if status != PJ_SUCCESS.rawValue {
                    let errorMsg = "Error registering thread at PJSUA"
                    print(errorMsg)
                }
            }
        
        var orient = pjmedia_orient(PJMEDIA_ORIENT_ROTATE_90DEG.rawValue)
        let topVC = topMostController()
        if UIDevice.current.orientation == UIDeviceOrientation.landscapeLeft{
            orient = pjmedia_orient(PJMEDIA_ORIENT_ROTATE_180DEG.rawValue)
            print("Orientation change--- (landscapeLeft)");
            if let vc = topVC as? VideoVC {
                vc.cameraPreviewView.transform  = CGAffineTransform(rotationAngle: -.pi / 2)
            }

        }
        
        else if UIDevice.current.orientation == UIDeviceOrientation.landscapeRight{
            orient = pjmedia_orient(PJMEDIA_ORIENT_NATURAL.rawValue)
            if let vc = topVC as? VideoVC {
                vc.cameraPreviewView.transform  = CGAffineTransform(rotationAngle: .pi / 2)

            }
            print("Orientation change--- landscapeRight");


        }
        else if UIDevice.current.orientation == UIDeviceOrientation.portraitUpsideDown{
            orient = pjmedia_orient(PJMEDIA_ORIENT_ROTATE_270DEG.rawValue)
            print("Orientation change--- portraitUpsideDown");
            if let vc = topVC as? VideoVC {
                vc.cameraPreviewView.transform  = CGAffineTransform(rotationAngle: .pi)
            }
        }
        else if UIDevice.current.orientation == UIDeviceOrientation.portrait{
            orient = pjmedia_orient(PJMEDIA_ORIENT_ROTATE_90DEG.rawValue)
            print("Orientation change--- (portrait)");
            if let vc = topVC as? VideoVC {
                vc.cameraPreviewView.transform  = CGAffineTransform(rotationAngle: 0)

            }

        }
       

        
        let count = pjsua_vid_dev_count()
        if count > 0 {
            for i  in 0...count{
                pjsua_vid_dev_set_setting(pjmedia_vid_dev_index(i),
                                          PJMEDIA_VID_DEV_CAP_ORIENTATION, &orient, pj_bool_t(PJ_TRUE.rawValue));
            }
        }
        
    }
    
}

