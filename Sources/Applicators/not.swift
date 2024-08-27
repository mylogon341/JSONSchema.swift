func not(context: Context, not: Any, instance: Any, schema: [String: Any]) throws -> AnySequence<ValidationError> {
  guard try context.descend(instance: instance, subschema: not).isValid else {
    return AnySequence(EmptyCollection())
  }

  return AnySequence([
    ValidationError(
      .applicators(.notNotMet(instance: instance)),
      instanceLocation: context.instanceLocation,
      keywordLocation: context.keywordLocation
    )
  ])
}

