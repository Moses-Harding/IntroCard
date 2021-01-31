import Foundation
import UIKit

extension UIColor {
    convenience init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1.0) {
        self.init(red: red / 256, green: green / 256, blue: blue / 256, alpha: alpha)
    }
}

public enum Position {
    case top, bottom, middle
}

public class IntroCard: UIView {
    
    weak var parentView: UIView!
    weak var parentController: UIViewController!
    
    //BackgroundView
    public var backgroundView: UIView! = UIView()
    public var backgroundViewColor = UIColor(256, 256, 256, 0.5)
    public var backgroundViewCornerRadius: CGFloat = 20
    
    //Card Body
    public var cardBody: UIView! = UIView()
    public var cardBodyBackgroundColor = UIColor(256, 256, 256, 0.85)
    
    public var messageLabel = UILabel()
    public var message: String!
    
    public var titleLabel = UILabel()
    public var title: String!
    
    //Shadow variables
    public var shadowCornerRadius: CGFloat  = 20
    public var shadowColor = UIColor.black.cgColor
    public var shadowOffset = CGSize.zero
    public var shadowRadius: CGFloat = 20
    public var shadowOpacity: Float = 0.25
    
    var titleMultiplier: CGFloat = 0.15
    var topSpacerMultiplier: CGFloat = 0.1

    var cardYConstraint: NSLayoutConstraint!
    var backgroundTopConstraint: NSLayoutConstraint!
    var backgroundBottomConstraint: NSLayoutConstraint!
    
    var stage: Int = 0
    public var action: ((IntroCard, Int) -> (Int))!
    
    public init(viewController: UIViewController, title: String, message: String, action: @escaping ((IntroCard, Int) -> (Int))) {
        super.init(frame: CGRect.zero)
        
        self.parentController = viewController
        self.parentView = viewController.view
        self.message = message
        self.title = title
        
        self.action = action
        
        constrainSelf()
        setUpBackgroundView()
        setUpCardBody()
        setUpMessageBody()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func constrainSelf() {
        
        parentView.addSubview(self)
        translatesAutoresizingMaskIntoConstraints = false
        
            let constraints = ([
                topAnchor.constraint(equalTo: parentView.topAnchor),
                bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
                leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
            ])
        
        NSLayoutConstraint.activate(constraints)
    }
    
    func setUpBackgroundView() {
        
        self.addSubview(backgroundView)
        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        backgroundTopConstraint = backgroundView.topAnchor.constraint(equalTo: topAnchor)
        backgroundBottomConstraint = backgroundView.bottomAnchor.constraint(equalTo: bottomAnchor)
        
        let constraints = ([
            backgroundTopConstraint!,
            backgroundBottomConstraint!,
            backgroundView.leadingAnchor.constraint(equalTo: leadingAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
        
        NSLayoutConstraint.activate(constraints)
        
        backgroundView.backgroundColor = backgroundViewColor
        backgroundView.layer.cornerRadius = backgroundViewCornerRadius
    }
    
    public func setUpCardBody() {
        
        backgroundView.addSubview(cardBody)
        cardBody.translatesAutoresizingMaskIntoConstraints = false
        
        cardYConstraint = cardBody.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
        
        let constraints = ([
            cardYConstraint!,
            cardBody.widthAnchor.constraint(equalTo: backgroundView.widthAnchor, multiplier: 0.9),
            cardBody.centerXAnchor.constraint(equalTo: backgroundView.centerXAnchor),
                            cardBody.bottomAnchor.constraint(lessThanOrEqualTo: backgroundView.bottomAnchor)
        ])
        
        NSLayoutConstraint.activate(constraints)
        
        cardBody.backgroundColor = cardBodyBackgroundColor
        cardBody.layer.cornerRadius = shadowCornerRadius
        cardBody.layer.shadowColor = shadowColor
        cardBody.layer.shadowOffset = shadowOffset
        cardBody.layer.shadowRadius = shadowRadius
        cardBody.layer.shadowOpacity = shadowOpacity
    }

    
    func setUpMessageBody() {
        
        titleLabel.text = self.title
        titleLabel.textColor = .black
        self.setFont(for: titleLabel, fontSize: 24, fontName: "AppleSDGothicNeo-Bold")
        

        self.setFont(for: messageLabel, fontSize: 18)
        messageLabel.textColor = .black
        messageLabel.text = self.message
        
        
        cardBody.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        cardBody.addSubview(messageLabel)
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        let spacer = parentView.frame.height / 35

        let titleConstraints = ([
            titleLabel.topAnchor.constraint(equalTo: cardBody.topAnchor, constant: spacer),
            titleLabel.leadingAnchor.constraint(equalTo: cardBody.leadingAnchor, constant: spacer),
            titleLabel.trailingAnchor.constraint(equalTo: cardBody.trailingAnchor, constant: -spacer)
        ])
        
        NSLayoutConstraint.activate(titleConstraints)
        
        let messageConstraints = ([
            messageLabel.bottomAnchor.constraint(equalTo: cardBody.bottomAnchor, constant: -spacer),
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: spacer),
            messageLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
            messageLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate(messageConstraints)
    }
    
    public func resetView() {
        
        backgroundView.removeFromSuperview()
        backgroundView = UIView()
        
        cardBody.removeFromSuperview()
        cardBody = UIView()
        
        setUpBackgroundView()
        setUpCardBody()
        setUpMessageBody()
    }
    
    public func setFont(for label: UILabel, fontSize: CGFloat, fontName: String = "AppleSDGothicNeo-Light") {
        
        guard let customFont = UIFont(name: fontName, size: fontSize) else { fatalError("Font not loaded")}
        if #available(iOS 11.0, *) {
            label.font = UIFontMetrics(forTextStyle: .body).scaledFont(for: customFont)
        } else {
            label.font = customFont
        }
        label.adjustsFontSizeToFitWidth = true
        label.minimumScaleFactor = 0.2
        label.numberOfLines = 0
    }
    
    public func transition(newTitle: String, newMessage: String, placement: CGFloat = 0, position: Position = .middle) {
        
        var newTop: NSLayoutConstraint!
        var newCard: NSLayoutConstraint
        var newBottom: NSLayoutConstraint!

        switch position {
        case .top:
            newCard = cardBody.topAnchor.constraint(equalTo: backgroundView.topAnchor, constant: 20)
            newTop = backgroundView.topAnchor.constraint(equalTo: self.topAnchor, constant: self.parentView.frame.height * placement)
            newBottom = backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        case .middle:
            newCard = cardBody.centerYAnchor.constraint(equalTo: backgroundView.centerYAnchor)
            newTop = backgroundView.topAnchor.constraint(equalTo: self.topAnchor)
            newBottom = backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
        case .bottom:
            newCard = cardBody.bottomAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: -20)
            newTop = backgroundView.topAnchor.constraint(equalTo: self.topAnchor)
            newBottom = backgroundView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: (1 - placement) * -self.parentView.frame.height)
        }
        
        UIView.animate(withDuration: 0.5, animations: {
            self.messageLabel.alpha = 0
            self.titleLabel.alpha = 0
        }, completion: { _ in
            UIView.animate(withDuration: 1, animations: {
                self.backgroundTopConstraint.isActive = false
                self.backgroundTopConstraint = newTop
                self.backgroundTopConstraint.isActive = true
                
                self.backgroundBottomConstraint.isActive = false
                self.backgroundBottomConstraint = newBottom
                self.backgroundBottomConstraint.isActive = true
                
                self.cardYConstraint.isActive = false
                self.cardYConstraint = newCard
                self.cardYConstraint.isActive = true
                
                self.messageLabel.text = newMessage
                self.titleLabel.text = newTitle
                self.layoutIfNeeded()
            }, completion: { _ in
                UIView.animate(withDuration: 0.5, animations: {
                    self.messageLabel.alpha = 1
                    self.titleLabel.alpha = 1
                })
            })
        })
    }
    
    public override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let action = action else { fatalError("No actions")}
        
        stage = action(self, stage)
    }
}
