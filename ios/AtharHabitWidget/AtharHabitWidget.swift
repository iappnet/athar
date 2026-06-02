//
//  AtharHabitWidget.swift
//  AtharHabitWidget
//
//  Updated PR9: forest v2 palette, ring-based layouts (small/medium/large),
//  Calibri font tokens, 7-day history grid (OQ4 confirmed), cap raised to 6,
//  success ring color #27AE60 (OQ5).
//
//  NOTE — Xcode manual steps required for Calibri (OQ3):
//    1. For the AtharHabitWidgetExtension target: Add Files → select
//       calibri-light.ttf, calibri-regular.ttf, calibri-bold.ttf from
//       assets/fonts/ → ensure only AtharHabitWidgetExtension is checked.
//    2. Open AtharHabitWidgetExtension/Info.plist → add UIAppFonts array →
//       three items: "calibri-light.ttf", "calibri-regular.ttf", "calibri-bold.ttf".
//    3. Device validate: font renders without system fallback.
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: – Shared App Group constants

private let kGroupId            = "group.com.iappsnet.athar"
private let kHabitsKey          = "athar_habits"
private let kHabitsTotalKey     = "athar_habits_total"
private let kHabitsDoneKey      = "athar_habits_done"
private let kAppLocaleKey       = "athar_app_locale"
private let kPendingActionsKey  = "athar_pending_habit_actions"
private let kHabitsHistory7dKey = "athar_habits_history_7d"   // v7: 7-element int array

// MARK: – Design tokens — Athar v2 forest palette + success
// OQ7 DEFERRED: inline consts; keep in sync with AtharColors.dart.

private extension Color {
    static let athaForest    = Color(red: 0.059, green: 0.239, blue: 0.180) // #0F3D2E
    static let athaForestMid = Color(red: 0.102, green: 0.353, blue: 0.271) // #1A5A45
    static let athaCream     = Color(red: 0.929, green: 0.902, blue: 0.784) // #EDE6C8
    static let habitSuccess  = Color(red: 0.153, green: 0.682, blue: 0.376) // #27AE60 (OQ5)
    static let habitTeal     = Color(red: 0.20,  green: 0.65,  blue: 0.75)
}

// MARK: – Calibri font helpers

private func calibri(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
    switch weight {
    case .light: return Font.custom("Calibri-Light", size: size)
    case .bold:  return Font.custom("Calibri-Bold",  size: size)
    default:     return Font.custom("Calibri",       size: size)
    }
}

// MARK: – Data model

struct WHabit: Identifiable, Decodable {
    var id: String { uuid }
    let title: String
    let done: Bool
    let streak: Int
    let uuid: String
    let currentProgress: Int
    let target: Int
    let type: String     // "r" = regular, "a" = athkar

    enum CodingKeys: String, CodingKey {
        case title           = "t"
        case done            = "d"
        case streak          = "s"
        case uuid            = "u"
        case currentProgress = "cp"
        case target          = "tg"
        case type            = "tp"
    }

    init(from decoder: Decoder) throws {
        let c           = try decoder.container(keyedBy: CodingKeys.self)
        title           = (try? c.decode(String.self, forKey: .title))           ?? ""
        done            = (try? c.decode(Bool.self,   forKey: .done))            ?? false
        streak          = (try? c.decode(Int.self,    forKey: .streak))          ?? 0
        uuid            = (try? c.decode(String.self, forKey: .uuid))            ?? ""
        currentProgress = (try? c.decode(Int.self,    forKey: .currentProgress)) ?? 0
        target          = (try? c.decode(Int.self,    forKey: .target))          ?? 1
        type            = (try? c.decode(String.self, forKey: .type))            ?? "r"
    }

    init(title: String, done: Bool, streak: Int, uuid: String,
         currentProgress: Int, target: Int, type: String = "r") {
        self.title           = title
        self.done            = done
        self.streak          = streak
        self.uuid            = uuid
        self.currentProgress = currentProgress
        self.target          = target
        self.type            = type
    }

    var isAthkar: Bool     { type == "a" }
    var isCountBased: Bool { !isAthkar && target > 1 }

    var progressFraction: Double {
        guard target > 0 else { return 0 }
        return min(1.0, Double(currentProgress) / Double(target))
    }
}

// MARK: – Timeline entry

struct HabitEntry: TimelineEntry {
    let date:      Date
    let habits:    [WHabit]
    let total:     Int
    let done:      Int
    let lang:      String           // "ar" | "en"
    let history7d: [Int]            // index 0 = 6 days ago, index 6 = today (OQ4)
    var isArabic: Bool { lang == "ar" }
}

// MARK: – Progress ring view (OQ5: success color #27AE60)

private struct ProgressRingView: View {
    let fraction: Double
    let size: CGFloat

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.15), lineWidth: 4)
            Circle()
                .trim(from: 0, to: fraction)
                .stroke(Color.habitSuccess,
                        style: StrokeStyle(lineWidth: 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .frame(width: size, height: size)
    }
}

// MARK: – Widget language configuration

enum WidgetLanguage: String, AppEnum {
    case system
    case arabic
    case english

    static var typeDisplayRepresentation =
        TypeDisplayRepresentation(name: "Language")

    static var caseDisplayRepresentations: [WidgetLanguage: DisplayRepresentation] = [
        .system:  DisplayRepresentation(title: "System"),
        .arabic:  DisplayRepresentation(title: "العربية"),
        .english: DisplayRepresentation(title: "English"),
    ]
}

// MARK: – Locale resolver

private func resolvedLang(intent: WidgetLanguage, stored: String?) -> String {
    switch intent {
    case .arabic:  return "ar"
    case .english: return "en"
    case .system:
        if let code = Locale.current.language.languageCode?.identifier {
            return code == "ar" ? "ar" : "en"
        }
        return "en"
    }
}

// MARK: – Shared pending-action writer

private func appendPendingHabitAction(d: UserDefaults?, type: String, uuid: String) {
    var pending: [[String: Any]] = []
    if let s    = d?.string(forKey: kPendingActionsKey),
       let data = s.data(using: .utf8),
       let arr  = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
        pending = arr
    }
    pending.append([
        "type":      type,
        "uuid":      uuid,
        "createdAt": Date().timeIntervalSince1970,
    ])
    if let encoded = try? JSONSerialization.data(withJSONObject: pending),
       let str     = String(data: encoded, encoding: .utf8) {
        d?.set(str, forKey: kPendingActionsKey)
    }
}

// MARK: – Widget configuration intent

struct HabitWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Today's Habits · عادات اليوم"
    static var description = IntentDescription(
        "Show today's habits with interactive completion."
    )

    @Parameter(title: "Language", default: .system)
    var language: WidgetLanguage
}

// MARK: – CompleteHabitIntent

struct CompleteHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "إتمام العادة"
    static var isDiscoverable: Bool = false

    @Parameter(title: "Habit UUID") var habitUuid: String

    init() { habitUuid = "" }
    init(habitUuid: String) { self.habitUuid = habitUuid }

    func perform() async throws -> some IntentResult {
        let d = UserDefaults(suiteName: kGroupId)
        appendPendingHabitAction(d: d, type: "complete_habit", uuid: habitUuid)
        optimisticallyToggle(d: d)
        WidgetCenter.shared.reloadTimelines(ofKind: "AtharHabitWidget")
        return .result()
    }

    private func optimisticallyToggle(d: UserDefaults?) {
        guard let json = d?.string(forKey: kHabitsKey),
              let data = json.data(using: .utf8),
              var arr  = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else { return }

        var wasDone: Bool? = nil
        for i in arr.indices where (arr[i]["u"] as? String) == habitUuid {
            wasDone     = arr[i]["d"] as? Bool
            let newDone = !(wasDone ?? false)
            arr[i]["d"] = newDone
            let tg       = arr[i]["tg"] as? Int ?? 1
            arr[i]["cp"] = newDone ? tg : 0
            break
        }

        if let encoded = try? JSONSerialization.data(withJSONObject: arr),
           let str     = String(data: encoded, encoding: .utf8) {
            d?.set(str, forKey: kHabitsKey)
        }

        let currentDone = d?.integer(forKey: kHabitsDoneKey) ?? 0
        let was = wasDone ?? false
        if !was { d?.set(currentDone + 1,         forKey: kHabitsDoneKey) }
        else    { d?.set(max(0, currentDone - 1), forKey: kHabitsDoneKey) }
    }
}

// MARK: – IncrementHabitIntent

struct IncrementHabitIntent: AppIntent {
    static var title: LocalizedStringResource = "إضافة تقدم"
    static var isDiscoverable: Bool = false

    @Parameter(title: "Habit UUID") var habitUuid: String

    init() { habitUuid = "" }
    init(habitUuid: String) { self.habitUuid = habitUuid }

    func perform() async throws -> some IntentResult {
        let d = UserDefaults(suiteName: kGroupId)
        appendPendingHabitAction(d: d, type: "increment_habit", uuid: habitUuid)
        optimisticallyIncrement(d: d)
        WidgetCenter.shared.reloadTimelines(ofKind: "AtharHabitWidget")
        return .result()
    }

    private func optimisticallyIncrement(d: UserDefaults?) {
        guard let json = d?.string(forKey: kHabitsKey),
              let data = json.data(using: .utf8),
              var arr  = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else { return }

        var becameDone = false
        for i in arr.indices where (arr[i]["u"] as? String) == habitUuid {
            let tg      = arr[i]["tg"] as? Int ?? 1
            let cp      = (arr[i]["cp"] as? Int ?? 0) + 1
            let clamped = min(cp, tg)
            arr[i]["cp"] = clamped
            if clamped >= tg && !(arr[i]["d"] as? Bool ?? false) {
                arr[i]["d"] = true
                becameDone = true
            }
            break
        }

        if let encoded = try? JSONSerialization.data(withJSONObject: arr),
           let str     = String(data: encoded, encoding: .utf8) {
            d?.set(str, forKey: kHabitsKey)
        }

        if becameDone {
            let currentDone = d?.integer(forKey: kHabitsDoneKey) ?? 0
            d?.set(currentDone + 1, forKey: kHabitsDoneKey)
        }
    }
}

// MARK: – Timeline provider

struct HabitProvider: AppIntentTimelineProvider {

    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(
            date:   .now,
            habits: [
                WHabit(title: "قراءة القرآن الكريم", done: false, streak: 7,
                       uuid: "ph-1", currentProgress: 0, target: 1),
                WHabit(title: "مراجعة المحفوظات",    done: true,  streak: 3,
                       uuid: "ph-2", currentProgress: 1, target: 1),
                WHabit(title: "أوراد الصباح",         done: false, streak: 0,
                       uuid: "ph-3", currentProgress: 2, target: 5),
            ],
            total: 5, done: 1, lang: "ar",
            history7d: [2, 3, 5, 5, 4, 3, 1]
        )
    }

    func snapshot(for configuration: HabitWidgetIntent, in context: Context) async -> HabitEntry {
        readEntry(configuration: configuration)
    }

    func timeline(for configuration: HabitWidgetIntent, in context: Context) async -> Timeline<HabitEntry> {
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        return Timeline(entries: [readEntry(configuration: configuration)], policy: .after(next))
    }

    private func readEntry(configuration: HabitWidgetIntent) -> HabitEntry {
        let d     = UserDefaults(suiteName: kGroupId)
        let total = d?.integer(forKey: kHabitsTotalKey) ?? 0
        let done  = d?.integer(forKey: kHabitsDoneKey)  ?? 0
        let lang  = resolvedLang(intent: configuration.language,
                                 stored: d?.string(forKey: kAppLocaleKey))

        var habits: [WHabit] = []
        if let json    = d?.string(forKey: kHabitsKey),
           let data    = json.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([WHabit].self, from: data) {
            habits = decoded.filter { !$0.uuid.isEmpty }
        }

        // 7-day history (v7 key; falls back to all-zeros when key absent)
        var history7d: [Int] = Array(repeating: 0, count: 7)
        if let json = d?.string(forKey: kHabitsHistory7dKey),
           let data = json.data(using: .utf8),
           let arr  = try? JSONDecoder().decode([Int].self, from: data),
           arr.count == 7 {
            history7d = arr
        }

        return HabitEntry(date: .now, habits: habits, total: total, done: done,
                          lang: lang, history7d: history7d)
    }
}

// MARK: – Background modifier

private struct HabitWidgetBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .containerBackground(for: .widget) {
                ZStack {
                    LinearGradient(
                        colors: [.athaForest, .athaForestMid],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Color.white.opacity(0.03)
                }
            }
    }
}

// MARK: – Widget view

struct HabitWidgetView: View {
    let entry: HabitEntry
    @Environment(\.widgetFamily) var family

    private var fractionDone: Double {
        guard entry.total > 0 else { return 0 }
        return min(1.0, Double(entry.done) / Double(entry.total))
    }

    var body: some View {
        Group {
            switch family {
            case .systemSmall:  smallBody
            case .systemLarge:  largeBody
            default:            mediumBody
            }
        }
        .modifier(HabitWidgetBackground())
        .environment(\.layoutDirection, entry.isArabic ? .rightToLeft : .leftToRight)
    }

    // ── small: ring-based (OQ1 spec §2a) ─────────────────────────────────────
    // 28pt ring + done/total inside + "Habits today" label below

    private var smallBody: some View {
        VStack(spacing: 10) {
            ZStack {
                ProgressRingView(fraction: fractionDone, size: 72)
                VStack(spacing: 1) {
                    Text("\(entry.done)")
                        .font(calibri(22, .bold))
                        .foregroundColor(.white)
                    Text("/ \(entry.total)")
                        .font(calibri(11))
                        .foregroundColor(.athaCream.opacity(0.7))
                }
            }

            Text(entry.isArabic ? "عادات اليوم" : "Habits today")
                .font(calibri(12))
                .foregroundColor(.athaCream.opacity(0.85))
                .lineLimit(1)
        }
        .padding(14)
    }

    // ── medium: ring + top-3 + 7-day dots (OQ4 §2b) ──────────────────────────

    private var mediumBody: some View {
        VStack(spacing: 8) {
            HStack(alignment: .top, spacing: 14) {

                // Left: ring + title
                VStack(spacing: 4) {
                    ZStack {
                        ProgressRingView(fraction: fractionDone, size: 65)
                        VStack(spacing: 0) {
                            Text("\(entry.done)")
                                .font(calibri(20, .bold))
                                .foregroundColor(.white)
                            Text("/ \(entry.total)")
                                .font(calibri(10))
                                .foregroundColor(.athaCream.opacity(0.7))
                        }
                    }
                    Text(entry.isArabic ? "عادات اليوم" : "Habits today")
                        .font(calibri(9))
                        .foregroundColor(.athaCream.opacity(0.75))
                        .lineLimit(1)
                }

                // Right: top-3 habit rows
                VStack(alignment: .leading, spacing: 6) {
                    if entry.habits.isEmpty {
                        Spacer()
                        Text(entry.isArabic ? "لا توجد عادات" : "No habits today")
                            .font(calibri(11))
                            .foregroundColor(.white.opacity(0.35))
                        Spacer()
                    } else {
                        ForEach(Array(entry.habits.prefix(3))) { habit in
                            habitRow(habit)
                        }
                        Spacer(minLength: 0)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }

            // 7-day completion dot grid (OQ4)
            weekHistoryRow
        }
        .padding(14)
    }

    // ── large: ring header + list max 6 (cap raised Dart-side) ───────────────

    private var largeBody: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Header: ring + stats
            HStack(alignment: .center, spacing: 14) {
                ZStack {
                    ProgressRingView(fraction: fractionDone, size: 72)
                    VStack(spacing: 0) {
                        Text("\(entry.done)")
                            .font(calibri(22, .bold))
                            .foregroundColor(.white)
                        Text("/ \(entry.total)")
                            .font(calibri(11))
                            .foregroundColor(.athaCream.opacity(0.7))
                    }
                }
                VStack(alignment: .leading, spacing: 3) {
                    Text(entry.isArabic ? "عادات اليوم" : "Today's Habits")
                        .font(calibri(14, .bold))
                        .foregroundColor(.athaCream)
                    if let first = entry.habits.first, first.streak > 1 {
                        HStack(spacing: 3) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 11))
                                .foregroundColor(.orange)
                            Text(entry.isArabic
                                 ? "\(first.streak) أيام متتالية"
                                 : "\(first.streak) day streak")
                                .font(calibri(11))
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
                Spacer()
            }
            .padding(.bottom, 10)

            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 1)

            habitRows(max: 6)
        }
        .padding(14)
    }

    // ── 7-day weekly dot grid ─────────────────────────────────────────────────

    private var weekHistoryRow: some View {
        HStack(spacing: 0) {
            ForEach(Array(entry.history7d.enumerated()), id: \.0) { i, count in
                VStack(spacing: 3) {
                    Circle()
                        .fill(count > 0 ? Color.habitSuccess : Color.white.opacity(0.15))
                        .frame(width: 7, height: 7)
                    Text(weekDayLabel(daysAgo: 6 - i, isArabic: entry.isArabic))
                        .font(.system(size: 7))
                        .foregroundColor(.white.opacity(0.35))
                }
                .frame(maxWidth: .infinity)
            }
        }
    }

    private func weekDayLabel(daysAgo: Int, isArabic: Bool) -> String {
        let date = Calendar.current.date(byAdding: .day, value: -daysAgo, to: Date()) ?? Date()
        let fmt  = DateFormatter()
        fmt.locale     = Locale(identifier: isArabic ? "ar_SA" : "en_US")
        fmt.dateFormat = "EEEEE"   // narrow weekday symbol
        return fmt.string(from: date)
    }

    // ── list of habit rows ─────────────────────────────────────────────────────

    private func habitRows(max: Int) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            if entry.habits.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text(entry.isArabic ? "لا توجد عادات اليوم" : "No habits today")
                        .font(calibri(12))
                        .foregroundColor(.white.opacity(0.35))
                    Spacer()
                }
                Spacer()
            } else {
                ForEach(Array(entry.habits.prefix(max))) { habit in
                    habitRow(habit)
                }
                Spacer()
            }
        }
        .padding(.top, 8)
    }

    @ViewBuilder
    private func habitRow(_ habit: WHabit) -> some View {
        if habit.isAthkar {
            athkarRow(habit)
        } else if habit.isCountBased {
            countBasedRow(habit)
        } else {
            booleanRow(habit)
        }
    }

    // ── athkar row (read-only) ─────────────────────────────────────────────────

    private func athkarRow(_ habit: WHabit) -> some View {
        HStack(spacing: 8) {
            Image(systemName: habit.done ? "book.closed.fill" : "book.fill")
                .font(.system(size: 14, weight: .light))
                .foregroundColor(habit.done ? .white.opacity(0.30) : .athaCream.opacity(0.80))

            Text(habit.title)
                .font(calibri(12))
                .foregroundColor(habit.done ? .white.opacity(0.30) : .white)
                .strikethrough(habit.done, color: .white.opacity(0.30))
                .lineLimit(1)

            Spacer(minLength: 4)

            if habit.target > 1 {
                Text("\(habit.currentProgress)/\(habit.target)")
                    .font(calibri(10))
                    .foregroundColor(habit.done ? .white.opacity(0.30) : .athaCream.opacity(0.70))
            } else if habit.done {
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white.opacity(0.40))
            }
        }
    }

    // ── boolean habit row ──────────────────────────────────────────────────────

    private func booleanRow(_ habit: WHabit) -> some View {
        HStack(spacing: 8) {
            Button(intent: CompleteHabitIntent(habitUuid: habit.uuid)) {
                Image(systemName: habit.done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(habit.done ? .habitSuccess : .white.opacity(0.45))
            }
            .buttonStyle(.plain)

            Text(habit.title)
                .font(calibri(12))
                .foregroundColor(habit.done ? .white.opacity(0.30) : .white)
                .strikethrough(habit.done, color: .white.opacity(0.30))
                .lineLimit(1)

            Spacer(minLength: 4)

            if habit.streak > 0 {
                streakBadge(habit.streak)
            }
        }
    }

    // ── count-based habit row ──────────────────────────────────────────────────

    private func countBasedRow(_ habit: WHabit) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 8) {
                if habit.done {
                    Button(intent: CompleteHabitIntent(habitUuid: habit.uuid)) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(.habitSuccess)
                    }
                    .buttonStyle(.plain)
                } else {
                    Button(intent: IncrementHabitIntent(habitUuid: habit.uuid)) {
                        Image(systemName: "plus.circle")
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(.habitTeal)
                    }
                    .buttonStyle(.plain)
                }

                Text(habit.title)
                    .font(calibri(12))
                    .foregroundColor(habit.done ? .white.opacity(0.30) : .white)
                    .strikethrough(habit.done, color: .white.opacity(0.30))
                    .lineLimit(1)

                Spacer(minLength: 4)

                Text("\(habit.currentProgress)/\(habit.target)")
                    .font(calibri(10))
                    .foregroundColor(habit.done ? .habitSuccess : .habitTeal)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 3)
                    Capsule()
                        .fill(habit.done ? Color.habitSuccess : Color.habitTeal)
                        .frame(width: geo.size.width * habit.progressFraction, height: 3)
                }
            }
            .frame(height: 3)
        }
    }

    // ── streak badge ───────────────────────────────────────────────────────────

    private func streakBadge(_ streak: Int) -> some View {
        HStack(spacing: 2) {
            Image(systemName: "flame.fill")
                .font(.system(size: 9))
                .foregroundColor(.orange)
            Text("\(streak)")
                .font(calibri(9, .bold))
                .foregroundColor(.orange)
        }
    }
}

// MARK: – Widget declaration

struct AtharHabitWidget: Widget {
    let kind = "AtharHabitWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind:     kind,
            intent:   HabitWidgetIntent.self,
            provider: HabitProvider()
        ) { entry in
            HabitWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's Habits · عادات اليوم")
        .description("Show today's habits with interactive completion.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct AtharHabitWidgetBundle: WidgetBundle {
    var body: some Widget {
        AtharHabitWidget()
    }
}
