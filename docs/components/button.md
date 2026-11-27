[Home](../README.md) › [Components](../README.md#components) › Button

# Button · `KaamosButton`

Action button. Equivalent of `<kaamos-button>` in open-ui-web.

```dart
KaamosButton(onPressed: save, child: const Text('Download'))
KaamosButton(
  onPressed: openDocs,
  variant: KaamosButtonVariant.secondary,
  trailing: const Text('→'),
  child: const Text('Learn more'),
)
KaamosButton(onPressed: null, child: const Text('Download')) // disabled
```

![Variants](../../test/components/button/goldens/button_variants.png)

## Parameters

| Parameter       | Type                  | Default   | Notes                                           |
| --------------- | --------------------- | --------- | ----------------------------------------------- |
| `onPressed`     | `VoidCallback?`       | required  | `null` = disabled                               |
| `child`         | `Widget`              | required  | usually a `Text`                                |
| `variant`       | `KaamosButtonVariant` | `primary` | `primary`, `secondary`, `tertiary`, `install`   |
| `leading`       | `Widget?`             | `null`    | before the label, 8px apart                     |
| `trailing`      | `Widget?`             | `null`    | after the label, 8px apart                      |
| `focusNode`     | `FocusNode?`          | `null`    | to focus it from code                           |
| `autofocus`     | `bool`                | `false`   |                                                 |
| `semanticLabel` | `String?`             | `null`    | for screen readers, useful with icons only      |

Icons in `leading`/`trailing` get their colour and size (16px) from an `IconTheme`.

## Keyboard and accessibility

- Tab moves focus, Enter or Space activates it.
- The focus ring only appears when using the keyboard.
- Screen readers announce it as a button, with its enabled/disabled state.

## Guidelines (DESIGN.md)

- **Only one `primary` per screen**: white is reserved for the main action.
- `secondary` for light actions ("Learn more →"), `tertiary` for medium actions inside cards, `install` on store cards.
- Height 36px (install 32px) on every platform: already above the WCAG AA threshold (24px) for touch targets, so one density only.
- As on the web, there is no hover state: it wouldn't exist on touch, and the look stays identical everywhere.

## See also

- [Foundation](../foundation.md#kaamospressable): the behaviour under every button
- [Navigation](navigation.md): pill tabs and the nav bar
