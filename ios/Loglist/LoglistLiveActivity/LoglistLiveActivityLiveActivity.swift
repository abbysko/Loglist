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

struct LoglistLiveActivityLiveActivity: Widget {
    @ViewBuilder
    private func activitySummary(
        context: ActivityViewContext<LoglistLiveActivityAttributes>
    ) -> some View {
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

                Text("Tracking items from \(context.attributes.listName)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal)
    }

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: LoglistLiveActivityAttributes.self) { context in
            activitySummary(context: context)

        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.bottom) {
                    activitySummary(context: context)
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
