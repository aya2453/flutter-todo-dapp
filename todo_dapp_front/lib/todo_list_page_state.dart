import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';

part 'todo_list_page_state.freezed.dart';

@freezed
class TodoListPageState with _$TodoListPageState {
  const factory TodoListPageState({
    required bool isLoading,
    required String lastName,
    required int age,
  }) = _TodoListPageState;
}
