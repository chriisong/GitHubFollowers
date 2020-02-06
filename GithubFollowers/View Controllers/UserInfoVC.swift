//
//  UserInfoVC.swift
//  GithubFollowers
//
//  Created by Chris Song on 2020-01-11.
//  Copyright © 2020 Chris Song. All rights reserved.
//

import CoreData
import UIKit

protocol UserInfoVCDelegate: class {
    func didRequestFollowers(for username: String)
}

class UserInfoVC: GFDataLoadingVC {
    
    let headerView = UIView()
    let itemViewOne = UIView()
    let itemViewTwo = UIView()
    let dateLabel = GFBodyLabel(textAlignment: .center)
    var itemViews: [UIView] = []
    
    weak var delegate: UserInfoVCDelegate!
    
    var follower: Follower!
    var favourite: CDFollower!
    
    var isFavourite = false
    var isFromHome = false
    var isAlreadySaved = false
    
    var _user: CDUser!
    
    init(follower: Follower, isFromHome: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.follower = follower
        self.isFromHome = isFromHome
    }
    
    init(favourite: CDFollower, isFavourite: Bool) {
        super.init(nibName: nil, bundle: nil)
        self.favourite = favourite
        self.isFavourite = isFavourite
    }
    
    init(cdUser: CDUser?, follower: Follower, delegate: UserInfoVCDelegate) {
        super.init(nibName: nil, bundle: nil)
        self._user = cdUser
        self.follower = follower
        self.delegate = delegate
    }
    
    required init?(coder: NSCoder) { fatalError("") }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        layoutUI()
        configureNavigationBar()
        getUserInfo()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    private func configureNavigationBar() {
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissVC))
        let addButton = UIBarButtonItem(image: Images.favouriteImage, style: .plain, target: self, action: #selector(addButtonTapped))
        navigationItem.leftBarButtonItems = isFromHome ? [] : [doneButton]
        navigationItem.rightBarButtonItem = addButton
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
        self.dateLabel.text = "GitHub since " + user.createdAt.convertToMonthYearFormat()
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
            headerView.heightAnchor.constraint(equalToConstant: 210),
            
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
    
    @objc func addButtonTapped() {
        showLoadingView()
        
        NetworkManager.shared.getUserInfo(for: isFavourite ? favourite.login : follower.login) { [weak self] result in
            guard let self = self else { return }
            self.dismissLoadingView()
            switch result {
            case .success(let user):
                let favourite = Follower(login: user.login, avatarUrl: user.avatarUrl)
                
                DispatchQueue.main.async {
                    CoreDataManager().updateWith(favourite: favourite, actionType: .add) { [weak self] error in
                        guard let self = self else { return }
                        guard let error = error else {
                            self.presentGFAlertOnMainThread(title: "Success!", message: "Successfully favourited this user.", buttonTitle: "Sweet.")
                            return
                        }
                        self.presentGFAlertOnMainThread(title: "Something went wrong", message: error.rawValue, buttonTitle: "Boo.")
                    }
                }
            case .failure(let error):
                self.presentGFAlertOnMainThread(title: "Something went wrong.", message: error.rawValue, buttonTitle: "OK")
            }
        }
    }
}
extension UserInfoVC: ItemInfoVCDelegate {
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
        
        if isFavourite || isFromHome {
            let vc = FollowerListVC(cdUser: self._user, page: 1)
            navigationController?.pushViewController(vc, animated: true)
        } else {
            delegate.didRequestFollowers(for: user.login)
            dismissVC()
        }
    }
}
