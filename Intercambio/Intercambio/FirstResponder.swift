//
//  FirstResponder.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 04.11.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

extension UIView {
    func firstResponder() -> UIView? {
        if isFirstResponder {
            return self
        } else {
            for subview in subviews {
                if let responder = subview.firstResponder() {
                    return responder
                }
            }
        }
        return nil
    }
}
