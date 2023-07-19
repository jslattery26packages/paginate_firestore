import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:paginate_firestore/pagination/pagination_notifier.dart';

class ListViewPaginated extends ConsumerWidget {
  const ListViewPaginated({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final PaginateFirestore widget;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paginationNotifierProvider);
    final notifier = ref.watch(paginationNotifierProvider.notifier);
    return Column(
      children: [
        Expanded(
          child: CustomScrollView(
            reverse: widget.reverse,
            controller: widget.scrollController,
            shrinkWrap: widget.shrinkWrap,
            scrollDirection: widget.scrollDirection,
            physics: widget.physics,
            keyboardDismissBehavior: widget.keyboardDismissBehavior,
            slivers: [
              if (widget.header != null)
                SliverToBoxAdapter(child: widget.header),
              SliverPadding(
                padding: widget.padding,
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final itemIndex = index ~/ 2;
                      if (index.isEven) {
                        if (itemIndex >= state.documentSnapshots.length) {
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
                    semanticIndexCallback: (widget, localIndex) {
                      if (localIndex.isEven) {
                        return localIndex ~/ 2;
                      }
                      // ignore: avoid_returning_null
                      return null;
                    },
                    childCount: max(
                      0,
                      (state.hasReachedEnd
                                  ? state.documentSnapshots.length
                                  : state.documentSnapshots.length + 1) *
                              2 -
                          1,
                    ),
                  ),
                ),
              ),
              if (widget.footer != null)
                SliverToBoxAdapter(child: widget.footer),
            ],
          ),
        ),
      ],
    );
  }
}
