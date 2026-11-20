# feat(thumbs): unify zoom shortcuts across image view, thumb view and film strip

## Summary

Make every zoomable view respond to the same shortcuts:

| View | Zoom in | Zoom out | Reset (Ctrl+0) |
| --- | --- | --- | --- |
| Image view | `Ctrl++`, `Ctrl+=`, `Ctrl+Shift+=` | `Ctrl+-` | fit image to window |
| Thumbnail view | `Ctrl++`, `Ctrl+=`, `Ctrl+Shift+=` | `Ctrl+-` | fit all thumbs to the viewport |
| Film strip | `Ctrl++`, `Ctrl+=`, `Ctrl+Shift+=` | `Ctrl+-` | default thumbnail size |

The zoom actions remain available in **Edit → Keyboard Shortcuts** (`View` and `Preview` groups), so users can rebind them like any other shortcut. The new `Reset Zoom` action is configurable as well.

## Motivation

* `Ctrl++` did not work in any view because `QKeySequence::ZoomIn` only contains `Ctrl++`, which does not match the actual key event produced by `Ctrl+Shift+=` on most layouts.
* The thumbnail view had no way to reset its zoom.
* The film strip could only be zoomed with `Ctrl+wheel`; it had no keyboard shortcuts.
* The thumbnail and image zoom shortcuts shared the same key sequences, which made them ambiguous when the thumb view was visible.

## Changes

### `DkActionManager`

* Added a small `zoomInShortcuts()` helper that returns `QKeySequence::ZoomIn` plus the `Ctrl+=` / `Ctrl+Shift+=` variants, and use it for both `view_zoom_in` and `preview_zoom_in`.
* Added the `preview_zoom_reset` action (`Ctrl+0`, reusing `shortcut_reset_view`).
* The thumbnail zoom actions use `Qt::WidgetWithChildrenShortcut`. They only activate while the thumb view or the film strip has focus, which removes the ambiguity with the image view shortcuts without disabling/enabling actions globally.

### `DkThumbScene` (thumbnail view)

* Added `resetThumbs()`: picks the largest thumbnail size for which the whole grid still fits the viewport.
* Extracted `setThumbSize()` from `resizeThumbs()` so zooming and resetting share the same clamping/layout logic.

### `DkThumbScrollWidget`

* Added the reset action to the thumb toolbar and connected/disconnected it with the other preview actions.
* Focus the thumb view when it becomes visible, so the zoom shortcuts work immediately after switching views.
* The shared zoom actions stay enabled when the thumb view is hidden, because the film strip uses them too.

### `DkFilePreview` (film strip)

* Reuses the same configurable `preview_zoom_in/out/reset` actions instead of hard-coded key handling.
* Added `zoomThumbs()` / `resetThumbSize()` and extracted `setThumbSize()` from `wheelEvent()`, so `Ctrl+wheel` and the keyboard shortcuts share one implementation.
* The strip accepts focus on click, which is required for the widget-scoped shortcuts.

## Testing

Built with Qt 6 on Linux and tested manually:

* Image view: `Ctrl+=`, `Ctrl+Shift+=` zoom in, `Ctrl+-` zooms out, `Ctrl+0` fits the image.
* Thumbnail view: same keys zoom the thumbnails; `Ctrl+0` fits all thumbnails to the panel.
* Film strip: clicking the strip and pressing the same keys zooms it; `Ctrl+0` restores the default thumbnail size; `Ctrl+wheel` still works.
* Switching between views no longer produces `Ambiguous shortcut overload` warnings.
* Verified the actions appear in **Edit → Keyboard Shortcuts** and can be edited.

## Notes

* `Zoom In` exposes its primary shortcut (`Ctrl++`) in the shortcuts dialog. The additional variants (`Ctrl+=`, `Ctrl+Shift+=`) are stored as extra shortcuts on the same action; assigning a custom shortcut replaces them with the chosen key.
* The print preview dialog keeps its existing (plain `+`/`-`) zoom shortcuts; it is a separate dialog and was intentionally left unchanged.
