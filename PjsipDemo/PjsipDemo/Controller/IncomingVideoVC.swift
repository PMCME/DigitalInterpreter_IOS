//
//  IncomingVideoVC.swift
//  PjsipDemo
//
//  Created by Apple on 25/05/23.
//

import UIKit

class IncomingVideoVC: UIViewController {

    @IBOutlet var btnReceive : UIButton!
    @IBOutlet var btnHangup : UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
    }
        
    @IBAction func btnReceive_Click(_ sender : UIButton) {
            self.dismiss(animated: true) {
            DispatchQueue.background(delay: 3.0, background: {
                receiveCall()
            }, completion: {
                // when background job finishes, wait 3 seconds and do something in main thread
            })
            /*DispatchQueue.global(qos: .userInitiated).async {

                DispatchQueue.main.async {
                var thread = Thread.current
                receiveCall()
            }
            }*/
        }

    }
    
    
    @IBAction func btnHangup_Click(_ sender : UIButton) {
        self.dismiss(animated: true, completion: nil)
        DispatchQueue.main.sync {
            hangup_allCall()
        }
      
    }
    
    
    

   
}
