# CrownPilot Deployment Guide

## Gereksinimler
- Xcode 16+
- Apple Developer hesabi
- XcodeGen (`brew install xcodegen`)
- Transporter (Mac App Store'dan indir)

## Proje Olustur
```bash
cd CrownPilot
xcodegen generate
```

## 1. Dogrudan Apple Watch'a Yukleme (Development)

### On Kosullar
- iPhone USB ile Mac'e bagli
- Apple Watch'ta Developer Mode acik (Ayarlar → Gizlilik ve Guvenlik → Gelistirici Modu)
- Watch UDID Apple Developer Portal'da kayitli

### Build & Install
```bash
# Build
xcodebuild clean build \
  -project CrownPilot.xcodeproj \
  -scheme "CrownPilot Watch App" \
  -destination 'generic/platform=watchOS' \
  DEVELOPMENT_TEAM=<YOUR_TEAM_ID> \
  CODE_SIGN_STYLE=Automatic \
  ONLY_ACTIVE_ARCH=NO \
  -allowProvisioningUpdates

# Cihaz UUID'sini bul
xcrun devicectl list devices

# Install
xcrun devicectl device install app \
  --device <DEVICE_UUID> \
  --timeout 120 \
  ~/Library/Developer/Xcode/DerivedData/CrownPilot-*/Build/Products/Debug-watchos/CrownPilot.app
```

## 2. TestFlight / App Store Dagitim

### Archive Olustur
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/CrownPilot-*

xcodebuild \
  -project CrownPilot.xcodeproj \
  -scheme "CrownPilot Watch App" \
  -destination 'generic/platform=watchOS' \
  -archivePath /tmp/CrownPilot.xcarchive \
  archive \
  DEVELOPMENT_TEAM=<YOUR_TEAM_ID> \
  CODE_SIGN_STYLE=Automatic \
  ONLY_ACTIVE_ARCH=NO \
  SKIP_INSTALL=NO \
  -allowProvisioningUpdates
```

### IPA Export
```bash
cat > /tmp/ExportOptions.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>release-testing</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>destination</key>
    <string>export</string>
</dict>
</plist>
EOF

xcodebuild -exportArchive \
  -archivePath /tmp/CrownPilot.xcarchive \
  -exportPath /tmp/CrownPilotExport \
  -exportOptionsPlist /tmp/ExportOptions.plist \
  -allowProvisioningUpdates
```

### Upload to App Store Connect

**Secenek A: Transporter App (Onerilen)**
1. Mac App Store'dan "Transporter" indir
2. Transporter'i ac → Apple ID ile giris yap
3. `/tmp/CrownPilotExport/CrownPilot.ipa` dosyasini surukle-birak
4. "Deliver" tikla

**Secenek B: Xcode Organizer**
1. Archive'i Xcode Organizer'da ac: `open /tmp/CrownPilot.xcarchive`
2. Distribute App → secenekleri takip et

### TestFlight Tester Ekleme
1. appstoreconnect.apple.com → Crown Pilot
2. TestFlight sekmesi → Internal Testing → "+" tikla
3. Tester e-posta adresi ekle

## 3. Kimlik Bilgileri
Kimlik bilgileri `.secrets` dosyasinda saklanir (gitignore'da):
```
APPLE_ID=<your-apple-id>
APP_SPECIFIC_PASSWORD=<app-specific-password>
TEAM_ID=<your-team-id>
BUNDLE_ID=com.hakan.CrownPilot.watchkitapp
```

## Sorun Giderme

### "Developer Mode is disabled" hatasi
Saatte: Ayarlar → Gizlilik ve Guvenlik → Gelistirici Modu → Ac → Yeniden Baslat

### "Provisioning profile cannot be installed" hatasi
1. Apple Developer Portal'da cihaz UDID'sini kaydet
2. Eski profilleri sil: `rm ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/*.mobileprovision`
3. Clean build: `rm -rf ~/Library/Developer/Xcode/DerivedData/CrownPilot-*`
4. `-allowProvisioningUpdates` ile yeniden build et

### "no DDI" hatasi
Saatte Developer Mode acikken: `xcrun devicectl manage ddis update`
