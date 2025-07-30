import SwiftUI
import AppKit
import Foundation

// MARK: - Main App
@main
struct StripeRevenueApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    var body: some Scene { Settings { EmptyView() } }
}

// MARK: - App Delegate
class AppDelegate: NSObject, NSApplicationDelegate {
    var statusItem: NSStatusItem!
    var popover = NSPopover()
    var revenueManager = StripeRevenueManager()
    var timer: Timer?
    
    // MARK: Life‑cycle
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Menubar item
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        if let button = statusItem.button {
            button.title = "Loading…"           // placeholder until first successful fetch
            button.action = #selector(togglePopover)
        }
        
        // Popover
        popover.contentViewController = NSHostingController(rootView: RevenueView(revenueManager: revenueManager))
        popover.behavior = .transient
        
        // Initial fetch + 5‑min refresh timer
        fetchRevenue()
        timer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { _ in self.fetchRevenue() }
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Invalidate timer to avoid any background work after app quit
        timer?.invalidate()
    }
    
    deinit { timer?.invalidate() }
    
    // MARK: UI helpers
    @objc private func togglePopover() {
        guard let button = statusItem.button else { return }
        popover.isShown ? popover.performClose(nil) : popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
    }
    
    /// Update menubar with *Today* and *MTD* values (called only after successful fetch).
    private func updateMenuBarTitle() {
        guard let button = statusItem.button else { return }
        let nf = NumberFormatter(); nf.numberStyle = .currency; nf.currencyCode = "USD"; nf.minimumFractionDigits = 2; nf.maximumFractionDigits = 2
        let today = nf.string(from: NSNumber(value: revenueManager.todayRevenue)) ?? "—"
        let mtd   = nf.string(from: NSNumber(value: revenueManager.monthRevenue)) ?? "—"
        button.title = "\(today) • MTD \(mtd)"
    }
    
    // MARK: Data fetch
    private func fetchRevenue() {
        // If no key yet, prompt user clearly and skip repeated network calls
        guard revenueManager.getAPIKey() != nil else {
            DispatchQueue.main.async { self.statusItem.button?.title = "Set API Key" }
            return
        }
        
        Task {
            let success = await revenueManager.fetchAllRevenue()
            await MainActor.run {
                if success { self.updateMenuBarTitle() }
                else       { self.statusItem.button?.title = "Network Error" }
            }
        }
    }
}

// MARK: - Revenue Popover
struct RevenueView: View {
    @ObservedObject var revenueManager: StripeRevenueManager
    @State private var isLoading = false
    @State private var showSettings = false
    
    var body: some View {
        VStack(spacing: 0) {
            header; Divider(); stats; Divider(); actions
        }
        .frame(width: 300)
        .sheet(isPresented: $showSettings) { SettingsView(revenueManager: revenueManager) }
    }
    
    private var header: some View {
        HStack {
            Text("Stripe Metrics").font(.headline)
            Spacer()
            Button { showSettings = true } label: { Image(systemName: "gear").foregroundColor(.secondary) }
                .buttonStyle(.plain)
        }.padding()
    }
    
    private var stats: some View {
        VStack(spacing: 0) {
            MetricRow(title: "TODAY", label: "Today", amount: revenueManager.todayRevenue)
            MetricRow(title: "WEEK",  label: "This Week", amount: revenueManager.weekRevenue)
            MetricRow(title: "MONTH", label: "This Month (MTD)", amount: revenueManager.monthRevenue)
        }
    }
    
    private var actions: some View {
        HStack {
            Button(action: refresh) { Label("Refresh", systemImage: "arrow.clockwise").foregroundColor(.blue) }
                .buttonStyle(.plain).disabled(isLoading)
            Spacer()
            Button { NSApplication.shared.terminate(nil) } label: { Label("Quit", systemImage: "xmark.circle").foregroundColor(.red) }
                .buttonStyle(.plain)
        }.padding()
    }
    
    private func refresh() {
        isLoading = true
        Task { _ = await revenueManager.fetchAllRevenue(); isLoading = false }
    }
}

// MARK: - Metric Row
struct MetricRow: View {
    let title: String; let label: String; let amount: Double
    
    private static let nf2: NumberFormatter = {
        let nf = NumberFormatter(); nf.numberStyle = .currency; nf.currencyCode = "USD"; nf.minimumFractionDigits = 2; nf.maximumFractionDigits = 2; return nf
    }()
    private static let nf0: NumberFormatter = {
        let nf = NumberFormatter(); nf.numberStyle = .currency; nf.currencyCode = "USD"; nf.minimumFractionDigits = 0; nf.maximumFractionDigits = 0; return nf
    }()
    
    var body: some View {
        let formatted = (title == "TODAY" || title == "WEEK") ? Self.nf2.string(from: NSNumber(value: amount)) : Self.nf0.string(from: NSNumber(value: amount))
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.caption).foregroundColor(.secondary)
                Text(label).font(.system(size: 14, weight: .medium))
            }
            Spacer()
            Text(formatted ?? "—").font(.system(size: 16, weight: .medium))
        }
        .padding(.horizontal).padding(.vertical, 10).background(Color.gray.opacity(0.05))
    }
}

// MARK: - Settings Sheet (unchanged)
struct SettingsView: View {
    @ObservedObject var revenueManager: StripeRevenueManager
    @State private var apiKey = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Stripe Settings").font(.title2).bold()
            apiKeySection; buttons
        }
        .padding().frame(width: 420)
        .onAppear { apiKey = revenueManager.getAPIKey() ?? "" }
    }
    
    private var apiKeySection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("API Key").font(.headline)
            SecureField("sk_live_…", text: $apiKey).textFieldStyle(.roundedBorder)
            Text("Your Stripe secret key is stored securely in Keychain.").font(.caption).foregroundColor(.secondary)
        }
    }
    
    private var buttons: some View {
        HStack {
            Button { revenueManager.deleteAPIKey(); apiKey = ""; dismiss() } label: { Text("Delete Key") }
                .foregroundColor(.red).disabled(revenueManager.getAPIKey() == nil).keyboardShortcut(.delete)
            Spacer()
            Button("Cancel") { dismiss() }.keyboardShortcut(.escape)
            Button("Save") { revenueManager.saveAPIKey(apiKey); dismiss() }
                .keyboardShortcut(.return).disabled(apiKey.isEmpty)
        }
    }
}

// MARK: - Revenue Manager (returns success flag)
class StripeRevenueManager: ObservableObject {
    @Published var todayRevenue: Double = 0
    @Published var weekRevenue: Double = 0
    @Published var monthRevenue: Double = 0 // MTD
    private let keychainKey = "com.prismo.stripe-revenue.apikey"
    
    // Keychain helpers
    func saveAPIKey(_ key: String) {
        let data = key.data(using: .utf8)!; let q: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: keychainKey, kSecValueData as String: data]
        SecItemDelete(q as CFDictionary); SecItemAdd(q as CFDictionary, nil)
    }
    func deleteAPIKey() { let q: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: keychainKey]; SecItemDelete(q as CFDictionary) }
    func getAPIKey() -> String? { let q: [String: Any] = [kSecClass as String: kSecClassGenericPassword, kSecAttrAccount as String: keychainKey, kSecReturnData as String: true]; var r: AnyObject?; return SecItemCopyMatching(q as CFDictionary, &r) == errSecSuccess ? String(data: r as! Data, encoding: .utf8) : nil }
    
    /// Fetch revenue for Today / Week / MTD. Returns `true` on success, `false` on network / decode error.
    @discardableResult
    func fetchAllRevenue() async -> Bool {
        guard let apiKey = getAPIKey(), !apiKey.isEmpty else { return false }
        let cal = Calendar.current; let now = Date()
        let startDay = cal.startOfDay(for: now); let startWeek = cal.dateInterval(of: .weekOfYear, for: now)?.start ?? now; let startMonth = cal.dateInterval(of: .month, for: now)?.start ?? now
        async let today = fetchRevenue(from: startDay,   to: now, apiKey: apiKey)
        async let week  = fetchRevenue(from: startWeek,  to: now, apiKey: apiKey)
        async let month = fetchRevenue(from: startMonth, to: now, apiKey: apiKey)
        do {
            let (t, w, m) = try await (today, week, month)
            await MainActor.run { self.todayRevenue = t; self.weekRevenue = w; self.monthRevenue = m }
            return true
        } catch { return false }
    }
    
    private func fetchRevenue(from start: Date, to end: Date, apiKey: String) async throws -> Double {
        let s = Int(start.timeIntervalSince1970), e = Int(end.timeIntervalSince1970)
        var charges: [StripeCharge] = [], hasMore = true, after: String?
        while hasMore {
            var url = "https://api.stripe.com/v1/charges?created[gte]=\(s)&created[lte]=\(e)&limit=100"; if let a = after { url += "&starting_after=\(a)" }
            guard let u = URL(string: url) else { throw URLError(.badURL) }
            var req = URLRequest(url: u); req.httpMethod = "GET"; req.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
            let (data, _) = try await URLSession.shared.data(for: req)
            let res = try JSONDecoder().decode(StripeChargesResponse.self, from: data)
            charges += res.data; hasMore = res.has_more && !res.data.isEmpty; after = res.data.last?.id
        }
        return charges.filter { $0.status == "succeeded" && !$0.refunded }.reduce(0) { $0 + Double($1.amount) / 100.0 }
    }
}

// MARK: - Stripe Models
struct StripeChargesResponse: Codable { let data: [StripeCharge]; let has_more: Bool }
struct StripeCharge: Codable { let id: String; let amount: Int; let currency: String; let status: String; let refunded: Bool; let created: Int }
