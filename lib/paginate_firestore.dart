library paginate_firestore;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paginate_firestore/pagination/pagination_notifier.dart';
import 'package:paginate_firestore/pagination/pagination_params_notifier.dart';
import 'package:paginate_firestore/pagination/pagination_state.dart';
import 'package:paginate_firestore/widgets/types/grid_view.dart';
import 'package:paginate_firestore/widgets/types/list_view.dart';
import 'package:paginate_firestore/widgets/types/page_view.dart';
import 'package:paginate_firestore/widgets/types/page_view_separated.dart';
import 'package:paginate_firestore/widgets/types/page_view_start_after.dart';

import 'widgets/bottom_loader.dart';
import 'widgets/empty_display.dart';
import 'widgets/empty_separator.dart';
import 'widgets/error_display.dart';
import 'widgets/initial_loader.dart';

class PaginateFirestore extends StatefulHookConsumerWidget {
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
          itemBuilderType != PaginateType.pageViewSeparated ||
              separatorEveryAmount > 0,
        ),
        // assert(
        //   (itemBuilderType == PaginateType.pageViewStartAfter &&
        //           prefixDocuments != null &&
        //           prefixDocuments.length > 0) ||
        //       itemBuilderType != PaginateType.pageViewStartAfter,
        // ),
        super(key: key);

  final Widget bottomLoader;
  final Widget emptyDisplay;
  final SliverGridDelegate gridDelegate;
  final Widget initialLoader;
  final PaginateType itemBuilderType;
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

  final Widget Function(Exception)? onError;

  final Widget Function(int, BuildContext, dynamic) itemBuilder;

  final void Function(PaginationState)? onReachedEnd;

  final void Function(PaginationState)? onLoaded;

  final void Function(int)? onPageChanged;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PaginateFirestoreRiverpodState();
}

class _PaginateFirestoreRiverpodState extends ConsumerState<PaginateFirestore> {
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ref.read(paginationParamsNotifierProvider.notifier).setParams(
            NotifierParams(
              query: widget.query,
              limit: widget.itemsPerPage,
              isLive: widget.isLive,
              startAfterDocument: widget.startAfterDocument,
              prefixDocuments: widget.prefixDocuments,
            ),
          );
      ref.read(paginationNotifierProvider.notifier).fetchPaginatedList();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paginationNotifierProvider);
    Widget buildWithScrollView(BuildContext context, Widget child) {
      return SingleChildScrollView(
        child: Container(
          alignment: Alignment.center,
          height: MediaQuery.of(context).size.height,
          child: child,
        ),
      );
    }

    Widget buildView(PaginationState state, PaginateType type) {
      switch (widget.itemBuilderType) {
        case PaginateType.listView:
          return ListViewPaginated(
            widget: widget,
          );
        case PaginateType.gridView:
          return GridViewPaginated(
            widget: widget,
          );
        case PaginateType.pageView:
          return PageViewPaginated(
            widget: widget,
          );
        case PaginateType.pageViewSeparated:
          return PageViewPaginatedSeparated(
            widget: widget,
          );
        case PaginateType.pageViewStartAfter:
          return PageViewStartAfter(
            widget: widget,
          );
      }
    }

    ref.listen<PaginationState>(paginationNotifierProvider, (previous, next) {
      // * Don't call before build is done
      if (previous != null &&
          !next.addedPrefixDocs &&
          widget.prefixDocuments != null) {}
    });
    var once = false;
    if (state.status == Status.initial) {
      return buildWithScrollView(context, widget.initialLoader);
    } else if (state.status == Status.error) {
      return buildWithScrollView(
        context,
        (widget.onError != null)
            ? widget.onError!(state.error!)
            : ErrorDisplay(exception: state.error!),
      );
    } else {
      if (widget.onLoaded != null) {
        widget.onLoaded?.call(state);
      }
      if (state.hasReachedEnd && widget.onReachedEnd != null) {
        widget.onReachedEnd!(state);
      }
      if (state.documentSnapshots.isEmpty) {
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

      return buildView(state, widget.itemBuilderType);
    }
  }
}

enum PaginateType {
  listView,
  gridView,
  pageView,
  pageViewSeparated,
  pageViewStartAfter
}
