//
//  Created by Andrey Tataurov on 10/18/18.
//  Copyright © 2018 Andrey Tataurov. All rights reserved.
//

import UIKit

class MainTableViewController: BaseTableViewController {

    fileprivate var tracks: [Track]
    fileprivate var filteredTracks: [Track]
    
    let searchController = UISearchController(searchResultsController: nil)

    required init?(coder aDecoder: NSCoder) {
//        fatalError("Initializer is not implemented")
        tracks = []
        filteredTracks = []
        
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        searchController.searchResultsUpdater = self
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.dimsBackgroundDuringPresentation = false
//        tableView.tableHeaderView = searchController.searchBar
        navigationItem.titleView = searchController.searchBar
        self.tableView.contentInset = UIEdgeInsets(top: 52,left: 0,bottom: 0,right: 0);
        
        //TODO: load data here from the web-service, also import it
        fetchTracks(with: "nirvana")
    }


}

extension MainTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return filteredTracks.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellIdentifier = String(describing: UITableViewCell.self)
        var cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
        }
        
        let track = filteredTracks[indexPath.row]
        
        guard let subtitleCell = cell else {
            fatalError("Failed to create a cell.")
        }
        subtitleCell.textLabel?.text = track.trackName
        subtitleCell.detailTextLabel?.text = track.collectionName
        
        return subtitleCell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
//        let charge = availableCharges[indexPath.row]
//        completion(charge)
        //TODO: Show Detail view
        
    }
}

extension MainTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
        if let searchText = searchController.searchBar.text, !searchText.isEmpty {
            filteredTracks = tracks.filter { track in
                return track.trackName.lowercased().contains(searchText.lowercased())
            }

        } else {
            filteredTracks = tracks
        }
        tableView.reloadData()
    }
}

extension MainTableViewController {
    
    fileprivate func fetchTracks(with searchText: String) {
        
        let url = URL(string: "https://itunes.apple.com/search?term=nirvana&entity=musicTrack")!
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
                self.filteredTracks = tracks
                DispatchQueue.main.async {
                    self.tableView.reloadData()
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
