//
//  MangaDetail.swift
//  Mango (Social Manga)
//
//  Created by Blake Harrison on 9/6/18.
//  Copyright © 2018 Blake Harrison. All rights reserved.
//

import UIKit
import SwiftyJSON
import RealmSwift

var selectedIndex = 0
var selectedID = ""
var selectedChapterID = ""
var currentChapter = ""
var mangaDataStructure = MangaDataStructure()

var currentMangaObject = RealmMangaObject()
var currentChaptersObject = RealmChapterObject()
var wasChapterViewed = RealmChapterViewed()

var chaptersArray = [MangaChapter]()

var chaptersArray2 = [[Any]]()

class MangaDetail: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: - Properties
    let networking = MangoNetworking()
    var mangaChapters: [[MetadataType?]] = [[]]
    var realm = try! Realm()

    //MARK: - Outlets
    @IBOutlet weak var mangaImage: UIImageView!
    @IBOutlet weak var authorLabel: UILabel!
    @IBOutlet weak var mangaDescription: UITextView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var categoriesLabel: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var releasedLabel: UILabel!
    @IBOutlet weak var readButton: UIButton!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var descriptionTitle: UILabel!
    @IBOutlet weak var activityDetails: UIActivityIndicatorView!
    
    //MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        activity.isHidden = false
        activity.startAnimating()
        
        activityDetails.isHidden = false
        activityDetails.startAnimating()

        toggleIsMangaBeingViewed()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(ReloadTableView(_:)),
                                               name: .ChapterWasAppended,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(UpdateUI(_:)),
                                               name: .ChapterDetailsWereFetched,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(toggleIsMangaBeingViewed(_:)),
                                               name: .MangaDetailWasExited,
                                               object: nil)


//        fetchMangaInfo(mangaID: selectedID)
        
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.font: UIFont(name: Fonts.Knockout.rawValue, size: 21)!]
        navigationItem.title = searchedMangaList[selectedIndex].t!
        
        mangaImage.addShadow()
        
        readButton.layer.cornerRadius = 5
    }
    
    override func viewWillAppear(_ animated: Bool) {
        chapterArray.removeAll()
        networking.fetchChapterDetails(chapterID: selectedID)
        networking.fetchChapters(mangaID: selectedID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        selectedIndex = 0
    }

    //MARK: - Methods
    @objc func ReloadTableView(_ notification: Notification) {
        DispatchQueue.main.async {
            chapterArray.reverse()
            self.tableView.reloadData()
            self.activity.isHidden = true
            self.activity.stopAnimating()
        }
    }
    
    @objc func UpdateUI(_ notification: Notification) {
        
        self.fetchImage()
        
        DispatchQueue.main.async {
            self.mangaDescription.text = currentManga.description
            self.authorLabel.text = "Author : " + currentManga.author
            self.categoriesLabel.text = "Category : " + currentManga.category
            self.releasedLabel.text = "Released : " + currentManga.released
            self.statusLabel.text = "Status :"
            self.descriptionTitle.text = "Description : "
            
            self.activityDetails.isHidden = true
            self.activityDetails.stopAnimating()
        }
    }
    
    @objc func toggleIsMangaBeingViewed(_ notification: Notification) {
        networking.isMangaDetailBeingViewed = false
    }
    
    func toggleIsMangaBeingViewed() {
        networking.isMangaDetailBeingViewed = false
    }
    
    fileprivate func setUIDetails(_ json: JSON, _ mangaInfo: MangaInfoAndChapterList) {

            let updatedStringDiscription = json["description"].string!.replacingOccurrences(of: "&rsquo;", with: "'", options: .literal, range: nil).replacingOccurrences(of: "&#039;", with: "'", options: .literal, range: nil).replacingOccurrences(of: "&ndash;", with: "-", options: .literal, range: nil).replacingOccurrences(of: "&ldquo;", with: "\"", options: .literal, range: nil).replacingOccurrences(of: "&rdquo;", with: "\"", options: .literal, range: nil).replacingOccurrences(of: "&#333;", with: "o", options: .literal, range: nil).replacingOccurrences(of: "&quot;", with: "\"").replacingOccurrences(of: "%27", with: "'", options: .literal, range: nil).replacingOccurrences(of: "&#39;", with: "'", options: .literal, range: nil)
            
            self.fetchImage()
        
        DispatchQueue.main.async {
            self.mangaDescription.text = updatedStringDiscription
        }
        
         DispatchQueue.main.async {
            self.authorLabel.text = "Author : " + json["author"].string!
        }
        
         DispatchQueue.main.async {
            self.categoriesLabel.text = "Category : " + json["categories"][0].stringValue
        }
         DispatchQueue.main.async {
            self.releasedLabel.text = "Released : " + json["released"].stringValue
        }

         DispatchQueue.main.async {
            if json["status"].int! == 1 {
                self.statusLabel.text = "Status : Ongoing"
            } else if json["status"].int! == 2 {
                self.statusLabel.text = "Status : Completed"
            }
        }
        
            self.mangaChapters = mangaInfo.chapters
            
            mangaDataStructure.removeIDs()
        
            if mangaInfo.chapters.isEmpty {
                return
            } else {
                let chapterID = mangaInfo.chapters[1][3]!
                print(chapterID)
            }
    }
    
    fileprivate func setUIImage(_ data: Data?) {
        DispatchQueue.main.async {
            self.mangaImage.image = UIImage(data: data!)
        }
    }
    
    //MARK: - Networking
    func fetchImage() { //TODO: Move to MangoNetworking
        
        guard searchedMangaList[selectedIndex].im != nil else {
            print("No Image")
            return
        }
        
//        networking.mangaImageURL + searchedMangaList[selectedIndex].im!
        
        guard let url = URL(string: currentManga.imageURL) else { return }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil {
                print("Failed fetching image:", error!)
                return
            }
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Not a proper HTTPURLResponse or statusCode")
                
                let alert = UIAlertController(title: "Connection Error", message: "404", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
            }
            
            self.setUIImage(data)
            
            }.resume()
    }
    
    func fetchMangaInfo(mangaID: String) { //TODO: Move to MangoNetworking

        guard let url = URL(string: networking.mangaURL + mangaID) else {return}
        
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data,
                error == nil else {
                    print(error?.localizedDescription ?? "Response Error")
                    return }
            do{
                //here dataResponse received from a network request
                _ = try JSONSerialization.jsonObject(with:
                    dataResponse, options: [])
                
                let decoder = JSONDecoder()
                
                let mangaInfo = try decoder.decode(MangaInfoAndChapterList.self, from: data!)
                
                let json = try JSON(data: data!)
                
                self.setUIDetails(json, mangaInfo)
   
            } catch let parsingError {
                print("Error", parsingError)
                self.activity.isHidden = true
                self.activity.stopAnimating()
            }
        }
        task.resume()
    }
 
    
    //MARK: - Actions
    @IBAction func reverseChapterOrder(_ sender: Any) {
        
        guard mangaDataStructure.isMangaChaptersReversed == false else {
            
            mangaDataStructure.mangaChaptersString.reverse()
            mangaDataStructure.reverseIDs()
            tableView.reloadData()
            mangaDataStructure.isMangaChaptersReversed = false
            return
        }
        
        mangaDataStructure.mangaChaptersString.reverse()
        mangaDataStructure.reverseIDs()
        tableView.reloadData()
        
        mangaDataStructure.isMangaChaptersReversed = true
        
        print("Structure of the Manga is \(mangaDataStructure.isMangaChaptersReversed)")
    }
    
    //TODO: - Add an aciton button for Read. !@#$%^&*()
    @IBAction func reloadTableView(_ sender: Any) {
        activity.isHidden = true
        self.tableView.reloadData()
    }
    
    //MARK: - Table View
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chapterArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chapters", for: indexPath)
        
        if let label = cell.viewWithTag(1000) as? UILabel {
            
            label.text = "\(chapterArray[indexPath.row].number) - \(chapterArray[indexPath.row].title)"
            
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if mangaDataStructure.mangaChapterIDs.count == 0 {
            return
        }

        networking.fetchPages(chapterID: chaptersArray[indexPath.row].id)
        
        currentChapter = mangaDataStructure.mangaChaptersString.reversed()[indexPath.row]
        mangaDataStructure.currentChapterIndex = indexPath.row
        selectedChapterID = mangaDataStructure.mangaChapterIDs.reversed()[indexPath.row]
        
        currentChapter = String(chaptersArray[indexPath.row].number)

        self.tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "readerSegue", sender: self)
        
    }
}

// URLContainer
extension Notification.Name {
    static let ChapterWasAppended = NSNotification.Name("ChapterWasAppended")
    
    static let ChapterDetailsWereFetched = NSNotification.Name("ChapterDetailsWereFetched")
    
    static let MangaDetailWasExited  = NSNotification.Name("MangaDetailWasExited")
}
