func contains(context: Context, contains: Any, instance: Any, schema: [String: Any]) throws -> AnySequence<ValidationError> {
  guard let instance = instance as? [Any] else {
    return AnySequence(EmptyCollection())
  }

  let min: Int
  if let minContains = schema["minContains"] as? Int, minContains >= 0 {
    min = minContains
  } else {
    min = 1
  }

  let max: Int?
  if let maxContains = schema["maxContains"] as? Int, maxContains > 0 {
    max = maxContains
  } else {

    max = nil
  }

  if max == nil && min == 0 {
    return AnySequence(EmptyCollection())
  }

  let containsCount = try Array(instance.enumerated()).filter({ (index, subinstance) throws -> Bool in
    context.instanceLocation.push(index.description)
    defer { context.instanceLocation.pop() }
    return try context.descend(instance: subinstance, subschema: contains).isValid
  }).count
  if let max = max, containsCount > max {
    return AnySequence([
      ValidationError(
        .applicators(.maxContainsNotMet(instance: instance, max: max)),
        instanceLocation: context.instanceLocation,
        keywordLocation: context.keywordLocation
      ),
      ValidationError(
        .applicators(.containsNotMet(instance: instance)),
        instanceLocation: context.instanceLocation,
        keywordLocation: context.keywordLocation
      )
    ])
  }

  if min == 0 || containsCount >= min {
    return AnySequence(EmptyCollection())
  }

  return AnySequence([
    ValidationError(
      .applicators(.containsNotMet(instance: instance)),
      instanceLocation: context.instanceLocation,
      keywordLocation: context.keywordLocation
    )
  ])
}
