//
//  ViewController.swift
//  3DGrapherSwift
//
//  Created by Vikram Mullick on 6/21/17.
//  Copyright © 2017 Vikram Mullick. All rights reserved.
//

import UIKit
import AudioToolbox

class ViewController: UIViewController {
    
    let defaults = UserDefaults.standard

    var prerender = [[point3D]]()
    
    var postfixOperations = [String]()
    
    @IBOutlet weak var graphView: UIView!
    
    let graphTypes = ["z(x,y)","z(r,θ)","ρ(θ,Φ)","r(u,v)","r(t)"]
    
    let smallDouble : Double = 0.0000001
    let desiredPrecision : Double = 0.0005
    let pinchPrecision : Double = 0.001
    var precision : Double = Double()
    
    var xx = Double()
    var xy = Double()
    var yx = Double()
    var yy = Double()
    var zy = Double()
    
    var isAxesOn : Bool = true
    var axisLayers : [CAShapeLayer] = [CAShapeLayer]()
    var axisLabels : [UILabel] = [UILabel]()

    let colorButtonSelectView = UIView()
    var colorButtonSelectViewAdjustment = CGFloat()
    var colors = [[UIColor]]()
    var colorIndex = 0
    
    let height : CGFloat = 45
    let spacing : CGFloat = 5.7
    let topSpacing : CGFloat = 2
    let switchLength : CGFloat = 51
    let gridDensityButtonLength : CGFloat = 56
    let densityHeight : CGFloat = 34
    let switchHeight : CGFloat = 31
    let colorButtonLength : CGFloat = 31
    let colorButtonRadius : CGFloat = 4
    let colorButtonSelectViewWidth : CGFloat = 2
    let colorSpacing : CGFloat = 6
    let leftSpacing : CGFloat = 6
    var maxHeight = CGFloat()
    
    var xSide = Double()
    var ySide = Double()
    var max : Double = 6
    var a : Double = -2.35
    var n : Double = 40
    var s : Double = Double()
    //let al : Double = 7.89
    var b : Double = 0.8
    var lineWidth : CGFloat = 0.75
    var parametricLineWidth : CGFloat = 2
    let pi : Double = M_PI
    
    var functionType = 0
    var chosenFunctionType = Int()
    //cartesian = 0
    //cylindrical = 1
    //spherical = 2
    //parametric(u,v) = 3
    //parametric(t) = 4
    
    let minexpandButton = UIButton()
    var topView : UIView = UIView()
    var fieldView : UIView = UIView()
    let plusLayer = CAShapeLayer()
    var functionTypeButton = UIButton()
    let functionDropDown = UIView()
    let buttons : [UIButton] = [UIButton(frame: CGRect(x: 5, y: 35, width: 130, height: 40)),
                                UIButton(frame: CGRect(x: 5, y: 80, width: 130, height: 40)),
                                UIButton(frame: CGRect(x: 5, y: 125, width: 130, height: 40)),
                                UIButton(frame: CGRect(x: 5, y: 170, width: 130, height: 40))]
    
    var fields = [UITextField(),UITextField(),UITextField(),UITextField(),UITextField(),UITextField(),UITextField()]
    var labels = [UILabel(),UILabel(),UILabel(),UILabel(),UILabel()]
    let labelNames = [["z(x,y) = ","",""],
                      ["z(r,θ) = ","",""],
                      ["ρ(θ,Φ) = ","",""],
                      ["x(u,v) = ","y(u,v) = ","z(u,v) = "],
                      ["x(t) = ","y(t) = ","z(t) = "]]
    
    var autorotateButton = UIButton()
    var timer: Timer = Timer()
    var isRotating = false
    
    let menuButton = UIButton()
    let menuButtonBackView = UIView()
    var menuView = UIView()
    
    let axesLabelBackView = UIView()
    let gridDensityLabelBackView = UIView()
    let colorLabelBackView = UIView()
    
    let axesLabel = UILabel()
    let gridDensityLabel = UILabel()
    let colorLabel = UILabel()


    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let gDensity = defaults.object(forKey: "gridDensity") {
            self.n = gDensity as! Double
            if n == 20
            {
                lineWidth = 1.5
            }
            else if n == 40
            {
                lineWidth = 0.75
            }
            else
            {
                lineWidth = 0.5
            }
        }
        if let cIndex = defaults.object(forKey: "colorIndex") {
            self.colorIndex = cIndex as! Int
        }
        if let axesOn = defaults.object(forKey: "isAxesOn") {
            self.isAxesOn = axesOn as! Bool
        }
        
        precision = desiredPrecision
        chosenFunctionType = functionType
    
        colors = [[UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 1),.red,.white],
                  [.green,.red,.white],
                  [view.tintColor,.red,.white],
                  [UIColor(red: 84/255, green: 65/255, blue: 181/255, alpha: 1),.red,.white],
                  [UIColor(red: 255/255, green: 51/255, blue : 0/255, alpha: 1),view.tintColor,.white],
                  [.white,.red,.white]]
        
        view.backgroundColor = view.tintColor

        graphView.clipsToBounds = true
        graphView.layer.cornerRadius = 10
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        graphView.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        graphView.addGestureRecognizer(pinchGestureRecognizer)
        
        let v : [String] = ["ln","(","x","multiply","x","plus","y","multiply","y",")"]
        
        postfixConvert(v: v)
        
    }
    func changeColor(sender: UIButton!) {
        let indexDifference = sender.tag - colorIndex
        if indexDifference != 0
        {
           
            self.colorButtonSelectView.frame = CGRect(x: self.colorButtonSelectView.frame.origin.x+CGFloat(indexDifference)*self.colorButtonSelectViewAdjustment, y: self.colorButtonSelectView.frame.origin.y, width: self.colorButtonSelectView.frame.width, height: self.colorButtonSelectView.frame.height)
            
        
            self.colorIndex = sender.tag
            defaults.set(self.colorIndex, forKey: "colorIndex")

        }
        
        redraw()
    }
    override func viewDidAppear(_ animated: Bool)
    {
        setupTopView()
        setupMenu()
        setupAutorotateButton()
        
        xSide = Double(graphView.bounds.width)
        ySide = Double(graphView.bounds.height)
        
        render()
    }
    func setupMenu()
    {
        colorButtonSelectViewAdjustment = colorButtonLength + colorSpacing
        maxHeight = height*4+spacing*3+topSpacing
        
        menuView.backgroundColor = .clear
        menuView.clipsToBounds = true
        menuView.frame = CGRect(x: graphView.frame.origin.x+leftSpacing, y: view.frame.height-maxHeight-(6+leftSpacing), width: view.frame.width-2*(graphView.frame.origin.x+leftSpacing), height: maxHeight)
        view.addSubview(menuView)
        //menuView.isUserInteractionEnabled = false
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        menuView.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        menuView.addGestureRecognizer(pinchGestureRecognizer)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAway(_:)))
        menuView.addGestureRecognizer(tap)

        menuButtonBackView.frame = CGRect(x: 0, y: height*3+spacing*3+topSpacing, width: height, height: height)
        menuButtonBackView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        menuButtonBackView.layer.cornerRadius = menuButtonBackView.frame.height/2
        menuButtonBackView.layer.borderColor = UIColor(red: 44/255, green: 138/255, blue: 238/255, alpha: 1).cgColor
        menuView.addSubview(menuButtonBackView)
        
        menuButton.frame = menuButtonBackView.frame
        menuButton.backgroundColor = view.tintColor.withAlphaComponent(0.4)
        menuButton.layer.cornerRadius = menuButton.frame.height/2
        menuButton.addTarget(self, action:#selector(toggleMenu), for: .touchDown)
        menuView.addSubview(menuButton)
        
        axesLabel.clipsToBounds = true
        axesLabel.backgroundColor = view.tintColor.withAlphaComponent(0.4)
        axesLabel.text = "axes"
        axesLabelBackView.frame = CGRect(x: 0, y: height*2+spacing*2+topSpacing, width: widthOfLabelText(label: axesLabel)+15, height: height)
        axesLabelBackView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        axesLabelBackView.layer.cornerRadius = axesLabelBackView.frame.height/2
        axesLabelBackView.clipsToBounds = true
        menuView.addSubview(axesLabelBackView)
        axesLabel.textAlignment = .center
        axesLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        axesLabel.frame = axesLabelBackView.frame
        axesLabel.layer.cornerRadius = axesLabel.frame.height/2
        menuView.addSubview(axesLabel)
        
        let swtch = UISwitch()
        swtch.frame = CGRect(x: axesLabelBackView.frame.width+spacing, y: (height-switchHeight)/2, width: switchLength, height: switchHeight)
        if isAxesOn
        {
            swtch.setOn(true, animated: false)
        }
        swtch.addTarget(self, action: #selector(switchValueDidChange), for: .valueChanged)
        axesLabelBackView.addSubview(swtch)
        
        colorLabel.clipsToBounds = true
        colorLabel.backgroundColor = view.tintColor.withAlphaComponent(0.4)
        colorLabel.text = "color"
        colorLabelBackView.frame = CGRect(x: 0, y: height+spacing+topSpacing, width: widthOfLabelText(label: colorLabel)+15, height: height)
        colorLabelBackView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        colorLabelBackView.layer.cornerRadius = colorLabelBackView.frame.height/2
        colorLabelBackView.clipsToBounds = true
        menuView.addSubview(colorLabelBackView)
        colorLabel.textAlignment = .center
        colorLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        colorLabel.frame = colorLabelBackView.frame
        colorLabel.layer.cornerRadius = colorLabel.frame.height/2
        menuView.addSubview(colorLabel)
        
        colorButtonSelectView.backgroundColor = .clear
        colorButtonSelectView.layer.borderWidth = colorButtonSelectViewWidth
        colorButtonSelectView.layer.borderColor = UIColor(red: 44/255, green: 138/255, blue: 238/255, alpha: 1).cgColor
        colorButtonSelectView.frame = CGRect(x: colorLabelBackView.frame.width+colorSpacing+(colorSpacing+colorButtonLength)*CGFloat(colorIndex)-colorButtonRadius, y: (height-colorButtonLength)/2-colorButtonRadius, width: colorButtonRadius*2+colorButtonLength, height: colorButtonRadius*2+colorButtonLength)
        colorButtonSelectView.layer.cornerRadius = colorButtonSelectView.frame.height/2
        colorLabelBackView.addSubview(colorButtonSelectView)

        for i in 0..<colors.count
        {
            let button = UIButton(frame: CGRect(x: colorLabelBackView.frame.width+colorSpacing+(colorSpacing+colorButtonLength)*CGFloat(i), y: (height-colorButtonLength)/2, width: colorButtonLength, height: colorButtonLength))
            button.backgroundColor = colors[i][0]
            button.layer.cornerRadius = colorButtonLength/2
            button.tag = i
            button.addTarget(self, action:#selector(changeColor), for: .touchDown)
            colorLabelBackView.addSubview(button)
        }
        
        
        gridDensityLabel.clipsToBounds = true
        gridDensityLabel.backgroundColor = view.tintColor.withAlphaComponent(0.4)
        gridDensityLabel.text = "grid density"
        gridDensityLabelBackView.frame = CGRect(x: 0, y: topSpacing, width: widthOfLabelText(label: gridDensityLabel)+15, height: height)
        gridDensityLabelBackView.backgroundColor = UIColor.white.withAlphaComponent(0.7)
        gridDensityLabelBackView.layer.cornerRadius = gridDensityLabelBackView.frame.height/2
        gridDensityLabelBackView.clipsToBounds = true
        menuView.addSubview(gridDensityLabelBackView)
        gridDensityLabel.textAlignment = .center
        gridDensityLabel.textColor = UIColor.white.withAlphaComponent(0.8)
        gridDensityLabel.frame = gridDensityLabelBackView.frame
        gridDensityLabel.layer.cornerRadius = gridDensityLabel.frame.height/2
        menuView.addSubview(gridDensityLabel)
        
        for i in 0..<3
        {
            let button = UIButton(frame: CGRect(x: gridDensityLabelBackView.frame.width+spacing+(spacing+gridDensityButtonLength)*CGFloat(i), y: (height-densityHeight)/2, width: gridDensityButtonLength, height: densityHeight))
            button.tag = i
            button.layer.borderWidth = 2
            if i == 0
            {
                button.setTitle("low", for: .normal)
                if n == 20
                {
                    button.setTitleColor(.white, for: .normal)
                    button.layer.borderColor = UIColor.orange.cgColor
                    button.backgroundColor = .orange
                }
                else
                {
                    button.setTitleColor(.orange, for: .normal)
                    button.layer.borderColor = UIColor.orange.cgColor
                    button.backgroundColor = .clear
                }
            
            }
            else if i == 1
            {
                button.setTitle("normal", for: .normal)
                if n == 40
                {
                    button.setTitleColor(.white, for: .normal)
                    button.layer.borderColor = UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1).cgColor
                    button.backgroundColor = UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1)
                }
                else
                {
                    button.setTitleColor(UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1), for: .normal)
                    button.layer.borderColor = UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1).cgColor
                    button.backgroundColor = .clear
                }
                
            }
            else if i == 2
            {
                button.setTitle("high", for: .normal)
                if n == 60
                {
                    button.setTitleColor(.white, for: .normal)
                    button.layer.borderColor = UIColor.red.cgColor
                    button.backgroundColor = UIColor.red
                }
                else
                {
                    button.setTitleColor(.red, for: .normal)
                    button.layer.borderColor = UIColor.red.cgColor
                    button.backgroundColor = .clear
                }
                
            }
            button.titleLabel?.font = button.titleLabel?.font.withSize(12)
            button.addTarget(self, action:#selector(changeGridDensity), for: .touchDown)
            button.layer.cornerRadius = densityHeight/2
            gridDensityLabelBackView.addSubview(button)
        }
        
        for i in -1...1
        {
            let line = UIBezierPath()
            line.move(to: CGPoint(x: 10,y: 22.5+8.5*Double(i)))
            line.addLine(to: CGPoint(x: 35,y: 22.5+8.5*Double(i)))
            let lineLayer = CAShapeLayer()
            lineLayer.path = line.cgPath
            lineLayer.strokeColor = UIColor.white.withAlphaComponent(0.8).cgColor
            lineLayer.fillColor = UIColor.clear.cgColor
            lineLayer.lineWidth = 2
            menuButton.layer.addSublayer(lineLayer)
            
        }
        
        self.menuView.frame = CGRect(x: graphView.frame.origin.x+leftSpacing, y: self.view.frame.height-height-(6+leftSpacing), width: self.view.frame.width-2*(leftSpacing+graphView.frame.origin.x), height: height)
        for v in self.menuView.subviews
        {
            v.frame = CGRect(x: v.frame.origin.x, y: v.frame.origin.y-(3*height+3*spacing+topSpacing), width: v.frame.width, height: v.frame.height)
        }
        
        
    }
    func changeGridDensity(sender: UIButton!)
    {
        n = Double(20 + sender.tag*20)
        defaults.set(n, forKey: "gridDensity")
        if n == 20
        {
            lineWidth = 1.5
        }
        else if n == 40
        {
            lineWidth = 0.75
        }
        else
        {
            lineWidth = 0.5
        }
        for b in gridDensityLabelBackView.subviews
        {
            let button : UIButton = b as! UIButton
            if button.tag == 0
            {
                if self.n == 20
                {
                    button.setTitleColor(.white, for: .normal)
                    button.layer.borderColor = UIColor.orange.cgColor
                    button.backgroundColor = .orange
                }
                else
                {
                    button.setTitleColor(.orange, for: .normal)
                    button.layer.borderColor = UIColor.orange.cgColor
                    button.backgroundColor = .clear
                }
                
            }
            else if button.tag == 1
            {
                if self.n == 40
                {
                    button.setTitleColor(.white, for: .normal)
                    button.layer.borderColor = UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1).cgColor
                    button.backgroundColor = UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1)
                }
                else
                {
                    button.setTitleColor(UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1), for: .normal)
                    button.layer.borderColor = UIColor(red: 0/255, green: 128/255, blue: 0/255, alpha: 1).cgColor
                    button.backgroundColor = .clear
                }
                
            }
            else if button.tag == 2
            {
                if self.n == 60
                {
                    button.setTitleColor(.white, for: .normal)
                    button.layer.borderColor = UIColor.red.cgColor
                    button.backgroundColor = UIColor.red
                }
                else
                {
                    button.setTitleColor(.red, for: .normal)
                    button.layer.borderColor = UIColor.red.cgColor
                    button.backgroundColor = .clear
                }
                
            }

        }
        render()
        
    }
    func toggleMenu(sender: UIButton!)
    {
        if sender.backgroundColor == view.tintColor.withAlphaComponent(0.4)
        {
            UIView.animate(withDuration: 0.25, animations: {
                
                self.menuView.frame = CGRect(x: self.graphView.frame.origin.x+self.leftSpacing, y: self.view.frame.height-self.maxHeight-(6+self.leftSpacing), width: self.view.frame.width-2*(self.graphView.frame.origin.x+self.leftSpacing), height: self.maxHeight)
                for v in self.menuView.subviews
                {
                    v.frame = CGRect(x: v.frame.origin.x, y: v.frame.origin.y+(3*self.height+3*self.spacing+self.topSpacing), width: v.frame.width, height: v.frame.height)
                }
                
                
            }, completion:
                {
                    complete in
                    
                    UIView.animate(withDuration: 0.25, animations: {
                        
                        sender.backgroundColor = UIColor.red.withAlphaComponent(0.5)
                        
                        sender.layer.sublayers?.removeAll()

                        for i in stride(from: -1, through: 1, by: 2)
                        {
                            let line = UIBezierPath()
                            line.move(to: CGPoint(x: 13,y: 22.5+9.5*Double(i)))
                            line.addLine(to: CGPoint(x: 32,y: 22.5-9.5*Double(i)))
                            let lineLayer = CAShapeLayer()
                            lineLayer.path = line.cgPath
                            lineLayer.strokeColor = UIColor.white.withAlphaComponent(0.8).cgColor
                            lineLayer.fillColor = UIColor.clear.cgColor
                            lineLayer.lineWidth = 2
                            sender.layer.addSublayer(lineLayer)
                            
                        }
                        
                        self.axesLabelBackView.frame = CGRect(x: self.axesLabelBackView.frame.origin.x, y: self.axesLabelBackView.frame.origin.y, width: self.axesLabelBackView.frame.width+self.spacing*2+self.switchLength, height: self.axesLabelBackView.frame.height)
                        
                        self.colorLabelBackView.frame = CGRect(x: self.colorLabelBackView.frame.origin.x, y: self.colorLabelBackView.frame.origin.y, width: self.colorLabelBackView.frame.width+self.colorSpacing*CGFloat(self.colors.count+1)+self.colorButtonLength*CGFloat(self.colors.count), height: self.colorLabelBackView.frame.height)
                        
                        self.gridDensityLabelBackView.frame = CGRect(x: self.gridDensityLabelBackView.frame.origin.x, y: self.gridDensityLabelBackView.frame.origin.y, width: self.gridDensityLabelBackView.frame.width+self.spacing*4+self.gridDensityButtonLength*3, height: self.gridDensityLabelBackView.frame.height)
                        
                    }, completion: nil)
                    
                    
            })

        }
        else
        {
            hideMenuButton()
        }
    }
    func hideMenuButton()
    {
        UIView.animate(withDuration: 0.25, animations: {
            
            self.axesLabelBackView.frame = CGRect(x: 0, y: self.height*2+self.spacing*2+self.topSpacing, width: self.widthOfLabelText(label: self.axesLabel)+15, height: self.height)
            
            self.colorLabelBackView.frame = CGRect(x: 0, y: self.height+self.spacing+self.topSpacing, width: self.widthOfLabelText(label: self.colorLabel)+15, height: self.height)
            
            self.gridDensityLabelBackView.frame = CGRect(x: 0, y: self.topSpacing, width: self.widthOfLabelText(label: self.gridDensityLabel)+15, height: self.height)
            
            
        }, completion:
            {
                complete in
                
                UIView.animate(withDuration: 0.25, animations: {
                    
                    self.menuButton.backgroundColor = self.view.tintColor.withAlphaComponent(0.4)
                    
                    self.menuButton.layer.sublayers?.removeAll()
                    
                    for i in -1...1
                    {
                        let line = UIBezierPath()
                        line.move(to: CGPoint(x: 10,y: 22.5+8.5*Double(i)))
                        line.addLine(to: CGPoint(x: 35,y: 22.5+8.5*Double(i)))
                        let lineLayer = CAShapeLayer()
                        lineLayer.path = line.cgPath
                        lineLayer.strokeColor = UIColor.white.withAlphaComponent(0.8).cgColor
                        lineLayer.fillColor = UIColor.clear.cgColor
                        lineLayer.lineWidth = 2
                        self.menuButton.layer.addSublayer(lineLayer)
                        
                    }
                    self.menuView.frame = CGRect(x: self.graphView.frame.origin.x+self.leftSpacing, y: self.view.frame.height-self.height-(6+self.leftSpacing), width: self.view.frame.width-2*(self.leftSpacing+self.graphView.frame.origin.x), height: self.height)

                   
                    self.menuButtonBackView.frame = CGRect(x: 0, y: self.height*3+self.spacing*3+self.topSpacing-(3*self.height+3*self.spacing+self.topSpacing), width: self.height, height: self.height)
                    self.menuButton.frame = self.menuButtonBackView.frame
                    
                    self.axesLabelBackView.frame = CGRect(x: 0, y: self.height*2+self.spacing*2+self.topSpacing-(3*self.height+3*self.spacing+self.topSpacing), width: self.widthOfLabelText(label: self.axesLabel)+15, height: self.height)
                    self.axesLabel.frame = self.axesLabelBackView.frame
                    
                    self.colorLabelBackView.frame = CGRect(x: 0, y: self.height+self.spacing+self.topSpacing-(3*self.height+3*self.spacing+self.topSpacing), width: self.widthOfLabelText(label: self.colorLabel)+15, height: self.height)
                    self.colorLabel.frame = self.colorLabelBackView.frame
                    
                    self.gridDensityLabelBackView.frame = CGRect(x: 0, y: self.topSpacing-(3*self.height+3*self.spacing+self.topSpacing), width: self.widthOfLabelText(label: self.gridDensityLabel)+15, height: self.height)
                    self.gridDensityLabel.frame = self.gridDensityLabelBackView.frame
                   
                    
                }, completion: nil)
                
                
        })

        
    }
    func switchValueDidChange(sender: UISwitch!)
    {
        isAxesOn = sender.isOn
        defaults.set(isAxesOn, forKey: "isAxesOn")
        for label in axisLabels
        {
            label.isHidden = !isAxesOn
        }
        for layer in axisLayers
        {
            layer.isHidden = !isAxesOn
        }
        
    }
    func setupTopView()
    {
        let tap = UITapGestureRecognizer(target: self, action: #selector(tapAway(_:)))
        
        var adjustment : CGFloat = 0
        if chosenFunctionType > 2
        {
            adjustment = 81
        }

        topView = UIView(frame: CGRect(x: graphView.frame.origin.x, y: graphView.frame.origin.y, width: graphView.frame.width, height: 94+adjustment))
        topView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.8)
        topView.layer.cornerRadius = 10
        topView.clipsToBounds = true
        topView.addGestureRecognizer(tap)
        view.addSubview(topView)
        
        fieldView.frame = CGRect(x: 0, y: 40, width: graphView.frame.width, height: 29+adjustment)
        fieldView.clipsToBounds = true
        topView.addSubview(fieldView)

        
        
        for i in 0...2
        {
            fields[i].frame = CGRect(x: 80, y: 2+CGFloat(i)*27, width: graphView.frame.width-85, height: 25)
            fields[i].backgroundColor = view.tintColor.withAlphaComponent(0.4)
            fields[i].layer.cornerRadius = 5
            fields[i].textColor = .white
            let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 25))
            fields[i].leftViewMode = .always
            fields[i].leftView = paddingView
            fields[i].adjustsFontSizeToFitWidth = true
            fields[i].minimumFontSize = 2
            fields[i].autocorrectionType = .no
            fields[i].inputAssistantItem.leadingBarButtonGroups = []
            fields[i].inputAssistantItem.trailingBarButtonGroups = []
            fields[i].addTarget(self, action: #selector(tapAway), for: .editingDidBegin)
            fields[i].addTarget(self, action: #selector(tapAway), for: .editingChanged)
            fieldView.addSubview(fields[i])
            
            labels[i].frame = CGRect(x: 5, y: 2+CGFloat(i)*27, width: 70, height: 25)
            labels[i].textColor = .black
            labels[i].layer.borderColor = UIColor.black.cgColor
            labels[i].layer.borderWidth = 1
            labels[i].textAlignment = .center
            labels[i].layer.cornerRadius = 5
            fieldView.addSubview(labels[i])
        }
        setupKeyboardForFunctionFields()
        for i in 3...6
        {
            fields[i].frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            fields[i].backgroundColor = view.tintColor.withAlphaComponent(0.4)
            fields[i].layer.cornerRadius = 5
            fields[i].textColor = .white
            fields[i].textAlignment = .center
            fields[i].adjustsFontSizeToFitWidth = true
            fields[i].minimumFontSize = 2
            fields[i].autocorrectionType = .no
            fields[i].inputAssistantItem.leadingBarButtonGroups = []
            fields[i].inputAssistantItem.trailingBarButtonGroups = []
            fields[i].addTarget(self, action: #selector(tapAway), for: .editingDidBegin)
            fields[i].addTarget(self, action: #selector(tapAway), for: .editingChanged)
            fieldView.addSubview(fields[i])
        }
        setupKeyboardForDomainFields()
        for i in 3...4
        {
            labels[i].frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            labels[i].textColor = .black
            labels[i].layer.borderColor = UIColor.black.cgColor
            labels[i].layer.borderWidth = 1
            labels[i].textAlignment = .center
            labels[i].layer.cornerRadius = 5
            fieldView.addSubview(labels[i])
        }
        setupInputs()

        minexpandButton.frame = CGRect(x: 0, y: 69+adjustment, width: graphView.frame.width, height: 25)
        minexpandButton.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2)
        minexpandButton.addTarget(self, action:#selector(minOrExpand), for: .touchDown)
        
        let minus = UIBezierPath()
        minus.move(to: CGPoint(x: graphView.frame.width-24,y: 13))
        minus.addLine(to: CGPoint(x: graphView.frame.width-8,y: 13))
        let minusLayer = CAShapeLayer()
        minusLayer.path = minus.cgPath
        minusLayer.strokeColor = view.tintColor.cgColor
        minusLayer.fillColor = UIColor.clear.cgColor
        minusLayer.lineWidth = 1
        minexpandButton.layer.addSublayer(minusLayer)
        
        let plus = UIBezierPath()
        plus.move(to: CGPoint(x: graphView.frame.width-16,y: 4.5))
        plus.addLine(to: CGPoint(x: graphView.frame.width-16,y: 20.5))
        plusLayer.path = plus.cgPath
        plusLayer.strokeColor = view.tintColor.cgColor
        plusLayer.fillColor = UIColor.clear.cgColor
        plusLayer.lineWidth = 1
        plusLayer.isHidden = true
        minexpandButton.layer.addSublayer(plusLayer)
        
        topView.addSubview(minexpandButton)
        
        let titleView : UIView = UIView(frame: CGRect(x: 0, y: 0, width: graphView.frame.width, height: 40))
        titleView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.2)
        topView.addSubview(titleView)
        
        let iconView = UIImageView(image: UIImage(named: "icon.png"))
        iconView.frame = CGRect(x: 5, y: 5, width: 30, height: 30)
        iconView.clipsToBounds = true
        iconView.layer.cornerRadius = 5
        titleView.addSubview(iconView)
        
        let titleLabel : UILabel = UILabel(frame: CGRect(x: 40, y: 5, width: 105, height: 30))
        titleLabel.text = "3D GRAPHER"
        titleLabel.textColor = .darkGray
        titleView.addSubview(titleLabel)
        
        functionDropDown.frame = CGRect(x: graphView.frame.width-95+6, y: 5+20, width: 90, height: 0)
        functionDropDown.layer.cornerRadius = 5
        functionDropDown.backgroundColor = UIColor(red: 122/255, green: 172/255, blue: 223/255, alpha: 1)
        for button in buttons
        {
            button.layer.cornerRadius = 5
            button.layer.borderColor = UIColor.white.cgColor
            button.layer.borderWidth = 1
            button.isHidden = true
            button.setTitleColor(.white, for: .normal)
            button.setTitleColor(.lightGray, for: .highlighted)
            functionDropDown.addSubview(button)
        }
        editDropdownButtons()
        view.addSubview(functionDropDown)
        
        functionTypeButton = UIButton(frame: CGRect(x: graphView.frame.width-95+6, y: 5+20, width: 90, height: 30))
        functionTypeButton.setTitle("\(graphTypes[chosenFunctionType]) \u{2193}", for: .normal)
        functionTypeButton.setTitleColor(view.tintColor, for: .normal)
        functionTypeButton.clipsToBounds = true
        functionTypeButton.layer.cornerRadius = 5
        functionTypeButton.layer.borderWidth = 1
        functionTypeButton.layer.borderColor = UIColor(red: 122/255, green: 172/255, blue: 223/255, alpha: 1).cgColor
        functionTypeButton.backgroundColor = UIColor(red: 214/255, green: 214/255, blue: 214/255, alpha: 1)
        functionTypeButton.addTarget(self, action:#selector(functionTypeButtonPress), for: .touchDown)
        view.addSubview(functionTypeButton)
        
        hideWithoutAnimation()
        expand()

    }
    func setupKeyboardForFunctionFields()
    {
        for i in 0...2
        {
            var inputView = keyboard()
            switch chosenFunctionType
            {
            case 1:
                inputView = (UINib(nibName: "mathBoardPolar", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? keyboard)!
            case 2:
                inputView = (UINib(nibName: "mathBoardSpherical", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? keyboard)!
            case 3:
                inputView = (UINib(nibName: "mathBoardUV", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? keyboard)!
            case 4:
                inputView = (UINib(nibName: "mathBoardT", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? keyboard)!
            default:
                inputView = (UINib(nibName: "mathBoardCartesian", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? keyboard)!
            }
            
            inputView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
            fields[i].inputView = inputView
            inputView.textField = fields[i]
        }
    }
    func setupKeyboardForDomainFields()
    {

        for i in 3...6
        {
            let inputView = (UINib(nibName: "mathBoard", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as? keyboard)!
            inputView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 200)
            
            fields[i].inputView = inputView
            inputView.textField = fields[i]
        }
    }
    func setupInputs()
    {
        for field in fields
        {
            field.text = ""
        }
        for i in 0...2
        {
            let text = labelNames[chosenFunctionType][i]
            if text != ""
            {
                labels[i].text = text
            }
        }
        if chosenFunctionType == 3
        {
            let width = (graphView.frame.width-5*7-50*2)/4
            
            fields[3].frame = CGRect(x: 5, y: 83, width: width, height: 25)
            labels[3].frame = CGRect(x: 10+width, y: 83, width: 50, height: 25)
            labels[3].text = "< u <"
            fields[4].frame = CGRect(x: 65+width, y: 83, width: width, height: 25)
            
            fields[5].frame = CGRect(x: 70+width*2, y: 83, width: width, height: 25)
            labels[4].frame = CGRect(x: 75+width*3, y: 83, width: 50, height: 25)
            labels[4].text = "< v <"
            fields[6].frame = CGRect(x: 130+width*3, y: 83, width: width, height: 25)

        }
        else if chosenFunctionType == 4
        {
            let width = (graphView.frame.width-5*4-50)/2
            
            fields[3].frame = CGRect(x: 5, y: 83, width: width, height: 25)
            labels[3].frame = CGRect(x: 10+width, y: 83, width: 50, height: 25)
            labels[3].text = "< t <"
            fields[4].frame = CGRect(x: 65+width, y: 83, width: width, height: 25)
            
            fields[5].frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            labels[4].frame = CGRect(x: 0, y: 0, width: 0, height: 0)
            fields[6].frame = CGRect(x: 0, y: 0, width: 0, height: 0)
        }
    }
    func editDropdownButtons()
    {
        var temp = 0
        for i in 0..<graphTypes.count
        {
            if i != chosenFunctionType
            {
                buttons[temp].setTitle(graphTypes[i], for: .normal)
                buttons[temp].tag = i
                buttons[temp].addTarget(self, action:#selector(dropdownChosen), for: .touchUpInside)
                temp = temp + 1
            }
        }
    }
    func dropdownChosen(sender:UIButton!)
    {
        tapAway()
        chosenFunctionType = sender.tag
        setupKeyboardForFunctionFields()
        functionTypeButton.setTitle("\(graphTypes[chosenFunctionType]) \u{2193}", for: .normal)
        editDropdownButtons()
        setupInputs()
        expand()
        
    }
    func functionTypeButtonPress(sender:UIButton!)
    {
        if self.functionDropDown.frame.height == 0
        {
            UIView.animate(withDuration: 0.25, animations: {
                
                sender.frame = CGRect(x: self.graphView.frame.width-145+6, y: 5+20, width: 140, height: 30)
                self.functionDropDown.frame = CGRect(x: self.graphView.frame.width-145+6, y: 5+20, width: 140, height: 215)
                
            }, completion:
                {
                    complete in
                    for button in self.buttons
                    {
                        button.isHidden = false
                    }
                })
        }
        else
        {
            self.tapAway()
        }

    }
    func keyboardTap(sender: UIButton!)
    {
        functionType = (functionType + 1)%5
        render()
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
    @IBAction func tapAway(_ sender: Any? = nil)
    {
        if let _ = sender as? UITextField {

        }
        else {
            self.view.endEditing(true)
        }
       

        if menuButton.backgroundColor == UIColor.red.withAlphaComponent(0.5)
        {
            hideMenuButton()
        }
        UIView.animate(withDuration: 0.25, animations: {
            
            self.functionTypeButton.frame = CGRect(x: self.graphView.frame.width-95+6, y: 5+20, width: 90, height: 30)
            self.functionDropDown.frame = CGRect(x: self.graphView.frame.width-95+6, y: 5+20, width: 90, height: 0)
            for button in self.buttons
            {
                button.isHidden = true
            }
        }, completion: nil)
    }
    func minOrExpand(sender:UIButton? = nil) {
        
        tapAway()
        
        if self.plusLayer.isHidden
        {
            hide()
        }
        else
        {
            expand()
        }
            
        
    }
    func hide()
    {
        UIView.animate(withDuration: 0.25, animations: {
            
            self.plusLayer.isHidden = false
            
            self.minexpandButton.frame = CGRect(x: 0, y: 41, width: self.graphView.frame.width, height: 25)
            
            self.fieldView.frame = CGRect(x: 0, y: 40, width: self.graphView.frame.width, height: 0)
            
            self.topView.frame = CGRect(x: self.graphView.frame.origin.x, y: self.graphView.frame.origin.y, width: self.graphView.frame.width, height: 66)
            
        }, completion: nil)

    }
    func hideWithoutAnimation()
    {
        self.plusLayer.isHidden = false
        
        self.minexpandButton.frame = CGRect(x: 0, y: 41, width: self.graphView.frame.width, height: 25)
        
        self.fieldView.frame = CGRect(x: 0, y: 40, width: self.graphView.frame.width, height: 0)
        
        self.topView.frame = CGRect(x: self.graphView.frame.origin.x, y: self.graphView.frame.origin.y, width: self.graphView.frame.width, height: 66)
    }
    func expand()
    {
        UIView.animate(withDuration: 0.25, animations: {
            
            var adjustment : CGFloat = 81
            if self.chosenFunctionType > 2
            {
                adjustment = 0
            }
            
            self.plusLayer.isHidden = true
            
            self.minexpandButton.frame = CGRect(x: 0, y: 150-adjustment, width: self.graphView.frame.width, height: 25)
            
            self.fieldView.frame = CGRect(x: 0, y: 40, width: self.graphView.frame.width, height: 110-adjustment)
            
            self.topView.frame = CGRect(x: self.graphView.frame.origin.x, y: self.graphView.frame.origin.y, width: self.graphView.frame.width, height: 175-adjustment)
            
        }, completion: nil)

    }
    func setupAutorotateButton()
    {
        autorotateButton = UIButton(frame: CGRect(x: view.frame.width-54-graphView.frame.origin.x, y: view.frame.height-55, width: 50, height: 50))
        autorotateButton.setImage(UIImage(named: "rotate1.png")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate), for: .normal)
        autorotateButton.tintColor = UIColor.white.withAlphaComponent(0.7)
        autorotateButton.addTarget(self, action:#selector(toggleAutorotate), for: .touchDown)
        view.addSubview(autorotateButton)
        
    }
    func toggleAutorotate(_ sender: UIButton? = nil)
    {
        if !isRotating
        {
            autorotateButton.tintColor = UIColor(red: 109/255, green: 157/255, blue: 206/255, alpha: 1)
            isRotating = true
            timer = Timer.scheduledTimer(timeInterval: 0.001, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)

        }
        else
        {
            autorotateButton.tintColor = UIColor.white.withAlphaComponent(0.7)
            isRotating = false
            timer.invalidate()
        }

    }
    func runTimedCode()
    {
        a = a + 0.01
        redraw()
    }
    func redraw()
    {
        recalibrate()
        
        for curve in prerender
        {
            let aPath = UIBezierPath()
        
            if curve.count > 0
            {
                var currentx = (xx*curve[0].x + yx*curve[0].y)/max*xSide/2
                var currenty = (xy*curve[0].x + yy*curve[0].y + zy*curve[0].z)/max*xSide/2
                aPath.move(to: CGPoint(x: xSide/2+currentx, y: ySide/2-currenty))
                
                for i in 1..<curve.count
                {
                    currentx = (xx*curve[i].x + yx*curve[i].y)/max*xSide/2
                    currenty = (xy*curve[i].x + yy*curve[i].y + zy*curve[i].z)/max*xSide/2
                    aPath.addLine(to: CGPoint(x: xSide/2+currentx, y: ySide/2-currenty))
                    
                }
                
                let curveLayer = CAShapeLayer()
                curveLayer.path = aPath.cgPath
                curveLayer.strokeColor = colors[colorIndex][0].cgColor
                curveLayer.lineWidth = CGFloat(lineWidth)
                if functionType == 4
                {
                    curveLayer.lineWidth = parametricLineWidth
                }
                else
                {
                    curveLayer.lineWidth = lineWidth
                }
                curveLayer.position = CGPoint(x: 0, y: 0)
                curveLayer.fillColor = UIColor.clear.cgColor
                graphView.layer.addSublayer(curveLayer)
            }

        }
    }
    func render()
    {
        prerender.removeAll()

        recalibrate()
        
        resizeS()
        
        if functionType == 4
        {
            prerender.append([point3D]())
            parametrictGraph()
        }
        else
        {
            for temp in stride(from: 0, through: n, by: 1)
            {
                prerender.append([point3D]())
                whiteGraph(start: Double(temp)/(self.n+1), end: Double(temp+1)/(self.n+1))
                prerender.append([point3D]())
                greenGraph(start: Double(temp)/(self.n+1), end: Double(temp+1)/(self.n+1))
            }
        }
        redraw()
        
        
    }
    func recalibrate()
    {
        if let layers = graphView.layer.sublayers
        {
            for l in layers
            {
                l.removeFromSuperlayer()
            }
        }
        
        xxComp()
        xyComp()
        yxComp()
        yyComp()
        zyComp()
        
        drawAxis()
        
    }
    func drawAxis()
    {
        let x = UIBezierPath()
        x.move(to: CGPoint(x: xSide/2, y: ySide/2))
        x.addLine(to: CGPoint(x: xSide/max/2*max*xx+xSide/2, y: ySide/2-max*xy*xSide/max/2))
        let xLayer = CAShapeLayer()
        xLayer.path = x.cgPath
        xLayer.strokeColor = colors[colorIndex][1].cgColor
        xLayer.lineWidth = 3.0
        xLayer.position = CGPoint(x: 0, y: 0);
        xLayer.fillColor = UIColor.clear.cgColor
        graphView.layer.addSublayer(xLayer)
    
        let xLetter = UILabel()
        xLetter.frame = CGRect(x: xSide/max/2*max*xx+xSide/2-6, y: ySide/2-max*xy*xSide/max/2-6, width: 12, height: 12)
        xLetter.text = "x"
        xLetter.textAlignment = .center
        xLetter.backgroundColor = UIColor.clear
        xLetter.textColor = colors[colorIndex][2]
        graphView.addSubview(xLetter)
       
        
        let y = UIBezierPath()
        y.move(to: CGPoint(x: xSide/2, y: ySide/2))
        y.addLine(to: CGPoint(x: xSide/max/2*max*yx+xSide/2, y: ySide/2-max*yy*xSide/max/2))
        let yLayer = CAShapeLayer()
        yLayer.path = y.cgPath
        yLayer.strokeColor = colors[colorIndex][1].cgColor
        yLayer.lineWidth = 3.0
        yLayer.position = CGPoint(x: 0, y: 0);
        yLayer.fillColor = UIColor.clear.cgColor
        graphView.layer.addSublayer(yLayer)
        
        let yLetter = UILabel()
        yLetter.frame = CGRect(x: xSide/max/2*max*yx+xSide/2-6, y: ySide/2-max*yy*xSide/max/2-10, width: 12, height: 20)
        yLetter.text = "y"
        yLetter.backgroundColor = UIColor.clear
        yLetter.textColor = colors[colorIndex][2]
        graphView.addSubview(yLetter)
        
        let z = UIBezierPath()
        z.move(to: CGPoint(x: xSide/2, y: ySide/2))
        z.addLine(to: CGPoint(x: xSide/2, y: ySide/2-max*zy*xSide/max/2))
        let zLayer = CAShapeLayer()
        zLayer.path = z.cgPath
        zLayer.strokeColor = colors[colorIndex][1].cgColor
        zLayer.lineWidth = 3.0
        zLayer.position = CGPoint(x: 0, y: 0);
        zLayer.fillColor = UIColor.clear.cgColor
        graphView.layer.addSublayer(zLayer)
        
        let zLetter = UILabel()
        zLetter.frame = CGRect(x: xSide/2-6, y: ySide/2-max*zy*xSide/max/2-6, width: 12, height: 12)
        zLetter.text = "z"
        zLetter.backgroundColor = UIColor.clear
        zLetter.textColor = colors[colorIndex][2]
        graphView.addSubview(zLetter)
        
        axisLayers = [xLayer,yLayer,zLayer]
        axisLabels = [xLetter,yLetter,zLetter]
        
        if !isAxesOn {
            for label in axisLabels
            {
                label.isHidden = true
            }
            for layer in axisLayers
            {
                layer.isHidden = true
            }
        }
        
    }
    func green(t: Double)
    {
        var currentx : Double = 0
        var currenty : Double = 0
        
        var x : Double = Double()
        var y : Double = Double()
        var z : Double = Double()

        if functionType == 0
        {
            let g : Double = self.g(t: t, min: -1*s, range: 2*s)
            let h : Double = self.h(t: t, min: -1*s, range: 2*s)
            x = h
            y = g
            z = function(x: h, y: g, operations: postfixOperations)
        }
        else if functionType == 1
        {
            let h : Double = self.h(t: t, min: -1*s, range: 2*s)
            let g : Double = self.g(t: t, min: 0, range: 2*pi)
            let cosg : Double = cos(g)
            let sing : Double = sin(g)
            x = h*cosg
            y = h*sing
            z = function(x: h, y: g, operations: postfixOperations)
        }
        else if functionType == 2
        {
            let h : Double = self.h(t: t, min: 0, range: 2*pi)
            let g : Double = self.g(t: t, min: 0, range: pi)
            let cosg : Double = cos(g)
            let sing : Double = sin(g)
            let cosh : Double = cos(h)
            let sinh : Double = sin(h)
            let funcgh : Double = function(x: g, y: h, operations: postfixOperations)
            x = funcgh*cosh*sing
            y = funcgh*sinh*sing
            z = funcgh*cosg
        }
        else if functionType == 3
        {
            let g : Double = self.g(t: t, min: 0, range: 4*pi)
            let h : Double = self.h(t: t, min: 0, range: 2*pi)
            x = X(x: g, y: h)
            y = Y(x: g, y: h)
            z = Z(x: g, y: h)
        }
        
        currentx = xx*x+yx*y
        currenty = xy*x+yy*y+zy*z
        currentx = currentx/max*xSide/2
        currenty = currenty/max*xSide/2

        if !(currentx.isNaN || currentx.isInfinite || currenty.isNaN || currenty.isInfinite)
        {
            self.prerender[prerender.count-1].append(point3D(x: x, y: y, z: z))
        }
        else
        {
            prerender.append([point3D]())
        }
       
    }
    func white(t: Double)
    {
        var currentx : Double = 0
        var currenty : Double = 0
        
        var x : Double = Double()
        var y : Double = Double()
        var z : Double = Double()
    
        if functionType == 0
        {
            let g : Double = self.g(t: t, min: -1*s, range: 2*s)
            let h : Double = self.h(t: t, min: -1*s, range: 2*s)
            x = g
            y = h
            z = function(x: g, y: h, operations: postfixOperations)
        }
        else if functionType == 1
        {
            let g : Double = self.g(t: t, min: -1*s, range: 2*s)
            let h : Double = self.h(t: t, min: 0, range: 2*pi)
            let cosh : Double = cos(h)
            let sinh : Double = sin(h)
            x = g*cosh
            y = g*sinh
            z = function(x: g, y: h, operations: postfixOperations)
        }
        else if functionType == 2
        {
            let g : Double = self.g(t: t, min: 0, range: 2*pi)
            let h : Double = self.h(t: t, min: 0, range: pi)
            let cosh : Double = cos(h)
            let sinh : Double = sin(h)
            let cosg : Double = cos(g)
            let sing : Double = sin(g)
            let funchg : Double = function(x: h, y: g, operations: postfixOperations)
            x = funchg*cosg*sinh
            y = funchg*sing*sinh
            z = funchg*cosh
        }
        else if functionType == 3
        {
            let h : Double = self.h(t: t, min: 0, range: 4*pi)
            let g : Double = self.g(t: t, min: 0, range: 2*pi)
            x = X(x: h, y: g)
            y = Y(x: h, y: g)
            z = Z(x: h, y: g)
        }
        
        currentx = xx*x+yx*y
        currenty = xy*x+yy*y+zy*z
        currentx = currentx/max*xSide/2
        currenty = currenty/max*xSide/2
        
        if !(currentx.isNaN || currentx.isInfinite || currenty.isNaN || currenty.isInfinite)
        {
            self.prerender[prerender.count-1].append(point3D(x: x, y: y, z: z))
        }
        else
        {
            prerender.append([point3D]())
        }

    }
    func parametrictGraph()
    {
        let minT : Double = 0
        let maxT : Double = 5*pi
        let deltaT = (maxT-minT)*precision/2
        for t in stride(from: minT, to: maxT, by: deltaT)
        {
            let x = X(x: t, y: 0)
            let y = Y(x: t, y: 0)
            let z = Z(x: t, y: 0)
            
            self.prerender[prerender.count-1].append(point3D(x: x, y: y, z: z))
        }
    }
    func greenGraph(start: Double, end: Double)
    {
        for t in stride(from: start, through: end, by: precision)
        {
            green(t: t)
        }
        green(t: end-smallDouble)

    }
    func whiteGraph(start: Double, end: Double)
    {
        for t in stride(from: start, through: end, by: precision)
        {
            white(t: t)
        }
        white(t: end-smallDouble)

    }
    func function(x: Double, y: Double, operations: [String]) -> Double
    {
        return sin(x*x+y*y)
    }
    func X(x: Double, y: Double) -> Double
    {
        return (1.2+0.5*cos(y))*cos(x)
        //return x*cos(x)*(4+cos(x+y))
    }
    func Y(x: Double, y: Double) -> Double
    {
        return (1.2+0.5*cos(y))*sin(x)
        //return x*sin(x)*(4+cos(x+y))
    }
    func Z(x: Double, y: Double) -> Double
    {
        return 0.5*sin(y)+x/pi
        //return x*sin(x+y)
    }
    func handlePan(recognizer: UIPanGestureRecognizer)
    {
        tapAway()

        let velocityX : Double = Double(recognizer.velocity(in: graphView).x)
        let velocityY : Double = Double(recognizer.velocity(in: graphView).y)
        let speedScale : Double = 1.5
        a = a + velocityX * 0.001 * speedScale
        b = b + velocityY * 0.001 * speedScale
        if b > pi/2
        {
            b = pi/2
        }
        if b < 0
        {
            b = 0
        }
        redraw()
        
    }
    func resizeS()
    {
        if functionType == 0
        {
            s = max/sqrt(2)
        }
        else if functionType == 1
        {
            s = max
        }
        s = s*9/10
    }
    func handlePinch(recognizer: UIPinchGestureRecognizer)
    {
        tapAway()
        if recognizer.state == .ended
        {
            if functionType < 2
            {
                render()
            }
        }
        else
        {
            let velocity = Double(recognizer.velocity)
            if !(velocity.isNaN || velocity.isInfinite)
            {
                max = max - velocity
                if max > 250
                {
                    max = 250
                }
                if max < 1
                {
                    max = 1
                }
                redraw()
                
            }
        }
        
    }
    func xxComp()
    {
        xx = cos(a)
    }
    func xyComp()
    {
        xy = sin(a)*sin(b)
    }
    func yxComp()
    {
        yx = -sin(a)
    }
    func yyComp()
    {
        yy = cos(a)*sin(b)
    }
    func zyComp()
    {
        zy = cos(b)
    }
    func g(t : Double, min : Double, range : Double) -> Double
    {
        return range*floor(t*(n+1))/n+min
    }
    func h(t : Double, min : Double, range : Double) -> Double
    {
        return range*fmod(t*(n+1),1)+min
    }
    func postfixConvert(v : [String])
    {
        var stack = [String]()
        for s in v
        {
            if(s == "x" || s == "y" || s == "e" || s == "π")
            {
                postfixOperations.append(s)
            }
            else if(stack.count == 0 || stack.last == "(")
            {
                stack.append(s)
            }
            else if(s == "(")
            {
                stack.append(s)
            }
            else if(s == ")")
            {
                var cont = true
                while(cont && stack.count>0)
                {
                    let temp : String = stack.popLast()!
                    if(temp != "(")
                    {
                        postfixOperations.append(temp)
                    }
                    else
                    {
                        cont = false
                    }
                }
                
            }
            else if(getPrecedence(o: s) > getPrecedence(o: stack.last!))
            {
                stack.append(s)
            }
            else if(getPrecedence(o: s) == getPrecedence(o: stack.last!))
            {
                postfixOperations.append(stack.popLast()!)
                stack.append(s)
            }
            else if(getPrecedence(o: s) < getPrecedence(o: stack.last!))
            {
                postfixOperations.append(stack.popLast()!)
                if stack.count > 0
                {
                    while(getPrecedence(o: s) < getPrecedence(o: stack.last!))
                    {
                        postfixOperations.append(stack.popLast()!)
                        if stack.count == 0
                        {
                            break
                        }
                    }
                }
                
                stack.append(s)
            }
            
        }
        while(stack.count > 0)
        {
            postfixOperations.append(stack.popLast()!)
        }
    }
    func getPrecedence(o: String) -> Int
    {
        if(o == "minus" || o == "plus")
        {
            return 1
        }
        if(o == "multiply" || o == "divide")
        {
            return 2
        }
        if(o == "exponent")
        {
            return 3
        }
        if(o == "sin" || o == "cos" || o == "tan" || o == "ln")
        {
            return 4
        }
        return 0
    }
   
    func widthOfLabelText(label: UILabel) -> CGFloat
    {
        let text : String = label.text!
        let font : UIFont = label.font
        let fontAttributes = [NSFontAttributeName: font]
        let size = (text as NSString).size(attributes: fontAttributes)
        return size.width
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
struct point3D
{
    let x : Double
    let y : Double
    let z : Double
}
extension UIColor {
    
    func add(overlay: UIColor) -> UIColor {
        var bgR: CGFloat = 0
        var bgG: CGFloat = 0
        var bgB: CGFloat = 0
        var bgA: CGFloat = 0
        
        var fgR: CGFloat = 0
        var fgG: CGFloat = 0
        var fgB: CGFloat = 0
        var fgA: CGFloat = 0
        
        self.getRed(&bgR, green: &bgG, blue: &bgB, alpha: &bgA)
        overlay.getRed(&fgR, green: &fgG, blue: &fgB, alpha: &fgA)
        
        let r = fgA * fgR + (1 - fgA) * bgR
        let g = fgA * fgG + (1 - fgA) * bgG
        let b = fgA * fgB + (1 - fgA) * bgB
        
        return UIColor(red: r, green: g, blue: b, alpha: 1.0)
    }
}
