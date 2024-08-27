import Foundation

public enum ValidationErrorMeta: ValidationErrorReasonType {
  case falsySchema
  
  public var description: String {
    switch self {
    case .falsySchema: 
      "Falsy schema"
    }
  }
}
