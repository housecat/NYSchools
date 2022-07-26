//
//  MKMenuView.swift
//  MKCore
//
//  Created by Mikhail Kouznetsov on 8/8/17.
//  Copyright © 2017 Mikhail Kouznetsov. All rights reserved.
//

import UIKit

protocol MKTableMenuViewDelegate:class{
    func menuTabSelected( _ sender:UIButton)
}

class MKTableMenuView: UITableViewHeaderFooterView {
    
    weak var delegate:MKTableMenuViewDelegate?
    
    var scrollable:Bool = true
    var buttonArray = [UIButton]()
    var items = [String]()
    var currentTab:UIButton!

    let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        return scrollView
    }()
    
    let bottomBarRail: UIView = {
        let view = UIView()
        return view
    }()
    
    let bottomBar: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        return view
    }()

    convenience init( height:Int, scrollable:Bool = true){
        self.init(frame: CGRect(origin: .zero, size: CGSize(width: 0, height: height)))
        self.scrollable = scrollable
        self.backgroundView = UIView(frame: self.bounds)

        scrollView.frame = self.bounds
        self.contentView.addSubview(scrollView)
        
        bottomBarRail.frame.size.height = 2
        bottomBarRail.frame.origin.y = self.frame.height - bottomBarRail.frame.height
        self.scrollView.addSubview( bottomBarRail)
        
        bottomBar.frame.size.height = bottomBarRail.frame.height
        bottomBarRail.addSubview(bottomBar)
    }
    
    func buidMenu( _ tabs:[String]){
        self.items = tabs
        self.buttonArray = []
        for view in self.scrollView.subviews where view is UIButton{
            view.removeFromSuperview()
        }
        
        for (i, item) in items.enumerated() {
            let button = UIButton()
            button.setTitleColor( .lightGray, for: .normal)
            button.setTitleColor( .darkGray, for: .selected)
            button.setTitle( item.uppercased(), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .bold)
            button.titleLabel?.sizeToFit()
            button.frame.size.height = bounds.height
            
            button.tag = i
            button.addTarget( self, action: #selector(menuTabAction(_:)), for: .touchUpInside)
            
            self.scrollView.insertSubview(button, belowSubview: bottomBarRail)
            
            self.buttonArray.append(button)
        }
        
        layoutSubviews()
        displayFirstItem()
    }
    
    func displayFirstItem(){
        if let first = buttonArray.first{
            first.sendActions(for: .touchUpInside)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var scrolViewContentWidth:CGFloat = 0
        for button in buttonArray{
            var width:CGFloat = 0.0
            let minButtonWidth:CGFloat = 70
            
            button.frame.origin.x = scrolViewContentWidth
            button.frame.origin.y = 0
            
            if scrollable == true {
                if (button.titleLabel?.frame.width)! + 20 > minButtonWidth{
                    width = (button.titleLabel?.frame.width)! + 20
                } else {
                    width = minButtonWidth
                }
            } else {
                width = UIScreen.main.bounds.width / CGFloat(items.count)
                
                if button.isSelected == true {
                    bottomBar.frame.origin.x = button.frame.origin.x
                    bottomBar.frame.size.width = width
                }
            }
            
            button.frame.size.width = width
            
            scrolViewContentWidth += button.frame.width
            
            self.scrollView.contentSize = CGSize(width: scrolViewContentWidth, height: button.frame.height)
        }
        
        bottomBarRail.frame.size.width = scrolViewContentWidth
    }
    
    @objc func menuTabAction( _ sender:UIButton){
        
        currentTab = sender
        
        self.delegate?.menuTabSelected(sender)
        
        for button in buttonArray{
            button.isSelected = false
        }
        
        sender.isSelected = !sender.isSelected
        
        if scrollable == true {
            let contentOffset = sender.frame.origin.x - (self.scrollView.frame.width/2 - sender.frame.width/2) < 0 ?
                0 : sender.frame.origin.x - (self.scrollView.frame.width/2 - sender.frame.width/2)
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.bottomBar.frame = sender.frame
                self?.scrollView.contentOffset.x = contentOffset
            }) 
        } else {
            UIView.animate(withDuration: 0.2, animations: { [weak self] in
                self?.bottomBar.frame = sender.frame
            }) 
        }
    }
}
