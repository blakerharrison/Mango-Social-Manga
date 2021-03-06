//
//  MangaObject.swift
//  MangoObjectSwiftJSON
//
//  Created by Blake Harrison on 2/11/19.
//  Copyright © 2019 Blake Harrison. All rights reserved.
//

import Foundation
import RealmSwift

var chapterArray = [MangaChapter]()

struct MangaChapter {
    var number: String
    var title: String
    var id: String
    var chapterPath: String
    
    init(number: String, title: String, id: String, chapterPath: String) {
        self.number = number
        self.title = title
        self.id = id
        self.chapterPath = chapterPath
    }
}

//Realm
final class MangaChapterPersistance: Object {
    @objc dynamic var chapterTitle: String = ""
    @objc dynamic var chapterNumber: String = ""
    @objc dynamic var chapterID: String = ""
    @objc dynamic var wasChapterViewed: Bool = true
}
