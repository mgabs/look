import Combine
import SwiftUI

/// The launchpad's L slot (2x2). Priority-driven, with a crossfade when the
/// active source changes:
///
/// - Pomo when a Pomodoro session is running (highest priority).
/// - Todo when no session runs but tasks remain today.
/// - Clock as the fallback when neither applies.
///
/// This is the one launchpad tile wired to live state in the layout pass, since
/// the Todo and Pomo stores already exist.
struct LaunchpadLSlotView: View {
    var themeStore: ThemeStore

    private typealias Const = AppConstants.Launcher.Launchpad

    private enum Slot: Equatable { case todo, pomo, clock }

    /// Pomo wins whenever a session is running; else Todo when tasks remain;
    /// else the Clock fallback.
    private var current: Slot {
        if PomoSharedState.shared.activeIndex != nil { return .pomo }
        if todoRemaining > 0 { return .todo }
        return .clock
    }

    private var todoRemaining: Int {
        TodoSharedState.shared.today?.openCount ?? 0
    }

    var body: some View {
        ZStack {
            switch current {
            case .todo:
                LaunchpadTodoTile(themeStore: themeStore)
            case .pomo:
                LaunchpadPomoTile(themeStore: themeStore)
            case .clock:
                LaunchpadClockTile(themeStore: themeStore)
            }
        }
        .id(current)
        .transition(.opacity)
        .animation(.easeInOut(duration: Const.rotateFadeSeconds), value: current)
    }
}

// MARK: - Todo tile

/// Done/total today plus a rotating next-task name (cycles per the spec).
private struct LaunchpadTodoTile: View {
    var themeStore: ThemeStore

    private typealias Const = AppConstants.Launcher.Launchpad

    @State private var taskIndex = 0

    @StateObject private var ticker = LauncherActiveTicker(
        every: AppConstants.Launcher.Launchpad.todoTaskRotateSeconds
    )

    private var stat: TodoStat { TodoSharedState.shared.todayStat }
    private var openTasks: [String] {
        TodoSharedState.shared.today?.tasks.filter { !$0.done }.map(\.name) ?? []
    }

    var body: some View {
        LaunchpadSlotCard(themeStore: themeStore, iconName: "checklist", showsClock: true) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text("\(stat.done)/\(stat.total)")
                        .font(themeStore.uiFont(size: 26, weight: .bold))
                        .foregroundColor(themeStore.fontColor())
                    Text("done today")
                        .font(themeStore.uiFont(size: Const.titleFontSize))
                        .foregroundColor(themeStore.secondaryTextColor())
                }
                HStack(spacing: 6) {
                    Circle()
                        .fill(themeStore.accentColor())
                        .frame(width: 5, height: 5)
                    Text(nextTaskLabel)
                        .font(themeStore.uiFont(size: Const.captionFontSize + 1))
                        .foregroundColor(themeStore.secondaryTextColor())
                        .lineLimit(1)
                        .id(taskIndex)
                        .transition(.opacity)
                }
                .animation(.easeInOut(duration: 0.35), value: taskIndex)
            }
        }
        .onReceive(ticker.tick) { _ in
            guard openTasks.count > 1 else { return }
            taskIndex = (taskIndex + 1) % openTasks.count
        }
    }

    private var nextTaskLabel: String {
        let tasks = openTasks
        guard !tasks.isEmpty else { return "All clear" }
        return tasks[taskIndex % tasks.count]
    }
}

// MARK: - Pomo tile

/// Live countdown, phase + session, and a progress bar for the running session.
private struct LaunchpadPomoTile: View {
    var themeStore: ThemeStore

    private typealias Const = AppConstants.Launcher.Launchpad

    private var state: PomoState { PomoSharedState.shared }

    var body: some View {
        LaunchpadSlotCard(themeStore: themeStore, iconName: "timer", showsClock: true) {
            VStack(alignment: .leading, spacing: 8) {
                Text(PomoCommand.formattedRemaining(state.secondsLeft))
                    .font(themeStore.uiFont(size: 30, weight: .bold))
                    .foregroundColor(themeStore.fontColor())
                    .monospacedDigit()
                    .contentTransition(.numericText(countsDown: true))
                    .animation(Motion.Value.rollDigits, value: state.secondsLeft)
                Text(phaseLabel)
                    .font(themeStore.uiFont(size: Const.captionFontSize + 1))
                    .foregroundColor(themeStore.secondaryTextColor())
                ProgressView(value: min(max(state.progress, 0), 1))
                    .tint(themeStore.accentColor())
                    .frame(height: 3)
            }
        }
    }

    private var phaseLabel: String {
        let phase = state.currentSession?.type == .focus ? "Focus" : "Break"
        guard let index = state.activeIndex else { return phase }
        return "\(phase) - session \(index + 1)/\(state.sessions.count)"
    }
}

// MARK: - Clock tile

/// Live time + date fallback, with today's lunar date in the top-right corner
/// (read from the shared `core/lunar` crate). Non-sensitive; safe during
/// screen-share.
private struct LaunchpadClockTile: View {
    var themeStore: ThemeStore

    private typealias Const = AppConstants.Launcher.Launchpad

    @State private var now = Date()
    @State private var secondaryBadge: SecondaryCalendarBadgeData?

    @StateObject private var ticker = LauncherActiveTicker(
        every: AppConstants.Launcher.Launchpad.clockTickSeconds
    )

    var body: some View {
        LaunchpadSlotCard(
            themeStore: themeStore,
            iconName: "clock",
            headerTrailing: secondaryBadge.map { AnyView(SecondaryCalendarBadge(badge: $0, themeStore: themeStore)) }
        ) {
            VStack(alignment: .leading, spacing: 6) {
                Text(now, format: .dateTime.hour().minute())
                    .font(themeStore.uiFont(size: 30, weight: .bold))
                    .foregroundColor(themeStore.fontColor())
                    .monospacedDigit()
                Text(now, format: .dateTime.weekday().month().day())
                    .font(themeStore.uiFont(size: Const.titleFontSize))
                    .foregroundColor(themeStore.secondaryTextColor())
            }
        }
        .onAppear { refreshCalendar(for: now) }
        .onChange(of: themeStore.settings.secondaryCalendar) { _, _ in
            refreshCalendar(for: now)
        }
        .onChange(of: themeStore.settings.hijriDayOffset) { _, _ in
            refreshCalendar(for: now)
        }
        .onReceive(ticker.tick) { tick in
            if secondaryBadge == nil || !Calendar.current.isDate(tick, inSameDayAs: now) {
                refreshCalendar(for: tick)
            }
            now = tick
        }
    }

    private func refreshCalendar(for date: Date) {
        secondaryBadge = SecondaryCalendarResolver.resolve(
            for: date,
            kind: themeStore.settings.secondaryCalendar,
            hijriOffset: themeStore.settings.hijriDayOffset
        )
    }
}

/// Data model representing a secondary calendar readout.
private struct SecondaryCalendarBadgeData: Equatable {
    let dayMonth: String
    let year: String
    let label: String
    let inlineText: String
}

private enum SecondaryCalendarResolver {
    static func resolve(
        for date: Date,
        kind: SecondaryCalendarKind,
        hijriOffset: Int = 0
    ) -> SecondaryCalendarBadgeData? {
        let parts = Calendar.current.dateComponents([.year, .month, .day], from: date)
        guard let year = parts.year, let month = parts.month, let day = parts.day else { return nil }

        switch kind {
        case .none:
            return nil
        case .lunar:
            let tzHours = Double(TimeZone.current.secondsFromGMT(for: date)) / 3600.0
            guard let lunar = EngineBridge.shared.lunarDate(year: year, month: month, day: day, tzHours: tzHours) else {
                return nil
            }
            let label = lunar.leap
                ? AppConstants.Launcher.Launchpad.lunarLeapLabel
                : AppConstants.Launcher.Launchpad.lunarLabel
            return SecondaryCalendarBadgeData(
                dayMonth: "\(lunar.day)/\(lunar.month)",
                year: "\(lunar.year)",
                label: label,
                inlineText: "\(lunar.day)/\(lunar.month)/\(lunar.year) \(label)"
            )
        case .hijri:
            guard let hijri = EngineBridge.shared.hijriDate(year: year, month: month, day: day, offsetDays: hijriOffset) else {
                return nil
            }
            let monthName = hijriMonthName(hijri.month)
            let dayMonth = "\(hijri.day) \(monthName)"
            return SecondaryCalendarBadgeData(
                dayMonth: dayMonth,
                year: "\(hijri.year) AH",
                label: AppConstants.Launcher.Launchpad.hijriLabel,
                inlineText: "\(dayMonth) \(hijri.year) AH"
            )
        }
    }

    private static func hijriMonthName(_ month: Int) -> String {
        switch month {
        case 1: return "Muharram"
        case 2: return "Safar"
        case 3: return "Rabi' I"
        case 4: return "Rabi' II"
        case 5: return "Jumada I"
        case 6: return "Jumada II"
        case 7: return "Rajab"
        case 8: return "Sha'ban"
        case 9: return "Ramadan"
        case 10: return "Shawwal"
        case 11: return "Dhu al-Qi'dah"
        case 12: return "Dhu al-Hijjah"
        default: return "\(month)"
        }
    }
}

/// Secondary calendar badge in clock tile header.
private struct SecondaryCalendarBadge: View {
    let badge: SecondaryCalendarBadgeData
    var themeStore: ThemeStore

    private typealias Const = AppConstants.Launcher.Launchpad

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            Text(badge.dayMonth)
                .font(themeStore.uiFont(size: Const.captionFontSize + 5, weight: .semibold))
                .foregroundColor(themeStore.secondaryTextColor())
                .monospacedDigit()
            Text(yearLabel)
                .font(themeStore.uiFont(size: Const.captionFontSize - 1))
                .foregroundColor(themeStore.mutedTextColor())
                .monospacedDigit()
        }
    }

    private var yearLabel: String {
        badge.label.isEmpty || badge.year.hasSuffix("AH")
            ? badge.year
            : "\(badge.year) \(badge.label)"
    }
}

// MARK: - Header clock

/// Time + Gregorian date (full strength) with secondary calendar date dimmed below.
private struct LaunchpadHeaderClock: View {
    var themeStore: ThemeStore

    private typealias Const = AppConstants.Launcher.Launchpad

    @State private var now = Date()
    @State private var secondaryBadge: SecondaryCalendarBadgeData?

    @StateObject private var ticker = LauncherActiveTicker(
        every: AppConstants.Launcher.Launchpad.clockTickSeconds
    )

    var body: some View {
        VStack(alignment: .trailing, spacing: Const.headerClockLineSpacing) {
            Text(now, format: .dateTime.hour().minute())
                .font(themeStore.uiFont(size: Const.headerClockTimeFontSize, weight: .semibold))
                .foregroundColor(themeStore.secondaryTextColor())
                .monospacedDigit()
            Text(now, format: .dateTime.weekday().month().day())
                .font(themeStore.uiFont(size: Const.headerClockDateFontSize))
                .foregroundColor(themeStore.secondaryTextColor())
            if let secondaryBadge {
                Text(secondaryBadge.inlineText)
                    .font(themeStore.uiFont(size: Const.headerClockDateFontSize))
                    .foregroundColor(themeStore.mutedTextColor())
                    .monospacedDigit()
            }
        }
        .onAppear { refreshCalendar(for: now) }
        .onChange(of: themeStore.settings.secondaryCalendar) { _, _ in
            refreshCalendar(for: now)
        }
        .onChange(of: themeStore.settings.hijriDayOffset) { _, _ in
            refreshCalendar(for: now)
        }
        .onReceive(ticker.tick) { tick in
            if secondaryBadge == nil || !Calendar.current.isDate(tick, inSameDayAs: now) {
                refreshCalendar(for: tick)
            }
            now = tick
        }
    }

    private func refreshCalendar(for date: Date) {
        secondaryBadge = SecondaryCalendarResolver.resolve(
            for: date,
            kind: themeStore.settings.secondaryCalendar,
            hijriOffset: themeStore.settings.hijriDayOffset
        )
    }
}

// MARK: - Shared L-slot card chrome

/// The common 2x2 card frame: an icon badge in the top-left, an optional header
/// readout in the top-right, and the slot's content pinned to the bottom. When
/// `showsClock` is set, a compact time + date sits in the header so it stays
/// visible even while the Todo or Pomo slot occupies the tile.
/// The L slot's outline sits lighter than the theme divider it derives from, so
/// the largest tile does not read as the most heavily framed.
private let slotBorderOpacity = 0.4

private struct LaunchpadSlotCard<Content: View>: View {
    var themeStore: ThemeStore
    let iconName: String
    var showsClock: Bool = false
    /// Optional readout pinned to the header's top-right (e.g. the clock tile's
    /// lunar date). Stays inside this card, beside the icon.
    var headerTrailing: AnyView? = nil
    @ViewBuilder var content: () -> Content

    private typealias Const = AppConstants.Launcher.Launchpad

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 8) {
                ZStack {
                    RoundedRectangle(cornerRadius: themeStore.tileRadius, style: .continuous)
                        .fill(themeStore.selectionFillColor())
                    Image(systemName: iconName)
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(themeStore.accentColor())
                }
                .frame(width: 40, height: 40)
                Spacer(minLength: 0)
                if showsClock {
                    LaunchpadHeaderClock(themeStore: themeStore)
                }
                if let headerTrailing {
                    headerTrailing
                }
            }
            Spacer(minLength: 0)
            content()
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(frostedTile(themeStore: themeStore))
        .overlay(
            // Same scaled radius as `frostedTile`, or the outline cuts the corners.
            RoundedRectangle(
                cornerRadius: themeStore.tileRadius,
                style: .continuous
            )
            .strokeBorder(themeStore.dividerColor().opacity(slotBorderOpacity), lineWidth: 1)
        )
    }
}
