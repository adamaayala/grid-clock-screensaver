import Foundation

/// Converts the current time into a set of active WordIDs.
enum TimeEngine {

    /// Converts a 24-hour value (0–23) to 12-hour (1–12).
    static func to12Hour(_ hour24: Int) -> Int {
        let h = hour24 % 12
        return h == 0 ? 12 : h
    }

    /// Wraps hour so 13 becomes 1.
    private static func nextHour(_ hour12: Int) -> Int {
        let next = hour12 + 1
        return next > 12 ? 1 : next
    }

    /// Returns the suffix WordID for a ones digit (1–9).
    private static func suffixForDigit(_ digit: Int) -> WordID {
        GridModel.suffix(forHour: digit)
    }

    /// Returns active words for the given time.
    ///
    /// Faithfully ports the JavaScript logic from index.js.
    static func activeWords(hour24: Int, minute: Int) -> Set<WordID> {
        let hour = to12Hour(hour24)

        switch minute {
        // [hour] o'clock
        case 0:
            return [GridModel.prefix(forHour: hour), .oclock]

        // one minute past [hour]
        case 1:
            return [.prefixOne, .minute, .past, GridModel.suffix(forHour: hour)]

        // [two..twelve] minutes past [hour]
        case 2...12:
            return [GridModel.prefix(forHour: minute), .minutes, .past, GridModel.suffix(forHour: hour)]

        // [hour] thirteen
        case 13:
            return [GridModel.prefix(forHour: hour), .thirteen]

        // [hour] fourteen
        case 14:
            return [GridModel.prefix(forHour: hour), .fourteen]

        // quarter past [hour]
        case 15:
            return [.quarter, .past, GridModel.suffix(forHour: hour)]

        // [hour] sixteen
        case 16:
            return [GridModel.prefix(forHour: hour), .sixteen]

        // [hour] seventeen
        case 17:
            return [GridModel.prefix(forHour: hour), .seventeen]

        // [hour] eighteen
        case 18:
            return [GridModel.prefix(forHour: hour), .eighteen]

        // [hour] nineteen
        case 19:
            return [GridModel.prefix(forHour: hour), .nineteen]

        // twenty past [hour]
        case 20:
            return [.twenty, .past, GridModel.suffix(forHour: hour)]

        // [hour] twenty-[one..nine]
        case 21...29:
            return [GridModel.prefix(forHour: hour), .twentyMinutes, suffixForDigit(minute % 10)]

        // half past [hour]
        case 30:
            return [.half, .past, GridModel.suffix(forHour: hour)]

        // [hour] thirty-[one..nine]
        case 31...39:
            return [GridModel.prefix(forHour: hour), .thirtyMinutes, suffixForDigit(minute % 10)]

        // twenty to [next hour]
        case 40:
            return [.twenty, .to, GridModel.suffix(forHour: nextHour(hour))]

        // [hour] forty-[one..four]
        case 41...44:
            return [GridModel.prefix(forHour: hour), .fortyMinutes, suffixForDigit(minute % 10)]

        // quarter to [next hour]
        case 45:
            return [.quarter, .to, GridModel.suffix(forHour: nextHour(hour))]

        // [hour] forty-[six..nine]
        case 46...49:
            return [GridModel.prefix(forHour: hour), .fortyMinutes, suffixForDigit(minute % 10)]

        // ten to [next hour]
        case 50:
            return [.prefixTen, .to, GridModel.suffix(forHour: nextHour(hour))]

        // [hour] fifty-[one..four]
        case 51...54:
            return [GridModel.prefix(forHour: hour), .fiftyMinutes, suffixForDigit(minute % 10)]

        // five to [next hour]
        case 55:
            return [.prefixFive, .to, GridModel.suffix(forHour: nextHour(hour))]

        // [hour] fifty-[six..nine]
        case 56...59:
            return [GridModel.prefix(forHour: hour), .fiftyMinutes, suffixForDigit(minute % 10)]

        default:
            return [GridModel.prefix(forHour: hour), .oclock]
        }
    }

    /// Returns the set of grid positions that should be active (lit) for the given time.
    static func activePositions(hour24: Int, minute: Int) -> Set<GridModel.Position> {
        let words = activeWords(hour24: hour24, minute: minute)
        var positions = Set<GridModel.Position>()
        for word in words {
            if let wordPositions = GridModel.wordPositions[word] {
                positions.formUnion(wordPositions)
            }
        }
        return positions
    }
}
