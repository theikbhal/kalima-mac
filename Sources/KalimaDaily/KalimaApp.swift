import SwiftUI

@main
struct KalimaApp: App {
    @StateObject private var store = Store()
    @StateObject private var tracker = TimeTracker()
    @StateObject private var speaker = Speaker()

    var body: some Scene {
        WindowGroup("Kalima Daily", id: "main") {
            ContentView()
                .environmentObject(store)
                .environmentObject(tracker)
                .environmentObject(speaker)
                .preferredColorScheme(store.scheme)
                .frame(minWidth: 1000, minHeight: 700)
                .onAppear { tracker.start() }
        }
    }
}
