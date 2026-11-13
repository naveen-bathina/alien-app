import 'package:flutter_test/flutter_test.dart';
import 'package:myalien/metadata/models/metadata_option.dart';
import 'package:myalien/metadata/repository/metadata_repository.dart';

void main() {
  group('MetadataRepository & MetadataOption', () {
    late MetadataRepository repo;

    setUp(() {
      repo = MetadataRepository();
    });

    test('watchActivityTypes returns curated default activities', () async {
      final stream = repo.watchActivityTypes();
      final activities = await stream.first;

      expect(activities, isNotEmpty);
      expect(
        activities.any((a) => a.title == 'Coffee & Chat'),
        isTrue,
      );
      expect(
        activities.any((a) => a.title == 'Movie & Entertainment'),
        isTrue,
      );
    });

    test('watchLookingForIntentions returns curated default intentions', () async {
      final stream = repo.watchLookingForIntentions();
      final intentions = await stream.first;

      expect(intentions, isNotEmpty);
      expect(
        intentions.any((i) => i.title == 'Cafe Catchups'),
        isTrue,
      );
    });

    test('resolveIconNameFromTitle resolves keywords accurately', () {
      expect(
        MetadataOption.resolveIconNameFromTitle('Netflix and Chill'),
        'tv_rounded',
      );
      expect(
        MetadataOption.resolveIconNameFromTitle('Specialty Coffee'),
        'local_cafe_rounded',
      );
      expect(
        MetadataOption.resolveIconNameFromTitle('Badminton Session'),
        'fitness_center_rounded',
      );
      expect(
        MetadataOption.resolveIconNameFromTitle('Dinner Companion'),
        'restaurant_rounded',
      );
    });

    test('addCustomActivityType adds Netflix and Chill to stream', () async {
      final added = await repo.addCustomActivityType(
        title: 'Netflix and Chill',
        subtitle: 'Movie marathon on the couch',
      );

      expect(added.title, 'Netflix and Chill');
      expect(added.isCustom, isTrue);
      expect(added.iconName, 'tv_rounded');

      final stream = repo.watchActivityTypes();
      final updatedList = await stream.first;
      expect(
        updatedList.any((a) => a.title == 'Netflix and Chill'),
        isTrue,
      );
    });

    test('addCustomLookingFor adds Netflix and Chill to intentions stream', () async {
      final added = await repo.addCustomLookingFor(
        title: 'Netflix and Chill',
        subtitle: 'Chill indoor hangouts',
      );

      expect(added.title, 'Netflix and Chill');
      expect(added.isCustom, isTrue);

      final stream = repo.watchLookingForIntentions();
      final updatedList = await stream.first;
      expect(
        updatedList.any((i) => i.title == 'Netflix and Chill'),
        isTrue,
      );
    });
  });
}
