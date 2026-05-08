//
//  AtharTaskWidget.swift
//  AtharTaskWidget
//

import AppIntents
import SwiftUI
import WidgetKit

// MARK: – Shared App Group constants

private let kGroupId           = "group.com.iappsnet.athar"
private let kTasksKey          = "athar_tasks"
private let kTasksTotalKey     = "athar_tasks_total"
private let kTasksDoneKey      = "athar_tasks_done"
private let kAppLocaleKey      = "athar_app_locale"
private let kPendingActionsKey = "athar_pending_task_actions"

// MARK: – Data model

struct WTask: Identifiable, Decodable {
    var id: String { uuid }
    let title: String
    let done: Bool
    let priority: Int
    let uuid: String

    enum CodingKeys: String, CodingKey {
        case title    = "t"
        case done     = "d"
        case priority = "p"
        case uuid     = "u"
    }
}

// MARK: – Timeline entry

struct TaskEntry: TimelineEntry {
    let date: Date
    let tasks: [WTask]
    let total: Int
    let done: Int
    let lang: String       // "ar" | "en"
    var isArabic: Bool { lang == "ar" }
}

// MARK: – Widget language configuration (mirrors PrayerWidgetIntent.WidgetLanguage)

enum WidgetLanguage: String, AppEnum {
    case system   // follow app locale / device locale
    case arabic   // force Arabic regardless of device locale
    case english  // force English regardless of device locale

    static var typeDisplayRepresentation =
        TypeDisplayRepresentation(name: "Language")

    static var caseDisplayRepresentations: [WidgetLanguage: DisplayRepresentation] = [
        .system:  DisplayRepresentation(title: "System"),
        .arabic:  DisplayRepresentation(title: "العربية"),
        .english: DisplayRepresentation(title: "English"),
    ]
}

// MARK: – Locale resolver

/// Resolves the final display language from the intent parameter + stored app locale.
/// Priority: explicit arabic/english intent > stored "ar"/"en" > device locale > Arabic default
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
    static let navyDeep       = Color(red: 0.07, green: 0.09, blue: 0.15)
    static let navyMid        = Color(red: 0.12, green: 0.16, blue: 0.24)
    static let gold           = Color(red: 0.83, green: 0.68, blue: 0.21)
    static let priorityHigh   = Color(red: 0.90, green: 0.35, blue: 0.25)
    static let priorityMedium = Color(red: 0.93, green: 0.72, blue: 0.18)
    static let priorityLow    = Color(red: 0.35, green: 0.72, blue: 0.82)
}

private func priorityColor(_ p: Int) -> Color {
    switch p {
    case 0:  return .priorityHigh
    case 1:  return .priorityMedium
    default: return .priorityLow
    }
}

// MARK: – Widget configuration intent

struct TaskWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Today's Tasks · مهام اليوم"
    static var description = IntentDescription(
        "Show today's tasks with interactive completion."
    )

    @Parameter(title: "Language", default: .system)
    var language: WidgetLanguage
}

// MARK: – ToggleTaskIntent (interactive: tapping a task row completes / un-completes it)

struct ToggleTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "إتمام المهمة"
    static var isDiscoverable: Bool = false

    @Parameter(title: "Task UUID") var taskUuid: String
    @Parameter(title: "Mark Done") var isDone: Bool

    // Required explicit init for AppIntent parameters
    init() { taskUuid = ""; isDone = false }
    init(taskUuid: String, isDone: Bool) {
        self.taskUuid = taskUuid
        self.isDone   = isDone
    }

    func perform() async throws -> some IntentResult {
        let d = UserDefaults(suiteName: kGroupId)

        // 1. Write pending action → Flutter will consume this on next resume
        writePendingAction(d: d)

        // 2. Optimistic update in shared storage so widget re-renders immediately
        optimisticallyToggle(d: d)

        // 3. Reload widget timeline
        WidgetCenter.shared.reloadTimelines(ofKind: "AtharTaskWidget")
        return .result()
    }

    // Appends one action to the existing pending-actions JSON array.
    private func writePendingAction(d: UserDefaults?) {
        var pending: [[String: Any]] = []
        if let s    = d?.string(forKey: kPendingActionsKey),
           let data = s.data(using: .utf8),
           let arr  = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            pending = arr
        }
        pending.append([
            "type":      "toggle_task",
            "uuid":      taskUuid,
            "done":      isDone,
            "createdAt": Date().timeIntervalSince1970,
        ])
        if let encoded = try? JSONSerialization.data(withJSONObject: pending),
           let str     = String(data: encoded, encoding: .utf8) {
            d?.set(str, forKey: kPendingActionsKey)
        }
    }

    // Mutates the tasks JSON in-place so the widget reflects the new state
    // before Flutter wakes up to write canonical data.
    private func optimisticallyToggle(d: UserDefaults?) {
        guard let json = d?.string(forKey: kTasksKey),
              let data = json.data(using: .utf8),
              var arr  = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]
        else { return }

        var wasDone: Bool? = nil
        for i in arr.indices where (arr[i]["u"] as? String) == taskUuid {
            wasDone  = arr[i]["d"] as? Bool
            arr[i]["d"] = isDone
            break
        }

        if let encoded = try? JSONSerialization.data(withJSONObject: arr),
           let str     = String(data: encoded, encoding: .utf8) {
            d?.set(str, forKey: kTasksKey)
        }

        // Keep the done counter in sync with the optimistic change
        let currentDone = d?.integer(forKey: kTasksDoneKey) ?? 0
        let was = wasDone ?? false
        if isDone && !was {
            d?.set(currentDone + 1, forKey: kTasksDoneKey)
        } else if !isDone && was {
            d?.set(max(0, currentDone - 1), forKey: kTasksDoneKey)
        }
    }
}

// MARK: – Timeline provider

struct TaskProvider: AppIntentTimelineProvider {

    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(
            date:  .now,
            tasks: [
                WTask(uuid: "ph-1"),
                WTask(uuid: "ph-2"),
            ],
            total: 3, done: 1, lang: "ar"
        )
    }

    func snapshot(for configuration: TaskWidgetIntent, in context: Context) async -> TaskEntry {
        readEntry(configuration: configuration)
    }

    func timeline(for configuration: TaskWidgetIntent, in context: Context) async -> Timeline<TaskEntry> {
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        return Timeline(entries: [readEntry(configuration: configuration)], policy: .after(next))
    }

    private func readEntry(configuration: TaskWidgetIntent) -> TaskEntry {
        let d     = UserDefaults(suiteName: kGroupId)
        let total = d?.integer(forKey: kTasksTotalKey) ?? 0
        let done  = d?.integer(forKey: kTasksDoneKey)  ?? 0
        let lang  = resolvedLang(intent: configuration.language, stored: d?.string(forKey: kAppLocaleKey))

        var tasks: [WTask] = []
        if let json    = d?.string(forKey: kTasksKey),
           let data    = json.data(using: .utf8),
           let decoded = try? JSONDecoder().decode([WTask].self, from: data) {
            tasks = decoded
        }

        return TaskEntry(date: .now, tasks: tasks, total: total, done: done, lang: lang)
    }
}

// Placeholder WTask factory (title-less, used in placeholder only)
private extension WTask {
    init(uuid: String) {
        self.uuid     = uuid
        self.title    = uuid == "ph-1" ? "قراءة القرآن الكريم" : "مراجعة مهام اليوم"
        self.done     = uuid == "ph-2"
        self.priority = 1
    }
}

// MARK: – Background modifier (iOS 17+ containerBackground)

private struct TaskWidgetBackground: ViewModifier {
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

struct TaskWidgetView: View {
    let entry: TaskEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:  smallBody
            case .systemLarge:  largeBody
            default:            mediumBody
            }
        }
        .modifier(TaskWidgetBackground())
        .environment(\.layoutDirection, entry.isArabic ? .rightToLeft : .leftToRight)
    }

    // ── small ──────────────────────────────────────────────────────────────────

    private var smallBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            header(compact: true)
            separator
            taskRows(max: 3)
        }
        .padding(12)
    }

    // ── medium ─────────────────────────────────────────────────────────────────

    private var mediumBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            header(compact: false)
            separator
            taskRows(max: 4)
        }
        .padding(14)
    }

    // ── large ──────────────────────────────────────────────────────────────────

    private var largeBody: some View {
        VStack(alignment: .leading, spacing: 0) {
            header(compact: false)
            separator
            taskRows(max: 7)
        }
        .padding(14)
    }

    // ── header ─────────────────────────────────────────────────────────────────

    private func header(compact: Bool) -> some View {
        let sz: CGFloat = compact ? 11 : 13
        // Compact (small widget): use short labels so badge never clips title.
        // "3/25" badge + icon leaves ~71pt for title — short label is ~36pt, safe.
        let titleAr = compact ? "المهام"     : "مهام اليوم"
        let titleEn = compact ? "Tasks"      : "Today's Tasks"
        return HStack(alignment: .center) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: sz, weight: .semibold))
                .foregroundColor(.gold)
            Text(entry.isArabic ? titleAr : titleEn)
                .font(.system(size: sz, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
            Spacer()
            // done / total badge
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

    // ── task rows ──────────────────────────────────────────────────────────────

    private func taskRows(max: Int) -> some View {
        VStack(alignment: .leading, spacing: 7) {
            if entry.tasks.isEmpty {
                Spacer()
                HStack {
                    Spacer()
                    Text(entry.isArabic ? "لا توجد مهام اليوم" : "No tasks today")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.35))
                    Spacer()
                }
                Spacer()
            } else {
                ForEach(Array(entry.tasks.prefix(max))) { task in
                    taskRow(task)
                }
                Spacer()
            }
        }
        .padding(.top, 8)
    }

    // ── single task row ────────────────────────────────────────────────────────

    private func taskRow(_ task: WTask) -> some View {
        HStack(spacing: 8) {
            // Interactive checkbox — tapping toggles completion state
            Button(intent: ToggleTaskIntent(taskUuid: task.uuid, isDone: !task.done)) {
                Image(systemName: task.done ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 15, weight: .light))
                    .foregroundColor(task.done ? Color(red: 0.35, green: 0.82, blue: 0.50) : .white.opacity(0.45))
            }
            .buttonStyle(.plain)

            // Title
            Text(task.title)
                .font(.system(size: 12))
                .foregroundColor(task.done ? .white.opacity(0.30) : .white)
                .strikethrough(task.done, color: .white.opacity(0.30))
                .lineLimit(1)

            Spacer(minLength: 4)

            // Priority dot
            Circle()
                .fill(priorityColor(task.priority))
                .frame(width: 5, height: 5)
                .opacity(task.done ? 0.25 : 0.75)
        }
    }
}

// MARK: – Widget declaration

// Removed @main from AtharTaskWidget — @main is on AtharTaskWidgetBundle below.

struct AtharTaskWidget: Widget {
    let kind = "AtharTaskWidget"
    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind:     kind,
            intent:   TaskWidgetIntent.self,
            provider: TaskProvider()
        ) { entry in
            TaskWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's Tasks · مهام اليوم")
        .description("Show today's tasks with interactive completion.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct AtharTaskWidgetBundle: WidgetBundle {
    var body: some Widget {
        AtharTaskWidget()
    }
}
