import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:paginate_firestore/pagination/pagination_notifier.dart';

class PageViewPaginated extends HookConsumerWidget {
  const PageViewPaginated({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final PaginateFirestore widget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paginationNotifierProvider);
    final notifier = ref.watch(paginationNotifierProvider.notifier);

    return Padding(
      padding: widget.padding,
      child: PageView.custom(
        allowImplicitScrolling: true,
        reverse: widget.reverse,
        controller: widget.pageController,
        scrollDirection: widget.scrollDirection,
        physics: widget.physics,
        onPageChanged: widget.onPageChanged,
        childrenDelegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index >= state.documentSnapshots.length) {
              notifier.fetchPaginatedList();
              return widget.bottomLoader;
            }

            return widget.itemBuilder(
              index,
              context,
              state.documentSnapshots[index],
            );
          },
          childCount: state.hasReachedEnd
              ? state.documentSnapshots.length
              : state.documentSnapshots.length + 1,
        ),
      ),
    );
  }
}
