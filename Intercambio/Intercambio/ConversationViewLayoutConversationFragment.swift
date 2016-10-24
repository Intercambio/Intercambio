//
//  ConversationViewLayoutConversationFragment.swift
//  Intercambio
//
//  Created by Tobias Kraentzer on 24.10.16.
//  Copyright © 2016 Tobias Kräntzer. All rights reserved.
//

import UIKit

class ConversationViewLayoutConversationFragment: ConversationViewLayoutAbstractFragment {
    
    override init() {
        super.init()
        childFragments = []
    }
    
    // Child Fragments
    
    func addChapter(timestamp: Date, showAvatar: Bool) {
        let chapter = ConversationViewLayoutChapterFragment(timestamp: timestamp)
        let paragraph = ConversationViewLayoutParagraphFragment(showAvatar: showAvatar)
        chapter.append(paragraph)
        childFragments.append(chapter)
    }
    
    func addParagraph(showAvatar: Bool) {
        guard let chapter = childFragments.last else {
            return
        }
        
        let paragraph = ConversationViewLayoutParagraphFragment(showAvatar: showAvatar)
        chapter.append(paragraph)
    }
    
    func addMessage(at indexPath: IndexPath, alignment: ConversationViewLayoutFragmentAlignment) {
        
        guard let chapter = childFragments.last else {
            return
        }
        
        guard let paragraph = chapter.childFragments.last else {
            return
        }
        
        let message = ConversationViewLayoutMessageFragment(indexPath: indexPath, alignment: alignment)
        paragraph.append(message)
    }
}
