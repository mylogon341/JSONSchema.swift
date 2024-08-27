public enum ValidationErrorPropertiesLength: ValidationErrorReasonType {
  case tooFew(min: Int)
  case tooMany(max: Int)
  
  public var description: String {
    switch self {
    case .tooFew(min: let min):
      "Amount of properties is less than the required amount of \(min)"
    case .tooMany(max: let max):
      "Amount of properties is greater than maximum permitted of \(max)"
    }
  }
}

func validatePropertiesLength(_ context: Context, 
                              _ length: Int,
                              comparitor: @escaping ((Int, Int) -> (Bool)),
                              error: ValidationErrorPropertiesLength) -> (_ value: Any) -> AnySequence<ValidationError> {
  return { value in
    if let value = value as? [String: Any] {
      if !comparitor(length, value.count) {
        return AnySequence([
          ValidationError(
            .propertiesLength(error),
            instanceLocation: context.instanceLocation,
            keywordLocation: context.keywordLocation
          ),
        ])
      }
    }

    return AnySequence(EmptyCollection())
  }
}


func minProperties(context: Context, minProperties: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  guard let minProperties = minProperties as? Int else {
    return AnySequence(EmptyCollection())
  }

  return validatePropertiesLength(context, 
                                  minProperties,
                                  comparitor: <=,
                                  error: .tooFew(min: minProperties))(instance)
}


func maxProperties(context: Context, maxProperties: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  guard let maxProperties = maxProperties as? Int else {
    return AnySequence(EmptyCollection())
  }

  return validatePropertiesLength(context, 
                                  maxProperties,
                                  comparitor: >=,
                                  error: .tooMany(max: maxProperties))(instance)
}
