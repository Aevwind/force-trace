// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ExercisesTable extends Exercises
    with TableInfo<$ExercisesTable, ExerciseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExercisesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _localNameMeta = const VerificationMeta(
    'localName',
  );
  @override
  late final GeneratedColumn<String> localName = GeneratedColumn<String>(
    'local_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyPartMeta = const VerificationMeta(
    'bodyPart',
  );
  @override
  late final GeneratedColumn<String> bodyPart = GeneratedColumn<String>(
    'body_part',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _equipmentMeta = const VerificationMeta(
    'equipment',
  );
  @override
  late final GeneratedColumn<String> equipment = GeneratedColumn<String>(
    'equipment',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetMeta = const VerificationMeta('target');
  @override
  late final GeneratedColumn<String> target = GeneratedColumn<String>(
    'target',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _secondaryMusclesMeta = const VerificationMeta(
    'secondaryMuscles',
  );
  @override
  late final GeneratedColumn<String> secondaryMuscles = GeneratedColumn<String>(
    'secondary_muscles',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<int> tier = GeneratedColumn<int>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _mediaIdMeta = const VerificationMeta(
    'mediaId',
  );
  @override
  late final GeneratedColumn<String> mediaId = GeneratedColumn<String>(
    'media_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    localName,
    category,
    bodyPart,
    equipment,
    target,
    secondaryMuscles,
    tier,
    mediaId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercises';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('local_name')) {
      context.handle(
        _localNameMeta,
        localName.isAcceptableOrUnknown(data['local_name']!, _localNameMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('body_part')) {
      context.handle(
        _bodyPartMeta,
        bodyPart.isAcceptableOrUnknown(data['body_part']!, _bodyPartMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyPartMeta);
    }
    if (data.containsKey('equipment')) {
      context.handle(
        _equipmentMeta,
        equipment.isAcceptableOrUnknown(data['equipment']!, _equipmentMeta),
      );
    } else if (isInserting) {
      context.missing(_equipmentMeta);
    }
    if (data.containsKey('target')) {
      context.handle(
        _targetMeta,
        target.isAcceptableOrUnknown(data['target']!, _targetMeta),
      );
    } else if (isInserting) {
      context.missing(_targetMeta);
    }
    if (data.containsKey('secondary_muscles')) {
      context.handle(
        _secondaryMusclesMeta,
        secondaryMuscles.isAcceptableOrUnknown(
          data['secondary_muscles']!,
          _secondaryMusclesMeta,
        ),
      );
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('media_id')) {
      context.handle(
        _mediaIdMeta,
        mediaId.isAcceptableOrUnknown(data['media_id']!, _mediaIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExerciseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      localName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      bodyPart: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body_part'],
      )!,
      equipment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}equipment'],
      )!,
      target: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target'],
      )!,
      secondaryMuscles: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}secondary_muscles'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tier'],
      )!,
      mediaId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}media_id'],
      )!,
    );
  }

  @override
  $ExercisesTable createAlias(String alias) {
    return $ExercisesTable(attachedDatabase, alias);
  }
}

class ExerciseRow extends DataClass implements Insertable<ExerciseRow> {
  final String id;
  final String name;
  final String localName;
  final String category;
  final String bodyPart;
  final String equipment;
  final String target;
  final String secondaryMuscles;
  final int tier;
  final String mediaId;
  const ExerciseRow({
    required this.id,
    required this.name,
    required this.localName,
    required this.category,
    required this.bodyPart,
    required this.equipment,
    required this.target,
    required this.secondaryMuscles,
    required this.tier,
    required this.mediaId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['local_name'] = Variable<String>(localName);
    map['category'] = Variable<String>(category);
    map['body_part'] = Variable<String>(bodyPart);
    map['equipment'] = Variable<String>(equipment);
    map['target'] = Variable<String>(target);
    map['secondary_muscles'] = Variable<String>(secondaryMuscles);
    map['tier'] = Variable<int>(tier);
    map['media_id'] = Variable<String>(mediaId);
    return map;
  }

  ExercisesCompanion toCompanion(bool nullToAbsent) {
    return ExercisesCompanion(
      id: Value(id),
      name: Value(name),
      localName: Value(localName),
      category: Value(category),
      bodyPart: Value(bodyPart),
      equipment: Value(equipment),
      target: Value(target),
      secondaryMuscles: Value(secondaryMuscles),
      tier: Value(tier),
      mediaId: Value(mediaId),
    );
  }

  factory ExerciseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      localName: serializer.fromJson<String>(json['localName']),
      category: serializer.fromJson<String>(json['category']),
      bodyPart: serializer.fromJson<String>(json['bodyPart']),
      equipment: serializer.fromJson<String>(json['equipment']),
      target: serializer.fromJson<String>(json['target']),
      secondaryMuscles: serializer.fromJson<String>(json['secondaryMuscles']),
      tier: serializer.fromJson<int>(json['tier']),
      mediaId: serializer.fromJson<String>(json['mediaId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'localName': serializer.toJson<String>(localName),
      'category': serializer.toJson<String>(category),
      'bodyPart': serializer.toJson<String>(bodyPart),
      'equipment': serializer.toJson<String>(equipment),
      'target': serializer.toJson<String>(target),
      'secondaryMuscles': serializer.toJson<String>(secondaryMuscles),
      'tier': serializer.toJson<int>(tier),
      'mediaId': serializer.toJson<String>(mediaId),
    };
  }

  ExerciseRow copyWith({
    String? id,
    String? name,
    String? localName,
    String? category,
    String? bodyPart,
    String? equipment,
    String? target,
    String? secondaryMuscles,
    int? tier,
    String? mediaId,
  }) => ExerciseRow(
    id: id ?? this.id,
    name: name ?? this.name,
    localName: localName ?? this.localName,
    category: category ?? this.category,
    bodyPart: bodyPart ?? this.bodyPart,
    equipment: equipment ?? this.equipment,
    target: target ?? this.target,
    secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
    tier: tier ?? this.tier,
    mediaId: mediaId ?? this.mediaId,
  );
  ExerciseRow copyWithCompanion(ExercisesCompanion data) {
    return ExerciseRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      localName: data.localName.present ? data.localName.value : this.localName,
      category: data.category.present ? data.category.value : this.category,
      bodyPart: data.bodyPart.present ? data.bodyPart.value : this.bodyPart,
      equipment: data.equipment.present ? data.equipment.value : this.equipment,
      target: data.target.present ? data.target.value : this.target,
      secondaryMuscles: data.secondaryMuscles.present
          ? data.secondaryMuscles.value
          : this.secondaryMuscles,
      tier: data.tier.present ? data.tier.value : this.tier,
      mediaId: data.mediaId.present ? data.mediaId.value : this.mediaId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('localName: $localName, ')
          ..write('category: $category, ')
          ..write('bodyPart: $bodyPart, ')
          ..write('equipment: $equipment, ')
          ..write('target: $target, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('tier: $tier, ')
          ..write('mediaId: $mediaId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    localName,
    category,
    bodyPart,
    equipment,
    target,
    secondaryMuscles,
    tier,
    mediaId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.localName == this.localName &&
          other.category == this.category &&
          other.bodyPart == this.bodyPart &&
          other.equipment == this.equipment &&
          other.target == this.target &&
          other.secondaryMuscles == this.secondaryMuscles &&
          other.tier == this.tier &&
          other.mediaId == this.mediaId);
}

class ExercisesCompanion extends UpdateCompanion<ExerciseRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> localName;
  final Value<String> category;
  final Value<String> bodyPart;
  final Value<String> equipment;
  final Value<String> target;
  final Value<String> secondaryMuscles;
  final Value<int> tier;
  final Value<String> mediaId;
  final Value<int> rowid;
  const ExercisesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.localName = const Value.absent(),
    this.category = const Value.absent(),
    this.bodyPart = const Value.absent(),
    this.equipment = const Value.absent(),
    this.target = const Value.absent(),
    this.secondaryMuscles = const Value.absent(),
    this.tier = const Value.absent(),
    this.mediaId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExercisesCompanion.insert({
    required String id,
    required String name,
    this.localName = const Value.absent(),
    required String category,
    required String bodyPart,
    required String equipment,
    required String target,
    this.secondaryMuscles = const Value.absent(),
    required int tier,
    this.mediaId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       bodyPart = Value(bodyPart),
       equipment = Value(equipment),
       target = Value(target),
       tier = Value(tier);
  static Insertable<ExerciseRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? localName,
    Expression<String>? category,
    Expression<String>? bodyPart,
    Expression<String>? equipment,
    Expression<String>? target,
    Expression<String>? secondaryMuscles,
    Expression<int>? tier,
    Expression<String>? mediaId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (localName != null) 'local_name': localName,
      if (category != null) 'category': category,
      if (bodyPart != null) 'body_part': bodyPart,
      if (equipment != null) 'equipment': equipment,
      if (target != null) 'target': target,
      if (secondaryMuscles != null) 'secondary_muscles': secondaryMuscles,
      if (tier != null) 'tier': tier,
      if (mediaId != null) 'media_id': mediaId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExercisesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? localName,
    Value<String>? category,
    Value<String>? bodyPart,
    Value<String>? equipment,
    Value<String>? target,
    Value<String>? secondaryMuscles,
    Value<int>? tier,
    Value<String>? mediaId,
    Value<int>? rowid,
  }) {
    return ExercisesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      localName: localName ?? this.localName,
      category: category ?? this.category,
      bodyPart: bodyPart ?? this.bodyPart,
      equipment: equipment ?? this.equipment,
      target: target ?? this.target,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      tier: tier ?? this.tier,
      mediaId: mediaId ?? this.mediaId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (localName.present) {
      map['local_name'] = Variable<String>(localName.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (bodyPart.present) {
      map['body_part'] = Variable<String>(bodyPart.value);
    }
    if (equipment.present) {
      map['equipment'] = Variable<String>(equipment.value);
    }
    if (target.present) {
      map['target'] = Variable<String>(target.value);
    }
    if (secondaryMuscles.present) {
      map['secondary_muscles'] = Variable<String>(secondaryMuscles.value);
    }
    if (tier.present) {
      map['tier'] = Variable<int>(tier.value);
    }
    if (mediaId.present) {
      map['media_id'] = Variable<String>(mediaId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExercisesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('localName: $localName, ')
          ..write('category: $category, ')
          ..write('bodyPart: $bodyPart, ')
          ..write('equipment: $equipment, ')
          ..write('target: $target, ')
          ..write('secondaryMuscles: $secondaryMuscles, ')
          ..write('tier: $tier, ')
          ..write('mediaId: $mediaId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExerciseDetailsTable extends ExerciseDetails
    with TableInfo<$ExerciseDetailsTable, ExerciseDetailRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExerciseDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES exercises (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _stepsMeta = const VerificationMeta('steps');
  @override
  late final GeneratedColumn<String> steps = GeneratedColumn<String>(
    'steps',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [exerciseId, steps];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exercise_details';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExerciseDetailRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('steps')) {
      context.handle(
        _stepsMeta,
        steps.isAcceptableOrUnknown(data['steps']!, _stepsMeta),
      );
    } else if (isInserting) {
      context.missing(_stepsMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {exerciseId};
  @override
  ExerciseDetailRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExerciseDetailRow(
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      steps: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}steps'],
      )!,
    );
  }

  @override
  $ExerciseDetailsTable createAlias(String alias) {
    return $ExerciseDetailsTable(attachedDatabase, alias);
  }
}

class ExerciseDetailRow extends DataClass
    implements Insertable<ExerciseDetailRow> {
  final String exerciseId;
  final String steps;
  const ExerciseDetailRow({required this.exerciseId, required this.steps});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['exercise_id'] = Variable<String>(exerciseId);
    map['steps'] = Variable<String>(steps);
    return map;
  }

  ExerciseDetailsCompanion toCompanion(bool nullToAbsent) {
    return ExerciseDetailsCompanion(
      exerciseId: Value(exerciseId),
      steps: Value(steps),
    );
  }

  factory ExerciseDetailRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExerciseDetailRow(
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      steps: serializer.fromJson<String>(json['steps']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'exerciseId': serializer.toJson<String>(exerciseId),
      'steps': serializer.toJson<String>(steps),
    };
  }

  ExerciseDetailRow copyWith({String? exerciseId, String? steps}) =>
      ExerciseDetailRow(
        exerciseId: exerciseId ?? this.exerciseId,
        steps: steps ?? this.steps,
      );
  ExerciseDetailRow copyWithCompanion(ExerciseDetailsCompanion data) {
    return ExerciseDetailRow(
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      steps: data.steps.present ? data.steps.value : this.steps,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseDetailRow(')
          ..write('exerciseId: $exerciseId, ')
          ..write('steps: $steps')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(exerciseId, steps);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExerciseDetailRow &&
          other.exerciseId == this.exerciseId &&
          other.steps == this.steps);
}

class ExerciseDetailsCompanion extends UpdateCompanion<ExerciseDetailRow> {
  final Value<String> exerciseId;
  final Value<String> steps;
  final Value<int> rowid;
  const ExerciseDetailsCompanion({
    this.exerciseId = const Value.absent(),
    this.steps = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExerciseDetailsCompanion.insert({
    required String exerciseId,
    required String steps,
    this.rowid = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       steps = Value(steps);
  static Insertable<ExerciseDetailRow> custom({
    Expression<String>? exerciseId,
    Expression<String>? steps,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (steps != null) 'steps': steps,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExerciseDetailsCompanion copyWith({
    Value<String>? exerciseId,
    Value<String>? steps,
    Value<int>? rowid,
  }) {
    return ExerciseDetailsCompanion(
      exerciseId: exerciseId ?? this.exerciseId,
      steps: steps ?? this.steps,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (steps.present) {
      map['steps'] = Variable<String>(steps.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExerciseDetailsCompanion(')
          ..write('exerciseId: $exerciseId, ')
          ..write('steps: $steps, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WorkoutSessionsTable extends WorkoutSessions
    with TableInfo<$WorkoutSessionsTable, WorkoutSessionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WorkoutSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<int> tier = GeneratedColumn<int>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _finishedAtMeta = const VerificationMeta(
    'finishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> finishedAt = GeneratedColumn<DateTime>(
    'finished_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _plateDiameterCmMeta = const VerificationMeta(
    'plateDiameterCm',
  );
  @override
  late final GeneratedColumn<double> plateDiameterCm = GeneratedColumn<double>(
    'plate_diameter_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(45),
  );
  static const VerificationMeta _scaleMetersPerPixelMeta =
      const VerificationMeta('scaleMetersPerPixel');
  @override
  late final GeneratedColumn<double> scaleMetersPerPixel =
      GeneratedColumn<double>(
        'scale_meters_per_pixel',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _totalRepsMeta = const VerificationMeta(
    'totalReps',
  );
  @override
  late final GeneratedColumn<int> totalReps = GeneratedColumn<int>(
    'total_reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _invalidRepsMeta = const VerificationMeta(
    'invalidReps',
  );
  @override
  late final GeneratedColumn<int> invalidReps = GeneratedColumn<int>(
    'invalid_reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _avgMeanVelocityMeta = const VerificationMeta(
    'avgMeanVelocity',
  );
  @override
  late final GeneratedColumn<double> avgMeanVelocity = GeneratedColumn<double>(
    'avg_mean_velocity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestMeanVelocityMeta = const VerificationMeta(
    'bestMeanVelocity',
  );
  @override
  late final GeneratedColumn<double> bestMeanVelocity = GeneratedColumn<double>(
    'best_mean_velocity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peakVelocityMeta = const VerificationMeta(
    'peakVelocity',
  );
  @override
  late final GeneratedColumn<double> peakVelocity = GeneratedColumn<double>(
    'peak_velocity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bestRomCmMeta = const VerificationMeta(
    'bestRomCm',
  );
  @override
  late final GeneratedColumn<double> bestRomCm = GeneratedColumn<double>(
    'best_rom_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _velocityLossMeta = const VerificationMeta(
    'velocityLoss',
  );
  @override
  late final GeneratedColumn<double> velocityLoss = GeneratedColumn<double>(
    'velocity_loss',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseId,
    exerciseName,
    tier,
    startedAt,
    finishedAt,
    weightKg,
    plateDiameterCm,
    scaleMetersPerPixel,
    totalReps,
    invalidReps,
    avgMeanVelocity,
    bestMeanVelocity,
    peakVelocity,
    bestRomCm,
    velocityLoss,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'workout_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<WorkoutSessionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseNameMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('finished_at')) {
      context.handle(
        _finishedAtMeta,
        finishedAt.isAcceptableOrUnknown(data['finished_at']!, _finishedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_finishedAtMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('plate_diameter_cm')) {
      context.handle(
        _plateDiameterCmMeta,
        plateDiameterCm.isAcceptableOrUnknown(
          data['plate_diameter_cm']!,
          _plateDiameterCmMeta,
        ),
      );
    }
    if (data.containsKey('scale_meters_per_pixel')) {
      context.handle(
        _scaleMetersPerPixelMeta,
        scaleMetersPerPixel.isAcceptableOrUnknown(
          data['scale_meters_per_pixel']!,
          _scaleMetersPerPixelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_scaleMetersPerPixelMeta);
    }
    if (data.containsKey('total_reps')) {
      context.handle(
        _totalRepsMeta,
        totalReps.isAcceptableOrUnknown(data['total_reps']!, _totalRepsMeta),
      );
    } else if (isInserting) {
      context.missing(_totalRepsMeta);
    }
    if (data.containsKey('invalid_reps')) {
      context.handle(
        _invalidRepsMeta,
        invalidReps.isAcceptableOrUnknown(
          data['invalid_reps']!,
          _invalidRepsMeta,
        ),
      );
    }
    if (data.containsKey('avg_mean_velocity')) {
      context.handle(
        _avgMeanVelocityMeta,
        avgMeanVelocity.isAcceptableOrUnknown(
          data['avg_mean_velocity']!,
          _avgMeanVelocityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_avgMeanVelocityMeta);
    }
    if (data.containsKey('best_mean_velocity')) {
      context.handle(
        _bestMeanVelocityMeta,
        bestMeanVelocity.isAcceptableOrUnknown(
          data['best_mean_velocity']!,
          _bestMeanVelocityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_bestMeanVelocityMeta);
    }
    if (data.containsKey('peak_velocity')) {
      context.handle(
        _peakVelocityMeta,
        peakVelocity.isAcceptableOrUnknown(
          data['peak_velocity']!,
          _peakVelocityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_peakVelocityMeta);
    }
    if (data.containsKey('best_rom_cm')) {
      context.handle(
        _bestRomCmMeta,
        bestRomCm.isAcceptableOrUnknown(data['best_rom_cm']!, _bestRomCmMeta),
      );
    } else if (isInserting) {
      context.missing(_bestRomCmMeta);
    }
    if (data.containsKey('velocity_loss')) {
      context.handle(
        _velocityLossMeta,
        velocityLoss.isAcceptableOrUnknown(
          data['velocity_loss']!,
          _velocityLossMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_velocityLossMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WorkoutSessionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WorkoutSessionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tier'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      finishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}finished_at'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      plateDiameterCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}plate_diameter_cm'],
      )!,
      scaleMetersPerPixel: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}scale_meters_per_pixel'],
      )!,
      totalReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_reps'],
      )!,
      invalidReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}invalid_reps'],
      )!,
      avgMeanVelocity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}avg_mean_velocity'],
      )!,
      bestMeanVelocity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}best_mean_velocity'],
      )!,
      peakVelocity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peak_velocity'],
      )!,
      bestRomCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}best_rom_cm'],
      )!,
      velocityLoss: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}velocity_loss'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $WorkoutSessionsTable createAlias(String alias) {
    return $WorkoutSessionsTable(attachedDatabase, alias);
  }
}

class WorkoutSessionRow extends DataClass
    implements Insertable<WorkoutSessionRow> {
  final int id;
  final String exerciseId;
  final String exerciseName;
  final int tier;
  final DateTime startedAt;
  final DateTime finishedAt;
  final double weightKg;
  final double plateDiameterCm;
  final double scaleMetersPerPixel;
  final int totalReps;
  final int invalidReps;
  final double avgMeanVelocity;
  final double bestMeanVelocity;
  final double peakVelocity;
  final double bestRomCm;
  final double velocityLoss;
  final String notes;
  const WorkoutSessionRow({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.tier,
    required this.startedAt,
    required this.finishedAt,
    required this.weightKg,
    required this.plateDiameterCm,
    required this.scaleMetersPerPixel,
    required this.totalReps,
    required this.invalidReps,
    required this.avgMeanVelocity,
    required this.bestMeanVelocity,
    required this.peakVelocity,
    required this.bestRomCm,
    required this.velocityLoss,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['exercise_name'] = Variable<String>(exerciseName);
    map['tier'] = Variable<int>(tier);
    map['started_at'] = Variable<DateTime>(startedAt);
    map['finished_at'] = Variable<DateTime>(finishedAt);
    map['weight_kg'] = Variable<double>(weightKg);
    map['plate_diameter_cm'] = Variable<double>(plateDiameterCm);
    map['scale_meters_per_pixel'] = Variable<double>(scaleMetersPerPixel);
    map['total_reps'] = Variable<int>(totalReps);
    map['invalid_reps'] = Variable<int>(invalidReps);
    map['avg_mean_velocity'] = Variable<double>(avgMeanVelocity);
    map['best_mean_velocity'] = Variable<double>(bestMeanVelocity);
    map['peak_velocity'] = Variable<double>(peakVelocity);
    map['best_rom_cm'] = Variable<double>(bestRomCm);
    map['velocity_loss'] = Variable<double>(velocityLoss);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  WorkoutSessionsCompanion toCompanion(bool nullToAbsent) {
    return WorkoutSessionsCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      exerciseName: Value(exerciseName),
      tier: Value(tier),
      startedAt: Value(startedAt),
      finishedAt: Value(finishedAt),
      weightKg: Value(weightKg),
      plateDiameterCm: Value(plateDiameterCm),
      scaleMetersPerPixel: Value(scaleMetersPerPixel),
      totalReps: Value(totalReps),
      invalidReps: Value(invalidReps),
      avgMeanVelocity: Value(avgMeanVelocity),
      bestMeanVelocity: Value(bestMeanVelocity),
      peakVelocity: Value(peakVelocity),
      bestRomCm: Value(bestRomCm),
      velocityLoss: Value(velocityLoss),
      notes: Value(notes),
    );
  }

  factory WorkoutSessionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WorkoutSessionRow(
      id: serializer.fromJson<int>(json['id']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      exerciseName: serializer.fromJson<String>(json['exerciseName']),
      tier: serializer.fromJson<int>(json['tier']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      finishedAt: serializer.fromJson<DateTime>(json['finishedAt']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      plateDiameterCm: serializer.fromJson<double>(json['plateDiameterCm']),
      scaleMetersPerPixel: serializer.fromJson<double>(
        json['scaleMetersPerPixel'],
      ),
      totalReps: serializer.fromJson<int>(json['totalReps']),
      invalidReps: serializer.fromJson<int>(json['invalidReps']),
      avgMeanVelocity: serializer.fromJson<double>(json['avgMeanVelocity']),
      bestMeanVelocity: serializer.fromJson<double>(json['bestMeanVelocity']),
      peakVelocity: serializer.fromJson<double>(json['peakVelocity']),
      bestRomCm: serializer.fromJson<double>(json['bestRomCm']),
      velocityLoss: serializer.fromJson<double>(json['velocityLoss']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'exerciseName': serializer.toJson<String>(exerciseName),
      'tier': serializer.toJson<int>(tier),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'finishedAt': serializer.toJson<DateTime>(finishedAt),
      'weightKg': serializer.toJson<double>(weightKg),
      'plateDiameterCm': serializer.toJson<double>(plateDiameterCm),
      'scaleMetersPerPixel': serializer.toJson<double>(scaleMetersPerPixel),
      'totalReps': serializer.toJson<int>(totalReps),
      'invalidReps': serializer.toJson<int>(invalidReps),
      'avgMeanVelocity': serializer.toJson<double>(avgMeanVelocity),
      'bestMeanVelocity': serializer.toJson<double>(bestMeanVelocity),
      'peakVelocity': serializer.toJson<double>(peakVelocity),
      'bestRomCm': serializer.toJson<double>(bestRomCm),
      'velocityLoss': serializer.toJson<double>(velocityLoss),
      'notes': serializer.toJson<String>(notes),
    };
  }

  WorkoutSessionRow copyWith({
    int? id,
    String? exerciseId,
    String? exerciseName,
    int? tier,
    DateTime? startedAt,
    DateTime? finishedAt,
    double? weightKg,
    double? plateDiameterCm,
    double? scaleMetersPerPixel,
    int? totalReps,
    int? invalidReps,
    double? avgMeanVelocity,
    double? bestMeanVelocity,
    double? peakVelocity,
    double? bestRomCm,
    double? velocityLoss,
    String? notes,
  }) => WorkoutSessionRow(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    exerciseName: exerciseName ?? this.exerciseName,
    tier: tier ?? this.tier,
    startedAt: startedAt ?? this.startedAt,
    finishedAt: finishedAt ?? this.finishedAt,
    weightKg: weightKg ?? this.weightKg,
    plateDiameterCm: plateDiameterCm ?? this.plateDiameterCm,
    scaleMetersPerPixel: scaleMetersPerPixel ?? this.scaleMetersPerPixel,
    totalReps: totalReps ?? this.totalReps,
    invalidReps: invalidReps ?? this.invalidReps,
    avgMeanVelocity: avgMeanVelocity ?? this.avgMeanVelocity,
    bestMeanVelocity: bestMeanVelocity ?? this.bestMeanVelocity,
    peakVelocity: peakVelocity ?? this.peakVelocity,
    bestRomCm: bestRomCm ?? this.bestRomCm,
    velocityLoss: velocityLoss ?? this.velocityLoss,
    notes: notes ?? this.notes,
  );
  WorkoutSessionRow copyWithCompanion(WorkoutSessionsCompanion data) {
    return WorkoutSessionRow(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      tier: data.tier.present ? data.tier.value : this.tier,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      finishedAt: data.finishedAt.present
          ? data.finishedAt.value
          : this.finishedAt,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      plateDiameterCm: data.plateDiameterCm.present
          ? data.plateDiameterCm.value
          : this.plateDiameterCm,
      scaleMetersPerPixel: data.scaleMetersPerPixel.present
          ? data.scaleMetersPerPixel.value
          : this.scaleMetersPerPixel,
      totalReps: data.totalReps.present ? data.totalReps.value : this.totalReps,
      invalidReps: data.invalidReps.present
          ? data.invalidReps.value
          : this.invalidReps,
      avgMeanVelocity: data.avgMeanVelocity.present
          ? data.avgMeanVelocity.value
          : this.avgMeanVelocity,
      bestMeanVelocity: data.bestMeanVelocity.present
          ? data.bestMeanVelocity.value
          : this.bestMeanVelocity,
      peakVelocity: data.peakVelocity.present
          ? data.peakVelocity.value
          : this.peakVelocity,
      bestRomCm: data.bestRomCm.present ? data.bestRomCm.value : this.bestRomCm,
      velocityLoss: data.velocityLoss.present
          ? data.velocityLoss.value
          : this.velocityLoss,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionRow(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('tier: $tier, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('plateDiameterCm: $plateDiameterCm, ')
          ..write('scaleMetersPerPixel: $scaleMetersPerPixel, ')
          ..write('totalReps: $totalReps, ')
          ..write('invalidReps: $invalidReps, ')
          ..write('avgMeanVelocity: $avgMeanVelocity, ')
          ..write('bestMeanVelocity: $bestMeanVelocity, ')
          ..write('peakVelocity: $peakVelocity, ')
          ..write('bestRomCm: $bestRomCm, ')
          ..write('velocityLoss: $velocityLoss, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    exerciseId,
    exerciseName,
    tier,
    startedAt,
    finishedAt,
    weightKg,
    plateDiameterCm,
    scaleMetersPerPixel,
    totalReps,
    invalidReps,
    avgMeanVelocity,
    bestMeanVelocity,
    peakVelocity,
    bestRomCm,
    velocityLoss,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WorkoutSessionRow &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.exerciseName == this.exerciseName &&
          other.tier == this.tier &&
          other.startedAt == this.startedAt &&
          other.finishedAt == this.finishedAt &&
          other.weightKg == this.weightKg &&
          other.plateDiameterCm == this.plateDiameterCm &&
          other.scaleMetersPerPixel == this.scaleMetersPerPixel &&
          other.totalReps == this.totalReps &&
          other.invalidReps == this.invalidReps &&
          other.avgMeanVelocity == this.avgMeanVelocity &&
          other.bestMeanVelocity == this.bestMeanVelocity &&
          other.peakVelocity == this.peakVelocity &&
          other.bestRomCm == this.bestRomCm &&
          other.velocityLoss == this.velocityLoss &&
          other.notes == this.notes);
}

class WorkoutSessionsCompanion extends UpdateCompanion<WorkoutSessionRow> {
  final Value<int> id;
  final Value<String> exerciseId;
  final Value<String> exerciseName;
  final Value<int> tier;
  final Value<DateTime> startedAt;
  final Value<DateTime> finishedAt;
  final Value<double> weightKg;
  final Value<double> plateDiameterCm;
  final Value<double> scaleMetersPerPixel;
  final Value<int> totalReps;
  final Value<int> invalidReps;
  final Value<double> avgMeanVelocity;
  final Value<double> bestMeanVelocity;
  final Value<double> peakVelocity;
  final Value<double> bestRomCm;
  final Value<double> velocityLoss;
  final Value<String> notes;
  const WorkoutSessionsCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.tier = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.finishedAt = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.plateDiameterCm = const Value.absent(),
    this.scaleMetersPerPixel = const Value.absent(),
    this.totalReps = const Value.absent(),
    this.invalidReps = const Value.absent(),
    this.avgMeanVelocity = const Value.absent(),
    this.bestMeanVelocity = const Value.absent(),
    this.peakVelocity = const Value.absent(),
    this.bestRomCm = const Value.absent(),
    this.velocityLoss = const Value.absent(),
    this.notes = const Value.absent(),
  });
  WorkoutSessionsCompanion.insert({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    required String exerciseName,
    required int tier,
    required DateTime startedAt,
    required DateTime finishedAt,
    this.weightKg = const Value.absent(),
    this.plateDiameterCm = const Value.absent(),
    required double scaleMetersPerPixel,
    required int totalReps,
    this.invalidReps = const Value.absent(),
    required double avgMeanVelocity,
    required double bestMeanVelocity,
    required double peakVelocity,
    required double bestRomCm,
    required double velocityLoss,
    this.notes = const Value.absent(),
  }) : exerciseName = Value(exerciseName),
       tier = Value(tier),
       startedAt = Value(startedAt),
       finishedAt = Value(finishedAt),
       scaleMetersPerPixel = Value(scaleMetersPerPixel),
       totalReps = Value(totalReps),
       avgMeanVelocity = Value(avgMeanVelocity),
       bestMeanVelocity = Value(bestMeanVelocity),
       peakVelocity = Value(peakVelocity),
       bestRomCm = Value(bestRomCm),
       velocityLoss = Value(velocityLoss);
  static Insertable<WorkoutSessionRow> custom({
    Expression<int>? id,
    Expression<String>? exerciseId,
    Expression<String>? exerciseName,
    Expression<int>? tier,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? finishedAt,
    Expression<double>? weightKg,
    Expression<double>? plateDiameterCm,
    Expression<double>? scaleMetersPerPixel,
    Expression<int>? totalReps,
    Expression<int>? invalidReps,
    Expression<double>? avgMeanVelocity,
    Expression<double>? bestMeanVelocity,
    Expression<double>? peakVelocity,
    Expression<double>? bestRomCm,
    Expression<double>? velocityLoss,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (tier != null) 'tier': tier,
      if (startedAt != null) 'started_at': startedAt,
      if (finishedAt != null) 'finished_at': finishedAt,
      if (weightKg != null) 'weight_kg': weightKg,
      if (plateDiameterCm != null) 'plate_diameter_cm': plateDiameterCm,
      if (scaleMetersPerPixel != null)
        'scale_meters_per_pixel': scaleMetersPerPixel,
      if (totalReps != null) 'total_reps': totalReps,
      if (invalidReps != null) 'invalid_reps': invalidReps,
      if (avgMeanVelocity != null) 'avg_mean_velocity': avgMeanVelocity,
      if (bestMeanVelocity != null) 'best_mean_velocity': bestMeanVelocity,
      if (peakVelocity != null) 'peak_velocity': peakVelocity,
      if (bestRomCm != null) 'best_rom_cm': bestRomCm,
      if (velocityLoss != null) 'velocity_loss': velocityLoss,
      if (notes != null) 'notes': notes,
    });
  }

  WorkoutSessionsCompanion copyWith({
    Value<int>? id,
    Value<String>? exerciseId,
    Value<String>? exerciseName,
    Value<int>? tier,
    Value<DateTime>? startedAt,
    Value<DateTime>? finishedAt,
    Value<double>? weightKg,
    Value<double>? plateDiameterCm,
    Value<double>? scaleMetersPerPixel,
    Value<int>? totalReps,
    Value<int>? invalidReps,
    Value<double>? avgMeanVelocity,
    Value<double>? bestMeanVelocity,
    Value<double>? peakVelocity,
    Value<double>? bestRomCm,
    Value<double>? velocityLoss,
    Value<String>? notes,
  }) {
    return WorkoutSessionsCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      tier: tier ?? this.tier,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      weightKg: weightKg ?? this.weightKg,
      plateDiameterCm: plateDiameterCm ?? this.plateDiameterCm,
      scaleMetersPerPixel: scaleMetersPerPixel ?? this.scaleMetersPerPixel,
      totalReps: totalReps ?? this.totalReps,
      invalidReps: invalidReps ?? this.invalidReps,
      avgMeanVelocity: avgMeanVelocity ?? this.avgMeanVelocity,
      bestMeanVelocity: bestMeanVelocity ?? this.bestMeanVelocity,
      peakVelocity: peakVelocity ?? this.peakVelocity,
      bestRomCm: bestRomCm ?? this.bestRomCm,
      velocityLoss: velocityLoss ?? this.velocityLoss,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (tier.present) {
      map['tier'] = Variable<int>(tier.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (finishedAt.present) {
      map['finished_at'] = Variable<DateTime>(finishedAt.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (plateDiameterCm.present) {
      map['plate_diameter_cm'] = Variable<double>(plateDiameterCm.value);
    }
    if (scaleMetersPerPixel.present) {
      map['scale_meters_per_pixel'] = Variable<double>(
        scaleMetersPerPixel.value,
      );
    }
    if (totalReps.present) {
      map['total_reps'] = Variable<int>(totalReps.value);
    }
    if (invalidReps.present) {
      map['invalid_reps'] = Variable<int>(invalidReps.value);
    }
    if (avgMeanVelocity.present) {
      map['avg_mean_velocity'] = Variable<double>(avgMeanVelocity.value);
    }
    if (bestMeanVelocity.present) {
      map['best_mean_velocity'] = Variable<double>(bestMeanVelocity.value);
    }
    if (peakVelocity.present) {
      map['peak_velocity'] = Variable<double>(peakVelocity.value);
    }
    if (bestRomCm.present) {
      map['best_rom_cm'] = Variable<double>(bestRomCm.value);
    }
    if (velocityLoss.present) {
      map['velocity_loss'] = Variable<double>(velocityLoss.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WorkoutSessionsCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('tier: $tier, ')
          ..write('startedAt: $startedAt, ')
          ..write('finishedAt: $finishedAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('plateDiameterCm: $plateDiameterCm, ')
          ..write('scaleMetersPerPixel: $scaleMetersPerPixel, ')
          ..write('totalReps: $totalReps, ')
          ..write('invalidReps: $invalidReps, ')
          ..write('avgMeanVelocity: $avgMeanVelocity, ')
          ..write('bestMeanVelocity: $bestMeanVelocity, ')
          ..write('peakVelocity: $peakVelocity, ')
          ..write('bestRomCm: $bestRomCm, ')
          ..write('velocityLoss: $velocityLoss, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $RepRecordsTable extends RepRecords
    with TableInfo<$RepRecordsTable, RepRecordRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RepRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sessionIdMeta = const VerificationMeta(
    'sessionId',
  );
  @override
  late final GeneratedColumn<int> sessionId = GeneratedColumn<int>(
    'session_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES workout_sessions (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _repIndexMeta = const VerificationMeta(
    'repIndex',
  );
  @override
  late final GeneratedColumn<int> repIndex = GeneratedColumn<int>(
    'rep_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _meanVelocityMeta = const VerificationMeta(
    'meanVelocity',
  );
  @override
  late final GeneratedColumn<double> meanVelocity = GeneratedColumn<double>(
    'mean_velocity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _peakVelocityMeta = const VerificationMeta(
    'peakVelocity',
  );
  @override
  late final GeneratedColumn<double> peakVelocity = GeneratedColumn<double>(
    'peak_velocity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _romCmMeta = const VerificationMeta('romCm');
  @override
  late final GeneratedColumn<double> romCm = GeneratedColumn<double>(
    'rom_cm',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _velocityLossPercentMeta =
      const VerificationMeta('velocityLossPercent');
  @override
  late final GeneratedColumn<double> velocityLossPercent =
      GeneratedColumn<double>(
        'velocity_loss_percent',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: true,
      );
  static const VerificationMeta _durationMsMeta = const VerificationMeta(
    'durationMs',
  );
  @override
  late final GeneratedColumn<int> durationMs = GeneratedColumn<int>(
    'duration_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eccentricMsMeta = const VerificationMeta(
    'eccentricMs',
  );
  @override
  late final GeneratedColumn<int> eccentricMs = GeneratedColumn<int>(
    'eccentric_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _concentricMsMeta = const VerificationMeta(
    'concentricMs',
  );
  @override
  late final GeneratedColumn<int> concentricMs = GeneratedColumn<int>(
    'concentric_ms',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minHipAngleMeta = const VerificationMeta(
    'minHipAngle',
  );
  @override
  late final GeneratedColumn<double> minHipAngle = GeneratedColumn<double>(
    'min_hip_angle',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minKneeAngleMeta = const VerificationMeta(
    'minKneeAngle',
  );
  @override
  late final GeneratedColumn<double> minKneeAngle = GeneratedColumn<double>(
    'min_knee_angle',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isBestRepMeta = const VerificationMeta(
    'isBestRep',
  );
  @override
  late final GeneratedColumn<bool> isBestRep = GeneratedColumn<bool>(
    'is_best_rep',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_best_rep" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sessionId,
    repIndex,
    meanVelocity,
    peakVelocity,
    romCm,
    velocityLossPercent,
    durationMs,
    eccentricMs,
    concentricMs,
    minHipAngle,
    minKneeAngle,
    isBestRep,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'rep_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<RepRecordRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('session_id')) {
      context.handle(
        _sessionIdMeta,
        sessionId.isAcceptableOrUnknown(data['session_id']!, _sessionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_sessionIdMeta);
    }
    if (data.containsKey('rep_index')) {
      context.handle(
        _repIndexMeta,
        repIndex.isAcceptableOrUnknown(data['rep_index']!, _repIndexMeta),
      );
    } else if (isInserting) {
      context.missing(_repIndexMeta);
    }
    if (data.containsKey('mean_velocity')) {
      context.handle(
        _meanVelocityMeta,
        meanVelocity.isAcceptableOrUnknown(
          data['mean_velocity']!,
          _meanVelocityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_meanVelocityMeta);
    }
    if (data.containsKey('peak_velocity')) {
      context.handle(
        _peakVelocityMeta,
        peakVelocity.isAcceptableOrUnknown(
          data['peak_velocity']!,
          _peakVelocityMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_peakVelocityMeta);
    }
    if (data.containsKey('rom_cm')) {
      context.handle(
        _romCmMeta,
        romCm.isAcceptableOrUnknown(data['rom_cm']!, _romCmMeta),
      );
    } else if (isInserting) {
      context.missing(_romCmMeta);
    }
    if (data.containsKey('velocity_loss_percent')) {
      context.handle(
        _velocityLossPercentMeta,
        velocityLossPercent.isAcceptableOrUnknown(
          data['velocity_loss_percent']!,
          _velocityLossPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_velocityLossPercentMeta);
    }
    if (data.containsKey('duration_ms')) {
      context.handle(
        _durationMsMeta,
        durationMs.isAcceptableOrUnknown(data['duration_ms']!, _durationMsMeta),
      );
    } else if (isInserting) {
      context.missing(_durationMsMeta);
    }
    if (data.containsKey('eccentric_ms')) {
      context.handle(
        _eccentricMsMeta,
        eccentricMs.isAcceptableOrUnknown(
          data['eccentric_ms']!,
          _eccentricMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_eccentricMsMeta);
    }
    if (data.containsKey('concentric_ms')) {
      context.handle(
        _concentricMsMeta,
        concentricMs.isAcceptableOrUnknown(
          data['concentric_ms']!,
          _concentricMsMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_concentricMsMeta);
    }
    if (data.containsKey('min_hip_angle')) {
      context.handle(
        _minHipAngleMeta,
        minHipAngle.isAcceptableOrUnknown(
          data['min_hip_angle']!,
          _minHipAngleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minHipAngleMeta);
    }
    if (data.containsKey('min_knee_angle')) {
      context.handle(
        _minKneeAngleMeta,
        minKneeAngle.isAcceptableOrUnknown(
          data['min_knee_angle']!,
          _minKneeAngleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minKneeAngleMeta);
    }
    if (data.containsKey('is_best_rep')) {
      context.handle(
        _isBestRepMeta,
        isBestRep.isAcceptableOrUnknown(data['is_best_rep']!, _isBestRepMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RepRecordRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepRecordRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sessionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}session_id'],
      )!,
      repIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rep_index'],
      )!,
      meanVelocity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}mean_velocity'],
      )!,
      peakVelocity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}peak_velocity'],
      )!,
      romCm: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rom_cm'],
      )!,
      velocityLossPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}velocity_loss_percent'],
      )!,
      durationMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_ms'],
      )!,
      eccentricMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}eccentric_ms'],
      )!,
      concentricMs: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}concentric_ms'],
      )!,
      minHipAngle: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_hip_angle'],
      )!,
      minKneeAngle: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}min_knee_angle'],
      )!,
      isBestRep: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_best_rep'],
      )!,
    );
  }

  @override
  $RepRecordsTable createAlias(String alias) {
    return $RepRecordsTable(attachedDatabase, alias);
  }
}

class RepRecordRow extends DataClass implements Insertable<RepRecordRow> {
  final int id;
  final int sessionId;
  final int repIndex;
  final double meanVelocity;
  final double peakVelocity;
  final double romCm;
  final double velocityLossPercent;
  final int durationMs;
  final int eccentricMs;
  final int concentricMs;
  final double minHipAngle;
  final double minKneeAngle;
  final bool isBestRep;
  const RepRecordRow({
    required this.id,
    required this.sessionId,
    required this.repIndex,
    required this.meanVelocity,
    required this.peakVelocity,
    required this.romCm,
    required this.velocityLossPercent,
    required this.durationMs,
    required this.eccentricMs,
    required this.concentricMs,
    required this.minHipAngle,
    required this.minKneeAngle,
    required this.isBestRep,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['session_id'] = Variable<int>(sessionId);
    map['rep_index'] = Variable<int>(repIndex);
    map['mean_velocity'] = Variable<double>(meanVelocity);
    map['peak_velocity'] = Variable<double>(peakVelocity);
    map['rom_cm'] = Variable<double>(romCm);
    map['velocity_loss_percent'] = Variable<double>(velocityLossPercent);
    map['duration_ms'] = Variable<int>(durationMs);
    map['eccentric_ms'] = Variable<int>(eccentricMs);
    map['concentric_ms'] = Variable<int>(concentricMs);
    map['min_hip_angle'] = Variable<double>(minHipAngle);
    map['min_knee_angle'] = Variable<double>(minKneeAngle);
    map['is_best_rep'] = Variable<bool>(isBestRep);
    return map;
  }

  RepRecordsCompanion toCompanion(bool nullToAbsent) {
    return RepRecordsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      repIndex: Value(repIndex),
      meanVelocity: Value(meanVelocity),
      peakVelocity: Value(peakVelocity),
      romCm: Value(romCm),
      velocityLossPercent: Value(velocityLossPercent),
      durationMs: Value(durationMs),
      eccentricMs: Value(eccentricMs),
      concentricMs: Value(concentricMs),
      minHipAngle: Value(minHipAngle),
      minKneeAngle: Value(minKneeAngle),
      isBestRep: Value(isBestRep),
    );
  }

  factory RepRecordRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepRecordRow(
      id: serializer.fromJson<int>(json['id']),
      sessionId: serializer.fromJson<int>(json['sessionId']),
      repIndex: serializer.fromJson<int>(json['repIndex']),
      meanVelocity: serializer.fromJson<double>(json['meanVelocity']),
      peakVelocity: serializer.fromJson<double>(json['peakVelocity']),
      romCm: serializer.fromJson<double>(json['romCm']),
      velocityLossPercent: serializer.fromJson<double>(
        json['velocityLossPercent'],
      ),
      durationMs: serializer.fromJson<int>(json['durationMs']),
      eccentricMs: serializer.fromJson<int>(json['eccentricMs']),
      concentricMs: serializer.fromJson<int>(json['concentricMs']),
      minHipAngle: serializer.fromJson<double>(json['minHipAngle']),
      minKneeAngle: serializer.fromJson<double>(json['minKneeAngle']),
      isBestRep: serializer.fromJson<bool>(json['isBestRep']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sessionId': serializer.toJson<int>(sessionId),
      'repIndex': serializer.toJson<int>(repIndex),
      'meanVelocity': serializer.toJson<double>(meanVelocity),
      'peakVelocity': serializer.toJson<double>(peakVelocity),
      'romCm': serializer.toJson<double>(romCm),
      'velocityLossPercent': serializer.toJson<double>(velocityLossPercent),
      'durationMs': serializer.toJson<int>(durationMs),
      'eccentricMs': serializer.toJson<int>(eccentricMs),
      'concentricMs': serializer.toJson<int>(concentricMs),
      'minHipAngle': serializer.toJson<double>(minHipAngle),
      'minKneeAngle': serializer.toJson<double>(minKneeAngle),
      'isBestRep': serializer.toJson<bool>(isBestRep),
    };
  }

  RepRecordRow copyWith({
    int? id,
    int? sessionId,
    int? repIndex,
    double? meanVelocity,
    double? peakVelocity,
    double? romCm,
    double? velocityLossPercent,
    int? durationMs,
    int? eccentricMs,
    int? concentricMs,
    double? minHipAngle,
    double? minKneeAngle,
    bool? isBestRep,
  }) => RepRecordRow(
    id: id ?? this.id,
    sessionId: sessionId ?? this.sessionId,
    repIndex: repIndex ?? this.repIndex,
    meanVelocity: meanVelocity ?? this.meanVelocity,
    peakVelocity: peakVelocity ?? this.peakVelocity,
    romCm: romCm ?? this.romCm,
    velocityLossPercent: velocityLossPercent ?? this.velocityLossPercent,
    durationMs: durationMs ?? this.durationMs,
    eccentricMs: eccentricMs ?? this.eccentricMs,
    concentricMs: concentricMs ?? this.concentricMs,
    minHipAngle: minHipAngle ?? this.minHipAngle,
    minKneeAngle: minKneeAngle ?? this.minKneeAngle,
    isBestRep: isBestRep ?? this.isBestRep,
  );
  RepRecordRow copyWithCompanion(RepRecordsCompanion data) {
    return RepRecordRow(
      id: data.id.present ? data.id.value : this.id,
      sessionId: data.sessionId.present ? data.sessionId.value : this.sessionId,
      repIndex: data.repIndex.present ? data.repIndex.value : this.repIndex,
      meanVelocity: data.meanVelocity.present
          ? data.meanVelocity.value
          : this.meanVelocity,
      peakVelocity: data.peakVelocity.present
          ? data.peakVelocity.value
          : this.peakVelocity,
      romCm: data.romCm.present ? data.romCm.value : this.romCm,
      velocityLossPercent: data.velocityLossPercent.present
          ? data.velocityLossPercent.value
          : this.velocityLossPercent,
      durationMs: data.durationMs.present
          ? data.durationMs.value
          : this.durationMs,
      eccentricMs: data.eccentricMs.present
          ? data.eccentricMs.value
          : this.eccentricMs,
      concentricMs: data.concentricMs.present
          ? data.concentricMs.value
          : this.concentricMs,
      minHipAngle: data.minHipAngle.present
          ? data.minHipAngle.value
          : this.minHipAngle,
      minKneeAngle: data.minKneeAngle.present
          ? data.minKneeAngle.value
          : this.minKneeAngle,
      isBestRep: data.isBestRep.present ? data.isBestRep.value : this.isBestRep,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RepRecordRow(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('repIndex: $repIndex, ')
          ..write('meanVelocity: $meanVelocity, ')
          ..write('peakVelocity: $peakVelocity, ')
          ..write('romCm: $romCm, ')
          ..write('velocityLossPercent: $velocityLossPercent, ')
          ..write('durationMs: $durationMs, ')
          ..write('eccentricMs: $eccentricMs, ')
          ..write('concentricMs: $concentricMs, ')
          ..write('minHipAngle: $minHipAngle, ')
          ..write('minKneeAngle: $minKneeAngle, ')
          ..write('isBestRep: $isBestRep')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    sessionId,
    repIndex,
    meanVelocity,
    peakVelocity,
    romCm,
    velocityLossPercent,
    durationMs,
    eccentricMs,
    concentricMs,
    minHipAngle,
    minKneeAngle,
    isBestRep,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepRecordRow &&
          other.id == this.id &&
          other.sessionId == this.sessionId &&
          other.repIndex == this.repIndex &&
          other.meanVelocity == this.meanVelocity &&
          other.peakVelocity == this.peakVelocity &&
          other.romCm == this.romCm &&
          other.velocityLossPercent == this.velocityLossPercent &&
          other.durationMs == this.durationMs &&
          other.eccentricMs == this.eccentricMs &&
          other.concentricMs == this.concentricMs &&
          other.minHipAngle == this.minHipAngle &&
          other.minKneeAngle == this.minKneeAngle &&
          other.isBestRep == this.isBestRep);
}

class RepRecordsCompanion extends UpdateCompanion<RepRecordRow> {
  final Value<int> id;
  final Value<int> sessionId;
  final Value<int> repIndex;
  final Value<double> meanVelocity;
  final Value<double> peakVelocity;
  final Value<double> romCm;
  final Value<double> velocityLossPercent;
  final Value<int> durationMs;
  final Value<int> eccentricMs;
  final Value<int> concentricMs;
  final Value<double> minHipAngle;
  final Value<double> minKneeAngle;
  final Value<bool> isBestRep;
  const RepRecordsCompanion({
    this.id = const Value.absent(),
    this.sessionId = const Value.absent(),
    this.repIndex = const Value.absent(),
    this.meanVelocity = const Value.absent(),
    this.peakVelocity = const Value.absent(),
    this.romCm = const Value.absent(),
    this.velocityLossPercent = const Value.absent(),
    this.durationMs = const Value.absent(),
    this.eccentricMs = const Value.absent(),
    this.concentricMs = const Value.absent(),
    this.minHipAngle = const Value.absent(),
    this.minKneeAngle = const Value.absent(),
    this.isBestRep = const Value.absent(),
  });
  RepRecordsCompanion.insert({
    this.id = const Value.absent(),
    required int sessionId,
    required int repIndex,
    required double meanVelocity,
    required double peakVelocity,
    required double romCm,
    required double velocityLossPercent,
    required int durationMs,
    required int eccentricMs,
    required int concentricMs,
    required double minHipAngle,
    required double minKneeAngle,
    this.isBestRep = const Value.absent(),
  }) : sessionId = Value(sessionId),
       repIndex = Value(repIndex),
       meanVelocity = Value(meanVelocity),
       peakVelocity = Value(peakVelocity),
       romCm = Value(romCm),
       velocityLossPercent = Value(velocityLossPercent),
       durationMs = Value(durationMs),
       eccentricMs = Value(eccentricMs),
       concentricMs = Value(concentricMs),
       minHipAngle = Value(minHipAngle),
       minKneeAngle = Value(minKneeAngle);
  static Insertable<RepRecordRow> custom({
    Expression<int>? id,
    Expression<int>? sessionId,
    Expression<int>? repIndex,
    Expression<double>? meanVelocity,
    Expression<double>? peakVelocity,
    Expression<double>? romCm,
    Expression<double>? velocityLossPercent,
    Expression<int>? durationMs,
    Expression<int>? eccentricMs,
    Expression<int>? concentricMs,
    Expression<double>? minHipAngle,
    Expression<double>? minKneeAngle,
    Expression<bool>? isBestRep,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sessionId != null) 'session_id': sessionId,
      if (repIndex != null) 'rep_index': repIndex,
      if (meanVelocity != null) 'mean_velocity': meanVelocity,
      if (peakVelocity != null) 'peak_velocity': peakVelocity,
      if (romCm != null) 'rom_cm': romCm,
      if (velocityLossPercent != null)
        'velocity_loss_percent': velocityLossPercent,
      if (durationMs != null) 'duration_ms': durationMs,
      if (eccentricMs != null) 'eccentric_ms': eccentricMs,
      if (concentricMs != null) 'concentric_ms': concentricMs,
      if (minHipAngle != null) 'min_hip_angle': minHipAngle,
      if (minKneeAngle != null) 'min_knee_angle': minKneeAngle,
      if (isBestRep != null) 'is_best_rep': isBestRep,
    });
  }

  RepRecordsCompanion copyWith({
    Value<int>? id,
    Value<int>? sessionId,
    Value<int>? repIndex,
    Value<double>? meanVelocity,
    Value<double>? peakVelocity,
    Value<double>? romCm,
    Value<double>? velocityLossPercent,
    Value<int>? durationMs,
    Value<int>? eccentricMs,
    Value<int>? concentricMs,
    Value<double>? minHipAngle,
    Value<double>? minKneeAngle,
    Value<bool>? isBestRep,
  }) {
    return RepRecordsCompanion(
      id: id ?? this.id,
      sessionId: sessionId ?? this.sessionId,
      repIndex: repIndex ?? this.repIndex,
      meanVelocity: meanVelocity ?? this.meanVelocity,
      peakVelocity: peakVelocity ?? this.peakVelocity,
      romCm: romCm ?? this.romCm,
      velocityLossPercent: velocityLossPercent ?? this.velocityLossPercent,
      durationMs: durationMs ?? this.durationMs,
      eccentricMs: eccentricMs ?? this.eccentricMs,
      concentricMs: concentricMs ?? this.concentricMs,
      minHipAngle: minHipAngle ?? this.minHipAngle,
      minKneeAngle: minKneeAngle ?? this.minKneeAngle,
      isBestRep: isBestRep ?? this.isBestRep,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sessionId.present) {
      map['session_id'] = Variable<int>(sessionId.value);
    }
    if (repIndex.present) {
      map['rep_index'] = Variable<int>(repIndex.value);
    }
    if (meanVelocity.present) {
      map['mean_velocity'] = Variable<double>(meanVelocity.value);
    }
    if (peakVelocity.present) {
      map['peak_velocity'] = Variable<double>(peakVelocity.value);
    }
    if (romCm.present) {
      map['rom_cm'] = Variable<double>(romCm.value);
    }
    if (velocityLossPercent.present) {
      map['velocity_loss_percent'] = Variable<double>(
        velocityLossPercent.value,
      );
    }
    if (durationMs.present) {
      map['duration_ms'] = Variable<int>(durationMs.value);
    }
    if (eccentricMs.present) {
      map['eccentric_ms'] = Variable<int>(eccentricMs.value);
    }
    if (concentricMs.present) {
      map['concentric_ms'] = Variable<int>(concentricMs.value);
    }
    if (minHipAngle.present) {
      map['min_hip_angle'] = Variable<double>(minHipAngle.value);
    }
    if (minKneeAngle.present) {
      map['min_knee_angle'] = Variable<double>(minKneeAngle.value);
    }
    if (isBestRep.present) {
      map['is_best_rep'] = Variable<bool>(isBestRep.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RepRecordsCompanion(')
          ..write('id: $id, ')
          ..write('sessionId: $sessionId, ')
          ..write('repIndex: $repIndex, ')
          ..write('meanVelocity: $meanVelocity, ')
          ..write('peakVelocity: $peakVelocity, ')
          ..write('romCm: $romCm, ')
          ..write('velocityLossPercent: $velocityLossPercent, ')
          ..write('durationMs: $durationMs, ')
          ..write('eccentricMs: $eccentricMs, ')
          ..write('concentricMs: $concentricMs, ')
          ..write('minHipAngle: $minHipAngle, ')
          ..write('minKneeAngle: $minKneeAngle, ')
          ..write('isBestRep: $isBestRep')
          ..write(')'))
        .toString();
  }
}

class $SetLogsTable extends SetLogs with TableInfo<$SetLogsTable, SetLogRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SetLogsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exerciseNameMeta = const VerificationMeta(
    'exerciseName',
  );
  @override
  late final GeneratedColumn<String> exerciseName = GeneratedColumn<String>(
    'exercise_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tierMeta = const VerificationMeta('tier');
  @override
  late final GeneratedColumn<int> tier = GeneratedColumn<int>(
    'tier',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _performedAtMeta = const VerificationMeta(
    'performedAt',
  );
  @override
  late final GeneratedColumn<DateTime> performedAt = GeneratedColumn<DateTime>(
    'performed_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repsMeta = const VerificationMeta('reps');
  @override
  late final GeneratedColumn<int> reps = GeneratedColumn<int>(
    'reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rpeMeta = const VerificationMeta('rpe');
  @override
  late final GeneratedColumn<double> rpe = GeneratedColumn<double>(
    'rpe',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _restSecondsMeta = const VerificationMeta(
    'restSeconds',
  );
  @override
  late final GeneratedColumn<int> restSeconds = GeneratedColumn<int>(
    'rest_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseId,
    exerciseName,
    tier,
    performedAt,
    weightKg,
    reps,
    rpe,
    restSeconds,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'set_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<SetLogRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('exercise_name')) {
      context.handle(
        _exerciseNameMeta,
        exerciseName.isAcceptableOrUnknown(
          data['exercise_name']!,
          _exerciseNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_exerciseNameMeta);
    }
    if (data.containsKey('tier')) {
      context.handle(
        _tierMeta,
        tier.isAcceptableOrUnknown(data['tier']!, _tierMeta),
      );
    } else if (isInserting) {
      context.missing(_tierMeta);
    }
    if (data.containsKey('performed_at')) {
      context.handle(
        _performedAtMeta,
        performedAt.isAcceptableOrUnknown(
          data['performed_at']!,
          _performedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_performedAtMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('reps')) {
      context.handle(
        _repsMeta,
        reps.isAcceptableOrUnknown(data['reps']!, _repsMeta),
      );
    } else if (isInserting) {
      context.missing(_repsMeta);
    }
    if (data.containsKey('rpe')) {
      context.handle(
        _rpeMeta,
        rpe.isAcceptableOrUnknown(data['rpe']!, _rpeMeta),
      );
    }
    if (data.containsKey('rest_seconds')) {
      context.handle(
        _restSecondsMeta,
        restSeconds.isAcceptableOrUnknown(
          data['rest_seconds']!,
          _restSecondsMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SetLogRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SetLogRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      exerciseName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_name'],
      )!,
      tier: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tier'],
      )!,
      performedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}performed_at'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      reps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reps'],
      )!,
      rpe: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}rpe'],
      )!,
      restSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rest_seconds'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      )!,
    );
  }

  @override
  $SetLogsTable createAlias(String alias) {
    return $SetLogsTable(attachedDatabase, alias);
  }
}

class SetLogRow extends DataClass implements Insertable<SetLogRow> {
  final int id;
  final String exerciseId;
  final String exerciseName;
  final int tier;
  final DateTime performedAt;
  final double weightKg;
  final int reps;
  final double rpe;
  final int restSeconds;
  final String notes;
  const SetLogRow({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.tier,
    required this.performedAt,
    required this.weightKg,
    required this.reps,
    required this.rpe,
    required this.restSeconds,
    required this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['exercise_name'] = Variable<String>(exerciseName);
    map['tier'] = Variable<int>(tier);
    map['performed_at'] = Variable<DateTime>(performedAt);
    map['weight_kg'] = Variable<double>(weightKg);
    map['reps'] = Variable<int>(reps);
    map['rpe'] = Variable<double>(rpe);
    map['rest_seconds'] = Variable<int>(restSeconds);
    map['notes'] = Variable<String>(notes);
    return map;
  }

  SetLogsCompanion toCompanion(bool nullToAbsent) {
    return SetLogsCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      exerciseName: Value(exerciseName),
      tier: Value(tier),
      performedAt: Value(performedAt),
      weightKg: Value(weightKg),
      reps: Value(reps),
      rpe: Value(rpe),
      restSeconds: Value(restSeconds),
      notes: Value(notes),
    );
  }

  factory SetLogRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SetLogRow(
      id: serializer.fromJson<int>(json['id']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      exerciseName: serializer.fromJson<String>(json['exerciseName']),
      tier: serializer.fromJson<int>(json['tier']),
      performedAt: serializer.fromJson<DateTime>(json['performedAt']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      reps: serializer.fromJson<int>(json['reps']),
      rpe: serializer.fromJson<double>(json['rpe']),
      restSeconds: serializer.fromJson<int>(json['restSeconds']),
      notes: serializer.fromJson<String>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'exerciseName': serializer.toJson<String>(exerciseName),
      'tier': serializer.toJson<int>(tier),
      'performedAt': serializer.toJson<DateTime>(performedAt),
      'weightKg': serializer.toJson<double>(weightKg),
      'reps': serializer.toJson<int>(reps),
      'rpe': serializer.toJson<double>(rpe),
      'restSeconds': serializer.toJson<int>(restSeconds),
      'notes': serializer.toJson<String>(notes),
    };
  }

  SetLogRow copyWith({
    int? id,
    String? exerciseId,
    String? exerciseName,
    int? tier,
    DateTime? performedAt,
    double? weightKg,
    int? reps,
    double? rpe,
    int? restSeconds,
    String? notes,
  }) => SetLogRow(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    exerciseName: exerciseName ?? this.exerciseName,
    tier: tier ?? this.tier,
    performedAt: performedAt ?? this.performedAt,
    weightKg: weightKg ?? this.weightKg,
    reps: reps ?? this.reps,
    rpe: rpe ?? this.rpe,
    restSeconds: restSeconds ?? this.restSeconds,
    notes: notes ?? this.notes,
  );
  SetLogRow copyWithCompanion(SetLogsCompanion data) {
    return SetLogRow(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      exerciseName: data.exerciseName.present
          ? data.exerciseName.value
          : this.exerciseName,
      tier: data.tier.present ? data.tier.value : this.tier,
      performedAt: data.performedAt.present
          ? data.performedAt.value
          : this.performedAt,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      reps: data.reps.present ? data.reps.value : this.reps,
      rpe: data.rpe.present ? data.rpe.value : this.rpe,
      restSeconds: data.restSeconds.present
          ? data.restSeconds.value
          : this.restSeconds,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SetLogRow(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('tier: $tier, ')
          ..write('performedAt: $performedAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('rpe: $rpe, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    exerciseId,
    exerciseName,
    tier,
    performedAt,
    weightKg,
    reps,
    rpe,
    restSeconds,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SetLogRow &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.exerciseName == this.exerciseName &&
          other.tier == this.tier &&
          other.performedAt == this.performedAt &&
          other.weightKg == this.weightKg &&
          other.reps == this.reps &&
          other.rpe == this.rpe &&
          other.restSeconds == this.restSeconds &&
          other.notes == this.notes);
}

class SetLogsCompanion extends UpdateCompanion<SetLogRow> {
  final Value<int> id;
  final Value<String> exerciseId;
  final Value<String> exerciseName;
  final Value<int> tier;
  final Value<DateTime> performedAt;
  final Value<double> weightKg;
  final Value<int> reps;
  final Value<double> rpe;
  final Value<int> restSeconds;
  final Value<String> notes;
  const SetLogsCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.exerciseName = const Value.absent(),
    this.tier = const Value.absent(),
    this.performedAt = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.reps = const Value.absent(),
    this.rpe = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.notes = const Value.absent(),
  });
  SetLogsCompanion.insert({
    this.id = const Value.absent(),
    required String exerciseId,
    required String exerciseName,
    required int tier,
    required DateTime performedAt,
    this.weightKg = const Value.absent(),
    required int reps,
    this.rpe = const Value.absent(),
    this.restSeconds = const Value.absent(),
    this.notes = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       exerciseName = Value(exerciseName),
       tier = Value(tier),
       performedAt = Value(performedAt),
       reps = Value(reps);
  static Insertable<SetLogRow> custom({
    Expression<int>? id,
    Expression<String>? exerciseId,
    Expression<String>? exerciseName,
    Expression<int>? tier,
    Expression<DateTime>? performedAt,
    Expression<double>? weightKg,
    Expression<int>? reps,
    Expression<double>? rpe,
    Expression<int>? restSeconds,
    Expression<String>? notes,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (exerciseName != null) 'exercise_name': exerciseName,
      if (tier != null) 'tier': tier,
      if (performedAt != null) 'performed_at': performedAt,
      if (weightKg != null) 'weight_kg': weightKg,
      if (reps != null) 'reps': reps,
      if (rpe != null) 'rpe': rpe,
      if (restSeconds != null) 'rest_seconds': restSeconds,
      if (notes != null) 'notes': notes,
    });
  }

  SetLogsCompanion copyWith({
    Value<int>? id,
    Value<String>? exerciseId,
    Value<String>? exerciseName,
    Value<int>? tier,
    Value<DateTime>? performedAt,
    Value<double>? weightKg,
    Value<int>? reps,
    Value<double>? rpe,
    Value<int>? restSeconds,
    Value<String>? notes,
  }) {
    return SetLogsCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      exerciseName: exerciseName ?? this.exerciseName,
      tier: tier ?? this.tier,
      performedAt: performedAt ?? this.performedAt,
      weightKg: weightKg ?? this.weightKg,
      reps: reps ?? this.reps,
      rpe: rpe ?? this.rpe,
      restSeconds: restSeconds ?? this.restSeconds,
      notes: notes ?? this.notes,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (exerciseName.present) {
      map['exercise_name'] = Variable<String>(exerciseName.value);
    }
    if (tier.present) {
      map['tier'] = Variable<int>(tier.value);
    }
    if (performedAt.present) {
      map['performed_at'] = Variable<DateTime>(performedAt.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (reps.present) {
      map['reps'] = Variable<int>(reps.value);
    }
    if (rpe.present) {
      map['rpe'] = Variable<double>(rpe.value);
    }
    if (restSeconds.present) {
      map['rest_seconds'] = Variable<int>(restSeconds.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SetLogsCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('exerciseName: $exerciseName, ')
          ..write('tier: $tier, ')
          ..write('performedAt: $performedAt, ')
          ..write('weightKg: $weightKg, ')
          ..write('reps: $reps, ')
          ..write('rpe: $rpe, ')
          ..write('restSeconds: $restSeconds, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }
}

class $PlanItemsTable extends PlanItems
    with TableInfo<$PlanItemsTable, PlanItemRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _exerciseIdMeta = const VerificationMeta(
    'exerciseId',
  );
  @override
  late final GeneratedColumn<String> exerciseId = GeneratedColumn<String>(
    'exercise_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dayMeta = const VerificationMeta('day');
  @override
  late final GeneratedColumn<String> day = GeneratedColumn<String>(
    'day',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _targetSetsMeta = const VerificationMeta(
    'targetSets',
  );
  @override
  late final GeneratedColumn<int> targetSets = GeneratedColumn<int>(
    'target_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _targetRepsMeta = const VerificationMeta(
    'targetReps',
  );
  @override
  late final GeneratedColumn<int> targetReps = GeneratedColumn<int>(
    'target_reps',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(8),
  );
  static const VerificationMeta _weightKgMeta = const VerificationMeta(
    'weightKg',
  );
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
    'weight_kg',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedSetsMeta = const VerificationMeta(
    'completedSets',
  );
  @override
  late final GeneratedColumn<int> completedSets = GeneratedColumn<int>(
    'completed_sets',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    exerciseId,
    day,
    position,
    targetSets,
    targetReps,
    weightKg,
    completedSets,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanItemRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('exercise_id')) {
      context.handle(
        _exerciseIdMeta,
        exerciseId.isAcceptableOrUnknown(data['exercise_id']!, _exerciseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_exerciseIdMeta);
    }
    if (data.containsKey('day')) {
      context.handle(
        _dayMeta,
        day.isAcceptableOrUnknown(data['day']!, _dayMeta),
      );
    } else if (isInserting) {
      context.missing(_dayMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    }
    if (data.containsKey('target_sets')) {
      context.handle(
        _targetSetsMeta,
        targetSets.isAcceptableOrUnknown(data['target_sets']!, _targetSetsMeta),
      );
    }
    if (data.containsKey('target_reps')) {
      context.handle(
        _targetRepsMeta,
        targetReps.isAcceptableOrUnknown(data['target_reps']!, _targetRepsMeta),
      );
    }
    if (data.containsKey('weight_kg')) {
      context.handle(
        _weightKgMeta,
        weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta),
      );
    }
    if (data.containsKey('completed_sets')) {
      context.handle(
        _completedSetsMeta,
        completedSets.isAcceptableOrUnknown(
          data['completed_sets']!,
          _completedSetsMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {exerciseId, day},
  ];
  @override
  PlanItemRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanItemRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      exerciseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}exercise_id'],
      )!,
      day: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}day'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
      targetSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_sets'],
      )!,
      targetReps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}target_reps'],
      )!,
      weightKg: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight_kg'],
      )!,
      completedSets: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_sets'],
      )!,
    );
  }

  @override
  $PlanItemsTable createAlias(String alias) {
    return $PlanItemsTable(attachedDatabase, alias);
  }
}

class PlanItemRow extends DataClass implements Insertable<PlanItemRow> {
  final int id;
  final String exerciseId;
  final String day;
  final int position;
  final int targetSets;
  final int targetReps;
  final double weightKg;
  final int completedSets;
  const PlanItemRow({
    required this.id,
    required this.exerciseId,
    required this.day,
    required this.position,
    required this.targetSets,
    required this.targetReps,
    required this.weightKg,
    required this.completedSets,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['exercise_id'] = Variable<String>(exerciseId);
    map['day'] = Variable<String>(day);
    map['position'] = Variable<int>(position);
    map['target_sets'] = Variable<int>(targetSets);
    map['target_reps'] = Variable<int>(targetReps);
    map['weight_kg'] = Variable<double>(weightKg);
    map['completed_sets'] = Variable<int>(completedSets);
    return map;
  }

  PlanItemsCompanion toCompanion(bool nullToAbsent) {
    return PlanItemsCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      day: Value(day),
      position: Value(position),
      targetSets: Value(targetSets),
      targetReps: Value(targetReps),
      weightKg: Value(weightKg),
      completedSets: Value(completedSets),
    );
  }

  factory PlanItemRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanItemRow(
      id: serializer.fromJson<int>(json['id']),
      exerciseId: serializer.fromJson<String>(json['exerciseId']),
      day: serializer.fromJson<String>(json['day']),
      position: serializer.fromJson<int>(json['position']),
      targetSets: serializer.fromJson<int>(json['targetSets']),
      targetReps: serializer.fromJson<int>(json['targetReps']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      completedSets: serializer.fromJson<int>(json['completedSets']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'exerciseId': serializer.toJson<String>(exerciseId),
      'day': serializer.toJson<String>(day),
      'position': serializer.toJson<int>(position),
      'targetSets': serializer.toJson<int>(targetSets),
      'targetReps': serializer.toJson<int>(targetReps),
      'weightKg': serializer.toJson<double>(weightKg),
      'completedSets': serializer.toJson<int>(completedSets),
    };
  }

  PlanItemRow copyWith({
    int? id,
    String? exerciseId,
    String? day,
    int? position,
    int? targetSets,
    int? targetReps,
    double? weightKg,
    int? completedSets,
  }) => PlanItemRow(
    id: id ?? this.id,
    exerciseId: exerciseId ?? this.exerciseId,
    day: day ?? this.day,
    position: position ?? this.position,
    targetSets: targetSets ?? this.targetSets,
    targetReps: targetReps ?? this.targetReps,
    weightKg: weightKg ?? this.weightKg,
    completedSets: completedSets ?? this.completedSets,
  );
  PlanItemRow copyWithCompanion(PlanItemsCompanion data) {
    return PlanItemRow(
      id: data.id.present ? data.id.value : this.id,
      exerciseId: data.exerciseId.present
          ? data.exerciseId.value
          : this.exerciseId,
      day: data.day.present ? data.day.value : this.day,
      position: data.position.present ? data.position.value : this.position,
      targetSets: data.targetSets.present
          ? data.targetSets.value
          : this.targetSets,
      targetReps: data.targetReps.present
          ? data.targetReps.value
          : this.targetReps,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      completedSets: data.completedSets.present
          ? data.completedSets.value
          : this.completedSets,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanItemRow(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('day: $day, ')
          ..write('position: $position, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetReps: $targetReps, ')
          ..write('weightKg: $weightKg, ')
          ..write('completedSets: $completedSets')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    exerciseId,
    day,
    position,
    targetSets,
    targetReps,
    weightKg,
    completedSets,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanItemRow &&
          other.id == this.id &&
          other.exerciseId == this.exerciseId &&
          other.day == this.day &&
          other.position == this.position &&
          other.targetSets == this.targetSets &&
          other.targetReps == this.targetReps &&
          other.weightKg == this.weightKg &&
          other.completedSets == this.completedSets);
}

class PlanItemsCompanion extends UpdateCompanion<PlanItemRow> {
  final Value<int> id;
  final Value<String> exerciseId;
  final Value<String> day;
  final Value<int> position;
  final Value<int> targetSets;
  final Value<int> targetReps;
  final Value<double> weightKg;
  final Value<int> completedSets;
  const PlanItemsCompanion({
    this.id = const Value.absent(),
    this.exerciseId = const Value.absent(),
    this.day = const Value.absent(),
    this.position = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.completedSets = const Value.absent(),
  });
  PlanItemsCompanion.insert({
    this.id = const Value.absent(),
    required String exerciseId,
    required String day,
    this.position = const Value.absent(),
    this.targetSets = const Value.absent(),
    this.targetReps = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.completedSets = const Value.absent(),
  }) : exerciseId = Value(exerciseId),
       day = Value(day);
  static Insertable<PlanItemRow> custom({
    Expression<int>? id,
    Expression<String>? exerciseId,
    Expression<String>? day,
    Expression<int>? position,
    Expression<int>? targetSets,
    Expression<int>? targetReps,
    Expression<double>? weightKg,
    Expression<int>? completedSets,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (exerciseId != null) 'exercise_id': exerciseId,
      if (day != null) 'day': day,
      if (position != null) 'position': position,
      if (targetSets != null) 'target_sets': targetSets,
      if (targetReps != null) 'target_reps': targetReps,
      if (weightKg != null) 'weight_kg': weightKg,
      if (completedSets != null) 'completed_sets': completedSets,
    });
  }

  PlanItemsCompanion copyWith({
    Value<int>? id,
    Value<String>? exerciseId,
    Value<String>? day,
    Value<int>? position,
    Value<int>? targetSets,
    Value<int>? targetReps,
    Value<double>? weightKg,
    Value<int>? completedSets,
  }) {
    return PlanItemsCompanion(
      id: id ?? this.id,
      exerciseId: exerciseId ?? this.exerciseId,
      day: day ?? this.day,
      position: position ?? this.position,
      targetSets: targetSets ?? this.targetSets,
      targetReps: targetReps ?? this.targetReps,
      weightKg: weightKg ?? this.weightKg,
      completedSets: completedSets ?? this.completedSets,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (exerciseId.present) {
      map['exercise_id'] = Variable<String>(exerciseId.value);
    }
    if (day.present) {
      map['day'] = Variable<String>(day.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    if (targetSets.present) {
      map['target_sets'] = Variable<int>(targetSets.value);
    }
    if (targetReps.present) {
      map['target_reps'] = Variable<int>(targetReps.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (completedSets.present) {
      map['completed_sets'] = Variable<int>(completedSets.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanItemsCompanion(')
          ..write('id: $id, ')
          ..write('exerciseId: $exerciseId, ')
          ..write('day: $day, ')
          ..write('position: $position, ')
          ..write('targetSets: $targetSets, ')
          ..write('targetReps: $targetReps, ')
          ..write('weightKg: $weightKg, ')
          ..write('completedSets: $completedSets')
          ..write(')'))
        .toString();
  }
}

class $AppMetaTable extends AppMeta with TableInfo<$AppMetaTable, AppMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppMetaTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppMetaData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppMetaTable createAlias(String alias) {
    return $AppMetaTable(attachedDatabase, alias);
  }
}

class AppMetaData extends DataClass implements Insertable<AppMetaData> {
  final String key;
  final String value;
  const AppMetaData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppMetaCompanion toCompanion(bool nullToAbsent) {
    return AppMetaCompanion(key: Value(key), value: Value(value));
  }

  factory AppMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppMetaData copyWith({String? key, String? value}) =>
      AppMetaData(key: key ?? this.key, value: value ?? this.value);
  AppMetaData copyWithCompanion(AppMetaCompanion data) {
    return AppMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppMetaData &&
          other.key == this.key &&
          other.value == this.value);
}

class AppMetaCompanion extends UpdateCompanion<AppMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppMetaCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ExercisesTable exercises = $ExercisesTable(this);
  late final $ExerciseDetailsTable exerciseDetails = $ExerciseDetailsTable(
    this,
  );
  late final $WorkoutSessionsTable workoutSessions = $WorkoutSessionsTable(
    this,
  );
  late final $RepRecordsTable repRecords = $RepRecordsTable(this);
  late final $SetLogsTable setLogs = $SetLogsTable(this);
  late final $PlanItemsTable planItems = $PlanItemsTable(this);
  late final $AppMetaTable appMeta = $AppMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    exercises,
    exerciseDetails,
    workoutSessions,
    repRecords,
    setLogs,
    planItems,
    appMeta,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'exercises',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('exercise_details', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'workout_sessions',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('rep_records', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$ExercisesTableCreateCompanionBuilder = ExercisesCompanion Function({
  required String id,
  required String name,
  Value<String> localName,
  required String category,
  required String bodyPart,
  required String equipment,
  required String target,
  Value<String> secondaryMuscles,
  required int tier,
  Value<String> mediaId,
  Value<int> rowid,
});
typedef $$ExercisesTableUpdateCompanionBuilder = ExercisesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> localName,
  Value<String> category,
  Value<String> bodyPart,
  Value<String> equipment,
  Value<String> target,
  Value<String> secondaryMuscles,
  Value<int> tier,
  Value<String> mediaId,
  Value<int> rowid,
});

final class $$ExercisesTableReferences
    extends BaseReferences<_$AppDatabase, $ExercisesTable, ExerciseRow> {
  $$ExercisesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExerciseDetailsTable, List<ExerciseDetailRow>>
  _exerciseDetailsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.exerciseDetails,
    aliasName: 'exercises__id__exercise_details__exercise_id',
  );

  $$ExerciseDetailsTableProcessedTableManager get exerciseDetailsRefs {
    final manager = $$ExerciseDetailsTableTableManager(
      $_db,
      $_db.exerciseDetails,
    ).filter((f) => f.exerciseId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _exerciseDetailsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ExercisesTableFilterComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localName => $composableBuilder(
    column: $table.localName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bodyPart => $composableBuilder(
    column: $table.bodyPart,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> exerciseDetailsRefs(
    Expression<bool> Function($$ExerciseDetailsTableFilterComposer f) f,
  ) {
    final $$ExerciseDetailsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseDetails,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseDetailsTableFilterComposer(
            $db: $db,
            $table: $db.exerciseDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localName => $composableBuilder(
    column: $table.localName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bodyPart => $composableBuilder(
    column: $table.bodyPart,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get equipment => $composableBuilder(
    column: $table.equipment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get target => $composableBuilder(
    column: $table.target,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mediaId => $composableBuilder(
    column: $table.mediaId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExercisesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExercisesTable> {
  $$ExercisesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get localName =>
      $composableBuilder(column: $table.localName, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get bodyPart =>
      $composableBuilder(column: $table.bodyPart, builder: (column) => column);

  GeneratedColumn<String> get equipment =>
      $composableBuilder(column: $table.equipment, builder: (column) => column);

  GeneratedColumn<String> get target =>
      $composableBuilder(column: $table.target, builder: (column) => column);

  GeneratedColumn<String> get secondaryMuscles => $composableBuilder(
    column: $table.secondaryMuscles,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<String> get mediaId =>
      $composableBuilder(column: $table.mediaId, builder: (column) => column);

  Expression<T> exerciseDetailsRefs<T extends Object>(
    Expression<T> Function($$ExerciseDetailsTableAnnotationComposer a) f,
  ) {
    final $$ExerciseDetailsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.exerciseDetails,
      getReferencedColumn: (t) => t.exerciseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExerciseDetailsTableAnnotationComposer(
            $db: $db,
            $table: $db.exerciseDetails,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ExercisesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExercisesTable,
          ExerciseRow,
          $$ExercisesTableFilterComposer,
          $$ExercisesTableOrderingComposer,
          $$ExercisesTableAnnotationComposer,
          $$ExercisesTableCreateCompanionBuilder,
          $$ExercisesTableUpdateCompanionBuilder,
          (ExerciseRow, $$ExercisesTableReferences),
          ExerciseRow,
          PrefetchHooks Function({bool exerciseDetailsRefs})
        > {
  $$ExercisesTableTableManager(_$AppDatabase db, $ExercisesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExercisesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExercisesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExercisesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> localName = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> bodyPart = const Value.absent(),
                Value<String> equipment = const Value.absent(),
                Value<String> target = const Value.absent(),
                Value<String> secondaryMuscles = const Value.absent(),
                Value<int> tier = const Value.absent(),
                Value<String> mediaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion(
                id: id,
                name: name,
                localName: localName,
                category: category,
                bodyPart: bodyPart,
                equipment: equipment,
                target: target,
                secondaryMuscles: secondaryMuscles,
                tier: tier,
                mediaId: mediaId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String> localName = const Value.absent(),
                required String category,
                required String bodyPart,
                required String equipment,
                required String target,
                Value<String> secondaryMuscles = const Value.absent(),
                required int tier,
                Value<String> mediaId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExercisesCompanion.insert(
                id: id,
                name: name,
                localName: localName,
                category: category,
                bodyPart: bodyPart,
                equipment: equipment,
                target: target,
                secondaryMuscles: secondaryMuscles,
                tier: tier,
                mediaId: mediaId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExercisesTable, ExerciseRow>(table),
                  $$ExercisesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseDetailsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (exerciseDetailsRefs) db.exerciseDetails,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (exerciseDetailsRefs)
                    await $_getPrefetchedData<
                      ExerciseRow,
                      $ExercisesTable,
                      ExerciseDetailRow
                    >(
                      currentTable: table,
                      referencedTable: $$ExercisesTableReferences
                          ._exerciseDetailsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ExercisesTableReferences(
                            db,
                            table,
                            p0,
                          ).exerciseDetailsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.exerciseId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ExercisesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExercisesTable,
      ExerciseRow,
      $$ExercisesTableFilterComposer,
      $$ExercisesTableOrderingComposer,
      $$ExercisesTableAnnotationComposer,
      $$ExercisesTableCreateCompanionBuilder,
      $$ExercisesTableUpdateCompanionBuilder,
      (ExerciseRow, $$ExercisesTableReferences),
      ExerciseRow,
      PrefetchHooks Function({bool exerciseDetailsRefs})
    >;
typedef $$ExerciseDetailsTableCreateCompanionBuilder =
    ExerciseDetailsCompanion Function({
      required String exerciseId,
      required String steps,
      Value<int> rowid,
    });
typedef $$ExerciseDetailsTableUpdateCompanionBuilder =
    ExerciseDetailsCompanion Function({
      Value<String> exerciseId,
      Value<String> steps,
      Value<int> rowid,
    });

final class $$ExerciseDetailsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ExerciseDetailsTable,
          ExerciseDetailRow
        > {
  $$ExerciseDetailsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ExercisesTable _exerciseIdTable(_$AppDatabase db) =>
      db.exercises.createAlias('exercise_details__exercise_id__exercises__id');

  $$ExercisesTableProcessedTableManager get exerciseId {
    final $_column = $_itemColumn<String>('exercise_id')!;

    final manager = $$ExercisesTableTableManager(
      $_db,
      $_db.exercises,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_exerciseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ExerciseDetailsTableFilterComposer
    extends Composer<_$AppDatabase, $ExerciseDetailsTable> {
  $$ExerciseDetailsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnFilters(column),
  );

  $$ExercisesTableFilterComposer get exerciseId {
    final $$ExercisesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableFilterComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseDetailsTableOrderingComposer
    extends Composer<_$AppDatabase, $ExerciseDetailsTable> {
  $$ExerciseDetailsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get steps => $composableBuilder(
    column: $table.steps,
    builder: (column) => ColumnOrderings(column),
  );

  $$ExercisesTableOrderingComposer get exerciseId {
    final $$ExercisesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableOrderingComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseDetailsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExerciseDetailsTable> {
  $$ExerciseDetailsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get steps =>
      $composableBuilder(column: $table.steps, builder: (column) => column);

  $$ExercisesTableAnnotationComposer get exerciseId {
    final $$ExercisesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.exerciseId,
      referencedTable: $db.exercises,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ExercisesTableAnnotationComposer(
            $db: $db,
            $table: $db.exercises,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ExerciseDetailsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExerciseDetailsTable,
          ExerciseDetailRow,
          $$ExerciseDetailsTableFilterComposer,
          $$ExerciseDetailsTableOrderingComposer,
          $$ExerciseDetailsTableAnnotationComposer,
          $$ExerciseDetailsTableCreateCompanionBuilder,
          $$ExerciseDetailsTableUpdateCompanionBuilder,
          (ExerciseDetailRow, $$ExerciseDetailsTableReferences),
          ExerciseDetailRow,
          PrefetchHooks Function({bool exerciseId})
        > {
  $$ExerciseDetailsTableTableManager(
    _$AppDatabase db,
    $ExerciseDetailsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExerciseDetailsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExerciseDetailsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExerciseDetailsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> exerciseId = const Value.absent(),
                Value<String> steps = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExerciseDetailsCompanion(
                exerciseId: exerciseId,
                steps: steps,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String exerciseId,
                required String steps,
                Value<int> rowid = const Value.absent(),
              }) => ExerciseDetailsCompanion.insert(
                exerciseId: exerciseId,
                steps: steps,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ExerciseDetailsTable, ExerciseDetailRow>(table),
                  $$ExerciseDetailsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({exerciseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (exerciseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.exerciseId,
                        referencedTable: $$ExerciseDetailsTableReferences
                            ._exerciseIdTable(db),
                        referencedColumn: $$ExerciseDetailsTableReferences
                            ._exerciseIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$ExerciseDetailsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExerciseDetailsTable,
      ExerciseDetailRow,
      $$ExerciseDetailsTableFilterComposer,
      $$ExerciseDetailsTableOrderingComposer,
      $$ExerciseDetailsTableAnnotationComposer,
      $$ExerciseDetailsTableCreateCompanionBuilder,
      $$ExerciseDetailsTableUpdateCompanionBuilder,
      (ExerciseDetailRow, $$ExerciseDetailsTableReferences),
      ExerciseDetailRow,
      PrefetchHooks Function({bool exerciseId})
    >;
typedef $$WorkoutSessionsTableCreateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<int> id,
      Value<String> exerciseId,
      required String exerciseName,
      required int tier,
      required DateTime startedAt,
      required DateTime finishedAt,
      Value<double> weightKg,
      Value<double> plateDiameterCm,
      required double scaleMetersPerPixel,
      required int totalReps,
      Value<int> invalidReps,
      required double avgMeanVelocity,
      required double bestMeanVelocity,
      required double peakVelocity,
      required double bestRomCm,
      required double velocityLoss,
      Value<String> notes,
    });
typedef $$WorkoutSessionsTableUpdateCompanionBuilder =
    WorkoutSessionsCompanion Function({
      Value<int> id,
      Value<String> exerciseId,
      Value<String> exerciseName,
      Value<int> tier,
      Value<DateTime> startedAt,
      Value<DateTime> finishedAt,
      Value<double> weightKg,
      Value<double> plateDiameterCm,
      Value<double> scaleMetersPerPixel,
      Value<int> totalReps,
      Value<int> invalidReps,
      Value<double> avgMeanVelocity,
      Value<double> bestMeanVelocity,
      Value<double> peakVelocity,
      Value<double> bestRomCm,
      Value<double> velocityLoss,
      Value<String> notes,
    });

final class $$WorkoutSessionsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSessionRow
        > {
  $$WorkoutSessionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$RepRecordsTable, List<RepRecordRow>>
  _repRecordsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.repRecords,
    aliasName: 'workout_sessions__id__rep_records__session_id',
  );

  $$RepRecordsTableProcessedTableManager get repRecordsRefs {
    final manager = $$RepRecordsTableTableManager(
      $_db,
      $_db.repRecords,
    ).filter((f) => f.sessionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_repRecordsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$WorkoutSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get plateDiameterCm => $composableBuilder(
    column: $table.plateDiameterCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get scaleMetersPerPixel => $composableBuilder(
    column: $table.scaleMetersPerPixel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalReps => $composableBuilder(
    column: $table.totalReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get invalidReps => $composableBuilder(
    column: $table.invalidReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get avgMeanVelocity => $composableBuilder(
    column: $table.avgMeanVelocity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bestMeanVelocity => $composableBuilder(
    column: $table.bestMeanVelocity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peakVelocity => $composableBuilder(
    column: $table.peakVelocity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get bestRomCm => $composableBuilder(
    column: $table.bestRomCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get velocityLoss => $composableBuilder(
    column: $table.velocityLoss,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> repRecordsRefs(
    Expression<bool> Function($$RepRecordsTableFilterComposer f) f,
  ) {
    final $$RepRecordsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepRecordsTableFilterComposer(
            $db: $db,
            $table: $db.repRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get plateDiameterCm => $composableBuilder(
    column: $table.plateDiameterCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get scaleMetersPerPixel => $composableBuilder(
    column: $table.scaleMetersPerPixel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalReps => $composableBuilder(
    column: $table.totalReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get invalidReps => $composableBuilder(
    column: $table.invalidReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get avgMeanVelocity => $composableBuilder(
    column: $table.avgMeanVelocity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bestMeanVelocity => $composableBuilder(
    column: $table.bestMeanVelocity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peakVelocity => $composableBuilder(
    column: $table.peakVelocity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get bestRomCm => $composableBuilder(
    column: $table.bestRomCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get velocityLoss => $composableBuilder(
    column: $table.velocityLoss,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WorkoutSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $WorkoutSessionsTable> {
  $$WorkoutSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get finishedAt => $composableBuilder(
    column: $table.finishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get plateDiameterCm => $composableBuilder(
    column: $table.plateDiameterCm,
    builder: (column) => column,
  );

  GeneratedColumn<double> get scaleMetersPerPixel => $composableBuilder(
    column: $table.scaleMetersPerPixel,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalReps =>
      $composableBuilder(column: $table.totalReps, builder: (column) => column);

  GeneratedColumn<int> get invalidReps => $composableBuilder(
    column: $table.invalidReps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get avgMeanVelocity => $composableBuilder(
    column: $table.avgMeanVelocity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bestMeanVelocity => $composableBuilder(
    column: $table.bestMeanVelocity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get peakVelocity => $composableBuilder(
    column: $table.peakVelocity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get bestRomCm =>
      $composableBuilder(column: $table.bestRomCm, builder: (column) => column);

  GeneratedColumn<double> get velocityLoss => $composableBuilder(
    column: $table.velocityLoss,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  Expression<T> repRecordsRefs<T extends Object>(
    Expression<T> Function($$RepRecordsTableAnnotationComposer a) f,
  ) {
    final $$RepRecordsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repRecords,
      getReferencedColumn: (t) => t.sessionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepRecordsTableAnnotationComposer(
            $db: $db,
            $table: $db.repRecords,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$WorkoutSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WorkoutSessionsTable,
          WorkoutSessionRow,
          $$WorkoutSessionsTableFilterComposer,
          $$WorkoutSessionsTableOrderingComposer,
          $$WorkoutSessionsTableAnnotationComposer,
          $$WorkoutSessionsTableCreateCompanionBuilder,
          $$WorkoutSessionsTableUpdateCompanionBuilder,
          (WorkoutSessionRow, $$WorkoutSessionsTableReferences),
          WorkoutSessionRow,
          PrefetchHooks Function({bool repRecordsRefs})
        > {
  $$WorkoutSessionsTableTableManager(
    _$AppDatabase db,
    $WorkoutSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WorkoutSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WorkoutSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WorkoutSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<String> exerciseName = const Value.absent(),
                Value<int> tier = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime> finishedAt = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<double> plateDiameterCm = const Value.absent(),
                Value<double> scaleMetersPerPixel = const Value.absent(),
                Value<int> totalReps = const Value.absent(),
                Value<int> invalidReps = const Value.absent(),
                Value<double> avgMeanVelocity = const Value.absent(),
                Value<double> bestMeanVelocity = const Value.absent(),
                Value<double> peakVelocity = const Value.absent(),
                Value<double> bestRomCm = const Value.absent(),
                Value<double> velocityLoss = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => WorkoutSessionsCompanion(
                id: id,
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                tier: tier,
                startedAt: startedAt,
                finishedAt: finishedAt,
                weightKg: weightKg,
                plateDiameterCm: plateDiameterCm,
                scaleMetersPerPixel: scaleMetersPerPixel,
                totalReps: totalReps,
                invalidReps: invalidReps,
                avgMeanVelocity: avgMeanVelocity,
                bestMeanVelocity: bestMeanVelocity,
                peakVelocity: peakVelocity,
                bestRomCm: bestRomCm,
                velocityLoss: velocityLoss,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                required String exerciseName,
                required int tier,
                required DateTime startedAt,
                required DateTime finishedAt,
                Value<double> weightKg = const Value.absent(),
                Value<double> plateDiameterCm = const Value.absent(),
                required double scaleMetersPerPixel,
                required int totalReps,
                Value<int> invalidReps = const Value.absent(),
                required double avgMeanVelocity,
                required double bestMeanVelocity,
                required double peakVelocity,
                required double bestRomCm,
                required double velocityLoss,
                Value<String> notes = const Value.absent(),
              }) => WorkoutSessionsCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                tier: tier,
                startedAt: startedAt,
                finishedAt: finishedAt,
                weightKg: weightKg,
                plateDiameterCm: plateDiameterCm,
                scaleMetersPerPixel: scaleMetersPerPixel,
                totalReps: totalReps,
                invalidReps: invalidReps,
                avgMeanVelocity: avgMeanVelocity,
                bestMeanVelocity: bestMeanVelocity,
                peakVelocity: peakVelocity,
                bestRomCm: bestRomCm,
                velocityLoss: velocityLoss,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$WorkoutSessionsTable, WorkoutSessionRow>(table),
                  $$WorkoutSessionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({repRecordsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (repRecordsRefs) db.repRecords],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (repRecordsRefs)
                    await $_getPrefetchedData<
                      WorkoutSessionRow,
                      $WorkoutSessionsTable,
                      RepRecordRow
                    >(
                      currentTable: table,
                      referencedTable: $$WorkoutSessionsTableReferences
                          ._repRecordsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$WorkoutSessionsTableReferences(
                            db,
                            table,
                            p0,
                          ).repRecordsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.sessionId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$WorkoutSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WorkoutSessionsTable,
      WorkoutSessionRow,
      $$WorkoutSessionsTableFilterComposer,
      $$WorkoutSessionsTableOrderingComposer,
      $$WorkoutSessionsTableAnnotationComposer,
      $$WorkoutSessionsTableCreateCompanionBuilder,
      $$WorkoutSessionsTableUpdateCompanionBuilder,
      (WorkoutSessionRow, $$WorkoutSessionsTableReferences),
      WorkoutSessionRow,
      PrefetchHooks Function({bool repRecordsRefs})
    >;
typedef $$RepRecordsTableCreateCompanionBuilder = RepRecordsCompanion Function({
  Value<int> id,
  required int sessionId,
  required int repIndex,
  required double meanVelocity,
  required double peakVelocity,
  required double romCm,
  required double velocityLossPercent,
  required int durationMs,
  required int eccentricMs,
  required int concentricMs,
  required double minHipAngle,
  required double minKneeAngle,
  Value<bool> isBestRep,
});
typedef $$RepRecordsTableUpdateCompanionBuilder = RepRecordsCompanion Function({
  Value<int> id,
  Value<int> sessionId,
  Value<int> repIndex,
  Value<double> meanVelocity,
  Value<double> peakVelocity,
  Value<double> romCm,
  Value<double> velocityLossPercent,
  Value<int> durationMs,
  Value<int> eccentricMs,
  Value<int> concentricMs,
  Value<double> minHipAngle,
  Value<double> minKneeAngle,
  Value<bool> isBestRep,
});

final class $$RepRecordsTableReferences
    extends BaseReferences<_$AppDatabase, $RepRecordsTable, RepRecordRow> {
  $$RepRecordsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $WorkoutSessionsTable _sessionIdTable(_$AppDatabase db) => db
      .workoutSessions
      .createAlias('rep_records__session_id__workout_sessions__id');

  $$WorkoutSessionsTableProcessedTableManager get sessionId {
    final $_column = $_itemColumn<int>('session_id')!;

    final manager = $$WorkoutSessionsTableTableManager(
      $_db,
      $_db.workoutSessions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_sessionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RepRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $RepRecordsTable> {
  $$RepRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repIndex => $composableBuilder(
    column: $table.repIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get meanVelocity => $composableBuilder(
    column: $table.meanVelocity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get peakVelocity => $composableBuilder(
    column: $table.peakVelocity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get romCm => $composableBuilder(
    column: $table.romCm,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get velocityLossPercent => $composableBuilder(
    column: $table.velocityLossPercent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get eccentricMs => $composableBuilder(
    column: $table.eccentricMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get concentricMs => $composableBuilder(
    column: $table.concentricMs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minHipAngle => $composableBuilder(
    column: $table.minHipAngle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get minKneeAngle => $composableBuilder(
    column: $table.minKneeAngle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isBestRep => $composableBuilder(
    column: $table.isBestRep,
    builder: (column) => ColumnFilters(column),
  );

  $$WorkoutSessionsTableFilterComposer get sessionId {
    final $$WorkoutSessionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableFilterComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $RepRecordsTable> {
  $$RepRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repIndex => $composableBuilder(
    column: $table.repIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get meanVelocity => $composableBuilder(
    column: $table.meanVelocity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get peakVelocity => $composableBuilder(
    column: $table.peakVelocity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get romCm => $composableBuilder(
    column: $table.romCm,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get velocityLossPercent => $composableBuilder(
    column: $table.velocityLossPercent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get eccentricMs => $composableBuilder(
    column: $table.eccentricMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get concentricMs => $composableBuilder(
    column: $table.concentricMs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minHipAngle => $composableBuilder(
    column: $table.minHipAngle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get minKneeAngle => $composableBuilder(
    column: $table.minKneeAngle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isBestRep => $composableBuilder(
    column: $table.isBestRep,
    builder: (column) => ColumnOrderings(column),
  );

  $$WorkoutSessionsTableOrderingComposer get sessionId {
    final $$WorkoutSessionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableOrderingComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $RepRecordsTable> {
  $$RepRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get repIndex =>
      $composableBuilder(column: $table.repIndex, builder: (column) => column);

  GeneratedColumn<double> get meanVelocity => $composableBuilder(
    column: $table.meanVelocity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get peakVelocity => $composableBuilder(
    column: $table.peakVelocity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get romCm =>
      $composableBuilder(column: $table.romCm, builder: (column) => column);

  GeneratedColumn<double> get velocityLossPercent => $composableBuilder(
    column: $table.velocityLossPercent,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationMs => $composableBuilder(
    column: $table.durationMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get eccentricMs => $composableBuilder(
    column: $table.eccentricMs,
    builder: (column) => column,
  );

  GeneratedColumn<int> get concentricMs => $composableBuilder(
    column: $table.concentricMs,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minHipAngle => $composableBuilder(
    column: $table.minHipAngle,
    builder: (column) => column,
  );

  GeneratedColumn<double> get minKneeAngle => $composableBuilder(
    column: $table.minKneeAngle,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isBestRep =>
      $composableBuilder(column: $table.isBestRep, builder: (column) => column);

  $$WorkoutSessionsTableAnnotationComposer get sessionId {
    final $$WorkoutSessionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.sessionId,
      referencedTable: $db.workoutSessions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$WorkoutSessionsTableAnnotationComposer(
            $db: $db,
            $table: $db.workoutSessions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RepRecordsTable,
          RepRecordRow,
          $$RepRecordsTableFilterComposer,
          $$RepRecordsTableOrderingComposer,
          $$RepRecordsTableAnnotationComposer,
          $$RepRecordsTableCreateCompanionBuilder,
          $$RepRecordsTableUpdateCompanionBuilder,
          (RepRecordRow, $$RepRecordsTableReferences),
          RepRecordRow,
          PrefetchHooks Function({bool sessionId})
        > {
  $$RepRecordsTableTableManager(_$AppDatabase db, $RepRecordsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RepRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RepRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RepRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> sessionId = const Value.absent(),
                Value<int> repIndex = const Value.absent(),
                Value<double> meanVelocity = const Value.absent(),
                Value<double> peakVelocity = const Value.absent(),
                Value<double> romCm = const Value.absent(),
                Value<double> velocityLossPercent = const Value.absent(),
                Value<int> durationMs = const Value.absent(),
                Value<int> eccentricMs = const Value.absent(),
                Value<int> concentricMs = const Value.absent(),
                Value<double> minHipAngle = const Value.absent(),
                Value<double> minKneeAngle = const Value.absent(),
                Value<bool> isBestRep = const Value.absent(),
              }) => RepRecordsCompanion(
                id: id,
                sessionId: sessionId,
                repIndex: repIndex,
                meanVelocity: meanVelocity,
                peakVelocity: peakVelocity,
                romCm: romCm,
                velocityLossPercent: velocityLossPercent,
                durationMs: durationMs,
                eccentricMs: eccentricMs,
                concentricMs: concentricMs,
                minHipAngle: minHipAngle,
                minKneeAngle: minKneeAngle,
                isBestRep: isBestRep,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int sessionId,
                required int repIndex,
                required double meanVelocity,
                required double peakVelocity,
                required double romCm,
                required double velocityLossPercent,
                required int durationMs,
                required int eccentricMs,
                required int concentricMs,
                required double minHipAngle,
                required double minKneeAngle,
                Value<bool> isBestRep = const Value.absent(),
              }) => RepRecordsCompanion.insert(
                id: id,
                sessionId: sessionId,
                repIndex: repIndex,
                meanVelocity: meanVelocity,
                peakVelocity: peakVelocity,
                romCm: romCm,
                velocityLossPercent: velocityLossPercent,
                durationMs: durationMs,
                eccentricMs: eccentricMs,
                concentricMs: concentricMs,
                minHipAngle: minHipAngle,
                minKneeAngle: minKneeAngle,
                isBestRep: isBestRep,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$RepRecordsTable, RepRecordRow>(table),
                  $$RepRecordsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({sessionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (sessionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.sessionId,
                        referencedTable: $$RepRecordsTableReferences
                            ._sessionIdTable(db),
                        referencedColumn: $$RepRecordsTableReferences
                            ._sessionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$RepRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RepRecordsTable,
      RepRecordRow,
      $$RepRecordsTableFilterComposer,
      $$RepRecordsTableOrderingComposer,
      $$RepRecordsTableAnnotationComposer,
      $$RepRecordsTableCreateCompanionBuilder,
      $$RepRecordsTableUpdateCompanionBuilder,
      (RepRecordRow, $$RepRecordsTableReferences),
      RepRecordRow,
      PrefetchHooks Function({bool sessionId})
    >;
typedef $$SetLogsTableCreateCompanionBuilder = SetLogsCompanion Function({
  Value<int> id,
  required String exerciseId,
  required String exerciseName,
  required int tier,
  required DateTime performedAt,
  Value<double> weightKg,
  required int reps,
  Value<double> rpe,
  Value<int> restSeconds,
  Value<String> notes,
});
typedef $$SetLogsTableUpdateCompanionBuilder = SetLogsCompanion Function({
  Value<int> id,
  Value<String> exerciseId,
  Value<String> exerciseName,
  Value<int> tier,
  Value<DateTime> performedAt,
  Value<double> weightKg,
  Value<int> reps,
  Value<double> rpe,
  Value<int> restSeconds,
  Value<String> notes,
});

class $$SetLogsTableFilterComposer
    extends Composer<_$AppDatabase, $SetLogsTable> {
  $$SetLogsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SetLogsTableOrderingComposer
    extends Composer<_$AppDatabase, $SetLogsTable> {
  $$SetLogsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get tier => $composableBuilder(
    column: $table.tier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reps => $composableBuilder(
    column: $table.reps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get rpe => $composableBuilder(
    column: $table.rpe,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SetLogsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SetLogsTable> {
  $$SetLogsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get exerciseName => $composableBuilder(
    column: $table.exerciseName,
    builder: (column) => column,
  );

  GeneratedColumn<int> get tier =>
      $composableBuilder(column: $table.tier, builder: (column) => column);

  GeneratedColumn<DateTime> get performedAt => $composableBuilder(
    column: $table.performedAt,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get reps =>
      $composableBuilder(column: $table.reps, builder: (column) => column);

  GeneratedColumn<double> get rpe =>
      $composableBuilder(column: $table.rpe, builder: (column) => column);

  GeneratedColumn<int> get restSeconds => $composableBuilder(
    column: $table.restSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$SetLogsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SetLogsTable,
          SetLogRow,
          $$SetLogsTableFilterComposer,
          $$SetLogsTableOrderingComposer,
          $$SetLogsTableAnnotationComposer,
          $$SetLogsTableCreateCompanionBuilder,
          $$SetLogsTableUpdateCompanionBuilder,
          (SetLogRow, BaseReferences<_$AppDatabase, $SetLogsTable, SetLogRow>),
          SetLogRow,
          PrefetchHooks Function()
        > {
  $$SetLogsTableTableManager(_$AppDatabase db, $SetLogsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SetLogsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SetLogsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SetLogsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<String> exerciseName = const Value.absent(),
                Value<int> tier = const Value.absent(),
                Value<DateTime> performedAt = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<int> reps = const Value.absent(),
                Value<double> rpe = const Value.absent(),
                Value<int> restSeconds = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => SetLogsCompanion(
                id: id,
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                tier: tier,
                performedAt: performedAt,
                weightKg: weightKg,
                reps: reps,
                rpe: rpe,
                restSeconds: restSeconds,
                notes: notes,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String exerciseId,
                required String exerciseName,
                required int tier,
                required DateTime performedAt,
                Value<double> weightKg = const Value.absent(),
                required int reps,
                Value<double> rpe = const Value.absent(),
                Value<int> restSeconds = const Value.absent(),
                Value<String> notes = const Value.absent(),
              }) => SetLogsCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                exerciseName: exerciseName,
                tier: tier,
                performedAt: performedAt,
                weightKg: weightKg,
                reps: reps,
                rpe: rpe,
                restSeconds: restSeconds,
                notes: notes,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$SetLogsTable, SetLogRow>(table),
                  BaseReferences<_$AppDatabase, $SetLogsTable, SetLogRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SetLogsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SetLogsTable,
      SetLogRow,
      $$SetLogsTableFilterComposer,
      $$SetLogsTableOrderingComposer,
      $$SetLogsTableAnnotationComposer,
      $$SetLogsTableCreateCompanionBuilder,
      $$SetLogsTableUpdateCompanionBuilder,
      (SetLogRow, BaseReferences<_$AppDatabase, $SetLogsTable, SetLogRow>),
      SetLogRow,
      PrefetchHooks Function()
    >;
typedef $$PlanItemsTableCreateCompanionBuilder = PlanItemsCompanion Function({
  Value<int> id,
  required String exerciseId,
  required String day,
  Value<int> position,
  Value<int> targetSets,
  Value<int> targetReps,
  Value<double> weightKg,
  Value<int> completedSets,
});
typedef $$PlanItemsTableUpdateCompanionBuilder = PlanItemsCompanion Function({
  Value<int> id,
  Value<String> exerciseId,
  Value<String> day,
  Value<int> position,
  Value<int> targetSets,
  Value<int> targetReps,
  Value<double> weightKg,
  Value<int> completedSets,
});

class $$PlanItemsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanItemsTable> {
  $$PlanItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedSets => $composableBuilder(
    column: $table.completedSets,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlanItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanItemsTable> {
  $$PlanItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get day => $composableBuilder(
    column: $table.day,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weightKg => $composableBuilder(
    column: $table.weightKg,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedSets => $composableBuilder(
    column: $table.completedSets,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanItemsTable> {
  $$PlanItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get exerciseId => $composableBuilder(
    column: $table.exerciseId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get day =>
      $composableBuilder(column: $table.day, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  GeneratedColumn<int> get targetSets => $composableBuilder(
    column: $table.targetSets,
    builder: (column) => column,
  );

  GeneratedColumn<int> get targetReps => $composableBuilder(
    column: $table.targetReps,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<int> get completedSets => $composableBuilder(
    column: $table.completedSets,
    builder: (column) => column,
  );
}

class $$PlanItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanItemsTable,
          PlanItemRow,
          $$PlanItemsTableFilterComposer,
          $$PlanItemsTableOrderingComposer,
          $$PlanItemsTableAnnotationComposer,
          $$PlanItemsTableCreateCompanionBuilder,
          $$PlanItemsTableUpdateCompanionBuilder,
          (
            PlanItemRow,
            BaseReferences<_$AppDatabase, $PlanItemsTable, PlanItemRow>,
          ),
          PlanItemRow,
          PrefetchHooks Function()
        > {
  $$PlanItemsTableTableManager(_$AppDatabase db, $PlanItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> exerciseId = const Value.absent(),
                Value<String> day = const Value.absent(),
                Value<int> position = const Value.absent(),
                Value<int> targetSets = const Value.absent(),
                Value<int> targetReps = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<int> completedSets = const Value.absent(),
              }) => PlanItemsCompanion(
                id: id,
                exerciseId: exerciseId,
                day: day,
                position: position,
                targetSets: targetSets,
                targetReps: targetReps,
                weightKg: weightKg,
                completedSets: completedSets,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String exerciseId,
                required String day,
                Value<int> position = const Value.absent(),
                Value<int> targetSets = const Value.absent(),
                Value<int> targetReps = const Value.absent(),
                Value<double> weightKg = const Value.absent(),
                Value<int> completedSets = const Value.absent(),
              }) => PlanItemsCompanion.insert(
                id: id,
                exerciseId: exerciseId,
                day: day,
                position: position,
                targetSets: targetSets,
                targetReps: targetReps,
                weightKg: weightKg,
                completedSets: completedSets,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanItemsTable, PlanItemRow>(table),
                  BaseReferences<_$AppDatabase, $PlanItemsTable, PlanItemRow>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlanItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanItemsTable,
      PlanItemRow,
      $$PlanItemsTableFilterComposer,
      $$PlanItemsTableOrderingComposer,
      $$PlanItemsTableAnnotationComposer,
      $$PlanItemsTableCreateCompanionBuilder,
      $$PlanItemsTableUpdateCompanionBuilder,
      (
        PlanItemRow,
        BaseReferences<_$AppDatabase, $PlanItemsTable, PlanItemRow>,
      ),
      PlanItemRow,
      PrefetchHooks Function()
    >;
typedef $$AppMetaTableCreateCompanionBuilder = AppMetaCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppMetaTableUpdateCompanionBuilder = AppMetaCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppMetaTableFilterComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppMetaTable> {
  $$AppMetaTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppMetaTable,
          AppMetaData,
          $$AppMetaTableFilterComposer,
          $$AppMetaTableOrderingComposer,
          $$AppMetaTableAnnotationComposer,
          $$AppMetaTableCreateCompanionBuilder,
          $$AppMetaTableUpdateCompanionBuilder,
          (
            AppMetaData,
            BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>,
          ),
          AppMetaData,
          PrefetchHooks Function()
        > {
  $$AppMetaTableTableManager(_$AppDatabase db, $AppMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppMetaCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) => AppMetaCompanion.insert(key: key, value: value, rowid: rowid),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppMetaTable, AppMetaData>(table),
                  BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppMetaTable,
      AppMetaData,
      $$AppMetaTableFilterComposer,
      $$AppMetaTableOrderingComposer,
      $$AppMetaTableAnnotationComposer,
      $$AppMetaTableCreateCompanionBuilder,
      $$AppMetaTableUpdateCompanionBuilder,
      (AppMetaData, BaseReferences<_$AppDatabase, $AppMetaTable, AppMetaData>),
      AppMetaData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ExercisesTableTableManager get exercises =>
      $$ExercisesTableTableManager(_db, _db.exercises);
  $$ExerciseDetailsTableTableManager get exerciseDetails =>
      $$ExerciseDetailsTableTableManager(_db, _db.exerciseDetails);
  $$WorkoutSessionsTableTableManager get workoutSessions =>
      $$WorkoutSessionsTableTableManager(_db, _db.workoutSessions);
  $$RepRecordsTableTableManager get repRecords =>
      $$RepRecordsTableTableManager(_db, _db.repRecords);
  $$SetLogsTableTableManager get setLogs =>
      $$SetLogsTableTableManager(_db, _db.setLogs);
  $$PlanItemsTableTableManager get planItems =>
      $$PlanItemsTableTableManager(_db, _db.planItems);
  $$AppMetaTableTableManager get appMeta =>
      $$AppMetaTableTableManager(_db, _db.appMeta);
}
