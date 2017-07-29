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
    
    var welcomeView = UIView()
    var showWelcome = true
    
    var equations = [String(),String(),String()]
    var domains = [Double(),Double(),Double(),Double()]
    var texts = [String(),String(),String(),String(),String(),String(),String()]
    var textArrays = [[String](),[String](),[String](),[String](),[String](),[String](),[String]()]
    
    let defaults = UserDefaults.standard

    var prerender = [[point3D]]()
    
    @IBOutlet weak var graphView: UIView!
    
    let graphTypes = ["z(x,y)","z(r,θ)","ρ(θ,Φ)","r(u,v)","r(t)"]
    
    let smallDouble : Double = 0.0000000000001
    let desiredPrecision : Double = 0.0005
    var precision : Double = Double()
    
    var xx = Double()
    var xy = Double()
    var yx = Double()
    var yy = Double()
    var zx = Double()
    var zy = Double()
    
    var isAxesOn : Bool = true
    var axisLayers : [CAShapeLayer] = [CAShapeLayer]()
    var axisLabels : [UILabel] = [UILabel]()

    let colorButtonSelectView = UIView()
    var colorButtonSelectViewAdjustment = CGFloat()
    var colors = [[UIColor]]()
    var colorIndex = 1
    
    let height : CGFloat = 47
    let spacing : CGFloat = 5.7
    let topSpacing : CGFloat = 2
    let switchLength : CGFloat = 51
    let gridDensityButtonLength : CGFloat = 56
    let densityHeight : CGFloat = 36
    let switchHeight : CGFloat = 31
    let colorButtonLength : CGFloat = 33
    let colorButtonRadius : CGFloat = 4
    let colorButtonSelectViewWidth : CGFloat = 2
    let colorSpacing : CGFloat = 6
    let leftSpacing : CGFloat = 6
    var maxHeight = CGFloat()
    
    var xSide = Double()
    var ySide = Double()
    var max : Double = 6
    var a : Double = M_PI_4-M_PI
    var n : Double = 40
    var s : Double = Double()
    var b : Double = M_PI_4
    var c : Double = 0
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
    let axisLengthLabel = UILabel()
    let eqnLabel = UILabel()
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
    let functionNames = ["z(x,y)","z(r,θ)","ρ(θ,Φ)","r(u,v)","r(t)"]
    
    var velocityTimer = Timer()
    var endingVelocityX = Double()
    var endingVelocityPositive = Bool()
    
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
        if let welcome = defaults.object(forKey: "showWelcome"){
            self.showWelcome = welcome as! Bool
        }
        axisLengthLabel.isHidden = !isAxesOn
        
        precision = desiredPrecision
        chosenFunctionType = functionType
    
        colors = [[UIColor(red: 255/255, green: 153/255, blue: 51/255, alpha: 1),.red,.white],
                  [UIColor(red: 0/255, green: 204/255, blue: 0/255, alpha: 1),.red,.white],
                  [view.tintColor,.red,.white],
                  [UIColor(red: 151/255, green: 85/255, blue: 183/255, alpha: 1),.red,.white],
                  [UIColor(red: 255/255, green: 51/255, blue : 0/255, alpha: 1),view.tintColor,.white],
                  [.white,.red,.white]]
        
        view.backgroundColor = view.tintColor

        graphView.clipsToBounds = true
        graphView.layer.cornerRadius = 10
        
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        graphView.addGestureRecognizer(panGestureRecognizer)
        
        let pinchGestureRecognizer = UIPinchGestureRecognizer(target: self, action: #selector(handlePinch))
        graphView.addGestureRecognizer(pinchGestureRecognizer)
        
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
        self.xSide = Double(self.graphView.bounds.width)
        self.ySide = Double(self.graphView.bounds.height)
        self.setupTopView()
        self.setupMenu()
        self.setupAutorotateButton()
        self.render()

        if showWelcome
        {
            runWelcome()
        }
   
        
    }
    func runWelcome()
    {
        let baseWelcomeView = UIView(frame: view.frame)
        view.addSubview(baseWelcomeView)
        
        welcomeView = UIView(frame: CGRect(x: self.graphView.frame.origin.x+self.graphView.frame.width/2-150, y: self.graphView.frame.origin.y+self.graphView.frame.height/2-200, width: 300, height: 400))
        welcomeView.backgroundColor = .white
        welcomeView.layer.cornerRadius = 10
        welcomeView.clipsToBounds = true
        baseWelcomeView.addSubview(welcomeView)
        
        let welcomeLabel = UILabel(frame: CGRect(x: 0, y: 0, width: welcomeView.frame.width, height: height))
        welcomeLabel.textAlignment = .center
        welcomeLabel.textColor = .darkGray
        welcomeLabel.backgroundColor = .white
        welcomeLabel.font = welcomeLabel.font.withSize(23)
        welcomeLabel.text = "Welcome!"
        welcomeView.addSubview(welcomeLabel)

        let continueButton = UIButton(frame: CGRect(x: 0, y: welcomeView.frame.height-height, width: welcomeView.frame.width, height: height))
        continueButton.backgroundColor = .white
        continueButton.setTitle("Continue to 3D Grapher", for: .normal)
        continueButton.setTitleColor(view.tintColor, for: .normal)
        continueButton.setTitleColor(.darkGray, for: .highlighted)
        continueButton.addTarget(self, action: #selector(closeWelcome), for: .touchUpInside)
        welcomeView.addSubview(continueButton)
        
        let welcomeText = UITextView(frame: CGRect(x: 10, y: height, width: 280, height: 400-height*2))
        welcomeText.backgroundColor = UIColor(red: 245/255, green: 245/255, blue: 245/255, alpha: 1)
        welcomeText.isUserInteractionEnabled = false
        welcomeText.text = "Thank you for downloading 3D Grapher!\n\n3D Grapher is available free of charge, but if you would like to show your support I would appreciate if you could leave a rating on the App Store and share 3D Grapher with your friends.\n\nI hope you enjoy the app! 😄"
        welcomeText.font = UIFont.systemFont(ofSize: 20, weight: UIFontWeightThin)
        welcomeView.addSubview(welcomeText)

        welcomeView.frame = CGRect(x: self.graphView.frame.origin.x+self.graphView.frame.width/2, y: self.graphView.frame.origin.y+self.graphView.frame.height/2, width: 0, height: 0)

        UIView.animate(withDuration: 1, animations: {
            
            self.welcomeView.frame = CGRect(x: self.graphView.frame.origin.x+self.graphView.frame.width/2-150, y: self.graphView.frame.origin.y+self.graphView.frame.height/2-200, width: 300, height: 400)

        })
        
    }
    func closeWelcome()
    {
        UIView.animate(withDuration: 1, animations: {
            
            self.welcomeView.frame = CGRect(x: self.graphView.frame.origin.x+self.graphView.frame.width/2, y: self.graphView.frame.origin.y+self.graphView.frame.height/2, width: 0, height: 0)
            
        }, completion:
            {
                complete in
                self.welcomeView.superview?.removeFromSuperview()
                self.toggleMenu(sender: self.menuButton)
                self.functionTypeButtonPress(sender: self.functionTypeButton)
                self.defaults.set(false, forKey: "showWelcome")
            })
    }
    func setupMenu()
    {
        colorButtonSelectViewAdjustment = colorButtonLength + colorSpacing
        maxHeight = height*4+spacing*3+topSpacing
        
        menuView.backgroundColor = .clear
        menuView.clipsToBounds = true
        menuView.frame = CGRect(x: graphView.frame.origin.x+leftSpacing, y: view.frame.height-maxHeight-(6+leftSpacing), width: view.frame.width-2*(graphView.frame.origin.x+leftSpacing), height: maxHeight)
        view.addSubview(menuView)

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
            line.move(to: CGPoint(x: 10,y: 23.5+9.5*Double(i)))
            line.addLine(to: CGPoint(x: 37,y: 23.5+9.5*Double(i)))
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
                            line.move(to: CGPoint(x: 13,y: 23.5+10.5*Double(i)))
                            line.addLine(to: CGPoint(x: 34,y: 23.5-10.5*Double(i)))
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
                        line.move(to: CGPoint(x: 10,y: 23.5+9.5*Double(i)))
                        line.addLine(to: CGPoint(x: 37,y: 23.5+9.5*Double(i)))
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
        axisLengthLabel.isHidden = !isAxesOn
        
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
            fields[i].readonly = true
            fields[i].tag = i
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
            fields[i].readonly = true
            fields[i].tag = i
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
        minexpandButton.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
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
        titleView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 0.3)
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
        
        eqnLabel.frame = CGRect(x: 10, y: 3, width: minexpandButton.frame.width-38, height: minexpandButton.frame.height-6)
        eqnLabel.font = eqnLabel.font.withSize(15)
        eqnLabel.adjustsFontSizeToFitWidth = true
        eqnLabel.isHidden = true
        eqnLabel.textColor = .darkGray
        minexpandButton.addSubview(eqnLabel)
        
        axisLengthLabel.frame = CGRect(x: topView.frame.origin.x+5, y: topView.frame.origin.y+topView.frame.height+5, width: topView.frame.width-10, height: 20)
        axisLengthLabel.adjustsFontSizeToFitWidth = true
        axisLengthLabel.textAlignment = .right
        axisLengthLabel.textColor = .white
        axisLengthLabel.font = axisLengthLabel.font.withSize(15)
        axisLengthLabel.text = "AXIS LENGTH: \(String(format: "%.1f", max))"
        view.addSubview(axisLengthLabel)
        
        functionDropDown.frame = CGRect(x: graphView.frame.width-95+6, y: 5+20, width: 90, height: 0)
        functionDropDown.layer.cornerRadius = 5
        functionDropDown.backgroundColor = view.tintColor
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
        functionTypeButton.layer.borderColor = view.tintColor.cgColor
        functionTypeButton.backgroundColor = UIColor(red: 219/255, green: 219/255, blue: 219/255, alpha: 1)
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
            inputView.viewController = self
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
            inputView.viewController = self
            inputView.textField = fields[i]
        }
    }
    func setupInputs()
    {
        if chosenFunctionType == functionType
        {
            for i in 0...6
            {
                fields[i].text = texts[i]
                (fields[i].inputView as! keyboard).expressionArray = textArrays[i]
                (fields[i].inputView as! keyboard).hasText = (fields[i].text?.characters.count)! > 0

            }
        }
        else
        {
            for field in fields
            {
                field.text = ""
                (field.inputView as! keyboard).expressionArray = []
                (field.inputView as! keyboard).hasText = false
            }
        }
        for field in fields
        {
            field.backgroundColor = view.tintColor.withAlphaComponent(0.4)
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
            
            self.axisLengthLabel.frame = CGRect(x: self.topView.frame.origin.x+5, y: self.topView.frame.origin.y+self.topView.frame.height+5, width: self.topView.frame.width-10, height: 20)

            
        }, completion:{
                complete in
                self.eqnLabel.isHidden = false
            })

    }
    func hideWithoutAnimation()
    {
        self.plusLayer.isHidden = false
        
        self.minexpandButton.frame = CGRect(x: 0, y: 41, width: self.graphView.frame.width, height: 25)
        
        self.fieldView.frame = CGRect(x: 0, y: 40, width: self.graphView.frame.width, height: 0)
        
        self.topView.frame = CGRect(x: self.graphView.frame.origin.x, y: self.graphView.frame.origin.y, width: self.graphView.frame.width, height: 66)
        
        self.axisLengthLabel.frame = CGRect(x: self.topView.frame.origin.x+5, y: self.topView.frame.origin.y+self.topView.frame.height+5, width: self.topView.frame.width-10, height: 20)

        self.eqnLabel.isHidden = false
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
            
            self.axisLengthLabel.frame = CGRect(x: self.topView.frame.origin.x+5, y: self.topView.frame.origin.y+self.topView.frame.height+5, width: self.topView.frame.width-10, height: 20)

            self.eqnLabel.isHidden = true

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
            autorotateButton.tintColor = view.tintColor
            isRotating = true
            velocityTimer.invalidate()
            timer = Timer.scheduledTimer(timeInterval: 0.01, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)

        }
        else
        {
            autorotateButton.tintColor = UIColor.white.withAlphaComponent(0.7)
            isRotating = false
            timer.invalidate()
        }

    }
    func runEndVelocityCode()
    {
        if endingVelocityPositive
        {
            if endingVelocityX > 0.01
            {
                a = a + endingVelocityX/10
                redraw()
                endingVelocityX = endingVelocityX*0.975
            }
            else
            {
                velocityTimer.invalidate()
            }
        }
        else if !endingVelocityPositive
        {
            if endingVelocityX < -0.01
            {
                a = a + endingVelocityX/10
                redraw()
                endingVelocityX = endingVelocityX*0.975
            }
            else
            {
                velocityTimer.invalidate()
            }
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
                var currentx = (xx*curve[0].x + yx*curve[0].y + zx*curve[0].z)/max*xSide/2
                var currenty = (xy*curve[0].x + yy*curve[0].y + zy*curve[0].z)/max*xSide/2
                aPath.move(to: CGPoint(x: xSide/2+currentx, y: ySide/2-currenty))
                
                for i in 1..<curve.count
                {
                    currentx = (xx*curve[i].x + yx*curve[i].y + zx*curve[i].z)/max*xSide/2
                    currenty = (xy*curve[i].x + yy*curve[i].y + zy*curve[i].z)/max*xSide/2
                    aPath.addLine(to: CGPoint(x: xSide/2+currentx, y: ySide/2-currenty))
                    
                }
                
                let curveLayer = CAShapeLayer()
                curveLayer.path = aPath.cgPath
                curveLayer.strokeColor = colors[colorIndex][0].withAlphaComponent(0.85).cgColor
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

        resizeS()
        
        recalibrate()
        
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
        zxComp()
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
        xLayer.lineWidth = 1.0
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
        yLayer.lineWidth = 1.0
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
        z.addLine(to: CGPoint(x: xSide/max/2*max*zx+xSide/2, y: ySide/2-max*zy*xSide/max/2))
        let zLayer = CAShapeLayer()
        zLayer.path = z.cgPath
        zLayer.strokeColor = colors[colorIndex][1].cgColor
        zLayer.lineWidth = 1.0
        zLayer.position = CGPoint(x: 0, y: 0);
        zLayer.fillColor = UIColor.clear.cgColor
        graphView.layer.addSublayer(zLayer)
        
        let zLetter = UILabel()
        zLetter.frame = CGRect(x: xSide/max/2*max*zx+xSide/2-6, y: ySide/2-max*zy*xSide/max/2-6, width: 12, height: 12)
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
        var x : Double = Double()
        var y : Double = Double()
        var z : Double = Double()

        if functionType == 0
        {
            let g : Double = self.g(t: t, min: -1*s, range: 2*s)
            let h : Double = self.h(t: t, min: -1*s, range: 2*s)
            x = h
            y = g
            z = function(x: h, y: g)
        }
        else if functionType == 1
        {
            let h : Double = self.h(t: t, min: -1*s, range: 2*s)
            let g : Double = self.g(t: t, min: 0, range: 2*pi)
            let cosg : Double = cos(g)
            let sing : Double = sin(g)
            x = h*cosg
            y = h*sing
            z = function(x: h, y: g)
        }
        else if functionType == 2
        {
            let h : Double = self.h(t: t, min: 0, range: 2*pi)
            let g : Double = self.g(t: t, min: 0, range: pi)
            let cosg : Double = cos(g)
            let sing : Double = sin(g)
            let cosh : Double = cos(h)
            let sinh : Double = sin(h)
            let funcgh : Double = function(x: g, y: h)
            x = funcgh*cosh*sing
            y = funcgh*sinh*sing
            z = funcgh*cosg
        }
        else if functionType == 3
        {
            let g : Double = self.g(t: t, min: domains[0], range: domains[1]-domains[0])
            let h : Double = self.h(t: t, min: domains[2], range: domains[3]-domains[2])
            x = X(x: g, y: h)
            y = Y(x: g, y: h)
            z = Z(x: g, y: h)
        }
        
        if !(x.isNaN || x.isInfinite || y.isNaN || y.isInfinite || z.isNaN || z.isInfinite)
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
        var x : Double = Double()
        var y : Double = Double()
        var z : Double = Double()
    
        if functionType == 0
        {
            let g : Double = self.g(t: t, min: -1*s, range: 2*s)
            let h : Double = self.h(t: t, min: -1*s, range: 2*s)
            x = g
            y = h
            z = function(x: g, y: h)
        }
        else if functionType == 1
        {
            let g : Double = self.g(t: t, min: -1*s, range: 2*s)
            let h : Double = self.h(t: t, min: 0, range: 2*pi)
            let cosh : Double = cos(h)
            let sinh : Double = sin(h)
            x = g*cosh
            y = g*sinh
            z = function(x: g, y: h)
        }
        else if functionType == 2
        {
            let g : Double = self.g(t: t, min: 0, range: 2*pi)
            let h : Double = self.h(t: t, min: 0, range: pi)
            let cosh : Double = cos(h)
            let sinh : Double = sin(h)
            let cosg : Double = cos(g)
            let sing : Double = sin(g)
            let funchg : Double = function(x: h, y: g)
            x = funchg*cosg*sinh
            y = funchg*sing*sinh
            z = funchg*cosh
        }
        else if functionType == 3
        {
            let h : Double = self.h(t: t, min: domains[0], range: domains[1]-domains[0])
            let g : Double = self.g(t: t, min: domains[2], range: domains[3]-domains[2])
            x = X(x: h, y: g)
            y = Y(x: h, y: g)
            z = Z(x: h, y: g)
        }
        
        if !(x.isNaN || x.isInfinite || y.isNaN || y.isInfinite || z.isNaN || z.isInfinite)
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
        let minT : Double = domains[0]
        let maxT : Double = domains[1]
        let deltaT = (maxT-minT)*precision/2
        for t in stride(from: minT, to: maxT, by: deltaT)
        {
            let x = X(x: t, y: 0)
            let y = Y(x: t, y: 0)
            let z = Z(x: t, y: 0)
        
            if !(x.isNaN || x.isInfinite || y.isNaN || y.isInfinite || z.isNaN || z.isInfinite)
            {
                self.prerender[prerender.count-1].append(point3D(x: x, y: y, z: z))
            }
            else
            {
                prerender.append([point3D]())
            }
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
    func function(x: Double, y: Double) -> Double
    {
        if (equations[0].characters.count) > 0
        {
            var numericExpression = self.equations[0]
            if functionType == 0
            {
                numericExpression = numericExpression.replacingOccurrences(of: "x", with: "(\(x))")
                numericExpression = numericExpression.replacingOccurrences(of: "y", with: "(\(y))")
            }
            else if functionType == 1
            {
                numericExpression = numericExpression.replacingOccurrences(of: "r", with: "(\(x))")
                numericExpression = numericExpression.replacingOccurrences(of: "θ", with: "(\(y))")
            }
            else if functionType == 2
            {
                numericExpression = numericExpression.replacingOccurrences(of: "θ", with: "(\(x))")
                numericExpression = numericExpression.replacingOccurrences(of: "Φ", with: "(\(y))")
            }
            let expression = NSExpression(format: numericExpression)
            let result = expression.expressionValue(with: nil, context: nil) as! Double
            return result
        }
        return 0
    }
    func X(x: Double, y: Double) -> Double
    {
        if (equations[0].characters.count) > 0
        {
            var numericExpression = self.equations[0]
            if functionType == 3
            {
                numericExpression = numericExpression.replacingOccurrences(of: "u", with: "(\(x))")
                numericExpression = numericExpression.replacingOccurrences(of: "v", with: "(\(y))")
            }
            else if functionType == 4
            {
                numericExpression = numericExpression.replacingOccurrences(of: "t", with: "(\(x))")
            }
            let expression = NSExpression(format: numericExpression)
            let result = expression.expressionValue(with: nil, context: nil) as! Double
            return result
        }
        return 0
        //return (1.2+0.5*cos(y))*cos(x)
        //return x*cos(x)*(4+cos(x+y))
    }
    func Y(x: Double, y: Double) -> Double
    {
        if (equations[1].characters.count) > 0
        {
            var numericExpression = self.equations[1]
            if functionType == 3
            {
                numericExpression = numericExpression.replacingOccurrences(of: "u", with: "(\(x))")
                numericExpression = numericExpression.replacingOccurrences(of: "v", with: "(\(y))")
            }
            else if functionType == 4
            {
                numericExpression = numericExpression.replacingOccurrences(of: "t", with: "(\(x))")
            }
            let expression = NSExpression(format: numericExpression)
            let result = expression.expressionValue(with: nil, context: nil) as! Double
            return result
        }
        return 0
        //return (1.2+0.5*cos(y))*sin(x)
        //return x*sin(x)*(4+cos(x+y))
    }
    func Z(x: Double, y: Double) -> Double
    {
        if (equations[2].characters.count) > 0
        {
            var numericExpression = self.equations[2]
            if functionType == 3
            {
                numericExpression = numericExpression.replacingOccurrences(of: "u", with: "(\(x))")
                numericExpression = numericExpression.replacingOccurrences(of: "v", with: "(\(y))")
            }
            else if functionType == 4
            {
                numericExpression = numericExpression.replacingOccurrences(of: "t", with: "(\(x))")
            }
            let expression = NSExpression(format: numericExpression)
            let result = expression.expressionValue(with: nil, context: nil) as! Double
            return result
        }
        return 0
        //return 0.5*sin(y)+x/pi
        //return x*sin(x+y)
    }
    func handlePan(recognizer: UIPanGestureRecognizer)
    {
        tapAway()
        let velocityX : Double = Double(recognizer.velocity(in: graphView).x)
        let velocityY : Double = Double(recognizer.velocity(in: graphView).y)
        let speedScale : Double = 0.0009
        if recognizer.state == .began
        {
            velocityTimer.invalidate()
        }
        else if recognizer.state == .ended
        {
            endingVelocityX = velocityX * speedScale
            endingVelocityPositive = endingVelocityX > 0
            if !timer.isValid
            {
                velocityTimer = Timer.scheduledTimer(timeInterval: 0.008, target: self, selector: #selector(runEndVelocityCode), userInfo: nil, repeats: true)
            }

        }
        else
        {
            panChange(velocityX: velocityX * speedScale, velocityY: velocityY * speedScale)
        }
        
    }
    func panChange(velocityX: Double, velocityY: Double)
    {
        a = a + velocityX
        b = b + velocityY
    
        if b < 0
        {
            b = 0
        }
        if b > pi/2
        {
            b = pi/2
        }
        redraw()

    }
    func sign(_ x: Double) -> Double
    {
        if x < 0
        {
            return -1
        }
        return 1
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
        s = s*24/25
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
                max = max - velocity * max/15
              
                if max < 1
                {
                    max = 1
                }
                axisLengthLabel.text = "AXIS LENGTH: \(String(format: "%.1f", max))"
                redraw()
                
            }
        }
        
    }
    func xxComp()
    {
        xx = cos(a)*cos(c)-sin(c)*sin(a)*sin(b)
    }
    func xyComp()
    {
        xy = sin(a)*sin(b)*cos(c)+sin(c)*cos(a)
    }
    func yxComp()
    {
        yx = -sin(a)*cos(c)-sin(c)*cos(a)*sin(b)
    }
    func yyComp()
    {
        yy = cos(a)*sin(b)*cos(c)-sin(c)*sin(a)
    }
    func zxComp()
    {
        zx = -sin(c)*cos(b)
    }
    func zyComp()
    {
        zy = cos(c)*cos(b)
    }
    func g(t : Double, min : Double, range : Double) -> Double
    {
        return range*floor(t*(n+1))/n+min
    }
    func h(t : Double, min : Double, range : Double) -> Double
    {
        return range*fmod(t*(n+1),1)+min
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
public extension NSNumber {
    func sn() -> NSNumber {
        return NSNumber(value: sin(self.doubleValue))
    }
    func cs() -> NSNumber {
        return NSNumber(value: cos(self.doubleValue))
    }
    func lg() -> NSNumber {
        return NSNumber(value: log(self.doubleValue))
    }
    func sq() -> NSNumber {
        return NSNumber(value: sqrt(self.doubleValue))
    }
}
var key: Void?

class UITextFieldAdditions: NSObject {
    var readonly: Bool = false
}
extension UITextField {

    var readonly: Bool {
        get {
            return self.getAdditions().readonly
        } set {
            self.getAdditions().readonly = newValue
        }
    }
    
    private func getAdditions() -> UITextFieldAdditions {
        var additions = objc_getAssociatedObject(self, &key) as? UITextFieldAdditions
        if additions == nil {
            additions = UITextFieldAdditions()
            objc_setAssociatedObject(self, &key, additions!, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
        }
        return additions!
    }
    
    open override func target(forAction action: Selector, withSender sender: Any?) -> Any? {
        
        return nil
    }

}
