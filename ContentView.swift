import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            SessionTimerView()
                .tabItem {
                    Label("Session", systemImage: "timer")
                }
            
            HistoryView()
                .tabItem {
                    Label("History", systemImage: "chart.xyaxis.line")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [BPSession.self, BPReading.self])
}
