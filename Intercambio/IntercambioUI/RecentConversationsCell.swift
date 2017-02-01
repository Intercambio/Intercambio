//
//  RecentConversationsCell.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 18.10.16.
//  Copyright © 2016, 2017 Tobias Kräntzer.
//
//  This file is part of Intercambio.
//
//  Intercambio is free software: you can redistribute it and/or modify it
//  under the terms of the GNU General Public License as published by the Free
//  Software Foundation, either version 3 of the License, or (at your option)
//  any later version.
//
//  Intercambio is distributed in the hope that it will be useful, but WITHOUT
//  ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
//  FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License along with
//  Intercambio. If not, see <http://www.gnu.org/licenses/>.
//
//  Linking this library statically or dynamically with other modules is making
//  a combined work based on this library. Thus, the terms and conditions of the
//  GNU General Public License cover the whole combination.
//
//  As a special exception, the copyright holders of this library give you
//  permission to link this library with independent modules to produce an
//  executable, regardless of the license terms of these independent modules,
//  and to copy and distribute the resulting executable under terms of your
//  choice, provided that you also meet, for each linked independent module, the
//  terms and conditions of the license of that module. An independent module is
//  a module which is not derived from or based on this library. If you modify
//  this library, you must extend this exception to your version of the library.
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
