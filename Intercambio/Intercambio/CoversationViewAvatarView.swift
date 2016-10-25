//
//  CoversationViewAvatarView.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 25.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class CoversationViewAvatarView: UICollectionReusableView {
    
    var viewModel: ConversationViewModel? {
        didSet {
            setNeedsLayout()
        }
    }
    
    let avatar: AvatarView
    
    override init(frame: CGRect) {
        avatar = AvatarView()
        super.init(frame: frame)
        
        avatar.frame = bounds
        avatar.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        addSubview(avatar)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
