import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/load_error_view.dart';
import '../../../../core/widgets/screen_top_bar.dart';
import '../../../post/presentation/widgets/post_grid.dart';
import '../../domain/entities/product.dart';
import '../cubits/product_detail_cubit.dart';
import '../product_failure_message.dart';

/// "See all looks" (not in Figma): every post that tags the product, which
/// can be narrowed to one style. Opened from "See It On People" and the
/// "How people style it" pills.
class ProductLooksPage extends StatefulWidget {
  const ProductLooksPage({super.key, this.initialStyle});

  /// The style chosen on the product screen, if any.
  final String? initialStyle;

  @override
  State<ProductLooksPage> createState() => _ProductLooksPageState();
}

class _ProductLooksPageState extends State<ProductLooksPage> {
  late String? _style = widget.initialStyle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: BlocBuilder<ProductDetailCubit, ProductDetailState>(
          builder: (context, state) {
            final detail = state.detail;
            return Column(
              children: [
                ScreenTopBar(title: l10n.productLooksTitle),
                Expanded(
                  child: switch (state.status) {
                    ProductDetailStatus.ready when detail != null => _looks(
                      context,
                      detail,
                    ),
                    ProductDetailStatus.failure => LoadErrorView(
                      message: state.failure!.message(l10n),
                      onRetry: context.read<ProductDetailCubit>().load,
                    ),
                    _ => const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    ),
                  },
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _looks(BuildContext context, ProductDetail detail) {
    final l10n = context.l10n;
    final looks = detail.looksIn(_style);
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 4),
            child: Text(
              detail.product.name,
              style: AppTypography.body,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        if (detail.styles.isNotEmpty)
          SliverToBoxAdapter(
            child: SizedBox(
              height: 52,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 10),
                children: [
                  for (final style in [
                    null,
                    ...detail.styles.map((s) => s.name),
                  ])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _FilterChip(
                        label: style ?? l10n.filterAll,
                        selected: style == _style,
                        onTap: () => setState(() => _style = style),
                      ),
                    ),
                ],
              ),
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(
            12,
            12,
            12,
            MediaQuery.paddingOf(context).bottom + 24,
          ),
          sliver: SliverToBoxAdapter(
            child: looks.isEmpty
                ? Padding(
                    padding: const EdgeInsets.only(top: 48),
                    child: Text(
                      l10n.productNoLooks,
                      style: AppTypography.body,
                      textAlign: TextAlign.center,
                    ),
                  )
                : PostGrid(posts: looks),
          ),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected ? AppColors.brandGradient : null,
            border: selected ? null : Border.all(color: AppColors.inputBorder),
            borderRadius: const BorderRadius.all(Radius.circular(999)),
          ),
          // Dark on the gradient, as Figma's gradient buttons.
          child: Text(label, style: AppTypography.captionStrong),
        ),
      ),
    );
  }
}
