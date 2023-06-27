//
//  incomingCallView.swift
//  PjsipDemo
//
//  Created by Apple on 31/05/23.
//

import UIKit

class incomingCallView: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet var btnAccept : UIButton!
    @IBOutlet var btnHangUp : UIButton!
    
    var isReceiveCallBack:((Bool) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("IncomingCallView", owner: self, options: nil)
        self.containerView.frame = frame
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(self.containerView)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    @IBAction func btnHangup_Click(_ sender : UIButton) {
        isReceiveCallBack?(false)
    }
    
    @IBAction func btnReceive_Click(_ sender : UIButton) {
        isReceiveCallBack?(true)
    }
    
}
