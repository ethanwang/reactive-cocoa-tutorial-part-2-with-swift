//
//  ViewController.swift
//  Twitter Instant
//
//  Created by Jechol Lee on 1/1/16.
//  Copyright © 2016 Reactive Cocoa. All rights reserved.
//

import UIKit
import ReactiveCocoa

class RWSearchFormViewController: UIViewController {

  @IBOutlet var searchText: UITextField!

  var resultsViewController: RWSearchResultsViewController!

  func isValidText(text: String) -> Bool {
    return text.characters.count > 2
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.resultsViewController = self.splitViewController!.viewControllers[1] as! RWSearchResultsViewController

    self.searchText.rac_textSignal().toSignalProducer()
      .map { self.isValidText($0 as! String) ? UIColor.whiteColor() : UIColor.yellowColor() }
      .startWithNext { self.searchText.backgroundColor = $0 }
  }
}

