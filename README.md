# Little Steps · Từng bước nhỏ

Bảng lịch trình hằng ngày bằng hình ảnh cho trẻ nhỏ, dùng trên điện thoại và
tablet. Ba mẹ xếp các thẻ hình ("Thức dậy", "Đánh răng", "Soạn cặp"); trẻ
chạm vào thẻ để nghe một nốt nhạc, chạm vào ngôi sao khi làm xong, và nhận
một nhãn dán con vật khi hoàn thành cả lịch trình.

Miễn phí, chạy offline, không quảng cáo, không mua hàng trong ứng dụng,
không tài khoản, không thu thập dữ liệu.

| Bảng việc | Phần thưởng | Sổ nhãn dán | Sửa lịch trình | Chọn thẻ |
|---|---|---|---|---|
| ![Bảng việc trên điện thoại](docs/screenshots/phone-board.png) | ![Màn hình chúc mừng](docs/screenshots/phone-celebration.png) | ![Sổ nhãn dán](docs/screenshots/phone-stickers.png) | ![Màn hình sửa lịch trình](docs/screenshots/phone-editor.png) | ![Màn hình chọn thẻ](docs/screenshots/phone-picker.png) |

![Bảng việc trên tablet, giao diện tiếng Việt](docs/screenshots/tablet-board.png)

## Ứng dụng làm được gì

**Dành cho trẻ**

- Mỗi việc là một thẻ lớn, xếp theo thứ tự, có số, hình và tên.
- Chạm vào thẻ để nghe nốt nhạc riêng của thẻ đó. Chạm vào ngôi sao của thẻ
  để đánh dấu đã xong.
- Thanh tiến độ đầy dần theo số sao trẻ nhận được.
- Làm xong một lịch trình, trẻ được chúc mừng bằng một hồi chuông và có thêm
  một bạn thú mới trong sổ nhãn dán (có 24 bạn để sưu tầm). Chạm vào bạn thú
  đã có để nghe nốt chuông của bạn ấy.
- Mỗi sáng, bảng việc bắt đầu lại từ đầu.

**Dành cho ba mẹ** (phải trả lời một phép nhân mới vào được)

- Nhiều lịch trình, mỗi lịch trình có tên và biểu tượng riêng. Buổi sáng và
  Buổi tối có sẵn từ đầu.
- 39 thẻ có sẵn, chia thành bốn nhóm: buổi sáng, đi học, ăn uống và vệ sinh,
  ở nhà và giờ ngủ.
- Tự tạo thẻ từ một tấm ảnh và một cái tên.
- Kéo để đổi thứ tự các việc.
- Tiếng Việt và tiếng Anh, đổi được ngay trong ứng dụng.
- Bật hoặc tắt âm thanh trong phần cài đặt.

## Những quyết định đáng chú ý

- **Nghe nốt nhạc và đánh dấu xong là hai vùng chạm riêng.** Thẻ thì phát
  nốt, ngôi sao thì đánh dấu xong. Trẻ chạm chơi với thẻ "Đánh răng" sẽ không
  lỡ tay đánh dấu việc đó là đã xong.
- **Mỗi lịch trình chỉ cho một nhãn dán mỗi ngày.** Bỏ đánh dấu rồi đánh dấu
  lại việc cuối cùng không sinh thêm nhãn dán, và không có cách nào nhận
  nhãn dán mà không làm hết lịch trình.
- **Âm thanh là nốt nhạc, không phải giọng đọc.** Giọng text-to-speech của
  thiết bị đọc tiếng Việt không đạt, còn thẻ ba mẹ tự tạo thì không thể có
  giọng thu sẵn. Vì vậy mỗi thẻ phát một nốt đàn gỗ cố định của riêng nó,
  mỗi bạn thú phát một nốt chuông, và làm xong lịch trình thì có một hồi
  chuông. Các nốt thuộc cùng một thang âm nên chạm theo thứ tự nào nghe cũng
  êm tai, và không phụ thuộc ngôn ngữ.
- **Không có gì rời khỏi thiết bị.** Không backend, không analytics SDK,
  không ad SDK. Ảnh của thẻ tự tạo được lưu trong thư mục riêng của ứng
  dụng. Xem [chính sách quyền riêng tư](docs/PRIVACY.md).
- **Một bố cục, ba hình dạng.** Màn hình hẹp hơn 600 px: bảng việc là một
  danh sách các hàng. Từ 600 px trở lên: một lưới các ô cao. Từ 840 px: các
  lịch trình chuyển từ dải ngang phía trên sang cột bên cạnh.

## Cấu trúc mã nguồn

Flutter 3.50 (Dart 3.14), một codebase cho Android, iOS và web.

```
lib/
  main.dart               mở bộ lưu trữ, khởi động ứng dụng
  app.dart                MaterialApp, locale, sang ngày mới khi mở lại ứng dụng
  core/                   theme, breakpoint, đồng hồ, id, giấy phép
  data/
    models.dart           Routine, RoutineItem, CustomCard, DayProgress, AppData
    card_catalog.dart     thẻ có sẵn, biểu tượng lịch trình, nhãn dán
    app_repository.dart   AppData <-> một tài liệu JSON trong key-value storage
    image_store*.dart     ảnh: file trên điện thoại, bộ nhớ trình duyệt trên web
  state/
    app_controller.dart   mọi quy tắc của ứng dụng, gói trong một Riverpod Notifier
    providers.dart        đồng hồ, số ngẫu nhiên, lưu trữ, âm thanh (thay thế được)
  services/               phát âm thanh, chọn ảnh
  features/child/         bảng việc, ô việc, chúc mừng, sổ nhãn dán
  features/parent/        cổng ba mẹ, lịch trình, sửa lịch trình, chọn thẻ, thẻ tự tạo, cài đặt
  l10n/                   app_en.arb, app_vi.arb (+ mã sinh tự động)
```

- **State**: `flutter_riverpod`. `AppController` giữ một `AppData` bất biến
  và lưu lại sau mỗi thay đổi. Thời gian, số ngẫu nhiên, lưu trữ và âm
  thanh đều là provider, nên test thay chúng bằng bản giả được.
- **Lưu trữ**: `shared_preferences` giữ một tài liệu JSON nhỏ (các lịch
  trình, tên thẻ, tiến độ của một ngày). Ảnh là các file riêng.
- **Hình vẽ**: SVG của [Twemoji](https://github.com/jdecked/twemoji), hiển
  thị bằng `flutter_svg`. `tool/asset_map.json` cho biết file nào ứng với
  emoji nào.
- **Icon**: do `tool/make_icon.py` vẽ; script này cũng xuất mọi kích thước
  icon cho Android, iOS và web.
- **Âm thanh**: do `tool/make_notes.py` tổng hợp (hai bộ 8 nốt và một hồi
  chuông trong `assets/sounds/`), phát bằng `audioplayers`.

## Chạy ứng dụng

```sh
flutter pub get
flutter run                 # điện thoại, tablet hoặc emulator đang kết nối
flutter run -d chrome       # trong trình duyệt
flutter test                # 63 unit test và widget test
```

CI (`.github/workflows/ci.yml`) kiểm tra định dạng mã, chạy analyze, chạy
test và build một APK bản release, đính kèm vào lần chạy dưới dạng artifact
tải về được. CI cũng build iOS ở dạng không ký và kiểm tra `pubspec.lock`
còn khớp với `pubspec.yaml`.

## Test

`test/app_controller_test.dart` kiểm tra các quy tắc: ngôi sao, quy tắc mỗi
ngày một nhãn dán, đặt lại khi sang ngày mới, sửa lịch trình, thẻ tự tạo và
việc lưu dữ liệu. `test/app_flow_test.dart` chạy giao diện thật: bảng việc,
màn hình chúc mừng, cổng ba mẹ, màn hình sửa lịch trình (cả kéo để đổi thứ
tự), chọn thẻ, tạo thẻ từ ảnh, đổi ngôn ngữ, và bố cục trên năm kích thước
màn hình, từ điện thoại 320 px tới tablet nằm ngang.
`test/app_repository_test.dart` kiểm tra việc lưu trữ, kể cả khi dữ liệu bị
hỏng. `test/sound_service_test.dart` kiểm tra mỗi thẻ và mỗi bạn thú luôn
phát đúng một nốt cố định, và mọi file âm thanh đều có trong ứng dụng.

## Tình trạng

Đây là bản MVP đầu tiên. Bản web đã được chạy thử từ đầu đến cuối trên
Chrome. Một bản APK do CI build đã được cài và mở trên điện thoại Android
thật. Project iOS được CI build ở dạng không ký, nhưng chưa chạy trên iPhone
hay iPad thật.

Chưa có trong bản này: đồng hồ đếm ngược cho từng việc, nhắc nhở, hồ sơ cho
nhiều trẻ, và lịch sử theo tuần.

Các bước đưa ứng dụng lên Google Play và App Store nằm trong
[docs/RELEASE.md](docs/RELEASE.md).

## Ghi công

- Hình vẽ của thẻ, biểu tượng và nhãn dán: Twemoji, © Twitter, Inc và những
  người đóng góp khác,
  [CC-BY 4.0](https://creativecommons.org/licenses/by/4.0/).
- Font: Nunito, © The Nunito Project Authors,
  [SIL Open Font License 1.1](assets/fonts/OFL.txt).
- Âm thanh: được tổng hợp riêng cho dự án này bằng `tool/make_notes.py`.

Bảng lịch trình bằng thẻ hình ("visual schedule") là công cụ có từ lâu trong
giáo dục mầm non. Ứng dụng này là một bản hiện thực độc lập của ý tưởng đó:
tên, mã nguồn, bố cục và icon đều được làm riêng cho dự án này.
