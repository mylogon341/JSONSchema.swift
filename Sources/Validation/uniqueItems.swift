import Foundation

public enum ValidationErrorUniqueness: ValidationErrorReasonType {
  case uniqueItemsNotIncluded(collection: [Any])
  
  public var description: String {
    switch self {
    case .uniqueItemsNotIncluded(collection: let instance):
      "\(instance) does not have unique items"
    }
  }
}

func uniqueItems(context: Context, uniqueItems: Any, instance: Any, schema: [String: Any]) -> AnySequence<ValidationError> {
  guard let uniqueItems = uniqueItems as? Bool, uniqueItems else {
    return AnySequence(EmptyCollection())
  }

  guard let instance = instance as? [Any] else {
    return AnySequence(EmptyCollection())
  }

  var items: [Any] = []
  for item in instance {
    if items.contains(where: { isEqual(item as! NSObject, $0 as! NSObject) }) {
      return AnySequence([
        ValidationError(
          .uniqueness(.uniqueItemsNotIncluded(collection: instance)),
          instanceLocation: context.instanceLocation,
          keywordLocation: context.keywordLocation
        )
      ])
    }
    items.append(item)
  }

  return AnySequence(EmptyCollection())
}
