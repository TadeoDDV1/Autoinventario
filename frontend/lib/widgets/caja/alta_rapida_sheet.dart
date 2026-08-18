import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/durations.dart';
import '../../core/errors/api_exception.dart';
import '../../core/utils/codigo_manual.dart';
import '../../core/utils/test_environment.dart';
import '../../database/database_provider.dart';
import '../../models/producto.dart';
import '../../providers/producto_provider.dart';

/// Bottom sheet para alta rápida de producto desde Caja.
///
/// Caso de uso: el operador escaneó (o tipeó) un código que **no existe**
/// en el backend. En lugar de mostrar un error y perder el flujo, abre
/// este sheet con 3 campos:
///
///   1. **Nombre** (autofocus, required).
///   2. **Código** (readOnly por defecto, 0–9999 auto-generado, botón 🔄).
///   3. **Precio venta** (required, >0).
///
/// Al submit crea el producto vía `ProductosNotifier.createProducto(...)`
/// que devuelve el `Producto` completo. El sheet hace `Navigator.pop`
/// con ese producto para que `CajaScreen._abrirAltaRapida` lo agregue
/// al carrito sin un round-trip extra.
///
/// **Manejo de errores**:
/// - `ApiException(409)` → colisión de código. Regenera automáticamente
///   hasta **5 veces**. Si tras 5 reintentos sigue, snack
///   "Tipealo manual" + campo código editable para intervención del
///   operador.
/// - Otro error → snack rojo con el mensaje y el sheet queda abierto
///   para que corrija.
///
/// **Codigo inicial**: si el operador escaneó algo no numérico o con
/// más de 4 dígitos (típicamente un EAN-13), se ignora y se genera uno
/// nuevo del rango 0–9999.
class AltaRapidaSheet extends ConsumerStatefulWidget {
  /// Código a usar como punto de partida. Si es null, no numérico, o
  /// excede 4 dígitos, se genera uno nuevo con
  /// [generarCodigoManualCaja].
  final String? codigoInicial;

  const AltaRapidaSheet({super.key, this.codigoInicial});

  @override
  ConsumerState<AltaRapidaSheet> createState() => _AltaRapidaSheetState();
}

class _AltaRapidaSheetState extends ConsumerState<AltaRapidaSheet> {
  static const int _maxReintentosColision = 5;

  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();
  final _precioController = TextEditingController();

  /// Controlador del código. Lo gestionamos manualmente (no dentro de un
  /// TextFormField) para poder alternar entre read-only y editable según
  /// el flujo de colisiones. Aún así lo envolvemos en un TextFormField
  /// para tener validator (sólo aplica cuando está editable).
  late final TextEditingController _codigoController;

  late final FocusNode _nombreFocus;
  late final FocusNode _codigoFocus;
  late final FocusNode _precioFocus;

  bool _codigoEditable = false;
  bool _procesando = false;

  @override
  void initState() {
    super.initState();
    _codigoController = TextEditingController(text: _codigoInicialValido());
    _nombreFocus = FocusNode();
    _codigoFocus = FocusNode();
    _precioFocus = FocusNode();

    // Autofocus en nombre después del primer frame (así el sheet ya
    // está animado y el focus no se pierde). Se omite en tests para
    // no dejar el cursor parpadeando (rompe `pumpAndSettle`).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !isRunningTests) _nombreFocus.requestFocus();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _precioController.dispose();
    _codigoController.dispose();
    _nombreFocus.dispose();
    _codigoFocus.dispose();
    _precioFocus.dispose();
    super.dispose();
  }

  /// Devuelve el código a usar como valor inicial del campo:
  /// - Si [widget.codigoInicial] es null → genera uno aleatorio.
  /// - Si no es numérico puro o excede 4 dígitos (típicamente un EAN)
  ///   → genera uno aleatorio del rango 0-9999.
  /// - Si es numérico 1-4 dígitos → lo usa tal cual.
  String _codigoInicialValido() {
    final inicial = widget.codigoInicial;
    if (inicial != null &&
        RegExp(r'^[0-9]+$').hasMatch(inicial) &&
        inicial.length <= 4) {
      return inicial;
    }
    return generarCodigoManualCaja();
  }

  void _regenerarCodigo() {
    setState(() {
      _codigoController.text = generarCodigoManualCaja();
      _codigoController.selection = TextSelection.collapsed(
        offset: _codigoController.text.length,
      );
    });
  }

  String? _validarNombre(String? v) {
    if (v == null || v.trim().isEmpty) return 'Requerido';
    return null;
  }

  String? _validarPrecio(String? v) {
    if (v == null || v.trim().isEmpty) return 'Requerido';
    final parsed = double.tryParse(v.replaceAll(',', '.'));
    if (parsed == null) return 'Debe ser un número';
    if (parsed <= 0) return 'Debe ser mayor a 0';
    return null;
  }

  String? _validarCodigo(String? v) {
    // Sólo se aplica cuando el campo es editable (post-5-colisiones).
    if (!_codigoEditable) return null;
    if (v == null || v.trim().isEmpty) return 'Requerido';
    if (!RegExp(r'^[0-9]+$').hasMatch(v.trim())) return 'Sólo dígitos';
    return null;
  }

  Future<void> _submit() async {
    if (_procesando) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _procesando = true);

    final nombre = _nombreController.text.trim();
    final precio = double.parse(
      _precioController.text.replaceAll(',', '.'),
    );

    // El código arranca con el valor actual del controller (que es el
    // inicial o el último regenerado por el operador vía 🔄).
    var codigoActual = _codigoController.text.trim();

    for (var intento = 0; intento < _maxReintentosColision; intento++) {
      try {
        // Offline-first: verificar duplicado contra la BD local antes de
        // crear (los códigos 0-9999 pueden chocar con un producto ya
        // guardado localmente). Si existe, regenerar y reintentar.
        final db = ref.read(appDatabaseProvider);
        final existente = await db.getProductoByCodigo(codigoActual);
        if (existente != null) {
          codigoActual = generarCodigoManualCaja();
          _codigoController.text = codigoActual;
          continue;
        }

        final creado = await ref
            .read(productosProvider.notifier)
            .createProducto(
              buildRapidoCreatePayload(
                nombre: nombre,
                codigoBarras: codigoActual,
                precioVenta: precio,
              ),
            );

        if (!mounted) return;
        Navigator.of(context).pop<Producto>(creado);
        return;
      } on ApiException catch (e) {
        if (!mounted) return;

        if (e.statusCode == 409 || e.code == 'DUPLICATE_CODE') {
          // Colisión: regenerar y reintentar.
          codigoActual = generarCodigoManualCaja();
          _codigoController.text = codigoActual;
          continue;
        }

        // Otro error → snack rojo y dejar sheet abierto.
        setState(() => _procesando = false);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red.shade700,
            duration: AppDurations.snackbarLong,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      } catch (e) {
        if (!mounted) return;
        setState(() => _procesando = false);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error inesperado: $e'),
            backgroundColor: Colors.red.shade700,
            duration: AppDurations.snackbarLong,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }
    }

    // Tras 5 intentos sigue colisionando → habilitar edición manual.
    if (!mounted) return;
    setState(() {
      _procesando = false;
      _codigoEditable = true;
    });
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Tipealo manual: 5 códigos aleatorios撞aron con uno existente',
        ),
        backgroundColor: Colors.orange,
        duration: AppDurations.snackbarLong,
        behavior: SnackBarBehavior.floating,
      ),
    );
    _codigoFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final mediaQuery = MediaQuery.of(context);

    return Padding(
      // Evita que el teclado tape los campos.
      padding: EdgeInsets.only(bottom: mediaQuery.viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(16),
          ),
        ),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── AppBar compacta ───────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Alta rápida',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Cancelar',
                        icon: const Icon(Icons.close),
                        onPressed: _procesando
                            ? null
                            : () => Navigator.of(context).pop<Producto>(null),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  // ─── Banner informativo ────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: theme.colorScheme.onSecondaryContainer,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Código interno generado automáticamente. '
                            'Stock inicial = 1.',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ─── Campo: Nombre ─────────────────────────────────────
                  TextFormField(
                    controller: _nombreController,
                    focusNode: _nombreFocus,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del producto *',
                      prefixIcon: Icon(Icons.label_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validarNombre,
                    onFieldSubmitted: (_) => _precioFocus.requestFocus(),
                  ),

                  const SizedBox(height: 16),

                  // ─── Campo: Código ─────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _codigoController,
                          focusNode: _codigoFocus,
                          // Por defecto readOnly; se habilita tras 5
                          // colisiones.
                          readOnly: !_codigoEditable,
                          // Si el operador edita manualmente, dejamos de
                          // forzar readOnly en cualquier rebuild.
                          // (El `setState` posterior hace el rebuild.)
                          decoration: const InputDecoration(
                            labelText: 'Código de barras',
                            prefixIcon: Icon(Icons.qr_code_2),
                            border: OutlineInputBorder(),
                          ),
                          validator: _validarCodigo,
                          // Permitir submit con Enter cuando está editable.
                          textInputAction: _codigoEditable
                              ? TextInputAction.next
                              : TextInputAction.done,
                          inputFormatters: _codigoEditable
                              ? [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(4),
                                ]
                              : null,
                          onTap: () {
                            if (!_codigoEditable) {
                              // En readOnly el tap no debe mostrar teclado.
                              _codigoFocus.unfocus();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Botón regenerar código
                      SizedBox(
                        height: 56, // match OutlineInputBorder height
                        child: IconButton.filledTonal(
                          tooltip: 'Regenerar código',
                          onPressed: _procesando ? null : _regenerarCodigo,
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // ─── Campo: Precio venta ───────────────────────────────
                  TextFormField(
                    controller: _precioController,
                    focusNode: _precioFocus,
                    textInputAction: TextInputAction.done,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: const InputDecoration(
                      labelText: 'Precio venta *',
                      prefixIcon: Icon(Icons.attach_money),
                      border: OutlineInputBorder(),
                    ),
                    validator: _validarPrecio,
                    onFieldSubmitted: (_) => _submit(),
                  ),

                  const SizedBox(height: 24),

                  // ─── Submit ────────────────────────────────────────────
                  FilledButton.icon(
                    onPressed: _procesando ? null : _submit,
                    icon: _procesando
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.add_circle_outline),
                    label: const Text('Crear y agregar al carrito'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}