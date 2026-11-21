import SwiftUI
import AppKit

extension View {
    func card() -> some View {
        self.padding(16).background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 18))
    }
}

func fmtLong(_ s: Int) -> String {
    let h = s / 3600, m = (s % 3600) / 60
    return h > 0 ? "\(h)h \(m)m" : "\(m)m \(s % 60)s"
}

struct LogoMark: View {
    var size: CGFloat = 44
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: size * 0.24)
                .fill(LinearGradient(colors: [Color(red: 0.05, green: 0.20, blue: 0.30),
                                              Color(red: 0.08, green: 0.45, blue: 0.45)],
                                     startPoint: .topLeading, endPoint: .bottomTrailing))
            Circle()
                .stroke(Color(red: 0.95, green: 0.78, blue: 0.35), lineWidth: size * 0.04)
                .frame(width: size * 0.7, height: size * 0.7)
            Text("٤")
                .font(.system(size: size * 0.5, weight: .bold))
                .foregroundStyle(Color.white)
        }
        .frame(width: size, height: size)
    }
}

struct BrandHeader: View {
    var body: some View {
        HStack(spacing: 10) {
            LogoMark(size: 44)
            VStack(alignment: .leading, spacing: 0) {
                Text("Kalima Daily").font(.system(size: 20, weight: .bold, design: .rounded))
                Text("كلمة تمجيد  •  4th Kalima").font(.caption).opacity(0.8)
            }
        }
    }
}

struct AnimatedBackground: View {
    @Environment(\.colorScheme) private var cs
    var body: some View {
        TimelineView(.animation) { tl in
            let t = tl.date.timeIntervalSinceReferenceDate
            ZStack {
                LinearGradient(colors: base, startPoint: .topLeading, endPoint: .bottomTrailing)
                GeometryReader { g in
                    ForEach(0..<6, id: \.self) { i in
                        blob(i: Double(i), t: t, size: g.size)
                    }
                }
            }
        }
        .ignoresSafeArea()
    }

    private var base: [Color] {
        cs == .dark
        ? [Color(red: 0.02, green: 0.07, blue: 0.10), Color(red: 0.03, green: 0.05, blue: 0.08)]
        : [Color(red: 0.90, green: 0.96, blue: 0.97), Color(red: 0.84, green: 0.93, blue: 0.93)]
    }

    private func blob(i: Double, t: Double, size: CGSize) -> some View {
        let x = size.width * (0.5 + 0.4 * sin(t / 6 + i * 1.3))
        let y = size.height * (0.5 + 0.4 * cos(t / 7 + i * 0.9))
        return Circle()
            .fill(Color.teal.opacity(cs == .dark ? 0.16 : 0.2))
            .frame(width: 220 + i * 40, height: 220 + i * 40)
            .blur(radius: 40)
            .position(x: x, y: y)
    }
}

struct StatTile: View {
    let icon: String, title: String, value: String, tint: Color
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.title2).foregroundStyle(tint)
            VStack(alignment: .leading) {
                Text(value).font(.title2.bold().monospacedDigit())
                Text(title).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .card()
    }
}

struct GradeBadge: View {
    let grade: Grade
    var body: some View {
        Text(grade.rawValue)
            .font(.caption2.bold())
            .padding(.horizontal, 8).padding(.vertical, 3)
            .background(grade.color.opacity(0.2), in: Capsule())
            .foregroundStyle(grade.color)
    }
}

struct CopyButton: View {
    let title: String
    let text: String
    @State private var done = false
    var body: some View {
        Button {
            copyToClipboard(text)
            done = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { done = false }
        } label: {
            Label(done ? "Copied ✓" : title, systemImage: done ? "checkmark" : "doc.on.doc")
        }
    }
}
