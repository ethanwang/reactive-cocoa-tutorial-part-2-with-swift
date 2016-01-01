//
//  RWSearchResultsViewController.swift
//  Twitter Instant
//
//  Created by Jechol Lee on 1/1/16.
//  Copyright © 2016 Reactive Cocoa. All rights reserved.
//

import UIKit

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

    return cell
  }
}
