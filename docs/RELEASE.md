# Phát hành lên Google Play và App Store

Tài liệu này ghi những gì repo đã chuẩn bị sẵn, những việc cần tài khoản và
khoá của chủ dự án, và nội dung nháp cho trang store.

Phí, yêu cầu thử nghiệm và kích thước ảnh do Google và Apple quy định và có
thể thay đổi. Các con số bên dưới cần được đối chiếu lại trên Play Console và
App Store Connect lúc nộp.

## Thông tin chung

| | Android | iOS |
|---|---|---|
| Tên hiển thị | Little Steps / Từng bước nhỏ (theo ngôn ngữ máy) | Little Steps |
| Định danh | `vn.vinh_hoa.little_steps` | `vn.vinh-hoa.little-steps` |
| Phiên bản | 1.0.0 (build 1), lấy từ `version` trong `pubspec.yaml` | như Android |
| Hệ điều hành tối thiểu | Android 7.0 (API 24) | iOS 15.0 |
| Thiết bị | điện thoại, tablet | iPhone, iPad |

Chính sách quyền riêng tư đã có URL công khai, dùng được cho cả hai store:
<https://github.com/meninstack/test-claude-cloud/blob/main/docs/PRIVACY.md>.
Nếu đổi tên repo, GitHub tự chuyển hướng URL cũ, nhưng nên cập nhật lại URL
trên hai store.

## Repo đã chuẩn bị gì

- **Ký bản Android.** `android/app/build.gradle.kts` đọc upload key từ
  `android/key.properties`. Có file này thì bản release được ký bằng upload
  key; không có thì ký bằng debug key để vẫn cài thử được.
- **CI build App Bundle.** Khi repo có đủ bốn secret ở mục Google Play bên
  dưới, CI build thêm `app-release.aab` đã ký và đính kèm dưới tên
  `little-steps-aab`. APK cài thử vẫn được build ở mọi lần chạy.
- **CI build iOS không ký.** Job `ios-build` chạy
  `flutter build ios --release --no-codesign` trên máy macOS của GitHub để
  chứng minh project iOS biên dịch được.
- **Info.plist.** Đã khai báo hai ngôn ngữ (`CFBundleLocalizations`), khai
  báo không dùng mã hoá ngoài loại được miễn
  (`ITSAppUsesNonExemptEncryption`), và có câu giải thích khi xin dùng máy
  ảnh và thư viện ảnh.
- **Quyền Android.** Bản release không xin quyền `INTERNET` và không xin
  quyền nguy hiểm nào.

## Google Play

### Việc chủ dự án cần làm

1. Đăng ký tài khoản Google Play Console (phí một lần, khoảng 25 USD). Tài
   khoản cá nhân mới thường phải chạy closed test với một nhóm người thử
   trong một thời gian trước khi được phát hành chính thức.
2. Tạo upload key. Lệnh này hỏi mật khẩu, bạn tự nhập và tự giữ:

   ```sh
   keytool -genkeypair -v -keystore upload-keystore.jks -storetype JKS -keyalg RSA -keysize 2048 -validity 10000 -alias upload
   ```

   Sao lưu file `upload-keystore.jks` và mật khẩu ở nơi an toàn. Không đưa
   file này vào repo (đã có trong `.gitignore`). Mật khẩu không nên chứa dấu
   `\`, vì file `key.properties` hiểu dấu đó là ký tự đặc biệt.
3. Đưa key vào secret của repo để CI ký được:

   | Secret | Giá trị |
   |---|---|
   | `ANDROID_KEYSTORE_BASE64` | nội dung `upload-keystore.jks` mã hoá base64 |
   | `ANDROID_KEYSTORE_PASSWORD` | mật khẩu của keystore |
   | `ANDROID_KEY_ALIAS` | `upload` |
   | `ANDROID_KEY_PASSWORD` | mật khẩu của key |

   Trên Windows (PowerShell), lệnh đầu đưa file lên, các lệnh sau hỏi giá
   trị:

   ```powershell
   [Convert]::ToBase64String([IO.File]::ReadAllBytes("upload-keystore.jks")) | gh secret set ANDROID_KEYSTORE_BASE64 -R meninstack/test-claude-cloud
   gh secret set ANDROID_KEYSTORE_PASSWORD -R meninstack/test-claude-cloud
   gh secret set ANDROID_KEY_ALIAS -R meninstack/test-claude-cloud
   gh secret set ANDROID_KEY_PASSWORD -R meninstack/test-claude-cloud
   ```

4. Tạo ứng dụng trên Play Console, bật Play App Signing, tải
   `app-release.aab` từ artifact `little-steps-aab` của CI lên.
5. Điền các khai báo ở mục "Khai báo trên store" và nội dung ở mục "Nội dung
   trang store".

Muốn build bản đã ký trên máy riêng: đặt `upload-keystore.jks` vào thư mục
`android/` và tạo `android/key.properties`:

```properties
storeFile=upload-keystore.jks
storePassword=...
keyAlias=upload
keyPassword=...
```

### Mỗi lần phát hành bản mới

Tăng số sau dấu `+` trong `version` của `pubspec.yaml` (ví dụ `1.0.1+2`).
Google Play từ chối bản có số build đã dùng.

## App Store

### Việc chủ dự án cần làm

1. Đăng ký Apple Developer Program (phí hằng năm, khoảng 99 USD).
2. Trong App Store Connect, tạo ứng dụng với bundle ID
   `vn.vinh-hoa.little-steps`.
3. Ký và tải bản build lên. Việc này cần một trong hai:
   - một máy Mac có Xcode: mở `ios/Runner.xcworkspace`, chọn team trong
     Signing & Capabilities, rồi chạy `flutter build ipa --release` và tải
     lên bằng Xcode hoặc Transporter;
   - hoặc cấu hình CI ký bằng App Store Connect API key. Repo chưa có phần
     này; sẽ làm khi có tài khoản.
4. Điền các khai báo và nội dung như bên dưới.

### Chưa làm trong project iOS

- Tên hiển thị dưới icon mới có "Little Steps". Thêm tên tiếng Việt cần file
  `InfoPlist.strings` cho tiếng Việt, phải thêm bằng Xcode.
- Câu giải thích khi xin dùng máy ảnh và thư viện ảnh mới có tiếng Anh.
- Âm thanh trên iOS đang dùng thiết lập mặc định của `audioplayers`. Cần
  nghe thử trên iPhone thật: ứng dụng có tôn trọng nút gạt im lặng không, có
  làm ngắt nhạc đang phát của ứng dụng khác không.
- Ứng dụng chưa từng chạy trên iPhone hay iPad thật.

## Khai báo trên store

Các câu trả lời dưới đây đúng với mã nguồn hiện tại.

| Câu hỏi | Trả lời |
|---|---|
| Ứng dụng có thu thập hoặc chia sẻ dữ liệu người dùng không? | Không. Google Play: Data safety chọn không thu thập, không chia sẻ. App Store: Data Not Collected. |
| Có quảng cáo không? | Không |
| Có mua hàng trong ứng dụng không? | Không |
| Có tài khoản hay đăng nhập không? | Không |
| Có dùng mạng không? | Không |
| Đối tượng | Trẻ nhỏ, dùng cùng ba mẹ. Google Play: chọn nhóm tuổi trẻ em nghĩa là phải theo Families Policy. App Store: có thể chọn Kids Category. |
| Phân loại nội dung | Mọi lứa tuổi (không bạo lực, không nội dung nhạy cảm) |
| Quyền truy cập | Máy ảnh và thư viện ảnh, chỉ khi ba mẹ tạo thẻ từ ảnh; ảnh không rời khỏi máy |
| Liên kết ra ngoài | Không có trong khu vực của bé. Khu vực ba mẹ nằm sau một phép nhân. |

## Nội dung trang store

Bản nháp, sửa tuỳ ý trước khi nộp.

### Tiếng Việt

- **Tên** (tối đa 30 ký tự): Từng bước nhỏ: lịch của bé
- **Mô tả ngắn** (tối đa 80 ký tự): Bảng lịch trình bằng hình cho bé. Miễn
  phí, không quảng cáo, chạy offline.
- **Mô tả đầy đủ**:

  > Từng bước nhỏ giúp bé tự làm các việc hằng ngày theo thứ tự: thức dậy,
  > đánh răng, thay quần áo, soạn cặp, đi ngủ.
  >
  > Ba mẹ xếp các thẻ hình thành một lịch trình. Bé chạm vào thẻ để nghe một
  > nốt nhạc, chạm vào ngôi sao khi làm xong, và nhận một bạn thú mới cho sổ
  > nhãn dán khi hoàn thành cả lịch trình.
  >
  > Dành cho bé
  > • Mỗi việc là một thẻ lớn có hình, số thứ tự và tên
  > • Thanh tiến độ đầy dần theo số sao
  > • 24 bạn thú để sưu tầm
  > • Mỗi sáng bảng việc bắt đầu lại từ đầu
  >
  > Dành cho ba mẹ
  > • 39 thẻ có sẵn: buổi sáng, đi học, ăn uống và vệ sinh, ở nhà và giờ ngủ
  > • Tự tạo thẻ từ ảnh của gia đình
  > • Nhiều lịch trình, kéo để đổi thứ tự các việc
  > • Tiếng Việt và tiếng Anh
  > • Khu vực ba mẹ được khoá bằng một phép nhân
  >
  > Miễn phí hoàn toàn. Không quảng cáo, không mua hàng trong ứng dụng,
  > không tài khoản, không thu thập dữ liệu, không cần mạng. Ảnh và tiến độ
  > chỉ nằm trên máy của bạn.

### Tiếng Anh

- **Name** (30 characters at most): Little Steps: Daily Routines
- **Short description** (80 characters at most): A picture routine chart
  for young children. Free, no ads, works offline.
- **Full description**:

  > Little Steps helps young children get through everyday routines on
  > their own, one step at a time: wake up, brush teeth, get dressed, pack
  > the bag, go to sleep.
  >
  > A grown-up arranges picture cards into a routine. The child taps a card
  > to hear its note, taps the star when the task is done, and meets a new
  > animal friend for the sticker book when the whole routine is finished.
  >
  > For children
  > • Every task is a large card with a picture, a number and a name
  > • A progress bar fills up with every star
  > • 24 animal friends to collect
  > • The board starts fresh every morning
  >
  > For grown-ups
  > • 39 ready-made cards: morning, school, meals and care, home and bedtime
  > • Make your own cards from family photos
  > • Several routines, drag to reorder tasks
  > • English and Vietnamese
  > • The grown-ups' area is locked behind a multiplication question
  >
  > Completely free. No ads, no in-app purchases, no accounts, no data
  > collection, no network needed. Photos and progress stay on your device.

## Ảnh và đồ hoạ cần chuẩn bị

| Thứ | Google Play | App Store |
|---|---|---|
| Icon | 512×512 px | lấy từ bản build |
| Ảnh bìa (feature graphic) | 1024×500 px | không có |
| Ảnh chụp điện thoại | ít nhất 2 ảnh | bắt buộc, theo cỡ màn hình iPhone lớn nhất mà App Store Connect yêu cầu |
| Ảnh chụp tablet | nên có | bắt buộc theo cỡ iPad, vì ứng dụng hỗ trợ iPad |

Ảnh trong `docs/screenshots/` chụp từ bản web: năm ảnh điện thoại còn giao
diện tiếng Anh, và không ảnh nào đúng kích thước store yêu cầu. Cần chụp lại
bằng tiếng Việt và tiếng Anh theo đúng kích thước. Bản icon gốc 1024 px nằm
trong `tool/branding/`, do `tool/make_icon.py` vẽ.

## Kiểm tra trước khi nộp

- [ ] CI xanh trên commit sẽ phát hành
- [ ] Đã cài bản build đó lên điện thoại Android thật và nghe đủ ba loại âm
      thanh: nốt của thẻ, nốt của bạn thú, hồi chuông khi xong lịch trình
- [ ] Đã chạy trên iPhone và iPad thật
- [ ] Đã thử tạo thẻ từ máy ảnh và từ thư viện ảnh trên cả hai hệ điều hành
- [ ] Số build trong `pubspec.yaml` chưa từng dùng trên store
