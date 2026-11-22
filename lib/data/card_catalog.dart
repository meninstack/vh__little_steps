/// Built-in content: task cards, routine icons and collectible stickers.
///
/// Artwork is Twemoji (CC-BY 4.0), copied into `assets/` under these ids.
/// `tool/asset_map.json` records which emoji each file came from, and
/// `tool/fetch_twemoji.py` downloads the files for new ids.
library;

/// The tabs of the card picker, in order. Each group has its own card colour.
enum CardGroup { morning, school, care, home, outside, manners }

class BuiltInCard {
  const BuiltInCard(this.id, this.group, {required this.en, required this.vi});

  final String id;
  final CardGroup group;
  final String en;
  final String vi;

  String get asset => 'assets/cards/$id.svg';

  String label(String languageCode) => languageCode == 'vi' ? vi : en;
}

const List<BuiltInCard> builtInCards = [
  // Morning
  BuiltInCard('wake_up', CardGroup.morning, en: 'Wake up', vi: 'Thức dậy'),
  BuiltInCard(
    'make_bed',
    CardGroup.morning,
    en: 'Make the bed',
    vi: 'Dọn giường',
  ),
  BuiltInCard(
    'toilet',
    CardGroup.morning,
    en: 'Use the toilet',
    vi: 'Đi vệ sinh',
  ),
  BuiltInCard(
    'brush_teeth',
    CardGroup.morning,
    en: 'Brush teeth',
    vi: 'Đánh răng',
  ),
  BuiltInCard('wash_face', CardGroup.morning, en: 'Wash face', vi: 'Rửa mặt'),
  BuiltInCard(
    'get_dressed',
    CardGroup.morning,
    en: 'Get dressed',
    vi: 'Thay quần áo',
  ),
  BuiltInCard('comb_hair', CardGroup.morning, en: 'Comb hair', vi: 'Chải tóc'),
  BuiltInCard(
    'breakfast',
    CardGroup.morning,
    en: 'Eat breakfast',
    vi: 'Ăn sáng',
  ),
  BuiltInCard(
    'drink_milk',
    CardGroup.morning,
    en: 'Drink milk',
    vi: 'Uống sữa',
  ),
  BuiltInCard(
    'open_curtains',
    CardGroup.morning,
    en: 'Open the curtains',
    vi: 'Mở rèm cửa',
  ),
  BuiltInCard(
    'put_on_socks',
    CardGroup.morning,
    en: 'Put on socks',
    vi: 'Mang vớ',
  ),
  BuiltInCard(
    'look_in_mirror',
    CardGroup.morning,
    en: 'Look in the mirror',
    vi: 'Soi gương',
  ),
  // School
  BuiltInCard('pack_bag', CardGroup.school, en: 'Pack my bag', vi: 'Soạn cặp'),
  BuiltInCard(
    'put_on_shoes',
    CardGroup.school,
    en: 'Put on shoes',
    vi: 'Mang giày',
  ),
  BuiltInCard('wear_hat', CardGroup.school, en: 'Put on a hat', vi: 'Đội mũ'),
  BuiltInCard(
    'go_to_school',
    CardGroup.school,
    en: 'Go to school',
    vi: 'Đi học',
  ),
  BuiltInCard(
    'homework',
    CardGroup.school,
    en: 'Do homework',
    vi: 'Làm bài tập',
  ),
  BuiltInCard('read_book', CardGroup.school, en: 'Read a book', vi: 'Đọc sách'),
  BuiltInCard('draw', CardGroup.school, en: 'Draw a picture', vi: 'Vẽ tranh'),
  BuiltInCard(
    'practice_music',
    CardGroup.school,
    en: 'Practice music',
    vi: 'Tập đàn',
  ),
  BuiltInCard('say_hello', CardGroup.school, en: 'Say hello', vi: 'Chào hỏi'),
  BuiltInCard(
    'practice_writing',
    CardGroup.school,
    en: 'Practice writing',
    vi: 'Tập viết',
  ),
  BuiltInCard(
    'count_numbers',
    CardGroup.school,
    en: 'Count numbers',
    vi: 'Tập đếm',
  ),
  BuiltInCard(
    'learn_letters',
    CardGroup.school,
    en: 'Learn letters',
    vi: 'Học chữ',
  ),
  BuiltInCard('puzzle', CardGroup.school, en: 'Do a puzzle', vi: 'Xếp hình'),
  BuiltInCard('sing', CardGroup.school, en: 'Sing a song', vi: 'Hát'),
  BuiltInCard(
    'cut_and_paste',
    CardGroup.school,
    en: 'Cut and paste',
    vi: 'Cắt dán',
  ),
  BuiltInCard(
    'school_bus',
    CardGroup.school,
    en: 'Take the bus',
    vi: 'Đi xe buýt',
  ),
  BuiltInCard(
    'lunch_box',
    CardGroup.school,
    en: 'Pack lunch box',
    vi: 'Soạn hộp cơm',
  ),
  // Meals & care
  BuiltInCard('wash_hands', CardGroup.care, en: 'Wash hands', vi: 'Rửa tay'),
  BuiltInCard('eat_lunch', CardGroup.care, en: 'Eat lunch', vi: 'Ăn trưa'),
  BuiltInCard('eat_dinner', CardGroup.care, en: 'Eat dinner', vi: 'Ăn tối'),
  BuiltInCard('eat_fruit', CardGroup.care, en: 'Eat fruit', vi: 'Ăn trái cây'),
  BuiltInCard(
    'drink_water',
    CardGroup.care,
    en: 'Drink water',
    vi: 'Uống nước',
  ),
  BuiltInCard('take_bath', CardGroup.care, en: 'Take a bath', vi: 'Tắm'),
  BuiltInCard('wash_hair', CardGroup.care, en: 'Wash hair', vi: 'Gội đầu'),
  BuiltInCard(
    'take_medicine',
    CardGroup.care,
    en: 'Take medicine',
    vi: 'Uống thuốc',
  ),
  BuiltInCard('nap', CardGroup.care, en: 'Take a nap', vi: 'Ngủ trưa'),
  BuiltInCard(
    'eat_vegetables',
    CardGroup.care,
    en: 'Eat vegetables',
    vi: 'Ăn rau',
  ),
  BuiltInCard('snack', CardGroup.care, en: 'Have a snack', vi: 'Ăn nhẹ'),
  BuiltInCard('blow_nose', CardGroup.care, en: 'Blow nose', vi: 'Xì mũi'),
  BuiltInCard('wash_feet', CardGroup.care, en: 'Wash feet', vi: 'Rửa chân'),
  BuiltInCard(
    'wear_glasses',
    CardGroup.care,
    en: 'Put on glasses',
    vi: 'Đeo kính',
  ),
  BuiltInCard('haircut', CardGroup.care, en: 'Get a haircut', vi: 'Cắt tóc'),
  BuiltInCard(
    'see_doctor',
    CardGroup.care,
    en: 'See the doctor',
    vi: 'Đi khám bác sĩ',
  ),
  BuiltInCard(
    'see_dentist',
    CardGroup.care,
    en: 'See the dentist',
    vi: 'Đi khám răng',
  ),
  BuiltInCard(
    'take_temperature',
    CardGroup.care,
    en: 'Take temperature',
    vi: 'Đo nhiệt độ',
  ),
  // Home & bedtime
  BuiltInCard(
    'tidy_toys',
    CardGroup.home,
    en: 'Tidy up toys',
    vi: 'Dọn đồ chơi',
  ),
  BuiltInCard(
    'water_plants',
    CardGroup.home,
    en: 'Water the plants',
    vi: 'Tưới cây',
  ),
  BuiltInCard(
    'feed_pet',
    CardGroup.home,
    en: 'Feed the pet',
    vi: 'Cho thú cưng ăn',
  ),
  BuiltInCard(
    'set_table',
    CardGroup.home,
    en: 'Set the table',
    vi: 'Dọn bàn ăn',
  ),
  BuiltInCard(
    'laundry_basket',
    CardGroup.home,
    en: 'Laundry in the basket',
    vi: 'Bỏ đồ vào giỏ',
  ),
  BuiltInCard(
    'play_outside',
    CardGroup.home,
    en: 'Play outside',
    vi: 'Chơi ngoài trời',
  ),
  BuiltInCard('exercise', CardGroup.home, en: 'Exercise', vi: 'Tập thể dục'),
  BuiltInCard(
    'screen_time',
    CardGroup.home,
    en: 'Screen time',
    vi: 'Xem ti vi',
  ),
  BuiltInCard(
    'story_time',
    CardGroup.home,
    en: 'Story time',
    vi: 'Nghe kể chuyện',
  ),
  BuiltInCard('hug', CardGroup.home, en: 'Give a hug', vi: 'Ôm ba mẹ'),
  BuiltInCard(
    'turn_off_light',
    CardGroup.home,
    en: 'Lights off',
    vi: 'Tắt đèn',
  ),
  BuiltInCard('go_to_sleep', CardGroup.home, en: 'Go to sleep', vi: 'Đi ngủ'),
  BuiltInCard('sweep', CardGroup.home, en: 'Sweep the floor', vi: 'Quét nhà'),
  BuiltInCard(
    'take_out_trash',
    CardGroup.home,
    en: 'Take out the trash',
    vi: 'Đổ rác',
  ),
  BuiltInCard(
    'wash_dishes',
    CardGroup.home,
    en: 'Wash the dishes',
    vi: 'Rửa chén',
  ),
  BuiltInCard(
    'fold_clothes',
    CardGroup.home,
    en: 'Fold clothes',
    vi: 'Xếp quần áo',
  ),
  BuiltInCard(
    'put_away_sandals',
    CardGroup.home,
    en: 'Put shoes away',
    vi: 'Cất dép',
  ),
  BuiltInCard(
    'feed_fish',
    CardGroup.home,
    en: 'Feed the fish',
    vi: 'Cho cá ăn',
  ),
  BuiltInCard(
    'listen_to_music',
    CardGroup.home,
    en: 'Listen to music',
    vi: 'Nghe nhạc',
  ),
  BuiltInCard(
    'call_grandparents',
    CardGroup.home,
    en: 'Call grandparents',
    vi: 'Gọi cho ông bà',
  ),
  BuiltInCard(
    'say_good_night',
    CardGroup.home,
    en: 'Say good night',
    vi: 'Chúc ngủ ngon',
  ),
  // Out and about
  BuiltInCard(
    'go_to_park',
    CardGroup.outside,
    en: 'Go to the park',
    vi: 'Đi công viên',
  ),
  BuiltInCard(
    'ride_bike',
    CardGroup.outside,
    en: 'Ride a bike',
    vi: 'Đi xe đạp',
  ),
  BuiltInCard('swim', CardGroup.outside, en: 'Go swimming', vi: 'Đi bơi'),
  BuiltInCard(
    'go_shopping',
    CardGroup.outside,
    en: 'Go shopping',
    vi: 'Đi siêu thị',
  ),
  BuiltInCard(
    'visit_grandparents',
    CardGroup.outside,
    en: 'Visit grandparents',
    vi: 'Thăm ông bà',
  ),
  BuiltInCard(
    'wear_helmet',
    CardGroup.outside,
    en: 'Wear a helmet',
    vi: 'Đội mũ bảo hiểm',
  ),
  BuiltInCard(
    'seat_belt',
    CardGroup.outside,
    en: 'Fasten seat belt',
    vi: 'Thắt dây an toàn',
  ),
  BuiltInCard(
    'hold_hands',
    CardGroup.outside,
    en: 'Hold hands',
    vi: 'Nắm tay ba mẹ',
  ),
  BuiltInCard(
    'cross_street',
    CardGroup.outside,
    en: 'Wait for green light',
    vi: 'Chờ đèn xanh',
  ),
  BuiltInCard(
    'umbrella',
    CardGroup.outside,
    en: 'Take an umbrella',
    vi: 'Mang dù',
  ),
  BuiltInCard(
    'wear_mask',
    CardGroup.outside,
    en: 'Wear a mask',
    vi: 'Đeo khẩu trang',
  ),
  // Kind words
  BuiltInCard(
    'say_thank_you',
    CardGroup.manners,
    en: 'Say thank you',
    vi: 'Nói cảm ơn',
  ),
  BuiltInCard(
    'say_sorry',
    CardGroup.manners,
    en: 'Say sorry',
    vi: 'Nói xin lỗi',
  ),
  BuiltInCard('share', CardGroup.manners, en: 'Share', vi: 'Chia sẻ'),
  BuiltInCard(
    'take_turns',
    CardGroup.manners,
    en: 'Wait my turn',
    vi: 'Chờ đến lượt',
  ),
  BuiltInCard('listen', CardGroup.manners, en: 'Listen', vi: 'Lắng nghe'),
  BuiltInCard(
    'quiet_voice',
    CardGroup.manners,
    en: 'Use a quiet voice',
    vi: 'Nói khẽ',
  ),
  BuiltInCard('help', CardGroup.manners, en: 'Help out', vi: 'Giúp đỡ'),
  BuiltInCard(
    'deep_breath',
    CardGroup.manners,
    en: 'Take a deep breath',
    vi: 'Hít thở sâu',
  ),
  BuiltInCard('ask_first', CardGroup.manners, en: 'Ask first', vi: 'Xin phép'),
];

final Map<String, BuiltInCard> builtInCardsById = {
  for (final card in builtInCards) card.id: card,
};

List<BuiltInCard> builtInCardsIn(CardGroup group) => [
  for (final card in builtInCards)
    if (card.group == group) card,
];

/// Icons a parent can give a routine.
const List<String> routineIconIds = [
  'sun',
  'moon',
  'school',
  'house',
  'star',
  'rainbow',
  'rocket',
  'balloon',
  'meal',
  'bath',
  'books',
  'backpack',
  'ball',
  'tree',
  'car',
  'heart',
];

const String defaultRoutineIconId = 'star';

String routineIconAsset(String iconId) => routineIconIds.contains(iconId)
    ? 'assets/icons/$iconId.svg'
    : 'assets/icons/$defaultRoutineIconId.svg';

/// The pages of the sticker book, in order.
enum StickerSet { farm, forest, wild, sea, tiny }

/// An animal friend a child collects by finishing a routine.
class Sticker {
  const Sticker(this.id, this.group, {required this.en, required this.vi});

  final String id;
  final StickerSet group;
  final String en;
  final String vi;

  String get asset => 'assets/stickers/$id.svg';

  String label(String languageCode) => languageCode == 'vi' ? vi : en;
}

const List<Sticker> stickers = [
  // Home and farm
  Sticker('dog', StickerSet.farm, en: 'Puppy', vi: 'Chó con'),
  Sticker('cat', StickerSet.farm, en: 'Kitten', vi: 'Mèo con'),
  Sticker('rabbit', StickerSet.farm, en: 'Bunny', vi: 'Thỏ'),
  Sticker('hamster', StickerSet.farm, en: 'Hamster', vi: 'Hamster'),
  Sticker('mouse', StickerSet.farm, en: 'Mouse', vi: 'Chuột nhắt'),
  Sticker('chick', StickerSet.farm, en: 'Chick', vi: 'Gà con'),
  Sticker('rooster', StickerSet.farm, en: 'Rooster', vi: 'Gà trống'),
  Sticker('duck', StickerSet.farm, en: 'Duck', vi: 'Vịt'),
  Sticker('pig', StickerSet.farm, en: 'Piggy', vi: 'Heo'),
  Sticker('cow', StickerSet.farm, en: 'Cow', vi: 'Bò'),
  Sticker('buffalo', StickerSet.farm, en: 'Buffalo', vi: 'Trâu'),
  Sticker('horse', StickerSet.farm, en: 'Horse', vi: 'Ngựa'),
  Sticker('sheep', StickerSet.farm, en: 'Sheep', vi: 'Cừu'),
  // In the forest
  Sticker('fox', StickerSet.forest, en: 'Fox', vi: 'Cáo'),
  Sticker('bear', StickerSet.forest, en: 'Bear', vi: 'Gấu'),
  Sticker('panda', StickerSet.forest, en: 'Panda', vi: 'Gấu trúc'),
  Sticker('koala', StickerSet.forest, en: 'Koala', vi: 'Koala'),
  Sticker('monkey', StickerSet.forest, en: 'Monkey', vi: 'Khỉ'),
  Sticker('owl', StickerSet.forest, en: 'Owl', vi: 'Cú mèo'),
  Sticker('deer', StickerSet.forest, en: 'Deer', vi: 'Hươu'),
  Sticker('squirrel', StickerSet.forest, en: 'Squirrel', vi: 'Sóc'),
  Sticker('hedgehog', StickerSet.forest, en: 'Hedgehog', vi: 'Nhím'),
  Sticker('sloth', StickerSet.forest, en: 'Sloth', vi: 'Con lười'),
  // Wild animals
  Sticker('tiger', StickerSet.wild, en: 'Tiger', vi: 'Hổ'),
  Sticker('lion', StickerSet.wild, en: 'Lion', vi: 'Sư tử'),
  Sticker('elephant', StickerSet.wild, en: 'Elephant', vi: 'Voi'),
  Sticker('giraffe', StickerSet.wild, en: 'Giraffe', vi: 'Hươu cao cổ'),
  Sticker('zebra', StickerSet.wild, en: 'Zebra', vi: 'Ngựa vằn'),
  Sticker('hippo', StickerSet.wild, en: 'Hippo', vi: 'Hà mã'),
  Sticker('kangaroo', StickerSet.wild, en: 'Kangaroo', vi: 'Chuột túi'),
  // In the sea
  Sticker('dolphin', StickerSet.sea, en: 'Dolphin', vi: 'Cá heo'),
  Sticker('whale', StickerSet.sea, en: 'Whale', vi: 'Cá voi'),
  Sticker('turtle', StickerSet.sea, en: 'Turtle', vi: 'Rùa'),
  Sticker('penguin', StickerSet.sea, en: 'Penguin', vi: 'Chim cánh cụt'),
  Sticker('octopus', StickerSet.sea, en: 'Octopus', vi: 'Bạch tuộc'),
  Sticker('crab', StickerSet.sea, en: 'Crab', vi: 'Cua'),
  Sticker('fish', StickerSet.sea, en: 'Fish', vi: 'Cá'),
  Sticker('shark', StickerSet.sea, en: 'Shark', vi: 'Cá mập'),
  Sticker('seal', StickerSet.sea, en: 'Seal', vi: 'Hải cẩu'),
  // Small and magical
  Sticker('butterfly', StickerSet.tiny, en: 'Butterfly', vi: 'Bướm'),
  Sticker('ladybug', StickerSet.tiny, en: 'Ladybug', vi: 'Bọ rùa'),
  Sticker('bee', StickerSet.tiny, en: 'Bee', vi: 'Ong'),
  Sticker('snail', StickerSet.tiny, en: 'Snail', vi: 'Ốc sên'),
  Sticker('frog', StickerSet.tiny, en: 'Frog', vi: 'Ếch'),
  Sticker('parrot', StickerSet.tiny, en: 'Parrot', vi: 'Vẹt'),
  Sticker('flamingo', StickerSet.tiny, en: 'Flamingo', vi: 'Hồng hạc'),
  Sticker('unicorn', StickerSet.tiny, en: 'Unicorn', vi: 'Kỳ lân'),
  Sticker('dinosaur', StickerSet.tiny, en: 'Dinosaur', vi: 'Khủng long'),
];

final Map<String, Sticker> stickersById = {
  for (final sticker in stickers) sticker.id: sticker,
};

List<Sticker> stickersIn(StickerSet group) => [
  for (final sticker in stickers)
    if (sticker.group == group) sticker,
];
