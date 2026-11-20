# feat(nav): go back to the previous view or image with Escape

## Summary

Add a configurable **Back** action (default `Esc`) that returns to where the user was before opening an image:

| Opened from | Escape goes back to |
| --- | --- |
| Thumbnail preview | the same thumbnail preview |
| Recent Files | the Recent Files view |
| File explorer, open dialog, etc. | the previously opened image |
| Fullscreen | first Escape exits fullscreen, the next one goes back |
| Crop / comment editor | Escape cancels the edit first, the next one goes back |

`Back` is available in **View → Back** and in **Edit → Keyboard Shortcuts**, so the shortcut can be changed like any other action. It is disabled when there is nothing to go back to.

## Existing Escape behavior

Before this change, Escape was handled in several places:

* `app.closeOnEsc` ("Close on ESC", default off) closed the application.
* Escape exited fullscreen; frameless mode closed the window.
* Crop, comment and dialog widgets consumed Escape locally.
* `shortcut_esc` existed in `DkActionManager.h` but was unused.
* There was no back/navigation history.

This change keeps the existing behavior as a fallback and gives Back priority when a return target exists.

## Changes

### `DkActionManager`

* Added the `view_back` action ("Back", default `shortcut_esc`, tooltip "Return to the previous view or image").
* Added it to the View menu.

### `DkTabInfo`

* `mReturnMode`: the view the tab was in before opening an image (`tab_thumb_preview` or `tab_recent_files`).
* `mBackImages`: a bounded stack (20 entries) of previously opened image paths.
* `clearBackHistory()` clears both when a view is shown or a directory is loaded.

### `DkCentralWidget`

* `load()` records the current view mode when an image is opened from the thumbnail preview or Recent Files, and pushes the current image path when an image is opened from the explorer/open dialog while already viewing an image.
* `canGoBack()` is true when the current tab is an image view and has a return view or back images.
* `goBack()` pops back images first (most recent), then restores the return view.
* `updateBackAction()` enables/disables the action as the tab/view changes.

### `DkNoMacs`

* The Escape handling now lets the configured Back shortcut go through before `closeOnEsc`, while fullscreen exit still takes precedence.
* Applied to both the normal and frameless window filters.

### `DkPreferenceWidgets`

* Updated the "Close on ESC" tooltip to mention that Escape does not close the window when there is a previous view to return to.

## Testing

Built with Qt 6 on Linux and verified manually:

* Thumbnail preview → open image → Escape returns to the same preview.
* Recent Files → open image → Escape returns to Recent Files.
* Preview → image A → open image B from the open dialog → Escape returns to A, then Escape returns to the preview.
* Fullscreen: Escape exits fullscreen first; the next Escape goes back.
* Crop mode: Escape cancels the crop and stays on the image; the next Escape goes back.
* Back appears in the View menu and the shortcuts dialog, and is grayed out when unavailable.
* No ambiguous-shortcut warnings.

## Notes

* The history is per tab and session-only; it is not persisted across restarts.
* The image history is capped at 20 entries.
* Opening a directory clears the back history, since it starts a new browsing context.
* Images opened in a new tab are not closed by Back; only the current tab's view/image history is used.
