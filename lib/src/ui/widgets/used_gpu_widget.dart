import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:what_to_mine/src/data/client/what_to_mine_client.dart';
import 'package:what_to_mine/src/domain/gpu/used_gpu.dart';
import '../design/app_ui.dart';

class UsedGpuWidget extends StatelessWidget {
  final UsedGpu usedGpu;
  final VoidCallback? onDelete;
  const UsedGpuWidget(this.usedGpu, {this.onDelete, super.key});

  @override
  Widget build(BuildContext context) {
    final vendor = WhatToMineClient.gpuVendor(
      usedGpu.gpuData.marketingName,
      usedGpu.gpuData.vendor,
    ).toUpperCase();
    final color = vendor == 'AMD'
        ? const Color(0xFFBB5C40)
        : Theme.of(context).colorScheme.primary;
    return SurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: .09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(Icons.memory_rounded, color: color, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  vendor,
                  style: TextStyle(
                    color: color,
                    fontSize: 11,
                    letterSpacing: 1,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 11,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withValues(alpha: .4),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text(
                  '×${usedGpu.quantity}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    fontFeatures: numberFeatures,
                  ),
                ),
              ),
              if (onDelete != null)
                IconButton(
                  tooltip: 'remove_gpu'.tr(context: context),
                  onPressed: onDelete,
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            usedGpu.gpuData.marketingName,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(
            'algorithm_count'.tr(
              args: [
                '${usedGpu.gpuData.hashAlgorithms.where((algo) => (algo.hashrate ?? 0) > 0).length}',
              ],
            ),
            style: TextStyle(
              fontSize: 11,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}
