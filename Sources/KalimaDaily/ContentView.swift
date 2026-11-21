import SwiftUI
import AppKit

enum Tab: String, CaseIterable, Identifiable {
    case today = "Today"
    case benefits = "Benefits"
    case howto = "How to Use"
    case prompts = "AI Prompts"
    case progress = "Progress"
    case github = "GitHub"
    case settings = "Settings"

    var id: String { rawValue }
    var icon: String {
        switch self {
        case .today: return "sun.max.fill"
        case .benefits: return "heart.text.square.fill"
        case .howto: return "questionmark.circle.fill"
        case .prompts: return "sparkles"
        case .progress: return "chart.bar.fill"
        case .github: return "chevron.left.forwardslash.chevron.right"
        case .settings: return "gearshape.fill"
        }
    }
}

struct ContentView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var tracker: TimeTracker
    @State private var tab: Tab? = .today

    var body: some View {
        NavigationSplitView {
            VStack(spacing: 0) {
                BrandHeader().padding()
                List(selection: $tab) {
                    ForEach(Tab.allCases) { t in
                        Label(t.rawValue, systemImage: t.icon).tag(t)
                    }
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text("Time in app").font(.caption).foregroundStyle(.secondary)
                    Text("Today \(fmtLong(tracker.today))").font(.callout.monospacedDigit())
                    Text("Total \(fmtLong(tracker.total))").font(.callout.monospacedDigit())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
            }
            .navigationSplitViewColumnWidth(min: 210, ideal: 230, max: 270)
        } detail: {
            ZStack {
                AnimatedBackground()
                detail
            }
        }
        .onAppear { store.requestAuth(); store.reschedule() }
    }

    @ViewBuilder private var detail: some View {
        switch tab ?? .today {
        case .today: TodayView()
        case .benefits: BenefitsView()
        case .howto: HowToView()
        case .prompts: PromptsView()
        case .progress: ProgressTab()
        case .github: GitHubView()
        case .settings: SettingsView()
        }
    }
}

struct TodayView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var tracker: TimeTracker
    @State private var celebrate = false

    private var greeting: String {
        let h = Calendar.current.component(.hour, from: Date())
        return h < 12 ? "Assalamu alaikum, good morning" : (h < 18 ? "Assalamu alaikum 🌤" : "Assalamu alaikum 🌙")
    }

    private func flash() {
        withAnimation(.spring()) { celebrate = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.8) { withAnimation { celebrate = false } }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                HStack {
                    Text(greeting).font(.largeTitle.bold())
                    Spacer()
                    ShareLink(item: store.shareText) { Label("Share streak", systemImage: "square.and.arrow.up") }
                }
                HStack(spacing: 12) {
                    StatTile(icon: "flame.fill", title: "Streak (days)", value: "\(store.streak)", tint: .orange)
                    StatTile(icon: "star.circle.fill", title: "Coins", value: "\(store.s.coins)", tint: .yellow)
                    StatTile(icon: "clock.fill", title: "In app today", value: fmtLong(tracker.today), tint: .blue)
                    StatTile(icon: "infinity", title: "In app total", value: fmtLong(tracker.total), tint: .purple)
                }
                KalimaCard()
                HStack(alignment: .top, spacing: 16) {
                    ReadCard(onDone: flash)
                    RewardCard()
                }
            }
            .padding(24)
        }
        .overlay {
            if celebrate {
                VStack(spacing: 8) {
                    Text("📿").font(.system(size: 90))
                    Text("Masha'Allah! Recorded").font(.title2.bold())
                }
                .padding(30)
                .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 24))
                .transition(.scale.combined(with: .opacity))
            }
        }
    }
}

struct KalimaCard: View {
    var body: some View {
        VStack(spacing: 14) {
            Text("The Fourth Kalima: Tamjeed (Glorification)").font(.headline)
            Text(Kalima.arabic)
                .font(.custom("Geeza Pro", size: 34))
                .lineSpacing(16)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity)
                .textSelection(.enabled)
            Text(Kalima.transliteration)
                .italic()
                .multilineTextAlignment(.center)
                .textSelection(.enabled)
            Text(Kalima.english)
                .multilineTextAlignment(.center)
                .textSelection(.enabled)
            Text(Kalima.hinglish)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .textSelection(.enabled)
            HStack {
                CopyButton(title: "Copy Arabic", text: Kalima.arabic)
                CopyButton(title: "Transliteration", text: Kalima.transliteration)
                CopyButton(title: "English", text: Kalima.english)
                CopyButton(title: "Hinglish", text: Kalima.hinglish)
                CopyButton(title: "Copy all", text: Kalima.all)
            }
        }
        .frame(maxWidth: .infinity)
        .card()
    }
}

struct ReadCard: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var speaker: Speaker
    var onDone: () -> Void
    @State private var msg = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Today's recitation", systemImage: "book.closed.fill").font(.headline)
            HStack(spacing: 8) {
                ForEach(0..<store.s.target, id: \.self) { i in
                    Image(systemName: i < store.readsToday ? "checkmark.circle.fill" : "circle")
                        .font(.title)
                        .foregroundStyle(i < store.readsToday ? Color.green : Color.secondary)
                }
                Text("\(store.readsToday) / \(store.s.target)").font(.title3.bold())
            }
            Text("Status: \(store.tierName)").font(.callout)
            HStack {
                Button("I read it ✅") { store.addRead(); onDone() }
                    .buttonStyle(.borderedProminent).tint(.teal)
                Button("Listened instead 🎧") { store.addListen(); onDone() }
                Button("Undo last") { store.undoToday() }
            }
            HStack {
                Button("Listen online") {
                    if let u = URL(string: Links.listen) { NSWorkspace.shared.open(u) }
                }
                Button("Speak (machine voice)") {
                    if !speaker.speak(Kalima.arabic) {
                        msg = "No Arabic voice installed. Add one in System Settings > Accessibility > Spoken Content > System Voice > Manage Voices."
                    } else { msg = "" }
                }
                Button("Stop") { speaker.stop() }
            }
            if !msg.isEmpty { Text(msg).font(.caption).foregroundStyle(.red) }
            Text("Goal: read \(store.s.target)x. Reading once is a pass. Listening is the worst-case minimum. The machine voice is not a reciter, so prefer a real recitation.")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }
}

struct RewardCard: View {
    @EnvironmentObject var store: Store
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Daily reward", systemImage: "gift.fill").font(.headline)
            if store.canClaim {
                Text("Claim \(store.rewardAmount) coins for today.")
            } else if store.tier > 0 {
                Text("Claimed for today ✅ Come back tomorrow.")
            } else {
                Text("Read or listen once to unlock today's reward.")
            }
            Text("Complete 15, pass 10, listened 5, plus a streak bonus (up to 30).")
                .font(.footnote).foregroundStyle(.secondary)
            Button("Claim") { withAnimation { store.claim() } }
                .disabled(!store.canClaim).buttonStyle(.borderedProminent).tint(.yellow)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .card()
    }
}

struct BenefitsView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("Benefits").font(.largeTitle.bold())
                Text("Each point shows its source and how authentic it is, so weak claims are not presented as sahih.")
                    .foregroundStyle(.secondary)
                ForEach(Content.benefits) { b in
                    HStack(alignment: .top, spacing: 14) {
                        Image(systemName: b.icon).font(.title).foregroundStyle(b.grade.color).frame(width: 40)
                        VStack(alignment: .leading, spacing: 6) {
                            Text(b.title).font(.headline)
                            Text(b.text).textSelection(.enabled)
                            Text(b.source).font(.caption).foregroundStyle(.secondary)
                            GradeBadge(grade: b.grade)
                        }
                        Spacer()
                    }
                    .card()
                }
                Text("Wording is a paraphrase. Please verify references with a trusted scholar.")
                    .font(.footnote).foregroundStyle(.secondary)
            }
            .padding(24)
        }
    }
}

struct HowToView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("How to Use").font(.largeTitle.bold())
                ForEach(Content.howto) { h in
                    HStack(alignment: .top, spacing: 14) {
                        Text("\(h.n)")
                            .font(.title2.bold())
                            .frame(width: 40, height: 40)
                            .background(Color.teal.opacity(0.25), in: Circle())
                        VStack(alignment: .leading, spacing: 4) {
                            Text(h.title).font(.headline)
                            Text(h.text)
                        }
                        Spacer()
                    }
                    .card()
                }
            }
            .padding(24)
        }
    }
}

struct PromptsView: View {
    private func claudeURL(_ text: String) -> URL? {
        let enc = text.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        return URL(string: "https://claude.ai/new?q=" + enc)
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 14) {
                Text("AI Prompts").font(.largeTitle.bold())
                Text("Copy a prompt into any AI assistant, or open it directly in Claude. Always double-check religious references with a scholar.")
                    .foregroundStyle(.secondary)
                ForEach(Content.prompts) { p in
                    VStack(alignment: .leading, spacing: 8) {
                        Text(p.title).font(.headline)
                        Text(p.text).font(.callout).textSelection(.enabled)
                        HStack {
                            CopyButton(title: "Copy prompt", text: p.text)
                            Button("Open in Claude") {
                                if let u = claudeURL(p.text) { NSWorkspace.shared.open(u) }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .card()
                }
            }
            .padding(24)
        }
    }
}

struct ProgressTab: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var tracker: TimeTracker

    private func color(_ t: Int) -> Color {
        switch t {
        case 3: return Color.green
        case 2: return Color.teal
        case 1: return Color.orange
        default: return Color.gray.opacity(0.25)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Progress").font(.largeTitle.bold())
                HStack(spacing: 12) {
                    StatTile(icon: "flame.fill", title: "Current streak", value: "\(store.streak)", tint: .orange)
                    StatTile(icon: "trophy.fill", title: "Longest streak", value: "\(store.longest)", tint: .yellow)
                    StatTile(icon: "calendar", title: "Days done", value: "\(store.dayset.count)", tint: .green)
                    StatTile(icon: "star.circle.fill", title: "Coins", value: "\(store.s.coins)", tint: .yellow)
                }
                HStack(spacing: 12) {
                    StatTile(icon: "book.fill", title: "Total readings", value: "\(store.totalReads)", tint: .teal)
                    StatTile(icon: "headphones", title: "Times listened", value: "\(store.totalListens)", tint: .orange)
                    StatTile(icon: "clock.fill", title: "In app today", value: fmtLong(tracker.today), tint: .blue)
                    StatTile(icon: "infinity", title: "In app total", value: fmtLong(tracker.total), tint: .purple)
                }
                VStack(alignment: .leading, spacing: 10) {
                    Text("Last 28 days").font(.headline)
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 7), spacing: 8) {
                        ForEach(store.lastDays(28), id: \.self) { d in
                            Text("\(Calendar.current.component(.day, from: d))")
                                .font(.caption.bold())
                                .frame(maxWidth: .infinity, minHeight: 36)
                                .background(color(store.status(on: d)), in: RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    Text("Green = complete, teal = pass, orange = listened, grey = missed")
                        .font(.caption).foregroundStyle(.secondary)
                }
                .card()
                VStack(alignment: .leading, spacing: 8) {
                    Text("Badges").font(.headline)
                    ForEach(Content.badges, id: \.0) { b in
                        HStack {
                            Text(b.1)
                            Spacer()
                            Text(store.longest >= b.0 ? "Earned ✅" : "\(b.0) days").foregroundStyle(.secondary)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .card()
            }
            .padding(24)
        }
    }
}

struct GitHubView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("GitHub").font(.largeTitle.bold())
                VStack(alignment: .leading, spacing: 10) {
                    Text("Open source").font(.headline)
                    Text(Links.repo).textSelection(.enabled)
                    HStack {
                        Button("Open repository") { open(Links.repo) }.buttonStyle(.borderedProminent).tint(.teal)
                        Button("Report an issue") { open(Links.repo + "/issues/new") }
                        Button("Star on GitHub ⭐") { open(Links.repo) }
                        CopyButton(title: "Copy repo link", text: Links.repo)
                    }
                }
                .card()
                VStack(alignment: .leading, spacing: 10) {
                    Text("Build it yourself").font(.headline)
                    Text(Links.clone).font(.system(.callout, design: .monospaced)).textSelection(.enabled)
                    Text("cd kalima-mac && ./install.sh").font(.system(.callout, design: .monospaced)).textSelection(.enabled)
                    HStack {
                        CopyButton(title: "Copy clone command", text: Links.clone)
                    }
                    Text("Needs macOS 13+ and Xcode command line tools. The script builds the app, installs it to Applications and adds a Desktop shortcut.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                .card()
                VStack(alignment: .leading, spacing: 6) {
                    Text("Contribute").font(.headline)
                    Text("• Add more languages or translations")
                    Text("• Add real recitation audio (with permission from the reciter)")
                    Text("• Add the other kalimas")
                    Text("• Improve accessibility and design")
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .card()
            }
            .padding(24)
        }
    }

    private func open(_ s: String) {
        if let u = URL(string: s) { NSWorkspace.shared.open(u) }
    }
}

struct SettingsView: View {
    @EnvironmentObject var store: Store
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Settings").font(.largeTitle.bold())
                VStack(alignment: .leading, spacing: 10) {
                    Text("Daily goal").font(.headline)
                    Picker("", selection: $store.s.target) {
                        Text("Read 1 time").tag(1)
                        Text("Read 3 times").tag(3)
                    }
                    .pickerStyle(.segmented).labelsHidden().frame(maxWidth: 320)
                    Text("Listening always counts as the worst-case minimum.")
                        .font(.footnote).foregroundStyle(.secondary)
                }
                .card()
                VStack(alignment: .leading, spacing: 10) {
                    Text("Appearance").font(.headline)
                    Picker("", selection: $store.s.appearance) {
                        Text("System").tag(0); Text("Light").tag(1); Text("Dark").tag(2)
                    }
                    .pickerStyle(.segmented).labelsHidden().frame(maxWidth: 320)
                }
                .card()
                VStack(alignment: .leading, spacing: 10) {
                    Text("Reminders").font(.headline)
                    Toggle("Daily reminder", isOn: $store.s.remindDaily)
                    Stepper("Hour: \(store.s.remindHour)", value: $store.s.remindHour, in: 0...23)
                    Stepper("Minute: \(store.s.remindMinute)", value: $store.s.remindMinute, in: 0...55, step: 5)
                    Toggle("If I miss: 2 days, weekly, monthly, quarterly, 6-month, yearly", isOn: $store.s.remindMissed)
                    Button("Save & schedule") { store.requestAuth(); store.reschedule() }
                        .buttonStyle(.borderedProminent).tint(.teal)
                }
                .card()
                VStack(alignment: .leading, spacing: 6) {
                    Text("About time tracking").font(.headline)
                    Text("Time in app counts only while Kalima Daily is the frontmost app. It is stored on your Mac only.")
                        .font(.callout).foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .card()
            }
            .padding(24)
        }
        .onDisappear { store.reschedule() }
    }
}
