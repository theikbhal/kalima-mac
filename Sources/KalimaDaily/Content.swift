import SwiftUI

enum Links {
    static let repo = "https://github.com/theikbhal/kalima-mac"
    static let clone = "git clone https://github.com/theikbhal/kalima-mac.git"
    static let listen = "https://www.youtube.com/results?search_query=4th+kalima+tamjeed+recitation"
}

enum Kalima {
    static let arabic = "لَآ اِلٰهَ اِلَّا اللّٰهُ وَحْدَهٗ لَا شَرِيْكَ لَهٗ لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ يُحْيٖ وَيُمِيْتُ وَهُوَ حَيٌّ لَّا يَمُوْتُ اَبَدًا اَبَدًا ذُوالْجَلَالِ وَالْاِكْرَامِ بِيَدِهِ الْخَيْرُ وَهُوَ عَلٰى كُلِّ شَيْءٍ قَدِيْرٌ"

    static let transliteration = "Laa ilaaha illallaahu wahdahu laa shareeka lah, lahul mulku wa lahul hamd, yuhyee wa yumeetu wa huwa hayyun laa yamootu abadan abadaa, zul jalaali wal ikraam, biyadihil khayr, wa huwa 'alaa kulli shay'in qadeer."

    static let english = "There is no god but Allah alone, He has no partner. His is the dominion and His is all praise. He gives life and causes death, and He is Ever-Living and never dies. Possessor of majesty and honour. In His hand is all good, and He has power over all things."

    static let hinglish = "Allah ke siwa koi ibadat ke laayak nahi, wo akela hai, uska koi shareek nahi. Usi ki badshahi hai aur usi ke liye har tareef. Wohi zindagi deta aur maut deta hai, wo hamesha zinda hai, kabhi nahi marega. Azmat aur ikraam wala hai. Uske haath me hi bhalai hai aur wo har cheez par qadir hai."

    static var all: String {
        "\(arabic)\n\n\(transliteration)\n\n\(english)\n\n\(hinglish)"
    }
}

enum Grade: String {
    case sahih = "Authentic (Sahih / Quran)"
    case hasan = "Graded Hasan"
    case disputed = "Weak / disputed"
    case note = "Note"

    var color: Color {
        switch self {
        case .sahih: return .green
        case .hasan: return .teal
        case .disputed: return .orange
        case .note: return .blue
        }
    }
}

struct Benefit: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let text: String
    let source: String
    let grade: Grade
}

struct HowTo: Identifiable {
    let id = UUID()
    let n: Int
    let title: String
    let text: String
}

struct PromptItem: Identifiable {
    let id = UUID()
    let title: String
    let text: String
}

enum Content {
    static let benefits: [Benefit] = [
        Benefit(icon: "heart.fill", title: "Hearts find rest in remembrance",
                text: "Verily, in the remembrance of Allah do hearts find rest.",
                source: "Quran 13:28", grade: .sahih),
        Benefit(icon: "star.fill", title: "Best of dhikr: La ilaha illallah",
                text: "The Prophet ﷺ said the best remembrance is La ilaha illallah.",
                source: "Sunan at-Tirmidhi 3383; Ibn Majah 3800", grade: .hasan),
        Benefit(icon: "100.circle.fill", title: "100 times a day: big reward + protection",
                text: "Whoever says 'La ilaha illallah wahdahu la sharika lah, lahul mulku wa lahul hamd, wa huwa ala kulli shay'in qadir' 100 times in a day gets the reward of freeing ten slaves, 100 good deeds written, 100 sins erased, and protection from Shaytan that day. These words are the opening part of the 4th Kalima.",
                source: "Sahih al-Bukhari 3293; Sahih Muslim 2691", grade: .sahih),
        Benefit(icon: "checkmark.seal.fill", title: "Dying upon tawheed",
                text: "Whoever dies knowing that there is no god but Allah enters Paradise. Also, whoever's last words are La ilaha illallah enters Paradise.",
                source: "Sahih Muslim 26; Sunan Abi Dawud 3116 (hasan)", grade: .sahih),
        Benefit(icon: "cart.fill", title: "The market dua (very close wording)",
                text: "A narration gives a huge reward for saying words very close to the 4th Kalima, including 'yuhyi wa yumit, wa huwa hayyun la yamut, biyadihil khayr', when entering the market. Scholars differ on its grading: some accept it as hasan, others call it weak. Treat the exact reward numbers with caution.",
                source: "Sunan at-Tirmidhi 3428; Ibn Majah 2235", grade: .disputed),
        Benefit(icon: "number.circle.fill", title: "Why 1 or 3 times?",
                text: "No authentic text fixes 'once' or 'three times' for the 4th Kalima. It is a personal routine to build consistency. Reading once is a pass, three is the complete goal, and listening is the worst-case minimum when you cannot read.",
                source: "App design note", grade: .note),
        Benefit(icon: "book.closed.fill", title: "What is the '4th Kalima'?",
                text: "The six kalimas are a popular teaching format in the Indian subcontinent. The wording of Kalima Tamjeed (glorification) is built from authentic dhikr words, but the numbered set itself is a later teaching compilation, not a single hadith.",
                source: "Educational note", grade: .note)
    ]

    static let howto: [HowTo] = [
        HowTo(n: 1, title: "Open the Today tab", text: "You will see the 4th Kalima in Arabic, transliteration, English and Hinglish. Text is selectable."),
        HowTo(n: 2, title: "Read it with meaning", text: "Read slowly. Tap 'I read it' after each recitation. Your goal is 1 or 3 times (change it in Settings)."),
        HowTo(n: 3, title: "Can't read right now?", text: "Tap 'Listen online' or 'Speak', then 'Listened instead'. This is the worst-case minimum and still protects your streak."),
        HowTo(n: 4, title: "Claim your daily reward", text: "Complete = 15 coins, pass (read once) = 10, listened = 5, plus a streak bonus."),
        HowTo(n: 5, title: "Copy and share", text: "Use the Copy buttons for Arabic, transliteration, English, Hinglish or everything. Share your streak from the Today tab."),
        HowTo(n: 6, title: "Turn on reminders", text: "Settings, then pick a daily time. If you miss, reminders come after 2 days, a week, a month, 3 months, 6 months and a year."),
        HowTo(n: 7, title: "Check Progress", text: "See your streak, 28-day calendar, total time spent in the app, and badges."),
        HowTo(n: 8, title: "Tips", text: "Best after Fajr or Maghrib. Wudu is recommended but not required for dhikr. Learn the meaning, it makes the habit stick.")
    ]

    static let badges: [(Int, String)] = [
        (3, "Starter 🌱"), (7, "Week Warrior 🔥"), (21, "Habit Maker 💪"),
        (40, "40-Day Champion 🏆"), (100, "Century 💯"), (365, "Year of Dhikr 🌙")
    ]

    static let prompts: [PromptItem] = [
        PromptItem(title: "Word-by-word meaning",
                   text: "Explain the Fourth Kalima (Kalima Tamjeed) word by word with Arabic, transliteration and simple meaning. Keep it short. Tell me which parts come from authentic hadith or Quran and which part is a later teaching compilation.\n\nText:\n\(Kalima.arabic)"),
        PromptItem(title: "Pronunciation coach",
                   text: "I am not an Arabic speaker. Break the Fourth Kalima into syllables with simple transliteration, point out the letters I will probably get wrong (like ح خ ع ذ ث), and give me a 5-minute practice drill.\n\nText:\n\(Kalima.arabic)"),
        PromptItem(title: "7-day memorization plan",
                   text: "Make a 7-day plan, 10 minutes a day, to memorize the Fourth Kalima. Split it into small chunks, add revision on each day, and a quick self-test at the end.\n\nText:\n\(Kalima.arabic)"),
        PromptItem(title: "Authentic references",
                   text: "List authentic hadith about La ilaha illallah and dhikr with exact references (collection and number) and grading. Separate sahih, hasan and weak. If you are not sure about a reference, say so instead of guessing."),
        PromptItem(title: "Verify a claim",
                   text: "Is this claim authentic? Claim: [paste here]. Check Quran and hadith sources, name the scholars who graded it, and tell me clearly if it is weak, fabricated or just a popular belief. Say if you are unsure."),
        PromptItem(title: "Teach my child",
                   text: "Explain the Fourth Kalima to an 8-year-old in simple words with one short story or example for each line. Keep it respectful and accurate.\n\nText:\n\(Kalima.arabic)"),
        PromptItem(title: "Daily routine builder",
                   text: "I am a [student/job] and wake up at [time]. Build a realistic daily dhikr routine around Fajr and Maghrib that includes the Fourth Kalima 1 or 3 times, plus a fallback when I am busy (listening only)."),
        PromptItem(title: "Translate the meaning",
                   text: "Translate the meaning of the Fourth Kalima into Telugu, Urdu and Hindi in simple language. Keep the Arabic text above each translation.\n\nText:\n\(Kalima.arabic)"),
        PromptItem(title: "3-minute reflection",
                   text: "Write a 3-minute reflection on the line 'He is Ever-Living and never dies' from the Fourth Kalima, suitable for a Friday gathering. Use only authentic sources and mention them."),
        PromptItem(title: "Fix my missed-days habit",
                   text: "I keep missing my daily Fourth Kalima. Ask me 5 short questions about my day, then give me a recovery plan with a weekly and monthly check-in. Be kind and practical.")
    ]
}
