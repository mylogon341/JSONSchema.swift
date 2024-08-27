

public enum ValidationResult: Encodable {
  case valid
  case invalid([ValidationError])

  enum CodingKeys: String, CodingKey {
    case valid
    case errors
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(valid, forKey: .valid)

    if !valid {
      try container.encode(errors, forKey: .errors)
    }
  }

  public var valid: Bool {
    switch self {
    case .valid:
      return true
    case .invalid:
      return false
    }
  }

  public var errors: [ValidationError]? {
    switch self {
    case .valid:
      return nil
    case .invalid(let errors):
      return errors
    }
  }
}
