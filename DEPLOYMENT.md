# CrownPilot Deployment Guide

## Gereksinimler
- Xcode 16+ 
- Apple Developer hesabı (Team ID: YOUR_TEAM_ID)
- XcodeGen (`brew install xcodegen`)
- Transporter (Mac App Store'dan indir)

## Proje Oluştur
```bash
cd /Users/h2o/Projects/mobile/CrownPilot
xcodegen generate
```

## 1. Doğrudan Apple Watch'a Yükleme (Development)

### Ön Koşullar
- iPhone USB ile Mac'e bağlı
- Apple Watch'ta Developer Mode açık (Ayarlar → Gizlilik ve Güvenlik → Geliştirici Modu)
- Watch UDID Apple Developer Portal'da kayıtlı

### Kayıtlı Cihazlar
| Cihaz | UDID | Tür |
|-------|------|-----|
| My Apple Watch | YOUR_WATCH_UDID | Apple Watch Ultra (1st Gen) |
| My iPhone | YOUR_IPHONE_UDID | iPhone 11 |

### Build & Install
```bash
# Build
xcodebuild clean build \
  -project CrownPilot.xcodeproj \
  -scheme "CrownPilot Watch App" \
  -destination 'generic/platform=watchOS' \
  DEVELOPMENT_TEAM=YOUR_TEAM_ID \
  CODE_SIGN_STYLE=Automatic \
  ONLY_ACTIVE_ARCH=NO \
  -allowProvisioningUpdates

# Install
xcrun devicectl device install app \
  --device YOUR_DEVICE_UUID \
  --timeout 120 \
  ~/Library/Developer/Xcode/DerivedData/CrownPilot-*/Build/Products/Debug-watchos/CrownPilot.app
```

## 2. TestFlight / App Store Dağıtım

### Archive Oluştur
```bash
rm -rf ~/Library/Developer/Xcode/DerivedData/CrownPilot-*

xcodebuild \
  -project CrownPilot.xcodeproj \
  -scheme "CrownPilot Watch App" \
  -destination 'generic/platform=watchOS' \
  -archivePath /tmp/CrownPilot.xcarchive \
  archive \
  DEVELOPMENT_TEAM=YOUR_TEAM_ID \
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
watchOS standalone uygulamalar için `altool` CLI desteklemiyor.

**Seçenek A: Transporter App (Önerilen)**
1. Mac App Store'dan "Transporter" indir
2. Transporter'ı aç → Apple ID ile giriş yap
3. `/tmp/CrownPilotExport/CrownPilot.ipa` dosyasını sürükle-bırak
4. "Deliver" tıkla

**Seçenek B: Xcode Organizer**
1. Archive'ı Xcode Organizer'da aç: `open /tmp/CrownPilot.xcarchive`
2. Distribute App → seçenekleri takip et

### TestFlight Tester Ekleme
1. [appstoreconnect.apple.com](https://appstoreconnect.apple.com) → Crown Pilot
2. TestFlight sekmesi → Internal Testing → "+" tıkla
3. Tester e-posta adresi ekle
4. ⚠️ TestFlight 13+ yaş gerektirir

## 3. Kimlik Bilgileri
Kimlik bilgileri `.secrets` dosyasında saklanır (gitignore'da):
```
APPLE_ID=your-apple-id@example.com
APP_SPECIFIC_PASSWORD=<app-specific-password>
TEAM_ID=YOUR_TEAM_ID
BUNDLE_ID=com.hakan.CrownPilot.watchkitapp
```

## App Store Connect Bilgileri
- **App Name**: Crown Pilot
- **Bundle ID**: com.hakan.CrownPilot.watchkitapp
- **Apple ID**: YOUR_APP_ID
- **SKU**: crownpilot

## Sorun Giderme

### "Developer Mode is disabled" hatası
Saatte: Ayarlar → Gizlilik ve Güvenlik → Geliştirici Modu → Aç → Yeniden Başlat

### "Provisioning profile cannot be installed" hatası
1. Apple Developer Portal'da cihaz UDID'sini kaydet
2. Eski profilleri sil: `rm ~/Library/Developer/Xcode/UserData/Provisioning\ Profiles/*.mobileprovision`
3. Clean build: `rm -rf ~/Library/Developer/Xcode/DerivedData/CrownPilot-*`
4. `-allowProvisioningUpdates` ile yeniden build et

### "no DDI" hatası
Saatte Developer Mode açıkken: `xcrun devicectl manage ddis update`
