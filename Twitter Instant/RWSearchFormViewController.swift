//
//  ViewController.swift
//  Twitter Instant
//
//  Created by Jechol Lee on 1/1/16.
//  Copyright © 2016 Reactive Cocoa. All rights reserved.
//

import UIKit

class RWSearchFormViewController: UIViewController {

  @IBOutlet var searchText: UITextField!

  var resultsViewController: RWSearchResultsViewController!

  override func viewDidLoad() {
    super.viewDidLoad()

    self.resultsViewController = self.splitViewController!.viewControllers[1] as! RWSearchResultsViewController
  }
}

