import 'package:fast_app_base_architecture/common/data/preference/item/preference_item.dart';

class NullablePreferenceItem<T> extends PreferenceItem<T?> {
  NullablePreferenceItem(String key, [T? defaultValue])
      : super(key, defaultValue);
}
