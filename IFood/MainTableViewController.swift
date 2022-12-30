//
//  MainTableViewController.swift
//  IFood
//
//  Created by Артём on 28.12.2022.
//

import UIKit
import RealmSwift

class MainTableViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    private var places : Results<Place>!
    private var filteredPlaces: Results<Place>!
    private var isAscendingSorting = true
    private let searchController = UISearchController.init(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sortingSegmentedControl: UISegmentedControl!
    @IBOutlet weak var reverseSortingButton: UIBarButtonItem!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        places = StorageManager.realm.objects(Place.self)
        
        setupSearchController()
    }
    
    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }

    // MARK: - Table view data source

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         if isFiltering {
             return filteredPlaces.count
         }
         return places.count
     }

     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "MainCell", for: indexPath) as! MainCell
         
         let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
         
         cell.nameLabel.text = place.name
         cell.locationLabel.text = place.location
         cell.typeLabel.text = place.type
         cell.placeImageView.image = UIImage(data: place.imageData!)
         cell.cosmosView.rating = place.rating
         
         return cell
     }
    
    // MARK: - Table view delegate
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let place = places[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            StorageManager.deleteObject(place)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            completion(true)
        }
        
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
//     func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return 100
//    }
    
    // MARK: - Sorting IBActions
    
    @IBAction func changeSortingType(_ sender: UISegmentedControl) {
        sorting()
    }
    
    @IBAction func reverseSorting(_ sender: UIBarButtonItem) {
        isAscendingSorting.toggle()
        
        if isAscendingSorting {
            reverseSortingButton.image = #imageLiteral(resourceName: "AZ")
        } else {
            reverseSortingButton.image = #imageLiteral(resourceName: "ZA")
        }
        sorting()
    }
    
    private func sorting() {
        if sortingSegmentedControl.selectedSegmentIndex == 0 {
            if isFiltering {
                filteredPlaces = filteredPlaces.sorted(byKeyPath: "date", ascending: isAscendingSorting)
            } else {
                places = places.sorted(byKeyPath: "date", ascending: isAscendingSorting)
            }
            
        } else {
            if isFiltering {
                filteredPlaces = filteredPlaces.sorted(byKeyPath: "name", ascending: isAscendingSorting)
            } else {
                places = places.sorted(byKeyPath: "name", ascending: isAscendingSorting)
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail",
           let detailVC = segue.destination as? DetailTableViewController {
            guard let indexPath = tableView.indexPathForSelectedRow else {return}
            let place = isFiltering ? filteredPlaces[indexPath.row] : places[indexPath.row]
            detailVC.currentPlace = place
        }
    }
    
    
    @IBAction func unwindSegue(_ segue: UIStoryboardSegue) {
        guard let newPlaceVC = segue.source as? DetailTableViewController else { return }
        newPlaceVC.savePlace()
        tableView.reloadData()
    }
    
}

extension MainTableViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
    private func filterContentForSearchText(searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        tableView.reloadData()
    }
    
}
