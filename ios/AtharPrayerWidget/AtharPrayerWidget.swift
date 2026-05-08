//
//  AtharPrayerWidget.swift
//  AtharPrayerWidget
//
//  Created by iTech on 27/04/2026.
//  Updated: AppIntentConfiguration — language & display mode configuration
//

import AppIntents
import WidgetKit
import SwiftUI

// MARK: – Shared App Group & Key constants
// Keep in sync with WidgetKeys in lib/core/services/widget_data_service.dart

private let kGroupId       = "group.com.iappsnet.athar"
private let kNameAr        = "athar_next_prayer_name_ar"
private let kNameEn        = "athar_next_prayer_name_en"
private let kPrayerType    = "athar_next_prayer_type"      // "fajr" | "sunrise" | "dhuhr" | "asr" | "maghrib" | "isha"
private let kPrayerTime    = "athar_next_prayer_time"      // ISO-8601 (Dart local time, no timezone)
private let kTimestamp     = "athar_next_prayer_timestamp" // Unix epoch milliseconds (double) — more reliable
private let kCity          = "athar_city_name"
private let kAppLocale     = "athar_app_locale"            // "ar" | "en" | "system"
private let kLastUpdated   = "athar_last_updated_at"       // ISO-8601
private let kDateAr        = "athar_current_date_ar"       // full Arabic date (Hijri + Gregorian)
private let kDateEn        = "athar_current_date_en"       // full English date
private let kPrevTimestamp = "athar_prev_prayer_timestamp" // Unix epoch ms of previous prayer
private let kIsDuhaTime    = "athar_is_duha_time"          // 1 when Duha window active, else 0
private let kIsQiyamTime   = "athar_is_qiyam_time"         // 1 when Qiyam al-Layl window active, else 0
private let kPrevNameAr    = "athar_prev_prayer_name_ar"   // Arabic name of prayer that just started
private let kPrevNameEn    = "athar_prev_prayer_name_en"   // English name of prayer that just started

// MARK: – Widget configuration intent

enum WidgetLanguage: String, AppEnum {
    case system   // follow device locale (existing behavior)
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

enum WidgetDisplayMode: String, AppEnum {
    case detailed  // full layout: name, time, countdown, city, date, progress bar
    case compact   // minimal: name, time, countdown only

    static var typeDisplayRepresentation =
        TypeDisplayRepresentation(name: "Display")

    static var caseDisplayRepresentations: [WidgetDisplayMode: DisplayRepresentation] = [
        .detailed: DisplayRepresentation(title: "Detailed"),
        .compact:  DisplayRepresentation(title: "Compact"),
    ]
}

struct PrayerWidgetIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Prayer Widget"
    static var description = IntentDescription(
        "Customize language and display style."
    )

    @Parameter(title: "Language", default: .system)
    var language: WidgetLanguage

    @Parameter(title: "Display", default: .detailed)
    var displayMode: WidgetDisplayMode
}

// MARK: – Entry

struct PrayerEntry: TimelineEntry {
    let date: Date
    let nameAr: String
    let nameEn: String
    let prayerType: String    // raw type string for icon lookup
    let prayerTime: Date?
    let prevPrayerTime: Date? // start of the current interval — for progress bar
    let prevNameAr: String    // Arabic name of the prayer that most recently started
    let prevNameEn: String    // English name of the prayer that most recently started
    let city: String
    let appLocale: String     // Flutter-written locale ("ar" | "en" | "system")
    let dateAr: String
    let dateEn: String
    let isStale: Bool         // true when Flutter hasn't pushed for > 2 h
    let intentLanguage: WidgetLanguage
    let intentDisplayMode: WidgetDisplayMode
    let isDuhaTime: Bool      // Duha nafl window is active
    let isQiyamTime: Bool     // Qiyam al-Layl window is active

    // ── Computed ──────────────────────────────────────────────────────────────

    /// 0.0–1.0 fraction of the current prayer interval that has elapsed.
    var intervalProgress: Double {
        guard let prev = prevPrayerTime, let next = prayerTime else { return 0 }
        let total = next.timeIntervalSince(prev)
        guard total > 0 else { return 0 }
        return min(max(Date().timeIntervalSince(prev) / total, 0), 1)
    }

    /// Resolved language:
    ///   1. intent arabic/english wins outright
    ///   2. system intent → use device language code
    ///   3. system intent + no device code → Flutter appLocale (ignore "system" sentinel → default "ar")
    var resolvedLocale: String {
        switch intentLanguage {
        case .arabic:  return "ar"
        case .english: return "en"
        case .system:
            if let code = Locale.current.language.languageCode?.identifier {
                return code
            }
            // appLocale may be "system" when user hasn't chosen a language in-app
            return (appLocale == "system" || appLocale.isEmpty) ? "ar" : appLocale
        }
    }

    var isArabic: Bool   { resolvedLocale == "ar" }
    var isDetailed: Bool { intentDisplayMode == .detailed }

    /// True when we are within 30 minutes after the previous prayer began.
    var isCurrentPrayerWindow: Bool {
        guard let prev = prevPrayerTime, !prevNameAr.isEmpty else { return false }
        return Date().timeIntervalSince(prev) < 1800
    }

    var localizedName: String     { isArabic ? nameAr : nameEn }
    var localizedPrevName: String { isArabic ? prevNameAr : prevNameEn }
    var headerLabel: String {
        if isCurrentPrayerWindow {
            return isArabic ? "صلاة جارية" : "Prayer Time"
        }
        return isArabic ? "الصلاة القادمة" : "Next Prayer"
    }
    var localizedDate: String  { isArabic ? dateAr : dateEn }

    static let placeholder = PrayerEntry(
        date: .now,
        nameAr: "الفجر", nameEn: "Fajr",
        prayerType: "fajr",
        prayerTime: Calendar.current.date(byAdding: .hour, value: 1, to: .now),
        prevPrayerTime: Calendar.current.date(byAdding: .hour, value: -1, to: .now),
        prevNameAr: "", prevNameEn: "",
        city: "الرياض", appLocale: "ar",
        dateAr: "الجمعة، ٠٢ ذو الحجة ١٤٤٦",
        dateEn: "Fri, 2 May · 02 Dhul Hijja 1446",
        isStale: false,
        intentLanguage: .system,
        intentDisplayMode: .detailed,
        isDuhaTime: false,
        isQiyamTime: false
    )
}

// MARK: – Provider

struct PrayerIntentProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> PrayerEntry { .placeholder }

    func snapshot(for configuration: PrayerWidgetIntent, in context: Context) async -> PrayerEntry {
        context.isPreview ? .placeholder : readEntry(configuration: configuration)
    }

    func timeline(for configuration: PrayerWidgetIntent, in context: Context) async -> Timeline<PrayerEntry> {
        let entry = readEntry(configuration: configuration)
        // Refresh at prayer time +1 min so new prayer name appears promptly.
        // Fall back to 30-min poll if prayer time is missing or already past.
        let refresh: Date
        if let t = entry.prayerTime, t > .now {
            refresh = Calendar.current.date(byAdding: .minute, value: 1, to: t)!
        } else {
            refresh = Calendar.current.date(byAdding: .minute, value: 30, to: .now)!
        }
        return Timeline(entries: [entry], policy: .after(refresh))
    }

    private func readEntry(configuration: PrayerWidgetIntent) -> PrayerEntry {
        let d = UserDefaults(suiteName: kGroupId)
        let nameAr    = d?.string(forKey: kNameAr)    ?? ""
        let nameEn    = d?.string(forKey: kNameEn)    ?? ""
        let type      = d?.string(forKey: kPrayerType) ?? "fajr"
        let city      = d?.string(forKey: kCity)       ?? ""
        let appLocale = d?.string(forKey: kAppLocale)  ?? "system"
        let dateAr    = d?.string(forKey: kDateAr)     ?? ""
        let dateEn    = d?.string(forKey: kDateEn)     ?? ""

        // Parse prayer time — prefer the ms-epoch double (written by Flutter as
        // time.millisecondsSinceEpoch.toDouble()), which needs no timezone parsing.
        // Fall back to ISO-8601 with a permissive formatter for Dart's local-time
        // format "yyyy-MM-dd'T'HH:mm:ss.SSSSSS" (no timezone designator).
        var prayerTime: Date?
        let tsMs = d?.double(forKey: kTimestamp) ?? 0
        if tsMs > 0 {
            prayerTime = Date(timeIntervalSince1970: tsMs / 1000.0)
        } else if let iso = d?.string(forKey: kPrayerTime) {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            prayerTime = df.date(from: iso)
            if prayerTime == nil {
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                prayerTime = df.date(from: iso)
            }
            if prayerTime == nil {
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                prayerTime = df.date(from: iso)
            }
        }

        // Previous prayer timestamp — present from v4 payload onward.
        var prevPrayerTime: Date?
        let prevTsMs = d?.double(forKey: kPrevTimestamp) ?? 0
        if prevTsMs > 0 {
            prevPrayerTime = Date(timeIntervalSince1970: prevTsMs / 1000.0)
        }

        // Nafl windows — stored as int 0/1 (v5 payload onward).
        let isDuhaTime  = (d?.integer(forKey: kIsDuhaTime) ?? 0) == 1
        let isQiyamTime = (d?.integer(forKey: kIsQiyamTime) ?? 0) == 1

        // Previous prayer name — v6 payload onward (current-prayer state).
        let prevNameAr = d?.string(forKey: kPrevNameAr) ?? ""
        let prevNameEn = d?.string(forKey: kPrevNameEn) ?? ""

        // Data is stale if Flutter hasn't written in > 2 hours.
        var isStale = nameAr.isEmpty
        if let lastStr = d?.string(forKey: kLastUpdated) {
            let df = DateFormatter()
            df.locale = Locale(identifier: "en_US_POSIX")
            df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
            var lastDate = df.date(from: lastStr)
            if lastDate == nil {
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                lastDate = df.date(from: lastStr)
            }
            if let lastDate {
                isStale = Date().timeIntervalSince(lastDate) > 7200
            }
        }

        return PrayerEntry(
            date: .now,
            nameAr: nameAr.isEmpty ? "الفجر" : nameAr,
            nameEn: nameEn.isEmpty ? "Fajr"  : nameEn,
            prayerType: type,
            prayerTime: prayerTime,
            prevPrayerTime: prevPrayerTime,
            prevNameAr: prevNameAr,
            prevNameEn: prevNameEn,
            city: city,
            appLocale: appLocale,
            dateAr: dateAr,
            dateEn: dateEn,
            isStale: isStale,
            intentLanguage: configuration.language,
            intentDisplayMode: configuration.displayMode,
            isDuhaTime: isDuhaTime,
            isQiyamTime: isQiyamTime
        )
    }
}

// MARK: – Design tokens (mirrors Athar Flutter palette)

private extension Color {
    static let navyDeep = Color(red: 0.07, green: 0.09, blue: 0.15)  // #111827
    static let navyMid  = Color(red: 0.12, green: 0.16, blue: 0.24)  // #1E293B
    static let gold     = Color(red: 0.83, green: 0.68, blue: 0.21)  // #D4AE35
    static let dimWhite = Color.white.opacity(0.55)
    static let qiyamBlue = Color(red: 0.45, green: 0.65, blue: 0.95) // soft blue for qiyam badge
}

// MARK: – SF Symbol per prayer type

private func prayerIcon(_ type: String) -> String {
    switch type {
    case "fajr":    return "moon.stars.fill"
    case "sunrise": return "sunrise.fill"
    case "dhuhr":   return "sun.max.fill"
    case "asr":     return "sun.min.fill"
    case "maghrib": return "sunset.fill"
    case "isha":    return "moon.fill"
    default:        return "clock.fill"
    }
}

// MARK: – Formatted time string (locale-aware)

/// Returns a short time string formatted for the resolved widget language.
private func formattedTime(_ date: Date?, lang: String) -> String {
    guard let date else { return "--:--" }
    let f = DateFormatter()
    f.timeStyle = .short
    f.locale = Locale(identifier: lang == "ar" ? "ar_SA" : "en_US")
    return f.string(from: date)
}

// MARK: – Nafl badge (Duha / Qiyam)

private struct NaflBadge: View {
    let isDuha: Bool
    let isQiyam: Bool
    let isArabic: Bool

    var body: some View {
        if isDuha || isQiyam {
            let label: String = {
                if isDuha  { return isArabic ? "وقت الضحى"   : "Duha" }
                             return isArabic ? "قيام الليل"  : "Qiyam"
            }()
            let color: Color = isDuha ? .gold : .qiyamBlue

            Text(label)
                .font(.system(size: 8, weight: .semibold))
                .foregroundColor(color)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Capsule().fill(color.opacity(0.18)))
        }
    }
}

// MARK: – Widget views

struct PrayerWidgetView: View {
    let entry: PrayerEntry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemSmall:          smallBody
            case .systemMedium:         mediumBody
            case .accessoryCircular:    circularBody
            case .accessoryRectangular: rectangularBody
            default:                    smallBody
            }
        }
        .modifier(WidgetBackground(family: family))
        // Apply RTL/LTR based on resolved language — fixes Arabic layout direction
        .environment(\.layoutDirection, entry.isArabic ? .rightToLeft : .leftToRight)
    }

    // ── systemSmall ──────────────────────────────────────────────────────────

    private var smallBody: some View {
        VStack(alignment: .center, spacing: 0) {

            // 1. Header: prayer icon + label
            HStack(spacing: 4) {
                Image(systemName: prayerIcon(entry.prayerType))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.gold)
                Text(entry.headerLabel)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.dimWhite)
                    .lineLimit(1)
            }
            .padding(.bottom, 2)

            // 2. Nafl badge — detailed only (Duha / Qiyam)
            if entry.isDetailed {
                NaflBadge(isDuha: entry.isDuhaTime, isQiyam: entry.isQiyamTime, isArabic: entry.isArabic)
                    .padding(.bottom, 2)
            }

            // 3. Prayer name (large)
            Text(entry.localizedName)
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            // 4. Prayer time (gold, prominent)
            Text(formattedTime(entry.prayerTime, lang: entry.resolvedLocale))
                .font(.system(size: 22, weight: .heavy, design: .rounded))
                .foregroundColor(.gold)
                .lineLimit(1)
                .padding(.top, 2)

            // 5. Live countdown with "باقي/in" label
            if let t = entry.prayerTime, t > .now {
                VStack(spacing: 1) {
                    Text(entry.isArabic ? "باقي" : "in")
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.dimWhite)
                    Text(t, style: .timer)
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(.dimWhite)
                        .lineLimit(1)
                }
                .padding(.top, 2)
            }

            // 6. City + date — detailed only
            if entry.isDetailed {
                Spacer(minLength: 4)
                VStack(spacing: 1) {
                    if !entry.city.isEmpty {
                        Text(entry.city)
                            .font(.system(size: 9))
                            .foregroundColor(.dimWhite)
                            .lineLimit(1)
                    }
                    if !entry.localizedDate.isEmpty {
                        Text(entry.localizedDate)
                            .font(.system(size: 8))
                            .foregroundColor(.dimWhite)
                            .lineLimit(1)
                            .minimumScaleFactor(0.6)
                    }
                }
            }

            if entry.isStale {
                Image(systemName: "exclamationmark.circle")
                    .font(.system(size: 9))
                    .foregroundColor(.dimWhite)
                    .padding(.top, 2)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }

    // ── systemMedium ─────────────────────────────────────────────────────────

    private var mediumBody: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 0) {

                // Left column: label + prayer name + nafl badge + optional city + date
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Image(systemName: prayerIcon(entry.prayerType))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.gold)
                        Text(entry.headerLabel)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.dimWhite)
                    }

                    Text(entry.localizedName)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    if entry.isDetailed {
                        // Nafl badge (Duha / Qiyam) — shown when active
                        NaflBadge(isDuha: entry.isDuhaTime, isQiyam: entry.isQiyamTime, isArabic: entry.isArabic)

                        if !entry.city.isEmpty {
                            HStack(spacing: 3) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 9))
                                    .foregroundColor(.dimWhite)
                                Text(entry.city)
                                    .font(.system(size: 11))
                                    .foregroundColor(.dimWhite)
                                    .lineLimit(1)
                            }
                        }
                        if !entry.localizedDate.isEmpty {
                            Text(entry.localizedDate)
                                .font(.system(size: 10))
                                .foregroundColor(.dimWhite)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }
                }

                Spacer()

                // Right column: time + live countdown
                VStack(alignment: .trailing, spacing: 4) {
                    Text(formattedTime(entry.prayerTime, lang: entry.resolvedLocale))
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundColor(.gold)
                        .lineLimit(1)

                    if let t = entry.prayerTime, t > .now {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(entry.isArabic ? "باقي" : "in")
                                .font(.system(size: 9, weight: .medium))
                                .foregroundColor(.dimWhite)
                            Text(t, style: .timer)
                                .font(.system(size: 13, weight: .medium, design: .monospaced))
                                .foregroundColor(.dimWhite)
                                .multilineTextAlignment(.trailing)
                        }
                    }

                    if entry.isStale {
                        Image(systemName: "exclamationmark.circle")
                            .font(.system(size: 10))
                            .foregroundColor(.dimWhite)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.top, 14)
            .padding(.bottom, entry.isDetailed ? 10 : 14)

            // Progress bar — detailed only
            if entry.isDetailed, entry.prevPrayerTime != nil {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(Color.white.opacity(0.12))
                            .frame(height: 3)
                        Capsule()
                            .fill(Color.gold.opacity(0.85))
                            .frame(width: geo.size.width * entry.intervalProgress, height: 3)
                    }
                }
                .frame(height: 3)
                .padding(.horizontal, 16)
                .padding(.bottom, 10)
            }
        }
    }

    // ── accessoryCircular ────────────────────────────────────────────────────

    private var circularBody: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: prayerIcon(entry.prayerType))
                    .font(.system(size: 13, weight: .semibold))
                Text(entry.localizedName)
                    .font(.system(size: 10, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
            }
        }
    }

    // ── accessoryRectangular ─────────────────────────────────────────────────

    private var rectangularBody: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(spacing: 4) {
                Image(systemName: prayerIcon(entry.prayerType))
                    .font(.system(size: 9, weight: .semibold))
                Text(entry.headerLabel)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.secondary)
            }
            HStack(alignment: .firstTextBaseline) {
                Text(entry.localizedName)
                    .font(.system(size: 15, weight: .bold))
                    .lineLimit(1)
                Spacer()
                Text(formattedTime(entry.prayerTime, lang: entry.resolvedLocale))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundColor(.gold)
            }
        }
        .padding(.horizontal, 2)
    }
}

// MARK: – Background (iOS 17+ only — no availability shim needed)

private struct WidgetBackground: ViewModifier {
    let family: WidgetFamily

    func body(content: Content) -> some View {
        if family == .accessoryCircular || family == .accessoryRectangular {
            content.containerBackground(.clear, for: .widget)
        } else {
            content.containerBackground(for: .widget) {
                LinearGradient(
                    colors: [.navyMid, .navyDeep],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        }
    }
}

// MARK: – Widget declaration

@main
struct AtharPrayerWidget: Widget {
    let kind = "AtharPrayerWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: PrayerWidgetIntent.self,
            provider: PrayerIntentProvider()
        ) { entry in
            PrayerWidgetView(entry: entry)
        }
        .configurationDisplayName("الصلاة القادمة · Next Prayer")
        .description("وقت الصلاة القادمة والعداد التنازلي · Next prayer time and countdown")
        .supportedFamilies([.systemSmall, .systemMedium,
                            .accessoryCircular, .accessoryRectangular])
    }
}
