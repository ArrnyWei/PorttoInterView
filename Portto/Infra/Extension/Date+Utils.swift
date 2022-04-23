//
//  Date+Utils.swift
//  NextDriveAppSDK_iOS
//
//  Created by EnochWu on 2019/08/07.
//  Copyright © 2019 NextDrive. All rights reserved.
//

import Foundation

extension Date {

    public enum WeekDay: Int {
        case sunday = 1
        case monday = 2
        case tuesday = 3
        case wednesday = 4
        case thursday = 5
        case friday = 6
        case saturday = 7
    }

    public enum Mounth: Int {
        case january = 1
        case february = 2
        case march = 3
        case april = 4
        case may = 5
        case june = 6
        case july = 7
        case august = 8
        case september = 9
        case october = 10
        case november = 11
        case december = 12
    }

    public init(milliseconds: Int64) {
        self = Date(timeIntervalSince1970: TimeInterval(milliseconds) / 1000)
    }

    public init(string: String, format: String) {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.dateFormat = format
        self = formatter.date(from: string)!
    }

    public func currentTimeMillis() -> Int64 {
        return Int64(self.timeIntervalSince1970 * 1000)
    }

    public func toFormatString(format: String = "yyyy-MM-dd HH:mm:ss ZZZ",
                               is12HourClock: Bool = false,
                               locale: Locale = .current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.calendar = getCalendar()
        dateFormatter.timeZone = TimeZone.current
        if is12HourClock {
            let localeCode = [locale.languageCode,
                              locale.scriptCode,
                              locale.regionCode].compactMap { $0 }.joined(separator: "-")
            dateFormatter.locale = Locale(identifier: "\(localeCode)_POSIX")
        }
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

    public func getCalendar(identifier: Calendar.Identifier = .gregorian) -> Calendar {
        return Calendar(identifier: identifier)
    }

    public func alignToMinuteStart() -> Date {
        return self.setTime(bySettings: (.second, 0), (.nanosecond, 0))
    }

    public func alignToHourStart() -> Date {
        return self.setTime(bySettings: (.minute, 0), (.second, 0), (.nanosecond, 0))
    }

    public func alignToHalfHour() -> Date {
        return self.setTime(bySettings: (.minute, 30), (.second, 0), (.nanosecond, 0))
    }

    public func alignToDayStart() -> Date {
        return self.setTime(bySettings: (.hour, 0), (.minute, 0), (.second, 0), (.nanosecond, 0))
    }

    public func alignToDayEnd() -> Date {
        return self.setTime(bySettings: (.hour, 23), (.minute, 59), (.second, 59), (.nanosecond, 999999999))
    }

    public func alignToWeekDay(weekDay: WeekDay) -> Date {
        return self.setTime(bySettings: (.weekday, weekDay.rawValue))
    }

    public func addTime(byAdding component: Calendar.Component, value: Int) -> Date {
        let calendar = getCalendar()
        return calendar.date(byAdding: component, value: value, to: self)!
    }

    public func setTime(bySettings componentSets: (Calendar.Component, Int)...) -> Date {
        let calendar = getCalendar()
        let components = Set(componentSets.map { $0.0 })
        var nextDateComponent = calendar.dateComponents(components, from: self)

        var target = DateComponents()
        componentSets.forEach {
            target.setValue($0.1, for: $0.0)
            nextDateComponent.setValue($0.1, for: $0.0)
        }

        if target.year == nil {
            target.year = self.get(Component: .year)
        }
        if target.month == nil {
            target.month = self.get(Component: .month)
        }
        if target.day == nil {
            target.day = self.get(Component: .day)
        }
        if target.hour == nil {
            target.hour = self.get(Component: .hour)
        }
        if target.minute == nil {
            target.minute = self.get(Component: .minute)
        }
        if target.second == nil {
            target.second = self.get(Component: .second)
        }
        if target.nanosecond == nil {
            target.nanosecond = self.get(Component: .nanosecond)
        }
        if target.weekdayOrdinal == nil {
            target.weekdayOrdinal = self.get(Component: .weekdayOrdinal)
        }
        if target.weekday == nil {
            target.weekday = self.get(Component: .weekday)
        }
        if target.weekOfMonth == nil {
            target.weekOfMonth = self.get(Component: .weekOfMonth)
        }
        if target.weekOfYear == nil {
            target.weekOfYear = self.get(Component: .weekOfYear)
        }
        if target.yearForWeekOfYear == nil {
            target.yearForWeekOfYear = self.get(Component: .yearForWeekOfYear)
        }
        if target.era == nil {
            target.era = self.get(Component: .era)
        }
        if target.quarter == nil {
            target.quarter = self.get(Component: .quarter)
        }

        if let year = target.year, let month = target.month, let day = target.day, let hour = target.hour, let minute = target.minute, let second = target.second {
            let str = String(format: "%04d-%02d-%02d %02d:%02d:%02d %@", year, month, day, hour, minute, second, self.toFormatString(format: "ZZZ"))

            let formatter = DateFormatter()
            formatter.locale = calendar.locale
            formatter.dateFormat = "YYYY-MM-dd HH:mm:ss ZZZ"
            let targetDate = formatter.date(from: str)

            if self.currentTimeMillis() == targetDate?.currentTimeMillis() &&
                self.get(Component: .weekday) == target.weekday {
                return self
            } else {
                let direction: Calendar.SearchDirection
                if self.currentTimeMillis() == targetDate?.currentTimeMillis() {
                    if let targetWeekday = target.weekday, self.get(Component: .weekday) > targetWeekday {
                        direction = .backward
                    } else {
                        direction = .forward
                    }
                } else if self.currentTimeMillis() < targetDate?.currentTimeMillis() ?? 0 {
                    direction = .forward
                } else {
                    direction = .backward
                }
                return calendar.nextDate(after: self, matching: nextDateComponent, matchingPolicy: .nextTime, direction: direction)!
            }
        }
        fatalError()
    }

    public func getActualMaximum(of: Calendar.Component, `in`: Calendar.Component) -> Int {
        let calendar = getCalendar()
        let range = calendar.range(of: of, in: `in`, for: self)
        return range!.count
    }

    public func get(Component component: Calendar.Component) -> Int {
        let calendar = getCalendar()
        let dateComponents = calendar.dateComponents(in: .current, from: self)

        switch component {
        case .era:
            return dateComponents.era!
        case .year:
            return dateComponents.year!
        case .month:
            return dateComponents.month!
        case .day:
            return dateComponents.day!
        case .hour:
            return dateComponents.hour!
        case .minute:
            return dateComponents.minute!
        case .second:
            return dateComponents.second!
        case .weekday:
            return dateComponents.weekday!
        case .weekdayOrdinal:
            return dateComponents.weekdayOrdinal!
        case .quarter:
            return dateComponents.quarter!
        case .weekOfMonth:
            return dateComponents.weekOfMonth!
        case .weekOfYear:
            return dateComponents.weekOfYear!
        case .yearForWeekOfYear:
            return dateComponents.yearForWeekOfYear!
        case .nanosecond:
            return dateComponents.nanosecond!
        case .calendar, .timeZone:
            fatalError("doesn't support calendar & timeZone")
        default:
            return -1
        }
    }

    public func getTimeDiffFromDate(Component component: Calendar.Component, date: Date) -> Int {
        let calendar = getCalendar()
        let dateComponents = calendar.dateComponents([component], from: self, to: date)

        switch component {
        case .era:
            return dateComponents.era!
        case .year:
            return dateComponents.year!
        case .month:
            return dateComponents.month!
        case .day:
            return dateComponents.day!
        case .hour:
            return dateComponents.hour!
        case .minute:
            return dateComponents.minute!
        case .second:
            return dateComponents.second!
        case .weekday:
            return dateComponents.weekday!
        case .weekdayOrdinal:
            return dateComponents.weekdayOrdinal!
        case .quarter:
            return dateComponents.quarter!
        case .weekOfMonth:
            return dateComponents.weekOfMonth!
        case .weekOfYear:
            return dateComponents.weekOfYear!
        case .yearForWeekOfYear:
            return dateComponents.yearForWeekOfYear!
        case .nanosecond:
            return dateComponents.nanosecond!
        case .calendar, .timeZone:
            fatalError("doesn't support calendar & timeZone")
        default:
            return -1
        }
    }

    public func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }

    public func timeAgoDisplay() -> String {
        let formatter = DateComponentsFormatter()
        formatter.calendar = getCalendar()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
        formatter.zeroFormattingBehavior = .dropAll
        formatter.maximumUnitCount = 1
        return String(format: formatter.string(from: self, to: Date()) ?? "--")
    }
}
