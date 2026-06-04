// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offline_db.dart';

// ignore_for_file: type=lint
class $StoriesOfflineTable extends StoriesOffline
    with TableInfo<$StoriesOfflineTable, StoriesOfflineData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StoriesOfflineTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _storyIdMeta = const VerificationMeta(
    'storyId',
  );
  @override
  late final GeneratedColumn<String> storyId = GeneratedColumn<String>(
    'story_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _coverUrlMeta = const VerificationMeta(
    'coverUrl',
  );
  @override
  late final GeneratedColumn<String> coverUrl = GeneratedColumn<String>(
    'cover_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    storyId,
    title,
    slug,
    author,
    coverUrl,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'stories_offline';
  @override
  VerificationContext validateIntegrity(
    Insertable<StoriesOfflineData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('story_id')) {
      context.handle(
        _storyIdMeta,
        storyId.isAcceptableOrUnknown(data['story_id']!, _storyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storyIdMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('cover_url')) {
      context.handle(
        _coverUrlMeta,
        coverUrl.isAcceptableOrUnknown(data['cover_url']!, _coverUrlMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {storyId};
  @override
  StoriesOfflineData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return StoriesOfflineData(
      storyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}story_id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      coverUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_url'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $StoriesOfflineTable createAlias(String alias) {
    return $StoriesOfflineTable(attachedDatabase, alias);
  }
}

class StoriesOfflineData extends DataClass
    implements Insertable<StoriesOfflineData> {
  final String storyId;
  final String title;
  final String slug;
  final String author;
  final String coverUrl;
  final DateTime updatedAt;
  const StoriesOfflineData({
    required this.storyId,
    required this.title,
    required this.slug,
    required this.author,
    required this.coverUrl,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['story_id'] = Variable<String>(storyId);
    map['title'] = Variable<String>(title);
    map['slug'] = Variable<String>(slug);
    map['author'] = Variable<String>(author);
    map['cover_url'] = Variable<String>(coverUrl);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  StoriesOfflineCompanion toCompanion(bool nullToAbsent) {
    return StoriesOfflineCompanion(
      storyId: Value(storyId),
      title: Value(title),
      slug: Value(slug),
      author: Value(author),
      coverUrl: Value(coverUrl),
      updatedAt: Value(updatedAt),
    );
  }

  factory StoriesOfflineData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return StoriesOfflineData(
      storyId: serializer.fromJson<String>(json['storyId']),
      title: serializer.fromJson<String>(json['title']),
      slug: serializer.fromJson<String>(json['slug']),
      author: serializer.fromJson<String>(json['author']),
      coverUrl: serializer.fromJson<String>(json['coverUrl']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'storyId': serializer.toJson<String>(storyId),
      'title': serializer.toJson<String>(title),
      'slug': serializer.toJson<String>(slug),
      'author': serializer.toJson<String>(author),
      'coverUrl': serializer.toJson<String>(coverUrl),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  StoriesOfflineData copyWith({
    String? storyId,
    String? title,
    String? slug,
    String? author,
    String? coverUrl,
    DateTime? updatedAt,
  }) => StoriesOfflineData(
    storyId: storyId ?? this.storyId,
    title: title ?? this.title,
    slug: slug ?? this.slug,
    author: author ?? this.author,
    coverUrl: coverUrl ?? this.coverUrl,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  StoriesOfflineData copyWithCompanion(StoriesOfflineCompanion data) {
    return StoriesOfflineData(
      storyId: data.storyId.present ? data.storyId.value : this.storyId,
      title: data.title.present ? data.title.value : this.title,
      slug: data.slug.present ? data.slug.value : this.slug,
      author: data.author.present ? data.author.value : this.author,
      coverUrl: data.coverUrl.present ? data.coverUrl.value : this.coverUrl,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('StoriesOfflineData(')
          ..write('storyId: $storyId, ')
          ..write('title: $title, ')
          ..write('slug: $slug, ')
          ..write('author: $author, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(storyId, title, slug, author, coverUrl, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is StoriesOfflineData &&
          other.storyId == this.storyId &&
          other.title == this.title &&
          other.slug == this.slug &&
          other.author == this.author &&
          other.coverUrl == this.coverUrl &&
          other.updatedAt == this.updatedAt);
}

class StoriesOfflineCompanion extends UpdateCompanion<StoriesOfflineData> {
  final Value<String> storyId;
  final Value<String> title;
  final Value<String> slug;
  final Value<String> author;
  final Value<String> coverUrl;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const StoriesOfflineCompanion({
    this.storyId = const Value.absent(),
    this.title = const Value.absent(),
    this.slug = const Value.absent(),
    this.author = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StoriesOfflineCompanion.insert({
    required String storyId,
    this.title = const Value.absent(),
    this.slug = const Value.absent(),
    this.author = const Value.absent(),
    this.coverUrl = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : storyId = Value(storyId);
  static Insertable<StoriesOfflineData> custom({
    Expression<String>? storyId,
    Expression<String>? title,
    Expression<String>? slug,
    Expression<String>? author,
    Expression<String>? coverUrl,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (storyId != null) 'story_id': storyId,
      if (title != null) 'title': title,
      if (slug != null) 'slug': slug,
      if (author != null) 'author': author,
      if (coverUrl != null) 'cover_url': coverUrl,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StoriesOfflineCompanion copyWith({
    Value<String>? storyId,
    Value<String>? title,
    Value<String>? slug,
    Value<String>? author,
    Value<String>? coverUrl,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return StoriesOfflineCompanion(
      storyId: storyId ?? this.storyId,
      title: title ?? this.title,
      slug: slug ?? this.slug,
      author: author ?? this.author,
      coverUrl: coverUrl ?? this.coverUrl,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (storyId.present) {
      map['story_id'] = Variable<String>(storyId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (coverUrl.present) {
      map['cover_url'] = Variable<String>(coverUrl.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StoriesOfflineCompanion(')
          ..write('storyId: $storyId, ')
          ..write('title: $title, ')
          ..write('slug: $slug, ')
          ..write('author: $author, ')
          ..write('coverUrl: $coverUrl, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChaptersOfflineTable extends ChaptersOffline
    with TableInfo<$ChaptersOfflineTable, ChaptersOfflineData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersOfflineTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storyIdMeta = const VerificationMeta(
    'storyId',
  );
  @override
  late final GeneratedColumn<String> storyId = GeneratedColumn<String>(
    'story_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterNumberMeta = const VerificationMeta(
    'chapterNumber',
  );
  @override
  late final GeneratedColumn<int> chapterNumber = GeneratedColumn<int>(
    'chapter_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queued'),
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sizeBytesMeta = const VerificationMeta(
    'sizeBytes',
  );
  @override
  late final GeneratedColumn<int> sizeBytes = GeneratedColumn<int>(
    'size_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentHashMeta = const VerificationMeta(
    'contentHash',
  );
  @override
  late final GeneratedColumn<String> contentHash = GeneratedColumn<String>(
    'content_hash',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _downloadedAtMeta = const VerificationMeta(
    'downloadedAt',
  );
  @override
  late final GeneratedColumn<DateTime> downloadedAt = GeneratedColumn<DateTime>(
    'downloaded_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    chapterId,
    storyId,
    chapterNumber,
    title,
    status,
    filePath,
    sizeBytes,
    contentHash,
    downloadedAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters_offline';
  @override
  VerificationContext validateIntegrity(
    Insertable<ChaptersOfflineData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('story_id')) {
      context.handle(
        _storyIdMeta,
        storyId.isAcceptableOrUnknown(data['story_id']!, _storyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storyIdMeta);
    }
    if (data.containsKey('chapter_number')) {
      context.handle(
        _chapterNumberMeta,
        chapterNumber.isAcceptableOrUnknown(
          data['chapter_number']!,
          _chapterNumberMeta,
        ),
      );
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    }
    if (data.containsKey('size_bytes')) {
      context.handle(
        _sizeBytesMeta,
        sizeBytes.isAcceptableOrUnknown(data['size_bytes']!, _sizeBytesMeta),
      );
    }
    if (data.containsKey('content_hash')) {
      context.handle(
        _contentHashMeta,
        contentHash.isAcceptableOrUnknown(
          data['content_hash']!,
          _contentHashMeta,
        ),
      );
    }
    if (data.containsKey('downloaded_at')) {
      context.handle(
        _downloadedAtMeta,
        downloadedAt.isAcceptableOrUnknown(
          data['downloaded_at']!,
          _downloadedAtMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {chapterId};
  @override
  ChaptersOfflineData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ChaptersOfflineData(
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      storyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}story_id'],
      )!,
      chapterNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_number'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      ),
      sizeBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}size_bytes'],
      ),
      contentHash: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_hash'],
      ),
      downloadedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}downloaded_at'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ChaptersOfflineTable createAlias(String alias) {
    return $ChaptersOfflineTable(attachedDatabase, alias);
  }
}

class ChaptersOfflineData extends DataClass
    implements Insertable<ChaptersOfflineData> {
  final String chapterId;
  final String storyId;
  final int chapterNumber;
  final String title;
  final String status;
  final String? filePath;
  final int? sizeBytes;
  final String? contentHash;
  final DateTime? downloadedAt;
  final DateTime updatedAt;
  const ChaptersOfflineData({
    required this.chapterId,
    required this.storyId,
    required this.chapterNumber,
    required this.title,
    required this.status,
    this.filePath,
    this.sizeBytes,
    this.contentHash,
    this.downloadedAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['chapter_id'] = Variable<String>(chapterId);
    map['story_id'] = Variable<String>(storyId);
    map['chapter_number'] = Variable<int>(chapterNumber);
    map['title'] = Variable<String>(title);
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || filePath != null) {
      map['file_path'] = Variable<String>(filePath);
    }
    if (!nullToAbsent || sizeBytes != null) {
      map['size_bytes'] = Variable<int>(sizeBytes);
    }
    if (!nullToAbsent || contentHash != null) {
      map['content_hash'] = Variable<String>(contentHash);
    }
    if (!nullToAbsent || downloadedAt != null) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ChaptersOfflineCompanion toCompanion(bool nullToAbsent) {
    return ChaptersOfflineCompanion(
      chapterId: Value(chapterId),
      storyId: Value(storyId),
      chapterNumber: Value(chapterNumber),
      title: Value(title),
      status: Value(status),
      filePath: filePath == null && nullToAbsent
          ? const Value.absent()
          : Value(filePath),
      sizeBytes: sizeBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(sizeBytes),
      contentHash: contentHash == null && nullToAbsent
          ? const Value.absent()
          : Value(contentHash),
      downloadedAt: downloadedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(downloadedAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory ChaptersOfflineData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ChaptersOfflineData(
      chapterId: serializer.fromJson<String>(json['chapterId']),
      storyId: serializer.fromJson<String>(json['storyId']),
      chapterNumber: serializer.fromJson<int>(json['chapterNumber']),
      title: serializer.fromJson<String>(json['title']),
      status: serializer.fromJson<String>(json['status']),
      filePath: serializer.fromJson<String?>(json['filePath']),
      sizeBytes: serializer.fromJson<int?>(json['sizeBytes']),
      contentHash: serializer.fromJson<String?>(json['contentHash']),
      downloadedAt: serializer.fromJson<DateTime?>(json['downloadedAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'chapterId': serializer.toJson<String>(chapterId),
      'storyId': serializer.toJson<String>(storyId),
      'chapterNumber': serializer.toJson<int>(chapterNumber),
      'title': serializer.toJson<String>(title),
      'status': serializer.toJson<String>(status),
      'filePath': serializer.toJson<String?>(filePath),
      'sizeBytes': serializer.toJson<int?>(sizeBytes),
      'contentHash': serializer.toJson<String?>(contentHash),
      'downloadedAt': serializer.toJson<DateTime?>(downloadedAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ChaptersOfflineData copyWith({
    String? chapterId,
    String? storyId,
    int? chapterNumber,
    String? title,
    String? status,
    Value<String?> filePath = const Value.absent(),
    Value<int?> sizeBytes = const Value.absent(),
    Value<String?> contentHash = const Value.absent(),
    Value<DateTime?> downloadedAt = const Value.absent(),
    DateTime? updatedAt,
  }) => ChaptersOfflineData(
    chapterId: chapterId ?? this.chapterId,
    storyId: storyId ?? this.storyId,
    chapterNumber: chapterNumber ?? this.chapterNumber,
    title: title ?? this.title,
    status: status ?? this.status,
    filePath: filePath.present ? filePath.value : this.filePath,
    sizeBytes: sizeBytes.present ? sizeBytes.value : this.sizeBytes,
    contentHash: contentHash.present ? contentHash.value : this.contentHash,
    downloadedAt: downloadedAt.present ? downloadedAt.value : this.downloadedAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ChaptersOfflineData copyWithCompanion(ChaptersOfflineCompanion data) {
    return ChaptersOfflineData(
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      storyId: data.storyId.present ? data.storyId.value : this.storyId,
      chapterNumber: data.chapterNumber.present
          ? data.chapterNumber.value
          : this.chapterNumber,
      title: data.title.present ? data.title.value : this.title,
      status: data.status.present ? data.status.value : this.status,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      sizeBytes: data.sizeBytes.present ? data.sizeBytes.value : this.sizeBytes,
      contentHash: data.contentHash.present
          ? data.contentHash.value
          : this.contentHash,
      downloadedAt: data.downloadedAt.present
          ? data.downloadedAt.value
          : this.downloadedAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersOfflineData(')
          ..write('chapterId: $chapterId, ')
          ..write('storyId: $storyId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('filePath: $filePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('contentHash: $contentHash, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    chapterId,
    storyId,
    chapterNumber,
    title,
    status,
    filePath,
    sizeBytes,
    contentHash,
    downloadedAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ChaptersOfflineData &&
          other.chapterId == this.chapterId &&
          other.storyId == this.storyId &&
          other.chapterNumber == this.chapterNumber &&
          other.title == this.title &&
          other.status == this.status &&
          other.filePath == this.filePath &&
          other.sizeBytes == this.sizeBytes &&
          other.contentHash == this.contentHash &&
          other.downloadedAt == this.downloadedAt &&
          other.updatedAt == this.updatedAt);
}

class ChaptersOfflineCompanion extends UpdateCompanion<ChaptersOfflineData> {
  final Value<String> chapterId;
  final Value<String> storyId;
  final Value<int> chapterNumber;
  final Value<String> title;
  final Value<String> status;
  final Value<String?> filePath;
  final Value<int?> sizeBytes;
  final Value<String?> contentHash;
  final Value<DateTime?> downloadedAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ChaptersOfflineCompanion({
    this.chapterId = const Value.absent(),
    this.storyId = const Value.absent(),
    this.chapterNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.filePath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChaptersOfflineCompanion.insert({
    required String chapterId,
    required String storyId,
    this.chapterNumber = const Value.absent(),
    this.title = const Value.absent(),
    this.status = const Value.absent(),
    this.filePath = const Value.absent(),
    this.sizeBytes = const Value.absent(),
    this.contentHash = const Value.absent(),
    this.downloadedAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : chapterId = Value(chapterId),
       storyId = Value(storyId);
  static Insertable<ChaptersOfflineData> custom({
    Expression<String>? chapterId,
    Expression<String>? storyId,
    Expression<int>? chapterNumber,
    Expression<String>? title,
    Expression<String>? status,
    Expression<String>? filePath,
    Expression<int>? sizeBytes,
    Expression<String>? contentHash,
    Expression<DateTime>? downloadedAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (chapterId != null) 'chapter_id': chapterId,
      if (storyId != null) 'story_id': storyId,
      if (chapterNumber != null) 'chapter_number': chapterNumber,
      if (title != null) 'title': title,
      if (status != null) 'status': status,
      if (filePath != null) 'file_path': filePath,
      if (sizeBytes != null) 'size_bytes': sizeBytes,
      if (contentHash != null) 'content_hash': contentHash,
      if (downloadedAt != null) 'downloaded_at': downloadedAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChaptersOfflineCompanion copyWith({
    Value<String>? chapterId,
    Value<String>? storyId,
    Value<int>? chapterNumber,
    Value<String>? title,
    Value<String>? status,
    Value<String?>? filePath,
    Value<int?>? sizeBytes,
    Value<String?>? contentHash,
    Value<DateTime?>? downloadedAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ChaptersOfflineCompanion(
      chapterId: chapterId ?? this.chapterId,
      storyId: storyId ?? this.storyId,
      chapterNumber: chapterNumber ?? this.chapterNumber,
      title: title ?? this.title,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      contentHash: contentHash ?? this.contentHash,
      downloadedAt: downloadedAt ?? this.downloadedAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (storyId.present) {
      map['story_id'] = Variable<String>(storyId.value);
    }
    if (chapterNumber.present) {
      map['chapter_number'] = Variable<int>(chapterNumber.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (sizeBytes.present) {
      map['size_bytes'] = Variable<int>(sizeBytes.value);
    }
    if (contentHash.present) {
      map['content_hash'] = Variable<String>(contentHash.value);
    }
    if (downloadedAt.present) {
      map['downloaded_at'] = Variable<DateTime>(downloadedAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersOfflineCompanion(')
          ..write('chapterId: $chapterId, ')
          ..write('storyId: $storyId, ')
          ..write('chapterNumber: $chapterNumber, ')
          ..write('title: $title, ')
          ..write('status: $status, ')
          ..write('filePath: $filePath, ')
          ..write('sizeBytes: $sizeBytes, ')
          ..write('contentHash: $contentHash, ')
          ..write('downloadedAt: $downloadedAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReadingProgressOfflineTable extends ReadingProgressOffline
    with TableInfo<$ReadingProgressOfflineTable, ReadingProgressOfflineData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReadingProgressOfflineTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _storyIdMeta = const VerificationMeta(
    'storyId',
  );
  @override
  late final GeneratedColumn<String> storyId = GeneratedColumn<String>(
    'story_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIndexMeta = const VerificationMeta(
    'chapterIndex',
  );
  @override
  late final GeneratedColumn<int> chapterIndex = GeneratedColumn<int>(
    'chapter_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lastPositionMeta = const VerificationMeta(
    'lastPosition',
  );
  @override
  late final GeneratedColumn<int> lastPosition = GeneratedColumn<int>(
    'last_position',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    storyId,
    chapterIndex,
    lastPosition,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reading_progress_offline';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReadingProgressOfflineData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('story_id')) {
      context.handle(
        _storyIdMeta,
        storyId.isAcceptableOrUnknown(data['story_id']!, _storyIdMeta),
      );
    } else if (isInserting) {
      context.missing(_storyIdMeta);
    }
    if (data.containsKey('chapter_index')) {
      context.handle(
        _chapterIndexMeta,
        chapterIndex.isAcceptableOrUnknown(
          data['chapter_index']!,
          _chapterIndexMeta,
        ),
      );
    }
    if (data.containsKey('last_position')) {
      context.handle(
        _lastPositionMeta,
        lastPosition.isAcceptableOrUnknown(
          data['last_position']!,
          _lastPositionMeta,
        ),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {storyId};
  @override
  ReadingProgressOfflineData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReadingProgressOfflineData(
      storyId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}story_id'],
      )!,
      chapterIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_index'],
      )!,
      lastPosition: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_position'],
      ),
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ReadingProgressOfflineTable createAlias(String alias) {
    return $ReadingProgressOfflineTable(attachedDatabase, alias);
  }
}

class ReadingProgressOfflineData extends DataClass
    implements Insertable<ReadingProgressOfflineData> {
  final String storyId;
  final int chapterIndex;
  final int? lastPosition;
  final DateTime updatedAt;
  const ReadingProgressOfflineData({
    required this.storyId,
    required this.chapterIndex,
    this.lastPosition,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['story_id'] = Variable<String>(storyId);
    map['chapter_index'] = Variable<int>(chapterIndex);
    if (!nullToAbsent || lastPosition != null) {
      map['last_position'] = Variable<int>(lastPosition);
    }
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ReadingProgressOfflineCompanion toCompanion(bool nullToAbsent) {
    return ReadingProgressOfflineCompanion(
      storyId: Value(storyId),
      chapterIndex: Value(chapterIndex),
      lastPosition: lastPosition == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPosition),
      updatedAt: Value(updatedAt),
    );
  }

  factory ReadingProgressOfflineData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReadingProgressOfflineData(
      storyId: serializer.fromJson<String>(json['storyId']),
      chapterIndex: serializer.fromJson<int>(json['chapterIndex']),
      lastPosition: serializer.fromJson<int?>(json['lastPosition']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'storyId': serializer.toJson<String>(storyId),
      'chapterIndex': serializer.toJson<int>(chapterIndex),
      'lastPosition': serializer.toJson<int?>(lastPosition),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  ReadingProgressOfflineData copyWith({
    String? storyId,
    int? chapterIndex,
    Value<int?> lastPosition = const Value.absent(),
    DateTime? updatedAt,
  }) => ReadingProgressOfflineData(
    storyId: storyId ?? this.storyId,
    chapterIndex: chapterIndex ?? this.chapterIndex,
    lastPosition: lastPosition.present ? lastPosition.value : this.lastPosition,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  ReadingProgressOfflineData copyWithCompanion(
    ReadingProgressOfflineCompanion data,
  ) {
    return ReadingProgressOfflineData(
      storyId: data.storyId.present ? data.storyId.value : this.storyId,
      chapterIndex: data.chapterIndex.present
          ? data.chapterIndex.value
          : this.chapterIndex,
      lastPosition: data.lastPosition.present
          ? data.lastPosition.value
          : this.lastPosition,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressOfflineData(')
          ..write('storyId: $storyId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('lastPosition: $lastPosition, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(storyId, chapterIndex, lastPosition, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReadingProgressOfflineData &&
          other.storyId == this.storyId &&
          other.chapterIndex == this.chapterIndex &&
          other.lastPosition == this.lastPosition &&
          other.updatedAt == this.updatedAt);
}

class ReadingProgressOfflineCompanion
    extends UpdateCompanion<ReadingProgressOfflineData> {
  final Value<String> storyId;
  final Value<int> chapterIndex;
  final Value<int?> lastPosition;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const ReadingProgressOfflineCompanion({
    this.storyId = const Value.absent(),
    this.chapterIndex = const Value.absent(),
    this.lastPosition = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReadingProgressOfflineCompanion.insert({
    required String storyId,
    this.chapterIndex = const Value.absent(),
    this.lastPosition = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : storyId = Value(storyId);
  static Insertable<ReadingProgressOfflineData> custom({
    Expression<String>? storyId,
    Expression<int>? chapterIndex,
    Expression<int>? lastPosition,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (storyId != null) 'story_id': storyId,
      if (chapterIndex != null) 'chapter_index': chapterIndex,
      if (lastPosition != null) 'last_position': lastPosition,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReadingProgressOfflineCompanion copyWith({
    Value<String>? storyId,
    Value<int>? chapterIndex,
    Value<int?>? lastPosition,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return ReadingProgressOfflineCompanion(
      storyId: storyId ?? this.storyId,
      chapterIndex: chapterIndex ?? this.chapterIndex,
      lastPosition: lastPosition ?? this.lastPosition,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (storyId.present) {
      map['story_id'] = Variable<String>(storyId.value);
    }
    if (chapterIndex.present) {
      map['chapter_index'] = Variable<int>(chapterIndex.value);
    }
    if (lastPosition.present) {
      map['last_position'] = Variable<int>(lastPosition.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReadingProgressOfflineCompanion(')
          ..write('storyId: $storyId, ')
          ..write('chapterIndex: $chapterIndex, ')
          ..write('lastPosition: $lastPosition, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$OfflineDb extends GeneratedDatabase {
  _$OfflineDb(QueryExecutor e) : super(e);
  $OfflineDbManager get managers => $OfflineDbManager(this);
  late final $StoriesOfflineTable storiesOffline = $StoriesOfflineTable(this);
  late final $ChaptersOfflineTable chaptersOffline = $ChaptersOfflineTable(
    this,
  );
  late final $ReadingProgressOfflineTable readingProgressOffline =
      $ReadingProgressOfflineTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    storiesOffline,
    chaptersOffline,
    readingProgressOffline,
  ];
}

typedef $$StoriesOfflineTableCreateCompanionBuilder =
    StoriesOfflineCompanion Function({
      required String storyId,
      Value<String> title,
      Value<String> slug,
      Value<String> author,
      Value<String> coverUrl,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$StoriesOfflineTableUpdateCompanionBuilder =
    StoriesOfflineCompanion Function({
      Value<String> storyId,
      Value<String> title,
      Value<String> slug,
      Value<String> author,
      Value<String> coverUrl,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$StoriesOfflineTableFilterComposer
    extends Composer<_$OfflineDb, $StoriesOfflineTable> {
  $$StoriesOfflineTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get storyId => $composableBuilder(
    column: $table.storyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StoriesOfflineTableOrderingComposer
    extends Composer<_$OfflineDb, $StoriesOfflineTable> {
  $$StoriesOfflineTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get storyId => $composableBuilder(
    column: $table.storyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverUrl => $composableBuilder(
    column: $table.coverUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StoriesOfflineTableAnnotationComposer
    extends Composer<_$OfflineDb, $StoriesOfflineTable> {
  $$StoriesOfflineTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get storyId =>
      $composableBuilder(column: $table.storyId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get coverUrl =>
      $composableBuilder(column: $table.coverUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$StoriesOfflineTableTableManager
    extends
        RootTableManager<
          _$OfflineDb,
          $StoriesOfflineTable,
          StoriesOfflineData,
          $$StoriesOfflineTableFilterComposer,
          $$StoriesOfflineTableOrderingComposer,
          $$StoriesOfflineTableAnnotationComposer,
          $$StoriesOfflineTableCreateCompanionBuilder,
          $$StoriesOfflineTableUpdateCompanionBuilder,
          (
            StoriesOfflineData,
            BaseReferences<
              _$OfflineDb,
              $StoriesOfflineTable,
              StoriesOfflineData
            >,
          ),
          StoriesOfflineData,
          PrefetchHooks Function()
        > {
  $$StoriesOfflineTableTableManager(_$OfflineDb db, $StoriesOfflineTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StoriesOfflineTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StoriesOfflineTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StoriesOfflineTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> storyId = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> coverUrl = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoriesOfflineCompanion(
                storyId: storyId,
                title: title,
                slug: slug,
                author: author,
                coverUrl: coverUrl,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String storyId,
                Value<String> title = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> coverUrl = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StoriesOfflineCompanion.insert(
                storyId: storyId,
                title: title,
                slug: slug,
                author: author,
                coverUrl: coverUrl,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StoriesOfflineTableProcessedTableManager =
    ProcessedTableManager<
      _$OfflineDb,
      $StoriesOfflineTable,
      StoriesOfflineData,
      $$StoriesOfflineTableFilterComposer,
      $$StoriesOfflineTableOrderingComposer,
      $$StoriesOfflineTableAnnotationComposer,
      $$StoriesOfflineTableCreateCompanionBuilder,
      $$StoriesOfflineTableUpdateCompanionBuilder,
      (
        StoriesOfflineData,
        BaseReferences<_$OfflineDb, $StoriesOfflineTable, StoriesOfflineData>,
      ),
      StoriesOfflineData,
      PrefetchHooks Function()
    >;
typedef $$ChaptersOfflineTableCreateCompanionBuilder =
    ChaptersOfflineCompanion Function({
      required String chapterId,
      required String storyId,
      Value<int> chapterNumber,
      Value<String> title,
      Value<String> status,
      Value<String?> filePath,
      Value<int?> sizeBytes,
      Value<String?> contentHash,
      Value<DateTime?> downloadedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ChaptersOfflineTableUpdateCompanionBuilder =
    ChaptersOfflineCompanion Function({
      Value<String> chapterId,
      Value<String> storyId,
      Value<int> chapterNumber,
      Value<String> title,
      Value<String> status,
      Value<String?> filePath,
      Value<int?> sizeBytes,
      Value<String?> contentHash,
      Value<DateTime?> downloadedAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ChaptersOfflineTableFilterComposer
    extends Composer<_$OfflineDb, $ChaptersOfflineTable> {
  $$ChaptersOfflineTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storyId => $composableBuilder(
    column: $table.storyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChaptersOfflineTableOrderingComposer
    extends Composer<_$OfflineDb, $ChaptersOfflineTable> {
  $$ChaptersOfflineTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storyId => $composableBuilder(
    column: $table.storyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sizeBytes => $composableBuilder(
    column: $table.sizeBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChaptersOfflineTableAnnotationComposer
    extends Composer<_$OfflineDb, $ChaptersOfflineTable> {
  $$ChaptersOfflineTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get storyId =>
      $composableBuilder(column: $table.storyId, builder: (column) => column);

  GeneratedColumn<int> get chapterNumber => $composableBuilder(
    column: $table.chapterNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<int> get sizeBytes =>
      $composableBuilder(column: $table.sizeBytes, builder: (column) => column);

  GeneratedColumn<String> get contentHash => $composableBuilder(
    column: $table.contentHash,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get downloadedAt => $composableBuilder(
    column: $table.downloadedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ChaptersOfflineTableTableManager
    extends
        RootTableManager<
          _$OfflineDb,
          $ChaptersOfflineTable,
          ChaptersOfflineData,
          $$ChaptersOfflineTableFilterComposer,
          $$ChaptersOfflineTableOrderingComposer,
          $$ChaptersOfflineTableAnnotationComposer,
          $$ChaptersOfflineTableCreateCompanionBuilder,
          $$ChaptersOfflineTableUpdateCompanionBuilder,
          (
            ChaptersOfflineData,
            BaseReferences<
              _$OfflineDb,
              $ChaptersOfflineTable,
              ChaptersOfflineData
            >,
          ),
          ChaptersOfflineData,
          PrefetchHooks Function()
        > {
  $$ChaptersOfflineTableTableManager(
    _$OfflineDb db,
    $ChaptersOfflineTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersOfflineTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersOfflineTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersOfflineTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> chapterId = const Value.absent(),
                Value<String> storyId = const Value.absent(),
                Value<int> chapterNumber = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> contentHash = const Value.absent(),
                Value<DateTime?> downloadedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChaptersOfflineCompanion(
                chapterId: chapterId,
                storyId: storyId,
                chapterNumber: chapterNumber,
                title: title,
                status: status,
                filePath: filePath,
                sizeBytes: sizeBytes,
                contentHash: contentHash,
                downloadedAt: downloadedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String chapterId,
                required String storyId,
                Value<int> chapterNumber = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> filePath = const Value.absent(),
                Value<int?> sizeBytes = const Value.absent(),
                Value<String?> contentHash = const Value.absent(),
                Value<DateTime?> downloadedAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChaptersOfflineCompanion.insert(
                chapterId: chapterId,
                storyId: storyId,
                chapterNumber: chapterNumber,
                title: title,
                status: status,
                filePath: filePath,
                sizeBytes: sizeBytes,
                contentHash: contentHash,
                downloadedAt: downloadedAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChaptersOfflineTableProcessedTableManager =
    ProcessedTableManager<
      _$OfflineDb,
      $ChaptersOfflineTable,
      ChaptersOfflineData,
      $$ChaptersOfflineTableFilterComposer,
      $$ChaptersOfflineTableOrderingComposer,
      $$ChaptersOfflineTableAnnotationComposer,
      $$ChaptersOfflineTableCreateCompanionBuilder,
      $$ChaptersOfflineTableUpdateCompanionBuilder,
      (
        ChaptersOfflineData,
        BaseReferences<_$OfflineDb, $ChaptersOfflineTable, ChaptersOfflineData>,
      ),
      ChaptersOfflineData,
      PrefetchHooks Function()
    >;
typedef $$ReadingProgressOfflineTableCreateCompanionBuilder =
    ReadingProgressOfflineCompanion Function({
      required String storyId,
      Value<int> chapterIndex,
      Value<int?> lastPosition,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$ReadingProgressOfflineTableUpdateCompanionBuilder =
    ReadingProgressOfflineCompanion Function({
      Value<String> storyId,
      Value<int> chapterIndex,
      Value<int?> lastPosition,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$ReadingProgressOfflineTableFilterComposer
    extends Composer<_$OfflineDb, $ReadingProgressOfflineTable> {
  $$ReadingProgressOfflineTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get storyId => $composableBuilder(
    column: $table.storyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPosition => $composableBuilder(
    column: $table.lastPosition,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReadingProgressOfflineTableOrderingComposer
    extends Composer<_$OfflineDb, $ReadingProgressOfflineTable> {
  $$ReadingProgressOfflineTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get storyId => $composableBuilder(
    column: $table.storyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPosition => $composableBuilder(
    column: $table.lastPosition,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReadingProgressOfflineTableAnnotationComposer
    extends Composer<_$OfflineDb, $ReadingProgressOfflineTable> {
  $$ReadingProgressOfflineTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get storyId =>
      $composableBuilder(column: $table.storyId, builder: (column) => column);

  GeneratedColumn<int> get chapterIndex => $composableBuilder(
    column: $table.chapterIndex,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPosition => $composableBuilder(
    column: $table.lastPosition,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ReadingProgressOfflineTableTableManager
    extends
        RootTableManager<
          _$OfflineDb,
          $ReadingProgressOfflineTable,
          ReadingProgressOfflineData,
          $$ReadingProgressOfflineTableFilterComposer,
          $$ReadingProgressOfflineTableOrderingComposer,
          $$ReadingProgressOfflineTableAnnotationComposer,
          $$ReadingProgressOfflineTableCreateCompanionBuilder,
          $$ReadingProgressOfflineTableUpdateCompanionBuilder,
          (
            ReadingProgressOfflineData,
            BaseReferences<
              _$OfflineDb,
              $ReadingProgressOfflineTable,
              ReadingProgressOfflineData
            >,
          ),
          ReadingProgressOfflineData,
          PrefetchHooks Function()
        > {
  $$ReadingProgressOfflineTableTableManager(
    _$OfflineDb db,
    $ReadingProgressOfflineTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReadingProgressOfflineTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$ReadingProgressOfflineTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReadingProgressOfflineTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> storyId = const Value.absent(),
                Value<int> chapterIndex = const Value.absent(),
                Value<int?> lastPosition = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressOfflineCompanion(
                storyId: storyId,
                chapterIndex: chapterIndex,
                lastPosition: lastPosition,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String storyId,
                Value<int> chapterIndex = const Value.absent(),
                Value<int?> lastPosition = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReadingProgressOfflineCompanion.insert(
                storyId: storyId,
                chapterIndex: chapterIndex,
                lastPosition: lastPosition,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReadingProgressOfflineTableProcessedTableManager =
    ProcessedTableManager<
      _$OfflineDb,
      $ReadingProgressOfflineTable,
      ReadingProgressOfflineData,
      $$ReadingProgressOfflineTableFilterComposer,
      $$ReadingProgressOfflineTableOrderingComposer,
      $$ReadingProgressOfflineTableAnnotationComposer,
      $$ReadingProgressOfflineTableCreateCompanionBuilder,
      $$ReadingProgressOfflineTableUpdateCompanionBuilder,
      (
        ReadingProgressOfflineData,
        BaseReferences<
          _$OfflineDb,
          $ReadingProgressOfflineTable,
          ReadingProgressOfflineData
        >,
      ),
      ReadingProgressOfflineData,
      PrefetchHooks Function()
    >;

class $OfflineDbManager {
  final _$OfflineDb _db;
  $OfflineDbManager(this._db);
  $$StoriesOfflineTableTableManager get storiesOffline =>
      $$StoriesOfflineTableTableManager(_db, _db.storiesOffline);
  $$ChaptersOfflineTableTableManager get chaptersOffline =>
      $$ChaptersOfflineTableTableManager(_db, _db.chaptersOffline);
  $$ReadingProgressOfflineTableTableManager get readingProgressOffline =>
      $$ReadingProgressOfflineTableTableManager(
        _db,
        _db.readingProgressOffline,
      );
}
