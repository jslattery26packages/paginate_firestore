import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:paginate_firestore/pagination/pagination_params_notifier.dart';
import 'package:paginate_firestore/pagination/pagination_state.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pagination_notifier.g.dart';

class NotifierParams {
  const NotifierParams({
    required this.query,
    required this.limit,
    this.startAfterDocument,
    this.prefixDocuments,
    this.isLive = true,
  });
  final Query query;
  final int limit;
  final bool isLive;
  final DocumentSnapshot? startAfterDocument;
  final List<DocumentSnapshot>? prefixDocuments;
}

@riverpod
class PaginationNotifier extends _$PaginationNotifier {
  @override
  PaginationState build() {
    return PaginationState();
  }

  filterPaginatedList(String searchTerm) {
    if (state.status == Status.loaded) {
      final filteredList = state.documentSnapshots
          .where(
            (document) => document
                .data()
                .toString()
                .toLowerCase()
                .contains(searchTerm.toLowerCase()),
          )
          .toList();
      state = state.copyWith(
        documentSnapshots: filteredList,
        hasReachedEnd: state.hasReachedEnd,
      );
    }
  }

  cleanPaginatedList(List<dynamic> blockedList, String key) {
    if (state.status == Status.loaded) {
      final filteredList = state.documentSnapshots
          .where(
            (document) => !blockedList.contains(
              (document.data()! as Map<String, dynamic>)[key],
            ),
          )
          .toList();

      state = state.copyWith(
        documentSnapshots: filteredList,
        hasReachedEnd: state.hasReachedEnd,
      );
    }
  }

  refreshPaginatedList() async {
    final params = ref.watch(paginationParamsNotifierProvider);
    state = state.copyWith(lastDocument: null);
    final localQuery = getQuery();

    final initialPreviousList =
        List<QueryDocumentSnapshot>.from(params.prefixDocuments ?? []);
    if (params.isLive) {
      final listener = localQuery.snapshots().listen((querySnapshot) {
        combineLists(
          querySnapshot.docs,
          previousList: initialPreviousList,
        );
      });
      final copy = List<StreamSubscription<QuerySnapshot>>.from(state.streams);
      copy.add(listener);
      state = state.copyWith(streams: copy);
    } else {
      final querySnapshot = await localQuery.get();
      combineLists(
        querySnapshot.docs,
        previousList: initialPreviousList,
      );
    }
  }

  fetchPaginatedList() {
    final params = ref.watch(paginationParamsNotifierProvider);
    params.isLive ? getLiveDocuments() : getDocuments();
  }

  getDocuments() async {
    final localQuery = getQuery();
    try {
      if (state.status == Status.initial) {
        refreshPaginatedList();
      } else if (state.status == Status.loaded) {
        if (state.hasReachedEnd) return;
        final querySnapshot = await localQuery.get();
        final previous =
            List<QueryDocumentSnapshot>.from(state.documentSnapshots);
        combineLists(
          querySnapshot.docs,
          previousList: previous,
        );
      }
    } on PlatformException catch (exception) {
      debugPrint(exception.toString());
      rethrow;
    }
  }

  addToBeginning(List<DocumentSnapshot> prefixDocuments) {
    // print(state.documentSnapshots.length);

    // print(prefixDocuments.first.id);
    // final copy = List<DocumentSnapshot>.from(state.documentSnapshots);
    // copy.insertAll(0, prefixDocuments);
    // print(copy.first.id);
    // state = state.copyWith(documentSnapshots: copy, addedPrefixDocs: true);
    // print(state.documentSnapshots.first.id);
  }

  getLiveDocuments() {
    final localQuery = getQuery();

    if (state.status == Status.initial) {
      refreshPaginatedList();
    } else if (state.status == Status.loaded) {
      localQuery.snapshots().listen((querySnapshot) {
        final currentDocs =
            List<QueryDocumentSnapshot>.from(state.documentSnapshots);
        combineLists(
          querySnapshot.docs,
          previousList: currentDocs,
        );
      });
    }
  }

  void combineLists(
    List<QueryDocumentSnapshot> newList, {
    List<QueryDocumentSnapshot> previousList = const [],
  }) {
    state = state.copyWith(
      status: Status.loaded,
      lastDocument: newList.isNotEmpty ? newList.last : null,
      documentSnapshots: previousList + newList,
      hasReachedEnd: newList.isEmpty,
    );
  }

  Query getQuery() {
    final params = ref.watch(paginationParamsNotifierProvider);
    var localQuery = (state.lastDocument != null)
        ? params.query.startAfterDocument(state.lastDocument!)
        : params.startAfterDocument != null
            ? params.query.startAfterDocument(params.startAfterDocument!)
            : params.query;
    return localQuery.limit(params.limit);
  }

  void dispose() {
    for (var listener in state.streams) {
      listener.cancel();
    }
  }
}
