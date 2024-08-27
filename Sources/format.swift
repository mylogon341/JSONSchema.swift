import Foundation

public enum ValidationErrorFormatting: ValidationErrorReasonType {
  case unsupported(instance: String)
  case invalidIPv4Address(instance: String)
  case invalidIPv6Address(instance: String)
  case invalidUri(instance: String)
  case invalidRegex(instance: String)
  case invalidUUID(instance: String)
  case invalidJsonPointer(instance: String)
  case rfc3339Time(instance: String)
  case rfc3339Date(instance: String)
  case duration(instance: String)
  
  var name: String {
    switch self {
    case .invalidIPv4Address: "IPv4 address"
    case .invalidIPv6Address: "IPv6 address"
    case .invalidUri: "URI"
    case .invalidUUID: "UUID"
    case .invalidRegex: "regex"
    case .invalidJsonPointer: "JSON Pointer"
    case .rfc3339Time: "RFC 3339 formatted time"
    case .rfc3339Date: "RFC 3339 formatted date"
    case .duration: "duration"
      
    case .unsupported: fatalError("should not be referenced")
    }
  }
  
  public var description: String {
    switch self {
      
    case .unsupported(instance: let format):
      "'format' validation of '\(format)' is not yet supported."
    case .invalidIPv4Address(instance: let instance),
        .invalidIPv6Address(instance: let instance),
        .invalidUri(instance: let instance),
        .invalidRegex(instance: let instance),
        .invalidUUID(instance: let instance),
        .invalidJsonPointer(instance: let instance),
        .rfc3339Time(instance: let instance),
        .rfc3339Date(instance: let instance),
        .duration(instance: let instance):
      
      "'\(instance)' is an invalid \(name)"
    }
  }
}

func format(context: Context, format: Any, instance: Any, schema: [String: Any]) throws -> AnySequence<ValidationError> {
  guard let format = format as? String else {
    return AnySequence(EmptyCollection())
  }

  guard let instance = instance as? String else {
    return AnySequence(EmptyCollection())
  }

  guard let validator = context.validator.formats[format] else {
    return AnySequence([
      ValidationError(
        .formatting(.unsupported(instance: format)),
        instanceLocation: context.instanceLocation,
        keywordLocation: context.keywordLocation
      )
    ])
  }

  return validator(context, instance)
}


func validateIPv4(_ context: Context, _ value: String) -> AnySequence<ValidationError> {
  if let expression = try? NSRegularExpression(pattern: "^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$", options: NSRegularExpression.Options(rawValue: 0)) {
    if expression.matches(in: value, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, value.utf16.count)).count == 1 {
      return AnySequence(EmptyCollection())
    }
  }

  return AnySequence([
    ValidationError(
      .formatting(.invalidIPv4Address(instance: value)),
      instanceLocation: context.instanceLocation,
      keywordLocation: context.keywordLocation
    )
  ])
}


func validateIPv6(_ context: Context, _ value: String) -> AnySequence<ValidationError> {
  if !value.contains("%") {
    var buf = UnsafeMutablePointer<Int8>.allocate(capacity: Int(INET6_ADDRSTRLEN))
    if inet_pton(AF_INET6, value, &buf) == 1 {
      return AnySequence(EmptyCollection())
    }
  }

  return AnySequence([
    ValidationError(
      .formatting(.invalidIPv6Address(instance: value)),
      instanceLocation: context.instanceLocation,
      keywordLocation: context.keywordLocation
    )
  ])
}


func validateURI(_ context: Context, _ value: String) -> AnySequence<ValidationError> {
  // Using the regex from http://blog.dieweltistgarnichtso.net/constructing-a-regular-expression-that-matches-uris

  if let expression = try? NSRegularExpression(pattern: "((?<=\\()[A-Za-z][A-Za-z0-9\\+\\.\\-]*:([A-Za-z0-9\\.\\-_~:/\\?#\\[\\]@!\\$&'\\(\\)\\*\\+,;=]|%[A-Fa-f0-9]{2})+(?=\\)))|([A-Za-z][A-Za-z0-9\\+\\.\\-]*:([A-Za-z0-9\\.\\-_~:/\\?#\\[\\]@!\\$&'\\(\\)\\*\\+,;=]|%[A-Fa-f0-9]{2})+)", options: NSRegularExpression.Options(rawValue: 0)) {
    let result = expression.matches(in: value, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, value.utf16.count))
    if result.count == 1 {
      let foundRange = result[0].range
      if foundRange.location == 0 && foundRange.length == value.utf16.count {
        return AnySequence(EmptyCollection())
      }
    }
  }

  return AnySequence([
    ValidationError(
      .formatting(.invalidUri(instance: value)),
      instanceLocation: context.instanceLocation,
      keywordLocation: context.keywordLocation
    )
  ])
}


func validateUUID(_ context: Context, _ value: String) -> AnySequence<ValidationError> {
  if UUID(uuidString: value) == nil {
    return AnySequence([
      ValidationError(
        .formatting(.invalidUUID(instance: value)),
        instanceLocation: context.instanceLocation,
        keywordLocation: context.keywordLocation
      )
    ])
  }

  return AnySequence(EmptyCollection())
}


func validateRegex(_ context: Context, _ value: String) -> AnySequence<ValidationError> {
  do {
    _ = try NSRegularExpression(pattern: value)
  } catch {
    return AnySequence([
      ValidationError(
        .formatting(.invalidRegex(instance: value)),
        instanceLocation: context.instanceLocation,
        keywordLocation: context.keywordLocation
      )
    ])
  }

  return AnySequence(EmptyCollection())
}


func validateJSONPointer(_ context: Context, _ value: String) -> AnySequence<ValidationError> {
  guard !value.isEmpty else {
    return AnySequence(EmptyCollection())
  }

  if !value.hasPrefix("/") {
    return AnySequence([
      ValidationError(
        .formatting(.invalidJsonPointer(instance: value)),
        instanceLocation: context.instanceLocation,
        keywordLocation: context.keywordLocation
      )
    ])
  }

  if value
      .replacingOccurrences(of: "~0", with: "")
      .replacingOccurrences(of: "~1", with: "")
      .contains("~")
  {
    // unescaped ~
    return AnySequence([
      ValidationError(
        .formatting(.invalidJsonPointer(instance: value)),
        instanceLocation: context.instanceLocation,
        keywordLocation: context.keywordLocation
      )
    ])
  }

  return AnySequence(EmptyCollection())
}
