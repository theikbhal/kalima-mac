import SwiftUI
import AppKit
import AVFoundation
import UserNotifications

struct Entry: Codable, Identifiable {
    var id = UUID()
    var date: Date
    var kind: String        // "read" or "listen"
}

struct AppState: Codable {
    var entries: [Entry] = []
    var coins = 0
    var lastClaim: Date? = nil
    var target = 3          // 1 or 3
    var appearance = 0      // 0 system, 1 light, 2 dark
    var remindDaily = true
    var remindHour = 7
    var remindMinute = 0
    var remindMissed = true
}

func copyToClipboard(_ text: String) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(text, forType: .string)
}

final class Store: ObservableObject {
    @Published var s: AppState { didSet { save() } }
    private let url: URL
    private var cal: Calendar { Calendar.current }

    init() {
        let dir = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("KalimaDaily", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        url = dir.appendingPathComponent("state.json")
        if let d = try? Data(contentsOf: url), let st = try? JSONDecoder().decode(AppState.self, from: d) {
            s = st
        } else {
            s = AppState()
        }
    }

    private func save() {
        if let d = try? JSONEncoder().encode(s) { try? d.write(to: url) }
    }

    var scheme: ColorScheme? { s.appearance == 1 ? .light : (s.appearance == 2 ? .dark : nil) }

    // MARK: today
    var readsToday: Int { s.entries.filter { $0.kind == "read" && cal.isDateInToday($0.date) }.count }
    var listenedToday: Bool { s.entries.contains { $0.kind == "listen" && cal.isDateInToday($0.date) } }

    // 3 complete, 2 pass, 1 listened (worst case), 0 none
    var tier: Int {
        if readsToday >= s.target { return 3 }
        if readsToday >= 1 { return 2 }
        if listenedToday { return 1 }
        return 0
    }

    var tierName: String {
        switch tier {
        case 3: return "Complete ✅"
        case 2: return "Pass (read at least once) ✔️"
        case 1: return "Worst case (listened) 🎧"
        default: return "Not yet today"
        }
    }

    func status(on day: Date) -> Int {
        let list = s.entries.filter { cal.isDate($0.date, inSameDayAs: day) }
        let reads = list.filter { $0.kind == "read" }.count
        if reads >= s.target { return 3 }
        if reads >= 1 { return 2 }
        if list.contains(where: { $0.kind == "listen" }) { return 1 }
        return 0
    }

    func lastDays(_ n: Int) -> [Date] {
        let today = cal.startOfDay(for: Date())
        return (0..<n).reversed().map { cal.date(byAdding: .day, value: -$0, to: today)! }
    }

    // MARK: stats
    var dayset: Set<Date> { Set(s.entries.map { cal.startOfDay(for: $0.date) }) }

    var streak: Int {
        let d = dayset
        var day = cal.startOfDay(for: Date())
        if !d.contains(day) { day = cal.date(byAdding: .day, value: -1, to: day)! }
        var n = 0
        while d.contains(day) { n += 1; day = cal.date(byAdding: .day, value: -1, to: day)! }
        return n
    }

    var longest: Int {
        var best = 0, run = 0
        var prev: Date? = nil
        for d in dayset.sorted() {
            if let p = prev, cal.date(byAdding: .day, value: 1, to: p) == d { run += 1 } else { run = 1 }
            best = max(best, run); prev = d
        }
        return best
    }

    var totalReads: Int { s.entries.filter { $0.kind == "read" }.count }
    var totalListens: Int { s.entries.filter { $0.kind == "listen" }.count }

    var shareText: String {
        "📿 \(streak)-day streak reciting the 4th Kalima (Kalima Tamjeed)\n\n\(Kalima.arabic)\n\n\(Kalima.english)\n\n#Kalima #Dhikr #LaIlahaIllallah"
    }

    // MARK: actions
    func addRead() { s.entries.append(Entry(date: Date(), kind: "read")); reschedule() }
    func addListen() { s.entries.append(Entry(date: Date(), kind: "listen")); reschedule() }

    func undoToday() {
        if let i = s.entries.lastIndex(where: { cal.isDateInToday($0.date) }) {
            s.entries.remove(at: i)
            reschedule()
        }
    }

    var rewardAmount: Int {
        let base = [0, 5, 10, 15][tier]
        return tier == 0 ? 0 : base + min(streak, 30)
    }

    var canClaim: Bool {
        guard tier > 0 else { return false }
        if let l = s.lastClaim, cal.isDateInToday(l) { return false }
        return true
    }

    func claim() {
        guard canClaim else { return }
        s.coins += rewardAmount
        s.lastClaim = Date()
    }

    // MARK: notifications
    func requestAuth() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func reschedule() {
        let c = UNUserNotificationCenter.current()
        c.removeAllPendingNotificationRequests()

        func add(_ id: String, _ title: String, _ body: String, _ trigger: UNNotificationTrigger) {
            let content = UNMutableNotificationContent()
            content.title = title; content.body = body; content.sound = .default
            c.add(UNNotificationRequest(identifier: id, content: content, trigger: trigger))
        }

        if s.remindDaily {
            var dc = DateComponents(); dc.hour = s.remindHour; dc.minute = s.remindMinute
            add("daily", "Time for the 4th Kalima 📿", "Read it \(s.target) time(s), or listen if you are busy. Keep your streak!",
                UNCalendarNotificationTrigger(dateMatching: dc, repeats: true))
        }

        if s.remindMissed {
            let last = s.entries.map { $0.date }.max() ?? Date()
            let items: [(String, Int, String)] = [
                ("miss2", 2, "You missed 2 days. Start again today, even one reading or listening counts."),
                ("weekly", 7, "A week without the 4th Kalima. Try again today, a small step."),
                ("monthly", 30, "A month has passed. Come back to your dhikr."),
                ("quarterly", 90, "3 months. It is never late to return."),
                ("semester", 182, "6 months. Begin again with one recitation today."),
                ("yearly", 365, "A year. Restart with a single Kalima today.")
            ]
            for (id, days, msg) in items {
                let base = cal.date(byAdding: .day, value: days, to: last)!
                let fire = cal.date(bySettingHour: 9, minute: 0, second: 0, of: base) ?? base
                if fire > Date() {
                    let comps = cal.dateComponents([.year, .month, .day, .hour, .minute], from: fire)
                    add(id, "Kalima reminder", msg, UNCalendarNotificationTrigger(dateMatching: comps, repeats: false))
                }
            }
        }
    }
}

// Tracks time while the app is the active (frontmost) application
final class TimeTracker: ObservableObject {
    @Published var total: Int
    @Published var today: Int
    private var dayKey: String
    private var timer: Timer?
    private var ticks = 0

    static func key(_ date: Date) -> String {
        let f = DateFormatter(); f.dateFormat = "yyyy-MM-dd"; return f.string(from: date)
    }

    init() {
        let k = TimeTracker.key(Date())
        dayKey = k
        total = UserDefaults.standard.integer(forKey: "totalSeconds")
        let map = UserDefaults.standard.dictionary(forKey: "dailySeconds") as? [String: Int] ?? [:]
        today = map[k] ?? 0
    }

    func start() {
        guard timer == nil else { return }
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in self?.tick() }
        NotificationCenter.default.addObserver(forName: NSApplication.willTerminateNotification,
                                               object: nil, queue: .main) { [weak self] _ in self?.persist() }
    }

    private func tick() {
        guard NSApplication.shared.isActive else { return }
        let k = TimeTracker.key(Date())
        if k != dayKey {
            persist()
            dayKey = k
            let map = UserDefaults.standard.dictionary(forKey: "dailySeconds") as? [String: Int] ?? [:]
            today = map[k] ?? 0
        }
        total += 1; today += 1; ticks += 1
        if ticks % 10 == 0 { persist() }
    }

    private func persist() {
        let d = UserDefaults.standard
        d.set(total, forKey: "totalSeconds")
        var map = d.dictionary(forKey: "dailySeconds") as? [String: Int] ?? [:]
        map[dayKey] = today
        d.set(map, forKey: "dailySeconds")
    }
}

final class Speaker: ObservableObject {
    private let synth = AVSpeechSynthesizer()

    // returns false if no Arabic voice is installed
    @discardableResult
    func speak(_ text: String) -> Bool {
        guard let voice = AVSpeechSynthesisVoice(language: "ar-SA") else { return false }
        synth.stopSpeaking(at: .immediate)
        let u = AVSpeechUtterance(string: text)
        u.voice = voice
        u.rate = 0.38
        synth.speak(u)
        return true
    }
    func stop() { synth.stopSpeaking(at: .immediate) }
}
