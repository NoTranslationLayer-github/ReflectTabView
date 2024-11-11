import PlaygroundSupport
import SwiftUI

// MARK: - Tab Option

enum TabOption: String, CaseIterable, Identifiable, Codable {
    case reflect = "Reflect"
    case plots = "Plots"
    case experiments = "Experiments"
    case insights = "Insights"
    case history = "History"
    case goals = "Goals"
    case metrics = "Metrics"
    case events = "Events"
    case reports = "Reports"
    case timers = "Timers"
    case tabSelection = "Edit"
    
    var id: String { rawValue }
    
    var icon: String {
        switch self {
        case .reflect: return "menucard.fill"
        case .plots: return "chart.xyaxis.line"
        case .experiments: return "testtube.2"
        case .insights: return "lightbulb.fill"
        case .history: return "clock"
        case .goals: return "target"
        case .metrics: return "compass.drawing"
        case .events: return "calendar.badge.plus"
        case .reports: return "chart.line.uptrend.xyaxis"
        case .timers: return "stopwatch"
        case .tabSelection: return "rectangle.stack.badge.plus"
        }
    }
}

// MARK: - Tab Item

struct TabItem: View {
    let tab: TabOption
    let isSelected: Bool
    let iconSize: CGFloat
    let indicatorWidth: CGFloat
    let indicatorHeight: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // Icon container
                ZStack(alignment: .center) {
                    VStack(spacing: 0) {
                        Spacer()
                            .frame(height: 14)
                        Image(systemName: tab.icon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: iconSize)
                            .symbolVariant(isSelected ? .fill : .none)
                            .opacity(isSelected ? 1.0 : 0.5)
                        Spacer()
                    }
                    .frame(height: 34)
                }
                
                // Text below icon
                Text(tab.rawValue)
                    .font(.caption)
                    .foregroundColor(isSelected ? .primary : .secondary)
                    .lineLimit(1)
                Color.clear
                    .frame(height: 12)
            }
            // Indicator
            Rectangle()
                .frame(width: indicatorWidth, height: indicatorHeight)
                .foregroundStyle(isSelected ? .blue : .clear)
                .shadow(
                    color: isSelected ? .blue.opacity(0.5) : .clear,
                    radius: 5,
                    x: 0,
                    y: -1
                ).padding(.bottom, 3)
        }
        .contentShape(Rectangle())
    }
}

// MARK: - Custom Tab Bar

struct CustomTabBar: View {
    var tabs: [TabOption]
    var selectedTab: TabOption
    var onTabTapped: (TabOption) -> Void
    
    // Fixed measurements
    private let tabItemWidth: CGFloat = 70
    private let contentHeight: CGFloat = 64
    private let indicatorWidth: CGFloat = 32
    private let indicatorHeight: CGFloat = 3
    private let iconSize: CGFloat = 20
    private let capsulePadding: CGFloat = 16
    
    private func totalRequiredWidth(tabCount: Int) -> CGFloat {
        let tabsWidth = CGFloat(tabCount) * tabItemWidth
        let spacingWidth = CGFloat(tabCount - 1) * 8.0
        return tabsWidth + spacingWidth + (capsulePadding * 2)
    }
    
    var body: some View {
        GeometryReader { geometry in
            let requiredWidth = totalRequiredWidth(tabCount: tabs.count)
            let shouldScroll = requiredWidth > geometry.size.width
            
            ZStack(alignment: .top) {
                // Background that extends to bottom of screen with rounded corners
                VStack(spacing: 0) {
                    // Top border line
                    Color(UIColor.systemGray5)
                        .frame(height: 0.5)
                    
                    Rectangle()
                        .fill(.ultraThinMaterial)
                }
                .ignoresSafeArea(edges: .bottom)
                
                // Fixed height content area
                VStack(spacing: 0) {
                    let content = HStack(spacing: shouldScroll ? 8 : nil) {
                        ForEach(Array(zip(tabs.indices, tabs)), id: \.1) { index, tab in
                            if !shouldScroll && index > 0 {
                                Spacer()
                            }
                            
                            TabItem(
                                tab: tab,
                                isSelected: selectedTab == tab,
                                iconSize: iconSize,
                                indicatorWidth: indicatorWidth,
                                indicatorHeight: indicatorHeight
                            )
                            .frame(width: tabItemWidth)
                            .id(tab)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.3)) {
                                    onTabTapped(tab)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, capsulePadding)
                    
                    if shouldScroll {
                        ScrollViewReader { proxy in
                            ScrollView(.horizontal, showsIndicators: false) {
                                content
                            }
                            .frame(height: contentHeight)
                            .onChange(of: selectedTab) { newTab in
                                withAnimation {
                                    proxy.scrollTo(newTab, anchor: .center)
                                }
                            }
                            .mask(
                                HStack(spacing: 0) {
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: .clear, location: 0),
                                            .init(color: .white, location: 1)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .frame(width: capsulePadding * 2)
                                    
                                    Rectangle()
                                    
                                    LinearGradient(
                                        gradient: Gradient(stops: [
                                            .init(color: .white, location: 0),
                                            .init(color: .clear, location: 1)
                                        ]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                    .frame(width: capsulePadding * 2)
                                }
                            )
                        }
                    } else {
                        content
                            .frame(height: contentHeight)
                    }
                }
                .frame(height: contentHeight)
            }
        }
        .frame(height: contentHeight + 0.5)
    }
}

// MARK: - Demo Content View

struct ContentView: View {
    @StateObject private var tabManager = TabManager()
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                TabView(selection: $tabManager.selectedTab) {
                    ForEach(tabManager.tabsToCache, id: \.self) { tab in
                        TabContentView(tab: tab, tabManager: tabManager)
                            .tag(tab)
                    }
                }
                .edgesIgnoringSafeArea(.bottom)
                .onChange(of: tabManager.selectedTab) { newTab in
                    tabManager.updatetabsToCache(for: newTab)
                }
                
                CustomTabBar(
                    tabs: TabOption.allCases,
                    selectedTab: tabManager.selectedTab,
                    onTabTapped: { tab in
                        withAnimation {
                            tabManager.selectedTab = tab
                        }
                    }
                )
            }
            .ignoresSafeArea(.keyboard)
        }
    }
}

class TabManager: ObservableObject {
    @Published var tabsToCache: [TabOption] = []
    @Published var selectedTab: TabOption = .reflect
    
    let defaultTabs: [TabOption] = [.reflect, .plots, .experiments, .insights]
    private var lastNonDefaultTab: TabOption?
    
    init() {
        // Initialize tabs to show with default tabs
        tabsToCache = Array(defaultTabs.prefix(4))
    }
    
    func updatetabsToCache(for newTab: TabOption) {
        // Check if the newTab is one of the default tabs
        if defaultTabs.contains(newTab) {
            // Update tabsToCache with default tabs, keeping lastNonDefaultTab if available
            tabsToCache = defaultTabs
            if let lastTab = lastNonDefaultTab, tabsToCache.count < 5 {
                tabsToCache.append(lastTab)
            }
        } else {
            // If newTab is not a default tab, add it as the 5th tab and store it as lastNonDefaultTab
            if !tabsToCache.contains(newTab) {
                if tabsToCache.count >= 5 {
                    tabsToCache.removeLast()
                }
                tabsToCache.append(newTab)
            }
            lastNonDefaultTab = newTab
        }
    }
}

struct TabContentView: View {
    let tab: TabOption
    @ObservedObject var tabManager: TabManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Spacer()
                
                Text(tab.rawValue)
                    .font(.largeTitle)
                
                VStack(alignment: .leading, spacing: 10) {
                    Text("Current TabView Tabs:")
                        .font(.headline)
                    ForEach(tabManager.tabsToCache, id: \.self) { tab in
                        Text("• \(tab.rawValue)")
                            .foregroundColor(.secondary)
                    }
                }
                .font(.system(.body, design: .monospaced))
                
                Spacer()
            }
            .padding()
        }
    }
}

// MARK: - Playground Configuration

let hostingController = UIHostingController(rootView: ContentView())
hostingController.view.frame = CGRect(x: 0, y: 0, width: 375, height: 667)
hostingController.view.backgroundColor = .systemBackground
PlaygroundPage.current.liveView = hostingController
