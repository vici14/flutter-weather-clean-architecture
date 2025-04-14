import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/base/bloc/loading_state.dart';
import '../../../core/dependency_injection/service_locator.dart';
import '../../../core/theme/theme.dart';
import '../../../data/models/country.dart';
import '../../../routes/app_routes.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_state.dart';

class CountryListWidget extends StatelessWidget {
  const CountryListWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<LocationBloc>.value(
      value: getIt<LocationBloc>(),
      child: BlocBuilder<LocationBloc, LocationState>(
        builder: (context, state) {
          // Show loading indicator if countries are being loaded initially
          if (state.countriesLoadingState.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
              ),
            );
          }

          // Show error if countries failed to load
          if (state.countriesLoadingState.loadError != null) {
            return Center(
              child: Text(
                state.countriesLoadingState.loadError?.message ?? '',
                style: AppTextStyles.bodyStyle.copyWith(
                  color: Colors.red,
                ),
              ),
            );
          }

          // Show empty state if no countries available
          if (state.allCountries.isEmpty) {
            return Center(
              child: Text(
                'No countries available',
                style: AppTextStyles.bodyStyle,
              ),
            );
          }

          return _buildCountryList(context, state);
        },
      ),
    );
  }

  Widget _buildCountryList(BuildContext context, LocationState state) {
    final countries = state.countries;
    final String query = state.query;
    final bool isSearching = state.searchLoadingState.isLoading;
    final bool hasSearchError = state.searchLoadingState.loadError != null;

    return CustomScrollView(
      slivers: [
        // If there's a search query, show it as a sticky header
        if (query.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
              color: AppColors.background,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Search results for "$query"',
                      style: AppTextStyles.bodyStyle.copyWith(
                        color: AppColors.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                  if (isSearching)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.accent,
                      ),
                    ),
                ],
              ),
            ),
          ),

        // Show search error if there is one
        if (hasSearchError)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                state.searchLoadingState.loadError?.message ?? 'Search error',
                style: AppTextStyles.bodyStyle.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),

        // Main list of countries
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final country = countries[index];
              return _buildCountryItem(context, country);
            },
            childCount: countries.length,
          ),
        ),

        // Show no results message when search has results but list is empty
        if (query.isNotEmpty &&
            countries.isEmpty &&
            !hasSearchError &&
            !isSearching)
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 48,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No countries found for "$query"',
                    style: AppTextStyles.bodyStyle.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

        // Add some bottom padding
        const SliverToBoxAdapter(
          child: SizedBox(height: 20),
        ),
      ],
    );
  }

  Widget _buildCountryItem(BuildContext context, Country country) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: AppColors.cardBackground,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          context.read<LocationBloc>().onCountrySelected(country);
          Navigator.pushNamed(
            context,
            AppRoutes.weatherDetails,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                child: Text(
                  country.emoji ?? '🌍',
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      country.name,
                      style: AppTextStyles.headerStyle,
                    ),
                    if (country.capital != null && country.capital!.isNotEmpty)
                      Text(
                        'Capital: ${country.capital}',
                        style: AppTextStyles.bodyStyle,
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.navigate_next,
                color: AppColors.accent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
