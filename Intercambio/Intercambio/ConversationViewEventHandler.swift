//
//  ConversationViewEventHandler.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 21.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import Foundation

protocol ConversationViewEventHandler: class {
    func shouldShowMenu(for itemAtIndexPtah: IndexPath) -> Bool
    func canPerformAction(_ action: Selector, forItemAt indexPath: IndexPath) -> Bool
    func performAction(_ action: Selector, forItemAt indexPath: IndexPath) -> Void
    func setValue(_ value: Any, forItemAt indexPath: IndexPath) -> Void
}
