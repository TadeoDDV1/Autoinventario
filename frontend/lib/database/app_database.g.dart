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
  static const VerificationMeta _skuMeta = const VerificationMeta('sku');
  @override
  late final GeneratedColumn<String> sku = GeneratedColumn<String>(
    'sku',
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
  static const VerificationMeta _categoriaNombreMeta = const VerificationMeta(
    'categoriaNombre',
  );
  @override
  late final GeneratedColumn<String> categoriaNombre = GeneratedColumn<String>(
    'categoria_nombre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    codigoBarras,
    sku,
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
    categoriaNombre,
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
    if (data.containsKey('sku')) {
      context.handle(
        _skuMeta,
        sku.isAcceptableOrUnknown(data['sku']!, _skuMeta),
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
    if (data.containsKey('categoria_nombre')) {
      context.handle(
        _categoriaNombreMeta,
        categoriaNombre.isAcceptableOrUnknown(
          data['categoria_nombre']!,
          _categoriaNombreMeta,
        ),
      );
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
      sku: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}sku'],
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
      categoriaNombre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categoria_nombre'],
      ),
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
  final String? sku;
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
  final String? categoriaNombre;
  const Producto({
    required this.id,
    this.codigoBarras,
    this.sku,
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
    this.categoriaNombre,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || codigoBarras != null) {
      map['codigo_barras'] = Variable<String>(codigoBarras);
    }
    if (!nullToAbsent || sku != null) {
      map['sku'] = Variable<String>(sku);
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
    if (!nullToAbsent || categoriaNombre != null) {
      map['categoria_nombre'] = Variable<String>(categoriaNombre);
    }
    return map;
  }

  ProductosCompanion toCompanion(bool nullToAbsent) {
    return ProductosCompanion(
      id: Value(id),
      codigoBarras: codigoBarras == null && nullToAbsent
          ? const Value.absent()
          : Value(codigoBarras),
      sku: sku == null && nullToAbsent ? const Value.absent() : Value(sku),
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
      categoriaNombre: categoriaNombre == null && nullToAbsent
          ? const Value.absent()
          : Value(categoriaNombre),
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
      sku: serializer.fromJson<String?>(json['sku']),
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
      categoriaNombre: serializer.fromJson<String?>(json['categoriaNombre']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'codigoBarras': serializer.toJson<String?>(codigoBarras),
      'sku': serializer.toJson<String?>(sku),
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
      'categoriaNombre': serializer.toJson<String?>(categoriaNombre),
    };
  }

  Producto copyWith({
    int? id,
    Value<String?> codigoBarras = const Value.absent(),
    Value<String?> sku = const Value.absent(),
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
    Value<String?> categoriaNombre = const Value.absent(),
  }) => Producto(
    id: id ?? this.id,
    codigoBarras: codigoBarras.present ? codigoBarras.value : this.codigoBarras,
    sku: sku.present ? sku.value : this.sku,
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
    categoriaNombre: categoriaNombre.present
        ? categoriaNombre.value
        : this.categoriaNombre,
  );
  Producto copyWithCompanion(ProductosCompanion data) {
    return Producto(
      id: data.id.present ? data.id.value : this.id,
      codigoBarras: data.codigoBarras.present
          ? data.codigoBarras.value
          : this.codigoBarras,
      sku: data.sku.present ? data.sku.value : this.sku,
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
      categoriaNombre: data.categoriaNombre.present
          ? data.categoriaNombre.value
          : this.categoriaNombre,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Producto(')
          ..write('id: $id, ')
          ..write('codigoBarras: $codigoBarras, ')
          ..write('sku: $sku, ')
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
          ..write('updatedAt: $updatedAt, ')
          ..write('categoriaNombre: $categoriaNombre')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    codigoBarras,
    sku,
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
    categoriaNombre,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Producto &&
          other.id == this.id &&
          other.codigoBarras == this.codigoBarras &&
          other.sku == this.sku &&
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
          other.updatedAt == this.updatedAt &&
          other.categoriaNombre == this.categoriaNombre);
}

class ProductosCompanion extends UpdateCompanion<Producto> {
  final Value<int> id;
  final Value<String?> codigoBarras;
  final Value<String?> sku;
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
  final Value<String?> categoriaNombre;
  const ProductosCompanion({
    this.id = const Value.absent(),
    this.codigoBarras = const Value.absent(),
    this.sku = const Value.absent(),
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
    this.categoriaNombre = const Value.absent(),
  });
  ProductosCompanion.insert({
    this.id = const Value.absent(),
    this.codigoBarras = const Value.absent(),
    this.sku = const Value.absent(),
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
    this.categoriaNombre = const Value.absent(),
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
    Expression<String>? sku,
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
    Expression<String>? categoriaNombre,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (codigoBarras != null) 'codigo_barras': codigoBarras,
      if (sku != null) 'sku': sku,
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
      if (categoriaNombre != null) 'categoria_nombre': categoriaNombre,
    });
  }

  ProductosCompanion copyWith({
    Value<int>? id,
    Value<String?>? codigoBarras,
    Value<String?>? sku,
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
    Value<String?>? categoriaNombre,
  }) {
    return ProductosCompanion(
      id: id ?? this.id,
      codigoBarras: codigoBarras ?? this.codigoBarras,
      sku: sku ?? this.sku,
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
      categoriaNombre: categoriaNombre ?? this.categoriaNombre,
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
    if (sku.present) {
      map['sku'] = Variable<String>(sku.value);
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
    if (categoriaNombre.present) {
      map['categoria_nombre'] = Variable<String>(categoriaNombre.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProductosCompanion(')
          ..write('id: $id, ')
          ..write('codigoBarras: $codigoBarras, ')
          ..write('sku: $sku, ')
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
          ..write('updatedAt: $updatedAt, ')
          ..write('categoriaNombre: $categoriaNombre')
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
    $customConstraints: 'UNIQUE',
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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProductosTable productos = $ProductosTable(this);
  late final $CategoriasTable categorias = $CategoriasTable(this);
  late final $VentasPendientesTable ventasPendientes = $VentasPendientesTable(
    this,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    productos,
    categorias,
    ventasPendientes,
  ];
}

typedef $$ProductosTableCreateCompanionBuilder =
    ProductosCompanion Function({
      Value<int> id,
      Value<String?> codigoBarras,
      Value<String?> sku,
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
      Value<String?> categoriaNombre,
    });
typedef $$ProductosTableUpdateCompanionBuilder =
    ProductosCompanion Function({
      Value<int> id,
      Value<String?> codigoBarras,
      Value<String?> sku,
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
      Value<String?> categoriaNombre,
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

  ColumnFilters<String> get sku => $composableBuilder(
    column: $table.sku,
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

  ColumnFilters<String> get categoriaNombre => $composableBuilder(
    column: $table.categoriaNombre,
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

  ColumnOrderings<String> get sku => $composableBuilder(
    column: $table.sku,
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

  ColumnOrderings<String> get categoriaNombre => $composableBuilder(
    column: $table.categoriaNombre,
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

  GeneratedColumn<String> get sku =>
      $composableBuilder(column: $table.sku, builder: (column) => column);

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

  GeneratedColumn<String> get categoriaNombre => $composableBuilder(
    column: $table.categoriaNombre,
    builder: (column) => column,
  );
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
                Value<String?> sku = const Value.absent(),
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
                Value<String?> categoriaNombre = const Value.absent(),
              }) => ProductosCompanion(
                id: id,
                codigoBarras: codigoBarras,
                sku: sku,
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
                categoriaNombre: categoriaNombre,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String?> codigoBarras = const Value.absent(),
                Value<String?> sku = const Value.absent(),
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
                Value<String?> categoriaNombre = const Value.absent(),
              }) => ProductosCompanion.insert(
                id: id,
                codigoBarras: codigoBarras,
                sku: sku,
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
                categoriaNombre: categoriaNombre,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProductosTableTableManager get productos =>
      $$ProductosTableTableManager(_db, _db.productos);
  $$CategoriasTableTableManager get categorias =>
      $$CategoriasTableTableManager(_db, _db.categorias);
  $$VentasPendientesTableTableManager get ventasPendientes =>
      $$VentasPendientesTableTableManager(_db, _db.ventasPendientes);
}
