// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CustomersTable extends Customers
    with TableInfo<$CustomersTable, Customer> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _internalNoteMeta = const VerificationMeta(
    'internalNote',
  );
  @override
  late final GeneratedColumn<String> internalNote = GeneratedColumn<String>(
    'internal_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    email,
    internalNote,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<Customer> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    }
    if (data.containsKey('internal_note')) {
      context.handle(
        _internalNoteMeta,
        internalNote.isAcceptableOrUnknown(
          data['internal_note']!,
          _internalNoteMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Customer map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Customer(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      ),
      internalNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}internal_note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomersTable createAlias(String alias) {
    return $CustomersTable(attachedDatabase, alias);
  }
}

class Customer extends DataClass implements Insertable<Customer> {
  final int id;
  final String name;
  final String? phone;
  final String? email;
  final String? internalNote;
  final DateTime createdAt;
  const Customer({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.internalNote,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || email != null) {
      map['email'] = Variable<String>(email);
    }
    if (!nullToAbsent || internalNote != null) {
      map['internal_note'] = Variable<String>(internalNote);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomersCompanion toCompanion(bool nullToAbsent) {
    return CustomersCompanion(
      id: Value(id),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      email: email == null && nullToAbsent
          ? const Value.absent()
          : Value(email),
      internalNote: internalNote == null && nullToAbsent
          ? const Value.absent()
          : Value(internalNote),
      createdAt: Value(createdAt),
    );
  }

  factory Customer.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Customer(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      email: serializer.fromJson<String?>(json['email']),
      internalNote: serializer.fromJson<String?>(json['internalNote']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'email': serializer.toJson<String?>(email),
      'internalNote': serializer.toJson<String?>(internalNote),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Customer copyWith({
    int? id,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> email = const Value.absent(),
    Value<String?> internalNote = const Value.absent(),
    DateTime? createdAt,
  }) => Customer(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    email: email.present ? email.value : this.email,
    internalNote: internalNote.present ? internalNote.value : this.internalNote,
    createdAt: createdAt ?? this.createdAt,
  );
  Customer copyWithCompanion(CustomersCompanion data) {
    return Customer(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      email: data.email.present ? data.email.value : this.email,
      internalNote: data.internalNote.present
          ? data.internalNote.value
          : this.internalNote,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Customer(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('internalNote: $internalNote, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, phone, email, internalNote, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Customer &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.email == this.email &&
          other.internalNote == this.internalNote &&
          other.createdAt == this.createdAt);
}

class CustomersCompanion extends UpdateCompanion<Customer> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> email;
  final Value<String?> internalNote;
  final Value<DateTime> createdAt;
  const CustomersCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.internalNote = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CustomersCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.phone = const Value.absent(),
    this.email = const Value.absent(),
    this.internalNote = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Customer> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? email,
    Expression<String>? internalNote,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (internalNote != null) 'internal_note': internalNote,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CustomersCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? email,
    Value<String?>? internalNote,
    Value<DateTime>? createdAt,
  }) {
    return CustomersCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      internalNote: internalNote ?? this.internalNote,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (internalNote.present) {
      map['internal_note'] = Variable<String>(internalNote.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('email: $email, ')
          ..write('internalNote: $internalNote, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $VehiclesTable extends Vehicles with TableInfo<$VehiclesTable, Vehicle> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VehiclesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _makeMeta = const VerificationMeta('make');
  @override
  late final GeneratedColumn<String> make = GeneratedColumn<String>(
    'make',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _modelMeta = const VerificationMeta('model');
  @override
  late final GeneratedColumn<String> model = GeneratedColumn<String>(
    'model',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vinMeta = const VerificationMeta('vin');
  @override
  late final GeneratedColumn<String> vin = GeneratedColumn<String>(
    'vin',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mileageMeta = const VerificationMeta(
    'mileage',
  );
  @override
  late final GeneratedColumn<int> mileage = GeneratedColumn<int>(
    'mileage',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _licensePlateMeta = const VerificationMeta(
    'licensePlate',
  );
  @override
  late final GeneratedColumn<String> licensePlate = GeneratedColumn<String>(
    'license_plate',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    year,
    make,
    model,
    vin,
    mileage,
    licensePlate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vehicles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vehicle> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
      );
    }
    if (data.containsKey('make')) {
      context.handle(
        _makeMeta,
        make.isAcceptableOrUnknown(data['make']!, _makeMeta),
      );
    }
    if (data.containsKey('model')) {
      context.handle(
        _modelMeta,
        model.isAcceptableOrUnknown(data['model']!, _modelMeta),
      );
    }
    if (data.containsKey('vin')) {
      context.handle(
        _vinMeta,
        vin.isAcceptableOrUnknown(data['vin']!, _vinMeta),
      );
    }
    if (data.containsKey('mileage')) {
      context.handle(
        _mileageMeta,
        mileage.isAcceptableOrUnknown(data['mileage']!, _mileageMeta),
      );
    }
    if (data.containsKey('license_plate')) {
      context.handle(
        _licensePlateMeta,
        licensePlate.isAcceptableOrUnknown(
          data['license_plate']!,
          _licensePlateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vehicle map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vehicle(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
      ),
      make: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}make'],
      ),
      model: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}model'],
      ),
      vin: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vin'],
      ),
      mileage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}mileage'],
      ),
      licensePlate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}license_plate'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VehiclesTable createAlias(String alias) {
    return $VehiclesTable(attachedDatabase, alias);
  }
}

class Vehicle extends DataClass implements Insertable<Vehicle> {
  final int id;
  final int customerId;
  final int? year;
  final String? make;
  final String? model;
  final String? vin;
  final int? mileage;
  final String? licensePlate;
  final DateTime createdAt;
  const Vehicle({
    required this.id,
    required this.customerId,
    this.year,
    this.make,
    this.model,
    this.vin,
    this.mileage,
    this.licensePlate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<int>(customerId);
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
    }
    if (!nullToAbsent || make != null) {
      map['make'] = Variable<String>(make);
    }
    if (!nullToAbsent || model != null) {
      map['model'] = Variable<String>(model);
    }
    if (!nullToAbsent || vin != null) {
      map['vin'] = Variable<String>(vin);
    }
    if (!nullToAbsent || mileage != null) {
      map['mileage'] = Variable<int>(mileage);
    }
    if (!nullToAbsent || licensePlate != null) {
      map['license_plate'] = Variable<String>(licensePlate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VehiclesCompanion toCompanion(bool nullToAbsent) {
    return VehiclesCompanion(
      id: Value(id),
      customerId: Value(customerId),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
      make: make == null && nullToAbsent ? const Value.absent() : Value(make),
      model: model == null && nullToAbsent
          ? const Value.absent()
          : Value(model),
      vin: vin == null && nullToAbsent ? const Value.absent() : Value(vin),
      mileage: mileage == null && nullToAbsent
          ? const Value.absent()
          : Value(mileage),
      licensePlate: licensePlate == null && nullToAbsent
          ? const Value.absent()
          : Value(licensePlate),
      createdAt: Value(createdAt),
    );
  }

  factory Vehicle.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vehicle(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<int>(json['customerId']),
      year: serializer.fromJson<int?>(json['year']),
      make: serializer.fromJson<String?>(json['make']),
      model: serializer.fromJson<String?>(json['model']),
      vin: serializer.fromJson<String?>(json['vin']),
      mileage: serializer.fromJson<int?>(json['mileage']),
      licensePlate: serializer.fromJson<String?>(json['licensePlate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerId': serializer.toJson<int>(customerId),
      'year': serializer.toJson<int?>(year),
      'make': serializer.toJson<String?>(make),
      'model': serializer.toJson<String?>(model),
      'vin': serializer.toJson<String?>(vin),
      'mileage': serializer.toJson<int?>(mileage),
      'licensePlate': serializer.toJson<String?>(licensePlate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Vehicle copyWith({
    int? id,
    int? customerId,
    Value<int?> year = const Value.absent(),
    Value<String?> make = const Value.absent(),
    Value<String?> model = const Value.absent(),
    Value<String?> vin = const Value.absent(),
    Value<int?> mileage = const Value.absent(),
    Value<String?> licensePlate = const Value.absent(),
    DateTime? createdAt,
  }) => Vehicle(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    year: year.present ? year.value : this.year,
    make: make.present ? make.value : this.make,
    model: model.present ? model.value : this.model,
    vin: vin.present ? vin.value : this.vin,
    mileage: mileage.present ? mileage.value : this.mileage,
    licensePlate: licensePlate.present ? licensePlate.value : this.licensePlate,
    createdAt: createdAt ?? this.createdAt,
  );
  Vehicle copyWithCompanion(VehiclesCompanion data) {
    return Vehicle(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      year: data.year.present ? data.year.value : this.year,
      make: data.make.present ? data.make.value : this.make,
      model: data.model.present ? data.model.value : this.model,
      vin: data.vin.present ? data.vin.value : this.vin,
      mileage: data.mileage.present ? data.mileage.value : this.mileage,
      licensePlate: data.licensePlate.present
          ? data.licensePlate.value
          : this.licensePlate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vehicle(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('year: $year, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('vin: $vin, ')
          ..write('mileage: $mileage, ')
          ..write('licensePlate: $licensePlate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    year,
    make,
    model,
    vin,
    mileage,
    licensePlate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vehicle &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.year == this.year &&
          other.make == this.make &&
          other.model == this.model &&
          other.vin == this.vin &&
          other.mileage == this.mileage &&
          other.licensePlate == this.licensePlate &&
          other.createdAt == this.createdAt);
}

class VehiclesCompanion extends UpdateCompanion<Vehicle> {
  final Value<int> id;
  final Value<int> customerId;
  final Value<int?> year;
  final Value<String?> make;
  final Value<String?> model;
  final Value<String?> vin;
  final Value<int?> mileage;
  final Value<String?> licensePlate;
  final Value<DateTime> createdAt;
  const VehiclesCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.year = const Value.absent(),
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.vin = const Value.absent(),
    this.mileage = const Value.absent(),
    this.licensePlate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VehiclesCompanion.insert({
    this.id = const Value.absent(),
    required int customerId,
    this.year = const Value.absent(),
    this.make = const Value.absent(),
    this.model = const Value.absent(),
    this.vin = const Value.absent(),
    this.mileage = const Value.absent(),
    this.licensePlate = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : customerId = Value(customerId);
  static Insertable<Vehicle> custom({
    Expression<int>? id,
    Expression<int>? customerId,
    Expression<int>? year,
    Expression<String>? make,
    Expression<String>? model,
    Expression<String>? vin,
    Expression<int>? mileage,
    Expression<String>? licensePlate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (year != null) 'year': year,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (vin != null) 'vin': vin,
      if (mileage != null) 'mileage': mileage,
      if (licensePlate != null) 'license_plate': licensePlate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VehiclesCompanion copyWith({
    Value<int>? id,
    Value<int>? customerId,
    Value<int?>? year,
    Value<String?>? make,
    Value<String?>? model,
    Value<String?>? vin,
    Value<int?>? mileage,
    Value<String?>? licensePlate,
    Value<DateTime>? createdAt,
  }) {
    return VehiclesCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      year: year ?? this.year,
      make: make ?? this.make,
      model: model ?? this.model,
      vin: vin ?? this.vin,
      mileage: mileage ?? this.mileage,
      licensePlate: licensePlate ?? this.licensePlate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
    }
    if (make.present) {
      map['make'] = Variable<String>(make.value);
    }
    if (model.present) {
      map['model'] = Variable<String>(model.value);
    }
    if (vin.present) {
      map['vin'] = Variable<String>(vin.value);
    }
    if (mileage.present) {
      map['mileage'] = Variable<int>(mileage.value);
    }
    if (licensePlate.present) {
      map['license_plate'] = Variable<String>(licensePlate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VehiclesCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('year: $year, ')
          ..write('make: $make, ')
          ..write('model: $model, ')
          ..write('vin: $vin, ')
          ..write('mileage: $mileage, ')
          ..write('licensePlate: $licensePlate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $EstimatesTable extends Estimates
    with TableInfo<$EstimatesTable, Estimate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EstimatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _customerComplaintMeta = const VerificationMeta(
    'customerComplaint',
  );
  @override
  late final GeneratedColumn<String> customerComplaint =
      GeneratedColumn<String>(
        'customer_complaint',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('draft'),
  );
  static const VerificationMeta _taxRateMeta = const VerificationMeta(
    'taxRate',
  );
  @override
  late final GeneratedColumn<double> taxRate = GeneratedColumn<double>(
    'tax_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _estimateDateMeta = const VerificationMeta(
    'estimateDate',
  );
  @override
  late final GeneratedColumn<DateTime> estimateDate = GeneratedColumn<DateTime>(
    'estimate_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    vehicleId,
    customerComplaint,
    note,
    status,
    taxRate,
    estimateDate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'estimates';
  @override
  VerificationContext validateIntegrity(
    Insertable<Estimate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    }
    if (data.containsKey('customer_complaint')) {
      context.handle(
        _customerComplaintMeta,
        customerComplaint.isAcceptableOrUnknown(
          data['customer_complaint']!,
          _customerComplaintMeta,
        ),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('tax_rate')) {
      context.handle(
        _taxRateMeta,
        taxRate.isAcceptableOrUnknown(data['tax_rate']!, _taxRateMeta),
      );
    }
    if (data.containsKey('estimate_date')) {
      context.handle(
        _estimateDateMeta,
        estimateDate.isAcceptableOrUnknown(
          data['estimate_date']!,
          _estimateDateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Estimate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Estimate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      ),
      customerComplaint: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_complaint'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      taxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}tax_rate'],
      )!,
      estimateDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}estimate_date'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $EstimatesTable createAlias(String alias) {
    return $EstimatesTable(attachedDatabase, alias);
  }
}

class Estimate extends DataClass implements Insertable<Estimate> {
  final int id;
  final int customerId;
  final int? vehicleId;
  final String? customerComplaint;
  final String? note;
  final String status;
  final double taxRate;
  final DateTime? estimateDate;
  final DateTime createdAt;
  const Estimate({
    required this.id,
    required this.customerId,
    this.vehicleId,
    this.customerComplaint,
    this.note,
    required this.status,
    required this.taxRate,
    this.estimateDate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['customer_id'] = Variable<int>(customerId);
    if (!nullToAbsent || vehicleId != null) {
      map['vehicle_id'] = Variable<int>(vehicleId);
    }
    if (!nullToAbsent || customerComplaint != null) {
      map['customer_complaint'] = Variable<String>(customerComplaint);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['status'] = Variable<String>(status);
    map['tax_rate'] = Variable<double>(taxRate);
    if (!nullToAbsent || estimateDate != null) {
      map['estimate_date'] = Variable<DateTime>(estimateDate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  EstimatesCompanion toCompanion(bool nullToAbsent) {
    return EstimatesCompanion(
      id: Value(id),
      customerId: Value(customerId),
      vehicleId: vehicleId == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleId),
      customerComplaint: customerComplaint == null && nullToAbsent
          ? const Value.absent()
          : Value(customerComplaint),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      status: Value(status),
      taxRate: Value(taxRate),
      estimateDate: estimateDate == null && nullToAbsent
          ? const Value.absent()
          : Value(estimateDate),
      createdAt: Value(createdAt),
    );
  }

  factory Estimate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Estimate(
      id: serializer.fromJson<int>(json['id']),
      customerId: serializer.fromJson<int>(json['customerId']),
      vehicleId: serializer.fromJson<int?>(json['vehicleId']),
      customerComplaint: serializer.fromJson<String?>(
        json['customerComplaint'],
      ),
      note: serializer.fromJson<String?>(json['note']),
      status: serializer.fromJson<String>(json['status']),
      taxRate: serializer.fromJson<double>(json['taxRate']),
      estimateDate: serializer.fromJson<DateTime?>(json['estimateDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'customerId': serializer.toJson<int>(customerId),
      'vehicleId': serializer.toJson<int?>(vehicleId),
      'customerComplaint': serializer.toJson<String?>(customerComplaint),
      'note': serializer.toJson<String?>(note),
      'status': serializer.toJson<String>(status),
      'taxRate': serializer.toJson<double>(taxRate),
      'estimateDate': serializer.toJson<DateTime?>(estimateDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Estimate copyWith({
    int? id,
    int? customerId,
    Value<int?> vehicleId = const Value.absent(),
    Value<String?> customerComplaint = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? status,
    double? taxRate,
    Value<DateTime?> estimateDate = const Value.absent(),
    DateTime? createdAt,
  }) => Estimate(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    vehicleId: vehicleId.present ? vehicleId.value : this.vehicleId,
    customerComplaint: customerComplaint.present
        ? customerComplaint.value
        : this.customerComplaint,
    note: note.present ? note.value : this.note,
    status: status ?? this.status,
    taxRate: taxRate ?? this.taxRate,
    estimateDate: estimateDate.present ? estimateDate.value : this.estimateDate,
    createdAt: createdAt ?? this.createdAt,
  );
  Estimate copyWithCompanion(EstimatesCompanion data) {
    return Estimate(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      customerComplaint: data.customerComplaint.present
          ? data.customerComplaint.value
          : this.customerComplaint,
      note: data.note.present ? data.note.value : this.note,
      status: data.status.present ? data.status.value : this.status,
      taxRate: data.taxRate.present ? data.taxRate.value : this.taxRate,
      estimateDate: data.estimateDate.present
          ? data.estimateDate.value
          : this.estimateDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Estimate(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('customerComplaint: $customerComplaint, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('taxRate: $taxRate, ')
          ..write('estimateDate: $estimateDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    vehicleId,
    customerComplaint,
    note,
    status,
    taxRate,
    estimateDate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Estimate &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.vehicleId == this.vehicleId &&
          other.customerComplaint == this.customerComplaint &&
          other.note == this.note &&
          other.status == this.status &&
          other.taxRate == this.taxRate &&
          other.estimateDate == this.estimateDate &&
          other.createdAt == this.createdAt);
}

class EstimatesCompanion extends UpdateCompanion<Estimate> {
  final Value<int> id;
  final Value<int> customerId;
  final Value<int?> vehicleId;
  final Value<String?> customerComplaint;
  final Value<String?> note;
  final Value<String> status;
  final Value<double> taxRate;
  final Value<DateTime?> estimateDate;
  final Value<DateTime> createdAt;
  const EstimatesCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.customerComplaint = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.taxRate = const Value.absent(),
    this.estimateDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  EstimatesCompanion.insert({
    this.id = const Value.absent(),
    required int customerId,
    this.vehicleId = const Value.absent(),
    this.customerComplaint = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.taxRate = const Value.absent(),
    this.estimateDate = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : customerId = Value(customerId);
  static Insertable<Estimate> custom({
    Expression<int>? id,
    Expression<int>? customerId,
    Expression<int>? vehicleId,
    Expression<String>? customerComplaint,
    Expression<String>? note,
    Expression<String>? status,
    Expression<double>? taxRate,
    Expression<DateTime>? estimateDate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (customerComplaint != null) 'customer_complaint': customerComplaint,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (taxRate != null) 'tax_rate': taxRate,
      if (estimateDate != null) 'estimate_date': estimateDate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  EstimatesCompanion copyWith({
    Value<int>? id,
    Value<int>? customerId,
    Value<int?>? vehicleId,
    Value<String?>? customerComplaint,
    Value<String?>? note,
    Value<String>? status,
    Value<double>? taxRate,
    Value<DateTime?>? estimateDate,
    Value<DateTime>? createdAt,
  }) {
    return EstimatesCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      vehicleId: vehicleId ?? this.vehicleId,
      customerComplaint: customerComplaint ?? this.customerComplaint,
      note: note ?? this.note,
      status: status ?? this.status,
      taxRate: taxRate ?? this.taxRate,
      estimateDate: estimateDate ?? this.estimateDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (customerComplaint.present) {
      map['customer_complaint'] = Variable<String>(customerComplaint.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (taxRate.present) {
      map['tax_rate'] = Variable<double>(taxRate.value);
    }
    if (estimateDate.present) {
      map['estimate_date'] = Variable<DateTime>(estimateDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EstimatesCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('customerComplaint: $customerComplaint, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('taxRate: $taxRate, ')
          ..write('estimateDate: $estimateDate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $VendorsTable extends Vendors with TableInfo<$VendorsTable, Vendor> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VendorsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactNameMeta = const VerificationMeta(
    'contactName',
  );
  @override
  late final GeneratedColumn<String> contactName = GeneratedColumn<String>(
    'contact_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _accountNumberMeta = const VerificationMeta(
    'accountNumber',
  );
  @override
  late final GeneratedColumn<String> accountNumber = GeneratedColumn<String>(
    'account_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    contactName,
    phone,
    accountNumber,
    isArchived,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'vendors';
  @override
  VerificationContext validateIntegrity(
    Insertable<Vendor> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact_name')) {
      context.handle(
        _contactNameMeta,
        contactName.isAcceptableOrUnknown(
          data['contact_name']!,
          _contactNameMeta,
        ),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('account_number')) {
      context.handle(
        _accountNumberMeta,
        accountNumber.isAcceptableOrUnknown(
          data['account_number']!,
          _accountNumberMeta,
        ),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Vendor map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Vendor(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contactName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_name'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      accountNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}account_number'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $VendorsTable createAlias(String alias) {
    return $VendorsTable(attachedDatabase, alias);
  }
}

class Vendor extends DataClass implements Insertable<Vendor> {
  final int id;
  final String name;
  final String? contactName;
  final String? phone;
  final String? accountNumber;
  final bool isArchived;
  final DateTime createdAt;
  const Vendor({
    required this.id,
    required this.name,
    this.contactName,
    this.phone,
    this.accountNumber,
    required this.isArchived,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contactName != null) {
      map['contact_name'] = Variable<String>(contactName);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || accountNumber != null) {
      map['account_number'] = Variable<String>(accountNumber);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  VendorsCompanion toCompanion(bool nullToAbsent) {
    return VendorsCompanion(
      id: Value(id),
      name: Value(name),
      contactName: contactName == null && nullToAbsent
          ? const Value.absent()
          : Value(contactName),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      accountNumber: accountNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(accountNumber),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
    );
  }

  factory Vendor.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Vendor(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contactName: serializer.fromJson<String?>(json['contactName']),
      phone: serializer.fromJson<String?>(json['phone']),
      accountNumber: serializer.fromJson<String?>(json['accountNumber']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'contactName': serializer.toJson<String?>(contactName),
      'phone': serializer.toJson<String?>(phone),
      'accountNumber': serializer.toJson<String?>(accountNumber),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Vendor copyWith({
    int? id,
    String? name,
    Value<String?> contactName = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> accountNumber = const Value.absent(),
    bool? isArchived,
    DateTime? createdAt,
  }) => Vendor(
    id: id ?? this.id,
    name: name ?? this.name,
    contactName: contactName.present ? contactName.value : this.contactName,
    phone: phone.present ? phone.value : this.phone,
    accountNumber: accountNumber.present
        ? accountNumber.value
        : this.accountNumber,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
  );
  Vendor copyWithCompanion(VendorsCompanion data) {
    return Vendor(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      contactName: data.contactName.present
          ? data.contactName.value
          : this.contactName,
      phone: data.phone.present ? data.phone.value : this.phone,
      accountNumber: data.accountNumber.present
          ? data.accountNumber.value
          : this.accountNumber,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Vendor(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactName: $contactName, ')
          ..write('phone: $phone, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    contactName,
    phone,
    accountNumber,
    isArchived,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vendor &&
          other.id == this.id &&
          other.name == this.name &&
          other.contactName == this.contactName &&
          other.phone == this.phone &&
          other.accountNumber == this.accountNumber &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt);
}

class VendorsCompanion extends UpdateCompanion<Vendor> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> contactName;
  final Value<String?> phone;
  final Value<String?> accountNumber;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  const VendorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contactName = const Value.absent(),
    this.phone = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VendorsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.contactName = const Value.absent(),
    this.phone = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Vendor> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? contactName,
    Expression<String>? phone,
    Expression<String>? accountNumber,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contactName != null) 'contact_name': contactName,
      if (phone != null) 'phone': phone,
      if (accountNumber != null) 'account_number': accountNumber,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VendorsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? contactName,
    Value<String?>? phone,
    Value<String?>? accountNumber,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
  }) {
    return VendorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      accountNumber: accountNumber ?? this.accountNumber,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contactName.present) {
      map['contact_name'] = Variable<String>(contactName.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (accountNumber.present) {
      map['account_number'] = Variable<String>(accountNumber.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VendorsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactName: $contactName, ')
          ..write('phone: $phone, ')
          ..write('accountNumber: $accountNumber, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $InventoryPartsTable extends InventoryParts
    with TableInfo<$InventoryPartsTable, InventoryPart> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryPartsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _partNumberMeta = const VerificationMeta(
    'partNumber',
  );
  @override
  late final GeneratedColumn<String> partNumber = GeneratedColumn<String>(
    'part_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _costMeta = const VerificationMeta('cost');
  @override
  late final GeneratedColumn<int> cost = GeneratedColumn<int>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _sellPriceMeta = const VerificationMeta(
    'sellPrice',
  );
  @override
  late final GeneratedColumn<int> sellPrice = GeneratedColumn<int>(
    'sell_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _stockQtyMeta = const VerificationMeta(
    'stockQty',
  );
  @override
  late final GeneratedColumn<int> stockQty = GeneratedColumn<int>(
    'stock_qty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _lowStockThresholdMeta = const VerificationMeta(
    'lowStockThreshold',
  );
  @override
  late final GeneratedColumn<int> lowStockThreshold = GeneratedColumn<int>(
    'low_stock_threshold',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(2),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    partNumber,
    description,
    category,
    cost,
    sellPrice,
    stockQty,
    lowStockThreshold,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_parts';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryPart> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('part_number')) {
      context.handle(
        _partNumberMeta,
        partNumber.isAcceptableOrUnknown(data['part_number']!, _partNumberMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('cost')) {
      context.handle(
        _costMeta,
        cost.isAcceptableOrUnknown(data['cost']!, _costMeta),
      );
    }
    if (data.containsKey('sell_price')) {
      context.handle(
        _sellPriceMeta,
        sellPrice.isAcceptableOrUnknown(data['sell_price']!, _sellPriceMeta),
      );
    }
    if (data.containsKey('stock_qty')) {
      context.handle(
        _stockQtyMeta,
        stockQty.isAcceptableOrUnknown(data['stock_qty']!, _stockQtyMeta),
      );
    }
    if (data.containsKey('low_stock_threshold')) {
      context.handle(
        _lowStockThresholdMeta,
        lowStockThreshold.isAcceptableOrUnknown(
          data['low_stock_threshold']!,
          _lowStockThresholdMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryPart map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryPart(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      partNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_number'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      cost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cost'],
      )!,
      sellPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sell_price'],
      )!,
      stockQty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_qty'],
      )!,
      lowStockThreshold: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}low_stock_threshold'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $InventoryPartsTable createAlias(String alias) {
    return $InventoryPartsTable(attachedDatabase, alias);
  }
}

class InventoryPart extends DataClass implements Insertable<InventoryPart> {
  final int id;
  final String? partNumber;
  final String description;
  final String? category;
  final int cost;
  final int sellPrice;
  final int stockQty;
  final int lowStockThreshold;
  final DateTime createdAt;
  const InventoryPart({
    required this.id,
    this.partNumber,
    required this.description,
    this.category,
    required this.cost,
    required this.sellPrice,
    required this.stockQty,
    required this.lowStockThreshold,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || partNumber != null) {
      map['part_number'] = Variable<String>(partNumber);
    }
    map['description'] = Variable<String>(description);
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['cost'] = Variable<int>(cost);
    map['sell_price'] = Variable<int>(sellPrice);
    map['stock_qty'] = Variable<int>(stockQty);
    map['low_stock_threshold'] = Variable<int>(lowStockThreshold);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  InventoryPartsCompanion toCompanion(bool nullToAbsent) {
    return InventoryPartsCompanion(
      id: Value(id),
      partNumber: partNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(partNumber),
      description: Value(description),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      cost: Value(cost),
      sellPrice: Value(sellPrice),
      stockQty: Value(stockQty),
      lowStockThreshold: Value(lowStockThreshold),
      createdAt: Value(createdAt),
    );
  }

  factory InventoryPart.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryPart(
      id: serializer.fromJson<int>(json['id']),
      partNumber: serializer.fromJson<String?>(json['partNumber']),
      description: serializer.fromJson<String>(json['description']),
      category: serializer.fromJson<String?>(json['category']),
      cost: serializer.fromJson<int>(json['cost']),
      sellPrice: serializer.fromJson<int>(json['sellPrice']),
      stockQty: serializer.fromJson<int>(json['stockQty']),
      lowStockThreshold: serializer.fromJson<int>(json['lowStockThreshold']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'partNumber': serializer.toJson<String?>(partNumber),
      'description': serializer.toJson<String>(description),
      'category': serializer.toJson<String?>(category),
      'cost': serializer.toJson<int>(cost),
      'sellPrice': serializer.toJson<int>(sellPrice),
      'stockQty': serializer.toJson<int>(stockQty),
      'lowStockThreshold': serializer.toJson<int>(lowStockThreshold),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  InventoryPart copyWith({
    int? id,
    Value<String?> partNumber = const Value.absent(),
    String? description,
    Value<String?> category = const Value.absent(),
    int? cost,
    int? sellPrice,
    int? stockQty,
    int? lowStockThreshold,
    DateTime? createdAt,
  }) => InventoryPart(
    id: id ?? this.id,
    partNumber: partNumber.present ? partNumber.value : this.partNumber,
    description: description ?? this.description,
    category: category.present ? category.value : this.category,
    cost: cost ?? this.cost,
    sellPrice: sellPrice ?? this.sellPrice,
    stockQty: stockQty ?? this.stockQty,
    lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
    createdAt: createdAt ?? this.createdAt,
  );
  InventoryPart copyWithCompanion(InventoryPartsCompanion data) {
    return InventoryPart(
      id: data.id.present ? data.id.value : this.id,
      partNumber: data.partNumber.present
          ? data.partNumber.value
          : this.partNumber,
      description: data.description.present
          ? data.description.value
          : this.description,
      category: data.category.present ? data.category.value : this.category,
      cost: data.cost.present ? data.cost.value : this.cost,
      sellPrice: data.sellPrice.present ? data.sellPrice.value : this.sellPrice,
      stockQty: data.stockQty.present ? data.stockQty.value : this.stockQty,
      lowStockThreshold: data.lowStockThreshold.present
          ? data.lowStockThreshold.value
          : this.lowStockThreshold,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryPart(')
          ..write('id: $id, ')
          ..write('partNumber: $partNumber, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('cost: $cost, ')
          ..write('sellPrice: $sellPrice, ')
          ..write('stockQty: $stockQty, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    partNumber,
    description,
    category,
    cost,
    sellPrice,
    stockQty,
    lowStockThreshold,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryPart &&
          other.id == this.id &&
          other.partNumber == this.partNumber &&
          other.description == this.description &&
          other.category == this.category &&
          other.cost == this.cost &&
          other.sellPrice == this.sellPrice &&
          other.stockQty == this.stockQty &&
          other.lowStockThreshold == this.lowStockThreshold &&
          other.createdAt == this.createdAt);
}

class InventoryPartsCompanion extends UpdateCompanion<InventoryPart> {
  final Value<int> id;
  final Value<String?> partNumber;
  final Value<String> description;
  final Value<String?> category;
  final Value<int> cost;
  final Value<int> sellPrice;
  final Value<int> stockQty;
  final Value<int> lowStockThreshold;
  final Value<DateTime> createdAt;
  const InventoryPartsCompanion({
    this.id = const Value.absent(),
    this.partNumber = const Value.absent(),
    this.description = const Value.absent(),
    this.category = const Value.absent(),
    this.cost = const Value.absent(),
    this.sellPrice = const Value.absent(),
    this.stockQty = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  InventoryPartsCompanion.insert({
    this.id = const Value.absent(),
    this.partNumber = const Value.absent(),
    required String description,
    this.category = const Value.absent(),
    this.cost = const Value.absent(),
    this.sellPrice = const Value.absent(),
    this.stockQty = const Value.absent(),
    this.lowStockThreshold = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : description = Value(description);
  static Insertable<InventoryPart> custom({
    Expression<int>? id,
    Expression<String>? partNumber,
    Expression<String>? description,
    Expression<String>? category,
    Expression<int>? cost,
    Expression<int>? sellPrice,
    Expression<int>? stockQty,
    Expression<int>? lowStockThreshold,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (partNumber != null) 'part_number': partNumber,
      if (description != null) 'description': description,
      if (category != null) 'category': category,
      if (cost != null) 'cost': cost,
      if (sellPrice != null) 'sell_price': sellPrice,
      if (stockQty != null) 'stock_qty': stockQty,
      if (lowStockThreshold != null) 'low_stock_threshold': lowStockThreshold,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  InventoryPartsCompanion copyWith({
    Value<int>? id,
    Value<String?>? partNumber,
    Value<String>? description,
    Value<String?>? category,
    Value<int>? cost,
    Value<int>? sellPrice,
    Value<int>? stockQty,
    Value<int>? lowStockThreshold,
    Value<DateTime>? createdAt,
  }) {
    return InventoryPartsCompanion(
      id: id ?? this.id,
      partNumber: partNumber ?? this.partNumber,
      description: description ?? this.description,
      category: category ?? this.category,
      cost: cost ?? this.cost,
      sellPrice: sellPrice ?? this.sellPrice,
      stockQty: stockQty ?? this.stockQty,
      lowStockThreshold: lowStockThreshold ?? this.lowStockThreshold,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (partNumber.present) {
      map['part_number'] = Variable<String>(partNumber.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (cost.present) {
      map['cost'] = Variable<int>(cost.value);
    }
    if (sellPrice.present) {
      map['sell_price'] = Variable<int>(sellPrice.value);
    }
    if (stockQty.present) {
      map['stock_qty'] = Variable<int>(stockQty.value);
    }
    if (lowStockThreshold.present) {
      map['low_stock_threshold'] = Variable<int>(lowStockThreshold.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryPartsCompanion(')
          ..write('id: $id, ')
          ..write('partNumber: $partNumber, ')
          ..write('description: $description, ')
          ..write('category: $category, ')
          ..write('cost: $cost, ')
          ..write('sellPrice: $sellPrice, ')
          ..write('stockQty: $stockQty, ')
          ..write('lowStockThreshold: $lowStockThreshold, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $EstimateLineItemsTable extends EstimateLineItems
    with TableInfo<$EstimateLineItemsTable, EstimateLineItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EstimateLineItemsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _estimateIdMeta = const VerificationMeta(
    'estimateId',
  );
  @override
  late final GeneratedColumn<int> estimateId = GeneratedColumn<int>(
    'estimate_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES estimates (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _unitPriceMeta = const VerificationMeta(
    'unitPrice',
  );
  @override
  late final GeneratedColumn<int> unitPrice = GeneratedColumn<int>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostMeta = const VerificationMeta(
    'unitCost',
  );
  @override
  late final GeneratedColumn<int> unitCost = GeneratedColumn<int>(
    'unit_cost',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _vendorIdMeta = const VerificationMeta(
    'vendorId',
  );
  @override
  late final GeneratedColumn<int> vendorId = GeneratedColumn<int>(
    'vendor_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vendors (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _parentLaborIdMeta = const VerificationMeta(
    'parentLaborId',
  );
  @override
  late final GeneratedColumn<int> parentLaborId = GeneratedColumn<int>(
    'parent_labor_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isDoneMeta = const VerificationMeta('isDone');
  @override
  late final GeneratedColumn<bool> isDone = GeneratedColumn<bool>(
    'is_done',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_done" IN (0, 1))',
    ),
  );
  static const VerificationMeta _approvalStatusMeta = const VerificationMeta(
    'approvalStatus',
  );
  @override
  late final GeneratedColumn<String> approvalStatus = GeneratedColumn<String>(
    'approval_status',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _inventoryPartIdMeta = const VerificationMeta(
    'inventoryPartId',
  );
  @override
  late final GeneratedColumn<int> inventoryPartId = GeneratedColumn<int>(
    'inventory_part_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES inventory_parts (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _laborNameMeta = const VerificationMeta(
    'laborName',
  );
  @override
  late final GeneratedColumn<String> laborName = GeneratedColumn<String>(
    'labor_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _partNumberMeta = const VerificationMeta(
    'partNumber',
  );
  @override
  late final GeneratedColumn<String> partNumber = GeneratedColumn<String>(
    'part_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    estimateId,
    type,
    description,
    quantity,
    unitPrice,
    unitCost,
    vendorId,
    parentLaborId,
    isDone,
    approvalStatus,
    inventoryPartId,
    laborName,
    partNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'estimate_line_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<EstimateLineItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('estimate_id')) {
      context.handle(
        _estimateIdMeta,
        estimateId.isAcceptableOrUnknown(data['estimate_id']!, _estimateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_estimateIdMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_descriptionMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit_price')) {
      context.handle(
        _unitPriceMeta,
        unitPrice.isAcceptableOrUnknown(data['unit_price']!, _unitPriceMeta),
      );
    } else if (isInserting) {
      context.missing(_unitPriceMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(
        _unitCostMeta,
        unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta),
      );
    }
    if (data.containsKey('vendor_id')) {
      context.handle(
        _vendorIdMeta,
        vendorId.isAcceptableOrUnknown(data['vendor_id']!, _vendorIdMeta),
      );
    }
    if (data.containsKey('parent_labor_id')) {
      context.handle(
        _parentLaborIdMeta,
        parentLaborId.isAcceptableOrUnknown(
          data['parent_labor_id']!,
          _parentLaborIdMeta,
        ),
      );
    }
    if (data.containsKey('is_done')) {
      context.handle(
        _isDoneMeta,
        isDone.isAcceptableOrUnknown(data['is_done']!, _isDoneMeta),
      );
    }
    if (data.containsKey('approval_status')) {
      context.handle(
        _approvalStatusMeta,
        approvalStatus.isAcceptableOrUnknown(
          data['approval_status']!,
          _approvalStatusMeta,
        ),
      );
    }
    if (data.containsKey('inventory_part_id')) {
      context.handle(
        _inventoryPartIdMeta,
        inventoryPartId.isAcceptableOrUnknown(
          data['inventory_part_id']!,
          _inventoryPartIdMeta,
        ),
      );
    }
    if (data.containsKey('labor_name')) {
      context.handle(
        _laborNameMeta,
        laborName.isAcceptableOrUnknown(data['labor_name']!, _laborNameMeta),
      );
    }
    if (data.containsKey('part_number')) {
      context.handle(
        _partNumberMeta,
        partNumber.isAcceptableOrUnknown(data['part_number']!, _partNumberMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EstimateLineItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EstimateLineItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      estimateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimate_id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
      unitPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_price'],
      )!,
      unitCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}unit_cost'],
      ),
      vendorId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vendor_id'],
      ),
      parentLaborId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}parent_labor_id'],
      ),
      isDone: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_done'],
      ),
      approvalStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}approval_status'],
      ),
      inventoryPartId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inventory_part_id'],
      ),
      laborName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}labor_name'],
      ),
      partNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}part_number'],
      ),
    );
  }

  @override
  $EstimateLineItemsTable createAlias(String alias) {
    return $EstimateLineItemsTable(attachedDatabase, alias);
  }
}

class EstimateLineItem extends DataClass
    implements Insertable<EstimateLineItem> {
  final int id;
  final int estimateId;
  final String type;
  final String description;
  final double quantity;
  final int unitPrice;
  final int? unitCost;
  final int? vendorId;
  final int? parentLaborId;
  final bool? isDone;
  final String? approvalStatus;
  final int? inventoryPartId;
  final String? laborName;
  final String? partNumber;
  const EstimateLineItem({
    required this.id,
    required this.estimateId,
    required this.type,
    required this.description,
    required this.quantity,
    required this.unitPrice,
    this.unitCost,
    this.vendorId,
    this.parentLaborId,
    this.isDone,
    this.approvalStatus,
    this.inventoryPartId,
    this.laborName,
    this.partNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['estimate_id'] = Variable<int>(estimateId);
    map['type'] = Variable<String>(type);
    map['description'] = Variable<String>(description);
    map['quantity'] = Variable<double>(quantity);
    map['unit_price'] = Variable<int>(unitPrice);
    if (!nullToAbsent || unitCost != null) {
      map['unit_cost'] = Variable<int>(unitCost);
    }
    if (!nullToAbsent || vendorId != null) {
      map['vendor_id'] = Variable<int>(vendorId);
    }
    if (!nullToAbsent || parentLaborId != null) {
      map['parent_labor_id'] = Variable<int>(parentLaborId);
    }
    if (!nullToAbsent || isDone != null) {
      map['is_done'] = Variable<bool>(isDone);
    }
    if (!nullToAbsent || approvalStatus != null) {
      map['approval_status'] = Variable<String>(approvalStatus);
    }
    if (!nullToAbsent || inventoryPartId != null) {
      map['inventory_part_id'] = Variable<int>(inventoryPartId);
    }
    if (!nullToAbsent || laborName != null) {
      map['labor_name'] = Variable<String>(laborName);
    }
    if (!nullToAbsent || partNumber != null) {
      map['part_number'] = Variable<String>(partNumber);
    }
    return map;
  }

  EstimateLineItemsCompanion toCompanion(bool nullToAbsent) {
    return EstimateLineItemsCompanion(
      id: Value(id),
      estimateId: Value(estimateId),
      type: Value(type),
      description: Value(description),
      quantity: Value(quantity),
      unitPrice: Value(unitPrice),
      unitCost: unitCost == null && nullToAbsent
          ? const Value.absent()
          : Value(unitCost),
      vendorId: vendorId == null && nullToAbsent
          ? const Value.absent()
          : Value(vendorId),
      parentLaborId: parentLaborId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentLaborId),
      isDone: isDone == null && nullToAbsent
          ? const Value.absent()
          : Value(isDone),
      approvalStatus: approvalStatus == null && nullToAbsent
          ? const Value.absent()
          : Value(approvalStatus),
      inventoryPartId: inventoryPartId == null && nullToAbsent
          ? const Value.absent()
          : Value(inventoryPartId),
      laborName: laborName == null && nullToAbsent
          ? const Value.absent()
          : Value(laborName),
      partNumber: partNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(partNumber),
    );
  }

  factory EstimateLineItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EstimateLineItem(
      id: serializer.fromJson<int>(json['id']),
      estimateId: serializer.fromJson<int>(json['estimateId']),
      type: serializer.fromJson<String>(json['type']),
      description: serializer.fromJson<String>(json['description']),
      quantity: serializer.fromJson<double>(json['quantity']),
      unitPrice: serializer.fromJson<int>(json['unitPrice']),
      unitCost: serializer.fromJson<int?>(json['unitCost']),
      vendorId: serializer.fromJson<int?>(json['vendorId']),
      parentLaborId: serializer.fromJson<int?>(json['parentLaborId']),
      isDone: serializer.fromJson<bool?>(json['isDone']),
      approvalStatus: serializer.fromJson<String?>(json['approvalStatus']),
      inventoryPartId: serializer.fromJson<int?>(json['inventoryPartId']),
      laborName: serializer.fromJson<String?>(json['laborName']),
      partNumber: serializer.fromJson<String?>(json['partNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'estimateId': serializer.toJson<int>(estimateId),
      'type': serializer.toJson<String>(type),
      'description': serializer.toJson<String>(description),
      'quantity': serializer.toJson<double>(quantity),
      'unitPrice': serializer.toJson<int>(unitPrice),
      'unitCost': serializer.toJson<int?>(unitCost),
      'vendorId': serializer.toJson<int?>(vendorId),
      'parentLaborId': serializer.toJson<int?>(parentLaborId),
      'isDone': serializer.toJson<bool?>(isDone),
      'approvalStatus': serializer.toJson<String?>(approvalStatus),
      'inventoryPartId': serializer.toJson<int?>(inventoryPartId),
      'laborName': serializer.toJson<String?>(laborName),
      'partNumber': serializer.toJson<String?>(partNumber),
    };
  }

  EstimateLineItem copyWith({
    int? id,
    int? estimateId,
    String? type,
    String? description,
    double? quantity,
    int? unitPrice,
    Value<int?> unitCost = const Value.absent(),
    Value<int?> vendorId = const Value.absent(),
    Value<int?> parentLaborId = const Value.absent(),
    Value<bool?> isDone = const Value.absent(),
    Value<String?> approvalStatus = const Value.absent(),
    Value<int?> inventoryPartId = const Value.absent(),
    Value<String?> laborName = const Value.absent(),
    Value<String?> partNumber = const Value.absent(),
  }) => EstimateLineItem(
    id: id ?? this.id,
    estimateId: estimateId ?? this.estimateId,
    type: type ?? this.type,
    description: description ?? this.description,
    quantity: quantity ?? this.quantity,
    unitPrice: unitPrice ?? this.unitPrice,
    unitCost: unitCost.present ? unitCost.value : this.unitCost,
    vendorId: vendorId.present ? vendorId.value : this.vendorId,
    parentLaborId: parentLaborId.present
        ? parentLaborId.value
        : this.parentLaborId,
    isDone: isDone.present ? isDone.value : this.isDone,
    approvalStatus: approvalStatus.present
        ? approvalStatus.value
        : this.approvalStatus,
    inventoryPartId: inventoryPartId.present
        ? inventoryPartId.value
        : this.inventoryPartId,
    laborName: laborName.present ? laborName.value : this.laborName,
    partNumber: partNumber.present ? partNumber.value : this.partNumber,
  );
  EstimateLineItem copyWithCompanion(EstimateLineItemsCompanion data) {
    return EstimateLineItem(
      id: data.id.present ? data.id.value : this.id,
      estimateId: data.estimateId.present
          ? data.estimateId.value
          : this.estimateId,
      type: data.type.present ? data.type.value : this.type,
      description: data.description.present
          ? data.description.value
          : this.description,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitPrice: data.unitPrice.present ? data.unitPrice.value : this.unitPrice,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      vendorId: data.vendorId.present ? data.vendorId.value : this.vendorId,
      parentLaborId: data.parentLaborId.present
          ? data.parentLaborId.value
          : this.parentLaborId,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      approvalStatus: data.approvalStatus.present
          ? data.approvalStatus.value
          : this.approvalStatus,
      inventoryPartId: data.inventoryPartId.present
          ? data.inventoryPartId.value
          : this.inventoryPartId,
      laborName: data.laborName.present ? data.laborName.value : this.laborName,
      partNumber: data.partNumber.present
          ? data.partNumber.value
          : this.partNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EstimateLineItem(')
          ..write('id: $id, ')
          ..write('estimateId: $estimateId, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('unitCost: $unitCost, ')
          ..write('vendorId: $vendorId, ')
          ..write('parentLaborId: $parentLaborId, ')
          ..write('isDone: $isDone, ')
          ..write('approvalStatus: $approvalStatus, ')
          ..write('inventoryPartId: $inventoryPartId, ')
          ..write('laborName: $laborName, ')
          ..write('partNumber: $partNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    estimateId,
    type,
    description,
    quantity,
    unitPrice,
    unitCost,
    vendorId,
    parentLaborId,
    isDone,
    approvalStatus,
    inventoryPartId,
    laborName,
    partNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EstimateLineItem &&
          other.id == this.id &&
          other.estimateId == this.estimateId &&
          other.type == this.type &&
          other.description == this.description &&
          other.quantity == this.quantity &&
          other.unitPrice == this.unitPrice &&
          other.unitCost == this.unitCost &&
          other.vendorId == this.vendorId &&
          other.parentLaborId == this.parentLaborId &&
          other.isDone == this.isDone &&
          other.approvalStatus == this.approvalStatus &&
          other.inventoryPartId == this.inventoryPartId &&
          other.laborName == this.laborName &&
          other.partNumber == this.partNumber);
}

class EstimateLineItemsCompanion extends UpdateCompanion<EstimateLineItem> {
  final Value<int> id;
  final Value<int> estimateId;
  final Value<String> type;
  final Value<String> description;
  final Value<double> quantity;
  final Value<int> unitPrice;
  final Value<int?> unitCost;
  final Value<int?> vendorId;
  final Value<int?> parentLaborId;
  final Value<bool?> isDone;
  final Value<String?> approvalStatus;
  final Value<int?> inventoryPartId;
  final Value<String?> laborName;
  final Value<String?> partNumber;
  const EstimateLineItemsCompanion({
    this.id = const Value.absent(),
    this.estimateId = const Value.absent(),
    this.type = const Value.absent(),
    this.description = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitPrice = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.parentLaborId = const Value.absent(),
    this.isDone = const Value.absent(),
    this.approvalStatus = const Value.absent(),
    this.inventoryPartId = const Value.absent(),
    this.laborName = const Value.absent(),
    this.partNumber = const Value.absent(),
  });
  EstimateLineItemsCompanion.insert({
    this.id = const Value.absent(),
    required int estimateId,
    required String type,
    required String description,
    this.quantity = const Value.absent(),
    required int unitPrice,
    this.unitCost = const Value.absent(),
    this.vendorId = const Value.absent(),
    this.parentLaborId = const Value.absent(),
    this.isDone = const Value.absent(),
    this.approvalStatus = const Value.absent(),
    this.inventoryPartId = const Value.absent(),
    this.laborName = const Value.absent(),
    this.partNumber = const Value.absent(),
  }) : estimateId = Value(estimateId),
       type = Value(type),
       description = Value(description),
       unitPrice = Value(unitPrice);
  static Insertable<EstimateLineItem> custom({
    Expression<int>? id,
    Expression<int>? estimateId,
    Expression<String>? type,
    Expression<String>? description,
    Expression<double>? quantity,
    Expression<int>? unitPrice,
    Expression<int>? unitCost,
    Expression<int>? vendorId,
    Expression<int>? parentLaborId,
    Expression<bool>? isDone,
    Expression<String>? approvalStatus,
    Expression<int>? inventoryPartId,
    Expression<String>? laborName,
    Expression<String>? partNumber,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (estimateId != null) 'estimate_id': estimateId,
      if (type != null) 'type': type,
      if (description != null) 'description': description,
      if (quantity != null) 'quantity': quantity,
      if (unitPrice != null) 'unit_price': unitPrice,
      if (unitCost != null) 'unit_cost': unitCost,
      if (vendorId != null) 'vendor_id': vendorId,
      if (parentLaborId != null) 'parent_labor_id': parentLaborId,
      if (isDone != null) 'is_done': isDone,
      if (approvalStatus != null) 'approval_status': approvalStatus,
      if (inventoryPartId != null) 'inventory_part_id': inventoryPartId,
      if (laborName != null) 'labor_name': laborName,
      if (partNumber != null) 'part_number': partNumber,
    });
  }

  EstimateLineItemsCompanion copyWith({
    Value<int>? id,
    Value<int>? estimateId,
    Value<String>? type,
    Value<String>? description,
    Value<double>? quantity,
    Value<int>? unitPrice,
    Value<int?>? unitCost,
    Value<int?>? vendorId,
    Value<int?>? parentLaborId,
    Value<bool?>? isDone,
    Value<String?>? approvalStatus,
    Value<int?>? inventoryPartId,
    Value<String?>? laborName,
    Value<String?>? partNumber,
  }) {
    return EstimateLineItemsCompanion(
      id: id ?? this.id,
      estimateId: estimateId ?? this.estimateId,
      type: type ?? this.type,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      unitCost: unitCost ?? this.unitCost,
      vendorId: vendorId ?? this.vendorId,
      parentLaborId: parentLaborId ?? this.parentLaborId,
      isDone: isDone ?? this.isDone,
      approvalStatus: approvalStatus ?? this.approvalStatus,
      inventoryPartId: inventoryPartId ?? this.inventoryPartId,
      laborName: laborName ?? this.laborName,
      partNumber: partNumber ?? this.partNumber,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (estimateId.present) {
      map['estimate_id'] = Variable<int>(estimateId.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    if (unitPrice.present) {
      map['unit_price'] = Variable<int>(unitPrice.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<int>(unitCost.value);
    }
    if (vendorId.present) {
      map['vendor_id'] = Variable<int>(vendorId.value);
    }
    if (parentLaborId.present) {
      map['parent_labor_id'] = Variable<int>(parentLaborId.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (approvalStatus.present) {
      map['approval_status'] = Variable<String>(approvalStatus.value);
    }
    if (inventoryPartId.present) {
      map['inventory_part_id'] = Variable<int>(inventoryPartId.value);
    }
    if (laborName.present) {
      map['labor_name'] = Variable<String>(laborName.value);
    }
    if (partNumber.present) {
      map['part_number'] = Variable<String>(partNumber.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EstimateLineItemsCompanion(')
          ..write('id: $id, ')
          ..write('estimateId: $estimateId, ')
          ..write('type: $type, ')
          ..write('description: $description, ')
          ..write('quantity: $quantity, ')
          ..write('unitPrice: $unitPrice, ')
          ..write('unitCost: $unitCost, ')
          ..write('vendorId: $vendorId, ')
          ..write('parentLaborId: $parentLaborId, ')
          ..write('isDone: $isDone, ')
          ..write('approvalStatus: $approvalStatus, ')
          ..write('inventoryPartId: $inventoryPartId, ')
          ..write('laborName: $laborName, ')
          ..write('partNumber: $partNumber')
          ..write(')'))
        .toString();
  }
}

class $ShopSettingsTable extends ShopSettings
    with TableInfo<$ShopSettingsTable, ShopSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShopSettingsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _shopNameMeta = const VerificationMeta(
    'shopName',
  );
  @override
  late final GeneratedColumn<String> shopName = GeneratedColumn<String>(
    'shop_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _defaultLaborRateMeta = const VerificationMeta(
    'defaultLaborRate',
  );
  @override
  late final GeneratedColumn<int> defaultLaborRate = GeneratedColumn<int>(
    'default_labor_rate',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(12000),
  );
  static const VerificationMeta _defaultPartsMarkupMeta =
      const VerificationMeta('defaultPartsMarkup');
  @override
  late final GeneratedColumn<double> defaultPartsMarkup =
      GeneratedColumn<double>(
        'default_parts_markup',
        aliasedName,
        false,
        type: DriftSqlType.double,
        requiredDuringInsert: false,
        defaultValue: const Constant(30.0),
      );
  static const VerificationMeta _defaultTaxRateMeta = const VerificationMeta(
    'defaultTaxRate',
  );
  @override
  late final GeneratedColumn<double> defaultTaxRate = GeneratedColumn<double>(
    'default_tax_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _shopAddressMeta = const VerificationMeta(
    'shopAddress',
  );
  @override
  late final GeneratedColumn<String> shopAddress = GeneratedColumn<String>(
    'shop_address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shopPhoneMeta = const VerificationMeta(
    'shopPhone',
  );
  @override
  late final GeneratedColumn<String> shopPhone = GeneratedColumn<String>(
    'shop_phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _shopEmailMeta = const VerificationMeta(
    'shopEmail',
  );
  @override
  late final GeneratedColumn<String> shopEmail = GeneratedColumn<String>(
    'shop_email',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopName,
    defaultLaborRate,
    defaultPartsMarkup,
    defaultTaxRate,
    shopAddress,
    shopPhone,
    shopEmail,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shop_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<ShopSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('shop_name')) {
      context.handle(
        _shopNameMeta,
        shopName.isAcceptableOrUnknown(data['shop_name']!, _shopNameMeta),
      );
    }
    if (data.containsKey('default_labor_rate')) {
      context.handle(
        _defaultLaborRateMeta,
        defaultLaborRate.isAcceptableOrUnknown(
          data['default_labor_rate']!,
          _defaultLaborRateMeta,
        ),
      );
    }
    if (data.containsKey('default_parts_markup')) {
      context.handle(
        _defaultPartsMarkupMeta,
        defaultPartsMarkup.isAcceptableOrUnknown(
          data['default_parts_markup']!,
          _defaultPartsMarkupMeta,
        ),
      );
    }
    if (data.containsKey('default_tax_rate')) {
      context.handle(
        _defaultTaxRateMeta,
        defaultTaxRate.isAcceptableOrUnknown(
          data['default_tax_rate']!,
          _defaultTaxRateMeta,
        ),
      );
    }
    if (data.containsKey('shop_address')) {
      context.handle(
        _shopAddressMeta,
        shopAddress.isAcceptableOrUnknown(
          data['shop_address']!,
          _shopAddressMeta,
        ),
      );
    }
    if (data.containsKey('shop_phone')) {
      context.handle(
        _shopPhoneMeta,
        shopPhone.isAcceptableOrUnknown(data['shop_phone']!, _shopPhoneMeta),
      );
    }
    if (data.containsKey('shop_email')) {
      context.handle(
        _shopEmailMeta,
        shopEmail.isAcceptableOrUnknown(data['shop_email']!, _shopEmailMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShopSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShopSetting(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      shopName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_name'],
      ),
      defaultLaborRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_labor_rate'],
      )!,
      defaultPartsMarkup: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_parts_markup'],
      )!,
      defaultTaxRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_tax_rate'],
      )!,
      shopAddress: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_address'],
      ),
      shopPhone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_phone'],
      ),
      shopEmail: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}shop_email'],
      ),
    );
  }

  @override
  $ShopSettingsTable createAlias(String alias) {
    return $ShopSettingsTable(attachedDatabase, alias);
  }
}

class ShopSetting extends DataClass implements Insertable<ShopSetting> {
  final int id;
  final String? shopName;
  final int defaultLaborRate;
  final double defaultPartsMarkup;
  final double defaultTaxRate;
  final String? shopAddress;
  final String? shopPhone;
  final String? shopEmail;
  const ShopSetting({
    required this.id,
    this.shopName,
    required this.defaultLaborRate,
    required this.defaultPartsMarkup,
    required this.defaultTaxRate,
    this.shopAddress,
    this.shopPhone,
    this.shopEmail,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || shopName != null) {
      map['shop_name'] = Variable<String>(shopName);
    }
    map['default_labor_rate'] = Variable<int>(defaultLaborRate);
    map['default_parts_markup'] = Variable<double>(defaultPartsMarkup);
    map['default_tax_rate'] = Variable<double>(defaultTaxRate);
    if (!nullToAbsent || shopAddress != null) {
      map['shop_address'] = Variable<String>(shopAddress);
    }
    if (!nullToAbsent || shopPhone != null) {
      map['shop_phone'] = Variable<String>(shopPhone);
    }
    if (!nullToAbsent || shopEmail != null) {
      map['shop_email'] = Variable<String>(shopEmail);
    }
    return map;
  }

  ShopSettingsCompanion toCompanion(bool nullToAbsent) {
    return ShopSettingsCompanion(
      id: Value(id),
      shopName: shopName == null && nullToAbsent
          ? const Value.absent()
          : Value(shopName),
      defaultLaborRate: Value(defaultLaborRate),
      defaultPartsMarkup: Value(defaultPartsMarkup),
      defaultTaxRate: Value(defaultTaxRate),
      shopAddress: shopAddress == null && nullToAbsent
          ? const Value.absent()
          : Value(shopAddress),
      shopPhone: shopPhone == null && nullToAbsent
          ? const Value.absent()
          : Value(shopPhone),
      shopEmail: shopEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(shopEmail),
    );
  }

  factory ShopSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShopSetting(
      id: serializer.fromJson<int>(json['id']),
      shopName: serializer.fromJson<String?>(json['shopName']),
      defaultLaborRate: serializer.fromJson<int>(json['defaultLaborRate']),
      defaultPartsMarkup: serializer.fromJson<double>(
        json['defaultPartsMarkup'],
      ),
      defaultTaxRate: serializer.fromJson<double>(json['defaultTaxRate']),
      shopAddress: serializer.fromJson<String?>(json['shopAddress']),
      shopPhone: serializer.fromJson<String?>(json['shopPhone']),
      shopEmail: serializer.fromJson<String?>(json['shopEmail']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'shopName': serializer.toJson<String?>(shopName),
      'defaultLaborRate': serializer.toJson<int>(defaultLaborRate),
      'defaultPartsMarkup': serializer.toJson<double>(defaultPartsMarkup),
      'defaultTaxRate': serializer.toJson<double>(defaultTaxRate),
      'shopAddress': serializer.toJson<String?>(shopAddress),
      'shopPhone': serializer.toJson<String?>(shopPhone),
      'shopEmail': serializer.toJson<String?>(shopEmail),
    };
  }

  ShopSetting copyWith({
    int? id,
    Value<String?> shopName = const Value.absent(),
    int? defaultLaborRate,
    double? defaultPartsMarkup,
    double? defaultTaxRate,
    Value<String?> shopAddress = const Value.absent(),
    Value<String?> shopPhone = const Value.absent(),
    Value<String?> shopEmail = const Value.absent(),
  }) => ShopSetting(
    id: id ?? this.id,
    shopName: shopName.present ? shopName.value : this.shopName,
    defaultLaborRate: defaultLaborRate ?? this.defaultLaborRate,
    defaultPartsMarkup: defaultPartsMarkup ?? this.defaultPartsMarkup,
    defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
    shopAddress: shopAddress.present ? shopAddress.value : this.shopAddress,
    shopPhone: shopPhone.present ? shopPhone.value : this.shopPhone,
    shopEmail: shopEmail.present ? shopEmail.value : this.shopEmail,
  );
  ShopSetting copyWithCompanion(ShopSettingsCompanion data) {
    return ShopSetting(
      id: data.id.present ? data.id.value : this.id,
      shopName: data.shopName.present ? data.shopName.value : this.shopName,
      defaultLaborRate: data.defaultLaborRate.present
          ? data.defaultLaborRate.value
          : this.defaultLaborRate,
      defaultPartsMarkup: data.defaultPartsMarkup.present
          ? data.defaultPartsMarkup.value
          : this.defaultPartsMarkup,
      defaultTaxRate: data.defaultTaxRate.present
          ? data.defaultTaxRate.value
          : this.defaultTaxRate,
      shopAddress: data.shopAddress.present
          ? data.shopAddress.value
          : this.shopAddress,
      shopPhone: data.shopPhone.present ? data.shopPhone.value : this.shopPhone,
      shopEmail: data.shopEmail.present ? data.shopEmail.value : this.shopEmail,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShopSetting(')
          ..write('id: $id, ')
          ..write('shopName: $shopName, ')
          ..write('defaultLaborRate: $defaultLaborRate, ')
          ..write('defaultPartsMarkup: $defaultPartsMarkup, ')
          ..write('defaultTaxRate: $defaultTaxRate, ')
          ..write('shopAddress: $shopAddress, ')
          ..write('shopPhone: $shopPhone, ')
          ..write('shopEmail: $shopEmail')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    shopName,
    defaultLaborRate,
    defaultPartsMarkup,
    defaultTaxRate,
    shopAddress,
    shopPhone,
    shopEmail,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShopSetting &&
          other.id == this.id &&
          other.shopName == this.shopName &&
          other.defaultLaborRate == this.defaultLaborRate &&
          other.defaultPartsMarkup == this.defaultPartsMarkup &&
          other.defaultTaxRate == this.defaultTaxRate &&
          other.shopAddress == this.shopAddress &&
          other.shopPhone == this.shopPhone &&
          other.shopEmail == this.shopEmail);
}

class ShopSettingsCompanion extends UpdateCompanion<ShopSetting> {
  final Value<int> id;
  final Value<String?> shopName;
  final Value<int> defaultLaborRate;
  final Value<double> defaultPartsMarkup;
  final Value<double> defaultTaxRate;
  final Value<String?> shopAddress;
  final Value<String?> shopPhone;
  final Value<String?> shopEmail;
  const ShopSettingsCompanion({
    this.id = const Value.absent(),
    this.shopName = const Value.absent(),
    this.defaultLaborRate = const Value.absent(),
    this.defaultPartsMarkup = const Value.absent(),
    this.defaultTaxRate = const Value.absent(),
    this.shopAddress = const Value.absent(),
    this.shopPhone = const Value.absent(),
    this.shopEmail = const Value.absent(),
  });
  ShopSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.shopName = const Value.absent(),
    this.defaultLaborRate = const Value.absent(),
    this.defaultPartsMarkup = const Value.absent(),
    this.defaultTaxRate = const Value.absent(),
    this.shopAddress = const Value.absent(),
    this.shopPhone = const Value.absent(),
    this.shopEmail = const Value.absent(),
  });
  static Insertable<ShopSetting> custom({
    Expression<int>? id,
    Expression<String>? shopName,
    Expression<int>? defaultLaborRate,
    Expression<double>? defaultPartsMarkup,
    Expression<double>? defaultTaxRate,
    Expression<String>? shopAddress,
    Expression<String>? shopPhone,
    Expression<String>? shopEmail,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopName != null) 'shop_name': shopName,
      if (defaultLaborRate != null) 'default_labor_rate': defaultLaborRate,
      if (defaultPartsMarkup != null)
        'default_parts_markup': defaultPartsMarkup,
      if (defaultTaxRate != null) 'default_tax_rate': defaultTaxRate,
      if (shopAddress != null) 'shop_address': shopAddress,
      if (shopPhone != null) 'shop_phone': shopPhone,
      if (shopEmail != null) 'shop_email': shopEmail,
    });
  }

  ShopSettingsCompanion copyWith({
    Value<int>? id,
    Value<String?>? shopName,
    Value<int>? defaultLaborRate,
    Value<double>? defaultPartsMarkup,
    Value<double>? defaultTaxRate,
    Value<String?>? shopAddress,
    Value<String?>? shopPhone,
    Value<String?>? shopEmail,
  }) {
    return ShopSettingsCompanion(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      defaultLaborRate: defaultLaborRate ?? this.defaultLaborRate,
      defaultPartsMarkup: defaultPartsMarkup ?? this.defaultPartsMarkup,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      shopAddress: shopAddress ?? this.shopAddress,
      shopPhone: shopPhone ?? this.shopPhone,
      shopEmail: shopEmail ?? this.shopEmail,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (shopName.present) {
      map['shop_name'] = Variable<String>(shopName.value);
    }
    if (defaultLaborRate.present) {
      map['default_labor_rate'] = Variable<int>(defaultLaborRate.value);
    }
    if (defaultPartsMarkup.present) {
      map['default_parts_markup'] = Variable<double>(defaultPartsMarkup.value);
    }
    if (defaultTaxRate.present) {
      map['default_tax_rate'] = Variable<double>(defaultTaxRate.value);
    }
    if (shopAddress.present) {
      map['shop_address'] = Variable<String>(shopAddress.value);
    }
    if (shopPhone.present) {
      map['shop_phone'] = Variable<String>(shopPhone.value);
    }
    if (shopEmail.present) {
      map['shop_email'] = Variable<String>(shopEmail.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShopSettingsCompanion(')
          ..write('id: $id, ')
          ..write('shopName: $shopName, ')
          ..write('defaultLaborRate: $defaultLaborRate, ')
          ..write('defaultPartsMarkup: $defaultPartsMarkup, ')
          ..write('defaultTaxRate: $defaultTaxRate, ')
          ..write('shopAddress: $shopAddress, ')
          ..write('shopPhone: $shopPhone, ')
          ..write('shopEmail: $shopEmail')
          ..write(')'))
        .toString();
  }
}

class $TechniciansTable extends Technicians
    with TableInfo<$TechniciansTable, Technician> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TechniciansTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _specialtyMeta = const VerificationMeta(
    'specialty',
  );
  @override
  late final GeneratedColumn<String> specialty = GeneratedColumn<String>(
    'specialty',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isArchivedMeta = const VerificationMeta(
    'isArchived',
  );
  @override
  late final GeneratedColumn<bool> isArchived = GeneratedColumn<bool>(
    'is_archived',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_archived" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    specialty,
    phone,
    isArchived,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'technicians';
  @override
  VerificationContext validateIntegrity(
    Insertable<Technician> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('specialty')) {
      context.handle(
        _specialtyMeta,
        specialty.isAcceptableOrUnknown(data['specialty']!, _specialtyMeta),
      );
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('is_archived')) {
      context.handle(
        _isArchivedMeta,
        isArchived.isAcceptableOrUnknown(data['is_archived']!, _isArchivedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Technician map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Technician(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      specialty: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}specialty'],
      ),
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      isArchived: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_archived'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $TechniciansTable createAlias(String alias) {
    return $TechniciansTable(attachedDatabase, alias);
  }
}

class Technician extends DataClass implements Insertable<Technician> {
  final int id;
  final String name;
  final String? specialty;
  final String? phone;
  final bool isArchived;
  final DateTime createdAt;
  const Technician({
    required this.id,
    required this.name,
    this.specialty,
    this.phone,
    required this.isArchived,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || specialty != null) {
      map['specialty'] = Variable<String>(specialty);
    }
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    map['is_archived'] = Variable<bool>(isArchived);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  TechniciansCompanion toCompanion(bool nullToAbsent) {
    return TechniciansCompanion(
      id: Value(id),
      name: Value(name),
      specialty: specialty == null && nullToAbsent
          ? const Value.absent()
          : Value(specialty),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      isArchived: Value(isArchived),
      createdAt: Value(createdAt),
    );
  }

  factory Technician.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Technician(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      specialty: serializer.fromJson<String?>(json['specialty']),
      phone: serializer.fromJson<String?>(json['phone']),
      isArchived: serializer.fromJson<bool>(json['isArchived']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'specialty': serializer.toJson<String?>(specialty),
      'phone': serializer.toJson<String?>(phone),
      'isArchived': serializer.toJson<bool>(isArchived),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Technician copyWith({
    int? id,
    String? name,
    Value<String?> specialty = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    bool? isArchived,
    DateTime? createdAt,
  }) => Technician(
    id: id ?? this.id,
    name: name ?? this.name,
    specialty: specialty.present ? specialty.value : this.specialty,
    phone: phone.present ? phone.value : this.phone,
    isArchived: isArchived ?? this.isArchived,
    createdAt: createdAt ?? this.createdAt,
  );
  Technician copyWithCompanion(TechniciansCompanion data) {
    return Technician(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      specialty: data.specialty.present ? data.specialty.value : this.specialty,
      phone: data.phone.present ? data.phone.value : this.phone,
      isArchived: data.isArchived.present
          ? data.isArchived.value
          : this.isArchived,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Technician(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('specialty: $specialty, ')
          ..write('phone: $phone, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, specialty, phone, isArchived, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Technician &&
          other.id == this.id &&
          other.name == this.name &&
          other.specialty == this.specialty &&
          other.phone == this.phone &&
          other.isArchived == this.isArchived &&
          other.createdAt == this.createdAt);
}

class TechniciansCompanion extends UpdateCompanion<Technician> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> specialty;
  final Value<String?> phone;
  final Value<bool> isArchived;
  final Value<DateTime> createdAt;
  const TechniciansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.specialty = const Value.absent(),
    this.phone = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TechniciansCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.specialty = const Value.absent(),
    this.phone = const Value.absent(),
    this.isArchived = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Technician> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? specialty,
    Expression<String>? phone,
    Expression<bool>? isArchived,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (specialty != null) 'specialty': specialty,
      if (phone != null) 'phone': phone,
      if (isArchived != null) 'is_archived': isArchived,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TechniciansCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? specialty,
    Value<String?>? phone,
    Value<bool>? isArchived,
    Value<DateTime>? createdAt,
  }) {
    return TechniciansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      phone: phone ?? this.phone,
      isArchived: isArchived ?? this.isArchived,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (specialty.present) {
      map['specialty'] = Variable<String>(specialty.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (isArchived.present) {
      map['is_archived'] = Variable<bool>(isArchived.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TechniciansCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('specialty: $specialty, ')
          ..write('phone: $phone, ')
          ..write('isArchived: $isArchived, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $RepairOrdersTable extends RepairOrders
    with TableInfo<$RepairOrdersTable, RepairOrder> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RepairOrdersTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _estimateIdMeta = const VerificationMeta(
    'estimateId',
  );
  @override
  late final GeneratedColumn<int> estimateId = GeneratedColumn<int>(
    'estimate_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES estimates (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<int> customerId = GeneratedColumn<int>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES customers (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _vehicleIdMeta = const VerificationMeta(
    'vehicleId',
  );
  @override
  late final GeneratedColumn<int> vehicleId = GeneratedColumn<int>(
    'vehicle_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES vehicles (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('open'),
  );
  static const VerificationMeta _technicianIdMeta = const VerificationMeta(
    'technicianId',
  );
  @override
  late final GeneratedColumn<int> technicianId = GeneratedColumn<int>(
    'technician_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES technicians (id) ON DELETE SET NULL',
    ),
  );
  static const VerificationMeta _serviceDateMeta = const VerificationMeta(
    'serviceDate',
  );
  @override
  late final GeneratedColumn<DateTime> serviceDate = GeneratedColumn<DateTime>(
    'service_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _commentMeta = const VerificationMeta(
    'comment',
  );
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
    'comment',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _taxRateBpsMeta = const VerificationMeta(
    'taxRateBps',
  );
  @override
  late final GeneratedColumn<int> taxRateBps = GeneratedColumn<int>(
    'tax_rate_bps',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    estimateId,
    customerId,
    vehicleId,
    note,
    status,
    technicianId,
    serviceDate,
    comment,
    taxRateBps,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'repair_orders';
  @override
  VerificationContext validateIntegrity(
    Insertable<RepairOrder> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('estimate_id')) {
      context.handle(
        _estimateIdMeta,
        estimateId.isAcceptableOrUnknown(data['estimate_id']!, _estimateIdMeta),
      );
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('vehicle_id')) {
      context.handle(
        _vehicleIdMeta,
        vehicleId.isAcceptableOrUnknown(data['vehicle_id']!, _vehicleIdMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('technician_id')) {
      context.handle(
        _technicianIdMeta,
        technicianId.isAcceptableOrUnknown(
          data['technician_id']!,
          _technicianIdMeta,
        ),
      );
    }
    if (data.containsKey('service_date')) {
      context.handle(
        _serviceDateMeta,
        serviceDate.isAcceptableOrUnknown(
          data['service_date']!,
          _serviceDateMeta,
        ),
      );
    }
    if (data.containsKey('comment')) {
      context.handle(
        _commentMeta,
        comment.isAcceptableOrUnknown(data['comment']!, _commentMeta),
      );
    }
    if (data.containsKey('tax_rate_bps')) {
      context.handle(
        _taxRateBpsMeta,
        taxRateBps.isAcceptableOrUnknown(
          data['tax_rate_bps']!,
          _taxRateBpsMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RepairOrder map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RepairOrder(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      estimateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}estimate_id'],
      ),
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_id'],
      )!,
      vehicleId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}vehicle_id'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      technicianId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}technician_id'],
      ),
      serviceDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}service_date'],
      ),
      comment: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}comment'],
      ),
      taxRateBps: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tax_rate_bps'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $RepairOrdersTable createAlias(String alias) {
    return $RepairOrdersTable(attachedDatabase, alias);
  }
}

class RepairOrder extends DataClass implements Insertable<RepairOrder> {
  final int id;
  final int? estimateId;
  final int customerId;
  final int? vehicleId;
  final String? note;
  final String status;
  final int? technicianId;
  final DateTime? serviceDate;
  final String? comment;
  final int? taxRateBps;
  final DateTime createdAt;
  const RepairOrder({
    required this.id,
    this.estimateId,
    required this.customerId,
    this.vehicleId,
    this.note,
    required this.status,
    this.technicianId,
    this.serviceDate,
    this.comment,
    this.taxRateBps,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || estimateId != null) {
      map['estimate_id'] = Variable<int>(estimateId);
    }
    map['customer_id'] = Variable<int>(customerId);
    if (!nullToAbsent || vehicleId != null) {
      map['vehicle_id'] = Variable<int>(vehicleId);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || technicianId != null) {
      map['technician_id'] = Variable<int>(technicianId);
    }
    if (!nullToAbsent || serviceDate != null) {
      map['service_date'] = Variable<DateTime>(serviceDate);
    }
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    if (!nullToAbsent || taxRateBps != null) {
      map['tax_rate_bps'] = Variable<int>(taxRateBps);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  RepairOrdersCompanion toCompanion(bool nullToAbsent) {
    return RepairOrdersCompanion(
      id: Value(id),
      estimateId: estimateId == null && nullToAbsent
          ? const Value.absent()
          : Value(estimateId),
      customerId: Value(customerId),
      vehicleId: vehicleId == null && nullToAbsent
          ? const Value.absent()
          : Value(vehicleId),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      status: Value(status),
      technicianId: technicianId == null && nullToAbsent
          ? const Value.absent()
          : Value(technicianId),
      serviceDate: serviceDate == null && nullToAbsent
          ? const Value.absent()
          : Value(serviceDate),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      taxRateBps: taxRateBps == null && nullToAbsent
          ? const Value.absent()
          : Value(taxRateBps),
      createdAt: Value(createdAt),
    );
  }

  factory RepairOrder.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RepairOrder(
      id: serializer.fromJson<int>(json['id']),
      estimateId: serializer.fromJson<int?>(json['estimateId']),
      customerId: serializer.fromJson<int>(json['customerId']),
      vehicleId: serializer.fromJson<int?>(json['vehicleId']),
      note: serializer.fromJson<String?>(json['note']),
      status: serializer.fromJson<String>(json['status']),
      technicianId: serializer.fromJson<int?>(json['technicianId']),
      serviceDate: serializer.fromJson<DateTime?>(json['serviceDate']),
      comment: serializer.fromJson<String?>(json['comment']),
      taxRateBps: serializer.fromJson<int?>(json['taxRateBps']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'estimateId': serializer.toJson<int?>(estimateId),
      'customerId': serializer.toJson<int>(customerId),
      'vehicleId': serializer.toJson<int?>(vehicleId),
      'note': serializer.toJson<String?>(note),
      'status': serializer.toJson<String>(status),
      'technicianId': serializer.toJson<int?>(technicianId),
      'serviceDate': serializer.toJson<DateTime?>(serviceDate),
      'comment': serializer.toJson<String?>(comment),
      'taxRateBps': serializer.toJson<int?>(taxRateBps),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  RepairOrder copyWith({
    int? id,
    Value<int?> estimateId = const Value.absent(),
    int? customerId,
    Value<int?> vehicleId = const Value.absent(),
    Value<String?> note = const Value.absent(),
    String? status,
    Value<int?> technicianId = const Value.absent(),
    Value<DateTime?> serviceDate = const Value.absent(),
    Value<String?> comment = const Value.absent(),
    Value<int?> taxRateBps = const Value.absent(),
    DateTime? createdAt,
  }) => RepairOrder(
    id: id ?? this.id,
    estimateId: estimateId.present ? estimateId.value : this.estimateId,
    customerId: customerId ?? this.customerId,
    vehicleId: vehicleId.present ? vehicleId.value : this.vehicleId,
    note: note.present ? note.value : this.note,
    status: status ?? this.status,
    technicianId: technicianId.present ? technicianId.value : this.technicianId,
    serviceDate: serviceDate.present ? serviceDate.value : this.serviceDate,
    comment: comment.present ? comment.value : this.comment,
    taxRateBps: taxRateBps.present ? taxRateBps.value : this.taxRateBps,
    createdAt: createdAt ?? this.createdAt,
  );
  RepairOrder copyWithCompanion(RepairOrdersCompanion data) {
    return RepairOrder(
      id: data.id.present ? data.id.value : this.id,
      estimateId: data.estimateId.present
          ? data.estimateId.value
          : this.estimateId,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      vehicleId: data.vehicleId.present ? data.vehicleId.value : this.vehicleId,
      note: data.note.present ? data.note.value : this.note,
      status: data.status.present ? data.status.value : this.status,
      technicianId: data.technicianId.present
          ? data.technicianId.value
          : this.technicianId,
      serviceDate: data.serviceDate.present
          ? data.serviceDate.value
          : this.serviceDate,
      comment: data.comment.present ? data.comment.value : this.comment,
      taxRateBps: data.taxRateBps.present
          ? data.taxRateBps.value
          : this.taxRateBps,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RepairOrder(')
          ..write('id: $id, ')
          ..write('estimateId: $estimateId, ')
          ..write('customerId: $customerId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('technicianId: $technicianId, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('comment: $comment, ')
          ..write('taxRateBps: $taxRateBps, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    estimateId,
    customerId,
    vehicleId,
    note,
    status,
    technicianId,
    serviceDate,
    comment,
    taxRateBps,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RepairOrder &&
          other.id == this.id &&
          other.estimateId == this.estimateId &&
          other.customerId == this.customerId &&
          other.vehicleId == this.vehicleId &&
          other.note == this.note &&
          other.status == this.status &&
          other.technicianId == this.technicianId &&
          other.serviceDate == this.serviceDate &&
          other.comment == this.comment &&
          other.taxRateBps == this.taxRateBps &&
          other.createdAt == this.createdAt);
}

class RepairOrdersCompanion extends UpdateCompanion<RepairOrder> {
  final Value<int> id;
  final Value<int?> estimateId;
  final Value<int> customerId;
  final Value<int?> vehicleId;
  final Value<String?> note;
  final Value<String> status;
  final Value<int?> technicianId;
  final Value<DateTime?> serviceDate;
  final Value<String?> comment;
  final Value<int?> taxRateBps;
  final Value<DateTime> createdAt;
  const RepairOrdersCompanion({
    this.id = const Value.absent(),
    this.estimateId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.technicianId = const Value.absent(),
    this.serviceDate = const Value.absent(),
    this.comment = const Value.absent(),
    this.taxRateBps = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  RepairOrdersCompanion.insert({
    this.id = const Value.absent(),
    this.estimateId = const Value.absent(),
    required int customerId,
    this.vehicleId = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.technicianId = const Value.absent(),
    this.serviceDate = const Value.absent(),
    this.comment = const Value.absent(),
    this.taxRateBps = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : customerId = Value(customerId);
  static Insertable<RepairOrder> custom({
    Expression<int>? id,
    Expression<int>? estimateId,
    Expression<int>? customerId,
    Expression<int>? vehicleId,
    Expression<String>? note,
    Expression<String>? status,
    Expression<int>? technicianId,
    Expression<DateTime>? serviceDate,
    Expression<String>? comment,
    Expression<int>? taxRateBps,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (estimateId != null) 'estimate_id': estimateId,
      if (customerId != null) 'customer_id': customerId,
      if (vehicleId != null) 'vehicle_id': vehicleId,
      if (note != null) 'note': note,
      if (status != null) 'status': status,
      if (technicianId != null) 'technician_id': technicianId,
      if (serviceDate != null) 'service_date': serviceDate,
      if (comment != null) 'comment': comment,
      if (taxRateBps != null) 'tax_rate_bps': taxRateBps,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  RepairOrdersCompanion copyWith({
    Value<int>? id,
    Value<int?>? estimateId,
    Value<int>? customerId,
    Value<int?>? vehicleId,
    Value<String?>? note,
    Value<String>? status,
    Value<int?>? technicianId,
    Value<DateTime?>? serviceDate,
    Value<String?>? comment,
    Value<int?>? taxRateBps,
    Value<DateTime>? createdAt,
  }) {
    return RepairOrdersCompanion(
      id: id ?? this.id,
      estimateId: estimateId ?? this.estimateId,
      customerId: customerId ?? this.customerId,
      vehicleId: vehicleId ?? this.vehicleId,
      note: note ?? this.note,
      status: status ?? this.status,
      technicianId: technicianId ?? this.technicianId,
      serviceDate: serviceDate ?? this.serviceDate,
      comment: comment ?? this.comment,
      taxRateBps: taxRateBps ?? this.taxRateBps,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (estimateId.present) {
      map['estimate_id'] = Variable<int>(estimateId.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<int>(customerId.value);
    }
    if (vehicleId.present) {
      map['vehicle_id'] = Variable<int>(vehicleId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (technicianId.present) {
      map['technician_id'] = Variable<int>(technicianId.value);
    }
    if (serviceDate.present) {
      map['service_date'] = Variable<DateTime>(serviceDate.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (taxRateBps.present) {
      map['tax_rate_bps'] = Variable<int>(taxRateBps.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RepairOrdersCompanion(')
          ..write('id: $id, ')
          ..write('estimateId: $estimateId, ')
          ..write('customerId: $customerId, ')
          ..write('vehicleId: $vehicleId, ')
          ..write('note: $note, ')
          ..write('status: $status, ')
          ..write('technicianId: $technicianId, ')
          ..write('serviceDate: $serviceDate, ')
          ..write('comment: $comment, ')
          ..write('taxRateBps: $taxRateBps, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $MarkupRulesTable extends MarkupRules
    with TableInfo<$MarkupRulesTable, MarkupRule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MarkupRulesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _minCostMeta = const VerificationMeta(
    'minCost',
  );
  @override
  late final GeneratedColumn<int> minCost = GeneratedColumn<int>(
    'min_cost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxCostMeta = const VerificationMeta(
    'maxCost',
  );
  @override
  late final GeneratedColumn<int> maxCost = GeneratedColumn<int>(
    'max_cost',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _markupPercentMeta = const VerificationMeta(
    'markupPercent',
  );
  @override
  late final GeneratedColumn<double> markupPercent = GeneratedColumn<double>(
    'markup_percent',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, minCost, maxCost, markupPercent];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'markup_rules';
  @override
  VerificationContext validateIntegrity(
    Insertable<MarkupRule> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('min_cost')) {
      context.handle(
        _minCostMeta,
        minCost.isAcceptableOrUnknown(data['min_cost']!, _minCostMeta),
      );
    } else if (isInserting) {
      context.missing(_minCostMeta);
    }
    if (data.containsKey('max_cost')) {
      context.handle(
        _maxCostMeta,
        maxCost.isAcceptableOrUnknown(data['max_cost']!, _maxCostMeta),
      );
    }
    if (data.containsKey('markup_percent')) {
      context.handle(
        _markupPercentMeta,
        markupPercent.isAcceptableOrUnknown(
          data['markup_percent']!,
          _markupPercentMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_markupPercentMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MarkupRule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MarkupRule(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      minCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}min_cost'],
      )!,
      maxCost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_cost'],
      ),
      markupPercent: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}markup_percent'],
      )!,
    );
  }

  @override
  $MarkupRulesTable createAlias(String alias) {
    return $MarkupRulesTable(attachedDatabase, alias);
  }
}

class MarkupRule extends DataClass implements Insertable<MarkupRule> {
  final int id;
  final int minCost;
  final int? maxCost;
  final double markupPercent;
  const MarkupRule({
    required this.id,
    required this.minCost,
    this.maxCost,
    required this.markupPercent,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['min_cost'] = Variable<int>(minCost);
    if (!nullToAbsent || maxCost != null) {
      map['max_cost'] = Variable<int>(maxCost);
    }
    map['markup_percent'] = Variable<double>(markupPercent);
    return map;
  }

  MarkupRulesCompanion toCompanion(bool nullToAbsent) {
    return MarkupRulesCompanion(
      id: Value(id),
      minCost: Value(minCost),
      maxCost: maxCost == null && nullToAbsent
          ? const Value.absent()
          : Value(maxCost),
      markupPercent: Value(markupPercent),
    );
  }

  factory MarkupRule.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MarkupRule(
      id: serializer.fromJson<int>(json['id']),
      minCost: serializer.fromJson<int>(json['minCost']),
      maxCost: serializer.fromJson<int?>(json['maxCost']),
      markupPercent: serializer.fromJson<double>(json['markupPercent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'minCost': serializer.toJson<int>(minCost),
      'maxCost': serializer.toJson<int?>(maxCost),
      'markupPercent': serializer.toJson<double>(markupPercent),
    };
  }

  MarkupRule copyWith({
    int? id,
    int? minCost,
    Value<int?> maxCost = const Value.absent(),
    double? markupPercent,
  }) => MarkupRule(
    id: id ?? this.id,
    minCost: minCost ?? this.minCost,
    maxCost: maxCost.present ? maxCost.value : this.maxCost,
    markupPercent: markupPercent ?? this.markupPercent,
  );
  MarkupRule copyWithCompanion(MarkupRulesCompanion data) {
    return MarkupRule(
      id: data.id.present ? data.id.value : this.id,
      minCost: data.minCost.present ? data.minCost.value : this.minCost,
      maxCost: data.maxCost.present ? data.maxCost.value : this.maxCost,
      markupPercent: data.markupPercent.present
          ? data.markupPercent.value
          : this.markupPercent,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MarkupRule(')
          ..write('id: $id, ')
          ..write('minCost: $minCost, ')
          ..write('maxCost: $maxCost, ')
          ..write('markupPercent: $markupPercent')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, minCost, maxCost, markupPercent);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MarkupRule &&
          other.id == this.id &&
          other.minCost == this.minCost &&
          other.maxCost == this.maxCost &&
          other.markupPercent == this.markupPercent);
}

class MarkupRulesCompanion extends UpdateCompanion<MarkupRule> {
  final Value<int> id;
  final Value<int> minCost;
  final Value<int?> maxCost;
  final Value<double> markupPercent;
  const MarkupRulesCompanion({
    this.id = const Value.absent(),
    this.minCost = const Value.absent(),
    this.maxCost = const Value.absent(),
    this.markupPercent = const Value.absent(),
  });
  MarkupRulesCompanion.insert({
    this.id = const Value.absent(),
    required int minCost,
    this.maxCost = const Value.absent(),
    required double markupPercent,
  }) : minCost = Value(minCost),
       markupPercent = Value(markupPercent);
  static Insertable<MarkupRule> custom({
    Expression<int>? id,
    Expression<int>? minCost,
    Expression<int>? maxCost,
    Expression<double>? markupPercent,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (minCost != null) 'min_cost': minCost,
      if (maxCost != null) 'max_cost': maxCost,
      if (markupPercent != null) 'markup_percent': markupPercent,
    });
  }

  MarkupRulesCompanion copyWith({
    Value<int>? id,
    Value<int>? minCost,
    Value<int?>? maxCost,
    Value<double>? markupPercent,
  }) {
    return MarkupRulesCompanion(
      id: id ?? this.id,
      minCost: minCost ?? this.minCost,
      maxCost: maxCost ?? this.maxCost,
      markupPercent: markupPercent ?? this.markupPercent,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (minCost.present) {
      map['min_cost'] = Variable<int>(minCost.value);
    }
    if (maxCost.present) {
      map['max_cost'] = Variable<int>(maxCost.value);
    }
    if (markupPercent.present) {
      map['markup_percent'] = Variable<double>(markupPercent.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MarkupRulesCompanion(')
          ..write('id: $id, ')
          ..write('minCost: $minCost, ')
          ..write('maxCost: $maxCost, ')
          ..write('markupPercent: $markupPercent')
          ..write(')'))
        .toString();
  }
}

class $ServiceTemplatesTable extends ServiceTemplates
    with TableInfo<$ServiceTemplatesTable, ServiceTemplate> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceTemplatesTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _laborDescriptionMeta = const VerificationMeta(
    'laborDescription',
  );
  @override
  late final GeneratedColumn<String> laborDescription = GeneratedColumn<String>(
    'labor_description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _defaultHoursMeta = const VerificationMeta(
    'defaultHours',
  );
  @override
  late final GeneratedColumn<double> defaultHours = GeneratedColumn<double>(
    'default_hours',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  static const VerificationMeta _defaultRateMeta = const VerificationMeta(
    'defaultRate',
  );
  @override
  late final GeneratedColumn<int> defaultRate = GeneratedColumn<int>(
    'default_rate',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    laborDescription,
    defaultHours,
    defaultRate,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_templates';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceTemplate> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('labor_description')) {
      context.handle(
        _laborDescriptionMeta,
        laborDescription.isAcceptableOrUnknown(
          data['labor_description']!,
          _laborDescriptionMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_laborDescriptionMeta);
    }
    if (data.containsKey('default_hours')) {
      context.handle(
        _defaultHoursMeta,
        defaultHours.isAcceptableOrUnknown(
          data['default_hours']!,
          _defaultHoursMeta,
        ),
      );
    }
    if (data.containsKey('default_rate')) {
      context.handle(
        _defaultRateMeta,
        defaultRate.isAcceptableOrUnknown(
          data['default_rate']!,
          _defaultRateMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceTemplate map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceTemplate(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      laborDescription: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}labor_description'],
      )!,
      defaultHours: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}default_hours'],
      )!,
      defaultRate: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}default_rate'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ServiceTemplatesTable createAlias(String alias) {
    return $ServiceTemplatesTable(attachedDatabase, alias);
  }
}

class ServiceTemplate extends DataClass implements Insertable<ServiceTemplate> {
  final int id;
  final String name;
  final String laborDescription;
  final double defaultHours;
  final int? defaultRate;
  final DateTime createdAt;
  const ServiceTemplate({
    required this.id,
    required this.name,
    required this.laborDescription,
    required this.defaultHours,
    this.defaultRate,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['labor_description'] = Variable<String>(laborDescription);
    map['default_hours'] = Variable<double>(defaultHours);
    if (!nullToAbsent || defaultRate != null) {
      map['default_rate'] = Variable<int>(defaultRate);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ServiceTemplatesCompanion toCompanion(bool nullToAbsent) {
    return ServiceTemplatesCompanion(
      id: Value(id),
      name: Value(name),
      laborDescription: Value(laborDescription),
      defaultHours: Value(defaultHours),
      defaultRate: defaultRate == null && nullToAbsent
          ? const Value.absent()
          : Value(defaultRate),
      createdAt: Value(createdAt),
    );
  }

  factory ServiceTemplate.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceTemplate(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      laborDescription: serializer.fromJson<String>(json['laborDescription']),
      defaultHours: serializer.fromJson<double>(json['defaultHours']),
      defaultRate: serializer.fromJson<int?>(json['defaultRate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'laborDescription': serializer.toJson<String>(laborDescription),
      'defaultHours': serializer.toJson<double>(defaultHours),
      'defaultRate': serializer.toJson<int?>(defaultRate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ServiceTemplate copyWith({
    int? id,
    String? name,
    String? laborDescription,
    double? defaultHours,
    Value<int?> defaultRate = const Value.absent(),
    DateTime? createdAt,
  }) => ServiceTemplate(
    id: id ?? this.id,
    name: name ?? this.name,
    laborDescription: laborDescription ?? this.laborDescription,
    defaultHours: defaultHours ?? this.defaultHours,
    defaultRate: defaultRate.present ? defaultRate.value : this.defaultRate,
    createdAt: createdAt ?? this.createdAt,
  );
  ServiceTemplate copyWithCompanion(ServiceTemplatesCompanion data) {
    return ServiceTemplate(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      laborDescription: data.laborDescription.present
          ? data.laborDescription.value
          : this.laborDescription,
      defaultHours: data.defaultHours.present
          ? data.defaultHours.value
          : this.defaultHours,
      defaultRate: data.defaultRate.present
          ? data.defaultRate.value
          : this.defaultRate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceTemplate(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('laborDescription: $laborDescription, ')
          ..write('defaultHours: $defaultHours, ')
          ..write('defaultRate: $defaultRate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    laborDescription,
    defaultHours,
    defaultRate,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceTemplate &&
          other.id == this.id &&
          other.name == this.name &&
          other.laborDescription == this.laborDescription &&
          other.defaultHours == this.defaultHours &&
          other.defaultRate == this.defaultRate &&
          other.createdAt == this.createdAt);
}

class ServiceTemplatesCompanion extends UpdateCompanion<ServiceTemplate> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> laborDescription;
  final Value<double> defaultHours;
  final Value<int?> defaultRate;
  final Value<DateTime> createdAt;
  const ServiceTemplatesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.laborDescription = const Value.absent(),
    this.defaultHours = const Value.absent(),
    this.defaultRate = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ServiceTemplatesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String laborDescription,
    this.defaultHours = const Value.absent(),
    this.defaultRate = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       laborDescription = Value(laborDescription);
  static Insertable<ServiceTemplate> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? laborDescription,
    Expression<double>? defaultHours,
    Expression<int>? defaultRate,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (laborDescription != null) 'labor_description': laborDescription,
      if (defaultHours != null) 'default_hours': defaultHours,
      if (defaultRate != null) 'default_rate': defaultRate,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ServiceTemplatesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? laborDescription,
    Value<double>? defaultHours,
    Value<int?>? defaultRate,
    Value<DateTime>? createdAt,
  }) {
    return ServiceTemplatesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      laborDescription: laborDescription ?? this.laborDescription,
      defaultHours: defaultHours ?? this.defaultHours,
      defaultRate: defaultRate ?? this.defaultRate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (laborDescription.present) {
      map['labor_description'] = Variable<String>(laborDescription.value);
    }
    if (defaultHours.present) {
      map['default_hours'] = Variable<double>(defaultHours.value);
    }
    if (defaultRate.present) {
      map['default_rate'] = Variable<int>(defaultRate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceTemplatesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('laborDescription: $laborDescription, ')
          ..write('defaultHours: $defaultHours, ')
          ..write('defaultRate: $defaultRate, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ServiceTemplatePartsTable extends ServiceTemplateParts
    with TableInfo<$ServiceTemplatePartsTable, ServiceTemplatePart> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ServiceTemplatePartsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _templateIdMeta = const VerificationMeta(
    'templateId',
  );
  @override
  late final GeneratedColumn<int> templateId = GeneratedColumn<int>(
    'template_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES service_templates (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _inventoryPartIdMeta = const VerificationMeta(
    'inventoryPartId',
  );
  @override
  late final GeneratedColumn<int> inventoryPartId = GeneratedColumn<int>(
    'inventory_part_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES inventory_parts (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<double> quantity = GeneratedColumn<double>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1.0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    templateId,
    inventoryPartId,
    quantity,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'service_template_parts';
  @override
  VerificationContext validateIntegrity(
    Insertable<ServiceTemplatePart> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('template_id')) {
      context.handle(
        _templateIdMeta,
        templateId.isAcceptableOrUnknown(data['template_id']!, _templateIdMeta),
      );
    } else if (isInserting) {
      context.missing(_templateIdMeta);
    }
    if (data.containsKey('inventory_part_id')) {
      context.handle(
        _inventoryPartIdMeta,
        inventoryPartId.isAcceptableOrUnknown(
          data['inventory_part_id']!,
          _inventoryPartIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_inventoryPartIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ServiceTemplatePart map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ServiceTemplatePart(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      templateId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}template_id'],
      )!,
      inventoryPartId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}inventory_part_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $ServiceTemplatePartsTable createAlias(String alias) {
    return $ServiceTemplatePartsTable(attachedDatabase, alias);
  }
}

class ServiceTemplatePart extends DataClass
    implements Insertable<ServiceTemplatePart> {
  final int id;
  final int templateId;
  final int inventoryPartId;
  final double quantity;
  const ServiceTemplatePart({
    required this.id,
    required this.templateId,
    required this.inventoryPartId,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['template_id'] = Variable<int>(templateId);
    map['inventory_part_id'] = Variable<int>(inventoryPartId);
    map['quantity'] = Variable<double>(quantity);
    return map;
  }

  ServiceTemplatePartsCompanion toCompanion(bool nullToAbsent) {
    return ServiceTemplatePartsCompanion(
      id: Value(id),
      templateId: Value(templateId),
      inventoryPartId: Value(inventoryPartId),
      quantity: Value(quantity),
    );
  }

  factory ServiceTemplatePart.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ServiceTemplatePart(
      id: serializer.fromJson<int>(json['id']),
      templateId: serializer.fromJson<int>(json['templateId']),
      inventoryPartId: serializer.fromJson<int>(json['inventoryPartId']),
      quantity: serializer.fromJson<double>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'templateId': serializer.toJson<int>(templateId),
      'inventoryPartId': serializer.toJson<int>(inventoryPartId),
      'quantity': serializer.toJson<double>(quantity),
    };
  }

  ServiceTemplatePart copyWith({
    int? id,
    int? templateId,
    int? inventoryPartId,
    double? quantity,
  }) => ServiceTemplatePart(
    id: id ?? this.id,
    templateId: templateId ?? this.templateId,
    inventoryPartId: inventoryPartId ?? this.inventoryPartId,
    quantity: quantity ?? this.quantity,
  );
  ServiceTemplatePart copyWithCompanion(ServiceTemplatePartsCompanion data) {
    return ServiceTemplatePart(
      id: data.id.present ? data.id.value : this.id,
      templateId: data.templateId.present
          ? data.templateId.value
          : this.templateId,
      inventoryPartId: data.inventoryPartId.present
          ? data.inventoryPartId.value
          : this.inventoryPartId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ServiceTemplatePart(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('inventoryPartId: $inventoryPartId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, templateId, inventoryPartId, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ServiceTemplatePart &&
          other.id == this.id &&
          other.templateId == this.templateId &&
          other.inventoryPartId == this.inventoryPartId &&
          other.quantity == this.quantity);
}

class ServiceTemplatePartsCompanion
    extends UpdateCompanion<ServiceTemplatePart> {
  final Value<int> id;
  final Value<int> templateId;
  final Value<int> inventoryPartId;
  final Value<double> quantity;
  const ServiceTemplatePartsCompanion({
    this.id = const Value.absent(),
    this.templateId = const Value.absent(),
    this.inventoryPartId = const Value.absent(),
    this.quantity = const Value.absent(),
  });
  ServiceTemplatePartsCompanion.insert({
    this.id = const Value.absent(),
    required int templateId,
    required int inventoryPartId,
    this.quantity = const Value.absent(),
  }) : templateId = Value(templateId),
       inventoryPartId = Value(inventoryPartId);
  static Insertable<ServiceTemplatePart> custom({
    Expression<int>? id,
    Expression<int>? templateId,
    Expression<int>? inventoryPartId,
    Expression<double>? quantity,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (templateId != null) 'template_id': templateId,
      if (inventoryPartId != null) 'inventory_part_id': inventoryPartId,
      if (quantity != null) 'quantity': quantity,
    });
  }

  ServiceTemplatePartsCompanion copyWith({
    Value<int>? id,
    Value<int>? templateId,
    Value<int>? inventoryPartId,
    Value<double>? quantity,
  }) {
    return ServiceTemplatePartsCompanion(
      id: id ?? this.id,
      templateId: templateId ?? this.templateId,
      inventoryPartId: inventoryPartId ?? this.inventoryPartId,
      quantity: quantity ?? this.quantity,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (templateId.present) {
      map['template_id'] = Variable<int>(templateId.value);
    }
    if (inventoryPartId.present) {
      map['inventory_part_id'] = Variable<int>(inventoryPartId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<double>(quantity.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ServiceTemplatePartsCompanion(')
          ..write('id: $id, ')
          ..write('templateId: $templateId, ')
          ..write('inventoryPartId: $inventoryPartId, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomersTable customers = $CustomersTable(this);
  late final $VehiclesTable vehicles = $VehiclesTable(this);
  late final $EstimatesTable estimates = $EstimatesTable(this);
  late final $VendorsTable vendors = $VendorsTable(this);
  late final $InventoryPartsTable inventoryParts = $InventoryPartsTable(this);
  late final $EstimateLineItemsTable estimateLineItems =
      $EstimateLineItemsTable(this);
  late final $ShopSettingsTable shopSettings = $ShopSettingsTable(this);
  late final $TechniciansTable technicians = $TechniciansTable(this);
  late final $RepairOrdersTable repairOrders = $RepairOrdersTable(this);
  late final $MarkupRulesTable markupRules = $MarkupRulesTable(this);
  late final $ServiceTemplatesTable serviceTemplates = $ServiceTemplatesTable(
    this,
  );
  late final $ServiceTemplatePartsTable serviceTemplateParts =
      $ServiceTemplatePartsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customers,
    vehicles,
    estimates,
    vendors,
    inventoryParts,
    estimateLineItems,
    shopSettings,
    technicians,
    repairOrders,
    markupRules,
    serviceTemplates,
    serviceTemplateParts,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'customers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('vehicles', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'customers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('estimates', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('estimates', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'estimates',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('estimate_line_items', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vendors',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('estimate_line_items', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'inventory_parts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('estimate_line_items', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'estimates',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('repair_orders', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'customers',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('repair_orders', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'vehicles',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('repair_orders', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'technicians',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('repair_orders', kind: UpdateKind.update)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'service_templates',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('service_template_parts', kind: UpdateKind.delete)],
    ),
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'inventory_parts',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('service_template_parts', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$CustomersTableCreateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> internalNote,
      Value<DateTime> createdAt,
    });
typedef $$CustomersTableUpdateCompanionBuilder =
    CustomersCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> phone,
      Value<String?> email,
      Value<String?> internalNote,
      Value<DateTime> createdAt,
    });

final class $$CustomersTableReferences
    extends BaseReferences<_$AppDatabase, $CustomersTable, Customer> {
  $$CustomersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$VehiclesTable, List<Vehicle>> _vehiclesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.vehicles,
    aliasName: $_aliasNameGenerator(db.customers.id, db.vehicles.customerId),
  );

  $$VehiclesTableProcessedTableManager get vehiclesRefs {
    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_vehiclesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$EstimatesTable, List<Estimate>>
  _estimatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.estimates,
    aliasName: $_aliasNameGenerator(db.customers.id, db.estimates.customerId),
  );

  $$EstimatesTableProcessedTableManager get estimatesRefs {
    final manager = $$EstimatesTableTableManager(
      $_db,
      $_db.estimates,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_estimatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RepairOrdersTable, List<RepairOrder>>
  _repairOrdersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.repairOrders,
    aliasName: $_aliasNameGenerator(
      db.customers.id,
      db.repairOrders.customerId,
    ),
  );

  $$RepairOrdersTableProcessedTableManager get repairOrdersRefs {
    final manager = $$RepairOrdersTableTableManager(
      $_db,
      $_db.repairOrders,
    ).filter((f) => f.customerId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_repairOrdersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$CustomersTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get internalNote => $composableBuilder(
    column: $table.internalNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> vehiclesRefs(
    Expression<bool> Function($$VehiclesTableFilterComposer f) f,
  ) {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> estimatesRefs(
    Expression<bool> Function($$EstimatesTableFilterComposer f) f,
  ) {
    final $$EstimatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.estimates,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstimatesTableFilterComposer(
            $db: $db,
            $table: $db.estimates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> repairOrdersRefs(
    Expression<bool> Function($$RepairOrdersTableFilterComposer f) f,
  ) {
    final $$RepairOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repairOrders,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepairOrdersTableFilterComposer(
            $db: $db,
            $table: $db.repairOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get internalNote => $composableBuilder(
    column: $table.internalNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTable> {
  $$CustomersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get internalNote => $composableBuilder(
    column: $table.internalNote,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> vehiclesRefs<T extends Object>(
    Expression<T> Function($$VehiclesTableAnnotationComposer a) f,
  ) {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> estimatesRefs<T extends Object>(
    Expression<T> Function($$EstimatesTableAnnotationComposer a) f,
  ) {
    final $$EstimatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.estimates,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstimatesTableAnnotationComposer(
            $db: $db,
            $table: $db.estimates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> repairOrdersRefs<T extends Object>(
    Expression<T> Function($$RepairOrdersTableAnnotationComposer a) f,
  ) {
    final $$RepairOrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repairOrders,
      getReferencedColumn: (t) => t.customerId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepairOrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.repairOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$CustomersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTable,
          Customer,
          $$CustomersTableFilterComposer,
          $$CustomersTableOrderingComposer,
          $$CustomersTableAnnotationComposer,
          $$CustomersTableCreateCompanionBuilder,
          $$CustomersTableUpdateCompanionBuilder,
          (Customer, $$CustomersTableReferences),
          Customer,
          PrefetchHooks Function({
            bool vehiclesRefs,
            bool estimatesRefs,
            bool repairOrdersRefs,
          })
        > {
  $$CustomersTableTableManager(_$AppDatabase db, $CustomersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> internalNote = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CustomersCompanion(
                id: id,
                name: name,
                phone: phone,
                email: email,
                internalNote: internalNote,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> email = const Value.absent(),
                Value<String?> internalNote = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => CustomersCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                email: email,
                internalNote: internalNote,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$CustomersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                vehiclesRefs = false,
                estimatesRefs = false,
                repairOrdersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (vehiclesRefs) db.vehicles,
                    if (estimatesRefs) db.estimates,
                    if (repairOrdersRefs) db.repairOrders,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (vehiclesRefs)
                        await $_getPrefetchedData<
                          Customer,
                          $CustomersTable,
                          Vehicle
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._vehiclesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).vehiclesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (estimatesRefs)
                        await $_getPrefetchedData<
                          Customer,
                          $CustomersTable,
                          Estimate
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._estimatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).estimatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (repairOrdersRefs)
                        await $_getPrefetchedData<
                          Customer,
                          $CustomersTable,
                          RepairOrder
                        >(
                          currentTable: table,
                          referencedTable: $$CustomersTableReferences
                              ._repairOrdersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$CustomersTableReferences(
                                db,
                                table,
                                p0,
                              ).repairOrdersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.customerId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$CustomersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTable,
      Customer,
      $$CustomersTableFilterComposer,
      $$CustomersTableOrderingComposer,
      $$CustomersTableAnnotationComposer,
      $$CustomersTableCreateCompanionBuilder,
      $$CustomersTableUpdateCompanionBuilder,
      (Customer, $$CustomersTableReferences),
      Customer,
      PrefetchHooks Function({
        bool vehiclesRefs,
        bool estimatesRefs,
        bool repairOrdersRefs,
      })
    >;
typedef $$VehiclesTableCreateCompanionBuilder =
    VehiclesCompanion Function({
      Value<int> id,
      required int customerId,
      Value<int?> year,
      Value<String?> make,
      Value<String?> model,
      Value<String?> vin,
      Value<int?> mileage,
      Value<String?> licensePlate,
      Value<DateTime> createdAt,
    });
typedef $$VehiclesTableUpdateCompanionBuilder =
    VehiclesCompanion Function({
      Value<int> id,
      Value<int> customerId,
      Value<int?> year,
      Value<String?> make,
      Value<String?> model,
      Value<String?> vin,
      Value<int?> mileage,
      Value<String?> licensePlate,
      Value<DateTime> createdAt,
    });

final class $$VehiclesTableReferences
    extends BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle> {
  $$VehiclesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias(
        $_aliasNameGenerator(db.vehicles.customerId, db.customers.id),
      );

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EstimatesTable, List<Estimate>>
  _estimatesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.estimates,
    aliasName: $_aliasNameGenerator(db.vehicles.id, db.estimates.vehicleId),
  );

  $$EstimatesTableProcessedTableManager get estimatesRefs {
    final manager = $$EstimatesTableTableManager(
      $_db,
      $_db.estimates,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_estimatesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RepairOrdersTable, List<RepairOrder>>
  _repairOrdersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.repairOrders,
    aliasName: $_aliasNameGenerator(db.vehicles.id, db.repairOrders.vehicleId),
  );

  $$RepairOrdersTableProcessedTableManager get repairOrdersRefs {
    final manager = $$RepairOrdersTableTableManager(
      $_db,
      $_db.repairOrders,
    ).filter((f) => f.vehicleId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_repairOrdersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VehiclesTableFilterComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableFilterComposer({
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

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vin => $composableBuilder(
    column: $table.vin,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get mileage => $composableBuilder(
    column: $table.mileage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> estimatesRefs(
    Expression<bool> Function($$EstimatesTableFilterComposer f) f,
  ) {
    final $$EstimatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.estimates,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstimatesTableFilterComposer(
            $db: $db,
            $table: $db.estimates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> repairOrdersRefs(
    Expression<bool> Function($$RepairOrdersTableFilterComposer f) f,
  ) {
    final $$RepairOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repairOrders,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepairOrdersTableFilterComposer(
            $db: $db,
            $table: $db.repairOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableOrderingComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableOrderingComposer({
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

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get make => $composableBuilder(
    column: $table.make,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get model => $composableBuilder(
    column: $table.model,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vin => $composableBuilder(
    column: $table.vin,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get mileage => $composableBuilder(
    column: $table.mileage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$VehiclesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VehiclesTable> {
  $$VehiclesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get make =>
      $composableBuilder(column: $table.make, builder: (column) => column);

  GeneratedColumn<String> get model =>
      $composableBuilder(column: $table.model, builder: (column) => column);

  GeneratedColumn<String> get vin =>
      $composableBuilder(column: $table.vin, builder: (column) => column);

  GeneratedColumn<int> get mileage =>
      $composableBuilder(column: $table.mileage, builder: (column) => column);

  GeneratedColumn<String> get licensePlate => $composableBuilder(
    column: $table.licensePlate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> estimatesRefs<T extends Object>(
    Expression<T> Function($$EstimatesTableAnnotationComposer a) f,
  ) {
    final $$EstimatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.estimates,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstimatesTableAnnotationComposer(
            $db: $db,
            $table: $db.estimates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> repairOrdersRefs<T extends Object>(
    Expression<T> Function($$RepairOrdersTableAnnotationComposer a) f,
  ) {
    final $$RepairOrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repairOrders,
      getReferencedColumn: (t) => t.vehicleId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepairOrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.repairOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VehiclesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VehiclesTable,
          Vehicle,
          $$VehiclesTableFilterComposer,
          $$VehiclesTableOrderingComposer,
          $$VehiclesTableAnnotationComposer,
          $$VehiclesTableCreateCompanionBuilder,
          $$VehiclesTableUpdateCompanionBuilder,
          (Vehicle, $$VehiclesTableReferences),
          Vehicle,
          PrefetchHooks Function({
            bool customerId,
            bool estimatesRefs,
            bool repairOrdersRefs,
          })
        > {
  $$VehiclesTableTableManager(_$AppDatabase db, $VehiclesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VehiclesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VehiclesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VehiclesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> make = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> vin = const Value.absent(),
                Value<int?> mileage = const Value.absent(),
                Value<String?> licensePlate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VehiclesCompanion(
                id: id,
                customerId: customerId,
                year: year,
                make: make,
                model: model,
                vin: vin,
                mileage: mileage,
                licensePlate: licensePlate,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int customerId,
                Value<int?> year = const Value.absent(),
                Value<String?> make = const Value.absent(),
                Value<String?> model = const Value.absent(),
                Value<String?> vin = const Value.absent(),
                Value<int?> mileage = const Value.absent(),
                Value<String?> licensePlate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VehiclesCompanion.insert(
                id: id,
                customerId: customerId,
                year: year,
                make: make,
                model: model,
                vin: vin,
                mileage: mileage,
                licensePlate: licensePlate,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VehiclesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                customerId = false,
                estimatesRefs = false,
                repairOrdersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (estimatesRefs) db.estimates,
                    if (repairOrdersRefs) db.repairOrders,
                  ],
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
                        if (customerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customerId,
                                    referencedTable: $$VehiclesTableReferences
                                        ._customerIdTable(db),
                                    referencedColumn: $$VehiclesTableReferences
                                        ._customerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (estimatesRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          Estimate
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._estimatesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).estimatesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (repairOrdersRefs)
                        await $_getPrefetchedData<
                          Vehicle,
                          $VehiclesTable,
                          RepairOrder
                        >(
                          currentTable: table,
                          referencedTable: $$VehiclesTableReferences
                              ._repairOrdersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$VehiclesTableReferences(
                                db,
                                table,
                                p0,
                              ).repairOrdersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.vehicleId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$VehiclesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VehiclesTable,
      Vehicle,
      $$VehiclesTableFilterComposer,
      $$VehiclesTableOrderingComposer,
      $$VehiclesTableAnnotationComposer,
      $$VehiclesTableCreateCompanionBuilder,
      $$VehiclesTableUpdateCompanionBuilder,
      (Vehicle, $$VehiclesTableReferences),
      Vehicle,
      PrefetchHooks Function({
        bool customerId,
        bool estimatesRefs,
        bool repairOrdersRefs,
      })
    >;
typedef $$EstimatesTableCreateCompanionBuilder =
    EstimatesCompanion Function({
      Value<int> id,
      required int customerId,
      Value<int?> vehicleId,
      Value<String?> customerComplaint,
      Value<String?> note,
      Value<String> status,
      Value<double> taxRate,
      Value<DateTime?> estimateDate,
      Value<DateTime> createdAt,
    });
typedef $$EstimatesTableUpdateCompanionBuilder =
    EstimatesCompanion Function({
      Value<int> id,
      Value<int> customerId,
      Value<int?> vehicleId,
      Value<String?> customerComplaint,
      Value<String?> note,
      Value<String> status,
      Value<double> taxRate,
      Value<DateTime?> estimateDate,
      Value<DateTime> createdAt,
    });

final class $$EstimatesTableReferences
    extends BaseReferences<_$AppDatabase, $EstimatesTable, Estimate> {
  $$EstimatesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias(
        $_aliasNameGenerator(db.estimates.customerId, db.customers.id),
      );

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias(
        $_aliasNameGenerator(db.estimates.vehicleId, db.vehicles.id),
      );

  $$VehiclesTableProcessedTableManager? get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id');
    if ($_column == null) return null;
    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$EstimateLineItemsTable, List<EstimateLineItem>>
  _estimateLineItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.estimateLineItems,
        aliasName: $_aliasNameGenerator(
          db.estimates.id,
          db.estimateLineItems.estimateId,
        ),
      );

  $$EstimateLineItemsTableProcessedTableManager get estimateLineItemsRefs {
    final manager = $$EstimateLineItemsTableTableManager(
      $_db,
      $_db.estimateLineItems,
    ).filter((f) => f.estimateId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _estimateLineItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$RepairOrdersTable, List<RepairOrder>>
  _repairOrdersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.repairOrders,
    aliasName: $_aliasNameGenerator(
      db.estimates.id,
      db.repairOrders.estimateId,
    ),
  );

  $$RepairOrdersTableProcessedTableManager get repairOrdersRefs {
    final manager = $$RepairOrdersTableTableManager(
      $_db,
      $_db.repairOrders,
    ).filter((f) => f.estimateId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_repairOrdersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EstimatesTableFilterComposer
    extends Composer<_$AppDatabase, $EstimatesTable> {
  $$EstimatesTableFilterComposer({
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

  ColumnFilters<String> get customerComplaint => $composableBuilder(
    column: $table.customerComplaint,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get taxRate => $composableBuilder(
    column: $table.taxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get estimateDate => $composableBuilder(
    column: $table.estimateDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> estimateLineItemsRefs(
    Expression<bool> Function($$EstimateLineItemsTableFilterComposer f) f,
  ) {
    final $$EstimateLineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.estimateLineItems,
      getReferencedColumn: (t) => t.estimateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstimateLineItemsTableFilterComposer(
            $db: $db,
            $table: $db.estimateLineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> repairOrdersRefs(
    Expression<bool> Function($$RepairOrdersTableFilterComposer f) f,
  ) {
    final $$RepairOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repairOrders,
      getReferencedColumn: (t) => t.estimateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepairOrdersTableFilterComposer(
            $db: $db,
            $table: $db.repairOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EstimatesTableOrderingComposer
    extends Composer<_$AppDatabase, $EstimatesTable> {
  $$EstimatesTableOrderingComposer({
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

  ColumnOrderings<String> get customerComplaint => $composableBuilder(
    column: $table.customerComplaint,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get taxRate => $composableBuilder(
    column: $table.taxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get estimateDate => $composableBuilder(
    column: $table.estimateDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EstimatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EstimatesTable> {
  $$EstimatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerComplaint => $composableBuilder(
    column: $table.customerComplaint,
    builder: (column) => column,
  );

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<double> get taxRate =>
      $composableBuilder(column: $table.taxRate, builder: (column) => column);

  GeneratedColumn<DateTime> get estimateDate => $composableBuilder(
    column: $table.estimateDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> estimateLineItemsRefs<T extends Object>(
    Expression<T> Function($$EstimateLineItemsTableAnnotationComposer a) f,
  ) {
    final $$EstimateLineItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.estimateLineItems,
          getReferencedColumn: (t) => t.estimateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EstimateLineItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.estimateLineItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> repairOrdersRefs<T extends Object>(
    Expression<T> Function($$RepairOrdersTableAnnotationComposer a) f,
  ) {
    final $$RepairOrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repairOrders,
      getReferencedColumn: (t) => t.estimateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepairOrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.repairOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EstimatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EstimatesTable,
          Estimate,
          $$EstimatesTableFilterComposer,
          $$EstimatesTableOrderingComposer,
          $$EstimatesTableAnnotationComposer,
          $$EstimatesTableCreateCompanionBuilder,
          $$EstimatesTableUpdateCompanionBuilder,
          (Estimate, $$EstimatesTableReferences),
          Estimate,
          PrefetchHooks Function({
            bool customerId,
            bool vehicleId,
            bool estimateLineItemsRefs,
            bool repairOrdersRefs,
          })
        > {
  $$EstimatesTableTableManager(_$AppDatabase db, $EstimatesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EstimatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EstimatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EstimatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<int?> vehicleId = const Value.absent(),
                Value<String?> customerComplaint = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> taxRate = const Value.absent(),
                Value<DateTime?> estimateDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EstimatesCompanion(
                id: id,
                customerId: customerId,
                vehicleId: vehicleId,
                customerComplaint: customerComplaint,
                note: note,
                status: status,
                taxRate: taxRate,
                estimateDate: estimateDate,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int customerId,
                Value<int?> vehicleId = const Value.absent(),
                Value<String?> customerComplaint = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<double> taxRate = const Value.absent(),
                Value<DateTime?> estimateDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => EstimatesCompanion.insert(
                id: id,
                customerId: customerId,
                vehicleId: vehicleId,
                customerComplaint: customerComplaint,
                note: note,
                status: status,
                taxRate: taxRate,
                estimateDate: estimateDate,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EstimatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                customerId = false,
                vehicleId = false,
                estimateLineItemsRefs = false,
                repairOrdersRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (estimateLineItemsRefs) db.estimateLineItems,
                    if (repairOrdersRefs) db.repairOrders,
                  ],
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
                        if (customerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customerId,
                                    referencedTable: $$EstimatesTableReferences
                                        ._customerIdTable(db),
                                    referencedColumn: $$EstimatesTableReferences
                                        ._customerIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (vehicleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.vehicleId,
                                    referencedTable: $$EstimatesTableReferences
                                        ._vehicleIdTable(db),
                                    referencedColumn: $$EstimatesTableReferences
                                        ._vehicleIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (estimateLineItemsRefs)
                        await $_getPrefetchedData<
                          Estimate,
                          $EstimatesTable,
                          EstimateLineItem
                        >(
                          currentTable: table,
                          referencedTable: $$EstimatesTableReferences
                              ._estimateLineItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EstimatesTableReferences(
                                db,
                                table,
                                p0,
                              ).estimateLineItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.estimateId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (repairOrdersRefs)
                        await $_getPrefetchedData<
                          Estimate,
                          $EstimatesTable,
                          RepairOrder
                        >(
                          currentTable: table,
                          referencedTable: $$EstimatesTableReferences
                              ._repairOrdersRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EstimatesTableReferences(
                                db,
                                table,
                                p0,
                              ).repairOrdersRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.estimateId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$EstimatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EstimatesTable,
      Estimate,
      $$EstimatesTableFilterComposer,
      $$EstimatesTableOrderingComposer,
      $$EstimatesTableAnnotationComposer,
      $$EstimatesTableCreateCompanionBuilder,
      $$EstimatesTableUpdateCompanionBuilder,
      (Estimate, $$EstimatesTableReferences),
      Estimate,
      PrefetchHooks Function({
        bool customerId,
        bool vehicleId,
        bool estimateLineItemsRefs,
        bool repairOrdersRefs,
      })
    >;
typedef $$VendorsTableCreateCompanionBuilder =
    VendorsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> contactName,
      Value<String?> phone,
      Value<String?> accountNumber,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
    });
typedef $$VendorsTableUpdateCompanionBuilder =
    VendorsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> contactName,
      Value<String?> phone,
      Value<String?> accountNumber,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
    });

final class $$VendorsTableReferences
    extends BaseReferences<_$AppDatabase, $VendorsTable, Vendor> {
  $$VendorsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EstimateLineItemsTable, List<EstimateLineItem>>
  _estimateLineItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.estimateLineItems,
        aliasName: $_aliasNameGenerator(
          db.vendors.id,
          db.estimateLineItems.vendorId,
        ),
      );

  $$EstimateLineItemsTableProcessedTableManager get estimateLineItemsRefs {
    final manager = $$EstimateLineItemsTableTableManager(
      $_db,
      $_db.estimateLineItems,
    ).filter((f) => f.vendorId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _estimateLineItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$VendorsTableFilterComposer
    extends Composer<_$AppDatabase, $VendorsTable> {
  $$VendorsTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactName => $composableBuilder(
    column: $table.contactName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> estimateLineItemsRefs(
    Expression<bool> Function($$EstimateLineItemsTableFilterComposer f) f,
  ) {
    final $$EstimateLineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.estimateLineItems,
      getReferencedColumn: (t) => t.vendorId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstimateLineItemsTableFilterComposer(
            $db: $db,
            $table: $db.estimateLineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$VendorsTableOrderingComposer
    extends Composer<_$AppDatabase, $VendorsTable> {
  $$VendorsTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactName => $composableBuilder(
    column: $table.contactName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VendorsTableAnnotationComposer
    extends Composer<_$AppDatabase, $VendorsTable> {
  $$VendorsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contactName => $composableBuilder(
    column: $table.contactName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get accountNumber => $composableBuilder(
    column: $table.accountNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> estimateLineItemsRefs<T extends Object>(
    Expression<T> Function($$EstimateLineItemsTableAnnotationComposer a) f,
  ) {
    final $$EstimateLineItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.estimateLineItems,
          getReferencedColumn: (t) => t.vendorId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EstimateLineItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.estimateLineItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$VendorsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VendorsTable,
          Vendor,
          $$VendorsTableFilterComposer,
          $$VendorsTableOrderingComposer,
          $$VendorsTableAnnotationComposer,
          $$VendorsTableCreateCompanionBuilder,
          $$VendorsTableUpdateCompanionBuilder,
          (Vendor, $$VendorsTableReferences),
          Vendor,
          PrefetchHooks Function({bool estimateLineItemsRefs})
        > {
  $$VendorsTableTableManager(_$AppDatabase db, $VendorsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VendorsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VendorsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VendorsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> contactName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> accountNumber = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VendorsCompanion(
                id: id,
                name: name,
                contactName: contactName,
                phone: phone,
                accountNumber: accountNumber,
                isArchived: isArchived,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> contactName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> accountNumber = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VendorsCompanion.insert(
                id: id,
                name: name,
                contactName: contactName,
                phone: phone,
                accountNumber: accountNumber,
                isArchived: isArchived,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$VendorsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({estimateLineItemsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (estimateLineItemsRefs) db.estimateLineItems,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (estimateLineItemsRefs)
                    await $_getPrefetchedData<
                      Vendor,
                      $VendorsTable,
                      EstimateLineItem
                    >(
                      currentTable: table,
                      referencedTable: $$VendorsTableReferences
                          ._estimateLineItemsRefsTable(db),
                      managerFromTypedResult: (p0) => $$VendorsTableReferences(
                        db,
                        table,
                        p0,
                      ).estimateLineItemsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.vendorId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$VendorsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VendorsTable,
      Vendor,
      $$VendorsTableFilterComposer,
      $$VendorsTableOrderingComposer,
      $$VendorsTableAnnotationComposer,
      $$VendorsTableCreateCompanionBuilder,
      $$VendorsTableUpdateCompanionBuilder,
      (Vendor, $$VendorsTableReferences),
      Vendor,
      PrefetchHooks Function({bool estimateLineItemsRefs})
    >;
typedef $$InventoryPartsTableCreateCompanionBuilder =
    InventoryPartsCompanion Function({
      Value<int> id,
      Value<String?> partNumber,
      required String description,
      Value<String?> category,
      Value<int> cost,
      Value<int> sellPrice,
      Value<int> stockQty,
      Value<int> lowStockThreshold,
      Value<DateTime> createdAt,
    });
typedef $$InventoryPartsTableUpdateCompanionBuilder =
    InventoryPartsCompanion Function({
      Value<int> id,
      Value<String?> partNumber,
      Value<String> description,
      Value<String?> category,
      Value<int> cost,
      Value<int> sellPrice,
      Value<int> stockQty,
      Value<int> lowStockThreshold,
      Value<DateTime> createdAt,
    });

final class $$InventoryPartsTableReferences
    extends BaseReferences<_$AppDatabase, $InventoryPartsTable, InventoryPart> {
  $$InventoryPartsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$EstimateLineItemsTable, List<EstimateLineItem>>
  _estimateLineItemsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.estimateLineItems,
        aliasName: $_aliasNameGenerator(
          db.inventoryParts.id,
          db.estimateLineItems.inventoryPartId,
        ),
      );

  $$EstimateLineItemsTableProcessedTableManager get estimateLineItemsRefs {
    final manager = $$EstimateLineItemsTableTableManager(
      $_db,
      $_db.estimateLineItems,
    ).filter((f) => f.inventoryPartId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _estimateLineItemsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $ServiceTemplatePartsTable,
    List<ServiceTemplatePart>
  >
  _serviceTemplatePartsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.serviceTemplateParts,
        aliasName: $_aliasNameGenerator(
          db.inventoryParts.id,
          db.serviceTemplateParts.inventoryPartId,
        ),
      );

  $$ServiceTemplatePartsTableProcessedTableManager
  get serviceTemplatePartsRefs {
    final manager = $$ServiceTemplatePartsTableTableManager(
      $_db,
      $_db.serviceTemplateParts,
    ).filter((f) => f.inventoryPartId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _serviceTemplatePartsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$InventoryPartsTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryPartsTable> {
  $$InventoryPartsTableFilterComposer({
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

  ColumnFilters<String> get partNumber => $composableBuilder(
    column: $table.partNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellPrice => $composableBuilder(
    column: $table.sellPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockQty => $composableBuilder(
    column: $table.stockQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> estimateLineItemsRefs(
    Expression<bool> Function($$EstimateLineItemsTableFilterComposer f) f,
  ) {
    final $$EstimateLineItemsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.estimateLineItems,
      getReferencedColumn: (t) => t.inventoryPartId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstimateLineItemsTableFilterComposer(
            $db: $db,
            $table: $db.estimateLineItems,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> serviceTemplatePartsRefs(
    Expression<bool> Function($$ServiceTemplatePartsTableFilterComposer f) f,
  ) {
    final $$ServiceTemplatePartsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceTemplateParts,
      getReferencedColumn: (t) => t.inventoryPartId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceTemplatePartsTableFilterComposer(
            $db: $db,
            $table: $db.serviceTemplateParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$InventoryPartsTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryPartsTable> {
  $$InventoryPartsTableOrderingComposer({
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

  ColumnOrderings<String> get partNumber => $composableBuilder(
    column: $table.partNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellPrice => $composableBuilder(
    column: $table.sellPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockQty => $composableBuilder(
    column: $table.stockQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InventoryPartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryPartsTable> {
  $$InventoryPartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get partNumber => $composableBuilder(
    column: $table.partNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<int> get sellPrice =>
      $composableBuilder(column: $table.sellPrice, builder: (column) => column);

  GeneratedColumn<int> get stockQty =>
      $composableBuilder(column: $table.stockQty, builder: (column) => column);

  GeneratedColumn<int> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> estimateLineItemsRefs<T extends Object>(
    Expression<T> Function($$EstimateLineItemsTableAnnotationComposer a) f,
  ) {
    final $$EstimateLineItemsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.estimateLineItems,
          getReferencedColumn: (t) => t.inventoryPartId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$EstimateLineItemsTableAnnotationComposer(
                $db: $db,
                $table: $db.estimateLineItems,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> serviceTemplatePartsRefs<T extends Object>(
    Expression<T> Function($$ServiceTemplatePartsTableAnnotationComposer a) f,
  ) {
    final $$ServiceTemplatePartsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.serviceTemplateParts,
          getReferencedColumn: (t) => t.inventoryPartId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ServiceTemplatePartsTableAnnotationComposer(
                $db: $db,
                $table: $db.serviceTemplateParts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$InventoryPartsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryPartsTable,
          InventoryPart,
          $$InventoryPartsTableFilterComposer,
          $$InventoryPartsTableOrderingComposer,
          $$InventoryPartsTableAnnotationComposer,
          $$InventoryPartsTableCreateCompanionBuilder,
          $$InventoryPartsTableUpdateCompanionBuilder,
          (InventoryPart, $$InventoryPartsTableReferences),
          InventoryPart,
          PrefetchHooks Function({
            bool estimateLineItemsRefs,
            bool serviceTemplatePartsRefs,
          })
        > {
  $$InventoryPartsTableTableManager(
    _$AppDatabase db,
    $InventoryPartsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryPartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryPartsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InventoryPartsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> partNumber = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> cost = const Value.absent(),
                Value<int> sellPrice = const Value.absent(),
                Value<int> stockQty = const Value.absent(),
                Value<int> lowStockThreshold = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => InventoryPartsCompanion(
                id: id,
                partNumber: partNumber,
                description: description,
                category: category,
                cost: cost,
                sellPrice: sellPrice,
                stockQty: stockQty,
                lowStockThreshold: lowStockThreshold,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> partNumber = const Value.absent(),
                required String description,
                Value<String?> category = const Value.absent(),
                Value<int> cost = const Value.absent(),
                Value<int> sellPrice = const Value.absent(),
                Value<int> stockQty = const Value.absent(),
                Value<int> lowStockThreshold = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => InventoryPartsCompanion.insert(
                id: id,
                partNumber: partNumber,
                description: description,
                category: category,
                cost: cost,
                sellPrice: sellPrice,
                stockQty: stockQty,
                lowStockThreshold: lowStockThreshold,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InventoryPartsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                estimateLineItemsRefs = false,
                serviceTemplatePartsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (estimateLineItemsRefs) db.estimateLineItems,
                    if (serviceTemplatePartsRefs) db.serviceTemplateParts,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (estimateLineItemsRefs)
                        await $_getPrefetchedData<
                          InventoryPart,
                          $InventoryPartsTable,
                          EstimateLineItem
                        >(
                          currentTable: table,
                          referencedTable: $$InventoryPartsTableReferences
                              ._estimateLineItemsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InventoryPartsTableReferences(
                                db,
                                table,
                                p0,
                              ).estimateLineItemsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.inventoryPartId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (serviceTemplatePartsRefs)
                        await $_getPrefetchedData<
                          InventoryPart,
                          $InventoryPartsTable,
                          ServiceTemplatePart
                        >(
                          currentTable: table,
                          referencedTable: $$InventoryPartsTableReferences
                              ._serviceTemplatePartsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$InventoryPartsTableReferences(
                                db,
                                table,
                                p0,
                              ).serviceTemplatePartsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.inventoryPartId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$InventoryPartsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryPartsTable,
      InventoryPart,
      $$InventoryPartsTableFilterComposer,
      $$InventoryPartsTableOrderingComposer,
      $$InventoryPartsTableAnnotationComposer,
      $$InventoryPartsTableCreateCompanionBuilder,
      $$InventoryPartsTableUpdateCompanionBuilder,
      (InventoryPart, $$InventoryPartsTableReferences),
      InventoryPart,
      PrefetchHooks Function({
        bool estimateLineItemsRefs,
        bool serviceTemplatePartsRefs,
      })
    >;
typedef $$EstimateLineItemsTableCreateCompanionBuilder =
    EstimateLineItemsCompanion Function({
      Value<int> id,
      required int estimateId,
      required String type,
      required String description,
      Value<double> quantity,
      required int unitPrice,
      Value<int?> unitCost,
      Value<int?> vendorId,
      Value<int?> parentLaborId,
      Value<bool?> isDone,
      Value<String?> approvalStatus,
      Value<int?> inventoryPartId,
      Value<String?> laborName,
      Value<String?> partNumber,
    });
typedef $$EstimateLineItemsTableUpdateCompanionBuilder =
    EstimateLineItemsCompanion Function({
      Value<int> id,
      Value<int> estimateId,
      Value<String> type,
      Value<String> description,
      Value<double> quantity,
      Value<int> unitPrice,
      Value<int?> unitCost,
      Value<int?> vendorId,
      Value<int?> parentLaborId,
      Value<bool?> isDone,
      Value<String?> approvalStatus,
      Value<int?> inventoryPartId,
      Value<String?> laborName,
      Value<String?> partNumber,
    });

final class $$EstimateLineItemsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $EstimateLineItemsTable,
          EstimateLineItem
        > {
  $$EstimateLineItemsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EstimatesTable _estimateIdTable(_$AppDatabase db) =>
      db.estimates.createAlias(
        $_aliasNameGenerator(db.estimateLineItems.estimateId, db.estimates.id),
      );

  $$EstimatesTableProcessedTableManager get estimateId {
    final $_column = $_itemColumn<int>('estimate_id')!;

    final manager = $$EstimatesTableTableManager(
      $_db,
      $_db.estimates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_estimateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VendorsTable _vendorIdTable(_$AppDatabase db) =>
      db.vendors.createAlias(
        $_aliasNameGenerator(db.estimateLineItems.vendorId, db.vendors.id),
      );

  $$VendorsTableProcessedTableManager? get vendorId {
    final $_column = $_itemColumn<int>('vendor_id');
    if ($_column == null) return null;
    final manager = $$VendorsTableTableManager(
      $_db,
      $_db.vendors,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vendorIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InventoryPartsTable _inventoryPartIdTable(_$AppDatabase db) =>
      db.inventoryParts.createAlias(
        $_aliasNameGenerator(
          db.estimateLineItems.inventoryPartId,
          db.inventoryParts.id,
        ),
      );

  $$InventoryPartsTableProcessedTableManager? get inventoryPartId {
    final $_column = $_itemColumn<int>('inventory_part_id');
    if ($_column == null) return null;
    final manager = $$InventoryPartsTableTableManager(
      $_db,
      $_db.inventoryParts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_inventoryPartIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$EstimateLineItemsTableFilterComposer
    extends Composer<_$AppDatabase, $EstimateLineItemsTable> {
  $$EstimateLineItemsTableFilterComposer({
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

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get parentLaborId => $composableBuilder(
    column: $table.parentLaborId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get approvalStatus => $composableBuilder(
    column: $table.approvalStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get laborName => $composableBuilder(
    column: $table.laborName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partNumber => $composableBuilder(
    column: $table.partNumber,
    builder: (column) => ColumnFilters(column),
  );

  $$EstimatesTableFilterComposer get estimateId {
    final $$EstimatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estimateId,
      referencedTable: $db.estimates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstimatesTableFilterComposer(
            $db: $db,
            $table: $db.estimates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VendorsTableFilterComposer get vendorId {
    final $$VendorsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vendorId,
      referencedTable: $db.vendors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorsTableFilterComposer(
            $db: $db,
            $table: $db.vendors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryPartsTableFilterComposer get inventoryPartId {
    final $$InventoryPartsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inventoryPartId,
      referencedTable: $db.inventoryParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryPartsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EstimateLineItemsTableOrderingComposer
    extends Composer<_$AppDatabase, $EstimateLineItemsTable> {
  $$EstimateLineItemsTableOrderingComposer({
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

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get parentLaborId => $composableBuilder(
    column: $table.parentLaborId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get approvalStatus => $composableBuilder(
    column: $table.approvalStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get laborName => $composableBuilder(
    column: $table.laborName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partNumber => $composableBuilder(
    column: $table.partNumber,
    builder: (column) => ColumnOrderings(column),
  );

  $$EstimatesTableOrderingComposer get estimateId {
    final $$EstimatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estimateId,
      referencedTable: $db.estimates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstimatesTableOrderingComposer(
            $db: $db,
            $table: $db.estimates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VendorsTableOrderingComposer get vendorId {
    final $$VendorsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vendorId,
      referencedTable: $db.vendors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorsTableOrderingComposer(
            $db: $db,
            $table: $db.vendors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryPartsTableOrderingComposer get inventoryPartId {
    final $$InventoryPartsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inventoryPartId,
      referencedTable: $db.inventoryParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryPartsTableOrderingComposer(
            $db: $db,
            $table: $db.inventoryParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EstimateLineItemsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EstimateLineItemsTable> {
  $$EstimateLineItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<int> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<int> get parentLaborId => $composableBuilder(
    column: $table.parentLaborId,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<String> get approvalStatus => $composableBuilder(
    column: $table.approvalStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get laborName =>
      $composableBuilder(column: $table.laborName, builder: (column) => column);

  GeneratedColumn<String> get partNumber => $composableBuilder(
    column: $table.partNumber,
    builder: (column) => column,
  );

  $$EstimatesTableAnnotationComposer get estimateId {
    final $$EstimatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estimateId,
      referencedTable: $db.estimates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstimatesTableAnnotationComposer(
            $db: $db,
            $table: $db.estimates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VendorsTableAnnotationComposer get vendorId {
    final $$VendorsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vendorId,
      referencedTable: $db.vendors,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VendorsTableAnnotationComposer(
            $db: $db,
            $table: $db.vendors,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryPartsTableAnnotationComposer get inventoryPartId {
    final $$InventoryPartsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inventoryPartId,
      referencedTable: $db.inventoryParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryPartsTableAnnotationComposer(
            $db: $db,
            $table: $db.inventoryParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EstimateLineItemsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EstimateLineItemsTable,
          EstimateLineItem,
          $$EstimateLineItemsTableFilterComposer,
          $$EstimateLineItemsTableOrderingComposer,
          $$EstimateLineItemsTableAnnotationComposer,
          $$EstimateLineItemsTableCreateCompanionBuilder,
          $$EstimateLineItemsTableUpdateCompanionBuilder,
          (EstimateLineItem, $$EstimateLineItemsTableReferences),
          EstimateLineItem,
          PrefetchHooks Function({
            bool estimateId,
            bool vendorId,
            bool inventoryPartId,
          })
        > {
  $$EstimateLineItemsTableTableManager(
    _$AppDatabase db,
    $EstimateLineItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EstimateLineItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EstimateLineItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EstimateLineItemsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> estimateId = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<double> quantity = const Value.absent(),
                Value<int> unitPrice = const Value.absent(),
                Value<int?> unitCost = const Value.absent(),
                Value<int?> vendorId = const Value.absent(),
                Value<int?> parentLaborId = const Value.absent(),
                Value<bool?> isDone = const Value.absent(),
                Value<String?> approvalStatus = const Value.absent(),
                Value<int?> inventoryPartId = const Value.absent(),
                Value<String?> laborName = const Value.absent(),
                Value<String?> partNumber = const Value.absent(),
              }) => EstimateLineItemsCompanion(
                id: id,
                estimateId: estimateId,
                type: type,
                description: description,
                quantity: quantity,
                unitPrice: unitPrice,
                unitCost: unitCost,
                vendorId: vendorId,
                parentLaborId: parentLaborId,
                isDone: isDone,
                approvalStatus: approvalStatus,
                inventoryPartId: inventoryPartId,
                laborName: laborName,
                partNumber: partNumber,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int estimateId,
                required String type,
                required String description,
                Value<double> quantity = const Value.absent(),
                required int unitPrice,
                Value<int?> unitCost = const Value.absent(),
                Value<int?> vendorId = const Value.absent(),
                Value<int?> parentLaborId = const Value.absent(),
                Value<bool?> isDone = const Value.absent(),
                Value<String?> approvalStatus = const Value.absent(),
                Value<int?> inventoryPartId = const Value.absent(),
                Value<String?> laborName = const Value.absent(),
                Value<String?> partNumber = const Value.absent(),
              }) => EstimateLineItemsCompanion.insert(
                id: id,
                estimateId: estimateId,
                type: type,
                description: description,
                quantity: quantity,
                unitPrice: unitPrice,
                unitCost: unitCost,
                vendorId: vendorId,
                parentLaborId: parentLaborId,
                isDone: isDone,
                approvalStatus: approvalStatus,
                inventoryPartId: inventoryPartId,
                laborName: laborName,
                partNumber: partNumber,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EstimateLineItemsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                estimateId = false,
                vendorId = false,
                inventoryPartId = false,
              }) {
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
                        if (estimateId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.estimateId,
                                    referencedTable:
                                        $$EstimateLineItemsTableReferences
                                            ._estimateIdTable(db),
                                    referencedColumn:
                                        $$EstimateLineItemsTableReferences
                                            ._estimateIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (vendorId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.vendorId,
                                    referencedTable:
                                        $$EstimateLineItemsTableReferences
                                            ._vendorIdTable(db),
                                    referencedColumn:
                                        $$EstimateLineItemsTableReferences
                                            ._vendorIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (inventoryPartId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.inventoryPartId,
                                    referencedTable:
                                        $$EstimateLineItemsTableReferences
                                            ._inventoryPartIdTable(db),
                                    referencedColumn:
                                        $$EstimateLineItemsTableReferences
                                            ._inventoryPartIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$EstimateLineItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EstimateLineItemsTable,
      EstimateLineItem,
      $$EstimateLineItemsTableFilterComposer,
      $$EstimateLineItemsTableOrderingComposer,
      $$EstimateLineItemsTableAnnotationComposer,
      $$EstimateLineItemsTableCreateCompanionBuilder,
      $$EstimateLineItemsTableUpdateCompanionBuilder,
      (EstimateLineItem, $$EstimateLineItemsTableReferences),
      EstimateLineItem,
      PrefetchHooks Function({
        bool estimateId,
        bool vendorId,
        bool inventoryPartId,
      })
    >;
typedef $$ShopSettingsTableCreateCompanionBuilder =
    ShopSettingsCompanion Function({
      Value<int> id,
      Value<String?> shopName,
      Value<int> defaultLaborRate,
      Value<double> defaultPartsMarkup,
      Value<double> defaultTaxRate,
      Value<String?> shopAddress,
      Value<String?> shopPhone,
      Value<String?> shopEmail,
    });
typedef $$ShopSettingsTableUpdateCompanionBuilder =
    ShopSettingsCompanion Function({
      Value<int> id,
      Value<String?> shopName,
      Value<int> defaultLaborRate,
      Value<double> defaultPartsMarkup,
      Value<double> defaultTaxRate,
      Value<String?> shopAddress,
      Value<String?> shopPhone,
      Value<String?> shopEmail,
    });

class $$ShopSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $ShopSettingsTable> {
  $$ShopSettingsTableFilterComposer({
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

  ColumnFilters<String> get shopName => $composableBuilder(
    column: $table.shopName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultLaborRate => $composableBuilder(
    column: $table.defaultLaborRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultPartsMarkup => $composableBuilder(
    column: $table.defaultPartsMarkup,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultTaxRate => $composableBuilder(
    column: $table.defaultTaxRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shopAddress => $composableBuilder(
    column: $table.shopAddress,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shopPhone => $composableBuilder(
    column: $table.shopPhone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get shopEmail => $composableBuilder(
    column: $table.shopEmail,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ShopSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $ShopSettingsTable> {
  $$ShopSettingsTableOrderingComposer({
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

  ColumnOrderings<String> get shopName => $composableBuilder(
    column: $table.shopName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultLaborRate => $composableBuilder(
    column: $table.defaultLaborRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultPartsMarkup => $composableBuilder(
    column: $table.defaultPartsMarkup,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultTaxRate => $composableBuilder(
    column: $table.defaultTaxRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shopAddress => $composableBuilder(
    column: $table.shopAddress,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shopPhone => $composableBuilder(
    column: $table.shopPhone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get shopEmail => $composableBuilder(
    column: $table.shopEmail,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ShopSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShopSettingsTable> {
  $$ShopSettingsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get shopName =>
      $composableBuilder(column: $table.shopName, builder: (column) => column);

  GeneratedColumn<int> get defaultLaborRate => $composableBuilder(
    column: $table.defaultLaborRate,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultPartsMarkup => $composableBuilder(
    column: $table.defaultPartsMarkup,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultTaxRate => $composableBuilder(
    column: $table.defaultTaxRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shopAddress => $composableBuilder(
    column: $table.shopAddress,
    builder: (column) => column,
  );

  GeneratedColumn<String> get shopPhone =>
      $composableBuilder(column: $table.shopPhone, builder: (column) => column);

  GeneratedColumn<String> get shopEmail =>
      $composableBuilder(column: $table.shopEmail, builder: (column) => column);
}

class $$ShopSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ShopSettingsTable,
          ShopSetting,
          $$ShopSettingsTableFilterComposer,
          $$ShopSettingsTableOrderingComposer,
          $$ShopSettingsTableAnnotationComposer,
          $$ShopSettingsTableCreateCompanionBuilder,
          $$ShopSettingsTableUpdateCompanionBuilder,
          (
            ShopSetting,
            BaseReferences<_$AppDatabase, $ShopSettingsTable, ShopSetting>,
          ),
          ShopSetting,
          PrefetchHooks Function()
        > {
  $$ShopSettingsTableTableManager(_$AppDatabase db, $ShopSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShopSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShopSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShopSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> shopName = const Value.absent(),
                Value<int> defaultLaborRate = const Value.absent(),
                Value<double> defaultPartsMarkup = const Value.absent(),
                Value<double> defaultTaxRate = const Value.absent(),
                Value<String?> shopAddress = const Value.absent(),
                Value<String?> shopPhone = const Value.absent(),
                Value<String?> shopEmail = const Value.absent(),
              }) => ShopSettingsCompanion(
                id: id,
                shopName: shopName,
                defaultLaborRate: defaultLaborRate,
                defaultPartsMarkup: defaultPartsMarkup,
                defaultTaxRate: defaultTaxRate,
                shopAddress: shopAddress,
                shopPhone: shopPhone,
                shopEmail: shopEmail,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> shopName = const Value.absent(),
                Value<int> defaultLaborRate = const Value.absent(),
                Value<double> defaultPartsMarkup = const Value.absent(),
                Value<double> defaultTaxRate = const Value.absent(),
                Value<String?> shopAddress = const Value.absent(),
                Value<String?> shopPhone = const Value.absent(),
                Value<String?> shopEmail = const Value.absent(),
              }) => ShopSettingsCompanion.insert(
                id: id,
                shopName: shopName,
                defaultLaborRate: defaultLaborRate,
                defaultPartsMarkup: defaultPartsMarkup,
                defaultTaxRate: defaultTaxRate,
                shopAddress: shopAddress,
                shopPhone: shopPhone,
                shopEmail: shopEmail,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ShopSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ShopSettingsTable,
      ShopSetting,
      $$ShopSettingsTableFilterComposer,
      $$ShopSettingsTableOrderingComposer,
      $$ShopSettingsTableAnnotationComposer,
      $$ShopSettingsTableCreateCompanionBuilder,
      $$ShopSettingsTableUpdateCompanionBuilder,
      (
        ShopSetting,
        BaseReferences<_$AppDatabase, $ShopSettingsTable, ShopSetting>,
      ),
      ShopSetting,
      PrefetchHooks Function()
    >;
typedef $$TechniciansTableCreateCompanionBuilder =
    TechniciansCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> specialty,
      Value<String?> phone,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
    });
typedef $$TechniciansTableUpdateCompanionBuilder =
    TechniciansCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> specialty,
      Value<String?> phone,
      Value<bool> isArchived,
      Value<DateTime> createdAt,
    });

final class $$TechniciansTableReferences
    extends BaseReferences<_$AppDatabase, $TechniciansTable, Technician> {
  $$TechniciansTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$RepairOrdersTable, List<RepairOrder>>
  _repairOrdersRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.repairOrders,
    aliasName: $_aliasNameGenerator(
      db.technicians.id,
      db.repairOrders.technicianId,
    ),
  );

  $$RepairOrdersTableProcessedTableManager get repairOrdersRefs {
    final manager = $$RepairOrdersTableTableManager(
      $_db,
      $_db.repairOrders,
    ).filter((f) => f.technicianId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_repairOrdersRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TechniciansTableFilterComposer
    extends Composer<_$AppDatabase, $TechniciansTable> {
  $$TechniciansTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialty => $composableBuilder(
    column: $table.specialty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> repairOrdersRefs(
    Expression<bool> Function($$RepairOrdersTableFilterComposer f) f,
  ) {
    final $$RepairOrdersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repairOrders,
      getReferencedColumn: (t) => t.technicianId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepairOrdersTableFilterComposer(
            $db: $db,
            $table: $db.repairOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TechniciansTableOrderingComposer
    extends Composer<_$AppDatabase, $TechniciansTable> {
  $$TechniciansTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialty => $composableBuilder(
    column: $table.specialty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TechniciansTableAnnotationComposer
    extends Composer<_$AppDatabase, $TechniciansTable> {
  $$TechniciansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get specialty =>
      $composableBuilder(column: $table.specialty, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<bool> get isArchived => $composableBuilder(
    column: $table.isArchived,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> repairOrdersRefs<T extends Object>(
    Expression<T> Function($$RepairOrdersTableAnnotationComposer a) f,
  ) {
    final $$RepairOrdersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.repairOrders,
      getReferencedColumn: (t) => t.technicianId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$RepairOrdersTableAnnotationComposer(
            $db: $db,
            $table: $db.repairOrders,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TechniciansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TechniciansTable,
          Technician,
          $$TechniciansTableFilterComposer,
          $$TechniciansTableOrderingComposer,
          $$TechniciansTableAnnotationComposer,
          $$TechniciansTableCreateCompanionBuilder,
          $$TechniciansTableUpdateCompanionBuilder,
          (Technician, $$TechniciansTableReferences),
          Technician,
          PrefetchHooks Function({bool repairOrdersRefs})
        > {
  $$TechniciansTableTableManager(_$AppDatabase db, $TechniciansTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TechniciansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TechniciansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TechniciansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> specialty = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TechniciansCompanion(
                id: id,
                name: name,
                specialty: specialty,
                phone: phone,
                isArchived: isArchived,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> specialty = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<bool> isArchived = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TechniciansCompanion.insert(
                id: id,
                name: name,
                specialty: specialty,
                phone: phone,
                isArchived: isArchived,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TechniciansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({repairOrdersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (repairOrdersRefs) db.repairOrders],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (repairOrdersRefs)
                    await $_getPrefetchedData<
                      Technician,
                      $TechniciansTable,
                      RepairOrder
                    >(
                      currentTable: table,
                      referencedTable: $$TechniciansTableReferences
                          ._repairOrdersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$TechniciansTableReferences(
                            db,
                            table,
                            p0,
                          ).repairOrdersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.technicianId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TechniciansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TechniciansTable,
      Technician,
      $$TechniciansTableFilterComposer,
      $$TechniciansTableOrderingComposer,
      $$TechniciansTableAnnotationComposer,
      $$TechniciansTableCreateCompanionBuilder,
      $$TechniciansTableUpdateCompanionBuilder,
      (Technician, $$TechniciansTableReferences),
      Technician,
      PrefetchHooks Function({bool repairOrdersRefs})
    >;
typedef $$RepairOrdersTableCreateCompanionBuilder =
    RepairOrdersCompanion Function({
      Value<int> id,
      Value<int?> estimateId,
      required int customerId,
      Value<int?> vehicleId,
      Value<String?> note,
      Value<String> status,
      Value<int?> technicianId,
      Value<DateTime?> serviceDate,
      Value<String?> comment,
      Value<int?> taxRateBps,
      Value<DateTime> createdAt,
    });
typedef $$RepairOrdersTableUpdateCompanionBuilder =
    RepairOrdersCompanion Function({
      Value<int> id,
      Value<int?> estimateId,
      Value<int> customerId,
      Value<int?> vehicleId,
      Value<String?> note,
      Value<String> status,
      Value<int?> technicianId,
      Value<DateTime?> serviceDate,
      Value<String?> comment,
      Value<int?> taxRateBps,
      Value<DateTime> createdAt,
    });

final class $$RepairOrdersTableReferences
    extends BaseReferences<_$AppDatabase, $RepairOrdersTable, RepairOrder> {
  $$RepairOrdersTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EstimatesTable _estimateIdTable(_$AppDatabase db) =>
      db.estimates.createAlias(
        $_aliasNameGenerator(db.repairOrders.estimateId, db.estimates.id),
      );

  $$EstimatesTableProcessedTableManager? get estimateId {
    final $_column = $_itemColumn<int>('estimate_id');
    if ($_column == null) return null;
    final manager = $$EstimatesTableTableManager(
      $_db,
      $_db.estimates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_estimateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $CustomersTable _customerIdTable(_$AppDatabase db) =>
      db.customers.createAlias(
        $_aliasNameGenerator(db.repairOrders.customerId, db.customers.id),
      );

  $$CustomersTableProcessedTableManager get customerId {
    final $_column = $_itemColumn<int>('customer_id')!;

    final manager = $$CustomersTableTableManager(
      $_db,
      $_db.customers,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_customerIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $VehiclesTable _vehicleIdTable(_$AppDatabase db) =>
      db.vehicles.createAlias(
        $_aliasNameGenerator(db.repairOrders.vehicleId, db.vehicles.id),
      );

  $$VehiclesTableProcessedTableManager? get vehicleId {
    final $_column = $_itemColumn<int>('vehicle_id');
    if ($_column == null) return null;
    final manager = $$VehiclesTableTableManager(
      $_db,
      $_db.vehicles,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_vehicleIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TechniciansTable _technicianIdTable(_$AppDatabase db) =>
      db.technicians.createAlias(
        $_aliasNameGenerator(db.repairOrders.technicianId, db.technicians.id),
      );

  $$TechniciansTableProcessedTableManager? get technicianId {
    final $_column = $_itemColumn<int>('technician_id');
    if ($_column == null) return null;
    final manager = $$TechniciansTableTableManager(
      $_db,
      $_db.technicians,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_technicianIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$RepairOrdersTableFilterComposer
    extends Composer<_$AppDatabase, $RepairOrdersTable> {
  $$RepairOrdersTableFilterComposer({
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

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get serviceDate => $composableBuilder(
    column: $table.serviceDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get taxRateBps => $composableBuilder(
    column: $table.taxRateBps,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EstimatesTableFilterComposer get estimateId {
    final $$EstimatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estimateId,
      referencedTable: $db.estimates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstimatesTableFilterComposer(
            $db: $db,
            $table: $db.estimates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableFilterComposer get customerId {
    final $$CustomersTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableFilterComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableFilterComposer get vehicleId {
    final $$VehiclesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableFilterComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TechniciansTableFilterComposer get technicianId {
    final $$TechniciansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.technicianId,
      referencedTable: $db.technicians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TechniciansTableFilterComposer(
            $db: $db,
            $table: $db.technicians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepairOrdersTableOrderingComposer
    extends Composer<_$AppDatabase, $RepairOrdersTable> {
  $$RepairOrdersTableOrderingComposer({
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

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get serviceDate => $composableBuilder(
    column: $table.serviceDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get comment => $composableBuilder(
    column: $table.comment,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get taxRateBps => $composableBuilder(
    column: $table.taxRateBps,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EstimatesTableOrderingComposer get estimateId {
    final $$EstimatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estimateId,
      referencedTable: $db.estimates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstimatesTableOrderingComposer(
            $db: $db,
            $table: $db.estimates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableOrderingComposer get customerId {
    final $$CustomersTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableOrderingComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableOrderingComposer get vehicleId {
    final $$VehiclesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableOrderingComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TechniciansTableOrderingComposer get technicianId {
    final $$TechniciansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.technicianId,
      referencedTable: $db.technicians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TechniciansTableOrderingComposer(
            $db: $db,
            $table: $db.technicians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepairOrdersTableAnnotationComposer
    extends Composer<_$AppDatabase, $RepairOrdersTable> {
  $$RepairOrdersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get serviceDate => $composableBuilder(
    column: $table.serviceDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<int> get taxRateBps => $composableBuilder(
    column: $table.taxRateBps,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$EstimatesTableAnnotationComposer get estimateId {
    final $$EstimatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.estimateId,
      referencedTable: $db.estimates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EstimatesTableAnnotationComposer(
            $db: $db,
            $table: $db.estimates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$CustomersTableAnnotationComposer get customerId {
    final $$CustomersTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.customerId,
      referencedTable: $db.customers,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$CustomersTableAnnotationComposer(
            $db: $db,
            $table: $db.customers,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$VehiclesTableAnnotationComposer get vehicleId {
    final $$VehiclesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.vehicleId,
      referencedTable: $db.vehicles,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$VehiclesTableAnnotationComposer(
            $db: $db,
            $table: $db.vehicles,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TechniciansTableAnnotationComposer get technicianId {
    final $$TechniciansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.technicianId,
      referencedTable: $db.technicians,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TechniciansTableAnnotationComposer(
            $db: $db,
            $table: $db.technicians,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$RepairOrdersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $RepairOrdersTable,
          RepairOrder,
          $$RepairOrdersTableFilterComposer,
          $$RepairOrdersTableOrderingComposer,
          $$RepairOrdersTableAnnotationComposer,
          $$RepairOrdersTableCreateCompanionBuilder,
          $$RepairOrdersTableUpdateCompanionBuilder,
          (RepairOrder, $$RepairOrdersTableReferences),
          RepairOrder,
          PrefetchHooks Function({
            bool estimateId,
            bool customerId,
            bool vehicleId,
            bool technicianId,
          })
        > {
  $$RepairOrdersTableTableManager(_$AppDatabase db, $RepairOrdersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RepairOrdersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RepairOrdersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RepairOrdersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> estimateId = const Value.absent(),
                Value<int> customerId = const Value.absent(),
                Value<int?> vehicleId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> technicianId = const Value.absent(),
                Value<DateTime?> serviceDate = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<int?> taxRateBps = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RepairOrdersCompanion(
                id: id,
                estimateId: estimateId,
                customerId: customerId,
                vehicleId: vehicleId,
                note: note,
                status: status,
                technicianId: technicianId,
                serviceDate: serviceDate,
                comment: comment,
                taxRateBps: taxRateBps,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> estimateId = const Value.absent(),
                required int customerId,
                Value<int?> vehicleId = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int?> technicianId = const Value.absent(),
                Value<DateTime?> serviceDate = const Value.absent(),
                Value<String?> comment = const Value.absent(),
                Value<int?> taxRateBps = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => RepairOrdersCompanion.insert(
                id: id,
                estimateId: estimateId,
                customerId: customerId,
                vehicleId: vehicleId,
                note: note,
                status: status,
                technicianId: technicianId,
                serviceDate: serviceDate,
                comment: comment,
                taxRateBps: taxRateBps,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$RepairOrdersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                estimateId = false,
                customerId = false,
                vehicleId = false,
                technicianId = false,
              }) {
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
                        if (estimateId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.estimateId,
                                    referencedTable:
                                        $$RepairOrdersTableReferences
                                            ._estimateIdTable(db),
                                    referencedColumn:
                                        $$RepairOrdersTableReferences
                                            ._estimateIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (customerId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.customerId,
                                    referencedTable:
                                        $$RepairOrdersTableReferences
                                            ._customerIdTable(db),
                                    referencedColumn:
                                        $$RepairOrdersTableReferences
                                            ._customerIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (vehicleId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.vehicleId,
                                    referencedTable:
                                        $$RepairOrdersTableReferences
                                            ._vehicleIdTable(db),
                                    referencedColumn:
                                        $$RepairOrdersTableReferences
                                            ._vehicleIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (technicianId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.technicianId,
                                    referencedTable:
                                        $$RepairOrdersTableReferences
                                            ._technicianIdTable(db),
                                    referencedColumn:
                                        $$RepairOrdersTableReferences
                                            ._technicianIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$RepairOrdersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $RepairOrdersTable,
      RepairOrder,
      $$RepairOrdersTableFilterComposer,
      $$RepairOrdersTableOrderingComposer,
      $$RepairOrdersTableAnnotationComposer,
      $$RepairOrdersTableCreateCompanionBuilder,
      $$RepairOrdersTableUpdateCompanionBuilder,
      (RepairOrder, $$RepairOrdersTableReferences),
      RepairOrder,
      PrefetchHooks Function({
        bool estimateId,
        bool customerId,
        bool vehicleId,
        bool technicianId,
      })
    >;
typedef $$MarkupRulesTableCreateCompanionBuilder =
    MarkupRulesCompanion Function({
      Value<int> id,
      required int minCost,
      Value<int?> maxCost,
      required double markupPercent,
    });
typedef $$MarkupRulesTableUpdateCompanionBuilder =
    MarkupRulesCompanion Function({
      Value<int> id,
      Value<int> minCost,
      Value<int?> maxCost,
      Value<double> markupPercent,
    });

class $$MarkupRulesTableFilterComposer
    extends Composer<_$AppDatabase, $MarkupRulesTable> {
  $$MarkupRulesTableFilterComposer({
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

  ColumnFilters<int> get minCost => $composableBuilder(
    column: $table.minCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxCost => $composableBuilder(
    column: $table.maxCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get markupPercent => $composableBuilder(
    column: $table.markupPercent,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MarkupRulesTableOrderingComposer
    extends Composer<_$AppDatabase, $MarkupRulesTable> {
  $$MarkupRulesTableOrderingComposer({
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

  ColumnOrderings<int> get minCost => $composableBuilder(
    column: $table.minCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxCost => $composableBuilder(
    column: $table.maxCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get markupPercent => $composableBuilder(
    column: $table.markupPercent,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MarkupRulesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MarkupRulesTable> {
  $$MarkupRulesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get minCost =>
      $composableBuilder(column: $table.minCost, builder: (column) => column);

  GeneratedColumn<int> get maxCost =>
      $composableBuilder(column: $table.maxCost, builder: (column) => column);

  GeneratedColumn<double> get markupPercent => $composableBuilder(
    column: $table.markupPercent,
    builder: (column) => column,
  );
}

class $$MarkupRulesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MarkupRulesTable,
          MarkupRule,
          $$MarkupRulesTableFilterComposer,
          $$MarkupRulesTableOrderingComposer,
          $$MarkupRulesTableAnnotationComposer,
          $$MarkupRulesTableCreateCompanionBuilder,
          $$MarkupRulesTableUpdateCompanionBuilder,
          (
            MarkupRule,
            BaseReferences<_$AppDatabase, $MarkupRulesTable, MarkupRule>,
          ),
          MarkupRule,
          PrefetchHooks Function()
        > {
  $$MarkupRulesTableTableManager(_$AppDatabase db, $MarkupRulesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MarkupRulesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MarkupRulesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MarkupRulesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> minCost = const Value.absent(),
                Value<int?> maxCost = const Value.absent(),
                Value<double> markupPercent = const Value.absent(),
              }) => MarkupRulesCompanion(
                id: id,
                minCost: minCost,
                maxCost: maxCost,
                markupPercent: markupPercent,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int minCost,
                Value<int?> maxCost = const Value.absent(),
                required double markupPercent,
              }) => MarkupRulesCompanion.insert(
                id: id,
                minCost: minCost,
                maxCost: maxCost,
                markupPercent: markupPercent,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MarkupRulesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MarkupRulesTable,
      MarkupRule,
      $$MarkupRulesTableFilterComposer,
      $$MarkupRulesTableOrderingComposer,
      $$MarkupRulesTableAnnotationComposer,
      $$MarkupRulesTableCreateCompanionBuilder,
      $$MarkupRulesTableUpdateCompanionBuilder,
      (
        MarkupRule,
        BaseReferences<_$AppDatabase, $MarkupRulesTable, MarkupRule>,
      ),
      MarkupRule,
      PrefetchHooks Function()
    >;
typedef $$ServiceTemplatesTableCreateCompanionBuilder =
    ServiceTemplatesCompanion Function({
      Value<int> id,
      required String name,
      required String laborDescription,
      Value<double> defaultHours,
      Value<int?> defaultRate,
      Value<DateTime> createdAt,
    });
typedef $$ServiceTemplatesTableUpdateCompanionBuilder =
    ServiceTemplatesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> laborDescription,
      Value<double> defaultHours,
      Value<int?> defaultRate,
      Value<DateTime> createdAt,
    });

final class $$ServiceTemplatesTableReferences
    extends
        BaseReferences<_$AppDatabase, $ServiceTemplatesTable, ServiceTemplate> {
  $$ServiceTemplatesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $ServiceTemplatePartsTable,
    List<ServiceTemplatePart>
  >
  _serviceTemplatePartsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.serviceTemplateParts,
        aliasName: $_aliasNameGenerator(
          db.serviceTemplates.id,
          db.serviceTemplateParts.templateId,
        ),
      );

  $$ServiceTemplatePartsTableProcessedTableManager
  get serviceTemplatePartsRefs {
    final manager = $$ServiceTemplatePartsTableTableManager(
      $_db,
      $_db.serviceTemplateParts,
    ).filter((f) => f.templateId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _serviceTemplatePartsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ServiceTemplatesTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceTemplatesTable> {
  $$ServiceTemplatesTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get laborDescription => $composableBuilder(
    column: $table.laborDescription,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get defaultHours => $composableBuilder(
    column: $table.defaultHours,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get defaultRate => $composableBuilder(
    column: $table.defaultRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> serviceTemplatePartsRefs(
    Expression<bool> Function($$ServiceTemplatePartsTableFilterComposer f) f,
  ) {
    final $$ServiceTemplatePartsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.serviceTemplateParts,
      getReferencedColumn: (t) => t.templateId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceTemplatePartsTableFilterComposer(
            $db: $db,
            $table: $db.serviceTemplateParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$ServiceTemplatesTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceTemplatesTable> {
  $$ServiceTemplatesTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get laborDescription => $composableBuilder(
    column: $table.laborDescription,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get defaultHours => $composableBuilder(
    column: $table.defaultHours,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get defaultRate => $composableBuilder(
    column: $table.defaultRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ServiceTemplatesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceTemplatesTable> {
  $$ServiceTemplatesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get laborDescription => $composableBuilder(
    column: $table.laborDescription,
    builder: (column) => column,
  );

  GeneratedColumn<double> get defaultHours => $composableBuilder(
    column: $table.defaultHours,
    builder: (column) => column,
  );

  GeneratedColumn<int> get defaultRate => $composableBuilder(
    column: $table.defaultRate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> serviceTemplatePartsRefs<T extends Object>(
    Expression<T> Function($$ServiceTemplatePartsTableAnnotationComposer a) f,
  ) {
    final $$ServiceTemplatePartsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.serviceTemplateParts,
          getReferencedColumn: (t) => t.templateId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$ServiceTemplatePartsTableAnnotationComposer(
                $db: $db,
                $table: $db.serviceTemplateParts,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ServiceTemplatesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServiceTemplatesTable,
          ServiceTemplate,
          $$ServiceTemplatesTableFilterComposer,
          $$ServiceTemplatesTableOrderingComposer,
          $$ServiceTemplatesTableAnnotationComposer,
          $$ServiceTemplatesTableCreateCompanionBuilder,
          $$ServiceTemplatesTableUpdateCompanionBuilder,
          (ServiceTemplate, $$ServiceTemplatesTableReferences),
          ServiceTemplate,
          PrefetchHooks Function({bool serviceTemplatePartsRefs})
        > {
  $$ServiceTemplatesTableTableManager(
    _$AppDatabase db,
    $ServiceTemplatesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceTemplatesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceTemplatesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ServiceTemplatesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> laborDescription = const Value.absent(),
                Value<double> defaultHours = const Value.absent(),
                Value<int?> defaultRate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ServiceTemplatesCompanion(
                id: id,
                name: name,
                laborDescription: laborDescription,
                defaultHours: defaultHours,
                defaultRate: defaultRate,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String laborDescription,
                Value<double> defaultHours = const Value.absent(),
                Value<int?> defaultRate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ServiceTemplatesCompanion.insert(
                id: id,
                name: name,
                laborDescription: laborDescription,
                defaultHours: defaultHours,
                defaultRate: defaultRate,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ServiceTemplatesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({serviceTemplatePartsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (serviceTemplatePartsRefs) db.serviceTemplateParts,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (serviceTemplatePartsRefs)
                    await $_getPrefetchedData<
                      ServiceTemplate,
                      $ServiceTemplatesTable,
                      ServiceTemplatePart
                    >(
                      currentTable: table,
                      referencedTable: $$ServiceTemplatesTableReferences
                          ._serviceTemplatePartsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ServiceTemplatesTableReferences(
                            db,
                            table,
                            p0,
                          ).serviceTemplatePartsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.templateId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ServiceTemplatesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServiceTemplatesTable,
      ServiceTemplate,
      $$ServiceTemplatesTableFilterComposer,
      $$ServiceTemplatesTableOrderingComposer,
      $$ServiceTemplatesTableAnnotationComposer,
      $$ServiceTemplatesTableCreateCompanionBuilder,
      $$ServiceTemplatesTableUpdateCompanionBuilder,
      (ServiceTemplate, $$ServiceTemplatesTableReferences),
      ServiceTemplate,
      PrefetchHooks Function({bool serviceTemplatePartsRefs})
    >;
typedef $$ServiceTemplatePartsTableCreateCompanionBuilder =
    ServiceTemplatePartsCompanion Function({
      Value<int> id,
      required int templateId,
      required int inventoryPartId,
      Value<double> quantity,
    });
typedef $$ServiceTemplatePartsTableUpdateCompanionBuilder =
    ServiceTemplatePartsCompanion Function({
      Value<int> id,
      Value<int> templateId,
      Value<int> inventoryPartId,
      Value<double> quantity,
    });

final class $$ServiceTemplatePartsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $ServiceTemplatePartsTable,
          ServiceTemplatePart
        > {
  $$ServiceTemplatePartsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ServiceTemplatesTable _templateIdTable(_$AppDatabase db) =>
      db.serviceTemplates.createAlias(
        $_aliasNameGenerator(
          db.serviceTemplateParts.templateId,
          db.serviceTemplates.id,
        ),
      );

  $$ServiceTemplatesTableProcessedTableManager get templateId {
    final $_column = $_itemColumn<int>('template_id')!;

    final manager = $$ServiceTemplatesTableTableManager(
      $_db,
      $_db.serviceTemplates,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_templateIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $InventoryPartsTable _inventoryPartIdTable(_$AppDatabase db) =>
      db.inventoryParts.createAlias(
        $_aliasNameGenerator(
          db.serviceTemplateParts.inventoryPartId,
          db.inventoryParts.id,
        ),
      );

  $$InventoryPartsTableProcessedTableManager get inventoryPartId {
    final $_column = $_itemColumn<int>('inventory_part_id')!;

    final manager = $$InventoryPartsTableTableManager(
      $_db,
      $_db.inventoryParts,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_inventoryPartIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$ServiceTemplatePartsTableFilterComposer
    extends Composer<_$AppDatabase, $ServiceTemplatePartsTable> {
  $$ServiceTemplatePartsTableFilterComposer({
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

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  $$ServiceTemplatesTableFilterComposer get templateId {
    final $$ServiceTemplatesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.serviceTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceTemplatesTableFilterComposer(
            $db: $db,
            $table: $db.serviceTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryPartsTableFilterComposer get inventoryPartId {
    final $$InventoryPartsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inventoryPartId,
      referencedTable: $db.inventoryParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryPartsTableFilterComposer(
            $db: $db,
            $table: $db.inventoryParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServiceTemplatePartsTableOrderingComposer
    extends Composer<_$AppDatabase, $ServiceTemplatePartsTable> {
  $$ServiceTemplatePartsTableOrderingComposer({
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

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  $$ServiceTemplatesTableOrderingComposer get templateId {
    final $$ServiceTemplatesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.serviceTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceTemplatesTableOrderingComposer(
            $db: $db,
            $table: $db.serviceTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryPartsTableOrderingComposer get inventoryPartId {
    final $$InventoryPartsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inventoryPartId,
      referencedTable: $db.inventoryParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryPartsTableOrderingComposer(
            $db: $db,
            $table: $db.inventoryParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServiceTemplatePartsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ServiceTemplatePartsTable> {
  $$ServiceTemplatePartsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  $$ServiceTemplatesTableAnnotationComposer get templateId {
    final $$ServiceTemplatesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.templateId,
      referencedTable: $db.serviceTemplates,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ServiceTemplatesTableAnnotationComposer(
            $db: $db,
            $table: $db.serviceTemplates,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$InventoryPartsTableAnnotationComposer get inventoryPartId {
    final $$InventoryPartsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.inventoryPartId,
      referencedTable: $db.inventoryParts,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InventoryPartsTableAnnotationComposer(
            $db: $db,
            $table: $db.inventoryParts,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$ServiceTemplatePartsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ServiceTemplatePartsTable,
          ServiceTemplatePart,
          $$ServiceTemplatePartsTableFilterComposer,
          $$ServiceTemplatePartsTableOrderingComposer,
          $$ServiceTemplatePartsTableAnnotationComposer,
          $$ServiceTemplatePartsTableCreateCompanionBuilder,
          $$ServiceTemplatePartsTableUpdateCompanionBuilder,
          (ServiceTemplatePart, $$ServiceTemplatePartsTableReferences),
          ServiceTemplatePart,
          PrefetchHooks Function({bool templateId, bool inventoryPartId})
        > {
  $$ServiceTemplatePartsTableTableManager(
    _$AppDatabase db,
    $ServiceTemplatePartsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ServiceTemplatePartsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ServiceTemplatePartsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ServiceTemplatePartsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> templateId = const Value.absent(),
                Value<int> inventoryPartId = const Value.absent(),
                Value<double> quantity = const Value.absent(),
              }) => ServiceTemplatePartsCompanion(
                id: id,
                templateId: templateId,
                inventoryPartId: inventoryPartId,
                quantity: quantity,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int templateId,
                required int inventoryPartId,
                Value<double> quantity = const Value.absent(),
              }) => ServiceTemplatePartsCompanion.insert(
                id: id,
                templateId: templateId,
                inventoryPartId: inventoryPartId,
                quantity: quantity,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$ServiceTemplatePartsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({templateId = false, inventoryPartId = false}) {
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
                        if (templateId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.templateId,
                                    referencedTable:
                                        $$ServiceTemplatePartsTableReferences
                                            ._templateIdTable(db),
                                    referencedColumn:
                                        $$ServiceTemplatePartsTableReferences
                                            ._templateIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (inventoryPartId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.inventoryPartId,
                                    referencedTable:
                                        $$ServiceTemplatePartsTableReferences
                                            ._inventoryPartIdTable(db),
                                    referencedColumn:
                                        $$ServiceTemplatePartsTableReferences
                                            ._inventoryPartIdTable(db)
                                            .id,
                                  )
                                  as T;
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

typedef $$ServiceTemplatePartsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ServiceTemplatePartsTable,
      ServiceTemplatePart,
      $$ServiceTemplatePartsTableFilterComposer,
      $$ServiceTemplatePartsTableOrderingComposer,
      $$ServiceTemplatePartsTableAnnotationComposer,
      $$ServiceTemplatePartsTableCreateCompanionBuilder,
      $$ServiceTemplatePartsTableUpdateCompanionBuilder,
      (ServiceTemplatePart, $$ServiceTemplatePartsTableReferences),
      ServiceTemplatePart,
      PrefetchHooks Function({bool templateId, bool inventoryPartId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomersTableTableManager get customers =>
      $$CustomersTableTableManager(_db, _db.customers);
  $$VehiclesTableTableManager get vehicles =>
      $$VehiclesTableTableManager(_db, _db.vehicles);
  $$EstimatesTableTableManager get estimates =>
      $$EstimatesTableTableManager(_db, _db.estimates);
  $$VendorsTableTableManager get vendors =>
      $$VendorsTableTableManager(_db, _db.vendors);
  $$InventoryPartsTableTableManager get inventoryParts =>
      $$InventoryPartsTableTableManager(_db, _db.inventoryParts);
  $$EstimateLineItemsTableTableManager get estimateLineItems =>
      $$EstimateLineItemsTableTableManager(_db, _db.estimateLineItems);
  $$ShopSettingsTableTableManager get shopSettings =>
      $$ShopSettingsTableTableManager(_db, _db.shopSettings);
  $$TechniciansTableTableManager get technicians =>
      $$TechniciansTableTableManager(_db, _db.technicians);
  $$RepairOrdersTableTableManager get repairOrders =>
      $$RepairOrdersTableTableManager(_db, _db.repairOrders);
  $$MarkupRulesTableTableManager get markupRules =>
      $$MarkupRulesTableTableManager(_db, _db.markupRules);
  $$ServiceTemplatesTableTableManager get serviceTemplates =>
      $$ServiceTemplatesTableTableManager(_db, _db.serviceTemplates);
  $$ServiceTemplatePartsTableTableManager get serviceTemplateParts =>
      $$ServiceTemplatePartsTableTableManager(_db, _db.serviceTemplateParts);
}
