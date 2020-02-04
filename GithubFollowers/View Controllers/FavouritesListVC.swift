//
//  FavouritesListVC.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-01-06.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import CoreData
import UIKit

class FavouritesListVC: GFDataLoadingVC {
    enum Section {
        case main
        enum Row {
            case main
        }
    }
    
    typealias SectionType = Section
    typealias ItemType = CDFollower
    
    // MARK: Core Data
    private var followerFetchRequestController: NSFetchedResultsController<CDFollower>!
    
    private var tableView: UITableView!
    private var favourites: [Follower] = []
    
    private var dataSource: DataSource!
    private var snapshot: NSDiffableDataSourceSnapshot<SectionType, ItemType>!

    // MARK: Search Controller
//    private var searchController: GFSearchController!
    private var isSearching = false
    private var currentSearchText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFetchedResultsController()
        getFavourites()
        configureViewController()
        configureTableView()
        configureDataSource()
        configureSearchController()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSnapshot()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func configureViewController() {
        view.backgroundColor = .systemBackground
        title = "Favourites"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let deleteAllButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteAllButtonTapped))
        navigationItem.rightBarButtonItem = deleteAllButton
        
    }
    
    private func configureTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        
        let inset = CGFloat(12)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: inset),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset)
        ])
        tableView.delegate = self
        tableView.register(FavouriteCell.self, forCellReuseIdentifier: FavouriteCell.reuseIdentifier)
    }
    
    private func configureDataSource() {
        dataSource = DataSource(tableView: tableView) { tableView, indexPath, favourite -> UITableViewCell? in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: FavouriteCell.reuseIdentifier, for: indexPath) as? FavouriteCell else {
                self.presentGFAlertOnMainThread(title: "Something went wrong", message: "Could not fetch Favourite Cell. Please contact the developer for support! Sorry!", buttonTitle: "OK")
                fatalError("")
            }
            cell.set(favourite: favourite)
            return cell
        }
    }
    
    private func setupSnapshot() {
        guard let favourites = followerFetchRequestController.fetchedObjects else { return }
        snapshot = NSDiffableDataSourceSnapshot<SectionType, ItemType>()
        snapshot.appendSections([.main])
        snapshot.appendItems(favourites)
        
        if favourites.isEmpty {
            if self.isSearching == false {
                DispatchQueue.main.async { self.showEmptyStateView(with: "You have not favourited any users yet!", in: self.view, tag: 99) }
                self.tableView.alpha = 0
            }
        } else {
            DispatchQueue.main.async { self.removeEmptyStateView(in: self.view, tag: 99) }
            self.tableView.alpha = 1
        }
        
        DispatchQueue.main.async { self.dataSource.apply(self.snapshot, animatingDifferences: true) }
    }
    
    private func getFavourites() {
        PersistenceManager.fetchFavourites { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let favourites):
                self.favourites = favourites
            case .failure:
                break
            }
        }
    }
}

extension FavouritesListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let item = followerFetchRequestController.object(at: indexPath)
        let userInfoVC = UserInfoVC(favourite: item, isFavourite: true)
        let nc = UINavigationController(rootViewController: userInfoVC)
        present(nc, animated: true)
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    class DataSource: UITableViewDiffableDataSource<SectionType, ItemType> {
        
        // MARK: reordering support
        
        override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
            guard let sourceIdentifier = itemIdentifier(for: sourceIndexPath) else { return }
            guard sourceIndexPath != destinationIndexPath else { return }
            let destinationIdentifier = itemIdentifier(for: destinationIndexPath)
            
            var snapshot = self.snapshot()
            
            if let destinationIdentifier = destinationIdentifier {
                if let sourceIndex = snapshot.indexOfItem(sourceIdentifier),
                    let destinationIndex = snapshot.indexOfItem(destinationIdentifier) {
                    let isAfter = destinationIndex > sourceIndex &&
                        snapshot.sectionIdentifier(containingItem: sourceIdentifier) ==
                        snapshot.sectionIdentifier(containingItem: destinationIdentifier)
                    snapshot.deleteItems([sourceIdentifier])
                    if isAfter {
                        snapshot.insertItems([sourceIdentifier], afterItem: destinationIdentifier)
                    } else {
                        snapshot.insertItems([sourceIdentifier], beforeItem: destinationIdentifier)
                    }
                }
            } else {
                let destinationSectionIdentifier = snapshot.sectionIdentifiers[destinationIndexPath.section]
                snapshot.deleteItems([sourceIdentifier])
                snapshot.appendItems([sourceIdentifier], toSection: destinationSectionIdentifier)
            }
            apply(snapshot, animatingDifferences: false)
        }
        
        // MARK: editing support
        
        override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
            return true
        }
        
        override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
            if editingStyle == .delete {
                if let identifierToDelete = itemIdentifier(for: indexPath) {
                    var snapshot = self.snapshot()
                    do {
                        CoreDataManager.shared.viewContext.delete(identifierToDelete)
                        snapshot.deleteItems([identifierToDelete])
                        try CoreDataManager.shared.viewContext.save()
                    } catch {
                        print(error.localizedDescription)
                    }
                    apply(snapshot)
                }
            }
        }
    }
}

extension FavouritesListVC: NSFetchedResultsControllerDelegate {
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        setupSnapshot()
    }
    
    private func configureFetchedResultsController() {
        let fetchRequest = NSFetchRequest<CDFollower>(entityName: CDFollower.entityName)
        let sort = NSSortDescriptor(key: "login", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        if currentSearchText != "" {
            fetchRequest.predicate = NSPredicate(format: "login CONTAINS[c] %@", currentSearchText)
        }
        
        followerFetchRequestController = NSFetchedResultsController<CDFollower>(
            fetchRequest: fetchRequest,
            managedObjectContext: CoreDataManager.shared.viewContext,
            sectionNameKeyPath: nil,
            cacheName: nil)
        
        do {
            try followerFetchRequestController.performFetch()
        } catch {
            print(error.localizedDescription)
        }
        followerFetchRequestController.delegate = self
    }
    
    @objc func deleteAllButtonTapped() {
        self.presentGFAlertActionVC(title: "Delete All Favourites?", message: "Do you wish to delete all your favourited users? This action cannot be reversed.", buttonTitle: "Delete All", buttonAction: deleteAllFavourites)
    }
    
    func deleteAllFavourites() {
        do {
            let results = try CoreDataManager.shared.viewContext.fetch(CDFollower.fetchRequest())
            for object in results {
                guard let objectData = object as? NSManagedObject else { continue }
                CoreDataManager.shared.viewContext.delete(objectData)
            }
            try CoreDataManager.shared.viewContext.save()
            isSearching = false
            setupSnapshot()
        } catch {
            self.presentGFAlertOnMainThread(title: "Something went wrong", message: "And error occured while deleting. Error: \(error.localizedDescription)", buttonTitle: "Oh no")
        }
    }
}

extension FavouritesListVC: UISearchResultsUpdating, UISearchBarDelegate {
    private func configureSearchController() {
        let searchController = GFSearchController(placeHolder: "Search for a username", textFieldBackgroundColor: UIColor.white.withAlphaComponent(0.1))
        searchController.searchResultsUpdater = self
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        searchController.searchBar.delegate = self
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        isSearching = true
        currentSearchText = text
        configureFetchedResultsController()
        setupSnapshot()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        isSearching = false
        currentSearchText = ""
        configureFetchedResultsController()
        setupSnapshot()
    }
}
