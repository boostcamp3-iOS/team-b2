//
//  BodabiAlertController.swift
//  Bodabi
//
//  Created by Kim DongHwan on 06/02/2019.
//  Copyright © 2019 LeeHyeJin. All rights reserved.
//

import UIKit

public protocol BodabiAlertControllerDelegate: NSObjectProtocol {
    func bodabiAlert(type: UIImagePickerController.SourceType) -> Void
}

public class BodabiAlertController: UIViewController {
    
    // MARK: - Property
    
    private let tag: Int
    private static var tagFactory = 0
    
    public var overlayColor = UIColor(white: 0, alpha: 0.2)
    public weak var delegate: BodabiAlertControllerDelegate?
    
    public var titleFont = UIFont(name: "Avenir Next", size: 15)
    public var titleTextColor = UIColor.black
    
    public var message: String?
    public var messageLabel = UILabel()
    public var messageFont = UIFont(name: "Avenir Next", size: 13)
    public var messageTextColor = UIColor.lightGray
    
    public var buttonHeight: CGFloat = 55
    public var buttonTextColor = UIColor.black
    public var buttonIconColor: UIColor?
    public var buttonFont = UIFont(name: "Avenir Next", size: 15)
    
    public var cancelButtonTitle: String?
    public var cancelButtonFont = UIFont(name: "Avenir Next", size: 14)
    public var cancelButtonTextColor = UIColor.darkGray
    
    public var containerView = UIView()
    public var style = BodabiAlertControllerStyle.ActionSheet
    public var touchingOutsideDismiss: Bool?
    
    private var buttons = [BodabiAlertButton]()
    private var instance: BodabiAlertController!
    private var currentOrientation: UIDeviceOrientation?
    private var cancelButton = UIButton()
    
    private var alertType: AlertType?
    
    // MARK: - Life cycle
    
    private static func getUniqueTag() -> Int {
        tagFactory += 1
        return tagFactory
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        initTapGesture()
    }
    
    // MARK: - Initailization
    
    public init() {
        self.tag = BodabiAlertController.getUniqueTag()
        super.init(nibName: nil, bundle: nil)
    }
    
    public convenience init(style: BodabiAlertControllerStyle) {
        self.init()
        self.style = style
    }
    
    public convenience init(title: String?, message: String?, type: AlertType?, style: BodabiAlertControllerStyle) {
        self.init(style: style)
        self.title = title
        self.message = message
        self.alertType = type
    }
    
    public convenience init(type: AlertType, style: BodabiAlertControllerStyle) {
        self.init(title: nil, message: nil, type: type, style: style)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initTapGesture() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissAlert))
        
        tapGesture.delegate = self
        
        view.addGestureRecognizer(tapGesture)
    }
    
    private func initContainerView() {
        containerView.clipsToBounds = true
        containerView.subviews.forEach { $0.removeFromSuperview() }
        view.subviews.forEach { $0.removeFromSuperview() }
        
        instance = self
        
        let viewWidth = style == .ActionSheet ? view.frame.width : view.frame.width * 0.9
        
        currentOrientation = UIDevice.current.orientation
        let orientation = UIApplication.shared.statusBarOrientation
        
        if orientation == UIInterfaceOrientation.portrait {
            currentOrientation = UIDeviceOrientation.portrait
        }
        
        var posY: CGFloat = 0
        
        if let alertType = alertType {
            title = alertType.title
            
            switch alertType {
            case let .camera(sourceTypes):
                for (index, element) in sourceTypes.enumerated() {
                    addButton(title: alertType.titles[index]) { [weak self] in
                        self?.delegate?.bodabiAlert(type: element)
                    }
                }
            default:
                break
            }
        }
        
        if let title = title, title != ""  {
            let titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: viewWidth, height: buttonHeight * 0.92))
            
            titleLabel.text = title
            titleLabel.font = titleFont
            titleLabel.textAlignment = .center
            titleLabel.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin]
            titleLabel.textColor = titleTextColor
            
            containerView.addSubview(titleLabel)
            
            let line = UIView(frame: CGRect(x: 0, y: titleLabel.frame.height, width: viewWidth, height: 1))
            
            line.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            line.autoresizingMask = [.flexibleWidth]
            
            containerView.addSubview(line)
            
            posY = titleLabel.frame.height + line.frame.height
        } else {
            posY = 0
        }
        
        if let message = message, message != "" {
            let paddingY: CGFloat = 8
            let paddingX: CGFloat = 10
            
            messageLabel.font = messageFont
            messageLabel.textColor = UIColor.gray
            messageLabel.translatesAutoresizingMaskIntoConstraints = false
            messageLabel.text = message
            messageLabel.numberOfLines = 0
            messageLabel.textColor = messageTextColor
            
            let labelSize = CGSize(width: viewWidth - paddingX * 2, height: CGFloat.greatestFiniteMagnitude)
            let rect = messageLabel.sizeThatFits(labelSize)
            
            messageLabel.frame = CGRect(x: paddingX, y: posY + paddingY, width: rect.width, height: rect.height)
            containerView.addSubview(messageLabel)
            containerView.addConstraints([
                NSLayoutConstraint(item: messageLabel, attribute: .rightMargin, relatedBy: NSLayoutConstraint.Relation.equal, toItem: containerView, attribute: .rightMargin, multiplier: 1, constant: -paddingX),
                NSLayoutConstraint(item: messageLabel, attribute: .leftMargin, relatedBy: .equal, toItem: containerView, attribute: .leftMargin, multiplier: 1.0, constant: paddingX),
                NSLayoutConstraint(item: messageLabel, attribute: .top, relatedBy: .equal, toItem: containerView, attribute: .top, multiplier: 1.0, constant: posY + paddingY),
                NSLayoutConstraint(item: messageLabel, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: rect.height)
                ])
            
            posY = messageLabel.frame.maxY + paddingY
            
            let line = UIView(frame: CGRect(x: 0, y: posY, width: viewWidth, height: 1))
            
            line.backgroundColor = UIColor(white: 0.9, alpha: 1.0)
            line.autoresizingMask = [.flexibleWidth]
            containerView.addSubview(line)
            
            posY += line.frame.height
        }
        
        for i in 0..<buttons.count {
            buttons[i].backgroundColor = UIColor.white
            buttons[i].buttonColor = buttonIconColor
            buttons[i].frame = CGRect(x: 0, y: posY, width: viewWidth, height: buttonHeight)
            buttons[i].textLabel.textColor = buttonTextColor
            buttons[i].buttonFont = buttonFont
            buttons[i].translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(buttons[i])
            
            containerView.addConstraints([
                NSLayoutConstraint(item: buttons[i], attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: buttonHeight),
                NSLayoutConstraint(item: buttons[i], attribute: NSLayoutConstraint.Attribute.rightMargin, relatedBy: NSLayoutConstraint.Relation.equal, toItem: containerView, attribute: NSLayoutConstraint.Attribute.rightMargin, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: buttons[i], attribute: NSLayoutConstraint.Attribute.leftMargin, relatedBy: NSLayoutConstraint.Relation.equal, toItem: containerView, attribute: NSLayoutConstraint.Attribute.leftMargin, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: buttons[i], attribute: NSLayoutConstraint.Attribute.top, relatedBy: NSLayoutConstraint.Relation.equal, toItem: containerView, attribute: NSLayoutConstraint.Attribute.top, multiplier: 1.0, constant: posY)
                ])
            
            posY += buttons[i].frame.height
        }
        
        if let cancelTitle = cancelButtonTitle, cancelTitle != "" {
            cancelButton = UIButton(frame: CGRect(x: 0, y: posY, width: viewWidth, height: buttonHeight * 0.9))
            cancelButton.autoresizingMask = [.flexibleRightMargin, .flexibleLeftMargin]
            cancelButton.titleLabel?.font = cancelButtonFont
            cancelButton.setTitle(cancelButtonTitle, for: .normal)
            cancelButton.setTitleColor(cancelButtonTextColor, for: .normal)
            cancelButton.addTarget(self, action: #selector(dismissAlert), for: .touchUpInside)
            containerView.addSubview(cancelButton)
            posY += cancelButton.frame.height
        }
        
        posY += 15
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        containerView.frame = CGRect(x: (view.frame.width - viewWidth) / 2, y: view.frame.height , width: viewWidth, height: posY)
        containerView.backgroundColor = UIColor.white
        containerView.cornerRadius = 15
        view.addSubview(containerView)
        
        switch style {
        case .ActionSheet:
            view.addConstraints([
                NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: .equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.bottom, relatedBy: .equal, toItem: view, attribute: NSLayoutConstraint.Attribute.bottom, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: posY)
                ])
        case .Alert:
            view.addConstraints([
                NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 0.9, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.centerX, relatedBy: .equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerX, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: NSLayoutConstraint.Attribute.centerY, relatedBy: .equal, toItem: view, attribute: NSLayoutConstraint.Attribute.centerY, multiplier: 1.0, constant: 0),
                NSLayoutConstraint(item: containerView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1.0, constant: posY)
                ])
        }
        
        if let window = UIApplication.shared.keyWindow, window.viewWithTag(tag) == nil {
            print("tag: ", tag)
            view.tag = tag
            window.addSubview(view)
        }
        
        cancelButton.isHidden = true
        buttons.forEach {
            $0.iconImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
            $0.textLabel.transform = CGAffineTransform(scaleX: 0, y: 0)
            $0.dotView.isHidden = true
        }
    }
    
    // MARK: - Method
    
    public func addButton(icon: UIImage?, title: String, action: @escaping ()->Void) {
        let button = BodabiAlertButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: buttonHeight), icon: icon, text: title)
        button.actionType = .Closure
        button.buttonColor = buttonIconColor
        button.buttonFont = buttonFont
        
        button.action = action
        
        button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
        buttons.append(button)
    }
    
    public func addButton(icon: UIImage?, title: String, target: AnyObject, selector: Selector) {
        let button = BodabiAlertButton(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: buttonHeight), icon: icon, text: title)
        button.actionType = .Selector
        button.buttonColor = buttonIconColor
        button.buttonFont = buttonFont
        
        button.target = target
        button.selector = selector
        
        button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
        buttons.append(button)
    }
    
    public func addButton(title: String, action: @escaping ()->Void) {
        addButton(icon: nil, title: title, action: action)
    }
    
    public func addButton(title: String, target: AnyObject, selector: Selector) {
        addButton(icon: nil, title: title, target: target, selector: selector)
    }
    
    public func show() {
        view.backgroundColor = overlayColor
        
        if touchingOutsideDismiss == nil {
            touchingOutsideDismiss = style == .ActionSheet ? true : false
        }
        
        initContainerView()
        
        switch style {
        case .ActionSheet:
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 0,
                           options: .curveEaseIn,
                           animations: {
                            self.containerView.frame.origin.y = self.view.frame.height - self.containerView.frame.height
            },
                           completion: { (_) in
                            self.startButtonAppearAnimation()
                            if let cancelTitle = self.cancelButtonTitle, cancelTitle != "" {
                                self.startCancelButtonAppearAnimation()
                            }
            }
            )
        case .Alert:
            containerView.frame.origin.y = view.frame.height / 2 - containerView.frame.height / 2
            containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            containerView.alpha = 0.0
            
            UIView.animate(withDuration: 0.1,
                           delay: 0,
                           usingSpringWithDamping: 0.9,
                           initialSpringVelocity: 0,
                           options: .curveEaseIn,
                           animations: {
                            self.containerView.alpha = 1.0
                            self.containerView.transform = CGAffineTransform(scaleX: 1, y: 1)
            },
                           completion: { (_) in
                            self.startButtonAppearAnimation()
                            if let cancelTitle = self.cancelButtonTitle, cancelTitle != "" {
                                self.startCancelButtonAppearAnimation()
                            }
            }
            )
        }
    }
    
    private func startButtonAppearAnimation() {
        buttons.forEach { $0.appear() }
    }
    
    private func startCancelButtonAppearAnimation() {
        cancelButton.titleLabel?.transform = CGAffineTransform(scaleX: 0, y: 0)
        cancelButton.isHidden = false
        
        UIView.animate(withDuration: 0.1,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0,
                       options: .curveEaseIn,
                       animations: {
                        self.cancelButton.titleLabel?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
        )
    }
    
    // MARK: - Objc
    
    @objc private func buttonTapped(button: BodabiAlertButton) {
        switch button.actionType! {
        case .Closure:
            button.action()
        case .Selector:
            let control = UIControl()
            control.sendAction(button.selector, to: button.target, for: nil)
        }
        
        dismissAlert()
    }
    
    @objc private func dismissAlert() {
        instance = nil
        
        if style == .ActionSheet {
            UIView.animate(withDuration: 0.2,
                           animations: {
                            self.containerView.frame.origin.y = self.view.frame.height
                            self.view.backgroundColor = UIColor(white: 0, alpha: 0)
            },
                           completion: { (_) in
                            self.view.removeFromSuperview()
            }
            )
        } else {
            UIView.animate(withDuration: 0.2,
                           animations: {
                            self.view.backgroundColor = UIColor(white: 0, alpha: 0)
                            self.containerView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
                            self.containerView.alpha = 0
            },
                           completion: { (_) in
                            self.view.removeFromSuperview()
            }
            )
        }
    }
}

// MARK: - UIGestureRecognizerDelegate

extension BodabiAlertController: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if touchingOutsideDismiss == false { return false }
        if touch.view != gestureRecognizer.view { return false }
        return true
    }
}

// MARK: - Type

extension BodabiAlertController {
    public enum BodabiAlertControllerStyle {
        case ActionSheet
        case Alert
    }
    
    public enum AlertType {
        case sort(sortTypes: [String])
        case camera(SourceTypes: [UIImagePickerController.SourceType])
        
        var title: String {
            switch self {
            case .camera:
                return "이미지를 가져올 방법을 선택해주세요"
            case .sort:
                return "정렬 방법을 선택해주세요"
            }
        }
        
        var titles: [String] {
            switch self {
            case .camera:
                return ["카메라", "저장 앨범", "사진 라이브러리"]
            case let .sort(sortTypes):
                return sortTypes
            }
        }
        
    }
    
    private enum BodabiButtonActionType {
        case Selector
        case Closure
    }
}

// MARK: - View

extension BodabiAlertController {
    private class BodabiAlertButton: UIButton {
        
        // MARK: - Property
        
        override public var isHighlighted: Bool {
            didSet {
                alpha = isHighlighted ? 0.3 : 1.0
            }
        }
        public var buttonColor: UIColor? {
            didSet {
                if let buttonColor = buttonColor {
                    iconImageView.image = icon?.withRenderingMode(.alwaysTemplate)
                    iconImageView.tintColor = buttonColor
                    dotView.dotColor = buttonColor
                } else {
                    iconImageView.image = icon
                }
            }
        }
        public var icon: UIImage?
        public var iconImageView = UIImageView()
        public var textLabel = UILabel()
        public var dotView = DotView()
        public var buttonFont: UIFont? {
            didSet {
                textLabel.font = buttonFont
            }
        }
        public var actionType: BodabiButtonActionType!
        public var target: AnyObject!
        public var selector: Selector!
        public var action: (()->Void)!
        
        // MARK: - Initialization
        
        public init(frame: CGRect, icon: UIImage?, text: String) {
            super.init(frame: frame)
            
            self.icon = icon
            
            let iconHeight: CGFloat = frame.height * 0.45
            let labelHeight = frame.height * 0.8
            
            iconImageView.frame = CGRect(x: 8, y: frame.height / 2 - iconHeight / 2, width: iconHeight, height: iconHeight)
            iconImageView.image = icon
            
            dotView.frame = iconImageView.frame
            dotView.backgroundColor = UIColor.clear
            dotView.isHidden = true
            
            textLabel.frame = CGRect(x: iconImageView.frame.maxX + 8, y: frame.midY - labelHeight / 2, width: frame.width - iconImageView.frame.maxX, height: labelHeight)
            textLabel.text = text
            textLabel.textColor = UIColor.black
            textLabel.font = buttonFont
            
            addSubview(iconImageView)
            addSubview(dotView)
            addSubview(textLabel)
        }
        
        required public init?(coder aDecoder:NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        // MARK: - Method
        
        override public func draw(_ rect: CGRect) {
            UIColor(white: 0.85, alpha: 1.0).setStroke()
            
            let line = UIBezierPath()
            
            line.lineWidth = 1
            line.move(to: CGPoint(x: iconImageView.frame.maxX + 5, y: frame.height))
            line.addLine(to: CGPoint(x: frame.width , y: frame.height))
            
            line.stroke()
        }
        
        public func appear() {
            dotView.transform = CGAffineTransform(scaleX: 0, y: 0)
            dotView.isHidden = false
            
            UIView.animate(withDuration: 0.1) {
                self.textLabel.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                
                if self.iconImageView.image == nil {
                    self.dotView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                } else {
                    self.iconImageView.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                }
            }
        }
    }
    
    private class DotView: UIView {
        
        // MARK: - Property
        
        public var dotColor = UIColor.black
        
        // MARK: - Method
        
        override public func draw(_ rect: CGRect) {
            dotColor.setFill()
            
            let circle = UIBezierPath(
                arcCenter: CGPoint(x: frame.width / 2, y: frame.height / 2),
                radius: 3,
                startAngle: 0,
                endAngle: 360,
                clockwise: true
            )
            
            circle.fill()
        }
    }
}


