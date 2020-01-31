//
//  UserInfoVC.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-01-11.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import CoreData
import UIKit

protocol UserInfoDelegate: class {
        func didTapGitHubProfile(for user: CDUser)
        func didTapGetFollowers(for user: CDUser)
}

class UserInfoVC: UIViewController {
    
    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    let dateLabel = GFBodyLabel(textAlignment: .center)
    var itemViews: [UIView] = []
    
    weak var delegate: FollowerListDelegate!
    
    var follower: Follower!
    var favourite: CDFollower!
    
    var isFavourite = false
    var isAlreadySaved = false
    
    var _user: CDUser!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
        configureNavigationBar()
        getUserInfo()
    }
    
    private func configureNavigationBar() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        
        navigationItem.rightBarButtonItems = [doneButton]
    }
    
    
    private func getUserInfo() {
        NetworkManager.shared.getUserInfo(for: isFavourite ? favourite.login : follower.login) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let user):
                DispatchQueue.main.async {
                    if CoreDataManager.shared.checkForRedudantUser(username: user.login) == false {
                        CoreDataManager.shared.saveToUserAndRetreive(user: user) { [weak self] cdUser in
                            guard let self = self else { return }
                            self._user = cdUser
                            self.configureUIElements(user: user)
                        }
                    } else {
                        self._user = CoreDataManager.shared.retrieveUserData(username: user.login)
                        self.configureUIElements(user: user)
                        return
                    }
                }
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "OK")
            }
        }
    }
    func configureUIElements(user: User) {
        let repoItemVC = GFRepoItemVC(coreData: _user, userDefaults: user)
        repoItemVC.delegate = self
        
        let followerItemVC = GFFollowerItemVC(coreData: _user, userDefaults: user)
        followerItemVC.delegate = self
        
        self.add(childVC: GFUserInfoHeaderVC(coreData: _user, userDefaults: user), to: self.headerView)
        self.add(childVC: repoItemVC, to: self.itemViewOne)
        self.add(childVC: followerItemVC, to: self.itemViewTwo)
        self.dateLabel.text = "GitHub since " + user.createdAt.convertToDisplayFormat()
    }
    
    private func add(childVC: UIViewController, to containerView: UIView) {
        addChild(childVC)
        containerView.addSubview(childVC.view)
        childVC.view.frame = containerView.bounds
        childVC.didMove(toParent: self)
    }
    private func layoutUI() {
        let inset = CGFloat(20)
        let itemHeight = CGFloat(140)
        
        itemViews = [headerView, itemViewOne, itemViewTwo, dateLabel]
        itemViews.forEach { itemView in
            view.addSubview(itemView)
            itemView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                itemView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset),
                itemView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset)
            ])
        }
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            headerView.heightAnchor.constraint(equalToConstant: 180),
            
            itemViewOne.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: inset),
            itemViewOne.heightAnchor.constraint(equalToConstant: itemHeight),
            
            itemViewTwo.topAnchor.constraint(equalTo: itemViewOne.bottomAnchor, constant: inset),
            itemViewTwo.heightAnchor.constraint(equalToConstant: itemHeight),
            
            dateLabel.topAnchor.constraint(equalTo: itemViewTwo.bottomAnchor, constant: inset),
            dateLabel.heightAnchor.constraint(equalToConstant: 18)
        ])
    }
    
    @objc func dismissVC() {
        dismiss(animated: true)
    }
}
extension UserInfoVC: UserInfoDelegate {
    func didTapGitHubProfile(for user: CDUser) {
        guard let url = URL(string: user.htmlUrl) else {
            presentGFAlertOnMainThread(title: "Invalid URL", message: "The URL attached to this user is invalid", buttonTitle: "OK")
            return
        }
        presentSafariVC(with: url)
    }
    
    func didTapGetFollowers(for user: CDUser) {
        guard user.followers != 0 else {
            presentGFAlertOnMainThread(title: "No followers", message: "This user has no followers.", buttonTitle: "Aww")
            return
        }
        
        if isFavourite {
            let vc = FollowerListVC()
            vc._user = self._user
            vc.title = self._user.login
            vc.username = self._user.login
            vc.page = 1
            navigationController?.pushViewController(vc, animated: true)
        } else {
            delegate.didRequestFollowers(for: user.login)
            dismissVC()
        }
    }
}
