import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pagination_state.freezed.dart';

@freezed
class PaginationState with _$PaginationState {
  factory PaginationState({
    @Default(Status.initial) Status status,
    @Default([]) List<DocumentSnapshot> documentSnapshots,
    @Default(false) bool addedPrefixDocs,
    @Default(false) hasReachedEnd,
    @Default([]) List<StreamSubscription<QuerySnapshot>> streams,
    DocumentSnapshot? lastDocument,
    Exception? error,
  }) = _PaginationState;
}

enum Status { initial, loading, loaded, error }
