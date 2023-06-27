//
//  DialPadRenderView.swift
//  PjsipDemo
//
//  Created by Apple on 30/05/23.
//

import UIKit

class DialPadRenderView: UIView {

    @IBOutlet var containerView: UIView!
    @IBOutlet var inputTextView : UIView!
    @IBOutlet var lblnumber : UILabel!
    
    var dialNumber : String = ""
    var dialedNumberBlock:((String) -> ())?
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        Bundle.main.loadNibNamed("DialPadRenderView", owner: self, options: nil)
        self.containerView.frame = frame
        containerView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        addSubview(self.containerView)
        self.inputTextView.layer.borderColor = UIColor.black.cgColor
        self.inputTextView.layer.borderWidth = 1.0
        
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func btnDialPadNumber_Click(_ sender : UIButton) {
        if sender.tag == 100 {
            dialNumber = String(dialNumber.dropLast())
        } else if sender.tag == 200 {
            dialedNumberBlock?(self.dialNumber)
        } else  {
            dialNumber =  "\(sender.tag)"
            dialedNumberBlock?("\(sender.tag)")
        }
        self.lblnumber.text = dialNumber
    }
}
