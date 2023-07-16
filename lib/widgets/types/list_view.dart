import 'dart:math';

import 'package:flutter/material.dart';
import 'package:paginate_firestore/bloc/pagination_cubit.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class ListViewPaginated extends StatelessWidget {
  const ListViewPaginated({
    Key? key,
    required this.loadedState,
    required this.widget,
    required this.cubit,
  }) : super(key: key);

  final PaginationLoaded loadedState;
  final PaginateFirestore widget;
  final PaginationCubit? cubit;
  @override
  Widget build(BuildContext context) {
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
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final itemIndex = index ~/ 2;
                if (index.isEven) {
                  if (itemIndex >= loadedState.documentSnapshots.length) {
                    cubit!.fetchPaginatedList();
                    return widget.bottomLoader;
                  }
                  return widget.itemBuilder(
                    itemIndex,
                    context,
                    loadedState.documentSnapshots[itemIndex],
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
                (loadedState.hasReachedEnd
                            ? loadedState.documentSnapshots.length
                            : loadedState.documentSnapshots.length + 1) *
                        2 -
                    1,
              ),
            ),
          ),
        ),
        if (widget.footer != null) SliverToBoxAdapter(child: widget.footer),
      ],
    );
  }
}
