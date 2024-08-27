import Foundation

public enum ValidationErrorPatternCheck: ValidationErrorReasonType {
  case invalid(pattern: String)
  case mismatch(instance: String, pattern: String)
  
  public var description: String {
    switch self {
    case .invalid(pattern: let pattern):
      
      "[Schema] Regex pattern '\(pattern)' is not valid"
    case .mismatch(instance: let instance, pattern: let pattern):
      "'\(instance)' does not match pattern: '\(pattern)'"
    }
  }
}

func pattern(context: Context, pattern: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  guard let pattern = pattern as? String else {
    return AnySequence(EmptyCollection())
  }

  guard let instance = instance as? String else {
    return AnySequence(EmptyCollection())
  }

  guard let expression = try? NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options(rawValue: 0)) else {
    return AnySequence([
      ValidationError(
        .formatting(.invalidRegex(instance: instance)),
        instanceLocation: context.instanceLocation,
        keywordLocation: context.keywordLocation
      )
    ])
  }

  let range = NSMakeRange(0, instance.count)
  if expression.matches(in: instance, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: range).count == 0 {
    return AnySequence([
      ValidationError(
        .pattern(.mismatch(instance: instance, pattern: pattern)),
        instanceLocation: context.instanceLocation,
        keywordLocation: context.keywordLocation
      )
    ])
  }

  return AnySequence(EmptyCollection())
}
