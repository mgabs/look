import Foundation

/// The pinned calculator row: evaluation and intent-detection ("is this
/// arithmetic, not a date/resolution/ratio?") live in the shared `core/calc`
/// crate via `EngineBridge`, so this file is presentation and placement only.
/// Mirrors `LauncherView+URLResults.swift`.
extension LauncherView {
    /// A synthesized row for the current query's arithmetic, unit conversion,
    /// currency, or timestamp answer. Network-free & fast.
    var calcResult: LauncherResult? {
        guard allowsSuggestionRows, let calc = QuickMathService.evaluate(query, bridge: bridge) else { return nil }
        let expr = query.trimmingCharacters(in: .whitespacesAndNewlines)

        var result = LauncherResult(
            id: "\(AppConstants.Launcher.Calc.resultIDPrefix)\(calc.raw)",
            kind: .app,
            title: calc.display,
            subtitle: calc.subtitle,
            path: calc.raw,
            score: .max
        )
        result.calcExpression = expr
        result.calcRawValue = calc.raw
        return result
    }
}
