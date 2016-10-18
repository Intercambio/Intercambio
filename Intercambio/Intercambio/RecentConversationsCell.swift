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
    @IBOutlet weak var timestampLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        avatarImageView.layer.cornerRadius = self.avatarImageView.bounds.height / 2.0
    }
    
    var viewModel: RecentConversationsViewModel? {
        didSet {
            updateUserInterface()
        }
    }
    
    private func updateUserInterface() {
        titleLabel.text = viewModel?.title
        timestampLabel.text = viewModel?.dateString
        bodyLabel.text = viewModel?.body
        
        if let image = viewModel?.avatarImage {
            avatarImageView.image = image
        } else {
            avatarImageView.image = UIImage(named: "avatar-normal")
        }
    }
}
