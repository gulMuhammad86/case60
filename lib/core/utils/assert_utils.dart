/// Guards a value against becoming null at the point of use.
///
/// Kept tiny and typed; use sparingly, mostly for migration/defaulting paths.
T requireNotNull<T>(T? value, {required String what}) {
  assert(value != null, '$what must not be null');
  return value as T;
}