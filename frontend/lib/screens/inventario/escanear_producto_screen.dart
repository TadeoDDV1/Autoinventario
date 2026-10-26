import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../core/format/money.dart';
import '../../core/navigation/nav_helpers.dart';
import '../../core/theme/glass_tokens.dart';
import '../../core/widgets/atmospheric_background.dart';
import '../../core/widgets/glass_container.dart';
import '../../database/database_provider.dart';
import '../../providers/producto_provider.dart';
import '../../services/chat_ejecutivo_service.dart' show ChatEjecutivoService, SugerenciaProducto;

/// Pantalla de "Escanear y Registrar" producto nuevo.
///
/// Flujo:
///  1) Escaneo con cámara (móvil) o input de pistola HID (desktop)
///  2) Llama a /productos/escanear. Si existe → redirige a editar.
///     Si no existe → va a pantalla de autocompletado.
///  3) Form de registro con sugerencias automáticas (categoría, precio,
///     descripción) desde la base de conocimiento.
///
/// La pantalla usa un solo State que alterna entre los pasos vía `_step`.
class EscanearProductoScreen extends ConsumerStatefulWidget {
  const EscanearProductoScreen({super.key});

  @override
  ConsumerState<EscanearProductoScreen> createState() => _EscanearProductoScreenState();
}

enum _Step { escanear, autocompletar, confirmar, exito }

class _EscanearProductoScreenState extends ConsumerState<EscanearProductoScreen> {
  _Step _step = _Step.escanear;
  String? _codigoEscaneado;
  bool _procesando = false;
  bool _sugerenciasCargadas = false;

  // Form data
  final _formKey = GlobalKey<FormState>();
  final _codigoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _precioCompraController = TextEditingController();
  final _precioVentaController = TextEditingController();
  final _stockController = TextEditingController();
  final _stockMinimoController = TextEditingController(text: '5');
  final _descripcionController = TextEditingController();
  int? _categoriaId;
  SugerenciaProducto? _sugerencia;
  int? _productoCreadoId;
  String? _productoCreadoNombre;

  // Scanner
  late final MobileScannerController _scannerController;
  bool _scannerDisposed = false;

  bool get _esMovil {
    if (kIsWeb) return false;
    return defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS;
  }

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
    _codigoController.addListener(_onCodigoChanged);
    // Solicitar permiso de cámara en runtime (Android 6+).
    // En desktop (Linux/Windows/macOS) la cámara no se usa; el flujo va por pistola HID.
    if (_esMovil) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _solicitarPermisoCamara();
      });
    }
  }

  /// Pide el permiso de CAMERA en runtime. Si el usuario lo rechaza permanentemente
  /// muestra un diálogo con un botón para abrir los ajustes del sistema.
  Future<void> _solicitarPermisoCamara() async {
    if (!mounted) return;
    final status = await Permission.camera.request();
    if (!mounted) return;
    if (status.isPermanentlyDenied) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          icon: const Icon(Icons.no_photography_outlined, size: 48),
          title: const Text('Cámara bloqueada'),
          content: const Text(
            'Has bloqueado el permiso de cámara para esta app. '
            'Para escanear productos por código de barras, abre los '
            'ajustes del sistema y habilita el permiso de cámara.\n\n'
            'También puedes escribir el código manualmente abajo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              onPressed: () {
                Navigator.of(ctx).pop();
                openAppSettings();
              },
              icon: const Icon(Icons.settings),
              label: const Text('Abrir ajustes'),
            ),
          ],
        ),
      );
    }
    // Si está denied (no permanente) lo dejamos: el MobileScanner mostrará
    // su errorBuilder con mensaje y el input manual sigue funcionando.
  }

  @override
  void dispose() {
    _scannerDisposed = true;
    try {
      _scannerController.stop();
    } catch (_) {
      // El scanner pudo no haberse inicializado aún
    }
    _scannerController.dispose();
    _codigoController.dispose();
    _nombreController.dispose();
    _precioCompraController.dispose();
    _precioVentaController.dispose();
    _stockController.dispose();
    _stockMinimoController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  /// Listener para pistola HID: detecta cuando llega un Enter (código completo).
  void _onCodigoChanged() {
    // La pistola HID envía caracteres rápido + Enter.
    // Aquí solo guardamos; el botón "Buscar" procesa.
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scannerDisposed || _procesando) return;
    final value = capture.barcodes.firstOrNull?.rawValue;
    if (value == null || value.isEmpty) return;
    setState(() => _procesando = true);
    // Feedback háptico: vibración breve al detectar código (solo móvil).
    HapticFeedback.lightImpact();
    try {
      _scannerController.stop();
    } catch (_) {
      // El scanner pudo no haberse inicializado aún
    }
    _codigoController.text = value;
    _procesarCodigo(value);
  }

  Future<void> _procesarCodigo(String codigo) async {
    if (codigo.trim().isEmpty) return;
    setState(() {
      _procesando = true;
      _codigoEscaneado = codigo.trim();
    });
    try {
      // Offline-first: buscar en la BD local (fuente de verdad). El
      // catálogo local se mantiene al día con el botón Sincronizar.
      final db = ref.read(appDatabaseProvider);
      final local = await db.getProductoByCodigo(codigo.trim());
      if (!mounted) return;

      if (local != null) {
        // Ya existe: ir a editar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('"${local.nombre}" ya está registrado'),
            backgroundColor: Colors.orange.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
        // Reemplazamos escanear por editar: al guardar, "atrás" vuelve a
        // inventario y no al escáner que ya cumplió su función.
        replaceWith(context, '/inventario/editar/${local.id}');
        return;
      }
      // No existe: pasar a autocompletado
      setState(() {
        _step = _Step.autocompletar;
        _procesando = false;
      });
      _cargarSugerencias(codigo.trim());
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al verificar: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _cargarSugerencias(String codigo) async {
    setState(() => _sugerenciasCargadas = false);
    // Primero intentar con la IA (mejor calidad)
    final chat = ChatEjecutivoService();
    SugerenciaProducto? sug = await chat.sugerirProducto(_nombreController.text.isNotEmpty
        ? _nombreController.text
        : 'producto código $codigo');
    if (sug != null && mounted) {
      setState(() {
        _sugerencia = sug;
        _sugerenciasCargadas = true;
        if (sug.categoriaId != null) _categoriaId = sug.categoriaId;
        if (sug.descripcion.isNotEmpty && _descripcionController.text.isEmpty) {
          _descripcionController.text = sug.descripcion;
        }
        // Sugerir precio si está vacío
        if (sug.precioPromedio > 0 && _precioVentaController.text.isEmpty) {
          _precioVentaController.text = sug.precioPromedio.toStringAsFixed(2);
        }
      });
    } else {
      if (mounted) setState(() => _sugerenciasCargadas = true);
    }
  }

  Future<void> _confirmarRegistro() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _procesando = true);
    try {
      final data = <String, dynamic>{
        'codigo_barras': _codigoEscaneado,
        'nombre': _nombreController.text.trim(),
        'precio_compra': double.tryParse(_precioCompraController.text) ?? 0,
        'precio_venta': double.tryParse(_precioVentaController.text) ?? 0,
        'stock_actual': int.tryParse(_stockController.text) ?? 0,
        'stock_minimo': int.tryParse(_stockMinimoController.text) ?? 5,
      };
      if (_descripcionController.text.trim().isNotEmpty) {
        data['descripcion'] = _descripcionController.text.trim();
      }
      if (_categoriaId != null) {
        data['categoria_id'] = _categoriaId;
      }
      final creado = await ref.read(productosProvider.notifier).createProducto(data);
      if (!mounted) return;
      setState(() {
        _productoCreadoId = creado.id;
        _productoCreadoNombre = _nombreController.text.trim();
        _step = _Step.exito;
        _procesando = false;
      });
      ref.invalidate(productosProvider);
    } catch (e) {
      if (!mounted) return;
      setState(() => _procesando = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al registrar: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _registrarOtro() {
    setState(() {
      _step = _Step.escanear;
      _codigoEscaneado = null;
      _codigoController.clear();
      _nombreController.clear();
      _precioCompraController.clear();
      _precioVentaController.clear();
      _stockController.clear();
      _descripcionController.clear();
      _categoriaId = null;
      _sugerencia = null;
      _productoCreadoId = null;
      _productoCreadoNombre = null;
      _procesando = false;
    });
    try {
      _scannerController.start();
    } catch (_) {
      // El scanner pudo no haberse inicializado aún
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Escanear producto nuevo'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => popOrGo(context, '/inventario'),
        ),
      ),
      body: Stack(
        children: [
          const AtmosphericBackground(),
          switch (_step) {
            _Step.escanear => _buildEscanearStep(),
            _Step.autocompletar => _buildAutocompletarStep(),
            _Step.exito => _buildExitoStep(),
            _Step.confirmar => _buildAutocompletarStep(),
          },
        ],
      ),
    );
  }

  // ── Paso 1: Escanear ──

  Widget _buildEscanearStep() {
    return Column(
      children: [
        if (_esMovil)
          Expanded(
            child: Stack(
              children: [
                MobileScanner(
                  controller: _scannerController,
                  onDetect: _onDetect,
                  errorBuilder: (ctx, error, child) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.no_photography, size: 64, color: Colors.grey),
                            const SizedBox(height: 12),
                            Text('Cámara no disponible: ${error.errorCode.name}'),
                            const SizedBox(height: 8),
                            const Text(
                              'Usa el campo de código manual o la pistola HID',
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                if (_procesando) const Center(child: CircularProgressIndicator()),
              ],
            ),
          )
        else
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.qr_code_scanner, size: 80, color: Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 16),
                    Text(
                      'Escaneo de código de barras',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _esMovil
                          ? 'Apunta la cámara al código de barras'
                          : 'Escanea con la pistola HID o escribe el código',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
          ),
        GlassContainer(
          padding: const EdgeInsets.all(16),
          borderRadius: 0,
          blur: GlassTokens.blurSmall,
          child: Column(
            children: [
              TextField(
                controller: _codigoController,
                decoration: InputDecoration(
                  labelText: 'Código de barras',
                  hintText: 'Escanea o escribe el código',
                  prefixIcon: const Icon(Icons.barcode_reader),
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _procesarCodigo(_codigoController.text),
                  ),
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.search,
                onSubmitted: _procesarCodigo,
              ),
              if (_procesando) ...[
                const SizedBox(height: 8),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ── Paso 2: Autocompletado ──

  Widget _buildAutocompletarStep() {
    final categoriasAsync = ref.watch(categoriasProvider);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header con código
                GlassContainer(
                  padding: const EdgeInsets.all(12),
                  borderRadius: GlassTokens.borderRadiusSmall,
                  blur: GlassTokens.blurSmall,
                  child: Row(
                    children: [
                      const Icon(Icons.qr_code),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Código: $_codigoEscaneado',
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                            const Text('Producto nuevo — completa los datos',
                                style: TextStyle(fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                if (_sugerencia != null) ...[
                  _buildSugerenciasIA(),
                  const SizedBox(height: 20),
                ],

                TextFormField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: 'Nombre del producto *',
                    prefixIcon: Icon(Icons.label_outline),
                  ),
                  validator: (v) => v == null || v.trim().isEmpty
                      ? 'Requerido'
                      : null,
                  onChanged: (v) {
                    // Si no hay sugerencia aún, intentar cargar una
                    if (!_sugerenciasCargadas && v.length > 4) {
                      _cargarSugerencias(_codigoEscaneado ?? '');
                    }
                  },
                ),
                const SizedBox(height: 16),
                categoriasAsync.when(
                  data: (categorias) => DropdownButtonFormField<int>(
                    initialValue: _categoriaId,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      prefixIcon: Icon(Icons.category_outlined),
                    ),
                    items: categorias
                        .map<DropdownMenuItem<int>>(
                          (c) => DropdownMenuItem<int>(
                            value: c.id,
                            child: Text(c.nombre),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => _categoriaId = v),
                  ),
                  loading: () => const LinearProgressIndicator(),
                  error: (_, __) => const Text('Error cargando categorías'),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _precioCompraController,
                        decoration: const InputDecoration(
                          labelText: 'Precio compra',
                          prefixIcon: Icon(Icons.attach_money),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _precioVentaController,
                        decoration: const InputDecoration(
                          labelText: 'Precio venta *',
                          prefixIcon: Icon(Icons.sell_outlined),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Requerido';
                          final n = double.tryParse(v);
                          if (n == null) return 'Número inválido';
                          if (n <= 0) return 'Debe ser > 0';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(
                          labelText: 'Stock actual',
                          prefixIcon: Icon(Icons.inventory_2_outlined),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _stockMinimoController,
                        decoration: const InputDecoration(
                          labelText: 'Stock mínimo',
                          prefixIcon: Icon(Icons.warning_amber),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descripcionController,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    prefixIcon: Icon(Icons.description_outlined),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _procesando
                            ? null
                            : () => setState(() {
                                  _step = _Step.escanear;
                                  try {
                                    _scannerController.start();
                                  } catch (_) {
                                    // El scanner pudo no haberse inicializado aún
                                  }
                                }),
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Re-escanear'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: FilledButton.icon(
                        onPressed: _procesando ? null : _confirmarRegistro,
                        icon: _procesando
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.check),
                        label: const Text('Registrar producto'),
                        style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSugerenciasIA() {
    final sug = _sugerencia!;
    final theme = Theme.of(context);
    return GlassContainer(
      padding: const EdgeInsets.all(14),
      borderRadius: GlassTokens.borderRadiusMedium,
      blur: GlassTokens.blurSmall,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, size: 18, color: theme.colorScheme.tertiary),
              const SizedBox(width: 8),
              Text(
                'Sugerencias IA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onTertiaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (sug.coincidencias > 0)
            Text('📊 ${sug.coincidencias} productos similares en tu inventario'),
          if (sug.precioMin > 0) ...[
            const SizedBox(height: 4),
            Text(
              '💰 Precio típico: ${money.format(sug.precioMin)} - ${money.format(sug.precioMax)} '
              '(promedio ${money.format(sug.precioPromedio)})',
            ),
          ],
          if (sug.categoriaSugerida.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('📂 Categoría sugerida: ${sug.categoriaSugerida}'),
          ],
          if (sug.necesita.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text('🔗 Clientes que compran esto también llevan: ${sug.necesita.length} productos'),
          ],
          const SizedBox(height: 4),
          Text(
            'Fuente: ${sug.fuente}',
            style: TextStyle(
              fontSize: 11,
              color: theme.colorScheme.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // ── Paso 3: Éxito ──

  Widget _buildExitoStep() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            GlassContainer(
              width: 80,
              height: 80,
              blur: GlassTokens.blurSmall,
              borderRadius: 40,
              borderColor: Colors.green.withValues(alpha: 0.3),
              child: Icon(Icons.check, size: 50, color: Colors.green.shade700),
            ),
            const SizedBox(height: 24),
            Text(
              '¡Producto registrado!',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              _productoCreadoNombre ?? '',
              style: Theme.of(context).textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _registrarOtro,
                  icon: const Icon(Icons.add),
                  label: const Text('Registrar otro'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    if (_productoCreadoId != null) {
                      replaceWith(
                        context,
                        '/inventario/editar/$_productoCreadoId',
                      );
                    } else {
                      // Salimos del stack overlay y volvemos al inventario.
                      context.go('/inventario');
                    }
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('Ir al inventario'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// (EscanearResult está definida al final de api_service.dart)
