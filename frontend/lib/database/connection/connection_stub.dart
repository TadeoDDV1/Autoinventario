import 'package:drift/drift.dart';

QueryExecutor openConnection() =>
    throw UnsupportedError('Plataforma sin implementación de base de datos');

QueryExecutor createTestConnection() =>
    throw UnsupportedError('AppDatabase.test() no está disponible');
