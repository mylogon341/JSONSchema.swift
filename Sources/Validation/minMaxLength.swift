public enum ValidationErrorStringLength: ValidationErrorReasonType {
  case tooManyCharacters(max: Int)
  case tooFewCharacters(min: Int)
  
  public var description: String {
    switch self {
    case .tooManyCharacters(max: let maxLength):
      "Length of string is larger than max length \(maxLength)"
    case .tooFewCharacters(min: let minLength):
      "Length of string is smaller than minimum length \(minLength)"
    }
  }
}

func validateLength(_ context: Context, 
                    _ comparitor: @escaping ((Int, Int) -> (Bool)),
                    length: Int,
                    error: ValidationErrorStringLength) -> (_ value: Any) -> AnySequence<ValidationError> {
  return { value in
    if let value = value as? String {
      if !comparitor(value.count, length) {
        return AnySequence([
          ValidationError(
            .stringLength(error),
            instanceLocation: context.instanceLocation,
            keywordLocation: context.keywordLocation
          ),
        ])
      }
    }

    return AnySequence(EmptyCollection())
  }
}


func minLength(context: Context, 
               minLength: Any,
               instance: Any,
               schema: [String: Any]) -> AnySequence<ValidationError> {
  guard let minLength = minLength as? Int else {
    return AnySequence(EmptyCollection())
  }

  return validateLength(context, 
                        >=,
                        length: minLength,
                        error: .tooFewCharacters(min: minLength))(instance)
}


func maxLength(context: Context, 
               maxLength: Any,
               instance: Any,
               schema: [String: Any]) -> AnySequence<ValidationError> {
  guard let maxLength = maxLength as? Int else {
    return AnySequence(EmptyCollection())
  }

  return validateLength(context, 
                        <=,
                        length: maxLength,
                        error: .tooManyCharacters(max: maxLength))(instance)
}
