// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pagination_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$PaginationState {
  Status get status => throw _privateConstructorUsedError;
  List<DocumentSnapshot<Object?>> get documentSnapshots =>
      throw _privateConstructorUsedError;
  bool get addedPrefixDocs => throw _privateConstructorUsedError;
  dynamic get hasReachedEnd => throw _privateConstructorUsedError;
  List<StreamSubscription<QuerySnapshot<Object?>>> get streams =>
      throw _privateConstructorUsedError;
  DocumentSnapshot<Object?>? get lastDocument =>
      throw _privateConstructorUsedError;
  Exception? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $PaginationStateCopyWith<PaginationState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PaginationStateCopyWith<$Res> {
  factory $PaginationStateCopyWith(
          PaginationState value, $Res Function(PaginationState) then) =
      _$PaginationStateCopyWithImpl<$Res, PaginationState>;
  @useResult
  $Res call(
      {Status status,
      List<DocumentSnapshot<Object?>> documentSnapshots,
      bool addedPrefixDocs,
      dynamic hasReachedEnd,
      List<StreamSubscription<QuerySnapshot<Object?>>> streams,
      DocumentSnapshot<Object?>? lastDocument,
      Exception? error});
}

/// @nodoc
class _$PaginationStateCopyWithImpl<$Res, $Val extends PaginationState>
    implements $PaginationStateCopyWith<$Res> {
  _$PaginationStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? documentSnapshots = null,
    Object? addedPrefixDocs = null,
    Object? hasReachedEnd = freezed,
    Object? streams = null,
    Object? lastDocument = freezed,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as Status,
      documentSnapshots: null == documentSnapshots
          ? _value.documentSnapshots
          : documentSnapshots // ignore: cast_nullable_to_non_nullable
              as List<DocumentSnapshot<Object?>>,
      addedPrefixDocs: null == addedPrefixDocs
          ? _value.addedPrefixDocs
          : addedPrefixDocs // ignore: cast_nullable_to_non_nullable
              as bool,
      hasReachedEnd: freezed == hasReachedEnd
          ? _value.hasReachedEnd
          : hasReachedEnd // ignore: cast_nullable_to_non_nullable
              as dynamic,
      streams: null == streams
          ? _value.streams
          : streams // ignore: cast_nullable_to_non_nullable
              as List<StreamSubscription<QuerySnapshot<Object?>>>,
      lastDocument: freezed == lastDocument
          ? _value.lastDocument
          : lastDocument // ignore: cast_nullable_to_non_nullable
              as DocumentSnapshot<Object?>?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as Exception?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_PaginationStateCopyWith<$Res>
    implements $PaginationStateCopyWith<$Res> {
  factory _$$_PaginationStateCopyWith(
          _$_PaginationState value, $Res Function(_$_PaginationState) then) =
      __$$_PaginationStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {Status status,
      List<DocumentSnapshot<Object?>> documentSnapshots,
      bool addedPrefixDocs,
      dynamic hasReachedEnd,
      List<StreamSubscription<QuerySnapshot<Object?>>> streams,
      DocumentSnapshot<Object?>? lastDocument,
      Exception? error});
}

/// @nodoc
class __$$_PaginationStateCopyWithImpl<$Res>
    extends _$PaginationStateCopyWithImpl<$Res, _$_PaginationState>
    implements _$$_PaginationStateCopyWith<$Res> {
  __$$_PaginationStateCopyWithImpl(
      _$_PaginationState _value, $Res Function(_$_PaginationState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? status = null,
    Object? documentSnapshots = null,
    Object? addedPrefixDocs = null,
    Object? hasReachedEnd = freezed,
    Object? streams = null,
    Object? lastDocument = freezed,
    Object? error = freezed,
  }) {
    return _then(_$_PaginationState(
      status: null == status
          ? _value.status
          : status // ignore: cast_nullable_to_non_nullable
              as Status,
      documentSnapshots: null == documentSnapshots
          ? _value._documentSnapshots
          : documentSnapshots // ignore: cast_nullable_to_non_nullable
              as List<DocumentSnapshot<Object?>>,
      addedPrefixDocs: null == addedPrefixDocs
          ? _value.addedPrefixDocs
          : addedPrefixDocs // ignore: cast_nullable_to_non_nullable
              as bool,
      hasReachedEnd:
          freezed == hasReachedEnd ? _value.hasReachedEnd! : hasReachedEnd,
      streams: null == streams
          ? _value._streams
          : streams // ignore: cast_nullable_to_non_nullable
              as List<StreamSubscription<QuerySnapshot<Object?>>>,
      lastDocument: freezed == lastDocument
          ? _value.lastDocument
          : lastDocument // ignore: cast_nullable_to_non_nullable
              as DocumentSnapshot<Object?>?,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as Exception?,
    ));
  }
}

/// @nodoc

class _$_PaginationState implements _PaginationState {
  _$_PaginationState(
      {this.status = Status.initial,
      final List<DocumentSnapshot<Object?>> documentSnapshots = const [],
      this.addedPrefixDocs = false,
      this.hasReachedEnd = false,
      final List<StreamSubscription<QuerySnapshot<Object?>>> streams = const [],
      this.lastDocument,
      this.error})
      : _documentSnapshots = documentSnapshots,
        _streams = streams;

  @override
  @JsonKey()
  final Status status;
  final List<DocumentSnapshot<Object?>> _documentSnapshots;
  @override
  @JsonKey()
  List<DocumentSnapshot<Object?>> get documentSnapshots {
    if (_documentSnapshots is EqualUnmodifiableListView)
      return _documentSnapshots;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_documentSnapshots);
  }

  @override
  @JsonKey()
  final bool addedPrefixDocs;
  @override
  @JsonKey()
  final dynamic hasReachedEnd;
  final List<StreamSubscription<QuerySnapshot<Object?>>> _streams;
  @override
  @JsonKey()
  List<StreamSubscription<QuerySnapshot<Object?>>> get streams {
    if (_streams is EqualUnmodifiableListView) return _streams;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_streams);
  }

  @override
  final DocumentSnapshot<Object?>? lastDocument;
  @override
  final Exception? error;

  @override
  String toString() {
    return 'PaginationState(status: $status, documentSnapshots: $documentSnapshots, addedPrefixDocs: $addedPrefixDocs, hasReachedEnd: $hasReachedEnd, streams: $streams, lastDocument: $lastDocument, error: $error)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_PaginationState &&
            (identical(other.status, status) || other.status == status) &&
            const DeepCollectionEquality()
                .equals(other._documentSnapshots, _documentSnapshots) &&
            (identical(other.addedPrefixDocs, addedPrefixDocs) ||
                other.addedPrefixDocs == addedPrefixDocs) &&
            const DeepCollectionEquality()
                .equals(other.hasReachedEnd, hasReachedEnd) &&
            const DeepCollectionEquality().equals(other._streams, _streams) &&
            (identical(other.lastDocument, lastDocument) ||
                other.lastDocument == lastDocument) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      status,
      const DeepCollectionEquality().hash(_documentSnapshots),
      addedPrefixDocs,
      const DeepCollectionEquality().hash(hasReachedEnd),
      const DeepCollectionEquality().hash(_streams),
      lastDocument,
      error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_PaginationStateCopyWith<_$_PaginationState> get copyWith =>
      __$$_PaginationStateCopyWithImpl<_$_PaginationState>(this, _$identity);
}

abstract class _PaginationState implements PaginationState {
  factory _PaginationState(
      {final Status status,
      final List<DocumentSnapshot<Object?>> documentSnapshots,
      final bool addedPrefixDocs,
      final dynamic hasReachedEnd,
      final List<StreamSubscription<QuerySnapshot<Object?>>> streams,
      final DocumentSnapshot<Object?>? lastDocument,
      final Exception? error}) = _$_PaginationState;

  @override
  Status get status;
  @override
  List<DocumentSnapshot<Object?>> get documentSnapshots;
  @override
  bool get addedPrefixDocs;
  @override
  dynamic get hasReachedEnd;
  @override
  List<StreamSubscription<QuerySnapshot<Object?>>> get streams;
  @override
  DocumentSnapshot<Object?>? get lastDocument;
  @override
  Exception? get error;
  @override
  @JsonKey(ignore: true)
  _$$_PaginationStateCopyWith<_$_PaginationState> get copyWith =>
      throw _privateConstructorUsedError;
}
