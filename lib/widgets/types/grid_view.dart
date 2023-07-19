import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:paginate_firestore/paginate_firestore.dart';
import 'package:paginate_firestore/pagination/pagination_notifier.dart';

class GridViewPaginated extends HookConsumerWidget {
  const GridViewPaginated({
    Key? key,
    required this.widget,
  }) : super(key: key);

  final PaginateFirestore widget;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(paginationNotifierProvider);
    final notifier = ref.watch(paginationNotifierProvider.notifier);

    return CustomScrollView(
      reverse: widget.reverse,
      controller: widget.scrollController,
      shrinkWrap: widget.shrinkWrap,
      scrollDirection: widget.scrollDirection,
      physics: widget.physics,
      keyboardDismissBehavior: widget.keyboardDismissBehavior,
      slivers: [
        if (widget.header != null) SliverToBoxAdapter(child: widget.header),
        SliverPadding(
          padding: widget.padding,
          sliver: SliverGrid(
            gridDelegate: widget.gridDelegate,
            delegate: SliverChildBuilderDelegate(
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
        ),
        if (widget.footer != null) SliverToBoxAdapter(child: widget.footer),
      ],
    );
  }
}
