//
//  RecentConversationsCell.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 18.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class RecentConversationsCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var chevronLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    var isChevronHidden: Bool = false {
        didSet {
            chevronLabel.isHidden = isChevronHidden
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        chevronLabel.font = UIFont(name: chevronLabel.font.fontName, size: timestampLabel.font.pointSize * 1.3)
    }
    
    var viewModel: RecentConversationsViewModel? {
        didSet {
            updateUserInterface()
        }
    }
    
    private func updateUserInterface() {
        titleLabel.text = viewModel?.title
        subtitleLabel.text = viewModel?.subtitle
        subtitleLabel.isHidden = viewModel?.subtitle == nil
        timestampLabel.text = viewModel?.dateString
        avatarImageView.image = viewModel?.avatarImage
        bodyLabel.text = viewModel?.body
        
        if viewModel?.type == .error {
            bodyLabel.textColor = #colorLiteral(red: 0.9254902005, green: 0.2352941185, blue: 0.1019607857, alpha: 1)
        } else {
            bodyLabel.textColor = #colorLiteral(red: 0.6666666667, green: 0.6666666667, blue: 0.6666666667, alpha: 1)
        }
    }
}
