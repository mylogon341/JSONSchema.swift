public enum ValidationErrorValueBounds: ValidationErrorReasonType {
  case tooLow(min: Double)
  case tooHigh(max: Double)
  
  public var description: String {
    switch self {
    case .tooLow(min: let minimum):
      "Value is lower than minimum value of \(minimum)"
    case .tooHigh(max: let maximum):
      "Value exceeds maximum value of \(maximum)"
    }
  }
}

func validateNumericLength(_ context: Context, 
                           _ length: Double,
                           comparitor: @escaping ((Double, Double) -> (Bool)),
                           exclusiveComparitor: @escaping ((Double, Double) -> (Bool)),
                           exclusive: Bool?, 
                           error: ValidationErrorValueBounds) -> (_ value: Any) -> AnySequence<ValidationError> {
  return { value in
    if let value = value as? Double {
      if exclusive ?? false {
        if !exclusiveComparitor(value, length) {
          return AnySequence([
            ValidationError(
              .numericValue(error),
              instanceLocation: context.instanceLocation,
              keywordLocation: context.keywordLocation
            )
          ])
        }
      }

      if !comparitor(value, length) {
        return AnySequence([
          ValidationError(
            .numericValue(error),
            instanceLocation: context.instanceLocation,
            keywordLocation: context.keywordLocation
          )
        ])
      }
    }

    return AnySequence(EmptyCollection())
  }
}


func minimumDraft4(context: Context, minimum: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  guard let minimum = minimum as? Double else {
    return AnySequence(EmptyCollection())
  }

  return validateNumericLength(context, 
                               minimum, 
                               comparitor: >=,
                               exclusiveComparitor: >,
                               exclusive: schema["exclusiveMinimum"] as? Bool,
                               error: .tooLow(min: minimum))(instance)
}


func maximumDraft4(context: Context, maximum: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  guard let maximum = maximum as? Double else {
    return AnySequence(EmptyCollection())
  }

  return validateNumericLength(context, 
                               maximum,
                               comparitor: <=,
                               exclusiveComparitor: <,
                               exclusive: schema["exclusiveMaximum"] as? Bool,
                               error: .tooHigh(max: maximum))(instance)
}


func minimum(context: Context, minimum: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  guard let minimum = minimum as? Double else {
    return AnySequence(EmptyCollection())
  }

  return validateNumericLength(context,
                               minimum,
                               comparitor: >=,
                               exclusiveComparitor: >,
                               exclusive: false,
                               error: .tooLow(min: minimum))(instance)
}


func maximum(context: Context, maximum: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  guard let maximum = maximum as? Double else {
    return AnySequence(EmptyCollection())
  }

  return validateNumericLength(context, 
                               maximum, 
                               comparitor: <=,
                               exclusiveComparitor: <, 
                               exclusive: false,
                               error: .tooHigh(max: maximum))(instance)
}


func exclusiveMinimum(context: Context, minimum: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  guard let minimum = minimum as? Double else {
    return AnySequence(EmptyCollection())
  }

  return validateNumericLength(context, 
                               minimum,
                               comparitor: >=,
                               exclusiveComparitor: >,
                               exclusive: true,
                               error: .tooLow(min: minimum))(instance)
}


func exclusiveMaximum(context: Context, maximum: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  guard let maximum = maximum as? Double else {
    return AnySequence(EmptyCollection())
  }

  return validateNumericLength(context, 
                               maximum,
                               comparitor: <=,
                               exclusiveComparitor: <,
                               exclusive: true,
                               error: .tooHigh(max: maximum))(instance)
}
