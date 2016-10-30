//
//  ContactPickerViewController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 30.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class ContactPickerViewController: UIViewController, CLTokenInputViewDelegate {
    
    class View : UIView {
        let contentView: UIView
        override init(frame: CGRect) {
            contentView = UIView()
            contentView.translatesAutoresizingMaskIntoConstraints = false
            super.init(frame: frame)
            addSubview(contentView)
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
            if contentView.frame.contains(point) {
                return super.hitTest(point, with: event)
            } else {
                return nil
            }
        }
    }
    
    var contentView: UIView? {
        if let view = self.view as? View {
            return view.contentView
        } else {
            return nil
        }
    }
    
    var backgroundView: UIVisualEffectView?
    var searchBar: CLTokenInputView?
    
    override func loadView() {
        let view = View()
        view.translatesAutoresizingMaskIntoConstraints = false
        self.view = view
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[contentView]|",
                                                           options: [],
                                                           metrics: [:],
                                                           views: ["contentView": view.contentView]))
        
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[top][contentView]",
                                                           options: [],
                                                           metrics: [:],
                                                           views: ["contentView": view.contentView,
                                                                   "top": topLayoutGuide]))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupBackgroundView()
        setupSearchBar()
    }
    
    private func setupSearchBar() {
        if let contentView = self.contentView {
            
            let searchBar = CLTokenInputView()
            searchBar.translatesAutoresizingMaskIntoConstraints = false
            searchBar.backgroundColor = UIColor.clear
            searchBar.keyboardType = .emailAddress
            searchBar.placeholderText = "Enter Address"
            searchBar.drawBottomBorder = true
            searchBar.delegate = self
            
            contentView.addSubview(searchBar)
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[searchBar]|",
                                                                      options: [],
                                                                      metrics: [:],
                                                                      views: ["searchBar":searchBar]))
            contentView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[searchBar]|",
                                                                      options: [],
                                                                      metrics: [:],
                                                                      views: ["searchBar":searchBar]))
            
            
            self.searchBar = searchBar
        }
    }
    
    private func setupBackgroundView() {
        if let contentView = self.contentView {
            
            let effect = UIBlurEffect(style: .extraLight)
            let backgroundView = UIVisualEffectView(effect: effect)
            backgroundView.translatesAutoresizingMaskIntoConstraints = false
            
            view.insertSubview(backgroundView, belowSubview: contentView)
            view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[backgroundView]|",
                                                               options: [],
                                                               metrics: [:],
                                                               views: ["backgroundView": backgroundView]))
            
            view.addConstraint(NSLayoutConstraint(item: contentView,
                                                  attribute: .top,
                                                  relatedBy: .equal,
                                                  toItem: backgroundView,
                                                  attribute: .top,
                                                  multiplier: 1,
                                                  constant: 0))
            
            view.addConstraint(NSLayoutConstraint(item: contentView,
                                                  attribute: .bottom,
                                                  relatedBy: .equal,
                                                  toItem: backgroundView,
                                                  attribute: .bottom,
                                                  multiplier: 1,
                                                  constant: 0))
            
            self.backgroundView = backgroundView
        }
    }
    
    // CLTokenInputViewDelegate
    
    func tokenInputView(_ view: CLTokenInputView, didChangeHeightTo height: CGFloat) {
        
    }
    
    func tokenInputView(_ view: CLTokenInputView, tokenForText text: String) -> CLToken? {
        return nil
    }
}
