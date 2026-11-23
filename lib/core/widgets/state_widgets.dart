import 'package:coingecko_mini/core/theme/app_theme.dart';
import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  const LoadingView({
    super.key,
    this.message = 'Fetching live market data…',
    this.compact = false,
  });

  final String message;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: compact ? 54 : 132,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(2),
                child: LinearProgressIndicator(
                  minHeight: compact ? 1.5 : 2,
                  backgroundColor: AppColors.surfaceSoft,
                  color: AppColors.primary,
                ),
              ),
            ),
            if (!compact) ...[
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: AppText.sans(
                  size: 12,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 6),
              Text('SYNCING', style: AppText.eyebrow(AppColors.faint)),
            ],
          ],
        ),
      ),
    );
  }
}

class ErrorView extends StatelessWidget {
  const ErrorView({
    super.key,
    required this.message,
    required this.onRetry,
    this.title = 'Something went wrong',
  });

  final String message;
  final String title;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.negative.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: AppColors.negative.withValues(alpha: 0.35),
                ),
              ),
              child: const Icon(
                Icons.wifi_off_rounded,
                color: AppColors.negative,
                size: 22,
              ),
            ),
            const SizedBox(height: 18),
            Text(title, style: AppText.display(size: 19, spacing: -0.5)),
            const SizedBox(height: 7),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppText.sans(
                size: 12,
                color: AppColors.muted,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}

class EmptyView extends StatelessWidget {
  const EmptyView({
    super.key,
    required this.title,
    this.message,
    this.icon = Icons.search_off_rounded,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(34),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.muted, size: 22),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppText.display(size: 19, spacing: -0.5),
            ),
            if (message != null) ...[
              const SizedBox(height: 7),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: AppText.sans(
                  size: 12,
                  color: AppColors.muted,
                  height: 1.5,
                ),
              ),
            ],
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 20),
              FilledButton(onPressed: onAction, child: Text(actionLabel!)),
            ],
          ],
        ),
      ),
    );
  }
}

class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    if (source.toLowerCase() != 'live') return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.positive.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(3),
        border: Border.all(
          color: AppColors.positive.withValues(alpha: 0.32),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: AppColors.positive,
              borderRadius: BorderRadius.circular(1),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            'LIVE API',
            style: AppText.mono(
              size: 9,
              weight: FontWeight.w700,
              color: AppColors.positive,
              letterSpacing: 0.7,
            ),
          ),
        ],
      ),
    );
  }
}
