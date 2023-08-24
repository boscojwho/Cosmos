//
//  PostSortType.swift
//  Cosmos
//
//  Created by Bosco Ho on 2023-08-24.
//

import Foundation

enum PostSortType: String, Codable, CaseIterable, Identifiable {
    case hot = "Hot"
    case active = "Active"
    case new = "New"
    case old = "Old"
    case newComments = "NewComments"
    case mostComments = "MostComments"
    case topHour = "TopHour"
    case topSixHour = "TopSixHour"
    case topTwelveHour = "TopTwelveHour"
    case topDay = "TopDay"
    case topWeek = "TopWeek"
    case topMonth = "TopMonth"
    case topYear = "TopYear"
    case topAll = "TopAll"
    
    var id: Self { self }
    
    static var outerTypes: [PostSortType] {[.hot, .active, .new, .old, .newComments, .mostComments]}
    static var topTypes: [PostSortType] {[.topHour, .topSixHour, .topTwelveHour, .topDay, .topWeek, .topMonth, .topYear, .topAll]}
    
    var description: String {
        switch self {
        case .topHour:
            return "Top of the last hour"
        case .topSixHour:
            return "Top of the last six hours"
        case .topTwelveHour:
            return "Top of the last twelve hours"
        case .topDay:
            return "Top of today"
        case .topWeek:
            return "Top of the week"
        case .topMonth:
            return "Top of the month"
        case .topYear:
            return "Top of the year"
        case .topAll:
            return "Top of all time"
        default:
            return self.rawValue
        }
    }
}
