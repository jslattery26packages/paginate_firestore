import 'package:flutter/material.dart';
import 'package:paginate_firestore/bloc/pagination_cubit.dart';
import 'package:paginate_firestore/paginate_firestore.dart';

class PageViewPaginatedSeparated extends StatelessWidget {
  const PageViewPaginatedSeparated({
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
    final sep = widget.separatorEveryAmount + 1;
    final docLength = loadedState.documentSnapshots.length;
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
              if (index >= loadedState.documentSnapshots.length) {
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
          childCount: loadedState.hasReachedEnd
              ? docLength + (docLength / (sep)).floor()
              : docLength + (docLength / (sep)).floor() + 1,
        ),
      ),
    );
  }
}
