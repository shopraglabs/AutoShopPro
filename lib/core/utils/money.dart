/// Money helpers for AutoShopPro.
///
/// All price/cost/rate values are stored in the database as **integer cents**
/// (e.g. $120.00 → 12000). These helpers convert between that representation
/// and the double-dollars that the UI works with, plus format amounts for
/// display.
///
/// Rule of thumb:
///   • Reading FROM the DB  → call [fromCents] to get a double you can display
///   • Writing TO the DB    → call [toCents] to get the int to store
///   • Displaying in the UI → call [formatMoney] (omits .00 cents)
///   • Displaying on a PDF  → call [formatMoneyFull] (always 2 decimal places)

/// Converts a dollar [amount] (e.g. 120.5) to integer cents (e.g. 12050).
/// Always rounds half-up so floating-point noise doesn't cause off-by-one errors.
int toCents(double amount) => (amount * 100).round();

/// Converts integer [cents] (e.g. 12050) back to a dollar double (e.g. 120.5).
double fromCents(int cents) => cents / 100;

/// Formats [cents] for UI display.
/// Omits the decimal portion when it is exactly zero:
///   12000 → "$120"      12050 → "$120.50"
///   123456 → "$1,234.56"
String formatMoney(int cents) {
  final amount = cents / 100;
  final hasCents = cents % 100 != 0;
  final str =
      hasCents ? amount.toStringAsFixed(2) : cents ~/ 100 == amount.truncate()
          ? (cents ~/ 100).toString()
          : amount.toStringAsFixed(0);
  final parts = str.split('.');
  final dollars = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return hasCents ? '\$$dollars.${parts[1]}' : '\$$dollars';
}

/// Formats [cents] for invoice PDFs — always shows two decimal places:
///   12000 → "$120.00"   12050 → "$120.50"
String formatMoneyFull(int cents) {
  final amount = cents / 100;
  final parts = amount.toStringAsFixed(2).split('.');
  final dollars = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return '\$$dollars.${parts[1]}';
}

/// Formats a [double] dollar value for UI display (convenience overload).
/// Prefer passing cents wherever possible; use this only when you already
/// have a dollar double (e.g. from a text-field calculation).
String formatMoneyFromDouble(double amount) => formatMoney(toCents(amount));
