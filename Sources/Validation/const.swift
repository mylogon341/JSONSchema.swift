import Foundation


func const(context: Context, const: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  if isEqual(instance as! NSObject, const as! NSObject) {
     return AnySequence(EmptyCollection())
  }

  return AnySequence([
    ValidationError(
      .applicators(.constNotMet(instance: instance, const: const)),
      instanceLocation: context.instanceLocation,
      keywordLocation: context.keywordLocation
    )
  ])
}
