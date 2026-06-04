import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'offline_db.g.dart';

class StoriesOffline extends Table {
  TextColumn get storyId => text().named('story_id')();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get slug => text().withDefault(const Constant(''))();
  TextColumn get author => text().withDefault(const Constant(''))();
  TextColumn get coverUrl => text().named('cover_url').withDefault(const Constant(''))();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {storyId};
}

class ChaptersOffline extends Table {
  TextColumn get chapterId => text().named('chapter_id')();
  TextColumn get storyId => text().named('story_id')();
  IntColumn get chapterNumber => integer().named('chapter_number').withDefault(const Constant(0))();
  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get status => text().withDefault(const Constant('queued'))();
  TextColumn get filePath => text().named('file_path').nullable()();
  IntColumn get sizeBytes => integer().named('size_bytes').nullable()();
  TextColumn get contentHash => text().named('content_hash').nullable()();
  DateTimeColumn get downloadedAt => dateTime().named('downloaded_at').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {chapterId};
}

class ReadingProgressOffline extends Table {
  TextColumn get storyId => text().named('story_id')();
  IntColumn get chapterIndex => integer().named('chapter_index').withDefault(const Constant(0))();
  IntColumn get lastPosition => integer().named('last_position').nullable()();
  DateTimeColumn get updatedAt => dateTime().named('updated_at').withDefault(currentDateAndTime)();

  @override
  Set<Column<Object>> get primaryKey => {storyId};
}

@DriftDatabase(
  tables: [
    StoriesOffline,
    ChaptersOffline,
    ReadingProgressOffline,
  ],
)
class OfflineDb extends _$OfflineDb {
  OfflineDb() : super(_openConnection());

  @override
  int get schemaVersion => 1;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final appDocDir = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(appDocDir.path, 'offline.db'));
    return NativeDatabase.createInBackground(dbFile);
  });
}
