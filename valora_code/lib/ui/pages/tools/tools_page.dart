import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../config/routes/app_router.dart';
import '../../../config/theme/app_theme.dart';
import '../../widgets/owl_mascot.dart';

class ToolsPage extends StatelessWidget {
  const ToolsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Herramientas',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 8),
              // ── Búho meditando ─────────────────────────────────────────
              const OwlMascot(
                scenario: OwlScenario.meditation,
                size: 150,
                label: 'Todo bajo control 🧘',
              ),
              const SizedBox(height: 32),
              // ── Grid de herramientas ───────────────────────────────────
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 1.1,
                children: [
                  _ToolCard(
                    icon: Icons.picture_as_pdf_outlined,
                    label: 'Cotización PDF',
                    description: 'Genera cotizaciones\npara tus clientes',
                    color: const Color(0xFF6C5BE7),
                    onTap: () => context.push(AppRouter.quotation),
                  ),
                  _ToolCard(
                    icon: Icons.cloud_upload_outlined,
                    label: 'Respaldo',
                    description: 'Exporta e importa\ntus datos',
                    color: const Color(0xFF3A8FC8),
                    onTap: () => context.push(AppRouter.backup),
                  ),
                  _ToolCard(
                    icon: Icons.inventory_2_outlined,
                    label: 'Productos',
                    description: 'Administra tu\ncatálogo',
                    color: const Color(0xFF2E9E6B),
                    onTap: () => context.push(AppRouter.productNew),
                  ),
                  _ToolCard(
                    icon: Icons.dashboard_outlined,
                    label: 'Dashboard',
                    description: 'Vista avanzada\nde métricas',
                    color: const Color(0xFFB85A9E),
                    onTap: () => context.push(AppRouter.dashboard),
                  ),
                  _ToolCard(
                    icon: Icons.people_outline,
                    label: 'Clientes',
                    description: 'Gestiona tus\nclientes',
                    color: const Color(0xFFE87B3A),
                    onTap: () => context.push(AppRouter.clients),
                  ),
                  _ToolCard(
                    icon: Icons.receipt_long_outlined,
                    label: 'Cuentas de Cobro',
                    description: 'Crea y consulta\ncuentas',
                    color: const Color(0xFF5E7C3A),
                    onTap: () => context.push(AppRouter.invoices),
                  ),
                  _ToolCard(
                    icon: Icons.business_outlined,
                    label: 'Config. Emisor',
                    description: 'Datos de tu\nempresa',
                    color: const Color(0xFF8B5E9E),
                    onTap: () => context.push(AppRouter.issuerConfig),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final VoidCallback onTap;

  const _ToolCard({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.35), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 11,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
