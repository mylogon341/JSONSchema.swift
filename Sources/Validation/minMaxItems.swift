public enum ValidationErrorItemCount: ValidationErrorReasonType {
  case tooManyItems(max: Int)
  case tooFewItems(min: Int)
  
  public var description: String {
    switch self {
    case .tooManyItems(max: let maxItems):
      "Length of array is greater than maximum \(maxItems)"
    case .tooFewItems(min: let minItems):
      "Length of array is smaller than the minimum \(minItems)"
    }
  }
}

func validateArrayLength(_ context: Context,
                         _ rhs: Int,
                         comparitor: @escaping ((Int, Int) -> Bool),
                         error: ValidationErrorItemCount) -> (_ value: Any) -> AnySequence<ValidationError> {
  return { value in
    if let value = value as? [Any] {
      if !comparitor(value.count, rhs) {
        return AnySequence([
          ValidationError(
            .itemCount(error),
            instanceLocation: context.instanceLocation,
            keywordLocation: context.keywordLocation
          )
        ])
      }
    }
    
    return AnySequence(EmptyCollection())
  }
}


func minItems(context: Context, minItems: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  guard let minItems = minItems as? Int else {
    return AnySequence(EmptyCollection())
  }
  
  return validateArrayLength(context, minItems, 
                             comparitor: >=,
                             error: .tooFewItems(min: minItems))(instance)
}


func maxItems(context: Context, 
              maxItems: Any,
              instance: Any,
              schema: [String: Any]) -> AnySequence<ValidationError> {
  guard let maxItems = maxItems as? Int else {
    return AnySequence(EmptyCollection())
  }
  
  return validateArrayLength(context, 
                             maxItems,
                             comparitor: <=,
                             error: .tooManyItems(max: maxItems))(instance)
}
