// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Từng bước nhỏ';

  @override
  String get commonCancel => 'Hủy';

  @override
  String get commonSave => 'Lưu';

  @override
  String get commonDelete => 'Xóa';

  @override
  String get commonDone => 'Xong';

  @override
  String get commonContinue => 'Tiếp tục';

  @override
  String get stickerBook => 'Sổ nhãn dán';

  @override
  String stickerBookProgress(int owned, int total) {
    return '$owned/$total bạn thú';
  }

  @override
  String get stickerLocked => 'Làm xong một lịch trình để gặp bạn này';

  @override
  String totalStars(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sao',
      zero: 'Chưa có sao',
    );
    return '$_temp0';
  }

  @override
  String get parentArea => 'Ba mẹ';

  @override
  String progressLabel(int done, int total) {
    return '$done/$total';
  }

  @override
  String get childEmptyRoutine => 'Chưa có việc nào. Nhờ ba mẹ thêm nhé!';

  @override
  String get childNoRoutines => 'Chưa có lịch trình. Nhờ ba mẹ tạo nhé!';

  @override
  String semanticMarkDone(String name) {
    return 'Đánh dấu đã xong $name';
  }

  @override
  String semanticMarkNotDone(String name) {
    return 'Đánh dấu chưa xong $name';
  }

  @override
  String get celebrateTitle => 'Giỏi lắm!';

  @override
  String get celebrateBody => 'Con đã làm xong hết rồi!';

  @override
  String get celebrateNewSticker => 'Một bạn mới đã vào sổ nhãn dán của con!';

  @override
  String get celebrateAllCollected => 'Con đã gặp đủ tất cả các bạn!';

  @override
  String get celebrateButton => 'Tuyệt!';

  @override
  String get gateTitle => 'Dành cho ba mẹ';

  @override
  String gateQuestion(int a, int b) {
    return '$a × $b bằng bao nhiêu?';
  }

  @override
  String get gateAnswerLabel => 'Đáp án';

  @override
  String get gateWrong => 'Chưa đúng. Thử lại nhé.';

  @override
  String get parentTitle => 'Khu vực ba mẹ';

  @override
  String get tabRoutines => 'Lịch trình';

  @override
  String get tabMyCards => 'Thẻ của tôi';

  @override
  String get tabSettings => 'Cài đặt';

  @override
  String get presetMorning => 'Buổi sáng';

  @override
  String get presetEvening => 'Buổi tối';

  @override
  String get newRoutine => 'Lịch trình mới';

  @override
  String taskCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count việc',
      zero: 'Chưa có việc',
    );
    return '$_temp0';
  }

  @override
  String get editRoutine => 'Sửa lịch trình';

  @override
  String get routineNameLabel => 'Tên lịch trình';

  @override
  String get routineIconLabel => 'Biểu tượng';

  @override
  String get tasksHeader => 'Các việc';

  @override
  String get addCards => 'Thêm thẻ';

  @override
  String get reorderHint => 'Kéo tay nắm để đổi thứ tự.';

  @override
  String get removeTask => 'Gỡ';

  @override
  String get deleteRoutine => 'Xóa lịch trình';

  @override
  String deleteRoutineConfirm(String name) {
    return 'Xóa “$name”? Không thể hoàn tác.';
  }

  @override
  String get editorEmptyRoutine =>
      'Chưa có việc nào. Chạm “Thêm thẻ” để bắt đầu.';

  @override
  String get pickCards => 'Chọn thẻ';

  @override
  String get groupMorning => 'Buổi sáng';

  @override
  String get groupSchool => 'Đi học';

  @override
  String get groupCare => 'Ăn uống & vệ sinh';

  @override
  String get groupHome => 'Ở nhà & giờ ngủ';

  @override
  String get groupCustom => 'Thẻ của tôi';

  @override
  String get pickerNoCustomCards =>
      'Bạn chưa tạo thẻ nào. Hãy tạo trong mục “Thẻ của tôi”.';

  @override
  String get newCard => 'Thẻ mới';

  @override
  String get cardNameLabel => 'Tên thẻ';

  @override
  String get takePhoto => 'Chụp ảnh';

  @override
  String get choosePhoto => 'Chọn ảnh';

  @override
  String get cardNeedsPhoto => 'Hãy thêm ảnh trước.';

  @override
  String get cardNeedsName => 'Hãy nhập tên.';

  @override
  String get photoError => 'Không tải được ảnh này.';

  @override
  String get deleteCard => 'Xóa thẻ';

  @override
  String deleteCardConfirm(String name) {
    return 'Xóa “$name”? Thẻ sẽ bị gỡ khỏi mọi lịch trình.';
  }

  @override
  String get myCardsEmpty => 'Tự tạo thẻ bằng ảnh và tên.';

  @override
  String get settingsLanguage => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Theo máy';

  @override
  String get settingsSound => 'Phát âm thanh';

  @override
  String get settingsResetToday => 'Đặt lại tiến độ hôm nay';

  @override
  String get settingsResetConfirm => 'Xóa mọi ngôi sao đã nhận hôm nay?';

  @override
  String get settingsResetDone => 'Đã đặt lại tiến độ hôm nay.';

  @override
  String get settingsPrivacyTitle => 'Quyền riêng tư';

  @override
  String get settingsPrivacyBody =>
      'Ứng dụng không thu thập dữ liệu. Ảnh và tiến độ chỉ nằm trên máy này.';

  @override
  String get settingsLicenses => 'Giấy phép và ghi công';
}
