import SwiftUI

struct ContentView: View {
    @StateObject private var moodDataManager = MoodDataManager()
    let generator = UIImpactFeedbackGenerator(style: .medium)
    var body: some View {
        TabView {
            MoodTrackerView()
                .tabItem {
                    Label("Track Mood", systemImage: "face.smiling")
                }

            WeeklyTrendsView()
                .tabItem {
                    Label("Weekly Trends", systemImage: "chart.bar.fill")
                }
        }
        .environmentObject(moodDataManager)
    }
}

#Preview {
    ContentView()
}
