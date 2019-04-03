//
//  Formatter.swift
//  Pace
//
//  Created by Tan Zheng Wei on 3/4/19.
//  Copyright © 2019 nus.cs3217.pace. All rights reserved.
//

import Foundation

class Formatter {
    private static var calendar = Calendar.current
    // Formatter for numbers
    private static var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .ordinal
        return formatter
    }()
    // Formatter for run times
    private static var timeFormatter = DateComponentsFormatter()
    // Formatter for dates
    private static var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: Constants.locale)
        return formatter
    }()

    /// Formats a run time (Double) into a string
    static func formatTime(_ time: Double) -> String? {
        timeFormatter.unitsStyle = .brief
        timeFormatter.allowedUnits = [.day, .hour, .minute, .second]
        return timeFormatter.string(from: time)
    }

    /// Formats a Date into a string
    /// Removes the year if the Date is in the current year.
    static func formatDate(_ date: Date) -> String? {
        if calendar.compare(Date(), to: date, toGranularity: .year) == .orderedSame {
            dateFormatter.dateFormat = "MMM, yyyy"
        } else {
            dateFormatter.dateFormat = "MMM, yyyy"
        }
        
        let mmyyString = dateFormatter.string(from: date) ?? ""
        let day = calendar.component(.day, from: date)
        let ddString = numberFormatter.string(from: NSNumber(value: day)) ?? ""
        return "\(ddString) \(mmyyString)"
    }
}
