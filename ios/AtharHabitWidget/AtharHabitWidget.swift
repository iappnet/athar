//
//  AtharHabitWidget.swift
//  AtharHabitWidget
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: – Shared App Group constants

private let kGroupId           = "group.com.iappsnet.athar"
private let kHabitsKey         = "athar_habits"
private let kHabitsTotalKey    = "athar_habits_total"
private let kHabitsDoneKey     = "athar_habits_done"
private let kAppLocaleKey      = "athar_app_locale"
private let kPendingActionsKey = "athar_pending_habit_actions"

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

    // Resilient decoder: missing / wrong-type fields fall back to safe defaults.
    init(from decoder: Decoder) throws {
        let c               = try decoder.container(keyedBy: CodingKeys.self)
        title               = (try? c.decode(String.self, forKey: .title)) ?? ""
        done                = (try? c.decode(Bool.self,   forKey: .done))  ?? false
        streak              = (try? c.decode(Int.self,    forKey: .streak)) ?? 0
        uuid                = (try? c.decode(String.self, forKey: .uuid))  ?? ""
        currentProgress     = (try? c.decode(Int.self,    forKey: .currentProgress)) ?? 0
        target              = (try? c.decode(Int.self,    forKey: .target)) ?? 1
        type                = (try? c.decode(String.self, forKey: .type))  ?? "r"
    }

    // Memberwise init used by placeholder factory.
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

    var isAthkar: Bool    { type == "a" }
    var isCountBased: Bool { !isAthkar && target > 1 }

    var progressFraction: Double {
        guard target > 0 else { return 0 }
        return min(1.0, Double(currentProgress) / Double(target))
    }
}

// MARK: – Timeline entry

struct HabitEntry: TimelineEntry {
    let date:   Date
    let habits: [WHabit]
    let total:  Int
    let done:   Int
    let lang:   String       // "ar" | "en"
    var isArabic: Bool { lang == "ar" }
}

// MARK: – Widget language configuration (mirrors PrayerWidgetIntent.WidgetLanguage)

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
        // System = device language. App locale is NOT the source of truth here.
        // Arabic device → Arabic; everything else (English, French, etc.) → English.
        if let code = Locale.current.language.languageCode?.identifier {
            return code == "ar" ? "ar" : "en"
        }
        return "en"
    }
}

// MARK: – Athar colour palette

private extension Color {
    static let navyDeep   = Color(red: 0.07, green: 0.09, blue: 0.15)
    static let navyMid    = Color(red: 0.12, green: 0.16, blue: 0.24)
    static let gold       = Color(red: 0.83, green: 0.68, blue: 0.21)
    static let habitGreen = Color(red: 0.30, green: 0.78, blue: 0.45)
    static let habitTeal  = Color(red: 0.20, green: 0.65, blue: 0.75)
}

// MARK: – Shared pending-action writer (used by both intents)

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

// MARK: – CompleteHabitIntent  (boolean habits — also un-completes when already done)

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
        if !was { d?.set(currentDone + 1,          forKey: kHabitsDoneKey) }
        else    { d?.set(max(0, currentDone - 1),  forKey: kHabitsDoneKey) }
    }
}

// MARK: – IncrementHabitIntent  (count-based habits — +1 per tap)

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
            total: 5, done: 1, lang: "ar"
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
        let lang  = resolvedLang(intent: configuration.language, stored: d?.string(forKey: kAppLocaleKey))

        var habits: [WHabit] = []
        if let json    = d?.string(forKey: kHabitsKey),
           let data    = json.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([WHabit].self, from: data) {
            // Athkar habits (tp=="a") appear as read-only rows — no intents wired.
            // Extra guard: skip any stray items with empty uuid.
            habits = decoded.filter { !$0.uuid.isEmpty }
        }

        return HabitEntry(date: .now, habits: habits, total: total, done: done, lang: lang)
    }
}

// MARK: – Background modifier (iOS 17+ containerBackground)

private struct HabitWidgetBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .containerBackground(for: .widget) {
                LinearGradient(
                    colors: [.navyDeep, .navyMid],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
    }
}

// MARK: – Widget view

struct HabitWidgetView: View {
    let entry: HabitEntry
    @Environment(\.widgetFamily) var family

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

    // ── small (3 rows) ─────────────────────────────────────────────────────────

    private var smallBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            header(compact: true)
            separator
            habitRows(max: 3)
        }
        .padding(12)
    }

    // ── medium (4 rows) ────────────────────────────────────────────────────────

    private var mediumBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            header(compact: false)
            separator
            habitRows(max: 4)
        }
        .padding(14)
    }

    // ── large (6 rows) ─────────────────────────────────────────────────────────

    private var largeBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            header(compact: false)
            separator
            habitRows(max: 6)
        }
        .padding(14)
    }

    // ── header ─────────────────────────────────────────────────────────────────

    private func header(compact: Bool) -> some View {
        let sz: CGFloat = compact ? 11 : 13
        // Compact (small widget): use short labels so badge never clips title.
        // "3/25" badge + icon leaves ~71pt for title — short label is ~40pt, safe.
        let titleAr = compact ? "العادات"    : "عادات اليوم"
        let titleEn = compact ? "Habits"     : "Today's Habits"
        return HStack(alignment: .center) {
            Image(systemName: "leaf.fill")
                .font(.system(size: sz, weight: .semibold))
                .foregroundColor(.gold)
            Text(entry.isArabic ? titleAr : titleEn)
                .font(.system(size: sz, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer()
            Text("\(entry.done)/\(entry.total)")
                .font(.system(size: sz - 1, weight: .semibold, design: .rounded))
                .foregroundColor(.gold)
        }
    }

    private var separator: some View {
        Rectangle()
            .fill(Color.white.opacity(0.12))
            .frame(height: 1)
            .padding(.top, 6)
    }

    // ── habit rows ─────────────────────────────────────────────────────────────

    private func habitRows(max: Int) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            if entry.habits.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text(entry.isArabic ? "لا توجد عادات اليوم" : "No habits today")
                        .font(.system(size: 12))
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

    // ── single habit row dispatcher ────────────────────────────────────────────

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

    // ── athkar row (read-only — no interaction intent) ─────────────────────────

    private func athkarRow(_ habit: WHabit) -> some View {
        HStack(spacing: 8) {
            Image(systemName: habit.done ? "book.closed.fill" : "book.fill")
                .font(.system(size: 14, weight: .light))
                .foregroundColor(habit.done ? .white.opacity(0.30) : .gold.opacity(0.80))

            Text(habit.title)
                .font(.system(size: 12))
                .foregroundColor(habit.done ? .white.opacity(0.30) : .white)
                .strikethrough(habit.done, color: .white.opacity(0.30))
                .lineLimit(1)

            Spacer(minLength: 4)

            if habit.target > 1 {
                Text("\(habit.currentProgress)/\(habit.target)")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(habit.done ? .white.opacity(0.30) : .gold.opacity(0.70))
            } else if habit.done {
                Image(systemName: "checkmark")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(.white.opacity(0.40))
            }
        }
    }

    // ── boolean habit row (target <= 1) ────────────────────────────────────────

    private func booleanRow(_ habit: WHabit) -> some View {
        HStack(spacing: 8) {
            Button(intent: CompleteHabitIntent(habitUuid: habit.uuid)) {
                Image(systemName: habit.done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(habit.done ? .habitGreen : .white.opacity(0.45))
            }
            .buttonStyle(.plain)

            Text(habit.title)
                .font(.system(size: 12))
                .foregroundColor(habit.done ? .white.opacity(0.30) : .white)
                .strikethrough(habit.done, color: .white.opacity(0.30))
                .lineLimit(1)

            Spacer(minLength: 4)

            if habit.streak > 0 {
                streakBadge(habit.streak)
            }
        }
    }

    // ── count-based habit row (target > 1) ─────────────────────────────────────

    private func countBasedRow(_ habit: WHabit) -> some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack(spacing: 8) {
                // Completed: tapping resets (sends complete_habit → toggleHabitOnDate unmarks it)
                // Not done: tapping increments progress by 1
                if habit.done {
                    Button(intent: CompleteHabitIntent(habitUuid: habit.uuid)) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(.habitGreen)
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
                    .font(.system(size: 12))
                    .foregroundColor(habit.done ? .white.opacity(0.30) : .white)
                    .strikethrough(habit.done, color: .white.opacity(0.30))
                    .lineLimit(1)

                Spacer(minLength: 4)

                Text("\(habit.currentProgress)/\(habit.target)")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(habit.done ? .habitGreen : .habitTeal)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.white.opacity(0.10))
                        .frame(height: 3)
                    Capsule()
                        .fill(habit.done ? Color.habitGreen : Color.habitTeal)
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
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(.orange)
        }
    }
}

// MARK: – Widget declaration

// @main is on AtharHabitWidgetBundle below — not here.
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
