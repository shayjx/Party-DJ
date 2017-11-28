//
//  ArtistViewController.swift
//  Party-DJ
//
//  Created by Shana Joseph on 11/26/17.
//  Copyright © 2017 Shana Joseph. All rights reserved.
//

import UIKit

class ArtistViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var track: Track!
    var artist: Artist!
    var album: Album!
    
    var topTracks: [Track] = []
    var albums: [Album] = []
    
    var addedtoQueue: [Bool]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = self
        tableView.delegate = self
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        if album != nil {
            var dictionary: [String: Any] = [:]
            dictionary["id"] = album.artists[0]["id"]
            dictionary["name"] = album.artists[0]["name"]
            dictionary["images"] = album.images
            dictionary["userId"] = User.current?.id
            dictionary["uri"] = album.artists[0]["uri"]
            artist = Artist(dictionary)
        }
        
        if !artist.images.isEmpty {
            let imageDictionary = artist.images[0]["url"]
            let url = URL(string: imageDictionary as! String)
            backgroundImageView.af_setImage(withURL: url!)
        }
        
        nameLabel.text = artist.name
        
        let artistURI = artist.uri
        APIManager.current?.getTopTracks(artistURI: URL(string: artistURI)!, user: User.current, callback: { (topTracks) in
            self.topTracks = topTracks
            self.addedtoQueue = [Bool](repeating: false, count: topTracks.count)
            self.tableView.reloadData()
        })
        
        APIManager.current?.getAlbumsByArtist(artistURI: URL(string: artistURI)!, user: User.current, callback: { (albums) in
            self.albums = albums
            self.collectionView.reloadData()
        })
        
        let navBar = self.navigationController!.navigationBar
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.isTranslucent = true
        navBar.tintColor = UIColor.white
        self.navigationController?.view.backgroundColor = .clear
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topTracks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
        cell.track = topTracks[indexPath.row]
        
        if addedtoQueue[indexPath.row] {
            // indicate track has been added
            cell.selectionStyle = .none
            cell.addTrackImageView.image = UIImage(named: "check")
        } else {
            // indicate track has not been added
            cell.selectionStyle = .default
            cell.addTrackImageView.image = UIImage(named: "plus")
        }
        let backgroundColorView = UIView()
        backgroundColorView.backgroundColor = UIColor.clear
        cell.selectedBackgroundView = backgroundColorView
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !addedtoQueue[indexPath.row] {
            // reload tableview
            addedtoQueue[indexPath.row] = true
            tableView.reloadData()
            
            // get the track
            let track = topTracks[indexPath.row]
            let searchCell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath) as! SearchResultCell
            searchCell.track = track
            
            // add track to playlist
            Queue.current!.addTrack(track, user: User.current!)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AlbumCell", for: indexPath) as! AlbumCell
        cell.album = albums[indexPath.item]
        return cell
        
        
    }
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UICollectionViewCell
        if let indexPath = collectionView.indexPath(for: cell) {
            let album = albums[indexPath.item]
            let albumViewController = segue.destination as! AlbumViewController
            albumViewController.album = album
            albumViewController.track = track
        }
    }
}


