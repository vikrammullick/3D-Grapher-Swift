//
//  keyboard.swift
//  3DGrapherSwift
//
//  Created by Vikram Mullick on 7/13/17.
//  Copyright © 2017 Vikram Mullick. All rights reserved.
//

import UIKit
import AudioToolbox
import SwiftTryCatch

class keyboard : UIView, UIKeyInput {
    public var hasText: Bool
    var expressionArray : [String]?
    
    var textField : UITextField?
    var viewController : ViewController?
    var draftNumericExression = String()
    var draftValue = Double()
    
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
        if (viewController?.chosenFunctionType)! < 3
        {
            if confirmField()
            {
                viewController?.equations[0] = draftNumericExression
                viewController?.functionType = (viewController?.chosenFunctionType)!
                viewController?.texts[0] = (textField?.text!)!
                viewController?.textArrays[0] = expressionArray!
                viewController?.eqnLabel.text = "\((viewController?.functionNames[(viewController?.functionType)!])! as String)=\((viewController?.texts[0])! as String)"
                viewController?.tapAway()
                viewController?.render()
            }
        }
        else if viewController?.chosenFunctionType == 3
        {
            var confirmations = [Bool]()
            for i in 0...6
            {
                confirmations.append((viewController?.fields[i].inputView as! keyboard).confirmField())
            }
            var confirm = true
            for c in confirmations
            {
                confirm = confirm && c
            }
            if confirm
            {
                var a = false
                if (viewController?.fields[3].inputView as! keyboard).draftValue < (viewController?.fields[4].inputView as! keyboard).draftValue
                {
                    viewController?.fields[3].backgroundColor = viewController?.view.tintColor.withAlphaComponent(0.4)
                    viewController?.fields[4].backgroundColor = viewController?.view.tintColor.withAlphaComponent(0.4)

                    a = true
                }
                else
                {
                    viewController?.fields[3].backgroundColor = UIColor.red.withAlphaComponent(0.5)
                    viewController?.fields[4].backgroundColor = UIColor.red.withAlphaComponent(0.5)

                }
                
                var b = false
                if (viewController?.fields[5].inputView as! keyboard).draftValue < (viewController?.fields[6].inputView as! keyboard).draftValue
                {
                    viewController?.fields[5].backgroundColor = viewController?.view.tintColor.withAlphaComponent(0.4)
                    viewController?.fields[6].backgroundColor = viewController?.view.tintColor.withAlphaComponent(0.4)
                    
                    b = true
                }
                else
                {
                    viewController?.fields[5].backgroundColor = UIColor.red.withAlphaComponent(0.5)
                    viewController?.fields[6].backgroundColor = UIColor.red.withAlphaComponent(0.5)
                }
                
                if a && b
                {
                    for i in 0...2
                    {
                        viewController?.equations[i] = (viewController?.fields[i].inputView as! keyboard).draftNumericExression
                    }
                    for i in 0...3
                    {
                        viewController?.domains[i] = (viewController?.fields[i+3].inputView as! keyboard).draftValue
                    }
          

                    for i in 0...6
                    {
                        viewController?.texts[i] = (viewController?.fields[i].text)!
                        viewController?.textArrays[i] = (viewController?.fields[i].inputView as! keyboard).expressionArray!
                    }
                    
                    viewController?.functionType = (viewController?.chosenFunctionType)!
                    viewController?.eqnLabel.text = "\((viewController?.functionNames[(viewController?.functionType)!])! as String)=<\((viewController?.texts[0])! as String),\((viewController?.texts[1])! as String),\((viewController?.texts[2])! as String)>"
                    viewController?.tapAway()
                    viewController?.render()
                }
            }
        }
        else if viewController?.chosenFunctionType == 4
        {
            var confirmations = [Bool]()
            for i in 0...4
            {
                confirmations.append((viewController?.fields[i].inputView as! keyboard).confirmField())
            }
            var confirm = true
            for c in confirmations
            {
                confirm = confirm && c
            }
            if confirm
            {
                var a = false
                if (viewController?.fields[3].inputView as! keyboard).draftValue < (viewController?.fields[4].inputView as! keyboard).draftValue
                {
                    viewController?.fields[3].backgroundColor = viewController?.view.tintColor.withAlphaComponent(0.4)
                    viewController?.fields[4].backgroundColor = viewController?.view.tintColor.withAlphaComponent(0.4)
                    
                    a = true
                }
                else
                {
                    viewController?.fields[3].backgroundColor = UIColor.red.withAlphaComponent(0.5)
                    viewController?.fields[4].backgroundColor = UIColor.red.withAlphaComponent(0.5)
                    
                }
                
                if a
                {
                    for i in 0...2
                    {
                        viewController?.equations[i] = (viewController?.fields[i].inputView as! keyboard).draftNumericExression
                    }
                    for i in 0...1
                    {
                        viewController?.domains[i] = (viewController?.fields[i+3].inputView as! keyboard).draftValue
                    }
                    for i in 0...4
                    {
                        viewController?.texts[i] = (viewController?.fields[i].text)!
                        viewController?.textArrays[i] = (viewController?.fields[i].inputView as! keyboard).expressionArray!
                    }
                    viewController?.functionType = (viewController?.chosenFunctionType)!
                    viewController?.eqnLabel.text =  "\((viewController?.functionNames[(viewController?.functionType)!])! as String)=<\((viewController?.texts[0])! as String),\((viewController?.texts[1])! as String),\((viewController?.texts[2])! as String)>"
                    viewController?.tapAway()
                    viewController?.render()
                }
            }
        }
        
    
    }
    func confirmField() -> Bool
    {
        var execute = true
        let numericExpression = convertString(self.textField?.text)
        var d = Double()
        
        SwiftTryCatch.tryRun({
            
            let expression = NSExpression(format: numericExpression.replacingOccurrences(of: "x", with: "0").replacingOccurrences(of: "y", with: "0").replacingOccurrences(of: "r", with: "0").replacingOccurrences(of: "θ", with: "0").replacingOccurrences(of: "Φ", with: "0").replacingOccurrences(of: "u", with: "0").replacingOccurrences(of: "v", with: "0").replacingOccurrences(of: "t", with: "0"))
            let answer = expression.expressionValue(with: nil, context: nil)
            if (self.textField?.tag)! > 2
            {
                d = answer as! Double
                if d.isNaN || d.isInfinite
                {
                    execute = false
                }
            }
            
        }, catchRun: { (error) in
            execute = false
        }, finallyRun: {})
        
        if execute
        {
            textField?.backgroundColor = viewController?.view.tintColor.withAlphaComponent(0.4)
            if (textField?.tag)! < 3
            {
                draftNumericExression = numericExpression
            }
            else
            {
                draftValue = d
            }
        }
        else
        {
            self.textField?.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        }
        
        return execute

    }
    func convertString(_ expression : String!) -> String
    {
        var numericExpression = expression!
        numericExpression = numericExpression.replacingOccurrences(of: "⋅", with: "*")
        numericExpression = numericExpression.replacingOccurrences(of: "^", with: "**")
        numericExpression = numericExpression.replacingOccurrences(of: "e", with: "(\(M_E))")
        numericExpression = numericExpression.replacingOccurrences(of: "π", with: "(\(M_PI))")
        
        while(numericExpression.contains("sin"))
        {
            let range = numericExpression.range(of: "sin")
            var temp = numericExpression.index(before: (range?.upperBound)!)
            var numPar : Int = 0
            repeat
            {
                temp = numericExpression.index(after: temp)
                
                let currentChar : Character = numericExpression[temp]
                if(currentChar=="(")
                {
                    numPar = numPar + 1
                }
                if(currentChar==")")
                {
                    numPar = numPar - 1
                }
            }while(numPar>0 && numericExpression.distance(from: numericExpression.startIndex, to: (temp))+1<numericExpression.characters.count)
            numericExpression.insert(contentsOf: ",'sn'".characters, at: temp)
            numericExpression.replaceSubrange(range!, with: "FUNCTION")
        }
        while(numericExpression.contains("cos"))
        {
            let range = numericExpression.range(of: "cos")
            var temp = numericExpression.index(before: (range?.upperBound)!)
            var numPar : Int = 0
            repeat
            {
                temp = numericExpression.index(after: temp)
                
                let currentChar : Character = numericExpression[temp]
                if(currentChar=="(")
                {
                    numPar = numPar + 1
                }
                if(currentChar==")")
                {
                    numPar = numPar - 1
                }
            }while(numPar>0 && numericExpression.distance(from: numericExpression.startIndex, to: (temp))+1<numericExpression.characters.count)
            numericExpression.insert(contentsOf: ",'cs'".characters, at: temp)
            numericExpression.replaceSubrange(range!, with: "FUNCTION")
        }
        while(numericExpression.contains("ln"))
        {
            let range = numericExpression.range(of: "ln")
            var temp = numericExpression.index(before: (range?.upperBound)!)
            var numPar : Int = 0
            repeat
            {
                temp = numericExpression.index(after: temp)
                
                let currentChar : Character = numericExpression[temp]
                if(currentChar=="(")
                {
                    numPar = numPar + 1
                }
                if(currentChar==")")
                {
                    numPar = numPar - 1
                }
            }while(numPar>0 && numericExpression.distance(from: numericExpression.startIndex, to: (temp))+1<numericExpression.characters.count)
            numericExpression.insert(contentsOf: ",'lg'".characters, at: temp)
            numericExpression.replaceSubrange(range!, with: "FUNCTION")
        }
        while(numericExpression.contains("√"))
        {
            let range = numericExpression.range(of: "√")
            var temp = numericExpression.index(before: (range?.upperBound)!)
            var numPar : Int = 0
            repeat
            {
                temp = numericExpression.index(after: temp)
                
                let currentChar : Character = numericExpression[temp]
                if(currentChar=="(")
                {
                    numPar = numPar + 1
                }
                if(currentChar==")")
                {
                    numPar = numPar - 1
                }
            }while(numPar>0 && numericExpression.distance(from: numericExpression.startIndex, to: (temp))+1<numericExpression.characters.count)
            numericExpression.insert(contentsOf: ",'sq'".characters, at: temp)
            numericExpression.replaceSubrange(range!, with: "FUNCTION")
        }
        return numericExpression
        
        
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
        else if string == "Φ"
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
