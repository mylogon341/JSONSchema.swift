public enum ValidationErrorValueBounds: ValidationErrorReasonType {
  case tooLow(min: any Numeric, exclusive: Bool)
  case tooHigh(max: any Numeric, exclusive: Bool)
  
  public var description: String {
    switch self {
    case .tooLow(min: let minimum, exclusive: let exclusive):
      "Value is lower than minimum value of \(minimum) (exclusive \(exclusive))"
    case .tooHigh(max: let maximum, exclusive: let exclusive):
      "Value exceeds maximum value of \(maximum) (exclusive \(exclusive))"
    }
  }
}

func validateNumericLength<N: Comparable>(_ context: Context,
                                       _ length: N,
                                       comparitor: @escaping ((N, N) -> (Bool)),
                                       exclusiveComparitor: @escaping ((N, N) -> (Bool)),
                                       exclusive: Bool?,
                                       error: ValidationErrorValueBounds) -> (_ value: N) -> AnySequence<ValidationError> {
  return { value in
    
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
    
    return AnySequence(EmptyCollection())
  }
}

func minimumDraft4(context: Context, minimum: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  
  let exclusive = schema["exclusiveMinimum"] as? Bool
  
  switch (minimum, instance) {
  case (let min as Int, let ins as Int):
    return validateNumericLength(context,
                                 min,
                                 comparitor: >=,
                                 exclusiveComparitor: >,
                                 exclusive: exclusive,
                                 error: .tooLow(min: min, exclusive: exclusive ?? false))(ins)
  case (let min as Double, let ins as Double):
    return validateNumericLength(context,
                                 min,
                                 comparitor: >=,
                                 exclusiveComparitor: >,
                                 exclusive: exclusive,
                                 error: .tooLow(min: min, exclusive: exclusive ?? false))(ins)
  default:
    return AnySequence(EmptyCollection())
  }
  
}


func maximumDraft4(context: Context, maximum: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  
  let exclusive = schema["exclusiveMaximum"] as? Bool
  
  switch (maximum, instance) {
  case (let maximum as Int, let instance as Int):
    return validateNumericLength(context,
                                 maximum,
                                 comparitor: <=,
                                 exclusiveComparitor: <,
                                 exclusive: exclusive,
                                 error: .tooHigh(max: maximum, exclusive: exclusive ?? false))(instance)
  case (let maximum as Double, let instance as Double):
    return validateNumericLength(context,
                                 maximum,
                                 comparitor: <=,
                                 exclusiveComparitor: <,
                                 exclusive: exclusive,
                                 error: .tooHigh(max: maximum, exclusive: exclusive ?? false))(instance)
  default:
    return AnySequence(EmptyCollection())
  }
}


func minimum(context: Context, minimum: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  
  switch (minimum, instance) {
  case (let minimum as Int, let instance as Int):
    return validateNumericLength(context,
                                 minimum,
                                 comparitor: >=,
                                 exclusiveComparitor: >,
                                 exclusive: false,
                                 error: .tooLow(min: minimum, exclusive: false))(instance)
  case (let minimum as Double, let instance as Double):
    return validateNumericLength(context,
                                 minimum,
                                 comparitor: >=,
                                 exclusiveComparitor: >,
                                 exclusive: false,
                                 error: .tooLow(min: minimum, exclusive: false))(instance)
  default:
    return AnySequence(EmptyCollection())
  }

 
}


func maximum(context: Context, maximum: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  switch (maximum, instance) {
  case (let maximum as Int, let instance as Int):
    return validateNumericLength(context,
                                 maximum,
                                 comparitor: <=,
                                 exclusiveComparitor: <,
                                 exclusive: false,
                                 error: .tooHigh(max: maximum, exclusive: false))(instance)
  case (let maximum as Double, let instance as Double):
    return validateNumericLength(context,
                                 maximum,
                                 comparitor: <=,
                                 exclusiveComparitor: <,
                                 exclusive: false,
                                 error: .tooHigh(max: maximum, exclusive: false))(instance)
  default:
    return AnySequence(EmptyCollection())
  }
  
}


func exclusiveMinimum(context: Context, minimum: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  switch (minimum, instance) {
  case (let minimum as Int, let instance as Int):
    return validateNumericLength(context,
                                 minimum,
                                 comparitor: >=,
                                 exclusiveComparitor: >,
                                 exclusive: true,
                                 error: .tooLow(min: minimum, exclusive: true))(instance)
  case (let minimum as Double, let instance as Double):
    return validateNumericLength(context,
                                 minimum,
                                 comparitor: >=,
                                 exclusiveComparitor: >,
                                 exclusive: true,
                                 error: .tooLow(min: minimum, exclusive: true))(instance)
  default:
    return AnySequence(EmptyCollection())
  }
}

func exclusiveMaximum(context: Context, maximum: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  switch (maximum, instance) {
  case (let maximum as Int, let instance as Int):
    return validateNumericLength(context,
                                 maximum,
                                 comparitor: <=,
                                 exclusiveComparitor: <,
                                 exclusive: true,
                                 error: .tooHigh(max: maximum, exclusive: true))(instance)
  case (let maximum as Double, let instance as Double):
    return validateNumericLength(context,
                                 maximum,
                                 comparitor: <=,
                                 exclusiveComparitor: <,
                                 exclusive: true,
                                 error: .tooHigh(max: maximum, exclusive: true))(instance)
  default:
    return AnySequence(EmptyCollection())
  }

}
