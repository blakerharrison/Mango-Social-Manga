//
//  MangaDescription.swift
//  Mango (Social Manga)
//
//  Created by bhrs on 10/5/19.
//  Copyright © 2019 Blake Harrison. All rights reserved.
//

import UIKit

class MangaDescriptionViewController: UIViewController {
    
    var mangaDescripton = ""
    
    @IBOutlet weak var textView: UITextView!
    
    override func viewDidLoad() {
        textView.text = mangaDescripton
    }
    
    
    
}
