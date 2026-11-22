/// Ready-made routines a parent can start from.
library;

class RoutineTemplate {
  const RoutineTemplate(this.presetKey, this.iconId, this.cardIds);

  /// Also becomes the routine's `presetKey`, which gives it a translated name
  /// until the parent types one.
  final String presetKey;
  final String iconId;
  final List<String> cardIds;
}

const List<RoutineTemplate> routineTemplates = [
  RoutineTemplate('morning', 'sun', [
    'wake_up',
    'make_bed',
    'brush_teeth',
    'wash_face',
    'get_dressed',
    'breakfast',
    'pack_bag',
  ]),
  RoutineTemplate('evening', 'moon', [
    'tidy_toys',
    'take_bath',
    'eat_dinner',
    'brush_teeth',
    'story_time',
    'go_to_sleep',
  ]),
  RoutineTemplate('after_school', 'backpack', [
    'put_away_sandals',
    'wash_hands',
    'drink_water',
    'snack',
    'homework',
    'play_outside',
  ]),
  RoutineTemplate('going_out', 'car', [
    'toilet',
    'put_on_socks',
    'put_on_shoes',
    'wear_hat',
    'wear_helmet',
    'hold_hands',
  ]),
  RoutineTemplate('mealtime', 'meal', [
    'wash_hands',
    'set_table',
    'eat_lunch',
    'eat_vegetables',
    'drink_water',
    'wash_dishes',
  ]),
  RoutineTemplate('bedtime', 'bath', [
    'take_bath',
    'brush_teeth',
    'story_time',
    'hug',
    'say_good_night',
    'turn_off_light',
    'go_to_sleep',
  ]),
  RoutineTemplate('weekend', 'tree', [
    'wake_up',
    'breakfast',
    'tidy_toys',
    'water_plants',
    'go_to_park',
    'visit_grandparents',
  ]),
  RoutineTemplate('chores', 'house', [
    'make_bed',
    'tidy_toys',
    'sweep',
    'water_plants',
    'feed_pet',
    'fold_clothes',
  ]),
  RoutineTemplate('doctor', 'heart', [
    'wear_mask',
    'hold_hands',
    'take_temperature',
    'see_doctor',
    'say_thank_you',
  ]),
];

final Map<String, RoutineTemplate> routineTemplatesByKey = {
  for (final template in routineTemplates) template.presetKey: template,
};

/// The routines a new installation starts with.
const List<String> starterTemplateKeys = ['morning', 'evening'];
