/// US17 — Premium add-on service that can be requested while the vehicle is parked.
class PremiumServiceEntity {
  final String id;
  final String name;
  final String description;
  final String estimatedTime;
  final String priceLabel;
  final String iconAsset;

  const PremiumServiceEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.estimatedTime,
    required this.priceLabel,
    required this.iconAsset,
  });
}

/// Catalogue served locally — the backend Wallet/Premium endpoints are still
/// SS04, so the screen iterates over this list. Replace by a network call
/// when the backend exposes `/api/v1/premium-services`.
const List<PremiumServiceEntity> kPremiumServiceCatalog = [
  PremiumServiceEntity(
    id: 'wash-basic',
    name: 'Lavado exterior',
    description: 'Limpieza completa del exterior mientras tu vehículo está estacionado.',
    estimatedTime: '20 min',
    priceLabel: 'PEN 18.00',
    iconAsset: 'wash',
  ),
  PremiumServiceEntity(
    id: 'wash-premium',
    name: 'Lavado Premium (int + ext)',
    description: 'Limpieza interior con aspirado, exterior + acondicionado de llantas.',
    estimatedTime: '45 min',
    priceLabel: 'PEN 45.00',
    iconAsset: 'wash',
  ),
  PremiumServiceEntity(
    id: 'detailing',
    name: 'Detailing rápido',
    description: 'Polishing express en zonas con marcas leves.',
    estimatedTime: '60 min',
    priceLabel: 'PEN 80.00',
    iconAsset: 'detail',
  ),
  PremiumServiceEntity(
    id: 'fuel-delivery',
    name: 'Entrega de combustible',
    description: 'Solicita 1 galón de gasolina si tienes el tanque bajo.',
    estimatedTime: '25 min',
    priceLabel: 'PEN 25.00',
    iconAsset: 'fuel',
  ),
];
