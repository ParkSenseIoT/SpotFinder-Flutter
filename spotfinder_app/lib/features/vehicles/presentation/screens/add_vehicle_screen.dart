import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../controllers/vehicles_controller.dart';

/// Form to register a new vehicle. Pops with `true` on success so the caller
/// (VehiclesScreen) can refresh its list.
class AddVehicleScreen extends StatefulWidget {
  const AddVehicleScreen({super.key});

  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  final _plateController = TextEditingController();
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _colorController = TextEditingController();

  /// Peruvian plate format. Same regex as the backend's `Plate` VO.
  final _plateFormat = RegExp(r'^[A-Z0-9]{3}-?[0-9]{3,4}$');

  @override
  void dispose() {
    _plateController.dispose();
    _brandController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final plate = _plateController.text.trim().toUpperCase();
    if (plate.isEmpty) {
      _showError('La placa es obligatoria.');
      return;
    }
    if (!_plateFormat.hasMatch(plate)) {
      _showError('Formato de placa peruana inválido. Ej: ABC-123 o A1B-234.');
      return;
    }

    final controller = context.read<VehiclesController>();
    final ok = await controller.register(
      plate: plate,
      brand: _brandController.text.trim(),
      model: _modelController.text.trim(),
      color: _colorController.text.trim(),
    );

    if (!mounted) return;
    if (!ok) {
      _showError(controller.errorMessage ?? 'No se pudo registrar el vehículo.');
      return;
    }
    Navigator.pop(context, true);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<VehiclesController>().isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text('Agregar vehículo',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primaryNeon.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.directions_car,
                      color: AppColors.primaryNeon, size: 36),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Registrar nuevo vehículo',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'La placa que registres aquí será usada por el ALPR del '
                'estacionamiento para asociarte a la sesión cuando ingreses.',
                style: TextStyle(color: AppColors.textGray, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 24),
              _input(
                label: 'PLACA',
                hint: 'ABC-123',
                controller: _plateController,
                icon: Icons.confirmation_number_outlined,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[A-Za-z0-9\-]')),
                  LengthLimitingTextInputFormatter(8),
                  _UppercaseFormatter(),
                ],
              ),
              const SizedBox(height: 16),
              _input(
                label: 'MARCA (opcional)',
                hint: 'Toyota',
                controller: _brandController,
                icon: Icons.factory_outlined,
              ),
              const SizedBox(height: 16),
              _input(
                label: 'MODELO (opcional)',
                hint: 'Yaris',
                controller: _modelController,
                icon: Icons.car_rental_outlined,
              ),
              const SizedBox(height: 16),
              _input(
                label: 'COLOR (opcional)',
                hint: 'Plata',
                controller: _colorController,
                icon: Icons.palette_outlined,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryNeon,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    disabledBackgroundColor:
                        AppColors.primaryNeon.withOpacity(0.4),
                  ),
                  child: isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                              strokeWidth: 2.4, color: Colors.black),
                        )
                      : const Text(
                          'REGISTRAR VEHÍCULO',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input({
    required String label,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textGray, fontSize: 12)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white),
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: AppColors.textGray),
            prefixIcon: Icon(icon, color: AppColors.primaryNeon, size: 20),
            filled: true,
            fillColor: AppColors.surfaceDark,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.transparent),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.primaryNeon),
            ),
          ),
        ),
      ],
    );
  }
}

/// Force plate input to uppercase as the user types.
class _UppercaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}
