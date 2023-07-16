import 'package:flutter/material.dart';
import 'package:paginate_firestore/bloc/pagination_cubit.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class PageViewPaginated extends StatelessWidget {
  const PageViewPaginated({
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
    );
  }
}
