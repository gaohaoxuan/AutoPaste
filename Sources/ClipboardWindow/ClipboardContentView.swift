import SwiftUI
struct ClipboardContentView: View {
    @ObservedObject var history: ClipboardHistory
    let onDismiss: () -> Void
    let onSelect: (ClipboardItem) -> Void
    let onDelete: (ClipboardItem) -> Void
    let onPin: (ClipboardItem) -> Void
    let onClearAll: () -> Void
    let onSettings: () -> Void
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                SearchBarView(text: $history.searchQuery)
                    .frame(height: 28)
                Button(action: onSettings) {
                    Image(systemName: "gearshape").font(.system(size: 12))
                }
                .buttonStyle(.plain).help("设置")
                Button(action: onClearAll) {
                    Image(systemName: "trash").font(.system(size: 12))
                }
                .buttonStyle(.plain).help("清空未固定项")
                .padding(.trailing, 8)
            }
            .padding(.horizontal, 10).padding(.vertical, 8)
            Divider()
            if history.filteredItems.isEmpty { EmptyStateView() }
            else {
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(history.filteredItems) { item in
                            ClipboardItemRow(item: item, onSelect: onSelect, onDelete: onDelete, onPin: onPin)
                            Divider().padding(.leading, 42)
                        }
                    }
                }
            }
        }
        .frame(minWidth: .clipboardWindowWidth, maxWidth: .clipboardWindowWidth)
        .frame(maxHeight: .clipboardWindowMaxHeight)
        .onExitCommand(perform: onDismiss)
    }
}
