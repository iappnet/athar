//
//  AtharHabitWidget_AtharHabitWidget_AtharHabitWidgetControl.swift
//  AtharHabitWidget AtharHabitWidget AtharHabitWidget
//
//  Created by iTech on 27/04/2026.
//

import AppIntents
import SwiftUI
import WidgetKit

struct AtharHabitWidget_AtharHabitWidget_AtharHabitWidgetControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        StaticControlConfiguration(
            kind: "com.iappsnet.athar.AtharHabitWidget AtharHabitWidget AtharHabitWidget",
            provider: Provider()
        ) { value in
            ControlWidgetToggle(
                "Start Timer",
                isOn: value,
                action: StartTimerIntent()
            ) { isRunning in
                Label(isRunning ? "On" : "Off", systemImage: "timer")
            }
        }
        .displayName("Timer")
        .description("A an example control that runs a timer.")
    }
}

extension AtharHabitWidget_AtharHabitWidget_AtharHabitWidgetControl {
    struct Provider: ControlValueProvider {
        var previewValue: Bool {
            false
        }

        func currentValue() async throws -> Bool {
            let isRunning = true // Check if the timer is running
            return isRunning
        }
    }
}

struct StartTimerIntent: SetValueIntent {
    static let title: LocalizedStringResource = "Start a timer"

    @Parameter(title: "Timer is running")
    var value: Bool

    func perform() async throws -> some IntentResult {
        // Start / stop the timer based on `value`.
        return .result()
    }
}
