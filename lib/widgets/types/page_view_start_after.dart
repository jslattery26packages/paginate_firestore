import 'package:flutter/material.dart';
import 'package:paginate_firestore/bloc/pagination_cubit.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class PageViewStartAfter extends StatelessWidget {
  const PageViewStartAfter({
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
      shrinkWrap: widget.shrinkWrap,
      controller: widget.scrollController,
      scrollDirection: widget.scrollDirection,
      physics: widget.physics,
      slivers: <Widget>[
        if (widget.header != null) SliverToBoxAdapter(child: widget.header),
        SliverPadding(
          padding: widget.padding,
          sliver: SliverFillRemaining(
            child: PageView.custom(
              allowImplicitScrolling: true,
              scrollDirection: Axis.vertical,
              controller: widget.pageController,
              childrenDelegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= loadedState.documentSnapshots.length) {
                    cubit!.fetchPaginatedList();
                    return widget.bottomLoader;
                  }
                  return widget.itemBuilder(
                    index,
                    context,
                    loadedState.documentSnapshots[index],
                  );
                },
                childCount: loadedState.hasReachedEnd
                    ? loadedState.documentSnapshots.length
                    : loadedState.documentSnapshots.length + 1,
              ),
            ),
          ),
        ),
        if (widget.footer != null) SliverToBoxAdapter(child: widget.footer),
      ],
    );
  }
}
