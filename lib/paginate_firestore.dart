library paginate_firestore;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:paginate_firestore/widgets/types/grid_view.dart';
import 'package:paginate_firestore/widgets/types/list_view.dart';
import 'package:paginate_firestore/widgets/types/page_view.dart';
import 'package:paginate_firestore/widgets/types/page_view_separated.dart';
import 'package:paginate_firestore/widgets/types/page_view_start_after.dart';
import 'package:provider/provider.dart';

import 'bloc/pagination_cubit.dart';
import 'bloc/pagination_listeners.dart';
import 'widgets/bottom_loader.dart';
import 'widgets/empty_display.dart';
import 'widgets/empty_separator.dart';
import 'widgets/error_display.dart';
import 'widgets/initial_loader.dart';

class PaginateFirestore extends StatefulWidget {
  const PaginateFirestore({
    Key? key,
    required this.itemBuilder,
    required this.query,
    required this.itemBuilderType,
    this.gridDelegate =
        const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
    this.startAfterDocument,
    this.itemsPerPage = 15,
    this.separatorEveryAmount = 1,
    this.onError,
    this.onReachedEnd,
    this.onLoaded,
    this.emptyDisplay = const EmptyDisplay(),
    this.separator = const EmptySeparator(),
    this.initialLoader = const InitialLoader(),
    this.bottomLoader = const BottomLoader(),
    this.shrinkWrap = false,
    this.reverse = false,
    this.scrollDirection = Axis.vertical,
    this.padding = EdgeInsets.zero,
    this.physics,
    this.listeners,
    this.prefixDocuments,
    this.scrollController,
    this.allowImplicitScrolling = false,
    this.keyboardDismissBehavior = ScrollViewKeyboardDismissBehavior.manual,
    this.pageController,
    this.onPageChanged,
    this.header,
    this.footer,
    this.isLive = false,
  })  : assert(
          itemBuilderType != PaginateBuilderType.pageViewSeparated ||
              separatorEveryAmount > 0,
        ),
        assert(
          (itemBuilderType == PaginateBuilderType.pageViewStartAfter &&
                  prefixDocuments != null &&
                  prefixDocuments.length > 0) ||
              itemBuilderType != PaginateBuilderType.pageViewStartAfter,
        ),
        super(key: key);

  final Widget bottomLoader;
  final Widget emptyDisplay;
  final SliverGridDelegate gridDelegate;
  final Widget initialLoader;
  final PaginateBuilderType itemBuilderType;
  final int itemsPerPage;
  final int separatorEveryAmount;
  final List<ChangeNotifier>? listeners;
  final EdgeInsets padding;
  final ScrollPhysics? physics;
  final Query query;
  final bool reverse;
  final List<DocumentSnapshot>? prefixDocuments;
  final bool allowImplicitScrolling;
  final ScrollViewKeyboardDismissBehavior keyboardDismissBehavior;
  final ScrollController? scrollController;
  final PageController? pageController;
  final Axis scrollDirection;
  final Widget separator;
  final bool shrinkWrap;
  final bool isLive;
  final DocumentSnapshot? startAfterDocument;
  final Widget? header;
  final Widget? footer;

  @override
  PaginateFirestoreState createState() => PaginateFirestoreState();

  final Widget Function(Exception)? onError;

  final Widget Function(int, BuildContext, dynamic) itemBuilder;

  final void Function(PaginationLoaded)? onReachedEnd;

  final void Function(PaginationLoaded)? onLoaded;

  final void Function(int)? onPageChanged;
}

class PaginateFirestoreState extends State<PaginateFirestore> {
  PaginationCubit? _cubit;

  @override
  Widget build(BuildContext context) {
    var once = false;
    return BlocBuilder<PaginationCubit, PaginationState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is PaginationInitial) {
          return _buildWithScrollView(context, widget.initialLoader);
        } else if (state is PaginationError) {
          return _buildWithScrollView(
            context,
            (widget.onError != null)
                ? widget.onError!(state.error)
                : ErrorDisplay(exception: state.error),
          );
        } else {
          final loadedState = state as PaginationLoaded;
          if (widget.onLoaded != null) {
            widget.onLoaded?.call(loadedState);
          }
          if (loadedState.hasReachedEnd && widget.onReachedEnd != null) {
            widget.onReachedEnd!(loadedState);
          }

          if (loadedState.documentSnapshots.isEmpty) {
            return Column(
              mainAxisAlignment: widget.header == null
                  ? MainAxisAlignment.center
                  : MainAxisAlignment.start,
              children: [
                if (widget.header != null) widget.header!,
                Center(child: widget.emptyDisplay),
              ],
            );
          }
          if (widget.prefixDocuments != null && !once) {
            loadedState.documentSnapshots.insertAll(0, widget.prefixDocuments!);
            once = true;
          }
          return _buildView(loadedState, widget.itemBuilderType);
        }
      },
    );
  }

  Widget _buildWithScrollView(BuildContext context, Widget child) {
    return SingleChildScrollView(
      child: Container(
        alignment: Alignment.center,
        height: MediaQuery.of(context).size.height,
        child: child,
      ),
    );
  }

  @override
  void dispose() {
    widget.scrollController?.dispose();
    _cubit?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    if (widget.listeners != null) {
      for (var listener in widget.listeners!) {
        if (listener is PaginateRefreshedChangeListener) {
          listener.addListener(() {
            if (listener.refreshed) {
              _cubit!.refreshPaginatedList();
            }
          });
        } else if (listener is PaginateFilterChangeListener) {
          listener.addListener(() {
            if (listener.searchTerm.isNotEmpty) {
              _cubit!.filterPaginatedList(listener.searchTerm);
            }
          });
        }
      }
    }

    _cubit = PaginationCubit(
      widget.query,
      widget.itemsPerPage,
      widget.startAfterDocument,
      isLive: widget.isLive,
    )..fetchPaginatedList();
    super.initState();
  }

  Widget _buildView(PaginationLoaded loadedState, PaginateBuilderType type) {
    Widget view;
    switch (widget.itemBuilderType) {
      case PaginateBuilderType.listView:
        view = ListViewPaginated(
          loadedState: loadedState,
          cubit: _cubit,
          widget: widget,
        );
        break;
      case PaginateBuilderType.gridView:
        view = GridViewPaginated(
          loadedState: loadedState,
          cubit: _cubit,
          widget: widget,
        );
        break;
      case PaginateBuilderType.pageView:
        view = PageViewPaginated(
          loadedState: loadedState,
          cubit: _cubit,
          widget: widget,
        );
        break;
      case PaginateBuilderType.pageViewSeparated:
        view = PageViewPaginatedSeparated(
          loadedState: loadedState,
          cubit: _cubit,
          widget: widget,
        );
        break;
      case PaginateBuilderType.pageViewStartAfter:
        view = PageViewStartAfter(
          loadedState: loadedState,
          cubit: _cubit,
          widget: widget,
        );
        break;
    }

    if (widget.listeners != null && widget.listeners!.isNotEmpty) {
      return MultiProvider(
        providers: widget.listeners!
            .map(
              (listener) => ChangeNotifierProvider(
                create: (context) => listener,
              ),
            )
            .toList(),
        child: view,
      );
    }

    return view;
  }
}

enum PaginateBuilderType {
  listView,
  gridView,
  pageView,
  pageViewSeparated,
  pageViewStartAfter
}
