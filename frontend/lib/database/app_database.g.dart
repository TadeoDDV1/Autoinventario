// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProductosTable extends Productos
    with TableInfo<$ProductosTable, Producto> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _codigoBarrasMeta = const VerificationMeta(
    'codigoBarras',
  );
  @override
  late final GeneratedColumn<String> codigoBarras = GeneratedColumn<String>(
    'codigo_barras',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _marcaMeta = const VerificationMeta('marca');
  @override
  late final GeneratedColumn<String> marca = GeneratedColumn<String>(
    'marca',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usoMeta = const VerificationMeta('uso');
  @override
  late final GeneratedColumn<String> uso = GeneratedColumn<String>(
    'uso',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _precioCompraMeta = const VerificationMeta(
    'precioCompra',
  );
  @override
  late final GeneratedColumn<double> precioCompra = GeneratedColumn<double>(
    'precio_compra',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioVentaMeta = const VerificationMeta(
    'precioVenta',
  );
  @override
  late final GeneratedColumn<double> precioVenta = GeneratedColumn<double>(
    'precio_venta',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioMayoreoMeta = const VerificationMeta(
    'precioMayoreo',
  );
  @override
  late final GeneratedColumn<double> precioMayoreo = GeneratedColumn<double>(
    'precio_mayoreo',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unidadMedidaMeta = const VerificationMeta(
    'unidadMedida',
  );
  @override
  late final GeneratedColumn<String> unidadMedida = GeneratedColumn<String>(
    'unidad_medida',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockActualMeta = const VerificationMeta(
    'stockActual',
  );
  @override
  late final GeneratedColumn<int> stockActual = GeneratedColumn<int>(
    'stock_actual',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stockMinimoMeta = const VerificationMeta(
    'stockMinimo',
  );
  @override
  late final GeneratedColumn<int> stockMinimo = GeneratedColumn<int>(
    'stock_minimo',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoriaIdMeta = const VerificationMeta(
    'categoriaId',
  );
  @override
  late final GeneratedColumn<int> categoriaId = GeneratedColumn<int>(
    'categoria_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ubicacionMeta = const VerificationMeta(
    'ubicacion',
  );
  @override
  late final GeneratedColumn<String> ubicacion = GeneratedColumn<String>(
    'ubicacion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codigoBarras,
    nombre,
    marca,
    descripcion,
    uso,
    precioCompra,
    precioVenta,
    precioMayoreo,
    unidadMedida,
    stockActual,
    stockMinimo,
    categoriaId,
    ubicacion,
    activo,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos';
  @override
  VerificationContext validateIntegrity(
    Insertable<Producto> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('codigo_barras')) {
      context.handle(
        _codigoBarrasMeta,
        codigoBarras.isAcceptableOrUnknown(
          data['codigo_barras']!,
          _codigoBarrasMeta,
        ),
      );
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('marca')) {
      context.handle(
        _marcaMeta,
        marca.isAcceptableOrUnknown(data['marca']!, _marcaMeta),
      );
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('uso')) {
      context.handle(
        _usoMeta,
        uso.isAcceptableOrUnknown(data['uso']!, _usoMeta),
      );
    }
    if (data.containsKey('precio_compra')) {
      context.handle(
        _precioCompraMeta,
        precioCompra.isAcceptableOrUnknown(
          data['precio_compra']!,
          _precioCompraMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioCompraMeta);
    }
    if (data.containsKey('precio_venta')) {
      context.handle(
        _precioVentaMeta,
        precioVenta.isAcceptableOrUnknown(
          data['precio_venta']!,
          _precioVentaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioVentaMeta);
    }
    if (data.containsKey('precio_mayoreo')) {
      context.handle(
        _precioMayoreoMeta,
        precioMayoreo.isAcceptableOrUnknown(
          data['precio_mayoreo']!,
          _precioMayoreoMeta,
        ),
      );
    }
    if (data.containsKey('unidad_medida')) {
      context.handle(
        _unidadMedidaMeta,
        unidadMedida.isAcceptableOrUnknown(
          data['unidad_medida']!,
          _unidadMedidaMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_unidadMedidaMeta);
    }
    if (data.containsKey('stock_actual')) {
      context.handle(
        _stockActualMeta,
        stockActual.isAcceptableOrUnknown(
          data['stock_actual']!,
          _stockActualMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stockActualMeta);
    }
    if (data.containsKey('stock_minimo')) {
      context.handle(
        _stockMinimoMeta,
        stockMinimo.isAcceptableOrUnknown(
          data['stock_minimo']!,
          _stockMinimoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_stockMinimoMeta);
    }
    if (data.containsKey('categoria_id')) {
      context.handle(
        _categoriaIdMeta,
        categoriaId.isAcceptableOrUnknown(
          data['categoria_id']!,
          _categoriaIdMeta,
        ),
      );
    }
    if (data.containsKey('ubicacion')) {
      context.handle(
        _ubicacionMeta,
        ubicacion.isAcceptableOrUnknown(data['ubicacion']!, _ubicacionMeta),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    } else if (isInserting) {
      context.missing(_activoMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Producto map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Producto(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      codigoBarras: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}codigo_barras'],
      ),
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      marca: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}marca'],
      ),
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      ),
      uso: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uso'],
      ),
      precioCompra: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_compra'],
      )!,
      precioVenta: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_venta'],
      )!,
      precioMayoreo: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_mayoreo'],
      ),
      unidadMedida: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}unidad_medida'],
      )!,
      stockActual: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_actual'],
      )!,
      stockMinimo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}stock_minimo'],
      )!,
      categoriaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}categoria_id'],
      ),
      ubicacion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ubicacion'],
      ),
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $ProductosTable createAlias(String alias) {
    return $ProductosTable(attachedDatabase, alias);
  }
}

class Producto extends DataClass implements Insertable<Producto> {
  final int id;
  final String? codigoBarras;
  final String nombre;
  final String? marca;
  final String? descripcion;
  final String? uso;
  final double precioCompra;
  final double precioVenta;
  final double? precioMayoreo;
  final String unidadMedida;
  final int stockActual;
  final int stockMinimo;
  final int? categoriaId;
  final String? ubicacion;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Producto({
    required this.id,
    this.codigoBarras,
    required this.nombre,
    this.marca,
    this.descripcion,
    this.uso,
    required this.precioCompra,
    required this.precioVenta,
    this.precioMayoreo,
    required this.unidadMedida,
    required this.stockActual,
    required this.stockMinimo,
    this.categoriaId,
    this.ubicacion,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || codigoBarras != null) {
      map['codigo_barras'] = Variable<String>(codigoBarras);
    }
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || marca != null) {
      map['marca'] = Variable<String>(marca);
    }
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    if (!nullToAbsent || uso != null) {
      map['uso'] = Variable<String>(uso);
    }
    map['precio_compra'] = Variable<double>(precioCompra);
    map['precio_venta'] = Variable<double>(precioVenta);
    if (!nullToAbsent || precioMayoreo != null) {
      map['precio_mayoreo'] = Variable<double>(precioMayoreo);
    }
    map['unidad_medida'] = Variable<String>(unidadMedida);
    map['stock_actual'] = Variable<int>(stockActual);
    map['stock_minimo'] = Variable<int>(stockMinimo);
    if (!nullToAbsent || categoriaId != null) {
      map['categoria_id'] = Variable<int>(categoriaId);
    }
    if (!nullToAbsent || ubicacion != null) {
      map['ubicacion'] = Variable<String>(ubicacion);
    }
    map['activo'] = Variable<bool>(activo);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  ProductosCompanion toCompanion(bool nullToAbsent) {
    return ProductosCompanion(
      id: Value(id),
      codigoBarras: codigoBarras == null && nullToAbsent
          ? const Value.absent()
          : Value(codigoBarras),
      nombre: Value(nombre),
      marca: marca == null && nullToAbsent
          ? const Value.absent()
          : Value(marca),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      uso: uso == null && nullToAbsent ? const Value.absent() : Value(uso),
      precioCompra: Value(precioCompra),
      precioVenta: Value(precioVenta),
      precioMayoreo: precioMayoreo == null && nullToAbsent
          ? const Value.absent()
          : Value(precioMayoreo),
      unidadMedida: Value(unidadMedida),
      stockActual: Value(stockActual),
      stockMinimo: Value(stockMinimo),
      categoriaId: categoriaId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaId),
      ubicacion: ubicacion == null && nullToAbsent
          ? const Value.absent()
          : Value(ubicacion),
      activo: Value(activo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Producto.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Producto(
      id: serializer.fromJson<int>(json['id']),
      codigoBarras: serializer.fromJson<String?>(json['codigoBarras']),
      nombre: serializer.fromJson<String>(json['nombre']),
      marca: serializer.fromJson<String?>(json['marca']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      uso: serializer.fromJson<String?>(json['uso']),
      precioCompra: serializer.fromJson<double>(json['precioCompra']),
      precioVenta: serializer.fromJson<double>(json['precioVenta']),
      precioMayoreo: serializer.fromJson<double?>(json['precioMayoreo']),
      unidadMedida: serializer.fromJson<String>(json['unidadMedida']),
      stockActual: serializer.fromJson<int>(json['stockActual']),
      stockMinimo: serializer.fromJson<int>(json['stockMinimo']),
      categoriaId: serializer.fromJson<int?>(json['categoriaId']),
      ubicacion: serializer.fromJson<String?>(json['ubicacion']),
      activo: serializer.fromJson<bool>(json['activo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigoBarras': serializer.toJson<String?>(codigoBarras),
      'nombre': serializer.toJson<String>(nombre),
      'marca': serializer.toJson<String?>(marca),
      'descripcion': serializer.toJson<String?>(descripcion),
      'uso': serializer.toJson<String?>(uso),
      'precioCompra': serializer.toJson<double>(precioCompra),
      'precioVenta': serializer.toJson<double>(precioVenta),
      'precioMayoreo': serializer.toJson<double?>(precioMayoreo),
      'unidadMedida': serializer.toJson<String>(unidadMedida),
      'stockActual': serializer.toJson<int>(stockActual),
      'stockMinimo': serializer.toJson<int>(stockMinimo),
      'categoriaId': serializer.toJson<int?>(categoriaId),
      'ubicacion': serializer.toJson<String?>(ubicacion),
      'activo': serializer.toJson<bool>(activo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Producto copyWith({
    int? id,
    Value<String?> codigoBarras = const Value.absent(),
    String? nombre,
    Value<String?> marca = const Value.absent(),
    Value<String?> descripcion = const Value.absent(),
    Value<String?> uso = const Value.absent(),
    double? precioCompra,
    double? precioVenta,
    Value<double?> precioMayoreo = const Value.absent(),
    String? unidadMedida,
    int? stockActual,
    int? stockMinimo,
    Value<int?> categoriaId = const Value.absent(),
    Value<String?> ubicacion = const Value.absent(),
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Producto(
    id: id ?? this.id,
    codigoBarras: codigoBarras.present ? codigoBarras.value : this.codigoBarras,
    nombre: nombre ?? this.nombre,
    marca: marca.present ? marca.value : this.marca,
    descripcion: descripcion.present ? descripcion.value : this.descripcion,
    uso: uso.present ? uso.value : this.uso,
    precioCompra: precioCompra ?? this.precioCompra,
    precioVenta: precioVenta ?? this.precioVenta,
    precioMayoreo: precioMayoreo.present
        ? precioMayoreo.value
        : this.precioMayoreo,
    unidadMedida: unidadMedida ?? this.unidadMedida,
    stockActual: stockActual ?? this.stockActual,
    stockMinimo: stockMinimo ?? this.stockMinimo,
    categoriaId: categoriaId.present ? categoriaId.value : this.categoriaId,
    ubicacion: ubicacion.present ? ubicacion.value : this.ubicacion,
    activo: activo ?? this.activo,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Producto copyWithCompanion(ProductosCompanion data) {
    return Producto(
      id: data.id.present ? data.id.value : this.id,
      codigoBarras: data.codigoBarras.present
          ? data.codigoBarras.value
          : this.codigoBarras,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      marca: data.marca.present ? data.marca.value : this.marca,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      uso: data.uso.present ? data.uso.value : this.uso,
      precioCompra: data.precioCompra.present
          ? data.precioCompra.value
          : this.precioCompra,
      precioVenta: data.precioVenta.present
          ? data.precioVenta.value
          : this.precioVenta,
      precioMayoreo: data.precioMayoreo.present
          ? data.precioMayoreo.value
          : this.precioMayoreo,
      unidadMedida: data.unidadMedida.present
          ? data.unidadMedida.value
          : this.unidadMedida,
      stockActual: data.stockActual.present
          ? data.stockActual.value
          : this.stockActual,
      stockMinimo: data.stockMinimo.present
          ? data.stockMinimo.value
          : this.stockMinimo,
      categoriaId: data.categoriaId.present
          ? data.categoriaId.value
          : this.categoriaId,
      ubicacion: data.ubicacion.present ? data.ubicacion.value : this.ubicacion,
      activo: data.activo.present ? data.activo.value : this.activo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Producto(')
          ..write('id: $id, ')
          ..write('codigoBarras: $codigoBarras, ')
          ..write('nombre: $nombre, ')
          ..write('marca: $marca, ')
          ..write('descripcion: $descripcion, ')
          ..write('uso: $uso, ')
          ..write('precioCompra: $precioCompra, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('precioMayoreo: $precioMayoreo, ')
          ..write('unidadMedida: $unidadMedida, ')
          ..write('stockActual: $stockActual, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('ubicacion: $ubicacion, ')
          ..write('activo: $activo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    codigoBarras,
    nombre,
    marca,
    descripcion,
    uso,
    precioCompra,
    precioVenta,
    precioMayoreo,
    unidadMedida,
    stockActual,
    stockMinimo,
    categoriaId,
    ubicacion,
    activo,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Producto &&
          other.id == this.id &&
          other.codigoBarras == this.codigoBarras &&
          other.nombre == this.nombre &&
          other.marca == this.marca &&
          other.descripcion == this.descripcion &&
          other.uso == this.uso &&
          other.precioCompra == this.precioCompra &&
          other.precioVenta == this.precioVenta &&
          other.precioMayoreo == this.precioMayoreo &&
          other.unidadMedida == this.unidadMedida &&
          other.stockActual == this.stockActual &&
          other.stockMinimo == this.stockMinimo &&
          other.categoriaId == this.categoriaId &&
          other.ubicacion == this.ubicacion &&
          other.activo == this.activo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ProductosCompanion extends UpdateCompanion<Producto> {
  final Value<int> id;
  final Value<String?> codigoBarras;
  final Value<String> nombre;
  final Value<String?> marca;
  final Value<String?> descripcion;
  final Value<String?> uso;
  final Value<double> precioCompra;
  final Value<double> precioVenta;
  final Value<double?> precioMayoreo;
  final Value<String> unidadMedida;
  final Value<int> stockActual;
  final Value<int> stockMinimo;
  final Value<int?> categoriaId;
  final Value<String?> ubicacion;
  final Value<bool> activo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const ProductosCompanion({
    this.id = const Value.absent(),
    this.codigoBarras = const Value.absent(),
    this.nombre = const Value.absent(),
    this.marca = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.uso = const Value.absent(),
    this.precioCompra = const Value.absent(),
    this.precioVenta = const Value.absent(),
    this.precioMayoreo = const Value.absent(),
    this.unidadMedida = const Value.absent(),
    this.stockActual = const Value.absent(),
    this.stockMinimo = const Value.absent(),
    this.categoriaId = const Value.absent(),
    this.ubicacion = const Value.absent(),
    this.activo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ProductosCompanion.insert({
    this.id = const Value.absent(),
    this.codigoBarras = const Value.absent(),
    required String nombre,
    this.marca = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.uso = const Value.absent(),
    required double precioCompra,
    required double precioVenta,
    this.precioMayoreo = const Value.absent(),
    required String unidadMedida,
    required int stockActual,
    required int stockMinimo,
    this.categoriaId = const Value.absent(),
    this.ubicacion = const Value.absent(),
    required bool activo,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : nombre = Value(nombre),
       precioCompra = Value(precioCompra),
       precioVenta = Value(precioVenta),
       unidadMedida = Value(unidadMedida),
       stockActual = Value(stockActual),
       stockMinimo = Value(stockMinimo),
       activo = Value(activo),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Producto> custom({
    Expression<int>? id,
    Expression<String>? codigoBarras,
    Expression<String>? nombre,
    Expression<String>? marca,
    Expression<String>? descripcion,
    Expression<String>? uso,
    Expression<double>? precioCompra,
    Expression<double>? precioVenta,
    Expression<double>? precioMayoreo,
    Expression<String>? unidadMedida,
    Expression<int>? stockActual,
    Expression<int>? stockMinimo,
    Expression<int>? categoriaId,
    Expression<String>? ubicacion,
    Expression<bool>? activo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigoBarras != null) 'codigo_barras': codigoBarras,
      if (nombre != null) 'nombre': nombre,
      if (marca != null) 'marca': marca,
      if (descripcion != null) 'descripcion': descripcion,
      if (uso != null) 'uso': uso,
      if (precioCompra != null) 'precio_compra': precioCompra,
      if (precioVenta != null) 'precio_venta': precioVenta,
      if (precioMayoreo != null) 'precio_mayoreo': precioMayoreo,
      if (unidadMedida != null) 'unidad_medida': unidadMedida,
      if (stockActual != null) 'stock_actual': stockActual,
      if (stockMinimo != null) 'stock_minimo': stockMinimo,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (ubicacion != null) 'ubicacion': ubicacion,
      if (activo != null) 'activo': activo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ProductosCompanion copyWith({
    Value<int>? id,
    Value<String?>? codigoBarras,
    Value<String>? nombre,
    Value<String?>? marca,
    Value<String?>? descripcion,
    Value<String?>? uso,
    Value<double>? precioCompra,
    Value<double>? precioVenta,
    Value<double?>? precioMayoreo,
    Value<String>? unidadMedida,
    Value<int>? stockActual,
    Value<int>? stockMinimo,
    Value<int?>? categoriaId,
    Value<String?>? ubicacion,
    Value<bool>? activo,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return ProductosCompanion(
      id: id ?? this.id,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      nombre: nombre ?? this.nombre,
      marca: marca ?? this.marca,
      descripcion: descripcion ?? this.descripcion,
      uso: uso ?? this.uso,
      precioCompra: precioCompra ?? this.precioCompra,
      precioVenta: precioVenta ?? this.precioVenta,
      precioMayoreo: precioMayoreo ?? this.precioMayoreo,
      unidadMedida: unidadMedida ?? this.unidadMedida,
      stockActual: stockActual ?? this.stockActual,
      stockMinimo: stockMinimo ?? this.stockMinimo,
      categoriaId: categoriaId ?? this.categoriaId,
      ubicacion: ubicacion ?? this.ubicacion,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (codigoBarras.present) {
      map['codigo_barras'] = Variable<String>(codigoBarras.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (marca.present) {
      map['marca'] = Variable<String>(marca.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (uso.present) {
      map['uso'] = Variable<String>(uso.value);
    }
    if (precioCompra.present) {
      map['precio_compra'] = Variable<double>(precioCompra.value);
    }
    if (precioVenta.present) {
      map['precio_venta'] = Variable<double>(precioVenta.value);
    }
    if (precioMayoreo.present) {
      map['precio_mayoreo'] = Variable<double>(precioMayoreo.value);
    }
    if (unidadMedida.present) {
      map['unidad_medida'] = Variable<String>(unidadMedida.value);
    }
    if (stockActual.present) {
      map['stock_actual'] = Variable<int>(stockActual.value);
    }
    if (stockMinimo.present) {
      map['stock_minimo'] = Variable<int>(stockMinimo.value);
    }
    if (categoriaId.present) {
      map['categoria_id'] = Variable<int>(categoriaId.value);
    }
    if (ubicacion.present) {
      map['ubicacion'] = Variable<String>(ubicacion.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosCompanion(')
          ..write('id: $id, ')
          ..write('codigoBarras: $codigoBarras, ')
          ..write('nombre: $nombre, ')
          ..write('marca: $marca, ')
          ..write('descripcion: $descripcion, ')
          ..write('uso: $uso, ')
          ..write('precioCompra: $precioCompra, ')
          ..write('precioVenta: $precioVenta, ')
          ..write('precioMayoreo: $precioMayoreo, ')
          ..write('unidadMedida: $unidadMedida, ')
          ..write('stockActual: $stockActual, ')
          ..write('stockMinimo: $stockMinimo, ')
          ..write('categoriaId: $categoriaId, ')
          ..write('ubicacion: $ubicacion, ')
          ..write('activo: $activo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $CategoriasTable extends Categorias
    with TableInfo<$CategoriasTable, Categoria> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriasTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nombreMeta = const VerificationMeta('nombre');
  @override
  late final GeneratedColumn<String> nombre = GeneratedColumn<String>(
    'nombre',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descripcionMeta = const VerificationMeta(
    'descripcion',
  );
  @override
  late final GeneratedColumn<String> descripcion = GeneratedColumn<String>(
    'descripcion',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activoMeta = const VerificationMeta('activo');
  @override
  late final GeneratedColumn<bool> activo = GeneratedColumn<bool>(
    'activo',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("activo" IN (0, 1))',
    ),
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
    requiredDuringInsert: true,
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    nombre,
    descripcion,
    activo,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categorias';
  @override
  VerificationContext validateIntegrity(
    Insertable<Categoria> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('nombre')) {
      context.handle(
        _nombreMeta,
        nombre.isAcceptableOrUnknown(data['nombre']!, _nombreMeta),
      );
    } else if (isInserting) {
      context.missing(_nombreMeta);
    }
    if (data.containsKey('descripcion')) {
      context.handle(
        _descripcionMeta,
        descripcion.isAcceptableOrUnknown(
          data['descripcion']!,
          _descripcionMeta,
        ),
      );
    }
    if (data.containsKey('activo')) {
      context.handle(
        _activoMeta,
        activo.isAcceptableOrUnknown(data['activo']!, _activoMeta),
      );
    } else if (isInserting) {
      context.missing(_activoMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Categoria map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Categoria(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      nombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre'],
      )!,
      descripcion: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}descripcion'],
      ),
      activo: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}activo'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $CategoriasTable createAlias(String alias) {
    return $CategoriasTable(attachedDatabase, alias);
  }
}

class Categoria extends DataClass implements Insertable<Categoria> {
  final int id;
  final String nombre;
  final String? descripcion;
  final bool activo;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Categoria({
    required this.id,
    required this.nombre,
    this.descripcion,
    required this.activo,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['nombre'] = Variable<String>(nombre);
    if (!nullToAbsent || descripcion != null) {
      map['descripcion'] = Variable<String>(descripcion);
    }
    map['activo'] = Variable<bool>(activo);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  CategoriasCompanion toCompanion(bool nullToAbsent) {
    return CategoriasCompanion(
      id: Value(id),
      nombre: Value(nombre),
      descripcion: descripcion == null && nullToAbsent
          ? const Value.absent()
          : Value(descripcion),
      activo: Value(activo),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Categoria.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Categoria(
      id: serializer.fromJson<int>(json['id']),
      nombre: serializer.fromJson<String>(json['nombre']),
      descripcion: serializer.fromJson<String?>(json['descripcion']),
      activo: serializer.fromJson<bool>(json['activo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'nombre': serializer.toJson<String>(nombre),
      'descripcion': serializer.toJson<String?>(descripcion),
      'activo': serializer.toJson<bool>(activo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Categoria copyWith({
    int? id,
    String? nombre,
    Value<String?> descripcion = const Value.absent(),
    bool? activo,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Categoria(
    id: id ?? this.id,
    nombre: nombre ?? this.nombre,
    descripcion: descripcion.present ? descripcion.value : this.descripcion,
    activo: activo ?? this.activo,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Categoria copyWithCompanion(CategoriasCompanion data) {
    return Categoria(
      id: data.id.present ? data.id.value : this.id,
      nombre: data.nombre.present ? data.nombre.value : this.nombre,
      descripcion: data.descripcion.present
          ? data.descripcion.value
          : this.descripcion,
      activo: data.activo.present ? data.activo.value : this.activo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Categoria(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('activo: $activo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, nombre, descripcion, activo, createdAt, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Categoria &&
          other.id == this.id &&
          other.nombre == this.nombre &&
          other.descripcion == this.descripcion &&
          other.activo == this.activo &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class CategoriasCompanion extends UpdateCompanion<Categoria> {
  final Value<int> id;
  final Value<String> nombre;
  final Value<String?> descripcion;
  final Value<bool> activo;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const CategoriasCompanion({
    this.id = const Value.absent(),
    this.nombre = const Value.absent(),
    this.descripcion = const Value.absent(),
    this.activo = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  CategoriasCompanion.insert({
    this.id = const Value.absent(),
    required String nombre,
    this.descripcion = const Value.absent(),
    required bool activo,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : nombre = Value(nombre),
       activo = Value(activo),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Categoria> custom({
    Expression<int>? id,
    Expression<String>? nombre,
    Expression<String>? descripcion,
    Expression<bool>? activo,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (nombre != null) 'nombre': nombre,
      if (descripcion != null) 'descripcion': descripcion,
      if (activo != null) 'activo': activo,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  CategoriasCompanion copyWith({
    Value<int>? id,
    Value<String>? nombre,
    Value<String?>? descripcion,
    Value<bool>? activo,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return CategoriasCompanion(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      descripcion: descripcion ?? this.descripcion,
      activo: activo ?? this.activo,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (nombre.present) {
      map['nombre'] = Variable<String>(nombre.value);
    }
    if (descripcion.present) {
      map['descripcion'] = Variable<String>(descripcion.value);
    }
    if (activo.present) {
      map['activo'] = Variable<bool>(activo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriasCompanion(')
          ..write('id: $id, ')
          ..write('nombre: $nombre, ')
          ..write('descripcion: $descripcion, ')
          ..write('activo: $activo, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $VentasPendientesTable extends VentasPendientes
    with TableInfo<$VentasPendientesTable, VentasPendiente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentasPendientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'UNIQUE NOT NULL',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ventaDataMeta = const VerificationMeta(
    'ventaData',
  );
  @override
  late final GeneratedColumn<String> ventaData = GeneratedColumn<String>(
    'venta_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    createdAt,
    ventaData,
    total,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ventas_pendientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<VentasPendiente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('venta_data')) {
      context.handle(
        _ventaDataMeta,
        ventaData.isAcceptableOrUnknown(data['venta_data']!, _ventaDataMeta),
      );
    } else if (isInserting) {
      context.missing(_ventaDataMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  VentasPendiente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VentasPendiente(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      ventaData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}venta_data'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $VentasPendientesTable createAlias(String alias) {
    return $VentasPendientesTable(attachedDatabase, alias);
  }
}

class VentasPendiente extends DataClass implements Insertable<VentasPendiente> {
  final String clientId;
  final DateTime createdAt;
  final String ventaData;
  final double total;
  final bool synced;
  const VentasPendiente({
    required this.clientId,
    required this.createdAt,
    required this.ventaData,
    required this.total,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['venta_data'] = Variable<String>(ventaData);
    map['total'] = Variable<double>(total);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  VentasPendientesCompanion toCompanion(bool nullToAbsent) {
    return VentasPendientesCompanion(
      clientId: Value(clientId),
      createdAt: Value(createdAt),
      ventaData: Value(ventaData),
      total: Value(total),
      synced: Value(synced),
    );
  }

  factory VentasPendiente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VentasPendiente(
      clientId: serializer.fromJson<String>(json['clientId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      ventaData: serializer.fromJson<String>(json['ventaData']),
      total: serializer.fromJson<double>(json['total']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'ventaData': serializer.toJson<String>(ventaData),
      'total': serializer.toJson<double>(total),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  VentasPendiente copyWith({
    String? clientId,
    DateTime? createdAt,
    String? ventaData,
    double? total,
    bool? synced,
  }) => VentasPendiente(
    clientId: clientId ?? this.clientId,
    createdAt: createdAt ?? this.createdAt,
    ventaData: ventaData ?? this.ventaData,
    total: total ?? this.total,
    synced: synced ?? this.synced,
  );
  VentasPendiente copyWithCompanion(VentasPendientesCompanion data) {
    return VentasPendiente(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      ventaData: data.ventaData.present ? data.ventaData.value : this.ventaData,
      total: data.total.present ? data.total.value : this.total,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VentasPendiente(')
          ..write('clientId: $clientId, ')
          ..write('createdAt: $createdAt, ')
          ..write('ventaData: $ventaData, ')
          ..write('total: $total, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(clientId, createdAt, ventaData, total, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VentasPendiente &&
          other.clientId == this.clientId &&
          other.createdAt == this.createdAt &&
          other.ventaData == this.ventaData &&
          other.total == this.total &&
          other.synced == this.synced);
}

class VentasPendientesCompanion extends UpdateCompanion<VentasPendiente> {
  final Value<String> clientId;
  final Value<DateTime> createdAt;
  final Value<String> ventaData;
  final Value<double> total;
  final Value<bool> synced;
  final Value<int> rowid;
  const VentasPendientesCompanion({
    this.clientId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.ventaData = const Value.absent(),
    this.total = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  VentasPendientesCompanion.insert({
    required String clientId,
    required DateTime createdAt,
    required String ventaData,
    required double total,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       createdAt = Value(createdAt),
       ventaData = Value(ventaData),
       total = Value(total);
  static Insertable<VentasPendiente> custom({
    Expression<String>? clientId,
    Expression<DateTime>? createdAt,
    Expression<String>? ventaData,
    Expression<double>? total,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (createdAt != null) 'created_at': createdAt,
      if (ventaData != null) 'venta_data': ventaData,
      if (total != null) 'total': total,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  VentasPendientesCompanion copyWith({
    Value<String>? clientId,
    Value<DateTime>? createdAt,
    Value<String>? ventaData,
    Value<double>? total,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return VentasPendientesCompanion(
      clientId: clientId ?? this.clientId,
      createdAt: createdAt ?? this.createdAt,
      ventaData: ventaData ?? this.ventaData,
      total: total ?? this.total,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (ventaData.present) {
      map['venta_data'] = Variable<String>(ventaData.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VentasPendientesCompanion(')
          ..write('clientId: $clientId, ')
          ..write('createdAt: $createdAt, ')
          ..write('ventaData: $ventaData, ')
          ..write('total: $total, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $EntradasPendientesTable extends EntradasPendientes
    with TableInfo<$EntradasPendientesTable, EntradasPendiente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntradasPendientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'UNIQUE NOT NULL',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _entradaDataMeta = const VerificationMeta(
    'entradaData',
  );
  @override
  late final GeneratedColumn<String> entradaData = GeneratedColumn<String>(
    'entrada_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    createdAt,
    entradaData,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entradas_pendientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntradasPendiente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('entrada_data')) {
      context.handle(
        _entradaDataMeta,
        entradaData.isAcceptableOrUnknown(
          data['entrada_data']!,
          _entradaDataMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_entradaDataMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  EntradasPendiente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntradasPendiente(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      entradaData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}entrada_data'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $EntradasPendientesTable createAlias(String alias) {
    return $EntradasPendientesTable(attachedDatabase, alias);
  }
}

class EntradasPendiente extends DataClass
    implements Insertable<EntradasPendiente> {
  final String clientId;
  final DateTime createdAt;
  final String entradaData;
  final bool synced;
  const EntradasPendiente({
    required this.clientId,
    required this.createdAt,
    required this.entradaData,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['entrada_data'] = Variable<String>(entradaData);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  EntradasPendientesCompanion toCompanion(bool nullToAbsent) {
    return EntradasPendientesCompanion(
      clientId: Value(clientId),
      createdAt: Value(createdAt),
      entradaData: Value(entradaData),
      synced: Value(synced),
    );
  }

  factory EntradasPendiente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntradasPendiente(
      clientId: serializer.fromJson<String>(json['clientId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      entradaData: serializer.fromJson<String>(json['entradaData']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'entradaData': serializer.toJson<String>(entradaData),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  EntradasPendiente copyWith({
    String? clientId,
    DateTime? createdAt,
    String? entradaData,
    bool? synced,
  }) => EntradasPendiente(
    clientId: clientId ?? this.clientId,
    createdAt: createdAt ?? this.createdAt,
    entradaData: entradaData ?? this.entradaData,
    synced: synced ?? this.synced,
  );
  EntradasPendiente copyWithCompanion(EntradasPendientesCompanion data) {
    return EntradasPendiente(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      entradaData: data.entradaData.present
          ? data.entradaData.value
          : this.entradaData,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntradasPendiente(')
          ..write('clientId: $clientId, ')
          ..write('createdAt: $createdAt, ')
          ..write('entradaData: $entradaData, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clientId, createdAt, entradaData, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntradasPendiente &&
          other.clientId == this.clientId &&
          other.createdAt == this.createdAt &&
          other.entradaData == this.entradaData &&
          other.synced == this.synced);
}

class EntradasPendientesCompanion extends UpdateCompanion<EntradasPendiente> {
  final Value<String> clientId;
  final Value<DateTime> createdAt;
  final Value<String> entradaData;
  final Value<bool> synced;
  final Value<int> rowid;
  const EntradasPendientesCompanion({
    this.clientId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.entradaData = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntradasPendientesCompanion.insert({
    required String clientId,
    required DateTime createdAt,
    required String entradaData,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       createdAt = Value(createdAt),
       entradaData = Value(entradaData);
  static Insertable<EntradasPendiente> custom({
    Expression<String>? clientId,
    Expression<DateTime>? createdAt,
    Expression<String>? entradaData,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (createdAt != null) 'created_at': createdAt,
      if (entradaData != null) 'entrada_data': entradaData,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntradasPendientesCompanion copyWith({
    Value<String>? clientId,
    Value<DateTime>? createdAt,
    Value<String>? entradaData,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return EntradasPendientesCompanion(
      clientId: clientId ?? this.clientId,
      createdAt: createdAt ?? this.createdAt,
      entradaData: entradaData ?? this.entradaData,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (entradaData.present) {
      map['entrada_data'] = Variable<String>(entradaData.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntradasPendientesCompanion(')
          ..write('clientId: $clientId, ')
          ..write('createdAt: $createdAt, ')
          ..write('entradaData: $entradaData, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProductosPendientesTable extends ProductosPendientes
    with TableInfo<$ProductosPendientesTable, ProductosPendiente> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProductosPendientesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'UNIQUE NOT NULL',
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoDataMeta = const VerificationMeta(
    'productoData',
  );
  @override
  late final GeneratedColumn<String> productoData = GeneratedColumn<String>(
    'producto_data',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    clientId,
    createdAt,
    productoData,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'productos_pendientes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProductosPendiente> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    } else if (isInserting) {
      context.missing(_clientIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('producto_data')) {
      context.handle(
        _productoDataMeta,
        productoData.isAcceptableOrUnknown(
          data['producto_data']!,
          _productoDataMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_productoDataMeta);
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => const {};
  @override
  ProductosPendiente map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProductosPendiente(
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      productoData: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}producto_data'],
      )!,
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $ProductosPendientesTable createAlias(String alias) {
    return $ProductosPendientesTable(attachedDatabase, alias);
  }
}

class ProductosPendiente extends DataClass
    implements Insertable<ProductosPendiente> {
  final String clientId;
  final DateTime createdAt;
  final String productoData;
  final bool synced;
  const ProductosPendiente({
    required this.clientId,
    required this.createdAt,
    required this.productoData,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['client_id'] = Variable<String>(clientId);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['producto_data'] = Variable<String>(productoData);
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  ProductosPendientesCompanion toCompanion(bool nullToAbsent) {
    return ProductosPendientesCompanion(
      clientId: Value(clientId),
      createdAt: Value(createdAt),
      productoData: Value(productoData),
      synced: Value(synced),
    );
  }

  factory ProductosPendiente.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProductosPendiente(
      clientId: serializer.fromJson<String>(json['clientId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      productoData: serializer.fromJson<String>(json['productoData']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'clientId': serializer.toJson<String>(clientId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'productoData': serializer.toJson<String>(productoData),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  ProductosPendiente copyWith({
    String? clientId,
    DateTime? createdAt,
    String? productoData,
    bool? synced,
  }) => ProductosPendiente(
    clientId: clientId ?? this.clientId,
    createdAt: createdAt ?? this.createdAt,
    productoData: productoData ?? this.productoData,
    synced: synced ?? this.synced,
  );
  ProductosPendiente copyWithCompanion(ProductosPendientesCompanion data) {
    return ProductosPendiente(
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      productoData: data.productoData.present
          ? data.productoData.value
          : this.productoData,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProductosPendiente(')
          ..write('clientId: $clientId, ')
          ..write('createdAt: $createdAt, ')
          ..write('productoData: $productoData, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(clientId, createdAt, productoData, synced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProductosPendiente &&
          other.clientId == this.clientId &&
          other.createdAt == this.createdAt &&
          other.productoData == this.productoData &&
          other.synced == this.synced);
}

class ProductosPendientesCompanion extends UpdateCompanion<ProductosPendiente> {
  final Value<String> clientId;
  final Value<DateTime> createdAt;
  final Value<String> productoData;
  final Value<bool> synced;
  final Value<int> rowid;
  const ProductosPendientesCompanion({
    this.clientId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.productoData = const Value.absent(),
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProductosPendientesCompanion.insert({
    required String clientId,
    required DateTime createdAt,
    required String productoData,
    this.synced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : clientId = Value(clientId),
       createdAt = Value(createdAt),
       productoData = Value(productoData);
  static Insertable<ProductosPendiente> custom({
    Expression<String>? clientId,
    Expression<DateTime>? createdAt,
    Expression<String>? productoData,
    Expression<bool>? synced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (clientId != null) 'client_id': clientId,
      if (createdAt != null) 'created_at': createdAt,
      if (productoData != null) 'producto_data': productoData,
      if (synced != null) 'synced': synced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProductosPendientesCompanion copyWith({
    Value<String>? clientId,
    Value<DateTime>? createdAt,
    Value<String>? productoData,
    Value<bool>? synced,
    Value<int>? rowid,
  }) {
    return ProductosPendientesCompanion(
      clientId: clientId ?? this.clientId,
      createdAt: createdAt ?? this.createdAt,
      productoData: productoData ?? this.productoData,
      synced: synced ?? this.synced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (productoData.present) {
      map['producto_data'] = Variable<String>(productoData.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosPendientesCompanion(')
          ..write('clientId: $clientId, ')
          ..write('createdAt: $createdAt, ')
          ..write('productoData: $productoData, ')
          ..write('synced: $synced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $VentasLocalTable extends VentasLocal
    with TableInfo<$VentasLocalTable, VentasLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentasLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _folioMeta = const VerificationMeta('folio');
  @override
  late final GeneratedColumn<String> folio = GeneratedColumn<String>(
    'folio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ivaMeta = const VerificationMeta('iva');
  @override
  late final GeneratedColumn<double> iva = GeneratedColumn<double>(
    'iva',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _metodoPagoMeta = const VerificationMeta(
    'metodoPago',
  );
  @override
  late final GeneratedColumn<String> metodoPago = GeneratedColumn<String>(
    'metodo_pago',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _montoRecibidoMeta = const VerificationMeta(
    'montoRecibido',
  );
  @override
  late final GeneratedColumn<double> montoRecibido = GeneratedColumn<double>(
    'monto_recibido',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _cambioMeta = const VerificationMeta('cambio');
  @override
  late final GeneratedColumn<double> cambio = GeneratedColumn<double>(
    'cambio',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    folio,
    clientId,
    fecha,
    subtotal,
    iva,
    total,
    metodoPago,
    montoRecibido,
    cambio,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ventas_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<VentasLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('folio')) {
      context.handle(
        _folioMeta,
        folio.isAcceptableOrUnknown(data['folio']!, _folioMeta),
      );
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    if (data.containsKey('iva')) {
      context.handle(
        _ivaMeta,
        iva.isAcceptableOrUnknown(data['iva']!, _ivaMeta),
      );
    } else if (isInserting) {
      context.missing(_ivaMeta);
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('metodo_pago')) {
      context.handle(
        _metodoPagoMeta,
        metodoPago.isAcceptableOrUnknown(data['metodo_pago']!, _metodoPagoMeta),
      );
    } else if (isInserting) {
      context.missing(_metodoPagoMeta);
    }
    if (data.containsKey('monto_recibido')) {
      context.handle(
        _montoRecibidoMeta,
        montoRecibido.isAcceptableOrUnknown(
          data['monto_recibido']!,
          _montoRecibidoMeta,
        ),
      );
    }
    if (data.containsKey('cambio')) {
      context.handle(
        _cambioMeta,
        cambio.isAcceptableOrUnknown(data['cambio']!, _cambioMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VentasLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VentasLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      folio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folio'],
      ),
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      ),
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
      iva: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}iva'],
      )!,
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      metodoPago: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}metodo_pago'],
      )!,
      montoRecibido: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}monto_recibido'],
      ),
      cambio: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}cambio'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $VentasLocalTable createAlias(String alias) {
    return $VentasLocalTable(attachedDatabase, alias);
  }
}

class VentasLocalData extends DataClass implements Insertable<VentasLocalData> {
  final int id;
  final String? folio;
  final String? clientId;
  final DateTime fecha;
  final double subtotal;
  final double iva;
  final double total;
  final String metodoPago;
  final double? montoRecibido;
  final double? cambio;
  final bool synced;
  const VentasLocalData({
    required this.id,
    this.folio,
    this.clientId,
    required this.fecha,
    required this.subtotal,
    required this.iva,
    required this.total,
    required this.metodoPago,
    this.montoRecibido,
    this.cambio,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || folio != null) {
      map['folio'] = Variable<String>(folio);
    }
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['fecha'] = Variable<DateTime>(fecha);
    map['subtotal'] = Variable<double>(subtotal);
    map['iva'] = Variable<double>(iva);
    map['total'] = Variable<double>(total);
    map['metodo_pago'] = Variable<String>(metodoPago);
    if (!nullToAbsent || montoRecibido != null) {
      map['monto_recibido'] = Variable<double>(montoRecibido);
    }
    if (!nullToAbsent || cambio != null) {
      map['cambio'] = Variable<double>(cambio);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  VentasLocalCompanion toCompanion(bool nullToAbsent) {
    return VentasLocalCompanion(
      id: Value(id),
      folio: folio == null && nullToAbsent
          ? const Value.absent()
          : Value(folio),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      fecha: Value(fecha),
      subtotal: Value(subtotal),
      iva: Value(iva),
      total: Value(total),
      metodoPago: Value(metodoPago),
      montoRecibido: montoRecibido == null && nullToAbsent
          ? const Value.absent()
          : Value(montoRecibido),
      cambio: cambio == null && nullToAbsent
          ? const Value.absent()
          : Value(cambio),
      synced: Value(synced),
    );
  }

  factory VentasLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VentasLocalData(
      id: serializer.fromJson<int>(json['id']),
      folio: serializer.fromJson<String?>(json['folio']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
      iva: serializer.fromJson<double>(json['iva']),
      total: serializer.fromJson<double>(json['total']),
      metodoPago: serializer.fromJson<String>(json['metodoPago']),
      montoRecibido: serializer.fromJson<double?>(json['montoRecibido']),
      cambio: serializer.fromJson<double?>(json['cambio']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'folio': serializer.toJson<String?>(folio),
      'clientId': serializer.toJson<String?>(clientId),
      'fecha': serializer.toJson<DateTime>(fecha),
      'subtotal': serializer.toJson<double>(subtotal),
      'iva': serializer.toJson<double>(iva),
      'total': serializer.toJson<double>(total),
      'metodoPago': serializer.toJson<String>(metodoPago),
      'montoRecibido': serializer.toJson<double?>(montoRecibido),
      'cambio': serializer.toJson<double?>(cambio),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  VentasLocalData copyWith({
    int? id,
    Value<String?> folio = const Value.absent(),
    Value<String?> clientId = const Value.absent(),
    DateTime? fecha,
    double? subtotal,
    double? iva,
    double? total,
    String? metodoPago,
    Value<double?> montoRecibido = const Value.absent(),
    Value<double?> cambio = const Value.absent(),
    bool? synced,
  }) => VentasLocalData(
    id: id ?? this.id,
    folio: folio.present ? folio.value : this.folio,
    clientId: clientId.present ? clientId.value : this.clientId,
    fecha: fecha ?? this.fecha,
    subtotal: subtotal ?? this.subtotal,
    iva: iva ?? this.iva,
    total: total ?? this.total,
    metodoPago: metodoPago ?? this.metodoPago,
    montoRecibido: montoRecibido.present
        ? montoRecibido.value
        : this.montoRecibido,
    cambio: cambio.present ? cambio.value : this.cambio,
    synced: synced ?? this.synced,
  );
  VentasLocalData copyWithCompanion(VentasLocalCompanion data) {
    return VentasLocalData(
      id: data.id.present ? data.id.value : this.id,
      folio: data.folio.present ? data.folio.value : this.folio,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
      iva: data.iva.present ? data.iva.value : this.iva,
      total: data.total.present ? data.total.value : this.total,
      metodoPago: data.metodoPago.present
          ? data.metodoPago.value
          : this.metodoPago,
      montoRecibido: data.montoRecibido.present
          ? data.montoRecibido.value
          : this.montoRecibido,
      cambio: data.cambio.present ? data.cambio.value : this.cambio,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VentasLocalData(')
          ..write('id: $id, ')
          ..write('folio: $folio, ')
          ..write('clientId: $clientId, ')
          ..write('fecha: $fecha, ')
          ..write('subtotal: $subtotal, ')
          ..write('iva: $iva, ')
          ..write('total: $total, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('montoRecibido: $montoRecibido, ')
          ..write('cambio: $cambio, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    folio,
    clientId,
    fecha,
    subtotal,
    iva,
    total,
    metodoPago,
    montoRecibido,
    cambio,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VentasLocalData &&
          other.id == this.id &&
          other.folio == this.folio &&
          other.clientId == this.clientId &&
          other.fecha == this.fecha &&
          other.subtotal == this.subtotal &&
          other.iva == this.iva &&
          other.total == this.total &&
          other.metodoPago == this.metodoPago &&
          other.montoRecibido == this.montoRecibido &&
          other.cambio == this.cambio &&
          other.synced == this.synced);
}

class VentasLocalCompanion extends UpdateCompanion<VentasLocalData> {
  final Value<int> id;
  final Value<String?> folio;
  final Value<String?> clientId;
  final Value<DateTime> fecha;
  final Value<double> subtotal;
  final Value<double> iva;
  final Value<double> total;
  final Value<String> metodoPago;
  final Value<double?> montoRecibido;
  final Value<double?> cambio;
  final Value<bool> synced;
  const VentasLocalCompanion({
    this.id = const Value.absent(),
    this.folio = const Value.absent(),
    this.clientId = const Value.absent(),
    this.fecha = const Value.absent(),
    this.subtotal = const Value.absent(),
    this.iva = const Value.absent(),
    this.total = const Value.absent(),
    this.metodoPago = const Value.absent(),
    this.montoRecibido = const Value.absent(),
    this.cambio = const Value.absent(),
    this.synced = const Value.absent(),
  });
  VentasLocalCompanion.insert({
    this.id = const Value.absent(),
    this.folio = const Value.absent(),
    this.clientId = const Value.absent(),
    required DateTime fecha,
    required double subtotal,
    required double iva,
    required double total,
    required String metodoPago,
    this.montoRecibido = const Value.absent(),
    this.cambio = const Value.absent(),
    this.synced = const Value.absent(),
  }) : fecha = Value(fecha),
       subtotal = Value(subtotal),
       iva = Value(iva),
       total = Value(total),
       metodoPago = Value(metodoPago);
  static Insertable<VentasLocalData> custom({
    Expression<int>? id,
    Expression<String>? folio,
    Expression<String>? clientId,
    Expression<DateTime>? fecha,
    Expression<double>? subtotal,
    Expression<double>? iva,
    Expression<double>? total,
    Expression<String>? metodoPago,
    Expression<double>? montoRecibido,
    Expression<double>? cambio,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (folio != null) 'folio': folio,
      if (clientId != null) 'client_id': clientId,
      if (fecha != null) 'fecha': fecha,
      if (subtotal != null) 'subtotal': subtotal,
      if (iva != null) 'iva': iva,
      if (total != null) 'total': total,
      if (metodoPago != null) 'metodo_pago': metodoPago,
      if (montoRecibido != null) 'monto_recibido': montoRecibido,
      if (cambio != null) 'cambio': cambio,
      if (synced != null) 'synced': synced,
    });
  }

  VentasLocalCompanion copyWith({
    Value<int>? id,
    Value<String?>? folio,
    Value<String?>? clientId,
    Value<DateTime>? fecha,
    Value<double>? subtotal,
    Value<double>? iva,
    Value<double>? total,
    Value<String>? metodoPago,
    Value<double?>? montoRecibido,
    Value<double?>? cambio,
    Value<bool>? synced,
  }) {
    return VentasLocalCompanion(
      id: id ?? this.id,
      folio: folio ?? this.folio,
      clientId: clientId ?? this.clientId,
      fecha: fecha ?? this.fecha,
      subtotal: subtotal ?? this.subtotal,
      iva: iva ?? this.iva,
      total: total ?? this.total,
      metodoPago: metodoPago ?? this.metodoPago,
      montoRecibido: montoRecibido ?? this.montoRecibido,
      cambio: cambio ?? this.cambio,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (folio.present) {
      map['folio'] = Variable<String>(folio.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    if (iva.present) {
      map['iva'] = Variable<double>(iva.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (metodoPago.present) {
      map['metodo_pago'] = Variable<String>(metodoPago.value);
    }
    if (montoRecibido.present) {
      map['monto_recibido'] = Variable<double>(montoRecibido.value);
    }
    if (cambio.present) {
      map['cambio'] = Variable<double>(cambio.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VentasLocalCompanion(')
          ..write('id: $id, ')
          ..write('folio: $folio, ')
          ..write('clientId: $clientId, ')
          ..write('fecha: $fecha, ')
          ..write('subtotal: $subtotal, ')
          ..write('iva: $iva, ')
          ..write('total: $total, ')
          ..write('metodoPago: $metodoPago, ')
          ..write('montoRecibido: $montoRecibido, ')
          ..write('cambio: $cambio, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $VentasDetalleLocalTable extends VentasDetalleLocal
    with TableInfo<$VentasDetalleLocalTable, VentasDetalleLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $VentasDetalleLocalTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _ventaIdMeta = const VerificationMeta(
    'ventaId',
  );
  @override
  late final GeneratedColumn<int> ventaId = GeneratedColumn<int>(
    'venta_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<int> productoId = GeneratedColumn<int>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreProductoMeta = const VerificationMeta(
    'nombreProducto',
  );
  @override
  late final GeneratedColumn<String> nombreProducto = GeneratedColumn<String>(
    'nombre_producto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _precioUnitarioMeta = const VerificationMeta(
    'precioUnitario',
  );
  @override
  late final GeneratedColumn<double> precioUnitario = GeneratedColumn<double>(
    'precio_unitario',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subtotalMeta = const VerificationMeta(
    'subtotal',
  );
  @override
  late final GeneratedColumn<double> subtotal = GeneratedColumn<double>(
    'subtotal',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ventaId,
    productoId,
    nombreProducto,
    precioUnitario,
    cantidad,
    subtotal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ventas_detalle_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<VentasDetalleLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('venta_id')) {
      context.handle(
        _ventaIdMeta,
        ventaId.isAcceptableOrUnknown(data['venta_id']!, _ventaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ventaIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('nombre_producto')) {
      context.handle(
        _nombreProductoMeta,
        nombreProducto.isAcceptableOrUnknown(
          data['nombre_producto']!,
          _nombreProductoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreProductoMeta);
    }
    if (data.containsKey('precio_unitario')) {
      context.handle(
        _precioUnitarioMeta,
        precioUnitario.isAcceptableOrUnknown(
          data['precio_unitario']!,
          _precioUnitarioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_precioUnitarioMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('subtotal')) {
      context.handle(
        _subtotalMeta,
        subtotal.isAcceptableOrUnknown(data['subtotal']!, _subtotalMeta),
      );
    } else if (isInserting) {
      context.missing(_subtotalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  VentasDetalleLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return VentasDetalleLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ventaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}venta_id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}producto_id'],
      )!,
      nombreProducto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_producto'],
      )!,
      precioUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}precio_unitario'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad'],
      )!,
      subtotal: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}subtotal'],
      )!,
    );
  }

  @override
  $VentasDetalleLocalTable createAlias(String alias) {
    return $VentasDetalleLocalTable(attachedDatabase, alias);
  }
}

class VentasDetalleLocalData extends DataClass
    implements Insertable<VentasDetalleLocalData> {
  final int id;
  final int ventaId;
  final int productoId;
  final String nombreProducto;
  final double precioUnitario;
  final int cantidad;
  final double subtotal;
  const VentasDetalleLocalData({
    required this.id,
    required this.ventaId,
    required this.productoId,
    required this.nombreProducto,
    required this.precioUnitario,
    required this.cantidad,
    required this.subtotal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['venta_id'] = Variable<int>(ventaId);
    map['producto_id'] = Variable<int>(productoId);
    map['nombre_producto'] = Variable<String>(nombreProducto);
    map['precio_unitario'] = Variable<double>(precioUnitario);
    map['cantidad'] = Variable<int>(cantidad);
    map['subtotal'] = Variable<double>(subtotal);
    return map;
  }

  VentasDetalleLocalCompanion toCompanion(bool nullToAbsent) {
    return VentasDetalleLocalCompanion(
      id: Value(id),
      ventaId: Value(ventaId),
      productoId: Value(productoId),
      nombreProducto: Value(nombreProducto),
      precioUnitario: Value(precioUnitario),
      cantidad: Value(cantidad),
      subtotal: Value(subtotal),
    );
  }

  factory VentasDetalleLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return VentasDetalleLocalData(
      id: serializer.fromJson<int>(json['id']),
      ventaId: serializer.fromJson<int>(json['ventaId']),
      productoId: serializer.fromJson<int>(json['productoId']),
      nombreProducto: serializer.fromJson<String>(json['nombreProducto']),
      precioUnitario: serializer.fromJson<double>(json['precioUnitario']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      subtotal: serializer.fromJson<double>(json['subtotal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ventaId': serializer.toJson<int>(ventaId),
      'productoId': serializer.toJson<int>(productoId),
      'nombreProducto': serializer.toJson<String>(nombreProducto),
      'precioUnitario': serializer.toJson<double>(precioUnitario),
      'cantidad': serializer.toJson<int>(cantidad),
      'subtotal': serializer.toJson<double>(subtotal),
    };
  }

  VentasDetalleLocalData copyWith({
    int? id,
    int? ventaId,
    int? productoId,
    String? nombreProducto,
    double? precioUnitario,
    int? cantidad,
    double? subtotal,
  }) => VentasDetalleLocalData(
    id: id ?? this.id,
    ventaId: ventaId ?? this.ventaId,
    productoId: productoId ?? this.productoId,
    nombreProducto: nombreProducto ?? this.nombreProducto,
    precioUnitario: precioUnitario ?? this.precioUnitario,
    cantidad: cantidad ?? this.cantidad,
    subtotal: subtotal ?? this.subtotal,
  );
  VentasDetalleLocalData copyWithCompanion(VentasDetalleLocalCompanion data) {
    return VentasDetalleLocalData(
      id: data.id.present ? data.id.value : this.id,
      ventaId: data.ventaId.present ? data.ventaId.value : this.ventaId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      nombreProducto: data.nombreProducto.present
          ? data.nombreProducto.value
          : this.nombreProducto,
      precioUnitario: data.precioUnitario.present
          ? data.precioUnitario.value
          : this.precioUnitario,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      subtotal: data.subtotal.present ? data.subtotal.value : this.subtotal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('VentasDetalleLocalData(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('productoId: $productoId, ')
          ..write('nombreProducto: $nombreProducto, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('cantidad: $cantidad, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ventaId,
    productoId,
    nombreProducto,
    precioUnitario,
    cantidad,
    subtotal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is VentasDetalleLocalData &&
          other.id == this.id &&
          other.ventaId == this.ventaId &&
          other.productoId == this.productoId &&
          other.nombreProducto == this.nombreProducto &&
          other.precioUnitario == this.precioUnitario &&
          other.cantidad == this.cantidad &&
          other.subtotal == this.subtotal);
}

class VentasDetalleLocalCompanion
    extends UpdateCompanion<VentasDetalleLocalData> {
  final Value<int> id;
  final Value<int> ventaId;
  final Value<int> productoId;
  final Value<String> nombreProducto;
  final Value<double> precioUnitario;
  final Value<int> cantidad;
  final Value<double> subtotal;
  const VentasDetalleLocalCompanion({
    this.id = const Value.absent(),
    this.ventaId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.nombreProducto = const Value.absent(),
    this.precioUnitario = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.subtotal = const Value.absent(),
  });
  VentasDetalleLocalCompanion.insert({
    this.id = const Value.absent(),
    required int ventaId,
    required int productoId,
    required String nombreProducto,
    required double precioUnitario,
    required int cantidad,
    required double subtotal,
  }) : ventaId = Value(ventaId),
       productoId = Value(productoId),
       nombreProducto = Value(nombreProducto),
       precioUnitario = Value(precioUnitario),
       cantidad = Value(cantidad),
       subtotal = Value(subtotal);
  static Insertable<VentasDetalleLocalData> custom({
    Expression<int>? id,
    Expression<int>? ventaId,
    Expression<int>? productoId,
    Expression<String>? nombreProducto,
    Expression<double>? precioUnitario,
    Expression<int>? cantidad,
    Expression<double>? subtotal,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ventaId != null) 'venta_id': ventaId,
      if (productoId != null) 'producto_id': productoId,
      if (nombreProducto != null) 'nombre_producto': nombreProducto,
      if (precioUnitario != null) 'precio_unitario': precioUnitario,
      if (cantidad != null) 'cantidad': cantidad,
      if (subtotal != null) 'subtotal': subtotal,
    });
  }

  VentasDetalleLocalCompanion copyWith({
    Value<int>? id,
    Value<int>? ventaId,
    Value<int>? productoId,
    Value<String>? nombreProducto,
    Value<double>? precioUnitario,
    Value<int>? cantidad,
    Value<double>? subtotal,
  }) {
    return VentasDetalleLocalCompanion(
      id: id ?? this.id,
      ventaId: ventaId ?? this.ventaId,
      productoId: productoId ?? this.productoId,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      precioUnitario: precioUnitario ?? this.precioUnitario,
      cantidad: cantidad ?? this.cantidad,
      subtotal: subtotal ?? this.subtotal,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ventaId.present) {
      map['venta_id'] = Variable<int>(ventaId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<int>(productoId.value);
    }
    if (nombreProducto.present) {
      map['nombre_producto'] = Variable<String>(nombreProducto.value);
    }
    if (precioUnitario.present) {
      map['precio_unitario'] = Variable<double>(precioUnitario.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (subtotal.present) {
      map['subtotal'] = Variable<double>(subtotal.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('VentasDetalleLocalCompanion(')
          ..write('id: $id, ')
          ..write('ventaId: $ventaId, ')
          ..write('productoId: $productoId, ')
          ..write('nombreProducto: $nombreProducto, ')
          ..write('precioUnitario: $precioUnitario, ')
          ..write('cantidad: $cantidad, ')
          ..write('subtotal: $subtotal')
          ..write(')'))
        .toString();
  }
}

class $EntradasLocalTable extends EntradasLocal
    with TableInfo<$EntradasLocalTable, EntradasLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntradasLocalTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _folioMeta = const VerificationMeta('folio');
  @override
  late final GeneratedColumn<String> folio = GeneratedColumn<String>(
    'folio',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _proveedorMeta = const VerificationMeta(
    'proveedor',
  );
  @override
  late final GeneratedColumn<String> proveedor = GeneratedColumn<String>(
    'proveedor',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observacionesMeta = const VerificationMeta(
    'observaciones',
  );
  @override
  late final GeneratedColumn<String> observaciones = GeneratedColumn<String>(
    'observaciones',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _totalMeta = const VerificationMeta('total');
  @override
  late final GeneratedColumn<double> total = GeneratedColumn<double>(
    'total',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fechaMeta = const VerificationMeta('fecha');
  @override
  late final GeneratedColumn<DateTime> fecha = GeneratedColumn<DateTime>(
    'fecha',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _clientIdMeta = const VerificationMeta(
    'clientId',
  );
  @override
  late final GeneratedColumn<String> clientId = GeneratedColumn<String>(
    'client_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _syncedMeta = const VerificationMeta('synced');
  @override
  late final GeneratedColumn<bool> synced = GeneratedColumn<bool>(
    'synced',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("synced" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    folio,
    proveedor,
    observaciones,
    total,
    fecha,
    clientId,
    synced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entradas_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntradasLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('folio')) {
      context.handle(
        _folioMeta,
        folio.isAcceptableOrUnknown(data['folio']!, _folioMeta),
      );
    }
    if (data.containsKey('proveedor')) {
      context.handle(
        _proveedorMeta,
        proveedor.isAcceptableOrUnknown(data['proveedor']!, _proveedorMeta),
      );
    }
    if (data.containsKey('observaciones')) {
      context.handle(
        _observacionesMeta,
        observaciones.isAcceptableOrUnknown(
          data['observaciones']!,
          _observacionesMeta,
        ),
      );
    }
    if (data.containsKey('total')) {
      context.handle(
        _totalMeta,
        total.isAcceptableOrUnknown(data['total']!, _totalMeta),
      );
    } else if (isInserting) {
      context.missing(_totalMeta);
    }
    if (data.containsKey('fecha')) {
      context.handle(
        _fechaMeta,
        fecha.isAcceptableOrUnknown(data['fecha']!, _fechaMeta),
      );
    } else if (isInserting) {
      context.missing(_fechaMeta);
    }
    if (data.containsKey('client_id')) {
      context.handle(
        _clientIdMeta,
        clientId.isAcceptableOrUnknown(data['client_id']!, _clientIdMeta),
      );
    }
    if (data.containsKey('synced')) {
      context.handle(
        _syncedMeta,
        synced.isAcceptableOrUnknown(data['synced']!, _syncedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntradasLocalData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntradasLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      folio: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}folio'],
      ),
      proveedor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}proveedor'],
      ),
      observaciones: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observaciones'],
      ),
      total: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total'],
      )!,
      fecha: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fecha'],
      )!,
      clientId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}client_id'],
      ),
      synced: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}synced'],
      )!,
    );
  }

  @override
  $EntradasLocalTable createAlias(String alias) {
    return $EntradasLocalTable(attachedDatabase, alias);
  }
}

class EntradasLocalData extends DataClass
    implements Insertable<EntradasLocalData> {
  final int id;
  final String? folio;
  final String? proveedor;
  final String? observaciones;
  final double total;
  final DateTime fecha;
  final String? clientId;
  final bool synced;
  const EntradasLocalData({
    required this.id,
    this.folio,
    this.proveedor,
    this.observaciones,
    required this.total,
    required this.fecha,
    this.clientId,
    required this.synced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || folio != null) {
      map['folio'] = Variable<String>(folio);
    }
    if (!nullToAbsent || proveedor != null) {
      map['proveedor'] = Variable<String>(proveedor);
    }
    if (!nullToAbsent || observaciones != null) {
      map['observaciones'] = Variable<String>(observaciones);
    }
    map['total'] = Variable<double>(total);
    map['fecha'] = Variable<DateTime>(fecha);
    if (!nullToAbsent || clientId != null) {
      map['client_id'] = Variable<String>(clientId);
    }
    map['synced'] = Variable<bool>(synced);
    return map;
  }

  EntradasLocalCompanion toCompanion(bool nullToAbsent) {
    return EntradasLocalCompanion(
      id: Value(id),
      folio: folio == null && nullToAbsent
          ? const Value.absent()
          : Value(folio),
      proveedor: proveedor == null && nullToAbsent
          ? const Value.absent()
          : Value(proveedor),
      observaciones: observaciones == null && nullToAbsent
          ? const Value.absent()
          : Value(observaciones),
      total: Value(total),
      fecha: Value(fecha),
      clientId: clientId == null && nullToAbsent
          ? const Value.absent()
          : Value(clientId),
      synced: Value(synced),
    );
  }

  factory EntradasLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntradasLocalData(
      id: serializer.fromJson<int>(json['id']),
      folio: serializer.fromJson<String?>(json['folio']),
      proveedor: serializer.fromJson<String?>(json['proveedor']),
      observaciones: serializer.fromJson<String?>(json['observaciones']),
      total: serializer.fromJson<double>(json['total']),
      fecha: serializer.fromJson<DateTime>(json['fecha']),
      clientId: serializer.fromJson<String?>(json['clientId']),
      synced: serializer.fromJson<bool>(json['synced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'folio': serializer.toJson<String?>(folio),
      'proveedor': serializer.toJson<String?>(proveedor),
      'observaciones': serializer.toJson<String?>(observaciones),
      'total': serializer.toJson<double>(total),
      'fecha': serializer.toJson<DateTime>(fecha),
      'clientId': serializer.toJson<String?>(clientId),
      'synced': serializer.toJson<bool>(synced),
    };
  }

  EntradasLocalData copyWith({
    int? id,
    Value<String?> folio = const Value.absent(),
    Value<String?> proveedor = const Value.absent(),
    Value<String?> observaciones = const Value.absent(),
    double? total,
    DateTime? fecha,
    Value<String?> clientId = const Value.absent(),
    bool? synced,
  }) => EntradasLocalData(
    id: id ?? this.id,
    folio: folio.present ? folio.value : this.folio,
    proveedor: proveedor.present ? proveedor.value : this.proveedor,
    observaciones: observaciones.present
        ? observaciones.value
        : this.observaciones,
    total: total ?? this.total,
    fecha: fecha ?? this.fecha,
    clientId: clientId.present ? clientId.value : this.clientId,
    synced: synced ?? this.synced,
  );
  EntradasLocalData copyWithCompanion(EntradasLocalCompanion data) {
    return EntradasLocalData(
      id: data.id.present ? data.id.value : this.id,
      folio: data.folio.present ? data.folio.value : this.folio,
      proveedor: data.proveedor.present ? data.proveedor.value : this.proveedor,
      observaciones: data.observaciones.present
          ? data.observaciones.value
          : this.observaciones,
      total: data.total.present ? data.total.value : this.total,
      fecha: data.fecha.present ? data.fecha.value : this.fecha,
      clientId: data.clientId.present ? data.clientId.value : this.clientId,
      synced: data.synced.present ? data.synced.value : this.synced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntradasLocalData(')
          ..write('id: $id, ')
          ..write('folio: $folio, ')
          ..write('proveedor: $proveedor, ')
          ..write('observaciones: $observaciones, ')
          ..write('total: $total, ')
          ..write('fecha: $fecha, ')
          ..write('clientId: $clientId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    folio,
    proveedor,
    observaciones,
    total,
    fecha,
    clientId,
    synced,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntradasLocalData &&
          other.id == this.id &&
          other.folio == this.folio &&
          other.proveedor == this.proveedor &&
          other.observaciones == this.observaciones &&
          other.total == this.total &&
          other.fecha == this.fecha &&
          other.clientId == this.clientId &&
          other.synced == this.synced);
}

class EntradasLocalCompanion extends UpdateCompanion<EntradasLocalData> {
  final Value<int> id;
  final Value<String?> folio;
  final Value<String?> proveedor;
  final Value<String?> observaciones;
  final Value<double> total;
  final Value<DateTime> fecha;
  final Value<String?> clientId;
  final Value<bool> synced;
  const EntradasLocalCompanion({
    this.id = const Value.absent(),
    this.folio = const Value.absent(),
    this.proveedor = const Value.absent(),
    this.observaciones = const Value.absent(),
    this.total = const Value.absent(),
    this.fecha = const Value.absent(),
    this.clientId = const Value.absent(),
    this.synced = const Value.absent(),
  });
  EntradasLocalCompanion.insert({
    this.id = const Value.absent(),
    this.folio = const Value.absent(),
    this.proveedor = const Value.absent(),
    this.observaciones = const Value.absent(),
    required double total,
    required DateTime fecha,
    this.clientId = const Value.absent(),
    this.synced = const Value.absent(),
  }) : total = Value(total),
       fecha = Value(fecha);
  static Insertable<EntradasLocalData> custom({
    Expression<int>? id,
    Expression<String>? folio,
    Expression<String>? proveedor,
    Expression<String>? observaciones,
    Expression<double>? total,
    Expression<DateTime>? fecha,
    Expression<String>? clientId,
    Expression<bool>? synced,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (folio != null) 'folio': folio,
      if (proveedor != null) 'proveedor': proveedor,
      if (observaciones != null) 'observaciones': observaciones,
      if (total != null) 'total': total,
      if (fecha != null) 'fecha': fecha,
      if (clientId != null) 'client_id': clientId,
      if (synced != null) 'synced': synced,
    });
  }

  EntradasLocalCompanion copyWith({
    Value<int>? id,
    Value<String?>? folio,
    Value<String?>? proveedor,
    Value<String?>? observaciones,
    Value<double>? total,
    Value<DateTime>? fecha,
    Value<String?>? clientId,
    Value<bool>? synced,
  }) {
    return EntradasLocalCompanion(
      id: id ?? this.id,
      folio: folio ?? this.folio,
      proveedor: proveedor ?? this.proveedor,
      observaciones: observaciones ?? this.observaciones,
      total: total ?? this.total,
      fecha: fecha ?? this.fecha,
      clientId: clientId ?? this.clientId,
      synced: synced ?? this.synced,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (folio.present) {
      map['folio'] = Variable<String>(folio.value);
    }
    if (proveedor.present) {
      map['proveedor'] = Variable<String>(proveedor.value);
    }
    if (observaciones.present) {
      map['observaciones'] = Variable<String>(observaciones.value);
    }
    if (total.present) {
      map['total'] = Variable<double>(total.value);
    }
    if (fecha.present) {
      map['fecha'] = Variable<DateTime>(fecha.value);
    }
    if (clientId.present) {
      map['client_id'] = Variable<String>(clientId.value);
    }
    if (synced.present) {
      map['synced'] = Variable<bool>(synced.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntradasLocalCompanion(')
          ..write('id: $id, ')
          ..write('folio: $folio, ')
          ..write('proveedor: $proveedor, ')
          ..write('observaciones: $observaciones, ')
          ..write('total: $total, ')
          ..write('fecha: $fecha, ')
          ..write('clientId: $clientId, ')
          ..write('synced: $synced')
          ..write(')'))
        .toString();
  }
}

class $EntradasDetalleLocalTable extends EntradasDetalleLocal
    with TableInfo<$EntradasDetalleLocalTable, EntradasDetalleLocalData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntradasDetalleLocalTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _entradaIdMeta = const VerificationMeta(
    'entradaId',
  );
  @override
  late final GeneratedColumn<int> entradaId = GeneratedColumn<int>(
    'entrada_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _productoIdMeta = const VerificationMeta(
    'productoId',
  );
  @override
  late final GeneratedColumn<int> productoId = GeneratedColumn<int>(
    'producto_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nombreProductoMeta = const VerificationMeta(
    'nombreProducto',
  );
  @override
  late final GeneratedColumn<String> nombreProducto = GeneratedColumn<String>(
    'nombre_producto',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _cantidadMeta = const VerificationMeta(
    'cantidad',
  );
  @override
  late final GeneratedColumn<int> cantidad = GeneratedColumn<int>(
    'cantidad',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _costoUnitarioMeta = const VerificationMeta(
    'costoUnitario',
  );
  @override
  late final GeneratedColumn<double> costoUnitario = GeneratedColumn<double>(
    'costo_unitario',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    entradaId,
    productoId,
    nombreProducto,
    cantidad,
    costoUnitario,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'entradas_detalle_local';
  @override
  VerificationContext validateIntegrity(
    Insertable<EntradasDetalleLocalData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('entrada_id')) {
      context.handle(
        _entradaIdMeta,
        entradaId.isAcceptableOrUnknown(data['entrada_id']!, _entradaIdMeta),
      );
    } else if (isInserting) {
      context.missing(_entradaIdMeta);
    }
    if (data.containsKey('producto_id')) {
      context.handle(
        _productoIdMeta,
        productoId.isAcceptableOrUnknown(data['producto_id']!, _productoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_productoIdMeta);
    }
    if (data.containsKey('nombre_producto')) {
      context.handle(
        _nombreProductoMeta,
        nombreProducto.isAcceptableOrUnknown(
          data['nombre_producto']!,
          _nombreProductoMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nombreProductoMeta);
    }
    if (data.containsKey('cantidad')) {
      context.handle(
        _cantidadMeta,
        cantidad.isAcceptableOrUnknown(data['cantidad']!, _cantidadMeta),
      );
    } else if (isInserting) {
      context.missing(_cantidadMeta);
    }
    if (data.containsKey('costo_unitario')) {
      context.handle(
        _costoUnitarioMeta,
        costoUnitario.isAcceptableOrUnknown(
          data['costo_unitario']!,
          _costoUnitarioMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_costoUnitarioMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EntradasDetalleLocalData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EntradasDetalleLocalData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      entradaId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}entrada_id'],
      )!,
      productoId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}producto_id'],
      )!,
      nombreProducto: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}nombre_producto'],
      )!,
      cantidad: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}cantidad'],
      )!,
      costoUnitario: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}costo_unitario'],
      )!,
    );
  }

  @override
  $EntradasDetalleLocalTable createAlias(String alias) {
    return $EntradasDetalleLocalTable(attachedDatabase, alias);
  }
}

class EntradasDetalleLocalData extends DataClass
    implements Insertable<EntradasDetalleLocalData> {
  final int id;
  final int entradaId;
  final int productoId;
  final String nombreProducto;
  final int cantidad;
  final double costoUnitario;
  const EntradasDetalleLocalData({
    required this.id,
    required this.entradaId,
    required this.productoId,
    required this.nombreProducto,
    required this.cantidad,
    required this.costoUnitario,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['entrada_id'] = Variable<int>(entradaId);
    map['producto_id'] = Variable<int>(productoId);
    map['nombre_producto'] = Variable<String>(nombreProducto);
    map['cantidad'] = Variable<int>(cantidad);
    map['costo_unitario'] = Variable<double>(costoUnitario);
    return map;
  }

  EntradasDetalleLocalCompanion toCompanion(bool nullToAbsent) {
    return EntradasDetalleLocalCompanion(
      id: Value(id),
      entradaId: Value(entradaId),
      productoId: Value(productoId),
      nombreProducto: Value(nombreProducto),
      cantidad: Value(cantidad),
      costoUnitario: Value(costoUnitario),
    );
  }

  factory EntradasDetalleLocalData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntradasDetalleLocalData(
      id: serializer.fromJson<int>(json['id']),
      entradaId: serializer.fromJson<int>(json['entradaId']),
      productoId: serializer.fromJson<int>(json['productoId']),
      nombreProducto: serializer.fromJson<String>(json['nombreProducto']),
      cantidad: serializer.fromJson<int>(json['cantidad']),
      costoUnitario: serializer.fromJson<double>(json['costoUnitario']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'entradaId': serializer.toJson<int>(entradaId),
      'productoId': serializer.toJson<int>(productoId),
      'nombreProducto': serializer.toJson<String>(nombreProducto),
      'cantidad': serializer.toJson<int>(cantidad),
      'costoUnitario': serializer.toJson<double>(costoUnitario),
    };
  }

  EntradasDetalleLocalData copyWith({
    int? id,
    int? entradaId,
    int? productoId,
    String? nombreProducto,
    int? cantidad,
    double? costoUnitario,
  }) => EntradasDetalleLocalData(
    id: id ?? this.id,
    entradaId: entradaId ?? this.entradaId,
    productoId: productoId ?? this.productoId,
    nombreProducto: nombreProducto ?? this.nombreProducto,
    cantidad: cantidad ?? this.cantidad,
    costoUnitario: costoUnitario ?? this.costoUnitario,
  );
  EntradasDetalleLocalData copyWithCompanion(
    EntradasDetalleLocalCompanion data,
  ) {
    return EntradasDetalleLocalData(
      id: data.id.present ? data.id.value : this.id,
      entradaId: data.entradaId.present ? data.entradaId.value : this.entradaId,
      productoId: data.productoId.present
          ? data.productoId.value
          : this.productoId,
      nombreProducto: data.nombreProducto.present
          ? data.nombreProducto.value
          : this.nombreProducto,
      cantidad: data.cantidad.present ? data.cantidad.value : this.cantidad,
      costoUnitario: data.costoUnitario.present
          ? data.costoUnitario.value
          : this.costoUnitario,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntradasDetalleLocalData(')
          ..write('id: $id, ')
          ..write('entradaId: $entradaId, ')
          ..write('productoId: $productoId, ')
          ..write('nombreProducto: $nombreProducto, ')
          ..write('cantidad: $cantidad, ')
          ..write('costoUnitario: $costoUnitario')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    entradaId,
    productoId,
    nombreProducto,
    cantidad,
    costoUnitario,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntradasDetalleLocalData &&
          other.id == this.id &&
          other.entradaId == this.entradaId &&
          other.productoId == this.productoId &&
          other.nombreProducto == this.nombreProducto &&
          other.cantidad == this.cantidad &&
          other.costoUnitario == this.costoUnitario);
}

class EntradasDetalleLocalCompanion
    extends UpdateCompanion<EntradasDetalleLocalData> {
  final Value<int> id;
  final Value<int> entradaId;
  final Value<int> productoId;
  final Value<String> nombreProducto;
  final Value<int> cantidad;
  final Value<double> costoUnitario;
  const EntradasDetalleLocalCompanion({
    this.id = const Value.absent(),
    this.entradaId = const Value.absent(),
    this.productoId = const Value.absent(),
    this.nombreProducto = const Value.absent(),
    this.cantidad = const Value.absent(),
    this.costoUnitario = const Value.absent(),
  });
  EntradasDetalleLocalCompanion.insert({
    this.id = const Value.absent(),
    required int entradaId,
    required int productoId,
    required String nombreProducto,
    required int cantidad,
    required double costoUnitario,
  }) : entradaId = Value(entradaId),
       productoId = Value(productoId),
       nombreProducto = Value(nombreProducto),
       cantidad = Value(cantidad),
       costoUnitario = Value(costoUnitario);
  static Insertable<EntradasDetalleLocalData> custom({
    Expression<int>? id,
    Expression<int>? entradaId,
    Expression<int>? productoId,
    Expression<String>? nombreProducto,
    Expression<int>? cantidad,
    Expression<double>? costoUnitario,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (entradaId != null) 'entrada_id': entradaId,
      if (productoId != null) 'producto_id': productoId,
      if (nombreProducto != null) 'nombre_producto': nombreProducto,
      if (cantidad != null) 'cantidad': cantidad,
      if (costoUnitario != null) 'costo_unitario': costoUnitario,
    });
  }

  EntradasDetalleLocalCompanion copyWith({
    Value<int>? id,
    Value<int>? entradaId,
    Value<int>? productoId,
    Value<String>? nombreProducto,
    Value<int>? cantidad,
    Value<double>? costoUnitario,
  }) {
    return EntradasDetalleLocalCompanion(
      id: id ?? this.id,
      entradaId: entradaId ?? this.entradaId,
      productoId: productoId ?? this.productoId,
      nombreProducto: nombreProducto ?? this.nombreProducto,
      cantidad: cantidad ?? this.cantidad,
      costoUnitario: costoUnitario ?? this.costoUnitario,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (entradaId.present) {
      map['entrada_id'] = Variable<int>(entradaId.value);
    }
    if (productoId.present) {
      map['producto_id'] = Variable<int>(productoId.value);
    }
    if (nombreProducto.present) {
      map['nombre_producto'] = Variable<String>(nombreProducto.value);
    }
    if (cantidad.present) {
      map['cantidad'] = Variable<int>(cantidad.value);
    }
    if (costoUnitario.present) {
      map['costo_unitario'] = Variable<double>(costoUnitario.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntradasDetalleLocalCompanion(')
          ..write('id: $id, ')
          ..write('entradaId: $entradaId, ')
          ..write('productoId: $productoId, ')
          ..write('nombreProducto: $nombreProducto, ')
          ..write('cantidad: $cantidad, ')
          ..write('costoUnitario: $costoUnitario')
          ..write(')'))
        .toString();
  }
}

class $SyncMetaTable extends SyncMeta
    with TableInfo<$SyncMetaTable, SyncMetaData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMetaTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_meta';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncMetaData> instance, {
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
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SyncMetaData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncMetaData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $SyncMetaTable createAlias(String alias) {
    return $SyncMetaTable(attachedDatabase, alias);
  }
}

class SyncMetaData extends DataClass implements Insertable<SyncMetaData> {
  final String key;
  final String value;
  final DateTime updatedAt;
  const SyncMetaData({
    required this.key,
    required this.value,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SyncMetaCompanion toCompanion(bool nullToAbsent) {
    return SyncMetaCompanion(
      key: Value(key),
      value: Value(value),
      updatedAt: Value(updatedAt),
    );
  }

  factory SyncMetaData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncMetaData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SyncMetaData copyWith({String? key, String? value, DateTime? updatedAt}) =>
      SyncMetaData(
        key: key ?? this.key,
        value: value ?? this.value,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SyncMetaData copyWithCompanion(SyncMetaCompanion data) {
    return SyncMetaData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncMetaData(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncMetaData &&
          other.key == this.key &&
          other.value == this.value &&
          other.updatedAt == this.updatedAt);
}

class SyncMetaCompanion extends UpdateCompanion<SyncMetaData> {
  final Value<String> key;
  final Value<String> value;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SyncMetaCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMetaCompanion.insert({
    required String key,
    required String value,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value),
       updatedAt = Value(updatedAt);
  static Insertable<SyncMetaData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMetaCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return SyncMetaCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      updatedAt: updatedAt ?? this.updatedAt,
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
    return (StringBuffer('SyncMetaCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductosTable productos = $ProductosTable(this);
  late final $CategoriasTable categorias = $CategoriasTable(this);
  late final $VentasPendientesTable ventasPendientes = $VentasPendientesTable(
    this,
  );
  late final $EntradasPendientesTable entradasPendientes =
      $EntradasPendientesTable(this);
  late final $ProductosPendientesTable productosPendientes =
      $ProductosPendientesTable(this);
  late final $VentasLocalTable ventasLocal = $VentasLocalTable(this);
  late final $VentasDetalleLocalTable ventasDetalleLocal =
      $VentasDetalleLocalTable(this);
  late final $EntradasLocalTable entradasLocal = $EntradasLocalTable(this);
  late final $EntradasDetalleLocalTable entradasDetalleLocal =
      $EntradasDetalleLocalTable(this);
  late final $SyncMetaTable syncMeta = $SyncMetaTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    productos,
    categorias,
    ventasPendientes,
    entradasPendientes,
    productosPendientes,
    ventasLocal,
    ventasDetalleLocal,
    entradasLocal,
    entradasDetalleLocal,
    syncMeta,
  ];
}

typedef $$ProductosTableCreateCompanionBuilder =
    ProductosCompanion Function({
      Value<int> id,
      Value<String?> codigoBarras,
      required String nombre,
      Value<String?> marca,
      Value<String?> descripcion,
      Value<String?> uso,
      required double precioCompra,
      required double precioVenta,
      Value<double?> precioMayoreo,
      required String unidadMedida,
      required int stockActual,
      required int stockMinimo,
      Value<int?> categoriaId,
      Value<String?> ubicacion,
      required bool activo,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$ProductosTableUpdateCompanionBuilder =
    ProductosCompanion Function({
      Value<int> id,
      Value<String?> codigoBarras,
      Value<String> nombre,
      Value<String?> marca,
      Value<String?> descripcion,
      Value<String?> uso,
      Value<double> precioCompra,
      Value<double> precioVenta,
      Value<double?> precioMayoreo,
      Value<String> unidadMedida,
      Value<int> stockActual,
      Value<int> stockMinimo,
      Value<int?> categoriaId,
      Value<String?> ubicacion,
      Value<bool> activo,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$ProductosTableFilterComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableFilterComposer({
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

  ColumnFilters<String> get codigoBarras => $composableBuilder(
    column: $table.codigoBarras,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uso => $composableBuilder(
    column: $table.uso,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioCompra => $composableBuilder(
    column: $table.precioCompra,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioMayoreo => $composableBuilder(
    column: $table.precioMayoreo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get unidadMedida => $composableBuilder(
    column: $table.unidadMedida,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockActual => $composableBuilder(
    column: $table.stockActual,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ubicacion => $composableBuilder(
    column: $table.ubicacion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductosTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableOrderingComposer({
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

  ColumnOrderings<String> get codigoBarras => $composableBuilder(
    column: $table.codigoBarras,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get marca => $composableBuilder(
    column: $table.marca,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uso => $composableBuilder(
    column: $table.uso,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioCompra => $composableBuilder(
    column: $table.precioCompra,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioMayoreo => $composableBuilder(
    column: $table.precioMayoreo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get unidadMedida => $composableBuilder(
    column: $table.unidadMedida,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockActual => $composableBuilder(
    column: $table.stockActual,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ubicacion => $composableBuilder(
    column: $table.ubicacion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductosTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductosTable> {
  $$ProductosTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get codigoBarras => $composableBuilder(
    column: $table.codigoBarras,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get marca =>
      $composableBuilder(column: $table.marca, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uso =>
      $composableBuilder(column: $table.uso, builder: (column) => column);

  GeneratedColumn<double> get precioCompra => $composableBuilder(
    column: $table.precioCompra,
    builder: (column) => column,
  );

  GeneratedColumn<double> get precioVenta => $composableBuilder(
    column: $table.precioVenta,
    builder: (column) => column,
  );

  GeneratedColumn<double> get precioMayoreo => $composableBuilder(
    column: $table.precioMayoreo,
    builder: (column) => column,
  );

  GeneratedColumn<String> get unidadMedida => $composableBuilder(
    column: $table.unidadMedida,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stockActual => $composableBuilder(
    column: $table.stockActual,
    builder: (column) => column,
  );

  GeneratedColumn<int> get stockMinimo => $composableBuilder(
    column: $table.stockMinimo,
    builder: (column) => column,
  );

  GeneratedColumn<int> get categoriaId => $composableBuilder(
    column: $table.categoriaId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get ubicacion =>
      $composableBuilder(column: $table.ubicacion, builder: (column) => column);

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ProductosTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductosTable,
          Producto,
          $$ProductosTableFilterComposer,
          $$ProductosTableOrderingComposer,
          $$ProductosTableAnnotationComposer,
          $$ProductosTableCreateCompanionBuilder,
          $$ProductosTableUpdateCompanionBuilder,
          (Producto, BaseReferences<_$AppDatabase, $ProductosTable, Producto>),
          Producto,
          PrefetchHooks Function()
        > {
  $$ProductosTableTableManager(_$AppDatabase db, $ProductosTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProductosTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> codigoBarras = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> marca = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<String?> uso = const Value.absent(),
                Value<double> precioCompra = const Value.absent(),
                Value<double> precioVenta = const Value.absent(),
                Value<double?> precioMayoreo = const Value.absent(),
                Value<String> unidadMedida = const Value.absent(),
                Value<int> stockActual = const Value.absent(),
                Value<int> stockMinimo = const Value.absent(),
                Value<int?> categoriaId = const Value.absent(),
                Value<String?> ubicacion = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => ProductosCompanion(
                id: id,
                codigoBarras: codigoBarras,
                nombre: nombre,
                marca: marca,
                descripcion: descripcion,
                uso: uso,
                precioCompra: precioCompra,
                precioVenta: precioVenta,
                precioMayoreo: precioMayoreo,
                unidadMedida: unidadMedida,
                stockActual: stockActual,
                stockMinimo: stockMinimo,
                categoriaId: categoriaId,
                ubicacion: ubicacion,
                activo: activo,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> codigoBarras = const Value.absent(),
                required String nombre,
                Value<String?> marca = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<String?> uso = const Value.absent(),
                required double precioCompra,
                required double precioVenta,
                Value<double?> precioMayoreo = const Value.absent(),
                required String unidadMedida,
                required int stockActual,
                required int stockMinimo,
                Value<int?> categoriaId = const Value.absent(),
                Value<String?> ubicacion = const Value.absent(),
                required bool activo,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => ProductosCompanion.insert(
                id: id,
                codigoBarras: codigoBarras,
                nombre: nombre,
                marca: marca,
                descripcion: descripcion,
                uso: uso,
                precioCompra: precioCompra,
                precioVenta: precioVenta,
                precioMayoreo: precioMayoreo,
                unidadMedida: unidadMedida,
                stockActual: stockActual,
                stockMinimo: stockMinimo,
                categoriaId: categoriaId,
                ubicacion: ubicacion,
                activo: activo,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductosTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductosTable,
      Producto,
      $$ProductosTableFilterComposer,
      $$ProductosTableOrderingComposer,
      $$ProductosTableAnnotationComposer,
      $$ProductosTableCreateCompanionBuilder,
      $$ProductosTableUpdateCompanionBuilder,
      (Producto, BaseReferences<_$AppDatabase, $ProductosTable, Producto>),
      Producto,
      PrefetchHooks Function()
    >;
typedef $$CategoriasTableCreateCompanionBuilder =
    CategoriasCompanion Function({
      Value<int> id,
      required String nombre,
      Value<String?> descripcion,
      required bool activo,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$CategoriasTableUpdateCompanionBuilder =
    CategoriasCompanion Function({
      Value<int> id,
      Value<String> nombre,
      Value<String?> descripcion,
      Value<bool> activo,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

class $$CategoriasTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableFilterComposer({
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

  ColumnFilters<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CategoriasTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableOrderingComposer({
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

  ColumnOrderings<String> get nombre => $composableBuilder(
    column: $table.nombre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get activo => $composableBuilder(
    column: $table.activo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CategoriasTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriasTable> {
  $$CategoriasTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get nombre =>
      $composableBuilder(column: $table.nombre, builder: (column) => column);

  GeneratedColumn<String> get descripcion => $composableBuilder(
    column: $table.descripcion,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get activo =>
      $composableBuilder(column: $table.activo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$CategoriasTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CategoriasTable,
          Categoria,
          $$CategoriasTableFilterComposer,
          $$CategoriasTableOrderingComposer,
          $$CategoriasTableAnnotationComposer,
          $$CategoriasTableCreateCompanionBuilder,
          $$CategoriasTableUpdateCompanionBuilder,
          (
            Categoria,
            BaseReferences<_$AppDatabase, $CategoriasTable, Categoria>,
          ),
          Categoria,
          PrefetchHooks Function()
        > {
  $$CategoriasTableTableManager(_$AppDatabase db, $CategoriasTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriasTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriasTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriasTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> nombre = const Value.absent(),
                Value<String?> descripcion = const Value.absent(),
                Value<bool> activo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => CategoriasCompanion(
                id: id,
                nombre: nombre,
                descripcion: descripcion,
                activo: activo,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String nombre,
                Value<String?> descripcion = const Value.absent(),
                required bool activo,
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => CategoriasCompanion.insert(
                id: id,
                nombre: nombre,
                descripcion: descripcion,
                activo: activo,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CategoriasTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CategoriasTable,
      Categoria,
      $$CategoriasTableFilterComposer,
      $$CategoriasTableOrderingComposer,
      $$CategoriasTableAnnotationComposer,
      $$CategoriasTableCreateCompanionBuilder,
      $$CategoriasTableUpdateCompanionBuilder,
      (Categoria, BaseReferences<_$AppDatabase, $CategoriasTable, Categoria>),
      Categoria,
      PrefetchHooks Function()
    >;
typedef $$VentasPendientesTableCreateCompanionBuilder =
    VentasPendientesCompanion Function({
      required String clientId,
      required DateTime createdAt,
      required String ventaData,
      required double total,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$VentasPendientesTableUpdateCompanionBuilder =
    VentasPendientesCompanion Function({
      Value<String> clientId,
      Value<DateTime> createdAt,
      Value<String> ventaData,
      Value<double> total,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$VentasPendientesTableFilterComposer
    extends Composer<_$AppDatabase, $VentasPendientesTable> {
  $$VentasPendientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ventaData => $composableBuilder(
    column: $table.ventaData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VentasPendientesTableOrderingComposer
    extends Composer<_$AppDatabase, $VentasPendientesTable> {
  $$VentasPendientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ventaData => $composableBuilder(
    column: $table.ventaData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VentasPendientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $VentasPendientesTable> {
  $$VentasPendientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get ventaData =>
      $composableBuilder(column: $table.ventaData, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$VentasPendientesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VentasPendientesTable,
          VentasPendiente,
          $$VentasPendientesTableFilterComposer,
          $$VentasPendientesTableOrderingComposer,
          $$VentasPendientesTableAnnotationComposer,
          $$VentasPendientesTableCreateCompanionBuilder,
          $$VentasPendientesTableUpdateCompanionBuilder,
          (
            VentasPendiente,
            BaseReferences<
              _$AppDatabase,
              $VentasPendientesTable,
              VentasPendiente
            >,
          ),
          VentasPendiente,
          PrefetchHooks Function()
        > {
  $$VentasPendientesTableTableManager(
    _$AppDatabase db,
    $VentasPendientesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentasPendientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentasPendientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentasPendientesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> ventaData = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VentasPendientesCompanion(
                clientId: clientId,
                createdAt: createdAt,
                ventaData: ventaData,
                total: total,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                required DateTime createdAt,
                required String ventaData,
                required double total,
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => VentasPendientesCompanion.insert(
                clientId: clientId,
                createdAt: createdAt,
                ventaData: ventaData,
                total: total,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VentasPendientesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VentasPendientesTable,
      VentasPendiente,
      $$VentasPendientesTableFilterComposer,
      $$VentasPendientesTableOrderingComposer,
      $$VentasPendientesTableAnnotationComposer,
      $$VentasPendientesTableCreateCompanionBuilder,
      $$VentasPendientesTableUpdateCompanionBuilder,
      (
        VentasPendiente,
        BaseReferences<_$AppDatabase, $VentasPendientesTable, VentasPendiente>,
      ),
      VentasPendiente,
      PrefetchHooks Function()
    >;
typedef $$EntradasPendientesTableCreateCompanionBuilder =
    EntradasPendientesCompanion Function({
      required String clientId,
      required DateTime createdAt,
      required String entradaData,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$EntradasPendientesTableUpdateCompanionBuilder =
    EntradasPendientesCompanion Function({
      Value<String> clientId,
      Value<DateTime> createdAt,
      Value<String> entradaData,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$EntradasPendientesTableFilterComposer
    extends Composer<_$AppDatabase, $EntradasPendientesTable> {
  $$EntradasPendientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get entradaData => $composableBuilder(
    column: $table.entradaData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntradasPendientesTableOrderingComposer
    extends Composer<_$AppDatabase, $EntradasPendientesTable> {
  $$EntradasPendientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get entradaData => $composableBuilder(
    column: $table.entradaData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntradasPendientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntradasPendientesTable> {
  $$EntradasPendientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get entradaData => $composableBuilder(
    column: $table.entradaData,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$EntradasPendientesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntradasPendientesTable,
          EntradasPendiente,
          $$EntradasPendientesTableFilterComposer,
          $$EntradasPendientesTableOrderingComposer,
          $$EntradasPendientesTableAnnotationComposer,
          $$EntradasPendientesTableCreateCompanionBuilder,
          $$EntradasPendientesTableUpdateCompanionBuilder,
          (
            EntradasPendiente,
            BaseReferences<
              _$AppDatabase,
              $EntradasPendientesTable,
              EntradasPendiente
            >,
          ),
          EntradasPendiente,
          PrefetchHooks Function()
        > {
  $$EntradasPendientesTableTableManager(
    _$AppDatabase db,
    $EntradasPendientesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntradasPendientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntradasPendientesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntradasPendientesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> entradaData = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntradasPendientesCompanion(
                clientId: clientId,
                createdAt: createdAt,
                entradaData: entradaData,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                required DateTime createdAt,
                required String entradaData,
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntradasPendientesCompanion.insert(
                clientId: clientId,
                createdAt: createdAt,
                entradaData: entradaData,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntradasPendientesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntradasPendientesTable,
      EntradasPendiente,
      $$EntradasPendientesTableFilterComposer,
      $$EntradasPendientesTableOrderingComposer,
      $$EntradasPendientesTableAnnotationComposer,
      $$EntradasPendientesTableCreateCompanionBuilder,
      $$EntradasPendientesTableUpdateCompanionBuilder,
      (
        EntradasPendiente,
        BaseReferences<
          _$AppDatabase,
          $EntradasPendientesTable,
          EntradasPendiente
        >,
      ),
      EntradasPendiente,
      PrefetchHooks Function()
    >;
typedef $$ProductosPendientesTableCreateCompanionBuilder =
    ProductosPendientesCompanion Function({
      required String clientId,
      required DateTime createdAt,
      required String productoData,
      Value<bool> synced,
      Value<int> rowid,
    });
typedef $$ProductosPendientesTableUpdateCompanionBuilder =
    ProductosPendientesCompanion Function({
      Value<String> clientId,
      Value<DateTime> createdAt,
      Value<String> productoData,
      Value<bool> synced,
      Value<int> rowid,
    });

class $$ProductosPendientesTableFilterComposer
    extends Composer<_$AppDatabase, $ProductosPendientesTable> {
  $$ProductosPendientesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get productoData => $composableBuilder(
    column: $table.productoData,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProductosPendientesTableOrderingComposer
    extends Composer<_$AppDatabase, $ProductosPendientesTable> {
  $$ProductosPendientesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get productoData => $composableBuilder(
    column: $table.productoData,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProductosPendientesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProductosPendientesTable> {
  $$ProductosPendientesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get productoData => $composableBuilder(
    column: $table.productoData,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$ProductosPendientesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProductosPendientesTable,
          ProductosPendiente,
          $$ProductosPendientesTableFilterComposer,
          $$ProductosPendientesTableOrderingComposer,
          $$ProductosPendientesTableAnnotationComposer,
          $$ProductosPendientesTableCreateCompanionBuilder,
          $$ProductosPendientesTableUpdateCompanionBuilder,
          (
            ProductosPendiente,
            BaseReferences<
              _$AppDatabase,
              $ProductosPendientesTable,
              ProductosPendiente
            >,
          ),
          ProductosPendiente,
          PrefetchHooks Function()
        > {
  $$ProductosPendientesTableTableManager(
    _$AppDatabase db,
    $ProductosPendientesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProductosPendientesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProductosPendientesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ProductosPendientesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> clientId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> productoData = const Value.absent(),
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductosPendientesCompanion(
                clientId: clientId,
                createdAt: createdAt,
                productoData: productoData,
                synced: synced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String clientId,
                required DateTime createdAt,
                required String productoData,
                Value<bool> synced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProductosPendientesCompanion.insert(
                clientId: clientId,
                createdAt: createdAt,
                productoData: productoData,
                synced: synced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProductosPendientesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProductosPendientesTable,
      ProductosPendiente,
      $$ProductosPendientesTableFilterComposer,
      $$ProductosPendientesTableOrderingComposer,
      $$ProductosPendientesTableAnnotationComposer,
      $$ProductosPendientesTableCreateCompanionBuilder,
      $$ProductosPendientesTableUpdateCompanionBuilder,
      (
        ProductosPendiente,
        BaseReferences<
          _$AppDatabase,
          $ProductosPendientesTable,
          ProductosPendiente
        >,
      ),
      ProductosPendiente,
      PrefetchHooks Function()
    >;
typedef $$VentasLocalTableCreateCompanionBuilder =
    VentasLocalCompanion Function({
      Value<int> id,
      Value<String?> folio,
      Value<String?> clientId,
      required DateTime fecha,
      required double subtotal,
      required double iva,
      required double total,
      required String metodoPago,
      Value<double?> montoRecibido,
      Value<double?> cambio,
      Value<bool> synced,
    });
typedef $$VentasLocalTableUpdateCompanionBuilder =
    VentasLocalCompanion Function({
      Value<int> id,
      Value<String?> folio,
      Value<String?> clientId,
      Value<DateTime> fecha,
      Value<double> subtotal,
      Value<double> iva,
      Value<double> total,
      Value<String> metodoPago,
      Value<double?> montoRecibido,
      Value<double?> cambio,
      Value<bool> synced,
    });

class $$VentasLocalTableFilterComposer
    extends Composer<_$AppDatabase, $VentasLocalTable> {
  $$VentasLocalTableFilterComposer({
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

  ColumnFilters<String> get folio => $composableBuilder(
    column: $table.folio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get iva => $composableBuilder(
    column: $table.iva,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get montoRecibido => $composableBuilder(
    column: $table.montoRecibido,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get cambio => $composableBuilder(
    column: $table.cambio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VentasLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $VentasLocalTable> {
  $$VentasLocalTableOrderingComposer({
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

  ColumnOrderings<String> get folio => $composableBuilder(
    column: $table.folio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get iva => $composableBuilder(
    column: $table.iva,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get montoRecibido => $composableBuilder(
    column: $table.montoRecibido,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get cambio => $composableBuilder(
    column: $table.cambio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VentasLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $VentasLocalTable> {
  $$VentasLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get folio =>
      $composableBuilder(column: $table.folio, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);

  GeneratedColumn<double> get iva =>
      $composableBuilder(column: $table.iva, builder: (column) => column);

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<String> get metodoPago => $composableBuilder(
    column: $table.metodoPago,
    builder: (column) => column,
  );

  GeneratedColumn<double> get montoRecibido => $composableBuilder(
    column: $table.montoRecibido,
    builder: (column) => column,
  );

  GeneratedColumn<double> get cambio =>
      $composableBuilder(column: $table.cambio, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$VentasLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VentasLocalTable,
          VentasLocalData,
          $$VentasLocalTableFilterComposer,
          $$VentasLocalTableOrderingComposer,
          $$VentasLocalTableAnnotationComposer,
          $$VentasLocalTableCreateCompanionBuilder,
          $$VentasLocalTableUpdateCompanionBuilder,
          (
            VentasLocalData,
            BaseReferences<_$AppDatabase, $VentasLocalTable, VentasLocalData>,
          ),
          VentasLocalData,
          PrefetchHooks Function()
        > {
  $$VentasLocalTableTableManager(_$AppDatabase db, $VentasLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentasLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentasLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentasLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> folio = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
                Value<double> iva = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<String> metodoPago = const Value.absent(),
                Value<double?> montoRecibido = const Value.absent(),
                Value<double?> cambio = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => VentasLocalCompanion(
                id: id,
                folio: folio,
                clientId: clientId,
                fecha: fecha,
                subtotal: subtotal,
                iva: iva,
                total: total,
                metodoPago: metodoPago,
                montoRecibido: montoRecibido,
                cambio: cambio,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> folio = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                required DateTime fecha,
                required double subtotal,
                required double iva,
                required double total,
                required String metodoPago,
                Value<double?> montoRecibido = const Value.absent(),
                Value<double?> cambio = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => VentasLocalCompanion.insert(
                id: id,
                folio: folio,
                clientId: clientId,
                fecha: fecha,
                subtotal: subtotal,
                iva: iva,
                total: total,
                metodoPago: metodoPago,
                montoRecibido: montoRecibido,
                cambio: cambio,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VentasLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VentasLocalTable,
      VentasLocalData,
      $$VentasLocalTableFilterComposer,
      $$VentasLocalTableOrderingComposer,
      $$VentasLocalTableAnnotationComposer,
      $$VentasLocalTableCreateCompanionBuilder,
      $$VentasLocalTableUpdateCompanionBuilder,
      (
        VentasLocalData,
        BaseReferences<_$AppDatabase, $VentasLocalTable, VentasLocalData>,
      ),
      VentasLocalData,
      PrefetchHooks Function()
    >;
typedef $$VentasDetalleLocalTableCreateCompanionBuilder =
    VentasDetalleLocalCompanion Function({
      Value<int> id,
      required int ventaId,
      required int productoId,
      required String nombreProducto,
      required double precioUnitario,
      required int cantidad,
      required double subtotal,
    });
typedef $$VentasDetalleLocalTableUpdateCompanionBuilder =
    VentasDetalleLocalCompanion Function({
      Value<int> id,
      Value<int> ventaId,
      Value<int> productoId,
      Value<String> nombreProducto,
      Value<double> precioUnitario,
      Value<int> cantidad,
      Value<double> subtotal,
    });

class $$VentasDetalleLocalTableFilterComposer
    extends Composer<_$AppDatabase, $VentasDetalleLocalTable> {
  $$VentasDetalleLocalTableFilterComposer({
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

  ColumnFilters<int> get ventaId => $composableBuilder(
    column: $table.ventaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$VentasDetalleLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $VentasDetalleLocalTable> {
  $$VentasDetalleLocalTableOrderingComposer({
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

  ColumnOrderings<int> get ventaId => $composableBuilder(
    column: $table.ventaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get subtotal => $composableBuilder(
    column: $table.subtotal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$VentasDetalleLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $VentasDetalleLocalTable> {
  $$VentasDetalleLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get ventaId =>
      $composableBuilder(column: $table.ventaId, builder: (column) => column);

  GeneratedColumn<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => column,
  );

  GeneratedColumn<double> get precioUnitario => $composableBuilder(
    column: $table.precioUnitario,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<double> get subtotal =>
      $composableBuilder(column: $table.subtotal, builder: (column) => column);
}

class $$VentasDetalleLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $VentasDetalleLocalTable,
          VentasDetalleLocalData,
          $$VentasDetalleLocalTableFilterComposer,
          $$VentasDetalleLocalTableOrderingComposer,
          $$VentasDetalleLocalTableAnnotationComposer,
          $$VentasDetalleLocalTableCreateCompanionBuilder,
          $$VentasDetalleLocalTableUpdateCompanionBuilder,
          (
            VentasDetalleLocalData,
            BaseReferences<
              _$AppDatabase,
              $VentasDetalleLocalTable,
              VentasDetalleLocalData
            >,
          ),
          VentasDetalleLocalData,
          PrefetchHooks Function()
        > {
  $$VentasDetalleLocalTableTableManager(
    _$AppDatabase db,
    $VentasDetalleLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$VentasDetalleLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$VentasDetalleLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$VentasDetalleLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> ventaId = const Value.absent(),
                Value<int> productoId = const Value.absent(),
                Value<String> nombreProducto = const Value.absent(),
                Value<double> precioUnitario = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<double> subtotal = const Value.absent(),
              }) => VentasDetalleLocalCompanion(
                id: id,
                ventaId: ventaId,
                productoId: productoId,
                nombreProducto: nombreProducto,
                precioUnitario: precioUnitario,
                cantidad: cantidad,
                subtotal: subtotal,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int ventaId,
                required int productoId,
                required String nombreProducto,
                required double precioUnitario,
                required int cantidad,
                required double subtotal,
              }) => VentasDetalleLocalCompanion.insert(
                id: id,
                ventaId: ventaId,
                productoId: productoId,
                nombreProducto: nombreProducto,
                precioUnitario: precioUnitario,
                cantidad: cantidad,
                subtotal: subtotal,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$VentasDetalleLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $VentasDetalleLocalTable,
      VentasDetalleLocalData,
      $$VentasDetalleLocalTableFilterComposer,
      $$VentasDetalleLocalTableOrderingComposer,
      $$VentasDetalleLocalTableAnnotationComposer,
      $$VentasDetalleLocalTableCreateCompanionBuilder,
      $$VentasDetalleLocalTableUpdateCompanionBuilder,
      (
        VentasDetalleLocalData,
        BaseReferences<
          _$AppDatabase,
          $VentasDetalleLocalTable,
          VentasDetalleLocalData
        >,
      ),
      VentasDetalleLocalData,
      PrefetchHooks Function()
    >;
typedef $$EntradasLocalTableCreateCompanionBuilder =
    EntradasLocalCompanion Function({
      Value<int> id,
      Value<String?> folio,
      Value<String?> proveedor,
      Value<String?> observaciones,
      required double total,
      required DateTime fecha,
      Value<String?> clientId,
      Value<bool> synced,
    });
typedef $$EntradasLocalTableUpdateCompanionBuilder =
    EntradasLocalCompanion Function({
      Value<int> id,
      Value<String?> folio,
      Value<String?> proveedor,
      Value<String?> observaciones,
      Value<double> total,
      Value<DateTime> fecha,
      Value<String?> clientId,
      Value<bool> synced,
    });

class $$EntradasLocalTableFilterComposer
    extends Composer<_$AppDatabase, $EntradasLocalTable> {
  $$EntradasLocalTableFilterComposer({
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

  ColumnFilters<String> get folio => $composableBuilder(
    column: $table.folio,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get proveedor => $composableBuilder(
    column: $table.proveedor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntradasLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $EntradasLocalTable> {
  $$EntradasLocalTableOrderingComposer({
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

  ColumnOrderings<String> get folio => $composableBuilder(
    column: $table.folio,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get proveedor => $composableBuilder(
    column: $table.proveedor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get total => $composableBuilder(
    column: $table.total,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fecha => $composableBuilder(
    column: $table.fecha,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get clientId => $composableBuilder(
    column: $table.clientId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get synced => $composableBuilder(
    column: $table.synced,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntradasLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntradasLocalTable> {
  $$EntradasLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get folio =>
      $composableBuilder(column: $table.folio, builder: (column) => column);

  GeneratedColumn<String> get proveedor =>
      $composableBuilder(column: $table.proveedor, builder: (column) => column);

  GeneratedColumn<String> get observaciones => $composableBuilder(
    column: $table.observaciones,
    builder: (column) => column,
  );

  GeneratedColumn<double> get total =>
      $composableBuilder(column: $table.total, builder: (column) => column);

  GeneratedColumn<DateTime> get fecha =>
      $composableBuilder(column: $table.fecha, builder: (column) => column);

  GeneratedColumn<String> get clientId =>
      $composableBuilder(column: $table.clientId, builder: (column) => column);

  GeneratedColumn<bool> get synced =>
      $composableBuilder(column: $table.synced, builder: (column) => column);
}

class $$EntradasLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntradasLocalTable,
          EntradasLocalData,
          $$EntradasLocalTableFilterComposer,
          $$EntradasLocalTableOrderingComposer,
          $$EntradasLocalTableAnnotationComposer,
          $$EntradasLocalTableCreateCompanionBuilder,
          $$EntradasLocalTableUpdateCompanionBuilder,
          (
            EntradasLocalData,
            BaseReferences<
              _$AppDatabase,
              $EntradasLocalTable,
              EntradasLocalData
            >,
          ),
          EntradasLocalData,
          PrefetchHooks Function()
        > {
  $$EntradasLocalTableTableManager(_$AppDatabase db, $EntradasLocalTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntradasLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntradasLocalTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntradasLocalTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> folio = const Value.absent(),
                Value<String?> proveedor = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
                Value<double> total = const Value.absent(),
                Value<DateTime> fecha = const Value.absent(),
                Value<String?> clientId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => EntradasLocalCompanion(
                id: id,
                folio: folio,
                proveedor: proveedor,
                observaciones: observaciones,
                total: total,
                fecha: fecha,
                clientId: clientId,
                synced: synced,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> folio = const Value.absent(),
                Value<String?> proveedor = const Value.absent(),
                Value<String?> observaciones = const Value.absent(),
                required double total,
                required DateTime fecha,
                Value<String?> clientId = const Value.absent(),
                Value<bool> synced = const Value.absent(),
              }) => EntradasLocalCompanion.insert(
                id: id,
                folio: folio,
                proveedor: proveedor,
                observaciones: observaciones,
                total: total,
                fecha: fecha,
                clientId: clientId,
                synced: synced,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntradasLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntradasLocalTable,
      EntradasLocalData,
      $$EntradasLocalTableFilterComposer,
      $$EntradasLocalTableOrderingComposer,
      $$EntradasLocalTableAnnotationComposer,
      $$EntradasLocalTableCreateCompanionBuilder,
      $$EntradasLocalTableUpdateCompanionBuilder,
      (
        EntradasLocalData,
        BaseReferences<_$AppDatabase, $EntradasLocalTable, EntradasLocalData>,
      ),
      EntradasLocalData,
      PrefetchHooks Function()
    >;
typedef $$EntradasDetalleLocalTableCreateCompanionBuilder =
    EntradasDetalleLocalCompanion Function({
      Value<int> id,
      required int entradaId,
      required int productoId,
      required String nombreProducto,
      required int cantidad,
      required double costoUnitario,
    });
typedef $$EntradasDetalleLocalTableUpdateCompanionBuilder =
    EntradasDetalleLocalCompanion Function({
      Value<int> id,
      Value<int> entradaId,
      Value<int> productoId,
      Value<String> nombreProducto,
      Value<int> cantidad,
      Value<double> costoUnitario,
    });

class $$EntradasDetalleLocalTableFilterComposer
    extends Composer<_$AppDatabase, $EntradasDetalleLocalTable> {
  $$EntradasDetalleLocalTableFilterComposer({
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

  ColumnFilters<int> get entradaId => $composableBuilder(
    column: $table.entradaId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntradasDetalleLocalTableOrderingComposer
    extends Composer<_$AppDatabase, $EntradasDetalleLocalTable> {
  $$EntradasDetalleLocalTableOrderingComposer({
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

  ColumnOrderings<int> get entradaId => $composableBuilder(
    column: $table.entradaId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get cantidad => $composableBuilder(
    column: $table.cantidad,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntradasDetalleLocalTableAnnotationComposer
    extends Composer<_$AppDatabase, $EntradasDetalleLocalTable> {
  $$EntradasDetalleLocalTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get entradaId =>
      $composableBuilder(column: $table.entradaId, builder: (column) => column);

  GeneratedColumn<int> get productoId => $composableBuilder(
    column: $table.productoId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get nombreProducto => $composableBuilder(
    column: $table.nombreProducto,
    builder: (column) => column,
  );

  GeneratedColumn<int> get cantidad =>
      $composableBuilder(column: $table.cantidad, builder: (column) => column);

  GeneratedColumn<double> get costoUnitario => $composableBuilder(
    column: $table.costoUnitario,
    builder: (column) => column,
  );
}

class $$EntradasDetalleLocalTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EntradasDetalleLocalTable,
          EntradasDetalleLocalData,
          $$EntradasDetalleLocalTableFilterComposer,
          $$EntradasDetalleLocalTableOrderingComposer,
          $$EntradasDetalleLocalTableAnnotationComposer,
          $$EntradasDetalleLocalTableCreateCompanionBuilder,
          $$EntradasDetalleLocalTableUpdateCompanionBuilder,
          (
            EntradasDetalleLocalData,
            BaseReferences<
              _$AppDatabase,
              $EntradasDetalleLocalTable,
              EntradasDetalleLocalData
            >,
          ),
          EntradasDetalleLocalData,
          PrefetchHooks Function()
        > {
  $$EntradasDetalleLocalTableTableManager(
    _$AppDatabase db,
    $EntradasDetalleLocalTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntradasDetalleLocalTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntradasDetalleLocalTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$EntradasDetalleLocalTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> entradaId = const Value.absent(),
                Value<int> productoId = const Value.absent(),
                Value<String> nombreProducto = const Value.absent(),
                Value<int> cantidad = const Value.absent(),
                Value<double> costoUnitario = const Value.absent(),
              }) => EntradasDetalleLocalCompanion(
                id: id,
                entradaId: entradaId,
                productoId: productoId,
                nombreProducto: nombreProducto,
                cantidad: cantidad,
                costoUnitario: costoUnitario,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int entradaId,
                required int productoId,
                required String nombreProducto,
                required int cantidad,
                required double costoUnitario,
              }) => EntradasDetalleLocalCompanion.insert(
                id: id,
                entradaId: entradaId,
                productoId: productoId,
                nombreProducto: nombreProducto,
                cantidad: cantidad,
                costoUnitario: costoUnitario,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntradasDetalleLocalTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EntradasDetalleLocalTable,
      EntradasDetalleLocalData,
      $$EntradasDetalleLocalTableFilterComposer,
      $$EntradasDetalleLocalTableOrderingComposer,
      $$EntradasDetalleLocalTableAnnotationComposer,
      $$EntradasDetalleLocalTableCreateCompanionBuilder,
      $$EntradasDetalleLocalTableUpdateCompanionBuilder,
      (
        EntradasDetalleLocalData,
        BaseReferences<
          _$AppDatabase,
          $EntradasDetalleLocalTable,
          EntradasDetalleLocalData
        >,
      ),
      EntradasDetalleLocalData,
      PrefetchHooks Function()
    >;
typedef $$SyncMetaTableCreateCompanionBuilder =
    SyncMetaCompanion Function({
      required String key,
      required String value,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$SyncMetaTableUpdateCompanionBuilder =
    SyncMetaCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$SyncMetaTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableFilterComposer({
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

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMetaTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableOrderingComposer({
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

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMetaTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMetaTable> {
  $$SyncMetaTableAnnotationComposer({
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

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$SyncMetaTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMetaTable,
          SyncMetaData,
          $$SyncMetaTableFilterComposer,
          $$SyncMetaTableOrderingComposer,
          $$SyncMetaTableAnnotationComposer,
          $$SyncMetaTableCreateCompanionBuilder,
          $$SyncMetaTableUpdateCompanionBuilder,
          (
            SyncMetaData,
            BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>,
          ),
          SyncMetaData,
          PrefetchHooks Function()
        > {
  $$SyncMetaTableTableManager(_$AppDatabase db, $SyncMetaTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMetaTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMetaTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMetaTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion(
                key: key,
                value: value,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => SyncMetaCompanion.insert(
                key: key,
                value: value,
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

typedef $$SyncMetaTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMetaTable,
      SyncMetaData,
      $$SyncMetaTableFilterComposer,
      $$SyncMetaTableOrderingComposer,
      $$SyncMetaTableAnnotationComposer,
      $$SyncMetaTableCreateCompanionBuilder,
      $$SyncMetaTableUpdateCompanionBuilder,
      (
        SyncMetaData,
        BaseReferences<_$AppDatabase, $SyncMetaTable, SyncMetaData>,
      ),
      SyncMetaData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductosTableTableManager get productos =>
      $$ProductosTableTableManager(_db, _db.productos);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db, _db.categorias);
  $$VentasPendientesTableTableManager get ventasPendientes =>
      $$VentasPendientesTableTableManager(_db, _db.ventasPendientes);
  $$EntradasPendientesTableTableManager get entradasPendientes =>
      $$EntradasPendientesTableTableManager(_db, _db.entradasPendientes);
  $$ProductosPendientesTableTableManager get productosPendientes =>
      $$ProductosPendientesTableTableManager(_db, _db.productosPendientes);
  $$VentasLocalTableTableManager get ventasLocal =>
      $$VentasLocalTableTableManager(_db, _db.ventasLocal);
  $$VentasDetalleLocalTableTableManager get ventasDetalleLocal =>
      $$VentasDetalleLocalTableTableManager(_db, _db.ventasDetalleLocal);
  $$EntradasLocalTableTableManager get entradasLocal =>
      $$EntradasLocalTableTableManager(_db, _db.entradasLocal);
  $$EntradasDetalleLocalTableTableManager get entradasDetalleLocal =>
      $$EntradasDetalleLocalTableTableManager(_db, _db.entradasDetalleLocal);
  $$SyncMetaTableTableManager get syncMeta =>
      $$SyncMetaTableTableManager(_db, _db.syncMeta);
}
