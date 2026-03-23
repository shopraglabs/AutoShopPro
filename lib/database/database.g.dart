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
  final DateTime createdAt;
  const Estimate({
    required this.id,
    required this.customerId,
    this.vehicleId,
    this.customerComplaint,
    this.note,
    required this.status,
    required this.taxRate,
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
  final Value<DateTime> createdAt;
  const EstimatesCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.customerComplaint = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.taxRate = const Value.absent(),
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
  late final GeneratedColumn<double> unitPrice = GeneratedColumn<double>(
    'unit_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostMeta = const VerificationMeta(
    'unitCost',
  );
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
    'unit_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
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
        DriftSqlType.double,
        data['${effectivePrefix}unit_price'],
      )!,
      unitCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
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
  final double unitPrice;
  final double? unitCost;
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
    map['unit_price'] = Variable<double>(unitPrice);
    if (!nullToAbsent || unitCost != null) {
      map['unit_cost'] = Variable<double>(unitCost);
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
      unitPrice: serializer.fromJson<double>(json['unitPrice']),
      unitCost: serializer.fromJson<double?>(json['unitCost']),
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
      'unitPrice': serializer.toJson<double>(unitPrice),
      'unitCost': serializer.toJson<double?>(unitCost),
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
    double? unitPrice,
    Value<double?> unitCost = const Value.absent(),
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
  final Value<double> unitPrice;
  final Value<double?> unitCost;
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
    required double unitPrice,
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
    Expression<double>? unitPrice,
    Expression<double>? unitCost,
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
    Value<double>? unitPrice,
    Value<double?>? unitCost,
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
      map['unit_price'] = Variable<double>(unitPrice.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
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
  late final GeneratedColumn<double> defaultLaborRate = GeneratedColumn<double>(
    'default_labor_rate',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(120.0),
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    shopName,
    defaultLaborRate,
    defaultPartsMarkup,
    defaultTaxRate,
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
        DriftSqlType.double,
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
  final double defaultLaborRate;
  final double defaultPartsMarkup;
  final double defaultTaxRate;
  const ShopSetting({
    required this.id,
    this.shopName,
    required this.defaultLaborRate,
    required this.defaultPartsMarkup,
    required this.defaultTaxRate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || shopName != null) {
      map['shop_name'] = Variable<String>(shopName);
    }
    map['default_labor_rate'] = Variable<double>(defaultLaborRate);
    map['default_parts_markup'] = Variable<double>(defaultPartsMarkup);
    map['default_tax_rate'] = Variable<double>(defaultTaxRate);
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
      defaultLaborRate: serializer.fromJson<double>(json['defaultLaborRate']),
      defaultPartsMarkup: serializer.fromJson<double>(
        json['defaultPartsMarkup'],
      ),
      defaultTaxRate: serializer.fromJson<double>(json['defaultTaxRate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'shopName': serializer.toJson<String?>(shopName),
      'defaultLaborRate': serializer.toJson<double>(defaultLaborRate),
      'defaultPartsMarkup': serializer.toJson<double>(defaultPartsMarkup),
      'defaultTaxRate': serializer.toJson<double>(defaultTaxRate),
    };
  }

  ShopSetting copyWith({
    int? id,
    Value<String?> shopName = const Value.absent(),
    double? defaultLaborRate,
    double? defaultPartsMarkup,
    double? defaultTaxRate,
  }) => ShopSetting(
    id: id ?? this.id,
    shopName: shopName.present ? shopName.value : this.shopName,
    defaultLaborRate: defaultLaborRate ?? this.defaultLaborRate,
    defaultPartsMarkup: defaultPartsMarkup ?? this.defaultPartsMarkup,
    defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
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
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShopSetting(')
          ..write('id: $id, ')
          ..write('shopName: $shopName, ')
          ..write('defaultLaborRate: $defaultLaborRate, ')
          ..write('defaultPartsMarkup: $defaultPartsMarkup, ')
          ..write('defaultTaxRate: $defaultTaxRate')
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
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShopSetting &&
          other.id == this.id &&
          other.shopName == this.shopName &&
          other.defaultLaborRate == this.defaultLaborRate &&
          other.defaultPartsMarkup == this.defaultPartsMarkup &&
          other.defaultTaxRate == this.defaultTaxRate);
}

class ShopSettingsCompanion extends UpdateCompanion<ShopSetting> {
  final Value<int> id;
  final Value<String?> shopName;
  final Value<double> defaultLaborRate;
  final Value<double> defaultPartsMarkup;
  final Value<double> defaultTaxRate;
  const ShopSettingsCompanion({
    this.id = const Value.absent(),
    this.shopName = const Value.absent(),
    this.defaultLaborRate = const Value.absent(),
    this.defaultPartsMarkup = const Value.absent(),
    this.defaultTaxRate = const Value.absent(),
  });
  ShopSettingsCompanion.insert({
    this.id = const Value.absent(),
    this.shopName = const Value.absent(),
    this.defaultLaborRate = const Value.absent(),
    this.defaultPartsMarkup = const Value.absent(),
    this.defaultTaxRate = const Value.absent(),
  });
  static Insertable<ShopSetting> custom({
    Expression<int>? id,
    Expression<String>? shopName,
    Expression<double>? defaultLaborRate,
    Expression<double>? defaultPartsMarkup,
    Expression<double>? defaultTaxRate,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (shopName != null) 'shop_name': shopName,
      if (defaultLaborRate != null) 'default_labor_rate': defaultLaborRate,
      if (defaultPartsMarkup != null)
        'default_parts_markup': defaultPartsMarkup,
      if (defaultTaxRate != null) 'default_tax_rate': defaultTaxRate,
    });
  }

  ShopSettingsCompanion copyWith({
    Value<int>? id,
    Value<String?>? shopName,
    Value<double>? defaultLaborRate,
    Value<double>? defaultPartsMarkup,
    Value<double>? defaultTaxRate,
  }) {
    return ShopSettingsCompanion(
      id: id ?? this.id,
      shopName: shopName ?? this.shopName,
      defaultLaborRate: defaultLaborRate ?? this.defaultLaborRate,
      defaultPartsMarkup: defaultPartsMarkup ?? this.defaultPartsMarkup,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
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
      map['default_labor_rate'] = Variable<double>(defaultLaborRate.value);
    }
    if (defaultPartsMarkup.present) {
      map['default_parts_markup'] = Variable<double>(defaultPartsMarkup.value);
    }
    if (defaultTaxRate.present) {
      map['default_tax_rate'] = Variable<double>(defaultTaxRate.value);
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
          ..write('defaultTaxRate: $defaultTaxRate')
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
  final DateTime createdAt;
  const Vendor({
    required this.id,
    required this.name,
    this.contactName,
    this.phone,
    this.accountNumber,
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Vendor copyWith({
    int? id,
    String? name,
    Value<String?> contactName = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    Value<String?> accountNumber = const Value.absent(),
    DateTime? createdAt,
  }) => Vendor(
    id: id ?? this.id,
    name: name ?? this.name,
    contactName: contactName.present ? contactName.value : this.contactName,
    phone: phone.present ? phone.value : this.phone,
    accountNumber: accountNumber.present
        ? accountNumber.value
        : this.accountNumber,
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, contactName, phone, accountNumber, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Vendor &&
          other.id == this.id &&
          other.name == this.name &&
          other.contactName == this.contactName &&
          other.phone == this.phone &&
          other.accountNumber == this.accountNumber &&
          other.createdAt == this.createdAt);
}

class VendorsCompanion extends UpdateCompanion<Vendor> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> contactName;
  final Value<String?> phone;
  final Value<String?> accountNumber;
  final Value<DateTime> createdAt;
  const VendorsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contactName = const Value.absent(),
    this.phone = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  VendorsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.contactName = const Value.absent(),
    this.phone = const Value.absent(),
    this.accountNumber = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Vendor> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? contactName,
    Expression<String>? phone,
    Expression<String>? accountNumber,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contactName != null) 'contact_name': contactName,
      if (phone != null) 'phone': phone,
      if (accountNumber != null) 'account_number': accountNumber,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  VendorsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? contactName,
    Value<String?>? phone,
    Value<String?>? accountNumber,
    Value<DateTime>? createdAt,
  }) {
    return VendorsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      accountNumber: accountNumber ?? this.accountNumber,
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
  final DateTime createdAt;
  const RepairOrder({
    required this.id,
    this.estimateId,
    required this.customerId,
    this.vehicleId,
    this.note,
    required this.status,
    this.technicianId,
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
    DateTime? createdAt,
  }) => RepairOrder(
    id: id ?? this.id,
    estimateId: estimateId.present ? estimateId.value : this.estimateId,
    customerId: customerId ?? this.customerId,
    vehicleId: vehicleId.present ? vehicleId.value : this.vehicleId,
    note: note.present ? note.value : this.note,
    status: status ?? this.status,
    technicianId: technicianId.present ? technicianId.value : this.technicianId,
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
  final Value<DateTime> createdAt;
  const RepairOrdersCompanion({
    this.id = const Value.absent(),
    this.estimateId = const Value.absent(),
    this.customerId = const Value.absent(),
    this.vehicleId = const Value.absent(),
    this.note = const Value.absent(),
    this.status = const Value.absent(),
    this.technicianId = const Value.absent(),
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
          ..write('createdAt: $createdAt')
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
  List<GeneratedColumn> get $columns => [id, name, specialty, phone, createdAt];
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
  final DateTime createdAt;
  const Technician({
    required this.id,
    required this.name,
    this.specialty,
    this.phone,
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
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Technician copyWith({
    int? id,
    String? name,
    Value<String?> specialty = const Value.absent(),
    Value<String?> phone = const Value.absent(),
    DateTime? createdAt,
  }) => Technician(
    id: id ?? this.id,
    name: name ?? this.name,
    specialty: specialty.present ? specialty.value : this.specialty,
    phone: phone.present ? phone.value : this.phone,
    createdAt: createdAt ?? this.createdAt,
  );
  Technician copyWithCompanion(TechniciansCompanion data) {
    return Technician(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      specialty: data.specialty.present ? data.specialty.value : this.specialty,
      phone: data.phone.present ? data.phone.value : this.phone,
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
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, specialty, phone, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Technician &&
          other.id == this.id &&
          other.name == this.name &&
          other.specialty == this.specialty &&
          other.phone == this.phone &&
          other.createdAt == this.createdAt);
}

class TechniciansCompanion extends UpdateCompanion<Technician> {
  final Value<int> id;
  final Value<String> name;
  final Value<String?> specialty;
  final Value<String?> phone;
  final Value<DateTime> createdAt;
  const TechniciansCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.specialty = const Value.absent(),
    this.phone = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  TechniciansCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.specialty = const Value.absent(),
    this.phone = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<Technician> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? specialty,
    Expression<String>? phone,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (specialty != null) 'specialty': specialty,
      if (phone != null) 'phone': phone,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  TechniciansCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String?>? specialty,
    Value<String?>? phone,
    Value<DateTime>? createdAt,
  }) {
    return TechniciansCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      phone: phone ?? this.phone,
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
  late final GeneratedColumn<double> cost = GeneratedColumn<double>(
    'cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _sellPriceMeta = const VerificationMeta(
    'sellPrice',
  );
  @override
  late final GeneratedColumn<double> sellPrice = GeneratedColumn<double>(
    'sell_price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
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
        DriftSqlType.double,
        data['${effectivePrefix}cost'],
      )!,
      sellPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
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
  final double cost;
  final double sellPrice;
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
    map['cost'] = Variable<double>(cost);
    map['sell_price'] = Variable<double>(sellPrice);
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
      cost: serializer.fromJson<double>(json['cost']),
      sellPrice: serializer.fromJson<double>(json['sellPrice']),
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
      'cost': serializer.toJson<double>(cost),
      'sellPrice': serializer.toJson<double>(sellPrice),
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
    double? cost,
    double? sellPrice,
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
  final Value<double> cost;
  final Value<double> sellPrice;
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
    Expression<double>? cost,
    Expression<double>? sellPrice,
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
    Value<double>? cost,
    Value<double>? sellPrice,
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
      map['cost'] = Variable<double>(cost.value);
    }
    if (sellPrice.present) {
      map['sell_price'] = Variable<double>(sellPrice.value);
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
  late final GeneratedColumn<double> minCost = GeneratedColumn<double>(
    'min_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _maxCostMeta = const VerificationMeta(
    'maxCost',
  );
  @override
  late final GeneratedColumn<double> maxCost = GeneratedColumn<double>(
    'max_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
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
        DriftSqlType.double,
        data['${effectivePrefix}min_cost'],
      )!,
      maxCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
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
  final double minCost;
  final double? maxCost;
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
    map['min_cost'] = Variable<double>(minCost);
    if (!nullToAbsent || maxCost != null) {
      map['max_cost'] = Variable<double>(maxCost);
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
      minCost: serializer.fromJson<double>(json['minCost']),
      maxCost: serializer.fromJson<double?>(json['maxCost']),
      markupPercent: serializer.fromJson<double>(json['markupPercent']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'minCost': serializer.toJson<double>(minCost),
      'maxCost': serializer.toJson<double?>(maxCost),
      'markupPercent': serializer.toJson<double>(markupPercent),
    };
  }

  MarkupRule copyWith({
    int? id,
    double? minCost,
    Value<double?> maxCost = const Value.absent(),
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
  final Value<double> minCost;
  final Value<double?> maxCost;
  final Value<double> markupPercent;
  const MarkupRulesCompanion({
    this.id = const Value.absent(),
    this.minCost = const Value.absent(),
    this.maxCost = const Value.absent(),
    this.markupPercent = const Value.absent(),
  });
  MarkupRulesCompanion.insert({
    this.id = const Value.absent(),
    required double minCost,
    this.maxCost = const Value.absent(),
    required double markupPercent,
  }) : minCost = Value(minCost),
       markupPercent = Value(markupPercent);
  static Insertable<MarkupRule> custom({
    Expression<int>? id,
    Expression<double>? minCost,
    Expression<double>? maxCost,
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
    Value<double>? minCost,
    Value<double?>? maxCost,
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
      map['min_cost'] = Variable<double>(minCost.value);
    }
    if (maxCost.present) {
      map['max_cost'] = Variable<double>(maxCost.value);
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
  late final GeneratedColumn<double> defaultRate = GeneratedColumn<double>(
    'default_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
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
        DriftSqlType.double,
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
  final double? defaultRate;
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
      map['default_rate'] = Variable<double>(defaultRate);
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
      defaultRate: serializer.fromJson<double?>(json['defaultRate']),
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
      'defaultRate': serializer.toJson<double?>(defaultRate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ServiceTemplate copyWith({
    int? id,
    String? name,
    String? laborDescription,
    double? defaultHours,
    Value<double?> defaultRate = const Value.absent(),
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
  final Value<double?> defaultRate;
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
    Expression<double>? defaultRate,
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
    Value<double?>? defaultRate,
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
      map['default_rate'] = Variable<double>(defaultRate.value);
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
  late final $EstimateLineItemsTable estimateLineItems =
      $EstimateLineItemsTable(this);
  late final $ShopSettingsTable shopSettings = $ShopSettingsTable(this);
  late final $VendorsTable vendors = $VendorsTable(this);
  late final $RepairOrdersTable repairOrders = $RepairOrdersTable(this);
  late final $TechniciansTable technicians = $TechniciansTable(this);
  late final $InventoryPartsTable inventoryParts = $InventoryPartsTable(this);
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
    estimateLineItems,
    shopSettings,
    vendors,
    repairOrders,
    technicians,
    inventoryParts,
    markupRules,
    serviceTemplates,
    serviceTemplateParts,
  ];
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
          (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
          Customer,
          PrefetchHooks Function()
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (Customer, BaseReferences<_$AppDatabase, $CustomersTable, Customer>),
      Customer,
      PrefetchHooks Function()
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

  ColumnFilters<int> get customerId => $composableBuilder(
    column: $table.customerId,
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

  ColumnOrderings<int> get customerId => $composableBuilder(
    column: $table.customerId,
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

  GeneratedColumn<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

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
          (Vehicle, BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle>),
          Vehicle,
          PrefetchHooks Function()
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (Vehicle, BaseReferences<_$AppDatabase, $VehiclesTable, Vehicle>),
      Vehicle,
      PrefetchHooks Function()
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
      Value<DateTime> createdAt,
    });

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

  ColumnFilters<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
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

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
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
          (Estimate, BaseReferences<_$AppDatabase, $EstimatesTable, Estimate>),
          Estimate,
          PrefetchHooks Function()
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
                Value<DateTime> createdAt = const Value.absent(),
              }) => EstimatesCompanion(
                id: id,
                customerId: customerId,
                vehicleId: vehicleId,
                customerComplaint: customerComplaint,
                note: note,
                status: status,
                taxRate: taxRate,
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
                Value<DateTime> createdAt = const Value.absent(),
              }) => EstimatesCompanion.insert(
                id: id,
                customerId: customerId,
                vehicleId: vehicleId,
                customerComplaint: customerComplaint,
                note: note,
                status: status,
                taxRate: taxRate,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (Estimate, BaseReferences<_$AppDatabase, $EstimatesTable, Estimate>),
      Estimate,
      PrefetchHooks Function()
    >;
typedef $$EstimateLineItemsTableCreateCompanionBuilder =
    EstimateLineItemsCompanion Function({
      Value<int> id,
      required int estimateId,
      required String type,
      required String description,
      Value<double> quantity,
      required double unitPrice,
      Value<double?> unitCost,
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
      Value<double> unitPrice,
      Value<double?> unitCost,
      Value<int?> vendorId,
      Value<int?> parentLaborId,
      Value<bool?> isDone,
      Value<String?> approvalStatus,
      Value<int?> inventoryPartId,
      Value<String?> laborName,
      Value<String?> partNumber,
    });

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

  ColumnFilters<int> get estimateId => $composableBuilder(
    column: $table.estimateId,
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

  ColumnFilters<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vendorId => $composableBuilder(
    column: $table.vendorId,
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

  ColumnFilters<int> get inventoryPartId => $composableBuilder(
    column: $table.inventoryPartId,
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

  ColumnOrderings<int> get estimateId => $composableBuilder(
    column: $table.estimateId,
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

  ColumnOrderings<double> get unitPrice => $composableBuilder(
    column: $table.unitPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vendorId => $composableBuilder(
    column: $table.vendorId,
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

  ColumnOrderings<int> get inventoryPartId => $composableBuilder(
    column: $table.inventoryPartId,
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

  GeneratedColumn<int> get estimateId => $composableBuilder(
    column: $table.estimateId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitPrice =>
      $composableBuilder(column: $table.unitPrice, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<int> get vendorId =>
      $composableBuilder(column: $table.vendorId, builder: (column) => column);

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

  GeneratedColumn<int> get inventoryPartId => $composableBuilder(
    column: $table.inventoryPartId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get laborName =>
      $composableBuilder(column: $table.laborName, builder: (column) => column);

  GeneratedColumn<String> get partNumber => $composableBuilder(
    column: $table.partNumber,
    builder: (column) => column,
  );
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
          (
            EstimateLineItem,
            BaseReferences<
              _$AppDatabase,
              $EstimateLineItemsTable,
              EstimateLineItem
            >,
          ),
          EstimateLineItem,
          PrefetchHooks Function()
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
                Value<double> unitPrice = const Value.absent(),
                Value<double?> unitCost = const Value.absent(),
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
                required double unitPrice,
                Value<double?> unitCost = const Value.absent(),
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        EstimateLineItem,
        BaseReferences<
          _$AppDatabase,
          $EstimateLineItemsTable,
          EstimateLineItem
        >,
      ),
      EstimateLineItem,
      PrefetchHooks Function()
    >;
typedef $$ShopSettingsTableCreateCompanionBuilder =
    ShopSettingsCompanion Function({
      Value<int> id,
      Value<String?> shopName,
      Value<double> defaultLaborRate,
      Value<double> defaultPartsMarkup,
      Value<double> defaultTaxRate,
    });
typedef $$ShopSettingsTableUpdateCompanionBuilder =
    ShopSettingsCompanion Function({
      Value<int> id,
      Value<String?> shopName,
      Value<double> defaultLaborRate,
      Value<double> defaultPartsMarkup,
      Value<double> defaultTaxRate,
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

  ColumnFilters<double> get defaultLaborRate => $composableBuilder(
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

  ColumnOrderings<double> get defaultLaborRate => $composableBuilder(
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

  GeneratedColumn<double> get defaultLaborRate => $composableBuilder(
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
                Value<double> defaultLaborRate = const Value.absent(),
                Value<double> defaultPartsMarkup = const Value.absent(),
                Value<double> defaultTaxRate = const Value.absent(),
              }) => ShopSettingsCompanion(
                id: id,
                shopName: shopName,
                defaultLaborRate: defaultLaborRate,
                defaultPartsMarkup: defaultPartsMarkup,
                defaultTaxRate: defaultTaxRate,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> shopName = const Value.absent(),
                Value<double> defaultLaborRate = const Value.absent(),
                Value<double> defaultPartsMarkup = const Value.absent(),
                Value<double> defaultTaxRate = const Value.absent(),
              }) => ShopSettingsCompanion.insert(
                id: id,
                shopName: shopName,
                defaultLaborRate: defaultLaborRate,
                defaultPartsMarkup: defaultPartsMarkup,
                defaultTaxRate: defaultTaxRate,
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
typedef $$VendorsTableCreateCompanionBuilder =
    VendorsCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> contactName,
      Value<String?> phone,
      Value<String?> accountNumber,
      Value<DateTime> createdAt,
    });
typedef $$VendorsTableUpdateCompanionBuilder =
    VendorsCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> contactName,
      Value<String?> phone,
      Value<String?> accountNumber,
      Value<DateTime> createdAt,
    });

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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
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
          (Vendor, BaseReferences<_$AppDatabase, $VendorsTable, Vendor>),
          Vendor,
          PrefetchHooks Function()
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
                Value<DateTime> createdAt = const Value.absent(),
              }) => VendorsCompanion(
                id: id,
                name: name,
                contactName: contactName,
                phone: phone,
                accountNumber: accountNumber,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> contactName = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> accountNumber = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => VendorsCompanion.insert(
                id: id,
                name: name,
                contactName: contactName,
                phone: phone,
                accountNumber: accountNumber,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (Vendor, BaseReferences<_$AppDatabase, $VendorsTable, Vendor>),
      Vendor,
      PrefetchHooks Function()
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
      Value<DateTime> createdAt,
    });

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

  ColumnFilters<int> get estimateId => $composableBuilder(
    column: $table.estimateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
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

  ColumnFilters<int> get technicianId => $composableBuilder(
    column: $table.technicianId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<int> get estimateId => $composableBuilder(
    column: $table.estimateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get vehicleId => $composableBuilder(
    column: $table.vehicleId,
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

  ColumnOrderings<int> get technicianId => $composableBuilder(
    column: $table.technicianId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<int> get estimateId => $composableBuilder(
    column: $table.estimateId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get vehicleId =>
      $composableBuilder(column: $table.vehicleId, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get technicianId => $composableBuilder(
    column: $table.technicianId,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
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
          (
            RepairOrder,
            BaseReferences<_$AppDatabase, $RepairOrdersTable, RepairOrder>,
          ),
          RepairOrder,
          PrefetchHooks Function()
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
                Value<DateTime> createdAt = const Value.absent(),
              }) => RepairOrdersCompanion(
                id: id,
                estimateId: estimateId,
                customerId: customerId,
                vehicleId: vehicleId,
                note: note,
                status: status,
                technicianId: technicianId,
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
                Value<DateTime> createdAt = const Value.absent(),
              }) => RepairOrdersCompanion.insert(
                id: id,
                estimateId: estimateId,
                customerId: customerId,
                vehicleId: vehicleId,
                note: note,
                status: status,
                technicianId: technicianId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        RepairOrder,
        BaseReferences<_$AppDatabase, $RepairOrdersTable, RepairOrder>,
      ),
      RepairOrder,
      PrefetchHooks Function()
    >;
typedef $$TechniciansTableCreateCompanionBuilder =
    TechniciansCompanion Function({
      Value<int> id,
      required String name,
      Value<String?> specialty,
      Value<String?> phone,
      Value<DateTime> createdAt,
    });
typedef $$TechniciansTableUpdateCompanionBuilder =
    TechniciansCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String?> specialty,
      Value<String?> phone,
      Value<DateTime> createdAt,
    });

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

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
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

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
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
          (
            Technician,
            BaseReferences<_$AppDatabase, $TechniciansTable, Technician>,
          ),
          Technician,
          PrefetchHooks Function()
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
                Value<DateTime> createdAt = const Value.absent(),
              }) => TechniciansCompanion(
                id: id,
                name: name,
                specialty: specialty,
                phone: phone,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<String?> specialty = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => TechniciansCompanion.insert(
                id: id,
                name: name,
                specialty: specialty,
                phone: phone,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        Technician,
        BaseReferences<_$AppDatabase, $TechniciansTable, Technician>,
      ),
      Technician,
      PrefetchHooks Function()
    >;
typedef $$InventoryPartsTableCreateCompanionBuilder =
    InventoryPartsCompanion Function({
      Value<int> id,
      Value<String?> partNumber,
      required String description,
      Value<String?> category,
      Value<double> cost,
      Value<double> sellPrice,
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
      Value<double> cost,
      Value<double> sellPrice,
      Value<int> stockQty,
      Value<int> lowStockThreshold,
      Value<DateTime> createdAt,
    });

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

  ColumnFilters<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get sellPrice => $composableBuilder(
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

  ColumnOrderings<double> get cost => $composableBuilder(
    column: $table.cost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get sellPrice => $composableBuilder(
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

  GeneratedColumn<double> get cost =>
      $composableBuilder(column: $table.cost, builder: (column) => column);

  GeneratedColumn<double> get sellPrice =>
      $composableBuilder(column: $table.sellPrice, builder: (column) => column);

  GeneratedColumn<int> get stockQty =>
      $composableBuilder(column: $table.stockQty, builder: (column) => column);

  GeneratedColumn<int> get lowStockThreshold => $composableBuilder(
    column: $table.lowStockThreshold,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
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
          (
            InventoryPart,
            BaseReferences<_$AppDatabase, $InventoryPartsTable, InventoryPart>,
          ),
          InventoryPart,
          PrefetchHooks Function()
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
                Value<double> cost = const Value.absent(),
                Value<double> sellPrice = const Value.absent(),
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
                Value<double> cost = const Value.absent(),
                Value<double> sellPrice = const Value.absent(),
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        InventoryPart,
        BaseReferences<_$AppDatabase, $InventoryPartsTable, InventoryPart>,
      ),
      InventoryPart,
      PrefetchHooks Function()
    >;
typedef $$MarkupRulesTableCreateCompanionBuilder =
    MarkupRulesCompanion Function({
      Value<int> id,
      required double minCost,
      Value<double?> maxCost,
      required double markupPercent,
    });
typedef $$MarkupRulesTableUpdateCompanionBuilder =
    MarkupRulesCompanion Function({
      Value<int> id,
      Value<double> minCost,
      Value<double?> maxCost,
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

  ColumnFilters<double> get minCost => $composableBuilder(
    column: $table.minCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get maxCost => $composableBuilder(
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

  ColumnOrderings<double> get minCost => $composableBuilder(
    column: $table.minCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get maxCost => $composableBuilder(
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

  GeneratedColumn<double> get minCost =>
      $composableBuilder(column: $table.minCost, builder: (column) => column);

  GeneratedColumn<double> get maxCost =>
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
                Value<double> minCost = const Value.absent(),
                Value<double?> maxCost = const Value.absent(),
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
                required double minCost,
                Value<double?> maxCost = const Value.absent(),
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
      Value<double?> defaultRate,
      Value<DateTime> createdAt,
    });
typedef $$ServiceTemplatesTableUpdateCompanionBuilder =
    ServiceTemplatesCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<String> laborDescription,
      Value<double> defaultHours,
      Value<double?> defaultRate,
      Value<DateTime> createdAt,
    });

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

  ColumnFilters<double> get defaultRate => $composableBuilder(
    column: $table.defaultRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<double> get defaultRate => $composableBuilder(
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

  GeneratedColumn<double> get defaultRate => $composableBuilder(
    column: $table.defaultRate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
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
          (
            ServiceTemplate,
            BaseReferences<
              _$AppDatabase,
              $ServiceTemplatesTable,
              ServiceTemplate
            >,
          ),
          ServiceTemplate,
          PrefetchHooks Function()
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
                Value<double?> defaultRate = const Value.absent(),
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
                Value<double?> defaultRate = const Value.absent(),
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        ServiceTemplate,
        BaseReferences<_$AppDatabase, $ServiceTemplatesTable, ServiceTemplate>,
      ),
      ServiceTemplate,
      PrefetchHooks Function()
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

  ColumnFilters<int> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get inventoryPartId => $composableBuilder(
    column: $table.inventoryPartId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );
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

  ColumnOrderings<int> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get inventoryPartId => $composableBuilder(
    column: $table.inventoryPartId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );
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

  GeneratedColumn<int> get templateId => $composableBuilder(
    column: $table.templateId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get inventoryPartId => $composableBuilder(
    column: $table.inventoryPartId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
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
          (
            ServiceTemplatePart,
            BaseReferences<
              _$AppDatabase,
              $ServiceTemplatePartsTable,
              ServiceTemplatePart
            >,
          ),
          ServiceTemplatePart,
          PrefetchHooks Function()
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
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
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
      (
        ServiceTemplatePart,
        BaseReferences<
          _$AppDatabase,
          $ServiceTemplatePartsTable,
          ServiceTemplatePart
        >,
      ),
      ServiceTemplatePart,
      PrefetchHooks Function()
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
  $$EstimateLineItemsTableTableManager get estimateLineItems =>
      $$EstimateLineItemsTableTableManager(_db, _db.estimateLineItems);
  $$ShopSettingsTableTableManager get shopSettings =>
      $$ShopSettingsTableTableManager(_db, _db.shopSettings);
  $$VendorsTableTableManager get vendors =>
      $$VendorsTableTableManager(_db, _db.vendors);
  $$RepairOrdersTableTableManager get repairOrders =>
      $$RepairOrdersTableTableManager(_db, _db.repairOrders);
  $$TechniciansTableTableManager get technicians =>
      $$TechniciansTableTableManager(_db, _db.technicians);
  $$InventoryPartsTableTableManager get inventoryParts =>
      $$InventoryPartsTableTableManager(_db, _db.inventoryParts);
  $$MarkupRulesTableTableManager get markupRules =>
      $$MarkupRulesTableTableManager(_db, _db.markupRules);
  $$ServiceTemplatesTableTableManager get serviceTemplates =>
      $$ServiceTemplatesTableTableManager(_db, _db.serviceTemplates);
  $$ServiceTemplatePartsTableTableManager get serviceTemplateParts =>
      $$ServiceTemplatePartsTableTableManager(_db, _db.serviceTemplateParts);
}
