import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../data/plate_capture_service.dart';

/// Runs the on-demand "Verificar placa" flow in a modal sheet: it turns the
/// camera on (via backend -> edge), polls until the plate is recognized, then
/// returns it so the caller can refresh. Cancelling / timing out turns the
/// camera off again so no ALPR quota is wasted.
Future<String?> showVerifyPlateSheet(BuildContext context) {
  return showModalBottomSheet<String>(
    context: context,
    backgroundColor: AppColors.surfaceDark,
    isDismissible: false,
    enableDrag: false,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => const _VerifyPlateSheet(),
  );
}

enum _Phase { idle, capturing, recognized, failed }

class _VerifyPlateSheet extends StatefulWidget {
  const _VerifyPlateSheet();

  @override
  State<_VerifyPlateSheet> createState() => _VerifyPlateSheetState();
}

class _VerifyPlateSheetState extends State<_VerifyPlateSheet> {
  final _service = PlateCaptureService();

  _Phase _phase = _Phase.idle;
  String? _plate;
  String? _error;
  Timer? _poll;
  Timer? _timeout;

  static const _timeoutDuration = Duration(seconds: 45);
  static const _pollInterval = Duration(milliseconds: 1500);

  @override
  void dispose() {
    _stopTimers();
    // If the user leaves mid-capture, make sure the camera is turned off.
    if (_phase == _Phase.capturing) {
      _service.stop();
    }
    super.dispose();
  }

  void _stopTimers() {
    _poll?.cancel();
    _timeout?.cancel();
  }

  Future<void> _start() async {
    setState(() {
      _phase = _Phase.capturing;
      _error = null;
    });
    try {
      await _service.start();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _phase = _Phase.failed;
        _error = 'No se pudo iniciar la cámara. Revisa que el edge esté encendido.';
      });
      return;
    }
    _timeout = Timer(_timeoutDuration, _onTimeout);
    _poll = Timer.periodic(_pollInterval, (_) => _tick());
  }

  Future<void> _tick() async {
    try {
      final s = await _service.status();
      if (!mounted || _phase != _Phase.capturing) return;
      if (s.recognized && s.plate != null && s.plate!.isNotEmpty) {
        _stopTimers();
        setState(() {
          _phase = _Phase.recognized;
          _plate = s.plate;
        });
      }
    } catch (_) {
      // Transient network blip; keep polling until the timeout fires.
    }
  }

  void _onTimeout() {
    _stopTimers();
    _service.stop();
    if (!mounted) return;
    setState(() {
      _phase = _Phase.failed;
      _error = 'No se detectó ninguna placa. Acércala bien iluminada e inténtalo de nuevo.';
    });
  }

  Future<void> _cancel() async {
    _stopTimers();
    await _service.stop();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 22,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: _buildContent(),
      ),
    );
  }

  List<Widget> _buildContent() {
    switch (_phase) {
      case _Phase.idle:
        return _idleContent();
      case _Phase.capturing:
        return _capturingContent();
      case _Phase.recognized:
        return _recognizedContent();
      case _Phase.failed:
        return _failedContent();
    }
  }

  List<Widget> _idleContent() => [
        const Icon(Icons.camera_alt_outlined, color: AppColors.primaryNeon, size: 48),
        const SizedBox(height: 14),
        const Text('Verificar placa',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        const Text(
          'La cámara tomará una foto solo cuando pulses el botón. '
          'Acerca tu placa al lente y mantenla quieta.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textGray, height: 1.4),
        ),
        const SizedBox(height: 20),
        _primaryButton('Iniciar', _start),
        _secondaryButton('Cancelar', () => Navigator.of(context).pop()),
      ];

  List<Widget> _capturingContent() => [
        const SizedBox(height: 8),
        const CircularProgressIndicator(color: AppColors.primaryNeon),
        const SizedBox(height: 18),
        const Text('Buscando placa…',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        const Text(
          'Acerca la placa a la cámara y mantenla quieta y bien iluminada.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textGray, height: 1.4),
        ),
        const SizedBox(height: 20),
        _secondaryButton('Cancelar', _cancel),
      ];

  List<Widget> _recognizedContent() => [
        const Icon(Icons.check_circle, color: Color(0xFF22C55E), size: 48),
        const SizedBox(height: 14),
        const Text('¡Placa reconocida!',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.primaryNeon.withOpacity(0.4)),
          ),
          child: Text(
            _plate ?? '',
            style: const TextStyle(
              color: AppColors.primaryNeon,
              fontSize: 26,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 20),
        _primaryButton('Listo', () => Navigator.of(context).pop(_plate)),
      ];

  List<Widget> _failedContent() => [
        const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
        const SizedBox(height: 14),
        const Text('No se reconoció',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(
          _error ?? 'Inténtalo de nuevo.',
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textGray, height: 1.4),
        ),
        const SizedBox(height: 20),
        _primaryButton('Reintentar', _start),
        _secondaryButton('Cerrar', () => Navigator.of(context).pop()),
      ];

  Widget _primaryButton(String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryNeon,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(label,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ),
      );

  Widget _secondaryButton(String label, VoidCallback onTap) => SizedBox(
        width: double.infinity,
        child: TextButton(
          onPressed: onTap,
          child: Text(label, style: const TextStyle(color: AppColors.textGray)),
        ),
      );
}
