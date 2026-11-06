# Vilfram *— Vi for Wolfram*

Vi-like editing in Wolfram Notebooks

<!-- [[TODO: Feature overview GIF showing movement, selection expansion, etc. ]] -->

### Features

* Vilfram supports a subset of standard Vi-like movement, selection, deletion,
  and change commands, alongside notebook-specific selection expansion.

* Vilfram works in any file type that can be opened by the Wolfram front end,
  including: .nb, .wl, .wls, .wlt, and more.

* A compact strip at the bottom of each notebook shows `INSERT`, `NORMAL`,
  or `VISUAL` on a colored badge, with pending keys right-aligned and inset by
  12 points. The colors match this checkout's user's NvChad One Dark setup:
  Normal `#81a1c1`, Insert `#c882e7`, Visual `#a3b8ef`, on `#22262e`.
  There is no package label or `Keys:` prefix. Completed and invalid commands
  clear the buffer. Mode and pending keys are independent for each notebook.



## Getting Started

The [ConnorGray/Vilfram](https://paclets.com/ConnorGray/Vilfram) paclet can be
installed from [paclets.com](https://paclets.com) by evaluating:

```wolfram
PacletInstall["ConnorGray/Vilfram"]
```

Once installed, Vilfram will automatically be available and enabled in any
opened notebook.

[**Disabling Vilfram »**](#disabling-vilfram)

## Examples

#### Use `h`, `j`, `k`, and `l` keys for basic movement:

![Vilfram basic movement](./docs/media/vilfram-E1-basic-movement.gif)

#### Switch between Insert and Command mode:

<!-- The current mode is indicated in the [Window Status Area][WindowStatusArea]: -->

![Vilfram mode switching](./docs/media/vilfram-E2-switch-modes.gif)

#### Use `$`, `^`, `e`, and `b` to jump to the beginning and end of lines and words

![Vilfram line and word movement](./docs/media/vilfram-E3-line-and-word-movement.gif)

#### Use visual selection to quickly copy, cut, and delete

![Vilfram visual selection](./docs/media/vilfram-E4-visual-selection.gif)

#### Smart selection expansion to efficiently select the right subexpression

![Vilfram smart selection expansion](./docs/media/vilfram-E5-smart-selection-expansion.gif)



## All Supported Commands

The following Command-mode sequences are supported:

### Mode switching

* `i` — enter Insert mode at the current caret
* `a` — advance one native character/box position and enter Insert mode
* `I` — move to the beginning of the current notebook line and enter Insert mode
* `A` — move to the end of the current notebook line and enter Insert mode
* `o`, `O` — open a line below/above and enter Insert mode
* `Esc` — enter Command mode (shown as `NORMAL`) and cancel pending keys/visual selection

New notebooks start in Insert mode. `I` and `A` use the same notebook line
boundaries as `^` and `$`; notebook boxes and wrapped lines can differ from Vim's
plain text lines. Visual mode is represented internally by a retained `v` prefix;
the status bar reports that state as `VISUAL`. Pressing Escape stops extending the
selection without deleting the selected content.

### Movement

Character-oriented:

* `h` — move single character left
* `l` — move single character right
* `j` — move single line down
* `k` — move single line up

Word-oriented:

* `e` — move to next word
* `b` — move to previous word

Line-oriented:

* `0`, `^` — move to beginning of line
* `$` — move to end of line
* `o` — insert new line below
* `O` — insert new line above

Document-oriented:

* `gg` — move to top of notebook
* `G` — move to end of notebook

These document motions now follow Vim's direction; earlier versions of this
checkout had them reversed.

### Visual Selection

* `v` — begin visual selection
  - `h` — change selection single character left
  - `l` — change selection single character right
  - `j` — change selection single line down
  - `k` — change selection single line up
  - `e` — extend selection to next word
  - `b` — extend selection to previous word
  - `^` — extend selection to beginning of line
  - `$` — extend selection to end of line

  - `y` — copy ("yank") current selection
  - `x`, `d` — cut current selection and return to Normal mode
  - `c` — cut current selection and enter Insert mode

### Deletion

* `dd` — select the current native notebook text line and cut it
* `de` — delete to next word
* `db` — delete to previous word
* `dw` — delete to next natural word
* `d^` — delete to beginning of line
* `d$`, `D` — delete to end of line

### Change

* `cc` — clear the current line's contents and enter Insert mode
* `C` — delete from the caret to the end of the line and enter Insert mode

`cc` preserves the line break. `dd` uses the documented
[`SelectionMove[..., All, TextLine]`](https://reference.wolfram.com/language/ref/SelectionMove.html)
unit and the native Cut action, preserving structured notebook data on the
clipboard. If selecting the line fails, nothing is cut. Line boundaries and
line-break selection follow the front end, including in wrapped text and
typeset cells; this has not been verified in a live front end here. `p` uses
native Paste at the caret, rather than Vim's separate linewise paste behavior.
Counts such as `3dd`, registers, repeat (`.`), and general change motions such
as `cw` are not implemented.

### Other

* `u` — undo
* `:w` — save current notebook
* `:x` — save and close current notebook

## Notable differences from Vi

Wolfram Notebooks are different in structure and supported functionality from
traditional character-based editors. Some Vi commands have Vilfram analogues
with slightly different behavior that is better suited to the features of
the notebook environment.

* Structured selection commands

  Notebooks support a powerful and inuitive structural selection
  mechanism whereby the current selection can be expanded in steps that are each
  an enclosing syntactical structure.

  - `vi` — expands the selection each time `i` is pressed
  - `di+` — expands the selection each time `i` is pressed; deletes when the
  `Return` key is pressed

* Caret appearance

  Vilfram attempts to use a thick, mode-colored caret in Normal/Visual mode and
  restores the original caret in Insert mode. Disabling Vilfram restores both
  the original thickness and color. This uses undocumented
  `InsertionCaretThickness` and `InsertionCaretColor` front end settings,
  discovered in the installed Wolfram 15.0 front end. Thickness is applied only
  when the setting returns a number; color is applied independently when its
  setting returns an explicit color.

  This is experimental: it has not been visually verified. It widens the native
  insertion bar; it does not create Vim's character-width block positioned over
  a character. The setting applies to the front end session, so the status
  bar updates it when notebook focus changes, and key presses update it too.
  Front ends that do not expose the setting retain their usual caret.

  There is no separate enable switch. Press Escape for Normal mode and `i` for
  Insert mode. To check whether your front end exposes the setting, evaluate:

  ```wolfram
  CurrentValue[$FrontEndSession, "InsertionCaretThickness"]
  CurrentValue[$FrontEndSession, "InsertionCaretColor"]
  ```

  A numeric thickness enables automatic thickness switching. An explicit color
  (`RGBColor`, `GrayLevel`, `Hue`, or `CMYKColor`) enables automatic color
  switching even if thickness is unavailable. Other results mean that part of
  the experiment is unavailable; forcing a value is not a verified workaround.
  No verified setting for text-caret blinking was found. The always-visible
  colored mode badge provides a nonflashing cue regardless of caret support.



## Disabling Vilfram

> "Help! I installed Vilfram and now I'm stuck!"

**Don't panic.**
[You're not the first to get stuck in Vi.](https://stackoverflow.blog/2017/05/23/stack-overflow-helping-one-million-developers-exit-vim/)

To disable Vilfram, use your mouse to select the **Edit** > **Disable Vilfram**
menu item:

![Disable Vilfram menu item](./docs/media/enable-disable-menu-items.png)

This will persistently disable Vilfram in the current and future sessions.

Use **Edit** > **Enable Vilfram** to re-enable Vilfram.




[WindowStatusArea]: https://reference.wolfram.com/language/ref/WindowStatusArea

## Working from a local checkout

To load changes into an already running Mathematica kernel, evaluate:

```wolfram
Get["/home/rdkgsk/Projects/Vilfram/Kernel/Vilfram.wl"];
ConnorGray`Vilfram`EnableVilfram[$FrontEndSession];
```

This uses the checkout for the current session. Re-run after editing the source.
In a fresh kernel, you can also make the checkout discoverable with
[PacletDirectoryLoad](https://reference.wolfram.com/language/ref/PacletDirectoryLoad.html):

```wolfram
PacletDirectoryLoad["/home/rdkgsk/Projects/Vilfram"];
Needs["ConnorGray`Vilfram`"];
ConnorGray`Vilfram`EnableVilfram[$FrontEndSession];
```

`PacletDirectoryLoad` applies only to the current kernel session; repeat it
after restarting the kernel.

The styled strip uses
[AttachCell](https://reference.wolfram.com/language/ref/AttachCell.html), anchored
to the notebook's bottom edge. Its cell is deployed and is not saved with the
notebook. It is 26 points high and overlays the lower edge of the document
viewport; it does not reserve a separate row of document space. This is the
tradeoff for colored blocks and independent alignment: the native
[WindowStatusArea](https://reference.wolfram.com/language/ref/WindowStatusArea.html)
is text-oriented. The rendered strip has not yet been verified in a live front
end in this environment.

A dynamic native status area installs one attached strip per normal notebook.
It also updates the experimental caret only for the active notebook. Vilfram
preserves the existing scrollbars and other window controls. Disabling removes
the attached strips and restores the previous session settings. Re-enabling
also closes a floating palette left by an earlier Vilfram version. If the
attachment fails, the native status area retains a plain mode/key display.

The status bar is inherited from session options. A notebook with explicit local
`WindowStatusArea` or `WindowElements` settings can override it. To let such a
notebook use the session settings, evaluate in that notebook:

```wolfram
SetOptions[EvaluationNotebook[], WindowStatusArea -> Inherited, WindowElements -> Inherited];
```

To install the edited checkout for future Mathematica sessions:

```wolfram
archive = CreatePacletArchive["/home/rdkgsk/Projects/Vilfram"];
PacletInstall[archive, ForceVersionInstall -> True];
PacletEnable["ConnorGray/Vilfram"];
```

Then quit Mathematica completely and reopen it. Repeat after future source edits.

Run the keyboard regression tests from the checkout directory:

```sh
WolframKernel -noinit -noprompt -script Tests/Run.wls
```

These tests run the real dispatcher with in-memory notebook state and front end
tokens replaced at the boundary. They do not simulate physical keyboard events
or verify rendered notebook layout.
