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

    self.requestAccessToTwitterSignal()
      .then(searchText.rac_textSignal().toSignalProducer())
      .map { $0 as! String }
      .filter { self.isValidText($0) }
      .flatMap(.Concat, transform: { self.signalForSearchWithText($0) })
      .observeOn(UIScheduler())
      .startWithSignal { (signal, _) -> () in
        signal.observeNext {
          NSLog("count: \($0["statuses"]!.count)")
        }
        signal.observeFailed { NSLog("An error occurred: \($0)") }
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

  func requestForTwitterSearchWithText(text: String) -> SLRequest {
    let url = NSURL(string: "https://api.twitter.com/1.1/search/tweets.json")
    let params = ["q": text]

    let request = SLRequest(forServiceType: SLServiceTypeTwitter, requestMethod: .GET
      , URL: url, parameters: params)
    return request
  }

  func signalForSearchWithText(text: String) -> SignalProducer<NSDictionary, NSError> {
    // 1 - define the errors
    let noAccountsError = NSError(domain: RWTwitterInstantDomain, code: RWTwitterInstantError.NoTwitterAccounts.rawValue, userInfo: nil)
    let invalidResponseError = NSError(domain: RWTwitterInstantDomain, code: RWTwitterInstantError.InvalidResponse.rawValue, userInfo: nil)

    // 2 - create the signal block
    return SignalProducer<NSDictionary, NSError> { (o, _) in
      // 3 - create the request
      let request = self.requestForTwitterSearchWithText(text)

      // 4 - supply a twitter account
      let twitterAccounts = self.accountStore.accountsWithAccountType(self.twitterAccountType)

      if (twitterAccounts.count == 0) {
        o.sendFailed(noAccountsError)
      } else {
        request.account = twitterAccounts.last as! ACAccount

        // 5 - perform the request
        request.performRequestWithHandler({ (data, response, error) -> Void in
          if (response.statusCode == 200) {

            // 6 - on success, parse the response
            let timelineData = try! NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as! NSDictionary
            o.sendNext(timelineData)
            o.sendCompleted()

          } else {

            // 7 - send an error on failure
            o.sendFailed(invalidResponseError)
          }
        })
      }
    }
  }
}
