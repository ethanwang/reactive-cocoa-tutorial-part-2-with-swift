//
//  RWSearchResultsViewController.swift
//  Twitter Instant
//
//  Created by Jechol Lee on 1/1/16.
//  Copyright © 2016 Reactive Cocoa. All rights reserved.
//

import UIKit
import ReactiveCocoa

class RWSearchResultsViewController: UITableViewController {

  var tweets = [RWTweet]()

  func displayTweets(tweets: [RWTweet]) {
    self.tweets = tweets
    self.tableView.reloadData()
  }

  // MARK: - Table view data source

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return tweets.count
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! RWTableViewCell
    let tweet = self.tweets[indexPath.row]

    cell.twitterStatusText.text = tweet.status
    cell.twitterUsernameText.text = "@\(tweet.username)"
    cell.twitterAvatarView.image = nil

    self.signalForLoadingImage(tweet.profileImageUrl)
      .takeUntil(cell.rac_prepareForReuseSignal.toSignalProducer().map { _ in () }.mapError { $0 as! NoError })
      .observeOn(UIScheduler())
      .startWithNext { (image) -> () in cell.twitterAvatarView.image = image }

    return cell
  }

  func signalForLoadingImage(imageUrl: String) -> SignalProducer<UIImage, NSError> {
    let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)
    let scheduler = QueueScheduler(queue: queue)

    return SignalProducer<UIImage, NSError> { o, _ in
      let data = NSData(contentsOfURL: NSURL(string: imageUrl)!)!
      let image = UIImage(data: data)!
      o.sendNext(image)
      o.sendCompleted()
    }.startOn(scheduler)
  }
}
