//
//  ViewController.swift
//  SmartSegmentedControlSwift
//
//  Created by Ievgen Shevtsov on 5/27/17.
//
//

import UIKit
import SmartSegmentedControl

class ViewController: UIViewController, UITextFieldDelegate {

    // MARK: outlets
    @IBOutlet weak var mainScrollView:UIScrollView!
    @IBOutlet weak var mainScrollBottomConstraint:NSLayoutConstraint!
    
    @IBOutlet weak var controlContainerScrollView:UIScrollView!
    @IBOutlet weak var configurableControl: SmartSegmentedControl!
    @IBOutlet weak var configurableControlWidthConstraint:NSLayoutConstraint!
    
    @IBOutlet weak var controlWidthTextField:UITextField!
    @IBOutlet weak var controlModeSegmentedControl:UISegmentedControl!
    
    @IBOutlet weak var segmentIndexTextField:UITextField!
    @IBOutlet weak var segmentIndexStepper:UIStepper!
    @IBOutlet weak var segmentWidthTextField:UITextField!
    @IBOutlet weak var segmentTitleTextField:UITextField!
    
    @IBOutlet weak var addButton:UIButton!
    @IBOutlet weak var insertButton:UIButton!
    @IBOutlet weak var removeButton:UIButton!
    
    
    // MARK: overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        configurableControl.backgroundColor = UIColor.yellow
//        configurableControl.setTitleTextAttributes([NSFontAttributeName:UIFont.boldSystemFont(ofSize: 20)], for: .normal)
        
        controlWidthTextField.text = "\(configurableControlWidthConstraint.constant)"
        changeControlMode(controlModeSegmentedControl)
        
        segmentIndexStepper.minimumValue = 0
        segmentIndexStepper.maximumValue = Double(configurableControl.numberOfSegments)
        segmentIndexStepper.value = segmentIndexStepper.minimumValue
        stepperValueChange(segmentIndexStepper)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(willShowKeyboard(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(willHideKeyboard(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if (configurableControlWidthConstraint.constant < controlContainerScrollView.frame.size.width) {
            controlContainerScrollView.contentInset.left = (controlContainerScrollView.frame.size.width - configurableControlWidthConstraint.constant) / 2.0
        }
        else {
            controlContainerScrollView.contentInset.left = 0.0
        }

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    // MARK: actions
    
    @IBAction func changeControlMode(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            configurableControl.apportionsSegmentWidthsByContent = false
            configurableControl.fixNativeProportionalSizing = false
            configurableControl.smartAdjustment = false
            
        case 1:
            configurableControl.apportionsSegmentWidthsByContent = true
            configurableControl.fixNativeProportionalSizing = false
            configurableControl.smartAdjustment = false
            
        case 2:
            configurableControl.apportionsSegmentWidthsByContent = false
            configurableControl.fixNativeProportionalSizing = true
            configurableControl.smartAdjustment = false
            
        case 3:
            configurableControl.apportionsSegmentWidthsByContent = false
            configurableControl.fixNativeProportionalSizing = false
            configurableControl.smartAdjustment = true

        default:
            showAlert(text:"!!! app is not ready for it yet")
        }
    }
    
    @IBAction func stepperValueChange(_ sender: UIStepper) {
        let index = Int(sender.value)
        segmentIndexTextField.text = "\(index)"
        
        if index < configurableControl.numberOfSegments {
            segmentWidthTextField.text = "\(configurableControl.widthForSegment(at: index))"
            segmentTitleTextField.text = configurableControl.titleForSegment(at: index)
            addButton.isEnabled = false
            insertButton.isEnabled = true
            removeButton.isEnabled = true
        }
        else {
            segmentWidthTextField.text = "0"
            segmentTitleTextField.text = ""
            addButton.isEnabled = true
            insertButton.isEnabled = false
            removeButton.isEnabled = false
        }
    }
    
    @IBAction func addButtonClick(_ sender: UIButton) {
        let index = Int(segmentIndexStepper.value)
        configurableControl.insertSegment(withTitle: segmentTitleTextField.text,
                                          at: index,
                                          animated: true)
        var width: Double?
        if let text = segmentWidthTextField.text {
            if let value = Double(text) {
                if value>0 {
                    width = value
                }
            }
        }
        if let unwrWidth = width {
            configurableControl.setWidth(CGFloat(unwrWidth), forSegmentAt: index)
        }
        
        segmentIndexStepper.maximumValue += 1
        stepperValueChange(segmentIndexStepper)
    }
    
    @IBAction func insertButtonClick(_ sender: UIButton) {
        let index = Int(segmentIndexStepper.value)
        configurableControl.insertSegment(withTitle: "",
                                          at: index,
                                          animated: true)
        segmentIndexStepper.maximumValue += 1
        stepperValueChange(segmentIndexStepper)
    }
    
    @IBAction func removeButtonClick(_ sender: UIButton) {
        let index = Int(segmentIndexStepper.value)
        configurableControl.removeSegment(at: index, animated: true)
        segmentIndexStepper.maximumValue -= 1
        stepperValueChange(segmentIndexStepper)
    }

    
    // MARK: textField delegate
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        var isValid = true
        
        switch textField {
        case controlWidthTextField:
            if let width = Double(textField.text!) {
                configurableControlWidthConstraint.constant = CGFloat(width)
                UIView.animate(withDuration: 0.2) {
                    self.updateViewConstraints()
                }
            }
            else {
                isValid = false
            }
            
        case segmentIndexTextField:
            if let index = Int(textField.text!) {
                if (index>=0 && index<=configurableControl.numberOfSegments) {
                    segmentIndexStepper.value = Double(index)
                    stepperValueChange(segmentIndexStepper)
                }
                else {
                    isValid = false
                }
            }
            else {
                isValid = false
            }
            
        case segmentWidthTextField:
            if let width = Double(textField.text!) {
                let index = Int(segmentIndexStepper.value)
                if index < configurableControl.numberOfSegments {
                    configurableControl.setWidth(CGFloat(width), forSegmentAt: index)
                }
            }
            else {
                isValid = false
            }

        case segmentTitleTextField:
            let index = Int(segmentIndexStepper.value)
            if index < configurableControl.numberOfSegments {
                configurableControl.setTitle(segmentTitleTextField.text, forSegmentAt: index)
            }
            
        default:
            isValid = true
        }
        
        if !isValid {
            showAlert(text: "Inapropriate value. Please, edit it :)")
        }
        return isValid
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    
    // MARK: keyboard observing
    
    func willShowKeyboard(_ notification: Notification) {
        let userInfo = notification.userInfo!
        let kbRectValue: NSValue = userInfo[UIKeyboardFrameEndUserInfoKey]! as! NSValue
        let kbRect = kbRectValue.cgRectValue
        
        mainScrollBottomConstraint.constant = kbRect.size.height
        UIView.animate(withDuration: (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue) { 
            self.updateViewConstraints()
        }
    }
    
    func willHideKeyboard(_ notification: Notification) {
        let userInfo = notification.userInfo!
        
        mainScrollBottomConstraint.constant = 0
        UIView.animate(withDuration: (userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber).doubleValue) {
            self.updateViewConstraints()
        }
    }
    
    // MARK: service
    
    func showAlert(text: String) {
        let alert = UIAlertController(title: nil, message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: { action in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}

