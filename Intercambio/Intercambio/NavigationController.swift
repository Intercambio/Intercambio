//
//  NavigationController.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 02.08.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

public class NavigationController: UINavigationController, NavigationControllerView {
    
    var presenter: NavigationControllerViewEventHandler?
    var status: [NavigationControllerStatusViewModel]? {
        didSet {
            updateStatus()
        }
    }
    
    func didTapStatus(sender: NavigationBarStatusView) {
        if let status = sender.status {
            presenter?.didTap(status: status)
        }
    }
    
    private func updateStatus() {
        if let bar = navigationBar as? NavigationBar {
            for view in bar.contentView.arrangedSubviews {
                view.removeFromSuperview()
            }
            if let status = self.status {
                for item in status {
                    let view = NavigationBarStatusView()
                    view.translatesAutoresizingMaskIntoConstraints = false
                    view.status = item
                    view.addTarget(self, action: #selector(didTapStatus(sender:)), for: .touchUpInside)
                    bar.contentView.addArrangedSubview(view)
                }
            }
            bar.triggerLayoutUpdate()
        }
    }
}
