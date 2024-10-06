//
//  Date+Extension.swift
//  MessengerClone
//
//  Created by Đoàn Văn Khoan on 11/9/24.
//

import Foundation

extension Date {
    
    /// Check same day
    func isSameDay(as otherDate: Date) -> Bool {
        let calendar = Calendar.current
        return calendar.isDate(self, inSameDayAs: otherDate)
    }
    
    
    // MARK: Relative time of message
    var relativeDateString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return toString(format: "h:mm a") // 9:20 am
        } else if isCurrentWeek {
            return toString(format: "MMM h:mm a") // Mon 9:30 pm
        } else if isCurrentYear {
            return toString(format: "MMM d 'at' h:mm a") // Feb 19 at 2:23 pm
        } else {
            return toString(format: "MMM dd, YYYY") // Mon, Feb 19, 2020
        }
    }
    
    func toString(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }
    
    private var isCurrentWeek: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .weekday)
    }
    
    private var isCurrentYear: Bool {
        return Calendar.current.isDate(self, equalTo: Date(), toGranularity: .year)
    }
    // MARK: END
    
    // Return how far from current story
    func timeAgo() -> String {
        let now = Date()
        let elapsedTime = now.timeIntervalSince(self)
        
        let secondsInMinute: TimeInterval = 60
        let secondsInHour: TimeInterval = 3600
        let secondsInDay: TimeInterval = 86400
        
        if elapsedTime < secondsInMinute {
            return "\(Int(elapsedTime))s ago"  // Less than a minute ago
        } else if elapsedTime < secondsInHour {
            let minutes = Int(elapsedTime / secondsInMinute)
            return "\(minutes)m"  // Less than an hour ago
        } else if elapsedTime < secondsInDay {
            let hours = Int(elapsedTime / secondsInHour)
            return "\(hours)h"   // Less than a day ago
        } else {
            let days = Int(elapsedTime / secondsInDay)
            return "\(days)d"    // More than a day ago
        }
    }
    
    // Convert Date to day of the week
    func formattedTimeIntervalPreviewChannel() -> String {
        let now = Date()
        
        let calendar = Calendar.current
        let date = self
        
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        
        if calendar.isDateInToday(date) {
            formatter.dateFormat = "h:mm a"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .weekOfYear) {
            formatter.dateFormat = "EEE"
        } else if calendar.isDate(date, equalTo: now, toGranularity: .year) {
            formatter.dateFormat = "MMM d"
        } else {
            formatter.dateFormat = "MMM d, YYYY"
        }
        
        return formatter.string(from: date)
    }
    
    // Convert to time of lastActive
    func formattedOnlineState() -> String {
        let now = Date()
        let elapsedTime = now.timeIntervalSince(self)
        
        let secondsInMinute: TimeInterval = 60
        let secondsInHour: TimeInterval = 3600
        let secondsInDay: TimeInterval = 86400

        if elapsedTime < secondsInMinute {
            return "Active now"
        } else if elapsedTime < secondsInHour {
            let minutes = Int(elapsedTime / secondsInMinute)
            return "Active \(minutes)m ago"
        } else if elapsedTime < secondsInDay {
            let hours = Int(elapsedTime / secondsInHour)
            return "Active \(hours)h ago"
        } else {
            return ""
        }
    }
    
    // Convert to time of channel
    func formattedOnlineChannel() -> String {
        let now = Date()
        let elapsedTime = now.timeIntervalSince(self)
        
        let secondsInMinute: TimeInterval = 60
        let secondsInHour: TimeInterval = 3600
        let secondsInDay: TimeInterval = 86400
        
        if elapsedTime < secondsInMinute {
            return "second"
        } else if elapsedTime < secondsInHour {
            let minutes = Int(elapsedTime / secondsInMinute)
            return "\(Int(minutes))m"
        } else if elapsedTime < secondsInDay {
            let hours = Int(elapsedTime / secondsInHour)
            return "\(Int(hours))h"
        } else {
            return ""
        }
    }
}
