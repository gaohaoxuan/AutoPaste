APP_NAME := Paste
BUILD_DIR := .build/release
APP_BUNDLE := $(BUILD_DIR)/$(APP_NAME).app
DMG_NAME := $(APP_NAME).dmg
DMG_DIR := $(BUILD_DIR)/dmg
ICNS := /tmp/Paste.icns
INSTALL_PATH := /Applications/$(APP_NAME).app
.PHONY: build install dmg clean run
build:
	swift build -c release
clean:
	swift package clean; rm -rf $(BUILD_DIR); rm -f $(DMG_NAME)
run: build
	open $(APP_BUNDLE)
$(ICNS): AppIcon.png
	@echo "🎨 生成图标..."
	rm -rf /tmp/Paste.iconset; mkdir -p /tmp/Paste.iconset
	sips -z 16 16 AppIcon.png --out /tmp/Paste.iconset/icon_16x16.png >/dev/null
	sips -z 32 32 AppIcon.png --out /tmp/Paste.iconset/icon_16x16@2x.png >/dev/null
	sips -z 32 32 AppIcon.png --out /tmp/Paste.iconset/icon_32x32.png >/dev/null
	sips -z 64 64 AppIcon.png --out /tmp/Paste.iconset/icon_32x32@2x.png >/dev/null
	sips -z 128 128 AppIcon.png --out /tmp/Paste.iconset/icon_128x128.png >/dev/null
	sips -z 256 256 AppIcon.png --out /tmp/Paste.iconset/icon_128x128@2x.png >/dev/null
	sips -z 256 256 AppIcon.png --out /tmp/Paste.iconset/icon_256x256.png >/dev/null
	sips -z 512 512 AppIcon.png --out /tmp/Paste.iconset/icon_256x256@2x.png >/dev/null
	sips -z 512 512 AppIcon.png --out /tmp/Paste.iconset/icon_512x512.png >/dev/null
	sips -z 1024 1024 AppIcon.png --out /tmp/Paste.iconset/icon_512x512@2x.png >/dev/null
	iconutil -c icns /tmp/Paste.iconset -o $(ICNS); rm -rf /tmp/Paste.iconset
bundle: build $(ICNS)
	@echo "📦 组装 $(APP_NAME).app..."
	rm -rf $(APP_BUNDLE)
	mkdir -p $(APP_BUNDLE)/Contents/MacOS $(APP_BUNDLE)/Contents/Resources
	cp $(BUILD_DIR)/$(APP_NAME) $(APP_BUNDLE)/Contents/MacOS/
	cp Info.plist $(APP_BUNDLE)/Contents/
	cp $(ICNS) $(APP_BUNDLE)/Contents/Resources/AppIcon.icns
	/usr/libexec/PlistBuddy -c "Add :CFBundleIconFile string AppIcon" $(APP_BUNDLE)/Contents/Info.plist 2>/dev/null; /usr/libexec/PlistBuddy -c "Set :CFBundleIconFile AppIcon" $(APP_BUNDLE)/Contents/Info.plist 2>/dev/null; true
	codesign --force --deep --sign - $(APP_BUNDLE)
	@echo "✅ 组装完成"
install: bundle
	@echo "📥 安装到 $(INSTALL_PATH)..."
	killall $(APP_NAME) 2>/dev/null || true
	rm -rf $(INSTALL_PATH)
	cp -R $(APP_BUNDLE) $(INSTALL_PATH)
	@echo "✅ 安装完成。启动: make run"
dmg: bundle
	@echo "💿 制作 DMG..."
	rm -rf $(DMG_DIR); mkdir -p $(DMG_DIR)
	cp -R $(APP_BUNDLE) $(DMG_DIR)/
	ln -s /Applications $(DMG_DIR)/Applications
	hdiutil create -volname "$(APP_NAME)" -srcfolder $(DMG_DIR) -ov -format UDZO $(DMG_NAME) 2>/dev/null
	rm -rf $(DMG_DIR)
	@echo "✅ DMG: $(DMG_NAME)"
all: install
