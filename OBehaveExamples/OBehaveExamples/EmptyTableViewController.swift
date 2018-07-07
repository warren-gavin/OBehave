//
//  EmptyTableViewController.swift
//  OBehaveExamples
//
//  Created by Warren Gavin on 20/06/2018.
//  Copyright © 2018 Apokrupto. All rights reserved.
//

import UIKit
import OBehave

class EmptyTableViewController: UITableViewController {
    // Set in the dock in the storyboard in this example
    @IBOutlet var emptyStateView: UIView!
    
    private var muppets: [Muppet] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addMuppet(_:)))
        navigationItem.rightBarButtonItem = addButton
    }

    @objc
    private func addMuppet(_ sender: UIBarButtonItem) {
        muppets.append(Muppet.randomMuppet)

        tableView.beginUpdates()
        tableView.insertRows(at: [IndexPath(row: muppets.count - 1, section: 0)], with: .automatic)
        tableView.endUpdates()
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return muppets.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "muppetCell")!
        let muppet = muppets[indexPath.row]
        
        cell.textLabel?.text = muppet.name
        cell.detailTextLabel?.text = muppet.comment
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        
        muppets.remove(at: indexPath.row)

        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
    }
}

// MARK: - OBEmptyStateBehaviorDataSource
extension EmptyTableViewController: OBEmptyStateBehaviorDataSource {
    func viewToDisplayOnEmpty(for behavior: OBEmptyStateBehavior?) -> UIView? {
        return emptyStateView
    }
}

// MARK: - Model
private struct Muppet {
    let name: String
    let comment: String
}

private extension Muppet {
    static let rowlf  = Muppet(name: "Rowlf",  comment: "Quiet genius")
    static let animal = Muppet(name: "Animal", comment: "Do not feed")
    static let sam    = Muppet(name: "Sam",    comment: "The AMERICAN eagle")
    static let beaker = Muppet(name: "Beaker", comment: "Meep")
    static let chef   = Muppet(name: "Chef",   comment: "Bork!")
    
    static var randomMuppet: Muppet {
        let allMuppets = [rowlf, animal, sam, beaker, chef]
        let index = Int(arc4random_uniform(UInt32(allMuppets.count - 1)))

        return allMuppets[index]
    }
}
