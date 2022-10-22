// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target

part of 'todo_list_page_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$TodoListPageState {
  bool get isLoading => throw _privateConstructorUsedError;
  String get lastName => throw _privateConstructorUsedError;
  int get age => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $TodoListPageStateCopyWith<TodoListPageState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TodoListPageStateCopyWith<$Res> {
  factory $TodoListPageStateCopyWith(
          TodoListPageState value, $Res Function(TodoListPageState) then) =
      _$TodoListPageStateCopyWithImpl<$Res, TodoListPageState>;
  @useResult
  $Res call({bool isLoading, String lastName, int age});
}

/// @nodoc
class _$TodoListPageStateCopyWithImpl<$Res, $Val extends TodoListPageState>
    implements $TodoListPageStateCopyWith<$Res> {
  _$TodoListPageStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? lastName = null,
    Object? age = null,
  }) {
    return _then(_value.copyWith(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_TodoListPageStateCopyWith<$Res>
    implements $TodoListPageStateCopyWith<$Res> {
  factory _$$_TodoListPageStateCopyWith(_$_TodoListPageState value,
          $Res Function(_$_TodoListPageState) then) =
      __$$_TodoListPageStateCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({bool isLoading, String lastName, int age});
}

/// @nodoc
class __$$_TodoListPageStateCopyWithImpl<$Res>
    extends _$TodoListPageStateCopyWithImpl<$Res, _$_TodoListPageState>
    implements _$$_TodoListPageStateCopyWith<$Res> {
  __$$_TodoListPageStateCopyWithImpl(
      _$_TodoListPageState _value, $Res Function(_$_TodoListPageState) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? isLoading = null,
    Object? lastName = null,
    Object? age = null,
  }) {
    return _then(_$_TodoListPageState(
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      lastName: null == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String,
      age: null == age
          ? _value.age
          : age // ignore: cast_nullable_to_non_nullable
              as int,
    ));
  }
}

/// @nodoc

class _$_TodoListPageState
    with DiagnosticableTreeMixin
    implements _TodoListPageState {
  const _$_TodoListPageState(
      {required this.isLoading, required this.lastName, required this.age});

  @override
  final bool isLoading;
  @override
  final String lastName;
  @override
  final int age;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'TodoListPageState(isLoading: $isLoading, lastName: $lastName, age: $age)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'TodoListPageState'))
      ..add(DiagnosticsProperty('isLoading', isLoading))
      ..add(DiagnosticsProperty('lastName', lastName))
      ..add(DiagnosticsProperty('age', age));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_TodoListPageState &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.age, age) || other.age == age));
  }

  @override
  int get hashCode => Object.hash(runtimeType, isLoading, lastName, age);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_TodoListPageStateCopyWith<_$_TodoListPageState> get copyWith =>
      __$$_TodoListPageStateCopyWithImpl<_$_TodoListPageState>(
          this, _$identity);
}

abstract class _TodoListPageState implements TodoListPageState {
  const factory _TodoListPageState(
      {required final bool isLoading,
      required final String lastName,
      required final int age}) = _$_TodoListPageState;

  @override
  bool get isLoading;
  @override
  String get lastName;
  @override
  int get age;
  @override
  @JsonKey(ignore: true)
  _$$_TodoListPageStateCopyWith<_$_TodoListPageState> get copyWith =>
      throw _privateConstructorUsedError;
}
