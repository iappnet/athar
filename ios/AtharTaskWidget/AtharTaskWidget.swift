//
//  AtharTaskWidget.swift
//  AtharTaskWidget
//
//  Created by iTech on 27/04/2026.
//


import WidgetKit
import SwiftUI

private let groupId = "group.com.iappsnet.athar"

struct WTask: Identifiable {
    let id = UUID(); let title: String; let done: Bool
}

struct TaskEntry: TimelineEntry {
    let date: Date; let tasks: [WTask]; let total: Int; let done: Int
}

struct TaskProvider: TimelineProvider {
    func placeholder(in context: Context) -> TaskEntry {
        TaskEntry(date: .now, tasks: [WTask(title: "مهمة اليوم", done: false)], total: 3, done: 1)
    }
    func getSnapshot(in context: Context, completion: @escaping (TaskEntry) -> Void) { completion(entry()) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<TaskEntry>) -> Void) {
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry()], policy: .after(next)))
    }
    private func entry() -> TaskEntry {
        let d = UserDefaults(suiteName: groupId)
        let total = d?.integer(forKey: "athar_tasks_total") ?? 0
        let done  = d?.integer(forKey: "athar_tasks_done")  ?? 0
        var tasks: [WTask] = []
        if let json = d?.string(forKey: "athar_tasks"),
           let data = json.data(using: .utf8),
           let arr  = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            tasks = arr.map { WTask(title: $0["t"] as? String ?? "", done: $0["d"] as? Bool ?? false) }
        }
        return TaskEntry(date: .now, tasks: tasks, total: total, done: done)
    }
}

struct TaskWidgetView: View {
    var entry: TaskEntry
    @Environment(\.widgetFamily) var family
    var body: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 0.1, green: 0.1, blue: 0.18)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("مهام اليوم").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                    Spacer()
                    Text("\(entry.done)/\(entry.total)").font(.system(size: 11))
                        .foregroundColor(Color(red: 0.83, green: 0.68, blue: 0.21))
                }
                Divider().background(Color.white.opacity(0.2))
                if entry.tasks.isEmpty {
                    Spacer()
                    Text("لا توجد مهام").font(.caption).foregroundColor(.white.opacity(0.5))
                } else {
                    let max = family == .systemSmall ? 3 : (family == .systemMedium ? 4 : 6)
                    ForEach(Array(entry.tasks.prefix(max))) { t in
                        HStack(spacing: 6) {
                            Image(systemName: t.done ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 11))
                                .foregroundColor(t.done ? .green : .white.opacity(0.5))
                            Text(t.title).font(.system(size: 11))
                                .foregroundColor(t.done ? .white.opacity(0.4) : .white).lineLimit(1)
                        }
                    }
                }
                Spacer()
            }.padding(10)
        }
        .background(
            Group {
                if #available(iOS 17.0, *) {
                    Color.clear.containerBackground(for: .widget) { Color(red: 0.1, green: 0.1, blue: 0.18) }
                } else {
                    Color(red: 0.1, green: 0.1, blue: 0.18)
                }
            }
        )
    }
}

// Removed @main attribute from this struct to avoid duplicate main entry point

struct AtharTaskWidget: Widget {
    let kind = "AtharTaskWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TaskProvider()) { entry in
            TaskWidgetView(entry: entry)
        }
        .configurationDisplayName("مهام اليوم")
        .description("يعرض المهام اليومية مع التقدم.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

@main
struct AtharTaskWidgetBundle: WidgetBundle {
    var body: some Widget {
        AtharTaskWidget()
    }
}

//import WidgetKit
//import SwiftUI
//
//struct Provider: TimelineProvider {
//    func placeholder(in context: Context) -> SimpleEntry {
//        SimpleEntry(date: Date(), emoji: "😀")
//    }
//
//    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
//        let entry = SimpleEntry(date: Date(), emoji: "😀")
//        completion(entry)
//    }
//
//    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
//        var entries: [SimpleEntry] = []
//
//        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
//        let currentDate = Date()
//        for hourOffset in 0 ..< 5 {
//            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
//            let entry = SimpleEntry(date: entryDate, emoji: "😀")
//            entries.append(entry)
//        }
//
//        let timeline = Timeline(entries: entries, policy: .atEnd)
//        completion(timeline)
//    }
//
////    func relevances() async -> WidgetRelevances<Void> {
////        // Generate a list containing the contexts this widget is relevant in.
////    }
//}
//
//struct SimpleEntry: TimelineEntry {
//    let date: Date
//    let emoji: String
//}
//
//struct AtharTaskWidgetEntryView : View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        VStack {
//            Text("Time:")
//            Text(entry.date, style: .time)
//
//            Text("Emoji:")
//            Text(entry.emoji)
//        }
//    }
//}
//
//struct AtharTaskWidget: Widget {
//    let kind: String = "AtharTaskWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            if #available(iOS 17.0, *) {
//                AtharTaskWidgetEntryView(entry: entry)
//                    .containerBackground(.fill.tertiary, for: .widget)
//            } else {
//                AtharTaskWidgetEntryView(entry: entry)
//                    .padding()
//                    .background()
//            }
//        }
//        .configurationDisplayName("My Widget")
//        .description("This is an example widget.")
//    }
//}
//
//#Preview(as: .systemSmall) {
//    AtharTaskWidget()
//} timeline: {
//    SimpleEntry(date: .now, emoji: "😀")
//    SimpleEntry(date: .now, emoji: "🤩")
//}

