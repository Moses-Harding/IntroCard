import Foundation
import UIKit

extension UIColor {
    convenience init(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat, _ alpha: CGFloat = 1.0) {
        self.init(red: red / 256, green: green / 256, blue: blue / 256, alpha: alpha)
    }
}

enum Position {
    case top, bottom, middle
}

class IntroCard: UIView {
    
    weak var parentView: UIView!
    weak var parentController: UIViewController!
    
    var backgroundView = UIView()
    
    var cardBody = UIView()
    
    var messageLabel = UILabel()
    var message: String!
    
    var titleLabel = UILabel()
    var title: String!
    
    var titleMultiplier: CGFloat = 0.15
    var topSpacerMultiplier: CGFloat = 0.1

    var cardYConstraint: NSLayoutConstraint!
    var backgroundTopConstraint: NSLayoutConstraint!
    var backgroundBottomConstraint: NSLayoutConstraint!
    
    var stage: Int = 0
    var action: ((IntroCard, Int) -> (Int))!
    
    init(viewController: UIViewController, title: String, message: String, action: @escaping ((IntroCard, Int) -> (Int))) {
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
        
        if #available(iOS 11.0, *) {
            let constraints = ([
                topAnchor.constraint(equalTo: parentView.topAnchor),
                bottomAnchor.constraint(equalTo: parentView.safeAreaLayoutGuide.bottomAnchor),
                leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
            ])
        } else {
            let constraints = ([
                topAnchor.constraint(equalTo: parentView.topAnchor),
                bottomAnchor.constraint(equalTo: parentView.bottomAnchor),
                leadingAnchor.constraint(equalTo: parentView.leadingAnchor),
                trailingAnchor.constraint(equalTo: parentView.trailingAnchor)
            ])
        }
        
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
        
        backgroundView.backgroundColor = UIColor(256, 256, 256, 0.5)
        backgroundView.layer.cornerRadius = 20
    }
    
    func setUpCardBody() {
        
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
        
        cardBody.backgroundColor = UIColor(256, 256, 256, 0.85)
        cardBody.layer.cornerRadius = 20
        cardBody.layer.shadowColor = UIColor.black.cgColor
        cardBody.layer.shadowOffset = CGSize.zero
        cardBody.layer.shadowRadius = 20
        cardBody.layer.shadowOpacity = 0.25
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
    
    func setFont(for label: UILabel, fontSize: CGFloat, fontName: String = "AppleSDGothicNeo-Light") {
        
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
    
    func transition(newTitle: String, newMessage: String, placement: CGFloat = 0, position: Position = .middle) {
        
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
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let action = action else { fatalError("No actions")}
        
        stage = action(self, stage)
    }
}
