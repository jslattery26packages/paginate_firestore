import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:paginate_firestore/pagination/pagination_notifier.dart';

class PageViewPaginatedSeparated extends HookConsumerWidget {
  const PageViewPaginatedSeparated({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final PaginateFirestore widget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paginationNotifierProvider);
    final notifier = ref.watch(paginationNotifierProvider.notifier);

    final sep = widget.separatorEveryAmount + 1;
    final docLength = state.documentSnapshots.length;
    return Padding(
      padding: widget.padding,
      child: PageView.custom(
        allowImplicitScrolling: true,
        scrollDirection: Axis.vertical,
        controller: widget.pageController,
        childrenDelegate: SliverChildBuilderDelegate(
          (context, index) {
            int itemIndex;
            if (index == 0 || index == 1) {
              itemIndex = index;
            } else {
              itemIndex = index - ((index / sep).ceil()) + 1;
            }
            if (index % sep != 0 || index == 0) {
              if (index >= state.documentSnapshots.length) {
                notifier.fetchPaginatedList();
                return widget.bottomLoader;
              }
              return widget.itemBuilder(
                itemIndex,
                context,
                state.documentSnapshots[itemIndex],
              );
            }
            return widget.separator;
          },
          childCount: state.hasReachedEnd
              ? docLength + (docLength / (sep)).floor()
              : docLength + (docLength / (sep)).floor() + 1,
        ),
      ),
    );
  }
}
