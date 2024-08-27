import Foundation

public enum ValidationErrorMultipleCheck: ValidationErrorReasonType {
  case notMultiple(instance: Double, multipleOf: Double)
  
  public var description: String {
    switch self {
    case .notMultiple(instance: let instance,
                      multipleOf: let multipleOf):
      "\(instance) is not a multiple of \(multipleOf)"
    }
  }
}

func multipleOf(context: Context, multipleOf: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  guard let multipleOf = multipleOf as? Double else {
    return AnySequence(EmptyCollection())
  }

  guard let instance = instance as? Double, instance > 0.0 else {
    return AnySequence(EmptyCollection())
  }

  let result = instance / multipleOf
  if result != floor(result) {
    return AnySequence([
      ValidationError(
        .multipleOf(.notMultiple(instance: instance,
                                 multipleOf: multipleOf)),
        instanceLocation: context.instanceLocation,
        keywordLocation: context.keywordLocation
      )
    ])
  }

  return AnySequence(EmptyCollection())
}
