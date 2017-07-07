//
//  ViewController.swift
//  ExpandingTVHeader
//
//  Created by Tim Beals on 2017-07-07.
//  Copyright © 2017 Tim Beals. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let headerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.blue
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var headerViewHeightConstraint: NSLayoutConstraint!
    let maxHeaderHeight: CGFloat = 88
    let minHeaderHeight: CGFloat = 0
    
    lazy var tableView: UITableView = {
        let tableview = UITableView()
        tableview.translatesAutoresizingMaskIntoConstraints = false
        tableview.delegate = self
        tableview.dataSource = self
        return tableview
    }()
    
    var previousScrollOffset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "View Controller"
        
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        headerViewHeightConstraint.constant = maxHeaderHeight
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupViews() {
        let navHeight = (self.navigationController?.navigationBar.frame.height)! + UIApplication.shared.statusBarFrame.height
        
        view.addSubview(headerView)
        headerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        headerView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        headerView.topAnchor.constraint(equalTo: view.topAnchor, constant: navHeight).isActive = true
        headerView.heightAnchor.constraint(equalToConstant: 88).isActive = true
        
        //pull out the height constraint from the header view
        headerViewHeightConstraint = NSLayoutConstraint(item: headerView, attribute: .height, relatedBy: .equal, toItem: headerView, attribute: .height, multiplier: 0, constant: 0)
        headerViewHeightConstraint.isActive = true

        view.addSubview(tableView)
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: headerView.bottomAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 40
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellID")
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "cellID")
        }
        cell?.textLabel?.text = "\(indexPath.row)"
        return cell!
    }
    
    
   
    
    //MARK: determine scrolling direction
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let scrollDiff = scrollView.contentOffset.y - self.previousScrollOffset
        
        let absoluteTop: CGFloat = 0
        let absoluteBottom: CGFloat = scrollView.contentSize.height - scrollView.frame.size.height
        
        let isScrollingDown = scrollDiff > 0 && scrollView.contentOffset.y > absoluteTop
        let isScrollingUp = scrollDiff < 0 && scrollView.contentOffset.y < absoluteBottom
        
        //print(scrollView.contentOffset.y)
        
        if canAnimateHeader(scrollView) {
            var newHeight = headerViewHeightConstraint.constant
            
            //remove the contentoffset.y from isScrolling up conditional to have the behavior at any scroll position.
            if isScrollingDown {
                //print("scrolling down")
                newHeight = max(self.minHeaderHeight, self.headerViewHeightConstraint.constant - abs(scrollDiff))
            } else if isScrollingUp && scrollView.contentOffset.y <= 0 {
                //print("scrolling up")
                newHeight = min(self.maxHeaderHeight, self.headerViewHeightConstraint.constant + abs(scrollDiff))
            }
            
            if newHeight != self.headerViewHeightConstraint.constant {
                self.headerViewHeightConstraint.constant = newHeight
                self.setScrollPosition(position: self.previousScrollOffset)
            }
        }
        self.previousScrollOffset = scrollView.contentOffset.y
    }
    
    //MARK: Don't collapse header if the scroll view content size is small enough to accommodate it.
    func canAnimateHeader(_ scrollView: UIScrollView) -> Bool {
        let scrollViewMaxHeight = scrollView.frame.height + headerViewHeightConstraint.constant - minHeaderHeight
        return scrollView.contentSize.height > scrollViewMaxHeight
    }
    
    //MARK: freeze the scroll position of the tableview while the header is collapsing expanding
    func setScrollPosition(position: CGFloat) {
        self.tableView.contentOffset = CGPoint(x: self.tableView.contentOffset.x, y: position)
    }
    
    //MARK: snap header to fully collapsed or fully expanded
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // scrolling has stopped
        
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            // scrolling has stopped
        }
    }
    
}

