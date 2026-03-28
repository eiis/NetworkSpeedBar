import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject private var settings: AppSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("刷新间隔")
                    .frame(width: 72, alignment: .leading)
                Picker("", selection: $settings.refreshInterval) {
                    ForEach(RefreshIntervalOption.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .labelsHidden()
            }

            HStack {
                Text("显示单位")
                    .frame(width: 72, alignment: .leading)
                Picker("", selection: $settings.displayUnit) {
                    ForEach(DisplayUnitPreference.allCases) { option in
                        Text(option.title).tag(option)
                    }
                }
                .labelsHidden()
            }

            Text("当前版本默认统计全部活动网络接口。")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(20)
        .frame(width: 320, alignment: .topLeading)
    }
}
