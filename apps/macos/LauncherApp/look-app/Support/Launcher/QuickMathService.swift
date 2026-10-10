import Foundation

struct QuickMathResult {
    let display: String
    let raw: String
    let subtitle: String
}

enum QuickMathService {
    static func evaluate(_ rawQuery: String, bridge: EngineBridge? = nil) -> QuickMathResult? {
        let trimmed = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        // Strip leading '?' if present
        let isExplicitQuestion = trimmed.hasPrefix("?")
        var query = trimmed
        if isExplicitQuestion {
            query = String(trimmed.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
        }

        guard !query.isEmpty else { return nil }

        // 1. Timestamp conversion
        if let timestampResult = evaluateTimestamp(query, isExplicit: isExplicitQuestion) {
            return timestampResult
        }

        // 2. Unit conversion
        if let unitResult = evaluateUnitConversion(query) {
            return unitResult
        }

        // 3. Currency conversion
        if let currencyResult = evaluateCurrencyConversion(query, bridge: bridge) {
            return currencyResult
        }

        // 4. Quick Math evaluation via Rust core/calc (if bridge available)
        if let bridge {
            let calcQuery = isExplicitQuestion ? query : trimmed
            if let calc = bridge.calcInline(query: calcQuery) {
                return QuickMathResult(
                    display: calc.display,
                    raw: calc.raw,
                    subtitle: "\(calcQuery)  •  \(AppConstants.Launcher.Calc.enterToCopyHint)"
                )
            }

            // If explicit question '?' was passed, try evaluating arithmetic directly
            if isExplicitQuestion {
                let res = bridge.calcEval(expr: query)
                if let calc = res.calculation {
                    return QuickMathResult(
                        display: calc.display,
                        raw: calc.raw,
                        subtitle: "\(query)  •  \(AppConstants.Launcher.Calc.enterToCopyHint)"
                    )
                }
            }
        }

        return nil
    }

    // MARK: - Timestamp Evaluation

    private static func evaluateTimestamp(_ query: String, isExplicit: Bool) -> QuickMathResult? {
        let lower = query.lowercased()

        if lower == "timestamp" || lower == "timestamp now" || lower == "now timestamp" {
            let now = Date()
            let epoch = Int64(now.timeIntervalSince1970)
            let formatted = formatDate(now)
            return QuickMathResult(
                display: "\(epoch)",
                raw: "\(epoch)",
                subtitle: "\(formatted.utc) (Local: \(formatted.local))  •  Press Enter to copy epoch"
            )
        }

        let prefix = "timestamp"
        var timestampStr = ""
        if lower.hasPrefix(prefix) {
            timestampStr = query.dropFirst(prefix.count).trimmingCharacters(in: .whitespacesAndNewlines)
        } else if isExplicit && CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: query)) {
            timestampStr = query
        }

        guard !timestampStr.isEmpty, let num = Double(timestampStr), num > 0 else {
            return nil
        }

        // Detect seconds vs milliseconds (ms is > 1e11, which corresponds to year 1973+ in ms vs year 5138+ in s)
        let epochSeconds: TimeInterval = num > 100_000_000_000 ? num / 1000.0 : num
        guard epochSeconds < 4_000_000_000 else { return nil }

        let date = Date(timeIntervalSince1970: epochSeconds)
        let formatted = formatDate(date)

        return QuickMathResult(
            display: "\(formatted.utc)",
            raw: "\(formatted.utc)",
            subtitle: "Local: \(formatted.local)  •  Epoch: \(Int64(epochSeconds))  •  Press Enter to copy"
        )
    }

    private static func formatDate(_ date: Date) -> (utc: String, local: String) {
        let utcFormatter = DateFormatter()
        utcFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        utcFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss 'UTC'"

        let localFormatter = DateFormatter()
        localFormatter.timeZone = TimeZone.current
        localFormatter.dateFormat = "E, MMM d, yyyy h:mm:ss a"

        return (utcFormatter.string(from: date), localFormatter.string(from: date))
    }

    // MARK: - Unit Conversions

    private static func evaluateUnitConversion(_ query: String) -> QuickMathResult? {
        // Pattern: <amount?> <unit1> (to|in|->|=) <unit2>
        let parts = query.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        guard parts.count >= 2 else { return nil }

        var amount: Double = 1.0
        var fromUnitRaw = ""
        var toUnitRaw = ""

        let separatorIndices = parts.indices.filter {
            let p = parts[$0].lowercased()
            return p == "to" || p == "in" || p == "->" || p == "=>" || p == "=" || p == "as"
        }

        if let sepIdx = separatorIndices.first, sepIdx > 0, sepIdx < parts.count - 1 {
            let leftParts = parts[..<sepIdx]
            let rightParts = parts[(sepIdx + 1)...]

            toUnitRaw = rightParts.joined(separator: " ")

            if let first = leftParts.first, let parsedAmount = Double(first.replacingOccurrences(of: ",", with: "")) {
                amount = parsedAmount
                fromUnitRaw = leftParts.dropFirst().joined(separator: " ")
            } else {
                fromUnitRaw = leftParts.joined(separator: " ")
            }
        } else {
            return nil
        }

        let fromUnit = fromUnitRaw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let toUnit = toUnitRaw.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !fromUnit.isEmpty, !toUnit.isEmpty else { return nil }

        // 1. Digital storage
        if let (fromBytes, fromName) = digitalUnitBytes(fromUnit),
           let (toBytes, toName) = digitalUnitBytes(toUnit) {
            let totalBytes = amount * fromBytes
            let converted = totalBytes / toBytes
            let formatted = formatNumber(converted)
            return QuickMathResult(
                display: "\(formatted) \(toName)",
                raw: formatted,
                subtitle: "\(formatNumber(amount)) \(fromName) = \(formatted) \(toName)  •  Press Enter to copy"
            )
        }

        // 2. Length
        if let (fromMeters, fromName) = lengthUnitMeters(fromUnit),
           let (toMeters, toName) = lengthUnitMeters(toUnit) {
            let totalMeters = amount * fromMeters
            let converted = totalMeters / toMeters
            let formatted = formatNumber(converted)
            return QuickMathResult(
                display: "\(formatted) \(toName)",
                raw: formatted,
                subtitle: "\(formatNumber(amount)) \(fromName) = \(formatted) \(toName)  •  Press Enter to copy"
            )
        }

        // 3. Weight / Mass
        if let (fromGrams, fromName) = weightUnitGrams(fromUnit),
           let (toGrams, toName) = weightUnitGrams(toUnit) {
            let totalGrams = amount * fromGrams
            let converted = totalGrams / toGrams
            let formatted = formatNumber(converted)
            return QuickMathResult(
                display: "\(formatted) \(toName)",
                raw: formatted,
                subtitle: "\(formatNumber(amount)) \(fromName) = \(formatted) \(toName)  •  Press Enter to copy"
            )
        }

        // 4. Temperature
        if let tempResult = convertTemperature(amount: amount, from: fromUnit, to: toUnit) {
            return tempResult
        }

        // 5. Time
        if let (fromSeconds, fromName) = timeUnitSeconds(fromUnit),
           let (toSeconds, toName) = timeUnitSeconds(toUnit) {
            let totalSeconds = amount * fromSeconds
            let converted = totalSeconds / toSeconds
            let formatted = formatNumber(converted)
            return QuickMathResult(
                display: "\(formatted) \(toName)",
                raw: formatted,
                subtitle: "\(formatNumber(amount)) \(fromName) = \(formatted) \(toName)  •  Press Enter to copy"
            )
        }

        // 6. Speed
        if let (fromMps, fromName) = speedUnitMps(fromUnit),
           let (toMps, toName) = speedUnitMps(toUnit) {
            let totalMps = amount * fromMps
            let converted = totalMps / toMps
            let formatted = formatNumber(converted)
            return QuickMathResult(
                display: "\(formatted) \(toName)",
                raw: formatted,
                subtitle: "\(formatNumber(amount)) \(fromName) = \(formatted) \(toName)  •  Press Enter to copy"
            )
        }

        return nil
    }

    private static func digitalUnitBytes(_ unit: String) -> (Double, String)? {
        switch unit {
        case "b", "byte", "bytes": return (1.0, "bytes")
        case "kb", "kilobyte", "kilobytes", "kib": return (1024.0, "KB")
        case "mb", "megabyte", "megabytes", "mib": return (1024.0 * 1024.0, "MB")
        case "gb", "gigabyte", "gigabytes", "gib": return (1024.0 * 1024.0 * 1024.0, "GB")
        case "tb", "terabyte", "terabytes", "tib": return (1024.0 * 1024.0 * 1024.0 * 1024.0, "TB")
        case "pb", "petabyte", "petabytes", "pib": return (1024.0 * 1024.0 * 1024.0 * 1024.0 * 1024.0, "PB")
        default: return nil
        }
    }

    private static func lengthUnitMeters(_ unit: String) -> (Double, String)? {
        switch unit {
        case "mm", "millimeter", "millimeters": return (0.001, "mm")
        case "cm", "centimeter", "centimeters": return (0.01, "cm")
        case "m", "meter", "meters": return (1.0, "m")
        case "km", "kilometer", "kilometers": return (1000.0, "km")
        case "in", "inch", "inches", "\"": return (0.0254, "in")
        case "ft", "foot", "feet", "'": return (0.3048, "ft")
        case "yd", "yard", "yards": return (0.9144, "yd")
        case "mi", "mile", "miles": return (1609.344, "mi")
        case "nm", "nautical mile", "nautical miles": return (1852.0, "NM")
        default: return nil
        }
    }

    private static func weightUnitGrams(_ unit: String) -> (Double, String)? {
        switch unit {
        case "mg", "milligram", "milligrams": return (0.001, "mg")
        case "g", "gram", "grams": return (1.0, "g")
        case "kg", "kilogram", "kilograms": return (1000.0, "kg")
        case "oz", "ounce", "ounces": return (28.349523125, "oz")
        case "lb", "lbs", "pound", "pounds": return (453.59237, "lbs")
        case "ton", "tons", "tonne", "tonnes": return (1_000_000.0, "tons")
        default: return nil
        }
    }

    private static func timeUnitSeconds(_ unit: String) -> (Double, String)? {
        switch unit {
        case "ms", "millisecond", "milliseconds": return (0.001, "ms")
        case "s", "sec", "second", "seconds": return (1.0, "s")
        case "min", "mins", "minute", "minutes": return (60.0, "min")
        case "h", "hr", "hrs", "hour", "hours": return (3600.0, "hours")
        case "d", "day", "days": return (86400.0, "days")
        case "w", "wk", "wks", "week", "weeks": return (604800.0, "weeks")
        case "month", "months": return (2629800.0, "months")
        case "yr", "year", "years": return (31557600.0, "years")
        default: return nil
        }
    }

    private static func speedUnitMps(_ unit: String) -> (Double, String)? {
        switch unit {
        case "m/s", "mps": return (1.0, "m/s")
        case "km/h", "kph", "kmh": return (1.0 / 3.6, "km/h")
        case "mph", "mi/h": return (0.44704, "mph")
        case "knot", "knots", "kt": return (0.514444, "knots")
        default: return nil
        }
    }

    private static func convertTemperature(amount: Double, from: String, to: String) -> QuickMathResult? {
        let normalizedFrom = from.trimmingCharacters(in: CharacterSet(charactersIn: "° "))
        let normalizedTo = to.trimmingCharacters(in: CharacterSet(charactersIn: "° "))

        var celsius: Double = 0.0
        switch normalizedFrom {
        case "c", "celsius": celsius = amount
        case "f", "fahrenheit": celsius = (amount - 32.0) * 5.0 / 9.0
        case "k", "kelvin": celsius = amount - 273.15
        default: return nil
        }

        var target: Double = 0.0
        var targetSymbol = ""
        switch normalizedTo {
        case "c", "celsius":
            target = celsius
            targetSymbol = "°C"
        case "f", "fahrenheit":
            target = celsius * 9.0 / 5.0 + 32.0
            targetSymbol = "°F"
        case "k", "kelvin":
            target = celsius + 273.15
            targetSymbol = "K"
        default: return nil
        }

        let formatted = formatNumber(target)
        let fromSymbol = normalizedFrom == "k" ? "K" : "°\(normalizedFrom.uppercased().prefix(1))"
        return QuickMathResult(
            display: "\(formatted) \(targetSymbol)",
            raw: formatted,
            subtitle: "\(formatNumber(amount)) \(fromSymbol) = \(formatted) \(targetSymbol)  •  Press Enter to copy"
        )
    }

    // MARK: - Currency Conversion

    private static let fallbackRatesToUSD: [String: Double] = [
        "USD": 1.0,
        "EUR": 1.09,
        "GBP": 1.28,
        "JPY": 0.0066,
        "CHF": 1.13,
        "CAD": 0.74,
        "AUD": 0.65,
        "CNY": 0.14,
        "INR": 0.012,
        "SGD": 0.75,
        "HKD": 0.128,
        "SEK": 0.096,
        "NOK": 0.094,
        "NZD": 0.60,
        "KRW": 0.00075,
        "TRY": 0.031,
        "BRL": 0.18,
        "MXN": 0.052,
        "ZAR": 0.055,
        "AED": 0.272,
        "SAR": 0.267,
        "THB": 0.028,
        "VND": 0.000040,
        "PLN": 0.25,
        "DKK": 0.146,
        "UAH": 0.024
    ]

    private static let currencySymbols: [String: String] = [
        "$": "USD",
        "€": "EUR",
        "£": "GBP",
        "¥": "JPY",
        "₹": "INR",
        "₽": "RUB",
        "₩": "KRW",
        "₫": "VND",
        "฿": "THB"
    ]

    private static func evaluateCurrencyConversion(_ query: String, bridge: EngineBridge?) -> QuickMathResult? {
        // Try live instant answer first if available
        if let bridge, let answer = bridge.instantAnswer(query: query) {
            return QuickMathResult(
                display: answer.text,
                raw: answer.text,
                subtitle: "\(query)  •  \(answer.source)  •  Press Enter to copy"
            )
        }

        // Offline / fast regex currency conversion
        let parts = query.components(separatedBy: .whitespaces).filter { !$0.isEmpty }
        guard parts.count >= 2 else { return nil }

        var amount: Double = 1.0
        var fromCode = ""
        var toCode = ""

        let separatorIndices = parts.indices.filter {
            let p = parts[$0].lowercased()
            return p == "to" || p == "in" || p == "->" || p == "=>" || p == "="
        }

        guard let sepIdx = separatorIndices.first, sepIdx > 0, sepIdx < parts.count - 1 else {
            return nil
        }

        let leftParts = parts[..<sepIdx]
        let rightParts = parts[(sepIdx + 1)...]

        let rawTo = rightParts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        toCode = currencySymbols[rawTo] ?? rawTo

        if let first = leftParts.first, let parsedAmount = Double(first.replacingOccurrences(of: ",", with: "")) {
            amount = parsedAmount
            let rawFrom = leftParts.dropFirst().joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            fromCode = currencySymbols[rawFrom] ?? rawFrom
        } else {
            let combined = leftParts.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
            if let sym = currencySymbols.keys.first(where: { combined.hasPrefix($0) }) {
                fromCode = currencySymbols[sym] ?? "USD"
                let remainder = combined.dropFirst(sym.count).trimmingCharacters(in: .whitespacesAndNewlines)
                amount = Double(remainder) ?? 1.0
            } else {
                fromCode = combined.uppercased()
            }
        }

        guard let rateFromUSD = fallbackRatesToUSD[fromCode],
              let rateToUSD = fallbackRatesToUSD[toCode] else {
            return nil
        }

        let amountInUSD = amount * rateFromUSD
        let converted = amountInUSD / rateToUSD
        let formatted = formatNumber(converted, decimals: 2)

        return QuickMathResult(
            display: "\(formatted) \(toCode)",
            raw: formatted,
            subtitle: "\(formatNumber(amount, decimals: 2)) \(fromCode) = \(formatted) \(toCode)  •  Press Enter to copy"
        )
    }

    private static func formatNumber(_ val: Double, decimals: Int = 4) -> String {
        if val == floor(val) && val < 1e12 && val > -1e12 {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter.string(from: NSNumber(value: Int64(val))) ?? "\(Int64(val))"
        }

        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.maximumFractionDigits = decimals
        formatter.minimumFractionDigits = 0
        return formatter.string(from: NSNumber(value: val)) ?? String(format: "%.\(decimals)f", val)
    }
}
