# IntroCard

As I was working on my latest app, I recognized the need for a simple introduction interface; one that would allow you to focus on key elements and keep your message clear and concise, while creating smooth animations. My solution was IntroCards, which allows you to create a card that moves around the screen gracefully and obscures irrelevant pieces of information.

## Usage

IntroCards are meant to be simple to use. Initializing requires a title, a message, and an action ( `((IntroCard, Int) -> (Int)) `). Each time the screen is tapped, the IntroCard runs that action. 

### Actions
Since most app introductions will probably have multiple stages, the action closure takes in an Int, which correlates to the “stage” variable, and runs a corresponding action. Make sure to increment the stage variable each time. 

It might be easiest to create a custom class to deal with this. See below as an example:

```
class IntroPresenter {
    
    weak var controller: UIViewController!
    
    init(controller: UIViewController) {
        self.controller = controller
        
        addCard()
    }
    
    func addCard() {
        
	//1
        let action: ((IntroCard, Int) -> (Int)) = { (card: IntroCard, stage: Int) in
            
            switch stage {
            case 0:
		//2
                card.transition(newTitle: "Second Title", newMessage: "This is the top of the screen. Let's look at the bottom.", placement: 0.5, position: .top)
            case 1:
		//3
                card.transition(newTitle: "Second Title", newMessage: "This is what the bottom looks like.", placement: 0.6, position: .bottom)
            case 2:
		//4
                card.transition(newTitle: "Last Title", newMessage: "Now we're back in the middle.", position: .middle)
            default:
		//5
                card.removeFromSuperview()
            }
		//6
            	return stage + 1
        }
        //7
        let card = IntroCard(viewController: self.controller, title: "First Title", message: "This is the first message. Next, we're going to look at the top half of the screen. Tap to continue.", action: action)

	//8
        card.cardBodyBackgroundColor = UIColor(red: 0, green: 0.6275, blue: 0.8196, alpha: 0.95)
        card.shadowColor = UIColor(red: 0, green: 0.6275, blue: 0.8196, alpha: 0.95).cgColor
        
	//9
        card.resetView()
        
	//10
        card.titleLabel.textColor = .white
        card.messageLabel.textColor = .white
    }
}
```

We can see a few things here:

1. We define our action, which takes in the ‘Stage’ variable, determines which action to run, and then increments it
2. The card runs the internal ‘transition’ function. This takes in a title and message, and can optionally take a ‘placement’ and ‘position.’ Placement refers to which point at the screen that the background obscured view should start or end. If position is “.top”, the top half of the screen will be unobscured and the card itself will be at the top portion of the obscured view.
3. When the position is “.bottom”, the inverse is true - the bottom half will be unobscured, and the card will hover near the bottom of it. 0.6 placement here means that about 40% of the screen will be visible. 
4. When you use “.middle”, the entire screen will be occupied with the obscured view, and the card will remain in the center.
5. Make sure to remove the card when finished.
6. Make sure to increment the stage each time.
7. Once we’ve defined the action, we can initialize the card. 
8. Once the card has been initialized, we can modify some of the card colors and properties.
9. After modifying properties, we use the ‘resetView()’ function to apply them.
10. Finally, changing label colors happens at the last step.
