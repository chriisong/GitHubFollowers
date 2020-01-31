# GitHubFollowers

This project is to showcase some of my core Swift skills.
* Result Type
    * new to Swift 5, this Result Type allows for clean handling of success and failure cases
* Custom Views
    * Created reusable custom views (i.e. buttons, labels, textfields) to reduce redundancy and allow for clean code practices
    * used custom initializers to handle different needs for each custom view
* 100% programmatic
    * Not that storyboards are evil, but it was my goal to pursue programmatic approach to UI build for larger environments where merging storyboard is not possible.
* No 3rd-party library
    * Displaying core skills using Apple’s standard libraries and frameworks without relying on third party dependencies.
* Diffable Data Source
    * Introduced in WWDC 2019, Diffable Data Source is Apple’s additional step toward declarative programming that handles the complexity of dealing with UI state into UIKit itself, resulting in faster and stable performing apps. 
    * UICollectionViewDiffableDataSource and UITableViewDiffableDataSource in conjunction with NSDiffableDataSourceSnapshot has provided an easier and cleaner way of programmatically handling tableView and collectionView, with an additional diffing animation bonus that the traditional APIs cannot provide.
* Core Data and CloudKit
    * This app handles persistence using Core Data and CloudKit using the latest NSPersistenceCloudKitContainer, which allows multiple-devices to stay in sync under the same iCloud account.
