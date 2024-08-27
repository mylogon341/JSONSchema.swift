import Foundation

public enum ValidationErrorApplicators: ValidationErrorReasonType {
  case additionalItemsNotPermitted
  case anyOfNotMet(instance: Any)
  case containsNotMet(instance: Any)
  case maxContainsNotMet(instance: Any, max: Int)
  case missingDependency(key: String, property: String)
  case oneOfNotMet(oneOf: [Any], instance: Any)
  case notNotMet(instance: Any)
  case enumNotMet(instance: Any, enum: [Any])
  case constNotMet(instance: Any, const: Any)
  
  public var description: String {
    switch self {
    case .additionalItemsNotPermitted:
      "Additional results are not permitted in this array."
    case .anyOfNotMet(instance: let instance):
      "\(instance) does not meet anyOf validation rules."
    case .containsNotMet(instance: let instance):
      "'\(instance) does not match contains"
    case .maxContainsNotMet(instance: let instance, max: let max):
      "\(instance) does not match contains + maxContains \(max)"
    case .missingDependency(key: let key, property: let property):
      "'\(key)' is a dependency for '\(property)'"
    case .oneOfNotMet(oneOf: let oneOf, instance: let instance):
      "Only one value from `oneOf` (\(oneOf)) should be met (\(instance))"
    case .notNotMet(instance: let instance):
      "'\(instance)' does not match 'not' validation."
    case .enumNotMet(instance: let instance, enum: let `enum`):
      "'\(instance)' is not a valid enumeration value of '\(`enum`)'"
    case .constNotMet(instance: let instance, const: let const):
      "'\(instance)' is not equal to const '\(const)'"
    }
  }
}
