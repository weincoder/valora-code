import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../config/providers/invoice_provider.dart';
import '../../../domain/models/invoice/invoice.dart';
import '../../widgets/invoice/currency_format_helper.dart';
import '../../widgets/invoice/invoice_line_tile.dart';
import '../../widgets/invoice/invoice_summary_card.dart';

class InvoiceDetailPage extends ConsumerStatefulWidget {
  final String invoiceId;

  const InvoiceDetailPage({super.key, required this.invoiceId});

  @override
  ConsumerState<InvoiceDetailPage> createState() => _InvoiceDetailPageState();
}

class _InvoiceDetailPageState extends ConsumerState<InvoiceDetailPage> {
  bool _isGenerating = false;

  Future<Uint8List> _buildPdf(Invoice invoice) async {
    final doc = pw.Document();
    final issuer = invoice.issuerSnapshot;
    final client = invoice.clientSnapshot;
    final accentPdf = PdfColor.fromHex('#4233CE');
    final primaryPdf = PdfColor.fromHex('#1A0047');

    pw.MemoryImage? clientImage;
    if (client.imageBase64 != null) {
      clientImage = pw.MemoryImage(base64Decode(client.imageBase64!));
    }

    final dateStr =
        '${invoice.createdAt.day.toString().padLeft(2, '0')}/'
        '${invoice.createdAt.month.toString().padLeft(2, '0')}/'
        '${invoice.createdAt.year}';

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (_) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  issuer.businessName,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryPdf,
                  ),
                ),
                pw.Text(
                  'NIT: ${issuer.nit}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
                pw.Text(
                  issuer.address,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'Cuenta de Cobro',
                  style: pw.TextStyle(fontSize: 20, color: accentPdf),
                ),
                pw.Text(
                  'N° ${invoice.invoiceNumber}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                    color: primaryPdf,
                  ),
                ),
                pw.Text(
                  'Fecha: $dateStr',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        build: (_) => [
          pw.SizedBox(height: 24),
          // Client section
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColors.grey100,
              borderRadius: pw.BorderRadius.circular(6),
            ),
            child: pw.Row(
              children: [
                if (clientImage != null) ...[
                  pw.ClipOval(
                    child: pw.Image(clientImage, width: 48, height: 48),
                  ),
                  pw.SizedBox(width: 12),
                ],
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      client.fullName,
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    pw.Text(
                      'Doc: ${client.documentId}',
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      client.email,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                    pw.Text(
                      client.phone,
                      style: const pw.TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),
          // Lines table
          pw.TableHelper.fromTextArray(
            headers: ['Ítem', 'Cant.', 'Precio Unit.', 'Subtotal'],
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 10,
            ),
            headerDecoration: pw.BoxDecoration(color: primaryPdf),
            cellStyle: const pw.TextStyle(fontSize: 10),
            data: invoice.lines
                .map(
                  (l) => [
                    l.itemName,
                    '${l.quantity}',
                    formatCop(l.unitPrice),
                    formatCop(l.subtotal),
                  ],
                )
                .toList(),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
            },
          ),
          pw.SizedBox(height: 16),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Container(
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  color: accentPdf,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  'Total: ${formatCop(invoice.total)}',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );

    return doc.save();
  }

  Future<void> _downloadPdf(Invoice invoice) async {
    setState(() => _isGenerating = true);
    try {
      final bytes = await _buildPdf(invoice);
      await Printing.layoutPdf(onLayout: (_) => bytes);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(invoiceProvider);

    if (state.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final Invoice? invoice = state.invoices
        .where((inv) => inv.id == widget.invoiceId)
        .firstOrNull;

    if (invoice == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Cuenta de Cobro')),
        body: const Center(child: Text('Cuenta no encontrada')),
      );
    }

    final issuer = invoice.issuerSnapshot;
    final client = invoice.clientSnapshot;
    final dateStr =
        '${invoice.createdAt.day.toString().padLeft(2, '0')}/'
        '${invoice.createdAt.month.toString().padLeft(2, '0')}/'
        '${invoice.createdAt.year}';

    return Scaffold(
      appBar: AppBar(
        title: Text(invoice.invoiceNumber),
        actions: [
          _isGenerating
              ? const Padding(
                  padding: EdgeInsets.all(14),
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                )
              : IconButton(
                  key: const Key('download-pdf-button'),
                  tooltip: 'Descargar PDF',
                  icon: const Icon(Icons.picture_as_pdf_outlined),
                  onPressed: () => _downloadPdf(invoice),
                ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Issuer section
            Text(
              'Datos del Emisor',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(issuer.businessName),
            Text('NIT: ${issuer.nit}'),
            Text(issuer.address),
            const Divider(height: 24),

            // Invoice metadata
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'N° ${invoice.invoiceNumber}',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                Text(dateStr),
              ],
            ),
            const Divider(height: 24),

            // Client section
            Text('Cliente', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(client.fullName),
            Text('Doc: ${client.documentId}'),
            Text(client.email),
            Text(client.phone),
            const Divider(height: 24),

            // Lines
            Text('Ítems', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            ...invoice.lines.map((line) => InvoiceLineTile(line: line)),
            const SizedBox(height: 16),

            // Summary
            InvoiceSummaryCard(total: invoice.total),
          ],
        ),
      ),
    );
  }
}
