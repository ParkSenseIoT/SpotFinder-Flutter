/// US16 — Google Wallet digital pass for an active parking session.
///
/// Pass states:
///   - `pending` → driver has not paid yet, QR is greyed-out.
///   - `active`  → payment succeeded, QR is the exit token Access Control reads.
///   - `expired` → vehicle already exited, pass should be removed.
enum WalletPassState { pending, active, expired }

class WalletPassEntity {
  final String passId;
  final String licensePlate;
  final DateTime entryTime;
  final String currentAmount;
  final String qrCode;
  final WalletPassState state;
  final String? saveUrl;

  const WalletPassEntity({
    required this.passId,
    required this.licensePlate,
    required this.entryTime,
    required this.currentAmount,
    required this.qrCode,
    required this.state,
    this.saveUrl,
  });
}
