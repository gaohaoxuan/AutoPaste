import SwiftUI
struct ClipboardItemRow: View {
    let item: ClipboardItem
    let onSelect: (ClipboardItem) -> Void
    let onDelete: (ClipboardItem) -> Void
    let onPin: (ClipboardItem) -> Void
    var body: some View {
        HStack(spacing: 10) {
            typeIcon.frame(width: 20)
            VStack(alignment: .leading, spacing: 2) {
                Text(item.preview.isEmpty ? "(空)" : item.preview)
                    .lineLimit(1).truncationMode(.tail).font(.system(size: 13))
                Text(item.timestamp, style: .time)
                    .font(.system(size: 10)).foregroundColor(.secondary)
            }
            Spacer()
            if item.isPinned {
                Image(systemName: "pin.fill").font(.system(size: 11)).foregroundColor(.accentColor)
            }
            Button(action: { onDelete(item) }) {
                Image(systemName: "xmark.circle.fill").font(.system(size: 13)).foregroundColor(.secondary)
            }
            .buttonStyle(.plain).help("删除")
        }
        .padding(.horizontal, 12).padding(.vertical, 6)
        .frame(height: .clipboardItemRowHeight)
        .contentShape(Rectangle())
        .onTapGesture { onSelect(item) }
        .contextMenu {
            Button(action: { onPin(item) }) {
                Label(item.isPinned ? "取消固定" : "固定", systemImage: item.isPinned ? "pin.slash" : "pin")
            }
            Divider()
            Button(role: .destructive, action: { onDelete(item) }) {
                Label("删除", systemImage: "trash")
            }
        }
    }
    @ViewBuilder private var typeIcon: some View {
        switch item.type {
        case .text: Image(systemName: "doc.text").foregroundColor(.blue)
        case .image:
            if let d = item.data, let ns = NSImage(data: d) {
                Image(nsImage: ns).resizable().aspectRatio(contentMode: .fill)
                    .frame(width: 20, height: 20).clipShape(RoundedRectangle(cornerRadius: 3))
            } else { Image(systemName: "photo").foregroundColor(.purple) }
        case .html: Image(systemName: "chevron.left.forwardslash.chevron.right").foregroundColor(.orange)
        case .file: Image(systemName: "doc").foregroundColor(.green)
        }
    }
}
