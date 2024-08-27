
import Foundation

public protocol ValidationErrorReasonType: Error {
  var description: String { get }
}

public enum ValidationErrorReason {
  case stringLength(ValidationErrorStringLength)
  case itemCount(ValidationErrorItemCount)
  case numericValue(ValidationErrorValueBounds)
  case propertiesLength(ValidationErrorPropertiesLength)
  case multipleOf(ValidationErrorMultipleCheck)
  case pattern(ValidationErrorPatternCheck)
  case propertyInclusion(ValidationErrorPropertyInclusion)
  case uniqueness(ValidationErrorUniqueness)
  case typeCheck(ValidationErrorTypeCheck)
  case applicators(ValidationErrorApplicators)
  case formatting(ValidationErrorFormatting)
  case meta(ValidationErrorMeta)
  
  public var description: String {
    switch self {
    case .itemCount(let error): error.description
    case .propertiesLength(let error): error.description
    case .stringLength(let error): error.description
    case .numericValue(let error): error.description
    case .multipleOf(let error): error.description
    case .pattern(let error): error.description
    case .propertyInclusion(let error): error.description
    case .uniqueness(let error): error.description
    case .typeCheck(let error): error.description
    case .applicators(let error): error.description
    case .formatting(let error): error.description
    case .meta(let error): error.description
    }
  }
}

public class ValidationError: Encodable {
  
  public let errorReason: ValidationErrorReason
  public var description: String {
    errorReason.description
  }
  
  init(_ value: ValidationErrorReason,
       instanceLocation: JSONPointer,
       keywordLocation: JSONPointer) {
    self.errorReason = value
    self.instanceLocation = instanceLocation
    self.keywordLocation = keywordLocation
  }
  
  enum CodingKeys: String, CodingKey {
    case error
    case instanceLocation
    case keywordLocation
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(description, forKey: .error)
    try container.encode(instanceLocation.path, forKey: .instanceLocation)
    try container.encode(keywordLocation.path, forKey: .keywordLocation)
  }
  
  public let instanceLocation: JSONPointer
  public let keywordLocation: JSONPointer
}
