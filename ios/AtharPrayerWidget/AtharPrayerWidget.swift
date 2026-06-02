//
//  AtharPrayerWidget.swift
//  AtharPrayerWidget
//
//  Updated PR9: forest v2 palette, Calibri font tokens, 40-min post-prayer
//  window (OQ2), systemLarge (OQ1), widgetURL deep-link, isPrayerEnabled gate (Conflict A).
//
//  NOTE — Xcode manual steps required for Calibri (OQ3):
//    1. For the AtharPrayerWidgetExtension target: Add Files → select
//       calibri-light.ttf, calibri-regular.ttf, calibri-bold.ttf from
//       assets/fonts/ → ensure only AtharPrayerWidgetExtension is checked.
//    2. Open AtharPrayerWidgetExtension/Info.plist → add UIAppFonts array →
//       three items: "calibri-light.ttf", "calibri-regular.ttf", "calibri-bold.ttf".
//    3. Device validate: font renders without system fallback.
//

import AppIntents
import WidgetKit
import SwiftUI

// MARK: – Shared App Group & Key constants
// Keep in sync with WidgetKeys in lib/core/services/widget_data_service.dart

private let kGroupId          = "group.com.iappsnet.athar"
private let kNameAr           = "athar_next_prayer_name_ar"
private let kNameEn           = "athar_next_prayer_name_en"
private let kPrayerType       = "athar_next_prayer_type"      // "fajr" | "sunrise" | "dhuhr" | "asr" | "maghrib" | "isha"
private let kPrayerTime       = "athar_next_prayer_time"      // ISO-8601
private let kTimestamp        = "athar_next_prayer_timestamp" // Unix epoch milliseconds (double)
private let kCity             = "athar_city_name"
private let kAppLocale        = "athar_app_locale"            // "ar" | "en" | "system"
private let kLastUpdated      = "athar_last_updated_at"
private let kDateAr           = "athar_current_date_ar"
private let kDateEn           = "athar_current_date_en"
private let kPrevTimestamp    = "athar_prev_prayer_timestamp"
private let kIsDuhaTime       = "athar_is_duha_time"
private let kIsQiyamTime      = "athar_is_qiyam_time"
private let kPrevNameAr       = "athar_prev_prayer_name_ar"
private let kPrevNameEn       = "athar_prev_prayer_name_en"
private let kIsPrayerEnabled  = "athar_is_prayer_enabled"     // v7: 1=enabled 0=disabled
private let kSunriseTime      = "athar_sunrise_time"           // v8: ISO-8601 sunrise
private let kSunsetTime       = "athar_sunset_time"            // v8: ISO-8601 sunset (maghrib proxy)

// MARK: – Widget configuration intent

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

enum WidgetDisplayMode: String, AppEnum {
    case detailed
    case compact

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
    let prayerType: String
    let prayerTime: Date?
    let prevPrayerTime: Date?
    let prevNameAr: String
    let prevNameEn: String
    let city: String
    let appLocale: String
    let dateAr: String
    let dateEn: String
    let isStale: Bool
    let intentLanguage: WidgetLanguage
    let intentDisplayMode: WidgetDisplayMode
    let isDuhaTime: Bool
    let isQiyamTime: Bool
    let isPrayerEnabled: Bool   // v7: false → show "Enable Prayer in Athar" prompt
    let sunriseTimeStr: String  // v8: ISO-8601 sunrise time ("" when unavailable)
    let sunsetTimeStr: String   // v8: ISO-8601 sunset time — maghrib proxy ("" when unavailable)

    var sunriseDate: Date? { parseISOTime(sunriseTimeStr) }
    var sunsetDate: Date?  { parseISOTime(sunsetTimeStr) }

    // ── Computed ──────────────────────────────────────────────────────────────

    var intervalProgress: Double {
        guard let prev = prevPrayerTime, let next = prayerTime else { return 0 }
        let total = next.timeIntervalSince(prev)
        guard total > 0 else { return 0 }
        return min(max(Date().timeIntervalSince(prev) / total, 0), 1)
    }

    var resolvedLocale: String {
        switch intentLanguage {
        case .arabic:  return "ar"
        case .english: return "en"
        case .system:
            if let code = Locale.current.language.languageCode?.identifier {
                return code
            }
            return (appLocale == "system" || appLocale.isEmpty) ? "ar" : appLocale
        }
    }

    var isArabic: Bool   { resolvedLocale == "ar" }
    var isDetailed: Bool { intentDisplayMode == .detailed }

    /// True when within 40 minutes after the previous prayer began (OQ2: 2400s).
    /// In-app window is dynamic (15–45 min; Fajr=40, Maghrib=20). Widget uses fixed 40 min
    /// — matches the Fajr special case; worst-case over-extends by ~10 min vs. Maghrib.
    /// Alignment decision deferred to designer. (P9-C)
    var isCurrentPrayerWindow: Bool {
        guard let prev = prevPrayerTime, !prevNameAr.isEmpty else { return false }
        return Date().timeIntervalSince(prev) < 2400
    }

    var localizedName: String     { isArabic ? nameAr : nameEn }
    var localizedPrevName: String { isArabic ? prevNameAr : prevNameEn }

    var headerLabel: String {
        if isCurrentPrayerWindow {
            return isArabic ? "بعد \(localizedPrevName)" : "After \(localizedPrevName)"
        }
        return isArabic ? "الصلاة القادمة" : "Next Prayer"
    }

    var localizedDate: String { isArabic ? dateAr : dateEn }

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
        isQiyamTime: false,
        isPrayerEnabled: true,
        sunriseTimeStr: "",
        sunsetTimeStr: ""
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

        var prevPrayerTime: Date?
        let prevTsMs = d?.double(forKey: kPrevTimestamp) ?? 0
        if prevTsMs > 0 {
            prevPrayerTime = Date(timeIntervalSince1970: prevTsMs / 1000.0)
        }

        let isDuhaTime  = (d?.integer(forKey: kIsDuhaTime)  ?? 0) == 1
        let isQiyamTime = (d?.integer(forKey: kIsQiyamTime) ?? 0) == 1
        let prevNameAr  = d?.string(forKey: kPrevNameAr) ?? ""
        let prevNameEn  = d?.string(forKey: kPrevNameEn) ?? ""
        // v7: default 1 (enabled) when key absent — backward compat with pre-PR9 pushes.
        let isPrayerEnabled = (d?.integer(forKey: kIsPrayerEnabled) ?? 1) == 1
        // v8: sunrise/sunset — empty string when not yet pushed (pre-PR9 installs).
        let sunriseTimeStr = d?.string(forKey: kSunriseTime) ?? ""
        let sunsetTimeStr  = d?.string(forKey: kSunsetTime)  ?? ""

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
            isQiyamTime: isQiyamTime,
            isPrayerEnabled: isPrayerEnabled,
            sunriseTimeStr: sunriseTimeStr,
            sunsetTimeStr: sunsetTimeStr
        )
    }
}

// MARK: – Design tokens — Athar v2 forest palette
// OQ7 DEFERRED: WidgetTokens.swift pipeline → PR-CLEANUP.
// Inline consts updated to v2 values; keep in sync with AtharColors.dart.

private extension Color {
    static let athaForest    = Color(red: 0.059, green: 0.239, blue: 0.180) // #0F3D2E
    static let athaForestMid = Color(red: 0.102, green: 0.353, blue: 0.271) // #1A5A45
    static let athaCream     = Color(red: 0.929, green: 0.902, blue: 0.784) // #EDE6C8
    static let dimWhite      = Color.white.opacity(0.55)
    static let qiyamBlue    = Color(red: 0.45, green: 0.65, blue: 0.95)
}

// MARK: – Calibri font helpers
// OQ3: font is used in code; rendering requires Calibri .ttf bundled in this
// extension target + UIAppFonts in Info.plist (manual Xcode step — see file header).
// Falls back to system font silently if font files are not registered.

private func calibri(_ size: CGFloat, _ weight: Font.Weight = .regular) -> Font {
    switch weight {
    case .light:  return Font.custom("Calibri-Light", size: size)
    case .bold:   return Font.custom("Calibri-Bold",  size: size)
    default:      return Font.custom("Calibri",       size: size)
    }
}

private func calibriMono(_ size: CGFloat) -> Font {
    Font.custom("Calibri-Light", size: size).monospacedDigit()
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

// MARK: – ISO-8601 date parser (used for sunrise/sunset v8 keys)

private func parseISOTime(_ iso: String) -> Date? {
    guard !iso.isEmpty else { return nil }
    let df = DateFormatter()
    df.locale = Locale(identifier: "en_US_POSIX")
    for fmt in ["yyyy-MM-dd'T'HH:mm:ss.SSSSSS",
                "yyyy-MM-dd'T'HH:mm:ss.SSS",
                "yyyy-MM-dd'T'HH:mm:ss"] {
        df.dateFormat = fmt
        if let d = df.date(from: iso) { return d }
    }
    return nil
}

// MARK: – Formatted time string (locale-aware)

private func formattedTime(_ date: Date?, lang: String) -> String {
    guard let date else { return "--:--" }
    let f = DateFormatter()
    f.timeStyle = .short
    f.locale = Locale(identifier: lang == "ar" ? "ar_SA" : "en_US")
    return f.string(from: date)
}

// MARK: – Prayer strip helpers (systemLarge)

private let prayerOrder: [String] = ["fajr", "dhuhr", "asr", "maghrib", "isha"]

private struct PrayerStripInfo {
    let type: String
    let nameAr: String
    let nameEn: String
}

private let prayerStripInfos: [PrayerStripInfo] = [
    PrayerStripInfo(type: "fajr",    nameAr: "الفجر",  nameEn: "Fajr"),
    PrayerStripInfo(type: "dhuhr",   nameAr: "الظهر",  nameEn: "Dhuhr"),
    PrayerStripInfo(type: "asr",     nameAr: "العصر",  nameEn: "Asr"),
    PrayerStripInfo(type: "maghrib", nameAr: "المغرب", nameEn: "Maghrib"),
    PrayerStripInfo(type: "isha",    nameAr: "العشاء", nameEn: "Isha"),
]

private enum StripCellState { case past, now, next, future }

private func stripState(
    idx: Int,
    nowIdx: Int,
    nextIdx: Int,
    isCurrentWindow: Bool
) -> StripCellState {
    // Night wrap: Isha is now, Fajr is next day
    if nextIdx == 0 && nowIdx == 4 {
        if idx == 0 { return .next }
        if idx == 4 { return isCurrentWindow ? .now : .past }
        return .past
    }
    if idx < nowIdx { return .past }
    if idx == nowIdx { return isCurrentWindow ? .now : .past }
    if idx == nextIdx { return .next }
    return .future
}

private func inferTypeFromEnglishName(_ name: String) -> String {
    switch name.lowercased() {
    case "fajr":    return "fajr"
    case "sunrise": return "sunrise"
    case "dhuhr":   return "dhuhr"
    case "asr":     return "asr"
    case "maghrib": return "maghrib"
    case "isha":    return "isha"
    default:        return ""
    }
}

// MARK: – Nafl badge

private struct NaflBadge: View {
    let isDuha: Bool
    let isQiyam: Bool
    let isArabic: Bool

    var body: some View {
        if isDuha || isQiyam {
            let label: String = {
                if isDuha  { return isArabic ? "وقت الضحى"  : "Duha" }
                             return isArabic ? "قيام الليل" : "Qiyam"
            }()
            let color: Color = isDuha ? .athaCream : .qiyamBlue

            Text(label)
                .font(calibri(8, .bold))
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
            if !entry.isPrayerEnabled {
                prayerDisabledView
            } else {
                switch family {
                case .systemSmall:          smallBody
                case .systemMedium:         mediumBody
                case .systemLarge:          largeBody
                case .accessoryCircular:    circularBody
                case .accessoryRectangular: rectangularBody
                default:                    smallBody
                }
            }
        }
        .widgetURL(URL(string: "athar://prayer"))
        .modifier(WidgetBackground(family: family))
        .environment(\.layoutDirection, entry.isArabic ? .rightToLeft : .leftToRight)
    }

    // ── Prayer disabled (Conflict A: gate) ─────────────────────────────────

    private var prayerDisabledView: some View {
        VStack(spacing: 8) {
            Image(systemName: "moon.stars")
                .font(.system(size: 26, weight: .light))
                .foregroundColor(.athaCream.opacity(0.6))
            Text(entry.isArabic ? "فعّل الصلاة في أثر" : "Enable Prayer in Athar")
                .font(calibri(12))
                .foregroundColor(.athaCream.opacity(0.75))
                .multilineTextAlignment(.center)
                .lineLimit(2)
        }
        .padding(16)
    }

    // ── systemSmall ──────────────────────────────────────────────────────────

    private var smallBody: some View {
        VStack(alignment: .center, spacing: 0) {

            HStack(spacing: 4) {
                Image(systemName: prayerIcon(entry.prayerType))
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundColor(.athaCream)
                Text(entry.headerLabel)
                    .font(calibri(10))
                    .foregroundColor(.dimWhite)
                    .lineLimit(1)
            }
            .padding(.bottom, 2)

            if entry.isDetailed {
                NaflBadge(isDuha: entry.isDuhaTime, isQiyam: entry.isQiyamTime, isArabic: entry.isArabic)
                    .padding(.bottom, 2)
            }

            Text(entry.localizedName)
                .font(calibri(20, .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            Text(formattedTime(entry.prayerTime, lang: entry.resolvedLocale))
                .font(calibri(22, .bold))
                .foregroundColor(.athaCream)
                .lineLimit(1)
                .padding(.top, 2)

            // Countdown — 32pt, Calibri-Light mono (OQ2 spec)
            if let t = entry.prayerTime, t > .now {
                VStack(spacing: 1) {
                    Text(entry.isArabic ? "باقي" : "in")
                        .font(calibri(8))
                        .foregroundColor(.dimWhite)
                    Text(t, style: .timer)
                        .font(calibriMono(32))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.6)
                }
                .padding(.top, 2)
            }

            if entry.isDetailed {
                Spacer(minLength: 4)
                VStack(spacing: 1) {
                    if !entry.city.isEmpty {
                        Text(entry.city)
                            .font(calibri(9))
                            .foregroundColor(.dimWhite)
                            .lineLimit(1)
                    }
                    if !entry.localizedDate.isEmpty {
                        Text(entry.localizedDate)
                            .font(calibri(8))
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

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 4) {
                        Image(systemName: prayerIcon(entry.prayerType))
                            .font(.system(size: 11, weight: .semibold))
                            .foregroundColor(.athaCream)
                        Text(entry.headerLabel)
                            .font(calibri(11))
                            .foregroundColor(.dimWhite)
                    }

                    Text(entry.localizedName)
                        .font(calibri(28, .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    if entry.isDetailed {
                        NaflBadge(isDuha: entry.isDuhaTime, isQiyam: entry.isQiyamTime, isArabic: entry.isArabic)

                        if !entry.city.isEmpty {
                            HStack(spacing: 3) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 9))
                                    .foregroundColor(.dimWhite)
                                Text(entry.city)
                                    .font(calibri(11))
                                    .foregroundColor(.dimWhite)
                                    .lineLimit(1)
                            }
                        }
                        if !entry.localizedDate.isEmpty {
                            Text(entry.localizedDate)
                                .font(calibri(10))
                                .foregroundColor(.dimWhite)
                                .lineLimit(1)
                                .minimumScaleFactor(0.7)
                        }
                    }
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 4) {
                    Text(formattedTime(entry.prayerTime, lang: entry.resolvedLocale))
                        .font(calibri(26, .bold))
                        .foregroundColor(.athaCream)
                        .lineLimit(1)

                    // Countdown — 22pt Calibri-Light mono for medium
                    if let t = entry.prayerTime, t > .now {
                        VStack(alignment: .trailing, spacing: 1) {
                            Text(entry.isArabic ? "باقي" : "in")
                                .font(calibri(9))
                                .foregroundColor(.dimWhite)
                            Text(t, style: .timer)
                                .font(calibriMono(22))
                                .foregroundColor(.white)
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

            if entry.isDetailed, entry.prevPrayerTime != nil {
                progressBar
                    .padding(.horizontal, 16)
                    .padding(.bottom, 10)
            }
        }
    }

    // ── systemLarge (OQ1) ────────────────────────────────────────────────────

    private var largeBody: some View {
        VStack(alignment: .leading, spacing: 0) {

            // Dual date header
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.dateAr.isEmpty ? entry.localizedDate : entry.dateAr)
                    .font(calibri(13, .bold))
                    .foregroundColor(.athaCream)
                    .lineLimit(1)
                if !entry.dateEn.isEmpty && entry.isArabic {
                    Text(entry.dateEn)
                        .font(calibri(11))
                        .foregroundColor(.dimWhite)
                        .lineLimit(1)
                } else if !entry.dateAr.isEmpty && !entry.isArabic {
                    Text(entry.dateAr)
                        .font(calibri(11))
                        .foregroundColor(.dimWhite)
                        .lineLimit(1)
                }
            }
            .padding(.bottom, 10)

            Rectangle()
                .fill(Color.white.opacity(0.12))
                .frame(height: 1)
                .padding(.bottom, 12)

            // Prayer name + header label
            HStack(spacing: 6) {
                Image(systemName: prayerIcon(entry.prayerType))
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.athaCream)
                Text(entry.headerLabel)
                    .font(calibri(13))
                    .foregroundColor(.dimWhite)
            }
            .padding(.bottom, 4)

            Text(entry.localizedName)
                .font(calibri(36, .bold))
                .foregroundColor(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
                .padding(.bottom, 2)

            // Nafl badge
            NaflBadge(isDuha: entry.isDuhaTime, isQiyam: entry.isQiyamTime, isArabic: entry.isArabic)
                .padding(.bottom, 4)

            // Countdown — 40pt, Calibri-Light mono (OQ1 spec)
            if let t = entry.prayerTime, t > .now {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(t, style: .timer)
                        .font(calibriMono(40))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    Text(entry.isArabic ? "باقي" : "remaining")
                        .font(calibri(13))
                        .foregroundColor(.dimWhite)
                }
                .padding(.bottom, 8)
            }

            Spacer(minLength: 8)

            // Progress bar
            if entry.prevPrayerTime != nil {
                progressBar
                    .padding(.bottom, 10)
            }

            // Sunrise/sunset time markers (P9-A — v8 keys)
            sunriseSunsetRow
                .padding(.bottom, 6)

            // 5-prayer strip
            prayerStripView
                .padding(.bottom, 4)

            // City + stale
            HStack {
                if !entry.city.isEmpty {
                    HStack(spacing: 3) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.dimWhite)
                        Text(entry.city)
                            .font(calibri(11))
                            .foregroundColor(.dimWhite)
                    }
                }
                Spacer()
                if entry.isStale {
                    Image(systemName: "exclamationmark.circle")
                        .font(.system(size: 10))
                        .foregroundColor(.dimWhite)
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }

    // ── 5-prayer strip (large only) ───────────────────────────────────────────

    private var prayerStripView: some View {
        let nextIdx  = prayerOrder.firstIndex(of: entry.prayerType) ?? 0
        let prevType = inferTypeFromEnglishName(entry.prevNameEn)
        let nowIdx   = prayerOrder.firstIndex(of: prevType) ?? -1

        return HStack(spacing: 0) {
            ForEach(Array(prayerStripInfos.enumerated()), id: \.0) { idx, info in
                let state = nowIdx >= 0
                    ? stripState(idx: idx, nowIdx: nowIdx, nextIdx: nextIdx,
                                 isCurrentWindow: entry.isCurrentPrayerWindow)
                    : (idx == nextIdx ? .next : .future)

                prayerStripCell(info: info, state: state)

                if idx < prayerStripInfos.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.15))
                        .frame(width: 1, height: 28)
                }
            }
        }
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }

    @ViewBuilder
    private func prayerStripCell(info: PrayerStripInfo, state: StripCellState) -> some View {
        let name          = entry.isArabic ? info.nameAr : info.nameEn
        let isHighlighted = state == .now || state == .next
        let opacity       = state == .past ? 0.35 : (state == .future ? 0.45 : 1.0)
        let accent: Color = isHighlighted ? .athaCream : .dimWhite
        let iconPt: CGFloat = isHighlighted ? 13 : 11
        let namePt: CGFloat = isHighlighted ? 11 : 10

        VStack(spacing: 3) {
            Image(systemName: prayerIcon(info.type))
                .font(.system(size: iconPt, weight: .semibold))
                .foregroundColor(accent)
            Text(name)
                .font(calibri(namePt))
                .foregroundColor(.white.opacity(opacity))
                .lineLimit(1)
                .minimumScaleFactor(0.6)
            if state == .now {
                Circle().fill(Color.athaCream).frame(width: 4, height: 4)
            } else if state == .next {
                Circle().fill(Color.white.opacity(0.4)).frame(width: 4, height: 4)
            } else {
                Spacer().frame(height: 4)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .opacity(opacity)
    }

    // ── Sunrise/sunset row (systemLarge, P9-A) ────────────────────────────────

    @ViewBuilder
    private var sunriseSunsetRow: some View {
        let sr = entry.sunriseDate
        let ss = entry.sunsetDate
        if sr != nil || ss != nil {
            HStack {
                if let sr {
                    HStack(spacing: 4) {
                        Image(systemName: "sunrise.fill")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.athaCream.opacity(0.7))
                        Text(formattedTime(sr, lang: entry.resolvedLocale))
                            .font(calibri(11))
                            .foregroundColor(.dimWhite)
                    }
                }
                Spacer()
                if let ss {
                    HStack(spacing: 4) {
                        Text(formattedTime(ss, lang: entry.resolvedLocale))
                            .font(calibri(11))
                            .foregroundColor(.dimWhite)
                        Image(systemName: "sunset.fill")
                            .font(.system(size: 10, weight: .semibold))
                            .foregroundColor(.athaCream.opacity(0.7))
                    }
                }
            }
        }
    }

    // ── Progress bar (shared) ─────────────────────────────────────────────────

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.12))
                    .frame(height: 3)
                Capsule()
                    .fill(Color.athaCream.opacity(0.85))
                    .frame(width: geo.size.width * entry.intervalProgress, height: 3)
            }
        }
        .frame(height: 3)
    }

    // ── accessoryCircular ────────────────────────────────────────────────────

    private var circularBody: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: prayerIcon(entry.prayerType))
                    .font(.system(size: 13, weight: .semibold))
                Text(entry.localizedName)
                    .font(calibri(10, .bold))
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
                    .font(calibri(9))
                    .foregroundColor(.secondary)
            }
            HStack(alignment: .firstTextBaseline) {
                Text(entry.localizedName)
                    .font(calibri(15, .bold))
                    .lineLimit(1)
                Spacer()
                Text(formattedTime(entry.prayerTime, lang: entry.resolvedLocale))
                    .font(calibri(15, .bold))
                    .foregroundColor(.athaCream)
            }
        }
        .padding(.horizontal, 2)
    }
}

// MARK: – Background

private struct WidgetBackground: ViewModifier {
    let family: WidgetFamily

    func body(content: Content) -> some View {
        if family == .accessoryCircular || family == .accessoryRectangular {
            content.containerBackground(.clear, for: .widget)
        } else {
            content.containerBackground(for: .widget) {
                ZStack {
                    LinearGradient(
                        colors: [.athaForest, .athaForestMid],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    Color.white.opacity(0.03) // subtle glass sheen
                }
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
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge,
                            .accessoryCircular, .accessoryRectangular])
    }
}
