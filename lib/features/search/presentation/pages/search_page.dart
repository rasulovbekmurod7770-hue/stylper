import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/l10n/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/widgets/load_error_view.dart';
import '../../../post/presentation/widgets/post_grid.dart';
import '../cubits/search_cubit.dart';
import '../search_failure_message.dart';
import '../widgets/search_rows.dart';

/// The Search tab: find brands and people by username or name. Before
/// anything is typed it shows the brands on Stylper and trending looks.
///
/// Not in Figma: built from the Search screen of the claude.ai "Stylper
/// Prototype", minus its Styles chips (nothing to open yet) and with a hint
/// that promises only what works. Styling is PROVISIONAL.
class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Starts from the cubit, so coming back to the tab shows the same search.
  late final _query = TextEditingController(
    text: context.read<SearchCubit>().state.query,
  );

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  void _clear() {
    _query.clear();
    context.read<SearchCubit>().setQuery('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final cubit = context.read<SearchCubit>();

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
              child: Text(l10n.tabSearch, style: AppTypography.headline),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ValueListenableBuilder(
                valueListenable: _query,
                builder: (context, value, _) => TextField(
                  controller: _query,
                  onChanged: cubit.setQuery,
                  textInputAction: TextInputAction.search,
                  autocorrect: false,
                  style: AppTypography.body,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: l10n.searchHint,
                    hintStyle: AppTypography.body.copyWith(
                      color: AppColors.textSubtle,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      size: 20,
                      color: AppColors.textSubtle,
                    ),
                    suffixIcon: value.text.isEmpty
                        ? null
                        : IconButton(
                            tooltip: l10n.searchClear,
                            onPressed: _clear,
                            icon: const Icon(
                              Icons.close,
                              size: 18,
                              color: AppColors.textSubtle,
                            ),
                          ),
                    filled: true,
                    fillColor: AppColors.surfaceMuted,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(999)),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<SearchCubit, SearchState>(
                builder: (context, state) => state.isIdle
                    ? _Discovery(state: state)
                    : _Results(state: state),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Before anything is typed: the brands, then trending looks.
class _Discovery extends StatelessWidget {
  const _Discovery({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final discovery = state.discovery;
    if (discovery == null) {
      final failure = state.discoveryFailure;
      return failure == null
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            )
          : LoadErrorView(
              message: failure.message(l10n),
              onRetry: context.read<SearchCubit>().loadDiscovery,
            );
    }
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(
        top: 24,
        bottom: MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        if (discovery.brands.isNotEmpty) ...[
          _Section(l10n.searchBrandsOnStylper),
          SizedBox(
            height: 82,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: discovery.brands.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) =>
                  BrandChip(brand: discovery.brands[index]),
            ),
          ),
          const SizedBox(height: 24),
        ],
        if (discovery.trending.isNotEmpty) ...[
          _Section(l10n.homeTrendingIn(discovery.city)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: PostGrid(posts: discovery.trending),
          ),
        ],
      ],
    );
  }
}

/// Brands, then people, matching the query.
class _Results extends StatelessWidget {
  const _Results({required this.state});

  final SearchState state;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final results = state.results;
    final failure = state.failure;
    if (results == null || (failure != null && !state.searching)) {
      if (failure != null && !state.searching) {
        return LoadErrorView(
          message: failure.message(l10n),
          onRetry: context.read<SearchCubit>().retry,
        );
      }
      return const Center(
        child: CircularProgressIndicator(color: AppColors.accent),
      );
    }
    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(32, 40, 32, 0),
        child: Text(
          l10n.searchNoResults(SearchCubit.normalize(state.query)),
          style: AppTypography.body.copyWith(color: AppColors.textSubtle),
          textAlign: TextAlign.center,
        ),
      );
    }
    return ListView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: EdgeInsets.only(
        top: 16,
        bottom: MediaQuery.paddingOf(context).bottom + 24,
      ),
      children: [
        ..._group(l10n.searchBrands, [
          for (final brand in results.brands) BrandRow(brand: brand),
        ]),
        ..._group(l10n.searchPeople, [
          for (final person in results.people) PersonRow(person: person),
        ]),
      ],
    );
  }

  static List<Widget> _group(String title, List<Widget> rows) => [
    if (rows.isNotEmpty) ...[
      _Section(title),
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(children: rows),
      ),
    ],
  ];
}

class _Section extends StatelessWidget {
  const _Section(this.title);

  final String title;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
    child: Text(title.toUpperCase(), style: AppTypography.overline),
  );
}
