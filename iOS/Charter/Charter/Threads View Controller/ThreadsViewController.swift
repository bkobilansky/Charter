//
//  ThreadsViewController.swift
//  Swift Mailing List
//
//  Created by Matthew Palmer on 29/01/2016.
//  Copyright © 2016 Matthew Palmer. All rights reserved.
//

import UIKit

protocol ThreadsViewControllerDelegate: class {
    func threadsViewController(threadsViewController: ThreadsViewController, didSelectEmail email: Email)
}

class ThreadsViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    private let dataSource: ThreadsViewControllerDataSource
    
    weak var delegate: ThreadsViewControllerDelegate?
    
    init(dataSource: ThreadsViewControllerDataSource) {
        self.dataSource = dataSource
        super.init(nibName: "ThreadsViewController", bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: "didRequestRefresh:", forControlEvents: .ValueChanged)
        return refreshControl
    }()
    
    override func viewDidLoad() {
        self.dataSource.registerTableView(tableView)
        
        tableView.delegate = self
        tableView.dataSource = dataSource
        navigationItem.title = dataSource.mailingList.name
        
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        
        tableView.addSubview(refreshControl)
        updateSeparatorStyle()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let selected = tableView.indexPathForSelectedRow {
            tableView.deselectRowAtIndexPath(selected, animated: true)
        }
    }
    
    private func updateSeparatorStyle() {
        if dataSource.isEmpty {
            tableView.separatorStyle = .None
        }
    }
    
    func didRequestRefresh(sender: AnyObject) {
        dataSource.refreshDataFromNetwork { (success) -> Void in
            self.refreshControl.endRefreshing()
            self.tableView.reloadData()
            self.updateSeparatorStyle()
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if dataSource.isEmpty {
            cell.userInteractionEnabled = false
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        delegate?.threadsViewController(self, didSelectEmail: dataSource.emailAtIndexPath(indexPath))
    }
}
