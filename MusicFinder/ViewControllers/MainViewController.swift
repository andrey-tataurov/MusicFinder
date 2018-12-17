//
//  Created by Andrey Tataurov on 10/18/18.
//  Copyright © 2018 Andrey Tataurov. All rights reserved.
//

import UIKit

class MainTableViewController: BaseTableViewController {

    fileprivate var tracks: [Track] = []
    
    let searchController = UISearchController(searchResultsController: nil)

    required init?(coder aDecoder: NSCoder) {
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
        navigationItem.titleView = searchController.searchBar
        searchController.searchBar.delegate = self
        tableView.contentInset = UIEdgeInsets(top: 52,left: 0,bottom: 0,right: 0);
    }
}

extension MainTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = String(describing: UITableViewCell.self)
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let track = tracks[indexPath.row]
        
        guard let subtitleCell = cell else {
            fatalError("Failed to create a cell.")
        }
        subtitleCell.textLabel?.text = track.trackName
        subtitleCell.detailTextLabel?.text = track.collectionName

        let url = NSURL(string: track.artworkUrl60)! as URL
        let image = UIImage(data: try! Data(contentsOf: url), scale: 1.2)
        subtitleCell.imageView?.image = image
        
        return subtitleCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //TODO: Show Detail view
    }
}

extension MainTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text, !searchText.isEmpty {
            tracks = []
            tableView.reloadData()
            displaySpinner()
            
            fetchTracks(with: searchText)
        }
    }
}

extension MainTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
//        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
//            filteredTracks = tracks.filter { track in
//                return track.trackName.lowercased().contains(searchText.lowercased())
//            }
//
//        } else {
//            filteredTracks = tracks
//        }
//        tableView.reloadData()
    }
}

extension MainTableViewController {
    
    fileprivate func fetchTracks(with searchText: String) {
        
        let url = URL(string: "https://itunes.apple.com/search?term=\(searchText)&entity=musicTrack")!
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
//                self.handleClientError(error)
                print(error)
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                (200...299).contains(httpResponse.statusCode) else {
//                    self.handleServerError(response)
                    
                    return
            }
            if let data = data,
               let text = String(data: data, encoding: .utf8) {
                
                    guard let results = self.convertToDictionary(text: text) else {
                        return
                    }
                
                    guard let dictionaryResults = results["results"] as? [[String: Any]] else {
                        return
                    }
                
                guard let tracks = self.convertDictionaryResultsToTracks(results: dictionaryResults)  else {
                    return
                }
                
                self.tracks = tracks
//                self.filteredTracks = tracks
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.hideSpinner()
                }
            }
        }
        task.resume()
    }
    
}

extension MainTableViewController {
    
    fileprivate func convertToDictionary(text: String) -> [String: Any]? {
        
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error)
            }
        }
        return nil
    }
    
    fileprivate func convertDictionaryResultsToTracks(results: [[String: Any]]) -> [Track]? {
        do {
            let json = try JSONSerialization.data(withJSONObject: results)
            return try JSONDecoder().decode([Track].self, from: json)
        } catch {
            print(error)
        }
        return nil
    }
}
