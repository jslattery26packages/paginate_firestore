import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:paginate_firestore/pagination/pagination_notifier.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'pagination_params_notifier.g.dart';

@riverpod
class PaginationParamsNotifier extends _$PaginationParamsNotifier {
  @override
  NotifierParams build() {
    return NotifierParams(
      query:
          FirebaseFirestore.instance.collection('users').orderBy('firstName'),
      limit: 20,
    );
  }

  setParams(NotifierParams params) {
    state = params;
  }
}
