import 'package:sqlite3_flutter_libs/sqlite3_flutter_libs.dart';

Future<void> applySqliteWorkaround() =>
    applyWorkaroundToOpenSqlite3OnOldAndroidVersions();
