# snake_game

Snake Game

## State Management with Inherited Widget

- We need an object that holds the state we want to manage, e.g. `ScoresState`.
- We need an `InheritedWidget` that holds the state object. The widget should have a static `of` method that returns the
state object. The `of` method should call `dependOnInheritedWidgetOfExactType` to register itself as a dependent of the
`InheritedWidget`:
- 
```dart
  static ScoresState of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<ScoresStateScope>()!
        .scoresState;
  }
```

- We need a stateful widget that wraps the inherited widget. This stateful widget also provides an `api` for interacting
with any other service we might want to "provide" (like a persistent store or a service that calls an API). This
stateful widget also has a static `of` method that returns its `state` object. The child widgets can use this to
access the exposed `api`.