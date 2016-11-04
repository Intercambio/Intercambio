//
//  FormButtonItemCell.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

public class FormButtonItemCell: UITableViewCell {

    public static var predicate: NSPredicate {
        return NSPredicate(block: { (item, options) -> Bool in
            return item is FormButtonItem
        })
    }
    
    public let button: UIButton
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        button = UIButton(type: .system)
        
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleAction), for: .touchUpInside)
        
        addSubview(button)
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[button]-|",
                                                      options: [],
                                                      metrics: [:],
                                                      views: ["button":button]))
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-[button]-|",
                                                      options: [],
                                                      metrics: [:],
                                                      views: ["button":button]))
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var item: FormButtonItem? {
        didSet {
            button.setTitle(item?.title, for: .normal)
            button.isEnabled = item?.enabled ?? false
            if item?.destructive ?? false {
                button.tintColor = UIColor.red
            } else {
                button.tintColor = nil
            }
        }
    }
    
    @objc private func handleAction() {
        
        if let item = self.item {
            if item.destructive == false {
                performAction(item.action, sender: self)
            } else {

                let doAction = UIAlertAction(title: item.title, style: .destructive) { (action) in
                    self.performAction(item.action, sender: self)
                }
                
                let cancelAction = UIAlertAction(title: "Cancle", style: .cancel, handler: nil)
                
                let alert = UIAlertController(title: nil, message: item.destructionMessage, preferredStyle: .actionSheet)
                
                alert.addAction(doAction)
                alert.addAction(cancelAction)
                
                if let viewControler = window?.rootViewController?.presentedViewController {
                    viewControler.present(alert, animated: true, completion: nil)
                } else if let viewControler = window?.rootViewController {
                    viewControler.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
