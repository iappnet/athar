//
//  AtharHabitWidget.swift
//  AtharHabitWidget
//
//  Created by iTech on 27/04/2026.
//

import WidgetKit
import SwiftUI

private let groupId = "group.com.iappsnet.athar"

struct WHabit: Identifiable {
    let id = UUID(); let title: String; let done: Bool; let streak: Int
}

struct HabitEntry: TimelineEntry {
    let date: Date; let habits: [WHabit]; let total: Int; let done: Int
}

struct HabitProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitEntry {
        HabitEntry(date: .now, habits: [WHabit(title: "قراءة القرآن", done: false, streak: 7)], total: 4, done: 2)
    }
    func getSnapshot(in context: Context, completion: @escaping (HabitEntry) -> Void) { completion(entry()) }
    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitEntry>) -> Void) {
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry()], policy: .after(next)))
    }
    private func entry() -> HabitEntry {
        let d = UserDefaults(suiteName: groupId)
        let total = d?.integer(forKey: "athar_habits_total") ?? 0
        let done  = d?.integer(forKey: "athar_habits_done")  ?? 0
        var habits: [WHabit] = []
        if let json = d?.string(forKey: "athar_habits"),
           let data = json.data(using: .utf8),
           let arr  = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
            habits = arr.map {
                WHabit(
                    title:  $0["t"] as? String ?? "",
                    done:   $0["d"] as? Bool   ?? false,
                    streak: $0["s"] as? Int    ?? 0
                )
            }
        }
        return HabitEntry(date: .now, habits: habits, total: total, done: done)
    }
}

struct HabitWidgetView: View {
    var entry: HabitEntry
    @Environment(\.widgetFamily) var family
    
    var selfBody: some View {
        ZStack(alignment: .topLeading) {
            Color(red: 0.1, green: 0.1, blue: 0.18)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text("العادات").font(.system(size: 12, weight: .bold)).foregroundColor(.white)
                    Spacer()
                    Text("\(entry.done)/\(entry.total)").font(.system(size: 11))
                        .foregroundColor(Color(red: 0.83, green: 0.68, blue: 0.21))
                }
                Divider().background(Color.white.opacity(0.2))
                if entry.habits.isEmpty {
                    Spacer()
                    Text("لا توجد عادات").font(.caption).foregroundColor(.white.opacity(0.5))
                } else {
                    let max = family == .systemSmall ? 3 : (family == .systemMedium ? 4 : 6)
                    ForEach(Array(entry.habits.prefix(max))) { h in
                        HStack(spacing: 6) {
                            Image(systemName: h.done ? "checkmark.circle.fill" : "circle")
                                .font(.system(size: 11))
                                .foregroundColor(h.done ? .green : .white.opacity(0.5))
                            Text(h.title).font(.system(size: 11))
                                .foregroundColor(h.done ? .white.opacity(0.4) : .white).lineLimit(1)
                            Spacer()
                            if h.streak > 0 {
                                Text("🔥\(h.streak)").font(.system(size: 10))
                                    .foregroundColor(Color.orange)
                            }
                        }
                    }
                }
                Spacer()
            }.padding(10)
        }
    }
    
    var body: some View {
#if compiler(>=5.9)
        if #available(iOS 17.0, *) {
            AnyView(selfBody.containerBackground(for: .widget) { Color(red: 0.1, green: 0.1, blue: 0.18) })
        } else {
            AnyView(selfBody.background(Color(red: 0.1, green: 0.1, blue: 0.18)))
        }
#else
        selfBody.background(Color(red: 0.1, green: 0.1, blue: 0.18))
#endif
    }
}

@main
struct AtharHabitWidget: Widget {
    let kind = "AtharHabitWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitProvider()) { entry in
            HabitWidgetView(entry: entry)
        }
        .configurationDisplayName("عادات اليوم")
        .description("يعرض عادات اليوم مع السلاسل.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
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
//struct AtharHabitWidgetEntryView : View {
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
//struct AtharHabitWidget: Widget {
//    let kind: String = "AtharHabitWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            if #available(iOS 17.0, *) {
//                AtharHabitWidgetEntryView(entry: entry)
//                    .containerBackground(.fill.tertiary, for: .widget)
//            } else {
//                AtharHabitWidgetEntryView(entry: entry)
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
//    AtharHabitWidget()
//} timeline: {
//    SimpleEntry(date: .now, emoji: "😀")
//    SimpleEntry(date: .now, emoji: "🤩")
//}
