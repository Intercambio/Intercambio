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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.height / 2.0
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
        bodyLabel.text = viewModel?.body
        
        if let image = viewModel?.avatarImage {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(named: "avatar-normal")
        }
    }
}
