//
//  ElementsTableViewController.swift
//  AC3.2-MidtermElements
//
//  Created by Victor Zhong on 12/8/16.
//  Copyright © 2016 Victor Zhong. All rights reserved.
//

import UIKit
import Kingfisher

class ElementsTableViewController: UITableViewController {
    
    let cellIdentifier = "elementCellReuse"
    let cellSegue = "elementSegue"
    let optionsSegue = "optionsSegue"
    var elements = [Element]()
    var expandingElements = [Element]()
    var myName = "Vic Zhong"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpFooterSpinner()
        loadData()
    }
    
    func loadData() {
        APIRequestManager.manager.getData(endPoint: "https://api.fieldbook.com/v1/58488d40b3e2ba03002df662/elements") { (data: Data?) in
            if  let validData = data,
                let validElements = Element.elements(from: validData) {
                print("We have elements! \(validElements.count)")
                self.elements = validElements
                self.expandingElements = validElements
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.prefetchAllImages()
                }
            }
        }
    }

    func setUpFooterSpinner() {
        let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        spinner.startAnimating()
        spinner.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: 44)
        self.tableView.tableFooterView = spinner;
    }
    
    //MARK: - Functions and Methods
    
    func prefetchAllImages() {
        let thumbUrls = self.expandingElements.map {
            URL(string: $0.thumb)!
        }
        
        let prefetcher = ImagePrefetcher(urls: thumbUrls, completionHandler: { (skippedResources, failedResources, completedResources) in
            print("Fetched \(completedResources)")
        })
        
        prefetcher.start()
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return expandingElements.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        let cellElement = expandingElements[indexPath.row]
        
        cell.textLabel?.text = cellElement.name
        cell.detailTextLabel?.text = "\(cellElement.symbol)(\(cellElement.number)) \(cellElement.weight)"
        
        let url = URL(string: cellElement.thumb)!
        cell.imageView?.kf.setImage(with: url, placeholder: UIImage(named: "placeholder"))

        return cell
    }

    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == self.expandingElements.count - 1 {
            self.expandingElements.append(contentsOf: self.elements)
            self.tableView.reloadData()
        }
    }

    // MARK: - Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let detailView = segue.destination as? DetailViewController,
            let cell = sender as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell) {
            detailView.element = expandingElements[indexPath.row]
            detailView.name = myName
        }
        
        if let optionsView = segue.destination as? OptionsViewController {
            optionsView.delegate = self
            optionsView.name = myName
        }
    }
}

extension ElementsTableViewController: OptionsDelegate {
    func changeSettings(_ controller: OptionsViewController, _ name: String) {
        if myName != name {
            myName = name
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}
