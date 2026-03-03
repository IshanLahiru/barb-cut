/// Simple memoization utility for caching function results based on inputs.
///
/// This implementation uses a last-value cache: it remembers the previous input
/// and output, and only recomputes when the input changes.
///
/// Perfect for expensive computations that happen frequently with the same inputs
/// (e.g., filtering lists per rebuild, transforming data).
library;

typedef MemoizedFunction<TArg, TResult> = TResult Function(TArg arg);
typedef MemoizedFunction2<TA, TB, TResult> = TResult Function(TA a, TB b);
typedef MemoizedFunction3<TA, TB, TC, TResult> =
    TResult Function(TA a, TB b, TC c);

/// Simple memoizer for single-argument functions.
///
/// Caches the last input and result. If the input is equal to the cached input,
/// returns the cached result without calling the function.
///
/// Usage:
/// ```dart
/// final memoized = Memoizer<List<String>, List<String>>(
///   (items) => items.where((i) => i.startsWith('A')).toList(),
/// );
///
/// final result1 = memoized.call(items);  // Computes
/// final result2 = memoized.call(items);  // Returns cached result
/// ```
class Memoizer<TArg, TResult> {
  final MemoizedFunction<TArg, TResult> _fn;
  TArg? _lastArg;
  TResult? _lastResult;
  bool _hasCache = false;

  Memoizer(this._fn);

  TResult call(TArg arg) {
    if (_hasCache && _lastArg == arg) {
      return _lastResult as TResult;
    }
    _lastArg = arg;
    _lastResult = _fn(arg);
    _hasCache = true;
    return _lastResult as TResult;
  }

  /// Clear the cached value, forcing recomputation on next call.
  void clear() {
    _hasCache = false;
    _lastArg = null;
    _lastResult = null;
  }
}

/// Memoizer for two-argument functions.
class Memoizer2<TA, TB, TResult> {
  final MemoizedFunction2<TA, TB, TResult> _fn;
  TA? _lastA;
  TB? _lastB;
  TResult? _lastResult;
  bool _hasCache = false;

  Memoizer2(this._fn);

  TResult call(TA a, TB b) {
    if (_hasCache && _lastA == a && _lastB == b) {
      return _lastResult as TResult;
    }
    _lastA = a;
    _lastB = b;
    _lastResult = _fn(a, b);
    _hasCache = true;
    return _lastResult as TResult;
  }

  void clear() {
    _hasCache = false;
    _lastA = null;
    _lastB = null;
    _lastResult = null;
  }
}

/// Memoizer for three-argument functions.
class Memoizer3<TA, TB, TC, TResult> {
  final MemoizedFunction3<TA, TB, TC, TResult> _fn;
  TA? _lastA;
  TB? _lastB;
  TC? _lastC;
  TResult? _lastResult;
  bool _hasCache = false;

  Memoizer3(this._fn);

  TResult call(TA a, TB b, TC c) {
    if (_hasCache && _lastA == a && _lastB == b && _lastC == c) {
      return _lastResult as TResult;
    }
    _lastA = a;
    _lastB = b;
    _lastC = c;
    _lastResult = _fn(a, b, c);
    _hasCache = true;
    return _lastResult as TResult;
  }

  void clear() {
    _hasCache = false;
    _lastA = null;
    _lastB = null;
    _lastC = null;
    _lastResult = null;
  }
}
