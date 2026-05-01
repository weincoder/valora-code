import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../config/providers/product_item_provider.dart';
import '../../../config/theme/app_theme.dart';
import '../../../domain/models/product_item/product_item.dart';

class QuotationPage extends ConsumerStatefulWidget {
  const QuotationPage({super.key});

  @override
  ConsumerState<QuotationPage> createState() => _QuotationPageState();
}

class _QuotationPageState extends ConsumerState<QuotationPage> {
  final Set<String> _selectedIds = {};
  String? _logoBase64;
  String _companyName = '';
  bool _isGenerating = false;

  Future<void> _pickLogo() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() => _logoBase64 = base64Encode(bytes));
  }

  List<ProductItem> _selectedProducts(List<ProductItem> all) =>
      all.where((p) => _selectedIds.contains(p.id)).toList();

  Future<Uint8List> _buildPdf(List<ProductItem> selected) async {
    final doc = pw.Document();
    pw.MemoryImage? logoImage;
    if (_logoBase64 != null) {
      logoImage = pw.MemoryImage(base64Decode(_logoBase64!));
    }

    final accentPdf = PdfColor.fromHex('#4233CE');
    final primaryPdf = PdfColor.fromHex('#1A0047');
    final total = selected.fold<double>(0, (sum, p) => sum + p.salePrice);

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (context) => pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            if (logoImage != null)
              pw.Image(logoImage, width: 60, height: 60)
            else
              pw.SizedBox(width: 60),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                if (_companyName.isNotEmpty)
                  pw.Text(
                    _companyName,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                      color: primaryPdf,
                    ),
                  ),
                pw.Text(
                  'Cotización',
                  style: pw.TextStyle(fontSize: 24, color: accentPdf),
                ),
                pw.Text(
                  'Fecha: ${DateTime.now().toLocal().toString().split(' ').first}',
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ],
            ),
          ],
        ),
        build: (context) => [
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Producto', 'Descripción', 'Precio'],
            headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
            ),
            headerDecoration: pw.BoxDecoration(color: primaryPdf),
            data: selected
                .map(
                  (p) => [
                    p.title,
                    p.description.length > 60
                        ? '${p.description.substring(0, 60)}...'
                        : p.description,
                    '\$${p.salePrice.toStringAsFixed(2)}',
                  ],
                )
                .toList(),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerRight,
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
                  'Total: \$${total.toStringAsFixed(2)}',
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

  Future<void> _generatePdf(List<ProductItem> all) async {
    final selected = _selectedProducts(all);
    if (selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un producto')),
      );
      return;
    }
    setState(() => _isGenerating = true);
    try {
      final bytes = await _buildPdf(selected);
      await Printing.layoutPdf(onLayout: (_) => bytes);
    } finally {
      if (mounted) setState(() => _isGenerating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(productItemProvider);
    final items = state.items;

    return Scaffold(
      appBar: AppBar(title: const Text('Generar Cotización')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  key: const Key('company-name-field'),
                  decoration: const InputDecoration(
                    labelText: 'Nombre de la empresa',
                    prefixIcon: Icon(Icons.business),
                  ),
                  onChanged: (v) => setState(() => _companyName = v),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  key: const Key('pick-logo-button'),
                  onPressed: _pickLogo,
                  icon: Icon(
                    _logoBase64 != null
                        ? Icons.check_circle
                        : Icons.add_photo_alternate,
                  ),
                  label: Text(
                    _logoBase64 != null ? 'Logo seleccionado' : 'Agregar logo',
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Selecciona los productos para la cotización:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              key: const Key('quotation-products-list'),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final product = items[index];
                final selected = _selectedIds.contains(product.id);
                return CheckboxListTile(
                  key: Key('quotation-check-${product.id}'),
                  value: selected,
                  title: Text(product.title),
                  subtitle: Text('\$${product.salePrice.toStringAsFixed(2)}'),
                  activeColor: AppTheme.accentColor,
                  onChanged: (v) {
                    setState(() {
                      if (v == true) {
                        _selectedIds.add(product.id);
                      } else {
                        _selectedIds.remove(product.id);
                      }
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              key: const Key('generate-pdf-button'),
              onPressed: _isGenerating ? null : () => _generatePdf(items),
              icon: _isGenerating
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.picture_as_pdf),
              label: const Text('Generar PDF'),
            ),
          ),
        ],
      ),
    );
  }
}
