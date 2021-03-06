//
//  NetworkManager.swift
//  GameLogger
//
//  Created by Henry Cooper on 22/08/2018.
//  Copyright © 2018 Henry Cooper. All rights reserved.
//

import UIKit

class NetworkManager: NSObject {
    
    // MARK: - Method for searching
    
    class func getDataFor(searchTerm: String, completion: @escaping ([Game]) -> ()) {
        
        let urlString = "https://api-endpoint.igdb.com/games/?search=\(searchTerm)&fields=name,summary,cover,screenshots,rating&filter[summary][exists]=true&order=rating:desc"
        guard let percentEncodingString = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        guard let gameURL = URL(string: percentEncodingString) else { return }
        parseJSONFrom(gameURL) { (games) in
            completion(games)
        }
    }
    
    // MARK: - Method for parsing JSON

    
    private class func parseJSONFrom(_ url: URL, completion: @escaping ([Game]) -> ()) {
        
        var games: [Game] = []
        var gameRequest = URLRequest(url: url)
        gameRequest.setValue("3855e34ce36dcb0a762eda82cac2f050", forHTTPHeaderField: "user-key")
        gameRequest.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: gameRequest) { (data, response, error) in
            
            if error != nil {
                print("Data task error: \(error!.localizedDescription)")
            }
            
            guard let responseData = data else {
                print("Error getting response data")
                return
            }
            
            guard let json = try? JSONSerialization.jsonObject(with: responseData),
                let mainArray = json as? [[String:Any]] else {
                    print("Error serialising JSON")
                    return
            }
            
            for dict in mainArray {
                guard let newGame = Game(withDictionary: dict) else { continue }
                games.append(newGame)
            }
            
            completion(games)
            
        }
        task.resume()
        
    }

    
    // MARK: - Method for downloading image
    
    class func downloadImageFrom(_ url: URL, completion: @escaping (UIImage) -> ()) {
        
        let stringUrl = "https:\(url)"
        guard let finalUrl = URL(string: stringUrl) else { return }
        let task = URLSession.shared.downloadTask(with: finalUrl) { (url, urlResponse, error) in
            
            if error != nil {
                print("Error downloading from URL")
                return
            }
            
            guard let url = url else { return }
            guard let data = try? Data(contentsOf: url) else { return }
            guard let imageToReturn = UIImage(data: data) else { return }
            
            completion(imageToReturn)
        }
        task.resume()
    }
    
    class func getPopularGames(completion: @escaping ([Game]) -> Void) {
        guard let url = URL(string: "https://api-endpoint.igdb.com/games/?fields=name,cover,screenshots,id,summary,rating,popularity&filter[release_dates.date][gte]=2018-01-01&filter[rating][gt]=85&filter[summary][exists]=true&order=popularity:desc") else { return }
        parseJSONFrom(url) { (games) in
            completion(games)
        }
    }
    
    
  // MARK: - Method for downloading images when detailView is accessed
  
    class func getScreenshots(game: Game, completion: () -> ()){
        guard let screenshotUrls = game.screenshotsURLs else { return }
        for url in screenshotUrls{
            do{
                let data = try Data(contentsOf: url)
                if let image = UIImage(data: data) {
                    game.screenshots?.append(image)
                    completion()
                }
            } catch let error {
                print("Unable to load data: \(error)")
            }
        }
    }
    
    class func getGameFromIds(_ ids: [Int], completion: @escaping ([Game]) -> ()) {
        var gamesToReturn = [Game]()
        
        for id in ids {
            guard let url = URL(string:"https://api-endpoint.igdb.com/games/\(id)/") else { fatalError("Game Id does not exist") }
            parseJSONFrom(url) { (games) in
                guard let game = games.first else { fatalError() }
                gamesToReturn.append(game)
                if gamesToReturn.count == ids.count {
                    completion(gamesToReturn)
                }
            }
        }
    }
}
