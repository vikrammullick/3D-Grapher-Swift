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
    var expressionArray : [String]?
    
    var textField : UITextField?
    var viewController : ViewController?
    
    var timer: Timer?
    
    override init(frame: CGRect) {
        self.hasText = false
        self.expressionArray = [String]()
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.hasText = false
        self.expressionArray = [String]()
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
                    if button.titleLabel?.text == "del"
                    {
                        button.addTarget(self, action:#selector(deleteStart), for: .touchDown)
                        button.addTarget(self, action:#selector(deleteEnd), for: .touchUpInside)
                        button.addTarget(self, action:#selector(deleteStart), for: .touchDragEnter)
                        button.addTarget(self, action:#selector(deleteEnd), for: .touchDragExit)
                        
                        button.addTarget(self, action:#selector(deleteBackward), for: .touchUpInside)
                    }
                    else if button.titleLabel?.text == "graph"
                    {
                        button.addTarget(self, action:#selector(graph), for: .touchUpInside)
                    }
                    else
                    {
                        button.addTarget(self, action:#selector(keyboardTap), for: .touchUpInside)
                    }
                    
                }
            }
        }

    }
    func keyboardTap(sender: UIButton!)
    {
        let textToEnter : String = getString((sender.titleLabel?.text)!)
        if isFunction(textToEnter) || isVariable(textToEnter)
        {
            if isNumber(getLast()) || isVariable(getLast()) || getLast() == ")"
            {
                insertText("⋅")
            }
            else if isDecimal(getLast())
            {
                insertText("0")
                insertText("⋅")
            }
        }
        else if isNumber(textToEnter)
        {
            if isVariable(getLast()) || getLast() == ")"
            {
                insertText("⋅")
            }
        }
        else
        {
            if isDecimal(getLast())
            {
                insertText("0")
            }
        }
        
        insertText(textToEnter)
        
      
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
    func graph()
    {
        //viewController?.render()
        
        /*if (textField?.tag)! > 2
        {
            let numericExpression = textField?.text
            let expression = NSExpression(format: numericExpression!)
            let result = expression.expressionValue(with: nil, context: nil) as! Double
            print(result)
        }*/
        
        
        do
        {
            let numericExpression = textField?.text
            let expression = NSExpression(format: numericExpression!)
            try let result = expression.expressionValue(with: nil, context: nil)

        }
        catch
        {
            print("error")
        }
        
    
    }
    func insertText(_ text: String) {
        hasText = true
        textField?.text?.append(text)
        expressionArray?.append(text)
        
    }
    func deleteStart()
    {
        timer = Timer.scheduledTimer(timeInterval: 0.15, target: self, selector: #selector(UIKeyInput.deleteBackward), userInfo: nil, repeats: true)
    }
    func deleteEnd()
    {
        timer?.invalidate()
        timer = nil
    }
    func deleteBackward() {
        if hasText
        {
            let lastVariable = expressionArray?.removeLast()
            hasText = expressionArray?.count != 0
            let index = textField?.text?.index((textField?.text?.startIndex)!, offsetBy: (textField?.text?.characters.count)! - (lastVariable?.characters.count)!)
            textField?.text? = (textField?.text?.substring(to: index!))!
        }

        
    }
    func getLast() -> String
    {
        if (expressionArray?.count)! > 0
        {
            return expressionArray![expressionArray!.count - 1]
        }
        return ""
    }
    func isOperator(_ string : String) -> Bool
    {
        if string == "⋅"
        {
            return true
        }
        else if string == "/"
        {
            return true
        }
        else if string == "+"
        {
            return true
        }
        else if string == "_"
        {
            return true
        }
        else if string == "^"
        {
            return true
        }
        return false
    }
    func isFunction(_ string : String) -> Bool
    {
        if string == "cos("
        {
            return true
        }
        else if string == "sin("
        {
            return true
        }
        else if string == "ln("
        {
            return true
        }
        else if string == "√("
        {
            return true
        }
        else if string == "("
        {
            return true
        }
        return false
    }
    func isDecimal(_ string : String) -> Bool
    {
        return string == "."
    }
    func isNumber(_ string : String) -> Bool
    {
        for i in 0...9
        {
            if string == "\(i)"
            {
                return true
            }
        }
        return false
    }
    func isVariable(_ string : String) -> Bool
    {
        if string == "x"
        {
            return true
        }
        else if string == "y"
        {
            return true
        }
        else if string == "t"
        {
            return true
        }
        else if string == "u"
        {
            return true
        }
        else if string == "v"
        {
            return true
        }
        else if string == "r"
        {
            return true
        }
        else if string == "θ"
        {
            return true
        }
        else if string == "φ"
        {
            return true
        }
        else if string == "π"
        {
            return true
        }
        else if string == "e"
        {
            return true
        }
        return false

    }
    func getString(_ string : String) -> String
    {
        if string == "×"
        {
            return "⋅"
        }
        else if string == "÷"
        {
            return "/"
        }
        else if string == "ln" || string == "cos" || string == "sin" || string == "√"
        {
            return "\(string)("
        }
        return string
    }
    
}
