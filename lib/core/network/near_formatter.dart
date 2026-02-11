/// Utility class for converting between NEAR and yoctoNEAR denominations.
///
/// 1 NEAR = 10^24 yoctoNEAR.
///
/// This replaces the flutterchain `NearFormatter` with a pure-Dart
/// implementation that has no external dependencies.
class NearFormatter {
  NearFormatter._();

  /// The number of decimal places in yoctoNEAR (10^24).
  static const int _yoctoDecimals = 24;

  /// Converts a NEAR amount (e.g. "1.5") to yoctoNEAR (e.g. "1500000000000000000000000").
  ///
  /// Accepts both integer and decimal string representations.
  /// Returns a string of the integer yoctoNEAR value (no decimal point).
  static String nearToYoctoNear(String nearAmount) {
    if (nearAmount.isEmpty) return '0';

    // Handle negative sign.
    final isNegative = nearAmount.startsWith('-');
    if (isNegative) {
      nearAmount = nearAmount.substring(1);
    }

    final parts = nearAmount.split('.');
    final integerPart = parts[0].isEmpty ? '0' : parts[0];
    final fractionalPart = parts.length > 1 ? parts[1] : '';

    // Pad or truncate the fractional part to exactly _yoctoDecimals digits.
    final paddedFraction = fractionalPart.length >= _yoctoDecimals
        ? fractionalPart.substring(0, _yoctoDecimals)
        : fractionalPart.padRight(_yoctoDecimals, '0');

    // Combine: integer part shifted left by _yoctoDecimals + fractional digits.
    final combined = '$integerPart$paddedFraction';

    // Strip leading zeros but keep at least one digit.
    final stripped = combined.replaceFirst(RegExp(r'^0+'), '');
    final result = stripped.isEmpty ? '0' : stripped;

    return isNegative && result != '0' ? '-$result' : result;
  }

  /// Converts a yoctoNEAR amount (e.g. "1500000000000000000000000") to NEAR
  /// (e.g. "1.5").
  ///
  /// Returns a decimal string representation. Trailing zeros after the decimal
  /// point are stripped for readability, but at least one decimal place is
  /// preserved when there is a fractional component.
  static String yoctoNearToNear(String yoctoNearAmount) {
    if (yoctoNearAmount.isEmpty) return '0';

    // Handle negative sign.
    final isNegative = yoctoNearAmount.startsWith('-');
    if (isNegative) {
      yoctoNearAmount = yoctoNearAmount.substring(1);
    }

    // Pad with leading zeros if shorter than _yoctoDecimals + 1 characters.
    final padded = yoctoNearAmount.padLeft(_yoctoDecimals + 1, '0');

    final integerPart = padded.substring(0, padded.length - _yoctoDecimals);
    final fractionalPart = padded.substring(padded.length - _yoctoDecimals);

    // Strip trailing zeros from fractional part.
    final trimmedFraction = fractionalPart.replaceFirst(RegExp(r'0+$'), '');

    final prefix = isNegative ? '-' : '';

    if (trimmedFraction.isEmpty) {
      return '$prefix$integerPart';
    }

    return '$prefix$integerPart.$trimmedFraction';
  }
}
