//
//  RWTweet.swift
//  Twitter Instant
//
//  Created by Jechol Lee on 1/1/16.
//  Copyright © 2016 Reactive Cocoa. All rights reserved.
//

import Foundation


class RWTweet {

  var status: String!
  var profileImageUrl: String!
  var username: String!

  static func tweetWithStatus(status: NSDictionary) -> RWTweet {
    let tweet = RWTweet()
    tweet.status = status["text"] as! String

    let user = status["user"] as! NSDictionary
    tweet.profileImageUrl = user["profile_image_url"] as! String
    tweet.username = user["screen_name"] as! String

    return tweet
  }
}
