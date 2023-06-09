/*
 * Copyright (C) 2012-2012 Teluu Inc. (http://www.teluu.com)
 * Contributed by Emre Tufekci (github.com/emretufekci)
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

import UIKit

func topMostController() -> UIViewController {
    var topController: UIViewController = (UIApplication.shared.windows.first { $0.isKeyWindow }?.rootViewController!)!
        while (topController.presentedViewController != nil) {
            topController = topController.presentedViewController!
        }
        return topController
    }


    
  //MARK: Display Video view
func displayVideoView(_ video : UIView? , _ localVideo : UIView?) {
        DispatchQueue.main.async () {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(withIdentifier: "viewController")
            let topVC = topMostController()
            if !topVC.isKind(of: VideoVC.self) {
                let vcToPresent = vc.storyboard!.instantiateViewController(withIdentifier: "VideoVC") as! VideoVC
                print(video)
                if  video != nil {
                    vcToPresent.customVideo = video!
                }
                if  localVideo != nil {
                  vcToPresent.localVideo =  localVideo!
                }
                vcToPresent.modalPresentationStyle = .fullScreen
              //  vcToPresent.incomingCallId = CPPWrapper().incomingCallInfoWrapper()
                topVC.present(vcToPresent, animated: true, completion: nil)
            } else  {
                if let vc = topVC as? VideoVC{
                    if  video != nil {
                        vc.customVideo = video!
                    }
                    if  localVideo != nil {
                        vc.localVideo =  localVideo!
                    }
                }
            }
            
        }
     }

//MARK: Dismiss Video View controller
    func dismissVideoViewController() {
        DispatchQueue.main.async () {
            let topVC = topMostController()
            topVC.dismiss(animated: true, completion: nil)
        }
    }
    
//MARK: Open video View controller

func openIncomingView() {
    DispatchQueue.main.async () {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "viewController")
        let topVC = topMostController()
        if !topVC.isKind(of: IncomingVideoVC.self) {
            let vcToPresent = vc.storyboard!.instantiateViewController(withIdentifier: "IncomingVideoVC") as! IncomingVideoVC
            topVC.present(vcToPresent, animated: true, completion: nil)
        }
    }
}
