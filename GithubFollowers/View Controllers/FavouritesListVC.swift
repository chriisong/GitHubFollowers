//
//  FavouritesListVC.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-01-06.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import CoreData
import UIKit

class FavouritesListVC: UIViewController {
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

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureFetchedResultsController()
        getFavourites()
        configureViewController()
        configureTableView()
        configureDataSource()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setupSnapshot()
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
        dataSource.apply(snapshot, animatingDifferences: true)
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

extension FavouritesListVC {
    private func configureFetchedResultsController() {
        let fetchRequest = NSFetchRequest<CDFollower>(entityName: CDFollower.entityName)
        let sort = NSSortDescriptor(key: "login", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
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
    }
    
    @objc func deleteAllButtonTapped() {
        
    }
}
