import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../config/providers/product_item_provider.dart';
import '../../../config/providers/client_provider.dart';
import '../../../config/providers/invoice_provider.dart';
import '../../../config/routes/app_router.dart';
import '../../../domain/models/invoice/invoice_line.dart';
import '../../../ui/widgets/invoice/currency_format_helper.dart';

class InvoiceFormPage extends ConsumerStatefulWidget {
  const InvoiceFormPage({super.key});

  @override
  ConsumerState<InvoiceFormPage> createState() => _InvoiceFormPageState();
}

class _InvoiceFormPageState extends ConsumerState<InvoiceFormPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkClients());
  }

  void _checkClients() {
    final clients = ref.read(clientProvider).clients;
    if (clients.isEmpty && mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: const Text('Sin clientes'),
          content: const Text(
            'Debes registrar al menos un cliente antes de crear una cuenta de cobro.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.pop();
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                context.push(AppRouter.clientNew);
              },
              child: const Text('Registrar cliente'),
            ),
          ],
        ),
      );
    }
  }

  Future<bool> _confirmDiscard() async {
    final draftLines = ref.read(invoiceProvider).draftLines;
    if (draftLines.isEmpty) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Descartar cambios?'),
        content: const Text(
          'Tienes líneas sin guardar. ¿Deseas salir sin crear la cuenta?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Seguir editando'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Descartar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    final invoiceState = ref.watch(invoiceProvider);
    final clientState = ref.watch(clientProvider);
    final productItemState = ref.watch(productItemProvider);

    final selectedClient = clientState.clients
        .where((c) => c.id == invoiceState.selectedClientId)
        .firstOrNull;

    final draftTotal = invoiceState.draftLines.fold(
      0.0,
      (sum, l) => sum + l.subtotal,
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) async {
        if (didPop) return;
        final shouldPop = await _confirmDiscard();
        if (shouldPop && context.mounted) {
          ref.read(invoiceProvider.notifier).clearDraft();
          context.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Nueva Cuenta de Cobro')),
        body: invoiceState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Client selector
                          DropdownButtonFormField<String>(
                            initialValue: invoiceState.selectedClientId,
                            decoration: const InputDecoration(
                              labelText: 'Cliente',
                            ),
                            items: clientState.clients
                                .map(
                                  (c) => DropdownMenuItem(
                                    value: c.id,
                                    child: Text(
                                      '${c.fullName} · ${c.documentId}',
                                    ),
                                  ),
                                )
                                .toList(),
                            onChanged: (id) {
                              if (id != null) {
                                ref
                                    .read(invoiceProvider.notifier)
                                    .selectClient(id);
                              }
                            },
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Líneas',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          if (invoiceState.draftLines.isEmpty)
                            const Text('Sin líneas. Agrega un ítem.'),
                          ...invoiceState.draftLines.asMap().entries.map((
                            entry,
                          ) {
                            final i = entry.key;
                            final line = entry.value;
                            return ListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(line.itemName),
                              subtitle: Text(
                                '${line.quantity} × ${formatCop(line.unitPrice)} = ${formatCop(line.subtotal)}',
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () => ref
                                    .read(invoiceProvider.notifier)
                                    .removeLine(i),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          OutlinedButton.icon(
                            onPressed: productItemState.items.isEmpty
                                ? null
                                : () => _showAddLineDialog(context, ref),
                            icon: const Icon(Icons.add),
                            label: const Text('Agregar ítem'),
                          ),
                          if (invoiceState.error != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                invoiceState.error!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                  // Footer with total and save button
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Total'),
                                Text(
                                  formatCop(draftTotal),
                                  style: Theme.of(context).textTheme.titleLarge,
                                ),
                              ],
                            ),
                          ),
                          FilledButton(
                            onPressed:
                                selectedClient == null ||
                                    invoiceState.draftLines.isEmpty
                                ? null
                                : () async {
                                    await ref
                                        .read(invoiceProvider.notifier)
                                        .createInvoice(selectedClient);
                                    if (!context.mounted) return;
                                    final err = ref.read(invoiceProvider).error;
                                    if (err != null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(err)),
                                      );
                                    } else {
                                      context.pop();
                                    }
                                  },
                            child: const Text('Guardar'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  void _showAddLineDialog(BuildContext context, WidgetRef ref) {
    final items = ref.read(productItemProvider).items;
    String? selectedItemId = items.first.id;
    int quantity = 1;

    showDialog<void>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocalState) => AlertDialog(
          title: const Text('Agregar ítem'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                initialValue: selectedItemId,
                items: items
                    .map(
                      (i) =>
                          DropdownMenuItem(value: i.id, child: Text(i.title)),
                    )
                    .toList(),
                onChanged: (id) => setLocalState(() => selectedItemId = id),
                decoration: const InputDecoration(labelText: 'Ítem'),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  IconButton(
                    onPressed: quantity > 1
                        ? () => setLocalState(() => quantity--)
                        : null,
                    icon: const Icon(Icons.remove),
                  ),
                  Text('$quantity'),
                  IconButton(
                    onPressed: () => setLocalState(() => quantity++),
                    icon: const Icon(Icons.add),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                final item = items.firstWhere((i) => i.id == selectedItemId);
                ref
                    .read(invoiceProvider.notifier)
                    .addLine(
                      InvoiceLine(
                        productItemId: item.id,
                        itemName: item.title,
                        unitPrice: item.salePrice,
                        quantity: quantity,
                      ),
                    );
                Navigator.of(ctx).pop();
              },
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }
}
