library paginate_firestore;

import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    this.separatorEveryAmount = 0,
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
    this.padding = const EdgeInsets.all(0),
    this.physics,
    this.listeners,
    this.prefixDocuments,
    this.scrollController,
    this.pageController,
    this.onPageChanged,
    this.header,
    this.footer,
    this.isLive = false,
  }) : super(key: key);

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
  _PaginateFirestoreState createState() => _PaginateFirestoreState();

  final Widget Function(Exception)? onError;

  final Widget Function(int, BuildContext, dynamic) itemBuilder;

  final void Function(PaginationLoaded)? onReachedEnd;

  final void Function(PaginationLoaded)? onLoaded;

  final void Function(int)? onPageChanged;
}

class _PaginateFirestoreState extends State<PaginateFirestore> {
  PaginationCubit? _cubit;

  @override
  Widget build(BuildContext context) {
    var once = false;
    return BlocBuilder<PaginationCubit, PaginationState>(
      bloc: _cubit,
      builder: (context, state) {
        if (state is PaginationInitial) {
          return widget.initialLoader;
        } else if (state is PaginationError) {
          return (widget.onError != null)
              ? widget.onError!(state.error)
              : ErrorDisplay(exception: state.error);
        } else {
          final loadedState = state as PaginationLoaded;
          if (widget.onLoaded != null) {
            widget.onLoaded!(loadedState);
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
            print(loadedState.documentSnapshots.length);
            once = true;
          }
          return widget.itemBuilderType == PaginateBuilderType.listView
              ? _buildListView(loadedState)
              : widget.itemBuilderType == PaginateBuilderType.gridView
                  ? _buildGridView(loadedState)
                  : widget.itemBuilderType == PaginateBuilderType.pageView
                      ? _buildPageView(loadedState)
                      : widget.itemBuilderType ==
                              PaginateBuilderType.savePageView
                          ? _buildSavePageView(loadedState)
                          : _buildAdPageView(loadedState);
        }
      },
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

  Widget _buildGridView(PaginationLoaded loadedState) {
    var gridView = CustomScrollView(
      reverse: widget.reverse,
      controller: widget.scrollController,
      shrinkWrap: widget.shrinkWrap,
      scrollDirection: widget.scrollDirection,
      physics: widget.physics,
      slivers: [
        if (widget.header != null) SliverToBoxAdapter(child: widget.header!),
        SliverPadding(
          padding: widget.padding,
          sliver: SliverGrid(
            gridDelegate: widget.gridDelegate,
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                if (index >= loadedState.documentSnapshots.length) {
                  _cubit!.fetchPaginatedList();
                  return widget.bottomLoader;
                }
                return widget.itemBuilder(
                    index, context, loadedState.documentSnapshots[index]);
              },
              childCount: loadedState.hasReachedEnd
                  ? loadedState.documentSnapshots.length
                  : loadedState.documentSnapshots.length + 1,
            ),
          ),
        ),
        if (widget.footer != null) SliverToBoxAdapter(child: widget.footer!),
      ],
    );

    if (widget.listeners != null && widget.listeners!.isNotEmpty) {
      return MultiProvider(
        providers: widget.listeners!
            .map((_listener) => ChangeNotifierProvider(
                  create: (context) => _listener,
                ))
            .toList(),
        child: gridView,
      );
    }

    return gridView;
  }

  Widget _buildListView(PaginationLoaded loadedState) {
    var listView = CustomScrollView(
      reverse: widget.reverse,
      controller: widget.scrollController,
      shrinkWrap: widget.shrinkWrap,
      scrollDirection: widget.scrollDirection,
      physics: widget.physics,
      slivers: [
        if (widget.header != null) SliverToBoxAdapter(child: widget.header!),
        SliverPadding(
          padding: widget.padding,
          sliver: SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final itemIndex = index ~/ 2;
                if (index.isEven) {
                  if (itemIndex >= loadedState.documentSnapshots.length) {
                    _cubit!.fetchPaginatedList();
                    return widget.bottomLoader;
                  }
                  return widget.itemBuilder(itemIndex, context,
                      loadedState.documentSnapshots[itemIndex]);
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
                      1),
            ),
          ),
        ),
        if (widget.footer != null) SliverToBoxAdapter(child: widget.footer!),
      ],
    );

    if (widget.listeners != null && widget.listeners!.isNotEmpty) {
      return MultiProvider(
        providers: widget.listeners!
            .map((_listener) => ChangeNotifierProvider(
                  create: (context) => _listener,
                ))
            .toList(),
        child: listView,
      );
    }

    return listView;
  }

  Widget _buildPageView(PaginationLoaded loadedState) {
    var pageView = Padding(
      padding: widget.padding,
      child: PageView.custom(
        allowImplicitScrolling: true,
        reverse: widget.reverse,
        controller: widget.pageController,
        scrollDirection: widget.scrollDirection,
        physics: widget.physics,
        onPageChanged: widget.onPageChanged,
        childrenDelegate: SliverChildBuilderDelegate((context, index) {
          if (index >= loadedState.documentSnapshots.length) {
            _cubit!.fetchPaginatedList();
            return widget.bottomLoader;
          }

          return widget.itemBuilder(
              index, context, loadedState.documentSnapshots[index]);
        },
            childCount: loadedState.hasReachedEnd
                ? loadedState.documentSnapshots.length
                : loadedState.documentSnapshots.length + 1),
      ),
    );

    if (widget.listeners != null && widget.listeners!.isNotEmpty) {
      return MultiProvider(
        providers: widget.listeners!
            .map((_listener) => ChangeNotifierProvider(
                  create: (context) => _listener,
                ))
            .toList(),
        child: pageView,
      );
    }

    return pageView;
  }

  Widget _buildAdPageView(PaginationLoaded loadedState) {
    var sep = widget.separatorEveryAmount + 1;
    var docLength = loadedState.documentSnapshots.length;

    print(docLength + (docLength / (sep)).floor());

    var adPageView = Padding(
      padding: widget.padding,
      child: PageView.custom(
        allowImplicitScrolling: true,
        scrollDirection: Axis.vertical,
        controller: widget.pageController,
        childrenDelegate: SliverChildBuilderDelegate((context, index) {
          var itemIndex;
          if (index == 0 || index == 1) {
            itemIndex = index;
          } else {
            itemIndex = index - ((index / sep).ceil()) + 1;
          }
          if (index % sep != 0 || index == 0) {
            if (index >= loadedState.documentSnapshots.length) {
              _cubit!.fetchPaginatedList();
              return widget.bottomLoader;
            }
            return widget.itemBuilder(
                itemIndex, context, loadedState.documentSnapshots[itemIndex]);
          }
          return widget.separator;
        },
            childCount: loadedState.hasReachedEnd
                ? docLength + (docLength / (sep)).floor()
                : docLength + (docLength / (sep)).floor() + 1),
      ),
    );

    if (widget.listeners != null && widget.listeners!.isNotEmpty) {
      return MultiProvider(
        providers: widget.listeners!
            .map((_listener) => ChangeNotifierProvider(
                  create: (context) => _listener,
                ))
            .toList(),
        child: adPageView,
      );
    }

    return adPageView;
  }

  Widget _buildSavePageView(PaginationLoaded loadedState) {
    var savePageView = CustomScrollView(
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
                      _cubit!.fetchPaginatedList();
                      return widget.bottomLoader;
                    }
                    return widget.itemBuilder(
                        index, context, loadedState.documentSnapshots[index]);
                  },
                  childCount: loadedState.hasReachedEnd
                      ? loadedState.documentSnapshots.length
                      : loadedState.documentSnapshots.length + 1,
                ),
              ),
            )),
        if (widget.footer != null) SliverToBoxAdapter(child: widget.footer),
      ],
    );

    if (widget.listeners != null && widget.listeners!.isNotEmpty) {
      return MultiProvider(
        providers: widget.listeners!
            .map((_listener) => ChangeNotifierProvider(
                  create: (context) => _listener,
                ))
            .toList(),
        child: savePageView,
      );
    }

    return savePageView;
  }
}

enum PaginateBuilderType {
  listView,
  gridView,
  pageView,
  savePageView,
  adPageView
}
