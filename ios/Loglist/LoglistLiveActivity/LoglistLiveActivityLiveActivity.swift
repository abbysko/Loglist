//
//  LoglistLiveActivityLiveActivity.swift
//  LoglistLiveActivity
//
//  Created by Abigail Skofield on 8/22/26.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct LoglistLiveActivityAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var observedCount: Int
        var totalCount: Int
    }

    var listName: String
}

private struct LoglistActivitySummaryView: View {
    let listName: String

    var body: some View {
        HStack(spacing: 12) {
            Image("SmallLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .clipShape(
                    RoundedRectangle(cornerRadius: 5, style: .continuous)
                )

            VStack(alignment: .leading, spacing: 2) {
                Text("Finish your Loglist session?")
                    .font(.headline)
                    .lineLimit(1)

                Text("Tracking items from \(listName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
    }
}

private struct LoglistActivityLockScreenContent: View {
    @Environment(\.activityFamily) private var activityFamily

    let listName: String

    var body: some View {

        // WatchOS uses activityFamily small
        if activityFamily == .small {
            HStack(spacing: 8) {
                Image("WatchLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 3, style: .continuous)
                    )

                VStack(alignment: .leading, spacing: 1) {
                    Text("Finish logging?")
                        .font(.caption2.weight(.semibold))
                        .lineLimit(1)

                    Text(listName)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 8)
        } else {
            LoglistActivitySummaryView(listName: listName)
        }
    }
}

struct LoglistLiveActivityLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LoglistLiveActivityAttributes.self) { context in
            LoglistActivityLockScreenContent(listName: context.attributes.listName)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    LoglistActivitySummaryView(listName: context.attributes.listName)
                }
            } compactLeading: {
                HStack(spacing: 4) {
                    Image("SmallLogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 18, height: 18)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                        )
                    Text("Loglist")
                        .font(.caption.weight(.semibold))
                }
            } compactTrailing: {
                Text(context.attributes.listName)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            } minimal: {
                Image("SmallLogo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 18, height: 18)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 2, style: .continuous)
                    )
            }
            .keylineTint(.accentColor)
        }
        .supplementalActivityFamilies([.small])
    }
}

extension LoglistLiveActivityAttributes {
    fileprivate static var preview: LoglistLiveActivityAttributes {
        LoglistLiveActivityAttributes(listName: "Car Makes")
    }
}

extension LoglistLiveActivityAttributes.ContentState {
    fileprivate static var progress: LoglistLiveActivityAttributes.ContentState {
        LoglistLiveActivityAttributes.ContentState(observedCount: 12, totalCount: 46)
    }
}

#Preview("Notification", as: .content, using: LoglistLiveActivityAttributes.preview) {
    LoglistLiveActivityLiveActivity()
} contentStates: {
    LoglistLiveActivityAttributes.ContentState.progress
}

#Preview("Dynamic Island Expanded", as: .dynamicIsland(.expanded), using: LoglistLiveActivityAttributes.preview) {
    LoglistLiveActivityLiveActivity()
} contentStates: {
    LoglistLiveActivityAttributes.ContentState.progress
}

#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: LoglistLiveActivityAttributes.preview) {
    LoglistLiveActivityLiveActivity()
} contentStates: {
    LoglistLiveActivityAttributes.ContentState.progress
}

#Preview("Dynamic Island Minimal", as: .dynamicIsland(.minimal), using: LoglistLiveActivityAttributes.preview) {
    LoglistLiveActivityLiveActivity()
} contentStates: {
    LoglistLiveActivityAttributes.ContentState.progress
}
