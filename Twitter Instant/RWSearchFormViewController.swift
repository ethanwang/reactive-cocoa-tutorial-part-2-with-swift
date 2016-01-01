//
//  ViewController.swift
//  Twitter Instant
//
//  Created by Jechol Lee on 1/1/16.
//  Copyright © 2016 Reactive Cocoa. All rights reserved.
//

import UIKit
import ReactiveCocoa
import Social
import Accounts

enum RWTwitterInstantError: Int {
  case AccessDenied = 0, NoTwitterAccounts, InvalidResponse
}

let RWTwitterInstantDomain = "TwitterInstant"

class RWSearchFormViewController: UIViewController {

  @IBOutlet var searchText: UITextField!

  var resultsViewController: RWSearchResultsViewController!
  var accountStore: ACAccountStore!
  var twitterAccountType: ACAccountType!

  func isValidText(text: String) -> Bool {
    return text.characters.count > 2
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    self.resultsViewController = self.splitViewController!.viewControllers[1] as! RWSearchResultsViewController

    self.searchText.rac_textSignal().toSignalProducer()
      .map { self.isValidText($0 as! String) ? UIColor.whiteColor() : UIColor.yellowColor() }
      .startWithNext { [weak self] in
        self?.searchText.backgroundColor = $0
    }

    self.accountStore = ACAccountStore()
    self.twitterAccountType = self.accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)

    self.requestAccessToTwitterSignal().startWithSignal { (signal, _) -> () in
      signal.observeNext { (_) -> () in
        NSLog("Access granted")
      }
      signal.observeFailed { (error) -> () in
        NSLog("An error occurred: \(error)")
      }
    }
  }

  func requestAccessToTwitterSignal() -> SignalProducer<AnyObject?, NSError> {
    // 1 - define an error
    let accessError = NSError(domain: RWTwitterInstantDomain, code: RWTwitterInstantError.AccessDenied.rawValue, userInfo: nil)

    // 2 - create the signal
    return SignalProducer<AnyObject?, NSError> { [weak self] o, _ in
      self?.accountStore.requestAccessToAccountsWithType(
        self?.twitterAccountType, options: nil, completion: {
          (granted: Bool, error: NSError!) -> Void in
          if (!granted) {
            o.sendFailed(accessError)
          } else {
            o.sendNext(nil)
            o.sendCompleted()
          }
      })
    }
  }
}
