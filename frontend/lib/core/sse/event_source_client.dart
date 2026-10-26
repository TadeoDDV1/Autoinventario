export 'event_source_client_stub.dart'
    if (dart.library.io) 'event_source_client_io.dart'
    if (dart.library.js_interop) 'event_source_client_web.dart';
