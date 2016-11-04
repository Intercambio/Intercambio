//
//  FormValueItemCell.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class FormValueItemCell: UITableViewCell {

    public static var predicate: NSPredicate {
        return NSPredicate(block: { (item, options) -> Bool in
            return item is FormValueItem
        })
    }
    
    public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .value1, reuseIdentifier: reuseIdentifier)
    }
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public var item: FormValueItem? {
        didSet {
            textLabel?.text = item?.title
            detailTextLabel?.text = item?.value
        }
    }
}
