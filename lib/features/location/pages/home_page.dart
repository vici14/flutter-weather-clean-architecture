import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:async';
import '../../../core/dependency_injection/service_locator.dart';
import '../../../core/services/network_checker.dart';
import '../../../routes/app_routes.dart';
import '../../../core/theme/theme.dart';
import '../bloc/location_bloc.dart';
import '../bloc/location_event.dart';
import '../widgets/index.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showPinnedSearch = false;
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  StreamSubscription<bool>? _networkSubscription;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Add scroll listener to determine when to show pinned search
    _scrollController.addListener(_onScroll);

    // Listen to network connectivity changes
    _listenToNetworkChanges();
  }

  void _listenToNetworkChanges() {
    final networkChecker = getIt<NetworkChecker>();

    // Listen to connection status changes
    _networkSubscription =
        networkChecker.connectionStatus.listen((isConnected) {
      if (isConnected) {
        context.read<LocationBloc>().getCountries();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animationController.dispose();
    _networkSubscription?.cancel();
    super.dispose();
  }

  void _onScroll() {
    // Show pinned search when scrolled past threshold (e.g., 80)
    final showPinned = _scrollController.offset > 80;
    if (showPinned != _showPinnedSearch) {
      setState(() {
        _showPinnedSearch = showPinned;
      });

      if (showPinned) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  void _filterLocations(String query) {
    // Use the convenience method in the bloc
    context.read<LocationBloc>().searchCountries(query);
  }

  void _selectLocation() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverAppBar(
              floating: true,
              pinned: true,
              snap: false,
              expandedHeight: 120,
              backgroundColor: AppColors.background,
              centerTitle: true,
              title: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: _showPinnedSearch
                        ? Container(
                            child: SearchFieldWidget(
                              controller: _searchController,
                              onSearch: _filterLocations,
                              hintText: 'Search countries...',
                              alwaysShowClear: true,
                              padding: EdgeInsets.zero,
                            ),
                          )
                        : null,
                  );
                },
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 1.0 - _opacityAnimation.value,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(8, 24, 16, 8),
                          child: _showPinnedSearch
                              ? null
                              : SearchFieldWidget(
                                  controller: _searchController,
                                  onSearch: _filterLocations,
                                  hintText: 'Search countries...',
                                ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ];
        },
        body: const CountryListWidget(),
      ),
    );
  }
}
