import Foundation

/// Identifies a word region in the grid that can be lit up.
enum WordID: Hashable {
    // Prefix hours (top half — used as the hour in "[hour] [minutes]" or "[hour] o'clock")
    case prefixOne, prefixTwo, prefixThree, prefixFour
    case prefixFive, prefixSix, prefixSeven, prefixEight
    case prefixNine, prefixTen, prefixEleven, prefixTwelve

    // Suffix hours (bottom half — used as the hour in "[time] past/to [hour]")
    case suffixOne, suffixTwo, suffixThree, suffixFour
    case suffixFive, suffixSix, suffixSeven, suffixEight
    case suffixNine, suffixTen, suffixEleven, suffixTwelve

    // Time connectors
    case oclock, past, to, half, quarter
    case minute, minutes    // singular vs plural ("minute" is cols 7-12, "minutes" adds the 's' at col 13)
    case twenty             // "twenty past" / "twenty to"

    // Teen minutes (displayed as "[hour] thirteen" etc.)
    case thirteen, fourteen, fifteen, sixteen
    case seventeen, eighteen, nineteen

    // Decade + suffix minutes (displayed as "[hour] twenty/thirty/forty/fifty [one-nine]")
    case twentyMinutes, thirtyMinutes, fortyMinutes, fiftyMinutes
}

/// The 15×16 character grid and word-to-position mappings.
enum GridModel {

    /// Number of columns in the grid.
    static let columns = 16

    /// Number of rows in the grid (row 15 is empty).
    static let rows = 15

    /// Each string is one row of 16 uppercase characters.
    static let characters: [String] = [
        "ONETWOTHREEFOURS",   // row 0
        "ATFIVESIXSEVENBE",   // row 1
        "EIGHTNINETENSOON",   // row 2
        "ELEVENTWELVEHALF",   // row 3
        "QUARTERMINUTESTO",   // row 4
        "TWENTYTHIRTEENAT",   // row 5
        "FOURTEENFIFTEENS",   // row 6
        "PASTTOSIXTEENCKN",   // row 7
        "SEVENTEENTWENTYA",   // row 8
        "EIGHTEENNINETEEN",   // row 9
        "THIRTYFORTYFIFTY",   // row 10
        "OCLOCKONETWOMOON",   // row 11
        "THREEFOURFIVESIX",   // row 12
        "SEVENEIGHTNINEIO",   // row 13
        "TENELEVENTWELVES",   // row 14
    ]

    /// A position in the grid.
    struct Position: Hashable {
        let row: Int
        let col: Int
    }

    /// Maps each WordID to its set of grid positions.
    static let wordPositions: [WordID: Set<Position>] = {
        var map = [WordID: Set<Position>]()

        func add(_ word: WordID, row: Int, cols: ClosedRange<Int>) {
            map[word] = Set(cols.map { Position(row: row, col: $0) })
        }

        // Prefix hours
        add(.prefixOne,    row: 0,  cols: 0...2)
        add(.prefixTwo,    row: 0,  cols: 3...5)
        add(.prefixThree,  row: 0,  cols: 6...10)
        add(.prefixFour,   row: 0,  cols: 11...14)
        add(.prefixFive,   row: 1,  cols: 2...5)
        add(.prefixSix,    row: 1,  cols: 6...8)
        add(.prefixSeven,  row: 1,  cols: 9...13)
        add(.prefixEight,  row: 2,  cols: 0...4)
        add(.prefixNine,   row: 2,  cols: 5...8)
        add(.prefixTen,    row: 2,  cols: 9...11)
        add(.prefixEleven, row: 3,  cols: 0...5)
        add(.prefixTwelve, row: 3,  cols: 6...11)

        // Time connectors
        add(.half,         row: 3,  cols: 12...15)
        add(.quarter,      row: 4,  cols: 0...6)
        add(.minute,       row: 4,  cols: 7...12)
        add(.minutes,      row: 4,  cols: 7...13)
        add(.twenty,       row: 5,  cols: 0...5)
        add(.thirteen,     row: 5,  cols: 6...13)
        add(.fourteen,     row: 6,  cols: 0...7)
        add(.fifteen,      row: 6,  cols: 8...14)
        add(.past,         row: 7,  cols: 0...3)
        add(.to,           row: 7,  cols: 4...5)
        add(.sixteen,      row: 7,  cols: 6...12)
        add(.seventeen,    row: 8,  cols: 0...8)
        add(.twentyMinutes,row: 8,  cols: 9...14)
        add(.eighteen,     row: 9,  cols: 0...7)
        add(.nineteen,     row: 9,  cols: 8...15)
        add(.thirtyMinutes,row: 10, cols: 0...5)
        add(.fortyMinutes, row: 10, cols: 6...10)
        add(.fiftyMinutes, row: 10, cols: 11...15)
        add(.oclock,       row: 11, cols: 0...5)

        // Suffix hours
        add(.suffixOne,    row: 11, cols: 6...8)
        add(.suffixTwo,    row: 11, cols: 9...11)
        add(.suffixThree,  row: 12, cols: 0...4)
        add(.suffixFour,   row: 12, cols: 5...8)
        add(.suffixFive,   row: 12, cols: 9...12)
        add(.suffixSix,    row: 12, cols: 13...15)
        add(.suffixSeven,  row: 13, cols: 0...4)
        add(.suffixEight,  row: 13, cols: 5...9)
        add(.suffixNine,   row: 13, cols: 10...13)
        add(.suffixTen,    row: 14, cols: 0...2)
        add(.suffixEleven, row: 14, cols: 3...8)
        add(.suffixTwelve, row: 14, cols: 9...14)

        return map
    }()

    /// Returns the prefix WordID for a given hour (1–12).
    static func prefix(forHour hour: Int) -> WordID {
        switch hour {
        case 1:  return .prefixOne
        case 2:  return .prefixTwo
        case 3:  return .prefixThree
        case 4:  return .prefixFour
        case 5:  return .prefixFive
        case 6:  return .prefixSix
        case 7:  return .prefixSeven
        case 8:  return .prefixEight
        case 9:  return .prefixNine
        case 10: return .prefixTen
        case 11: return .prefixEleven
        case 12: return .prefixTwelve
        default: return .prefixTwelve
        }
    }

    /// Returns the suffix WordID for a given hour (1–12).
    static func suffix(forHour hour: Int) -> WordID {
        switch hour {
        case 1:  return .suffixOne
        case 2:  return .suffixTwo
        case 3:  return .suffixThree
        case 4:  return .suffixFour
        case 5:  return .suffixFive
        case 6:  return .suffixSix
        case 7:  return .suffixSeven
        case 8:  return .suffixEight
        case 9:  return .suffixNine
        case 10: return .suffixTen
        case 11: return .suffixEleven
        case 12: return .suffixTwelve
        default: return .suffixTwelve
        }
    }
}
