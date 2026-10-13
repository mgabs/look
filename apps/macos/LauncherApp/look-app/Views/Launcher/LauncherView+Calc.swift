import Foundation

/// The pinned calculator row: evaluation and intent-detection ("is this
/// arithmetic, not a date/resolution/ratio?") live in the shared `core/calc`
/// crate via `EngineBridge`, so this file is presentation and placement only.
/// Mirrors `LauncherView+URLResults.swift`.
extension LauncherView {
    /// A synthesized row for the current query's arithmetic, unit conversion,
    /// currency, or timestamp answer. Network-free & fast.
    var calcResult: LauncherResult? {
        guard allowsSuggestionRows else { return nil }
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        let evalQuery: String
        let calcExpr: String

        if trimmed.lowercased().hasPrefix("/calc ") {
            let expr = String(trimmed.dropFirst(6)).trimmingCharacters(in: .whitespacesAndNewlines)
            guard !expr.isEmpty else { return nil }
            // Prefix with ? to trigger direct math evaluation in QuickMathService
            evalQuery = "?\(expr)"
            calcExpr = expr
        } else {
            evalQuery = query
            calcExpr = trimmed
        }

        guard let calc = QuickMathService.evaluate(evalQuery, bridge: bridge) else { return nil }

        var result = LauncherResult(
            id: "\(AppConstants.Launcher.Calc.resultIDPrefix)\(calc.raw)",
            kind: .app,
            title: calc.display,
            subtitle: calc.subtitle,
            path: calc.raw,
            score: .max
        )
        result.calcExpression = calcExpr
        result.calcRawValue = calc.raw
        return result
    }
}
