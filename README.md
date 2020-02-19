# GitHubFollowers

This was part of @SAllen0400's take-home project course. After completing the course, I have added few more features, such as Core Data and CloudKit implementation, to further polish the app and showcare some of my core Swift skills.

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
    

# Screen Recordings

## Core Data and CloudKit sync across devices of same iCloud account
![Alt Text](https://media.giphy.com/media/gKO2vbpLlJVzPRIQmQ/giphy.gif)

## Core Data and UITableViewDiffableDataSource
![Alt Text](https://media.giphy.com/media/H82jkCq5l5YcdH9XC5/giphy.gif)

## SafariServices
![Alt Text](https://media.giphy.com/media/MEk5d1akwmKVZpAnZR/giphy.gif)

## Deleting UITableView Row with Snapshot and updating Core Data
![Alt Text](https://media.giphy.com/media/S8MjUXWFP3DIifXDPB/giphy.gif)

## Deleting all UITableView Rows with Snapshot and updating Core Data
![Alt Text](https://media.giphy.com/media/Ka1e3EblOPWFfRJpOO/giphy.gif)

