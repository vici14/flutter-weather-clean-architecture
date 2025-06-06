// Mocks generated by Mockito 5.4.5 from annotations
// in weather_app_assignment/test/unit/services/location_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i4;

import 'package:dio/dio.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:weather_app_assignment/data/api_client.dart' as _i3;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: must_be_immutable
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeResponse_0<T1> extends _i1.SmartFake implements _i2.Response<T1> {
  _FakeResponse_0(Object parent, Invocation parentInvocation)
    : super(parent, parentInvocation);
}

/// A class which mocks [ApiClient].
///
/// See the documentation for Mockito's code generation for more information.
class MockApiClient extends _i1.Mock implements _i3.ApiClient {
  MockApiClient() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i4.Future<_i2.Response<T>> get<T>(
    String? path, {
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? headers,
  }) =>
      (super.noSuchMethod(
            Invocation.method(
              #get,
              [path],
              {#queryParameters: queryParameters, #headers: headers},
            ),
            returnValue: _i4.Future<_i2.Response<T>>.value(
              _FakeResponse_0<T>(
                this,
                Invocation.method(
                  #get,
                  [path],
                  {#queryParameters: queryParameters, #headers: headers},
                ),
              ),
            ),
          )
          as _i4.Future<_i2.Response<T>>);

  @override
  void close() => super.noSuchMethod(
    Invocation.method(#close, []),
    returnValueForMissingStub: null,
  );
}
