//
//  keyboard.swift
//  3DGrapherSwift
//
//  Created by Vikram Mullick on 7/13/17.
//  Copyright © 2017 Vikram Mullick. All rights reserved.
//

import UIKit
import AudioToolbox

class keyboard : UIView, UIKeyInput {
    public var hasText: Bool
    
    var textField : UITextField?
    
    override init(frame: CGRect) {
        self.hasText = false
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.hasText = false
        super.init(coder: aDecoder)

    }
    
    override func awakeFromNib() {
        setupButtons()
    }
    
    func setupButtons()
    {
        for v in self.subviews
        {
            for v2 in v.subviews
            {
                for v3 in v2.subviews
                {
                    let button : UIButton = v3 as! UIButton
                    button.layer.borderWidth = 0.50
                    if button.tag < 2
                    {
                        button.setTitleColor(button.backgroundColor, for: .highlighted)
                    }
                    button.addTarget(self, action:#selector(keyboardTapStart), for: .touchDown)
                    button.addTarget(self, action:#selector(keyboardTapEnd), for: .touchUpInside)
                    button.addTarget(self, action:#selector(keyboardTapStart), for: .touchDragEnter)
                    button.addTarget(self, action:#selector(keyboardTapEnd), for: .touchDragExit)
                    button.addTarget(self, action:#selector(keyboardTap), for: .touchUpInside)
                    
                }
            }
        }

    }
    func keyboardTap(sender: UIButton!)
    {
        insertText((sender.titleLabel?.text)!)
      
    }
    func keyboardTapEnd(sender: UIButton!)
    {
        sender.layer.borderColor = UIColor.black.cgColor
        if sender.subviews.count > 0
        {
            if let keyLabel : AdaptiveLabel = sender.subviews[sender.subviews.count-1] as? AdaptiveLabel
            {
                keyLabel.removeFromSuperview()
            }
        }
        
    }
    func keyboardTapStart(sender: UIButton!)
    {
        if sender.tag < 2
        {
            sender.layer.borderColor = sender.backgroundColor?.cgColor
            let v = AdaptiveLabel(frame: CGRect(x: CGFloat(-10-10*sender.tag), y: -sender.frame.height-10, width: sender.frame.width+20, height: sender.frame.height+10.50))
            v.backgroundColor = sender.backgroundColor
            v.layer.borderWidth = 0.50
            v.clipsToBounds = true
            v.text = sender.titleLabel?.text
            v.textColor = sender.titleColor(for: .normal)
            v.textAlignment = .center
            sender.addSubview(v)
        }
        AudioServicesPlaySystemSound(1104)
    }

    
    func insertText(_ text: String) {
        textField?.text?.append(text)
        let numericExpression = "5-8"
        let expression = NSExpression(format: numericExpression)
        let result = expression.expressionValue(with: nil, context: nil) as! Double
        print(result)
    }
    
    func deleteBackward() {
       
    }
}
