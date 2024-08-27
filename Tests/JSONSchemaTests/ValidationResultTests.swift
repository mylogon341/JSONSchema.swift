import Foundation
import Spectre
@testable import JSONSchema


public let testValidationResult: ((ContextType) -> Void) = {
  $0.describe("valid result") {
    $0.it("can be converted to JSON") {
      let result = ValidationResult.valid

      let jsonData = try JSONEncoder().encode(result)
      let json = try! JSONSerialization.jsonObject(with: jsonData) as! NSDictionary

      try expect(json) == [
        "valid": true,
      ]
    }
  }

  $0.describe("invalid result") {
    $0.it("can be converted to JSON") {
      let error = ValidationError(
        .meta(.falsySchema),
        instanceLocation: JSONPointer(path: "/test/1"),
        keywordLocation: JSONPointer(path: "#/example")
      )
      let result = ValidationResult.invalid([error])

      let jsonData = try JSONEncoder().encode(result)
      let json = try! JSONSerialization.jsonObject(with: jsonData) as! NSDictionary

      try expect(json) == [
        "valid": false,
        "errors": [
          [
            "error": "Falsy schema",
            "instanceLocation": "/test/1",
            "keywordLocation": "#/example",
          ],
        ],
      ]
    }
  }
}
