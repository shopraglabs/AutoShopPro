import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../database/database.dart';
import '../../widgets/context_menu.dart';

// ─── Money + number helpers ────────────────────────────────────────────────────

// Formats a double as a dollar amount, always with 2 decimal places
// (invoice is an official document): 1234.5 → "$1,234.50"
String _money(double amount) {
  final parts = amount.toStringAsFixed(2).split('.');
  final dollars = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
  return '\$$dollars.${parts[1]}';
}

String _qty(double q) =>
    q % 1 == 0 ? q.toInt().toString() : q.toStringAsFixed(1);

String _roNumber(int id) => 'RO-${id.toString().padLeft(4, '0')}';

// ─── PDF builder ──────────────────────────────────────────────────────────────

/// Builds invoice PDF bytes from RO data.
/// Returns the raw bytes — caller decides what to do with them (save / print / email).
Future<Uint8List> buildInvoicePdf({
  required RepairOrder ro,
  required Customer customer,
  required Vehicle? vehicle,
  required List<EstimateLineItem> lineItems,
  required double taxRate,
  required String? shopName,
  String? customerComplaint,
  String? comment,
  List<EstimateLineItem> declinedItems = const [],
}) async {
  final doc = pw.Document();

  // Only approved/pending items (declined already excluded at RO level)
  final labor = lineItems.where((l) => l.type == 'labor').toList();
  final parts = lineItems.where((l) => l.type == 'part').toList();
  final subtotal = lineItems.fold(0.0, (s, l) => s + l.quantity * l.unitPrice);
  final taxAmount = subtotal * (taxRate / 100);
  final total = subtotal + taxAmount;

  // ── Colour palette ────────────────────────────────────────────────────────
  const accent = PdfColor.fromInt(0xFF007AFF); // system blue
  const dark = PdfColor.fromInt(0xFF1C1C1E);
  const mid = PdfColor.fromInt(0xFF8E8E93);
  const light = PdfColor.fromInt(0xFFE5E5EA);

  // ── Date string ───────────────────────────────────────────────────────────
  final now = DateTime.now();
  final dateStr =
      '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';

  // ── Vehicle label ─────────────────────────────────────────────────────────
  final vehicleLabel = vehicle != null
      ? [vehicle.year?.toString(), vehicle.make, vehicle.model]
          .whereType<String>()
          .join(' ')
      : null;
  final vin = vehicle?.vin;
  final plate = vehicle?.licensePlate;

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        // ── Header ──────────────────────────────────────────────────────────
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    shopName?.isNotEmpty == true ? shopName! : 'AutoShopPro',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: dark,
                    ),
                  ),
                ],
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    fontSize: 28,
                    fontWeight: pw.FontWeight.bold,
                    color: accent,
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  _roNumber(ro.id),
                  style: pw.TextStyle(
                    fontSize: 13,
                    color: mid,
                  ),
                ),
                pw.Text(
                  dateStr,
                  style: pw.TextStyle(
                    fontSize: 13,
                    color: mid,
                  ),
                ),
              ],
            ),
          ],
        ),

        pw.SizedBox(height: 4),
        pw.Divider(color: accent, thickness: 1.5),
        pw.SizedBox(height: 16),

        // ── Bill To / Vehicle ────────────────────────────────────────────────
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Customer
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'BILL TO',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: mid,
                      letterSpacing: 1.0,
                    ),
                  ),
                  pw.SizedBox(height: 6),
                  pw.Text(
                    customer.name,
                    style: pw.TextStyle(
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                      color: dark,
                    ),
                  ),
                  if (customer.phone?.isNotEmpty == true)
                    pw.Text(
                      customer.phone!,
                      style: pw.TextStyle(fontSize: 12, color: dark),
                    ),
                  if (customer.email?.isNotEmpty == true)
                    pw.Text(
                      customer.email!,
                      style: pw.TextStyle(fontSize: 12, color: dark),
                    ),
                ],
              ),
            ),
            // Vehicle
            if (vehicle != null)
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'VEHICLE',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: mid,
                        letterSpacing: 1.0,
                      ),
                    ),
                    pw.SizedBox(height: 6),
                    if (vehicleLabel != null)
                      pw.Text(
                        vehicleLabel,
                        style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: dark,
                        ),
                      ),
                    if (vin?.isNotEmpty == true)
                      pw.Text(
                        'VIN: $vin',
                        style: pw.TextStyle(fontSize: 12, color: dark),
                      ),
                    if (plate?.isNotEmpty == true && plate != 'NO PLATE')
                      pw.Text(
                        'Plate: $plate',
                        style: pw.TextStyle(fontSize: 12, color: dark),
                      ),
                  ],
                ),
              ),
          ],
        ),

        // ── Customer Complaints ───────────────────────────────────────────────
        if (customerComplaint != null && customerComplaint.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          _sectionDivider('CUSTOMER CONCERN', accent),
          pw.SizedBox(height: 8),
          ...customerComplaint.split('\n').where((s) => s.isNotEmpty).map(
                (c) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• ',
                          style: pw.TextStyle(fontSize: 11, color: dark)),
                      pw.Expanded(
                        child: pw.Text(c,
                            style: pw.TextStyle(fontSize: 11, color: dark)),
                      ),
                    ],
                  ),
                ),
              ),
        ],

        pw.SizedBox(height: 24),

        // ── Services: labor rows + parts nested under their labor line ───────
        if (labor.isNotEmpty || parts.isNotEmpty) ...[
          _sectionDivider('LABOR', accent),
          pw.SizedBox(height: 8),
          _tableHeaderWithType(light, mid),
          ...labor.expand((l) {
            final linkedParts =
                parts.where((p) => p.parentLaborId == l.id).toList();
            return [
              _lineRow(
                typeLabel: 'Labor',
                description: l.laborName ?? l.description,
                subtitle: l.laborName != null ? l.description : null,
                qty: '${_qty(l.quantity)} hr',
                unit: _money(l.unitPrice),
                total: _money(l.quantity * l.unitPrice),
                isLabor: true,
                dark: dark,
                mid: mid,
                light: light,
              ),
              ...linkedParts.map((p) => _lineRow(
                    typeLabel: 'Part',
                    description: p.description,
                    qty: _qty(p.quantity),
                    unit: _money(p.unitPrice),
                    total: _money(p.quantity * p.unitPrice),
                    isLabor: false,
                    dark: dark,
                    mid: mid,
                    light: light,
                  )),
            ];
          }),
          // Parts with no parent labor line — shown after all grouped items
          ...parts
              .where((p) => p.parentLaborId == null)
              .map((p) => _lineRow(
                    typeLabel: 'Part',
                    description: p.description,
                    qty: _qty(p.quantity),
                    unit: _money(p.unitPrice),
                    total: _money(p.quantity * p.unitPrice),
                    isLabor: false,
                    dark: dark,
                    mid: mid,
                    light: light,
                  )),
          pw.SizedBox(height: 16),
        ],

        // ── Totals ────────────────────────────────────────────────────────────
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Container(
            width: 240,
            child: pw.Column(
              children: [
                pw.Divider(color: light, thickness: 0.5),
                _totalRow('Subtotal', _money(subtotal), dark, mid, false),
                if (taxRate > 0) ...[
                  pw.Divider(color: light, thickness: 0.5),
                  _totalRow(
                    'Tax (${taxRate.toStringAsFixed(taxRate % 1 == 0 ? 0 : 1)}%)',
                    _money(taxAmount),
                    dark,
                    mid,
                    false,
                  ),
                ],
                pw.Divider(color: accent, thickness: 1),
                _totalRow('Total', _money(total), dark, accent, true),
              ],
            ),
          ),
        ),

        pw.SizedBox(height: 40),

        // ── Declined items ────────────────────────────────────────────────────
        if (declinedItems.isNotEmpty) ...[
          _sectionDivider('DECLINED — NOT BILLED', mid),
          pw.SizedBox(height: 8),
          ...declinedItems.map((d) {
            final title = (d.type == 'labor' || d.type == 'other') &&
                    d.laborName != null
                ? d.laborName!
                : d.description;
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: mid,
                        decoration: pw.TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                  pw.Text(
                    _money(d.quantity * d.unitPrice),
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: mid,
                      decoration: pw.TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            );
          }),
          pw.SizedBox(height: 24),
        ],

        // ── Invoice Comment ───────────────────────────────────────────────────
        if (comment != null && comment.isNotEmpty) ...[
          pw.Divider(color: light, thickness: 0.5),
          pw.SizedBox(height: 8),
          pw.Text(
            comment,
            style: pw.TextStyle(fontSize: 10, color: mid),
          ),
          pw.SizedBox(height: 16),
        ],

        // ── Footer ────────────────────────────────────────────────────────────
        pw.Center(
          child: pw.Text(
            'Thank you for your business.',
            style: pw.TextStyle(
              fontSize: 12,
              color: mid,
              fontStyle: pw.FontStyle.italic,
            ),
          ),
        ),
      ],
    ),
  );

  return doc.save();
}

// ─── PDF widget helpers ───────────────────────────────────────────────────────

/// Section header with accent lines on both sides: ─── LABOR ───
pw.Widget _sectionDivider(String label, PdfColor color) => pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Expanded(child: pw.Container(height: 1.5, color: color)),
        pw.Padding(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8),
          child: pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: color,
              letterSpacing: 1.2,
            ),
          ),
        ),
        pw.Expanded(child: pw.Container(height: 1.5, color: color)),
      ],
    );

/// Table header row with a blank left column for the Labor/Part type label.
pw.Widget _tableHeaderWithType(PdfColor bg, PdfColor textColor) =>
    pw.Container(
      color: bg,
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Row(
        children: [
          pw.SizedBox(width: 46), // blank — aligns with type label column
          pw.Expanded(
            flex: 5,
            child: pw.Text('Description',
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: textColor)),
          ),
          pw.SizedBox(
            width: 60,
            child: pw.Text('Qty',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: textColor)),
          ),
          pw.SizedBox(
            width: 70,
            child: pw.Text('Unit',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: textColor)),
          ),
          pw.SizedBox(
            width: 70,
            child: pw.Text('Total',
                textAlign: pw.TextAlign.right,
                style: pw.TextStyle(
                    fontSize: 9,
                    fontWeight: pw.FontWeight.bold,
                    color: textColor)),
          ),
        ],
      ),
    );

/// A single line item row. Labor rows are bold/dark; Part rows are muted/gray.
/// [subtitle] shows a second smaller line under [description] (e.g. the full
/// labor operation description when [description] is the short labor name).
pw.Widget _lineRow({
  required String typeLabel,
  required String description,
  String? subtitle,
  required String qty,
  required String unit,
  required String total,
  required bool isLabor,
  required PdfColor dark,
  required PdfColor mid,
  required PdfColor light,
}) {
  final textColor = isLabor ? dark : mid;
  final fontSize = isLabor ? 11.0 : 10.0;
  final weight = isLabor ? pw.FontWeight.bold : pw.FontWeight.normal;

  return pw.Column(
    children: [
      pw.Container(
        padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        child: pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // Type label column
            pw.SizedBox(
              width: 46,
              child: pw.Text(
                typeLabel,
                style: pw.TextStyle(
                  fontSize: 9,
                  color: isLabor ? dark : mid,
                  fontWeight: isLabor ? pw.FontWeight.bold : pw.FontWeight.normal,
                ),
              ),
            ),
            pw.Expanded(
              flex: 5,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(description,
                      style: pw.TextStyle(
                          fontSize: fontSize,
                          color: textColor,
                          fontWeight: weight)),
                  if (subtitle != null)
                    pw.Text(subtitle,
                        style: pw.TextStyle(fontSize: 9, color: mid)),
                ],
              ),
            ),
            pw.SizedBox(
              width: 60,
              child: pw.Text(qty,
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(fontSize: fontSize, color: textColor)),
            ),
            pw.SizedBox(
              width: 70,
              child: pw.Text(unit,
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(fontSize: fontSize, color: textColor)),
            ),
            pw.SizedBox(
              width: 70,
              child: pw.Text(total,
                  textAlign: pw.TextAlign.right,
                  style: pw.TextStyle(
                      fontSize: fontSize,
                      color: textColor,
                      fontWeight: weight)),
            ),
          ],
        ),
      ),
      pw.Divider(color: light, thickness: 0.5),
    ],
  );
}

pw.Widget _totalRow(String label, String value, PdfColor labelColor,
    PdfColor valueColor, bool bold) =>
    pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 12,
              color: labelColor,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
          pw.Text(
            value,
            style: pw.TextStyle(
              fontSize: 12,
              color: valueColor,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),
        ],
      ),
    );

// ─── Delivery helpers ─────────────────────────────────────────────────────────

/// Saves PDF bytes to ~/Downloads and returns the saved file path.
Future<String> saveInvoiceToDownloads(Uint8List bytes, int roId) async {
  final dir = await getDownloadsDirectory();
  final folder = dir ?? await getTemporaryDirectory();
  final fileName = 'Invoice-${_roNumber(roId)}.pdf';
  final file = File('${folder.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file.path;
}

/// Saves PDF bytes to a temp file and returns the path.
Future<String> saveInvoiceToTemp(Uint8List bytes, int roId) async {
  final dir = await getTemporaryDirectory();
  final fileName = 'Invoice-${_roNumber(roId)}.pdf';
  final file = File('${dir.path}/$fileName');
  await file.writeAsBytes(bytes);
  return file.path;
}

/// Opens the PDF file in the system default viewer (Preview on macOS).
Future<void> openInPreview(String filePath) async {
  await Process.run('open', [filePath]);
}

/// Opens Mail.app with the PDF attached as a new draft using AppleScript.
Future<void> openInMailWithAttachment({
  required String filePath,
  required String roNumber,
  required String customerName,
  String? customerEmail,
}) async {
  final to = customerEmail?.isNotEmpty == true ? customerEmail! : '';
  final subject = 'Invoice $roNumber';
  final body = 'Please find your invoice attached.';

  final toLine =
      to.isNotEmpty ? 'make new to recipient with properties {address:"$to"}' : '';
  final script = '''
tell application "Mail"
  activate
  set newMsg to make new outgoing message with properties {subject:"$subject", content:"$body", visible:true}
  tell newMsg
    $toLine
    make new attachment with properties {file name:POSIX file "$filePath"}
  end tell
end tell
''';

  await Process.run('osascript', ['-e', script]);
}

// ─── Simple invoice PDF builder ───────────────────────────────────────────────

/// Builds a customer-friendly invoice: one row per labor job with parts cost
/// rolled in. Unlinked parts are listed separately.
Future<Uint8List> buildSimpleInvoicePdf({
  required RepairOrder ro,
  required Customer customer,
  required Vehicle? vehicle,
  required List<EstimateLineItem> lineItems,
  required double taxRate,
  required String? shopName,
  String? customerComplaint,
  String? comment,
  List<EstimateLineItem> declinedItems = const [],
}) async {
  final doc = pw.Document();

  final labor = lineItems.where((l) => l.type == 'labor').toList();
  final parts = lineItems.where((l) => l.type == 'part').toList();

  // Build combined rows: each labor line + sum of its linked parts
  final rows =
      <({String typeLabel, String description, String? subtitle, double total})>[];
  for (final l in labor) {
    final linked = parts.where((p) => p.parentLaborId == l.id).toList();
    final partsTotal = linked.fold(0.0, (s, p) => s + p.quantity * p.unitPrice);
    final laborTotal = l.quantity * l.unitPrice;
    rows.add((
      typeLabel: linked.isNotEmpty ? 'Parts / Labor' : 'Labor',
      description: l.laborName ?? l.description,
      subtitle: l.laborName != null ? l.description : null,
      total: laborTotal + partsTotal,
    ));
  }
  // Parts with no parent labor — listed on their own
  for (final p in parts.where((p) => p.parentLaborId == null)) {
    rows.add((
      typeLabel: 'Part',
      description: p.description,
      subtitle: null,
      total: p.quantity * p.unitPrice,
    ));
  }

  final subtotal = rows.fold(0.0, (s, r) => s + r.total);
  final taxAmount = subtotal * (taxRate / 100);
  final total = subtotal + taxAmount;

  const accent = PdfColor.fromInt(0xFF007AFF);
  const dark = PdfColor.fromInt(0xFF1C1C1E);
  const mid = PdfColor.fromInt(0xFF8E8E93);
  const light = PdfColor.fromInt(0xFFE5E5EA);

  final now = DateTime.now();
  final dateStr =
      '${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}/${now.year}';
  final vehicleLabel = vehicle != null
      ? [vehicle.year?.toString(), vehicle.make, vehicle.model]
          .whereType<String>()
          .join(' ')
      : null;
  final vin = vehicle?.vin;
  final plate = vehicle?.licensePlate;

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        // ── Header ────────────────────────────────────────────────────────────
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                shopName?.isNotEmpty == true ? shopName! : 'AutoShopPro',
                style: pw.TextStyle(
                    fontSize: 22, fontWeight: pw.FontWeight.bold, color: dark),
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('INVOICE',
                    style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: accent)),
                pw.SizedBox(height: 4),
                pw.Text(_roNumber(ro.id),
                    style: pw.TextStyle(fontSize: 13, color: mid)),
                pw.Text(dateStr,
                    style: pw.TextStyle(fontSize: 13, color: mid)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Divider(color: accent, thickness: 1.5),
        pw.SizedBox(height: 16),

        // ── Bill To / Vehicle ────────────────────────────────────────────────
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('BILL TO',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: mid,
                          letterSpacing: 1.0)),
                  pw.SizedBox(height: 6),
                  pw.Text(customer.name,
                      style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: dark)),
                  if (customer.phone?.isNotEmpty == true)
                    pw.Text(customer.phone!,
                        style: pw.TextStyle(fontSize: 12, color: dark)),
                  if (customer.email?.isNotEmpty == true)
                    pw.Text(customer.email!,
                        style: pw.TextStyle(fontSize: 12, color: dark)),
                ],
              ),
            ),
            if (vehicle != null)
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('VEHICLE',
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: mid,
                            letterSpacing: 1.0)),
                    pw.SizedBox(height: 6),
                    if (vehicleLabel != null)
                      pw.Text(vehicleLabel,
                          style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                              color: dark)),
                    if (vin?.isNotEmpty == true)
                      pw.Text('VIN: $vin',
                          style: pw.TextStyle(fontSize: 12, color: dark)),
                    if (plate?.isNotEmpty == true && plate != 'NO PLATE')
                      pw.Text('Plate: $plate',
                          style: pw.TextStyle(fontSize: 12, color: dark)),
                  ],
                ),
              ),
          ],
        ),

        // ── Customer Complaints ───────────────────────────────────────────────
        if (customerComplaint != null && customerComplaint.isNotEmpty) ...[
          pw.SizedBox(height: 16),
          _sectionDivider('CUSTOMER CONCERN', accent),
          pw.SizedBox(height: 8),
          ...customerComplaint.split('\n').where((s) => s.isNotEmpty).map(
                (c) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• ',
                          style: pw.TextStyle(fontSize: 11, color: dark)),
                      pw.Expanded(
                        child: pw.Text(c,
                            style: pw.TextStyle(fontSize: 11, color: dark)),
                      ),
                    ],
                  ),
                ),
              ),
        ],

        pw.SizedBox(height: 24),

        // ── Services table ───────────────────────────────────────────────────
        if (rows.isNotEmpty) ...[
          _sectionDivider('SERVICES', accent),
          pw.SizedBox(height: 8),
          // Simple table header: Type | Description | Total
          pw.Container(
            color: light,
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: pw.Row(
              children: [
                pw.SizedBox(
                  width: 80,
                  child: pw.Text('Type',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: mid)),
                ),
                pw.Expanded(
                  child: pw.Text('Description',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: mid)),
                ),
                pw.SizedBox(
                  width: 80,
                  child: pw.Text('Total',
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: mid)),
                ),
              ],
            ),
          ),
          ...rows.map((r) => pw.Column(
                children: [
                  pw.Container(
                    padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8, vertical: 8),
                    child: pw.Row(
                      children: [
                        pw.SizedBox(
                          width: 80,
                          child: pw.Text(r.typeLabel,
                              style: pw.TextStyle(
                                  fontSize: 10, color: mid)),
                        ),
                        pw.Expanded(
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text(r.description,
                                  style: pw.TextStyle(
                                      fontSize: 11,
                                      fontWeight: pw.FontWeight.bold,
                                      color: dark)),
                              if (r.subtitle != null)
                                pw.Text(r.subtitle!,
                                    style: pw.TextStyle(
                                        fontSize: 9, color: mid)),
                            ],
                          ),
                        ),
                        pw.SizedBox(
                          width: 80,
                          child: pw.Text(_money(r.total),
                              textAlign: pw.TextAlign.right,
                              style: pw.TextStyle(
                                  fontSize: 11,
                                  fontWeight: pw.FontWeight.bold,
                                  color: dark)),
                        ),
                      ],
                    ),
                  ),
                  pw.Divider(color: light, thickness: 0.5),
                ],
              )),
          pw.SizedBox(height: 16),
        ],

        // ── Totals ────────────────────────────────────────────────────────────
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Container(
            width: 240,
            child: pw.Column(
              children: [
                pw.Divider(color: light, thickness: 0.5),
                _totalRow('Subtotal', _money(subtotal), dark, mid, false),
                if (taxRate > 0) ...[
                  pw.Divider(color: light, thickness: 0.5),
                  _totalRow(
                    'Tax (${taxRate.toStringAsFixed(taxRate % 1 == 0 ? 0 : 1)}%)',
                    _money(taxAmount),
                    dark,
                    mid,
                    false,
                  ),
                ],
                pw.Divider(color: accent, thickness: 1),
                _totalRow('Total', _money(total), dark, accent, true),
              ],
            ),
          ),
        ),

        pw.SizedBox(height: 40),

        // ── Declined items ────────────────────────────────────────────────────
        if (declinedItems.isNotEmpty) ...[
          _sectionDivider('DECLINED — NOT BILLED', mid),
          pw.SizedBox(height: 8),
          ...declinedItems.map((d) {
            final title = (d.type == 'labor' || d.type == 'other') &&
                    d.laborName != null
                ? d.laborName!
                : d.description;
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                children: [
                  pw.Expanded(
                    child: pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 10,
                        color: mid,
                        decoration: pw.TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                  pw.Text(
                    _money(d.quantity * d.unitPrice),
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: mid,
                      decoration: pw.TextDecoration.lineThrough,
                    ),
                  ),
                ],
              ),
            );
          }),
          pw.SizedBox(height: 24),
        ],

        // ── Invoice Comment ───────────────────────────────────────────────────
        if (comment != null && comment.isNotEmpty) ...[
          pw.Divider(color: light, thickness: 0.5),
          pw.SizedBox(height: 8),
          pw.Text(
            comment,
            style: pw.TextStyle(fontSize: 10, color: mid),
          ),
          pw.SizedBox(height: 16),
        ],

        pw.Center(
          child: pw.Text(
            'Thank you for your business.',
            style: pw.TextStyle(
                fontSize: 12,
                color: mid,
                fontStyle: pw.FontStyle.italic),
          ),
        ),
      ],
    ),
  );

  return doc.save();
}

// ─── Cupertino action sheet ───────────────────────────────────────────────────

/// Shows the Save / Print / Email action sheet for a closed RO.
/// [simple] = true uses the simple (combined) invoice layout.
Future<void> showInvoiceActions({
  required BuildContext context,
  required RepairOrder ro,
  required Customer customer,
  required Vehicle? vehicle,
  required List<EstimateLineItem> lineItems,
  required double taxRate,
  required String? shopName,
  String? customerComplaint,
  String? comment,
  List<EstimateLineItem> declinedItems = const [],
  bool simple = false,
  Offset? position,
}) async {
  if ((Platform.isMacOS || Platform.isWindows) && position != null) {
    showContextMenu(
      context: context,
      position: position,
      items: [
        ContextMenuAction(
          label: 'Save as PDF',
          icon: CupertinoIcons.arrow_down_doc,
          onTap: () => _handleSave(context, ro, customer, vehicle, lineItems,
              taxRate, shopName, customerComplaint, simple,
              comment: comment, declinedItems: declinedItems),
        ),
        ContextMenuAction(
          label: 'Print',
          icon: CupertinoIcons.printer,
          onTap: () => _handlePrint(context, ro, customer, vehicle, lineItems,
              taxRate, shopName, customerComplaint, simple,
              comment: comment, declinedItems: declinedItems),
        ),
        ContextMenuAction(
          label: 'Email',
          icon: CupertinoIcons.mail,
          onTap: () => _handleEmail(context, ro, customer, vehicle, lineItems,
              taxRate, shopName, customerComplaint, simple,
              comment: comment, declinedItems: declinedItems),
        ),
      ],
    );
    return;
  }
  await showCupertinoModalPopup<void>(
    context: context,
    builder: (sheetCtx) => CupertinoActionSheet(
      title: Text(simple ? 'Simple Invoice' : 'Itemized Invoice'),
      message: Text('${_roNumber(ro.id)} — ${customer.name}'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(sheetCtx);
            await _handleSave(context, ro, customer, vehicle, lineItems,
                taxRate, shopName, customerComplaint, simple,
                comment: comment, declinedItems: declinedItems);
          },
          child: const Text('Save as PDF'),
        ),
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(sheetCtx);
            await _handlePrint(context, ro, customer, vehicle, lineItems,
                taxRate, shopName, customerComplaint, simple,
                comment: comment, declinedItems: declinedItems);
          },
          child: const Text('Print'),
        ),
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(sheetCtx);
            await _handleEmail(context, ro, customer, vehicle, lineItems,
                taxRate, shopName, customerComplaint, simple,
                comment: comment, declinedItems: declinedItems);
          },
          child: const Text('Email'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        isDestructiveAction: false,
        onPressed: () => Navigator.pop(sheetCtx),
        child: const Text('Cancel'),
      ),
    ),
  );
}

Future<Uint8List> _buildBytes(
  RepairOrder ro,
  Customer customer,
  Vehicle? vehicle,
  List<EstimateLineItem> lineItems,
  double taxRate,
  String? shopName,
  String? customerComplaint,
  bool simple, {
  String? comment,
  List<EstimateLineItem> declinedItems = const [],
}) =>
    simple
        ? buildSimpleInvoicePdf(
            ro: ro,
            customer: customer,
            vehicle: vehicle,
            lineItems: lineItems,
            taxRate: taxRate,
            shopName: shopName,
            customerComplaint: customerComplaint,
            comment: comment,
            declinedItems: declinedItems,
          )
        : buildInvoicePdf(
            ro: ro,
            customer: customer,
            vehicle: vehicle,
            lineItems: lineItems,
            taxRate: taxRate,
            shopName: shopName,
            customerComplaint: customerComplaint,
            comment: comment,
            declinedItems: declinedItems,
          );

Future<void> _handleSave(
  BuildContext context,
  RepairOrder ro,
  Customer customer,
  Vehicle? vehicle,
  List<EstimateLineItem> lineItems,
  double taxRate,
  String? shopName,
  String? customerComplaint,
  bool simple, {
  String? comment,
  List<EstimateLineItem> declinedItems = const [],
}) async {
  try {
    final bytes = await _buildBytes(
        ro, customer, vehicle, lineItems, taxRate, shopName, customerComplaint, simple,
        comment: comment, declinedItems: declinedItems);
    final path = await saveInvoiceToDownloads(bytes, ro.id);
    final fileName = path.split('/').last;
    if (context.mounted) {
      showCupertinoDialog(
        context: context,
        builder: (dialogCtx) => CupertinoAlertDialog(
          title: const Text('Saved to Downloads'),
          content: Text(fileName),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('OK'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(dialogCtx);
                Process.run('open', [path]);
              },
              child: const Text('Open'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    if (context.mounted) _showError(context, e);
  }
}

Future<void> _handlePrint(
  BuildContext context,
  RepairOrder ro,
  Customer customer,
  Vehicle? vehicle,
  List<EstimateLineItem> lineItems,
  double taxRate,
  String? shopName,
  String? customerComplaint,
  bool simple, {
  String? comment,
  List<EstimateLineItem> declinedItems = const [],
}) async {
  try {
    final bytes = await _buildBytes(
        ro, customer, vehicle, lineItems, taxRate, shopName, customerComplaint, simple,
        comment: comment, declinedItems: declinedItems);
    final path = await saveInvoiceToTemp(bytes, ro.id);
    await openInPreview(path);
    if (context.mounted) {
      showCupertinoDialog(
        context: context,
        builder: (dialogCtx) => CupertinoAlertDialog(
          title: const Text('Opened in Preview'),
          content: const Text('Press ⌘P in Preview to print.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    if (context.mounted) _showError(context, e);
  }
}

Future<void> _handleEmail(
  BuildContext context,
  RepairOrder ro,
  Customer customer,
  Vehicle? vehicle,
  List<EstimateLineItem> lineItems,
  double taxRate,
  String? shopName,
  String? customerComplaint,
  bool simple, {
  String? comment,
  List<EstimateLineItem> declinedItems = const [],
}) async {
  try {
    final bytes = await _buildBytes(
        ro, customer, vehicle, lineItems, taxRate, shopName, customerComplaint, simple,
        comment: comment, declinedItems: declinedItems);
    final path = await saveInvoiceToTemp(bytes, ro.id);
    await openInMailWithAttachment(
      filePath: path,
      roNumber: _roNumber(ro.id),
      customerName: customer.name,
      customerEmail: customer.email,
    );
  } catch (e) {
    if (context.mounted) _showError(context, e);
  }
}

void _showError(BuildContext context, Object e) {
  showCupertinoDialog(
    context: context,
    builder: (dialogCtx) => CupertinoAlertDialog(
      title: const Text('Error'),
      content: Text(e.toString()),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: () => Navigator.pop(dialogCtx),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}

// ─── Estimate PDF builder ─────────────────────────────────────────────────────

String _estimateNumber(int id) => 'EST-${id.toString().padLeft(4, '0')}';

/// Builds an estimate PDF — same layout as the invoice but labelled "ESTIMATE".
Future<Uint8List> buildEstimatePdf({
  required Estimate estimate,
  required Customer customer,
  required Vehicle? vehicle,
  required List<EstimateLineItem> lineItems,
  required String? shopName,
}) async {
  final doc = pw.Document();

  final labor = lineItems.where((l) => l.type == 'labor').toList();
  final parts = lineItems.where((l) => l.type == 'part').toList();

  final activeItems =
      lineItems.where((l) => l.approvalStatus != 'declined').toList();
  final declinedItems =
      lineItems.where((l) => l.approvalStatus == 'declined').toList();
  final subtotal =
      activeItems.fold(0.0, (s, l) => s + l.quantity * l.unitPrice);
  final taxAmount = subtotal * (estimate.taxRate / 100);
  final total = subtotal + taxAmount;
  final declinedTotal =
      declinedItems.fold(0.0, (s, l) => s + l.quantity * l.unitPrice);

  const accent = PdfColor.fromInt(0xFF007AFF);
  const dark = PdfColor.fromInt(0xFF1C1C1E);
  const mid = PdfColor.fromInt(0xFF8E8E93);
  const light = PdfColor.fromInt(0xFFE5E5EA);
  const red = PdfColor.fromInt(0xFFFF3B30);

  final d = estimate.createdAt;
  final dateStr =
      '${d.month.toString().padLeft(2, '0')}/${d.day.toString().padLeft(2, '0')}/${d.year}';

  final vehicleLabel = vehicle != null
      ? [vehicle.year?.toString(), vehicle.make, vehicle.model]
          .whereType<String>()
          .join(' ')
      : null;
  final vin = vehicle?.vin;
  final plate = vehicle?.licensePlate;

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.letter,
      margin: const pw.EdgeInsets.all(40),
      build: (pw.Context context) => [
        // ── Header ──────────────────────────────────────────────────────────
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Text(
                shopName?.isNotEmpty == true ? shopName! : 'AutoShopPro',
                style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    color: dark),
              ),
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text('ESTIMATE',
                    style: pw.TextStyle(
                        fontSize: 28,
                        fontWeight: pw.FontWeight.bold,
                        color: accent)),
                pw.SizedBox(height: 4),
                pw.Text(_estimateNumber(estimate.id),
                    style: pw.TextStyle(fontSize: 13, color: mid)),
                pw.Text(dateStr,
                    style: pw.TextStyle(fontSize: 13, color: mid)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Divider(color: accent, thickness: 1.5),
        pw.SizedBox(height: 16),

        // ── Bill To / Vehicle ────────────────────────────────────────────────
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('BILL TO',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: mid,
                          letterSpacing: 1.0)),
                  pw.SizedBox(height: 6),
                  pw.Text(customer.name,
                      style: pw.TextStyle(
                          fontSize: 13,
                          fontWeight: pw.FontWeight.bold,
                          color: dark)),
                  if (customer.phone?.isNotEmpty == true)
                    pw.Text(customer.phone!,
                        style: pw.TextStyle(fontSize: 12, color: dark)),
                  if (customer.email?.isNotEmpty == true)
                    pw.Text(customer.email!,
                        style: pw.TextStyle(fontSize: 12, color: dark)),
                ],
              ),
            ),
            if (vehicle != null)
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('VEHICLE',
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: mid,
                            letterSpacing: 1.0)),
                    pw.SizedBox(height: 6),
                    if (vehicleLabel != null)
                      pw.Text(vehicleLabel,
                          style: pw.TextStyle(
                              fontSize: 13,
                              fontWeight: pw.FontWeight.bold,
                              color: dark)),
                    if (vin?.isNotEmpty == true)
                      pw.Text('VIN: $vin',
                          style: pw.TextStyle(fontSize: 12, color: dark)),
                    if (plate?.isNotEmpty == true && plate != 'NO PLATE')
                      pw.Text('Plate: $plate',
                          style: pw.TextStyle(fontSize: 12, color: dark)),
                  ],
                ),
              ),
          ],
        ),

        if (estimate.customerComplaint?.isNotEmpty == true) ...[
          pw.SizedBox(height: 16),
          _sectionDivider('CUSTOMER CONCERN', accent),
          pw.SizedBox(height: 8),
          ...estimate.customerComplaint!
              .split('\n')
              .where((s) => s.isNotEmpty)
              .map(
                (c) => pw.Padding(
                  padding: const pw.EdgeInsets.only(bottom: 4),
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('• ',
                          style: pw.TextStyle(fontSize: 11, color: dark)),
                      pw.Expanded(
                        child: pw.Text(c,
                            style: pw.TextStyle(fontSize: 11, color: dark)),
                      ),
                    ],
                  ),
                ),
              ),
        ],

        pw.SizedBox(height: 24),

        // ── Line items ───────────────────────────────────────────────────────
        if (labor.isNotEmpty || parts.isNotEmpty) ...[
          _sectionDivider('LABOR', accent),
          pw.SizedBox(height: 8),
          _tableHeaderWithType(light, mid),
          ...labor.expand((l) {
            if (l.approvalStatus == 'declined') return const <pw.Widget>[];
            final linkedParts =
                parts.where((p) => p.parentLaborId == l.id).toList();
            return [
              _lineRow(
                typeLabel: 'Labor',
                description: l.laborName ?? l.description,
                subtitle: l.laborName != null ? l.description : null,
                qty: '${_qty(l.quantity)} hr',
                unit: _money(l.unitPrice),
                total: _money(l.quantity * l.unitPrice),
                isLabor: true,
                dark: dark,
                mid: mid,
                light: light,
              ),
              ...linkedParts
                  .where((p) => p.approvalStatus != 'declined')
                  .map((p) => _lineRow(
                        typeLabel: 'Part',
                        description: p.description,
                        qty: _qty(p.quantity),
                        unit: _money(p.unitPrice),
                        total: _money(p.quantity * p.unitPrice),
                        isLabor: false,
                        dark: dark,
                        mid: mid,
                        light: light,
                      )),
            ];
          }),
          ...parts
              .where((p) =>
                  p.parentLaborId == null && p.approvalStatus != 'declined')
              .map((p) => _lineRow(
                    typeLabel: 'Part',
                    description: p.description,
                    qty: _qty(p.quantity),
                    unit: _money(p.unitPrice),
                    total: _money(p.quantity * p.unitPrice),
                    isLabor: false,
                    dark: dark,
                    mid: mid,
                    light: light,
                  )),
          pw.SizedBox(height: 16),
        ],

        // ── Totals ────────────────────────────────────────────────────────────
        pw.Align(
          alignment: pw.Alignment.centerRight,
          child: pw.Container(
            width: 240,
            child: pw.Column(
              children: [
                pw.Divider(color: light, thickness: 0.5),
                _totalRow('Subtotal', _money(subtotal), dark, mid, false),
                if (estimate.taxRate > 0) ...[
                  pw.Divider(color: light, thickness: 0.5),
                  _totalRow(
                    'Tax (${estimate.taxRate.toStringAsFixed(estimate.taxRate % 1 == 0 ? 0 : 1)}%)',
                    _money(taxAmount),
                    dark,
                    mid,
                    false,
                  ),
                ],
                if (declinedItems.isNotEmpty) ...[
                  pw.Divider(color: light, thickness: 0.5),
                  _totalRow(
                    '${declinedItems.length} item${declinedItems.length == 1 ? '' : 's'} declined',
                    '−${_money(declinedTotal)}',
                    red,
                    red,
                    false,
                  ),
                ],
                pw.Divider(color: accent, thickness: 1),
                _totalRow('Total', _money(total), dark, accent, true),
              ],
            ),
          ),
        ),

        pw.SizedBox(height: 40),

        pw.Center(
          child: pw.Text(
            'This is an estimate — final charges may vary.',
            style: pw.TextStyle(
                fontSize: 12, color: mid, fontStyle: pw.FontStyle.italic),
          ),
        ),
      ],
    ),
  );

  return doc.save();
}

/// Shows the Save / Print / Email action sheet for an estimate.
Future<void> showEstimateActions({
  required BuildContext context,
  required Estimate estimate,
  required Customer customer,
  required Vehicle? vehicle,
  required List<EstimateLineItem> lineItems,
  required String? shopName,
  Offset? position,
}) async {
  if ((Platform.isMacOS || Platform.isWindows) && position != null) {
    showContextMenu(
      context: context,
      position: position,
      items: [
        ContextMenuAction(
          label: 'Save as PDF',
          icon: CupertinoIcons.arrow_down_doc,
          onTap: () => _handleEstimateSave(
              context, estimate, customer, vehicle, lineItems, shopName),
        ),
        ContextMenuAction(
          label: 'Print',
          icon: CupertinoIcons.printer,
          onTap: () => _handleEstimatePrint(
              context, estimate, customer, vehicle, lineItems, shopName),
        ),
        ContextMenuAction(
          label: 'Email',
          icon: CupertinoIcons.mail,
          onTap: () => _handleEstimateEmail(
              context, estimate, customer, vehicle, lineItems, shopName),
        ),
      ],
    );
    return;
  }
  await showCupertinoModalPopup<void>(
    context: context,
    builder: (sheetCtx) => CupertinoActionSheet(
      title: const Text('Estimate PDF'),
      message: Text('${_estimateNumber(estimate.id)} — ${customer.name}'),
      actions: [
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(sheetCtx);
            await _handleEstimateSave(
                context, estimate, customer, vehicle, lineItems, shopName);
          },
          child: const Text('Save as PDF'),
        ),
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(sheetCtx);
            await _handleEstimatePrint(
                context, estimate, customer, vehicle, lineItems, shopName);
          },
          child: const Text('Print'),
        ),
        CupertinoActionSheetAction(
          onPressed: () async {
            Navigator.pop(sheetCtx);
            await _handleEstimateEmail(
                context, estimate, customer, vehicle, lineItems, shopName);
          },
          child: const Text('Email'),
        ),
      ],
      cancelButton: CupertinoActionSheetAction(
        onPressed: () => Navigator.pop(sheetCtx),
        child: const Text('Cancel'),
      ),
    ),
  );
}

Future<void> _handleEstimateSave(
  BuildContext context,
  Estimate estimate,
  Customer customer,
  Vehicle? vehicle,
  List<EstimateLineItem> lineItems,
  String? shopName,
) async {
  try {
    final bytes = await buildEstimatePdf(
        estimate: estimate,
        customer: customer,
        vehicle: vehicle,
        lineItems: lineItems,
        shopName: shopName);
    final dir = await getDownloadsDirectory();
    final folder = dir ?? await getTemporaryDirectory();
    final fileName = 'Estimate-${_estimateNumber(estimate.id)}.pdf';
    final file = File('${folder.path}/$fileName');
    await file.writeAsBytes(bytes);
    if (context.mounted) {
      showCupertinoDialog(
        context: context,
        builder: (dialogCtx) => CupertinoAlertDialog(
          title: const Text('Saved to Downloads'),
          content: Text(fileName),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('OK'),
            ),
            CupertinoDialogAction(
              onPressed: () {
                Navigator.pop(dialogCtx);
                Process.run('open', [file.path]);
              },
              child: const Text('Open'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    if (context.mounted) _showError(context, e);
  }
}

Future<void> _handleEstimatePrint(
  BuildContext context,
  Estimate estimate,
  Customer customer,
  Vehicle? vehicle,
  List<EstimateLineItem> lineItems,
  String? shopName,
) async {
  try {
    final bytes = await buildEstimatePdf(
        estimate: estimate,
        customer: customer,
        vehicle: vehicle,
        lineItems: lineItems,
        shopName: shopName);
    final path = await saveInvoiceToTemp(bytes, estimate.id);
    await openInPreview(path);
    if (context.mounted) {
      showCupertinoDialog(
        context: context,
        builder: (dialogCtx) => CupertinoAlertDialog(
          title: const Text('Opened in Preview'),
          content: const Text('Press ⌘P in Preview to print.'),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.pop(dialogCtx),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  } catch (e) {
    if (context.mounted) _showError(context, e);
  }
}

Future<void> _handleEstimateEmail(
  BuildContext context,
  Estimate estimate,
  Customer customer,
  Vehicle? vehicle,
  List<EstimateLineItem> lineItems,
  String? shopName,
) async {
  try {
    final bytes = await buildEstimatePdf(
        estimate: estimate,
        customer: customer,
        vehicle: vehicle,
        lineItems: lineItems,
        shopName: shopName);
    final path = await saveInvoiceToTemp(bytes, estimate.id);
    await openInMailWithAttachment(
      filePath: path,
      roNumber: _estimateNumber(estimate.id),
      customerName: customer.name,
      customerEmail: customer.email,
    );
  } catch (e) {
    if (context.mounted) _showError(context, e);
  }
}
