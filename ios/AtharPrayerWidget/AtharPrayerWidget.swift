//
//  AtharPrayerWidget.swift
//  AtharPrayerWidget
//
//  Created by iTech on 27/04/2026.
//

import WidgetKit
import SwiftUI

private let groupId = "group.com.iappsnet.athar"

struct PrayerEntry: TimelineEntry {
    let date: Date
    let nameAr: String
    let prayerTime: Date?
    let city: String
}

struct PrayerProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrayerEntry {
        PrayerEntry(date: .now, nameAr: "الفجر", prayerTime: nil, city: "الرياض")
    }
    func getSnapshot(in context: Context, completion: @escaping (PrayerEntry) -> Void) {
        completion(entry())
    }
    func getTimeline(in context: Context, completion: @escaping (Timeline<PrayerEntry>) -> Void) {
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        completion(Timeline(entries: [entry()], policy: .after(next)))
    }
    private func entry() -> PrayerEntry {
        let d = UserDefaults(suiteName: groupId)
        let nameAr = d?.string(forKey: "athar_next_prayer_name_ar") ?? "الفجر"
        let city   = d?.string(forKey: "athar_city_name") ?? "الرياض"
        var time: Date? = nil
        if let iso = d?.string(forKey: "athar_next_prayer_time") {
            time = ISO8601DateFormatter().date(from: iso)
        }
        return PrayerEntry(date: .now, nameAr: nameAr, prayerTime: time, city: city)
    }
}

struct PrayerWidgetView: View {
    var entry: PrayerEntry
    @Environment(\.widgetFamily) var family

    var timeText: String {
        guard let t = entry.prayerTime else { return "--:--" }
        let f = DateFormatter(); f.timeStyle = .short; f.locale = Locale(identifier: "ar_SA")
        return f.string(from: t)
    }

    var body: some View {
        ZStack {
            Color(red: 0.1, green: 0.1, blue: 0.18)
            VStack(spacing: 4) {
                Text(entry.nameAr)
                    .font(.system(size: family == .systemSmall ? 15 : 18, weight: .bold))
                    .foregroundColor(.white)
                Text(timeText)
                    .font(.system(size: family == .systemSmall ? 22 : 28, weight: .heavy))
                    .foregroundColor(Color(red: 0.83, green: 0.68, blue: 0.21))
                if family != .systemSmall {
                    Text(entry.city)
                        .font(.system(size: 11))
                        .foregroundColor(.white.opacity(0.6))
                }
            }
        }
        .modifier(ContainerBackgroundCompat())
    }
}

private struct ContainerBackgroundCompat: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.containerBackground(for: .widget) { Color(red: 0.1, green: 0.1, blue: 0.18) }
        } else {
            content.background(Color(red: 0.1, green: 0.1, blue: 0.18))
        }
    }
}

@main
struct AtharPrayerWidget: Widget {
    let kind = "AtharPrayerWidget"
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrayerProvider()) { entry in
            PrayerWidgetView(entry: entry)
        }
        .configurationDisplayName("الصلاة القادمة")
        .description("يعرض وقت الصلاة القادمة.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryCircular, .accessoryRectangular])
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
//struct AtharPrayerWidgetEntryView : View {
//    var entry: Provider.Entry
//
//    var body: some View {
//        VStack {
//            Text("Time:")
//
//            Text(entry.date, style: .time)
//
//            Text("Emoji:")
//            Text(entry.emoji)
//        }
//    }
//}
//
//struct AtharPrayerWidget: Widget {
//    let kind: String = "AtharPrayerWidget"
//
//    var body: some WidgetConfiguration {
//        StaticConfiguration(kind: kind, provider: Provider()) { entry in
//            if #available(iOS 17.0, *) {
//                AtharPrayerWidgetEntryView(entry: entry)
//                    .containerBackground(.fill.tertiary, for: .widget)
//            } else {
//                AtharPrayerWidgetEntryView(entry: entry)
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
//    AtharPrayerWidget()
//} timeline: {
//    SimpleEntry(date: .now, emoji: "😀")
//    SimpleEntry(date: .now, emoji: "🤩")
//}

