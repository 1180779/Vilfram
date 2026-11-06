# Vilfram *— Vi for Wolfram*

Vi-like editing in Wolfram Notebooks

<!-- [[TODO: Feature overview GIF showing movement, selection expansion, etc. ]] -->

### Features

* Vilfram supports most of the standard Vi-like movement, selection, and
  deletion commands.

* Vilfram works in any file type that can be opened by the Wolfram front end,
  including: .nb, .wl, .wls, .wlt, and more.

* A small **Vilfram** palette shows the active notebook's `INSERT`, `NORMAL`,
  or `VISUAL` mode and pending command keys (for example `d`, `:w`, or `v`).
  Completed and invalid commands clear the key buffer. The palette follows
  notebook focus; mode and pending keys are independent for each notebook.



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

* `i`, `a` — enter Insert mode
* `I` — move to the beginning of the current notebook line and enter Insert mode
* `A` — move to the end of the current notebook line and enter Insert mode
* `o`, `O` — open a line below/above and enter Insert mode
* `Esc` — enter Command mode (shown as `NORMAL`) and cancel pending keys/visual selection

New notebooks start in Insert mode. `I` and `A` use the same notebook line
boundaries as `^` and `$`; notebook boxes and wrapped lines can differ from Vim's
plain text lines. Visual mode is represented internally by a retained `v` prefix;
the palette reports that state as `VISUAL`. Pressing Escape stops extending the
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

* `^` — move to beginning of line
* `$` — move to end of line
* `o` — insert new line below
* `O` — insert new line above

Document-oriented:

* `G` — move to top of notebook
* `gg` — move to end of notebook

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
  - `x` — cut current selection

### Deletion

* `de` — delete to next word
* `db` — delete to previous word
* `d^` — delete to beginning of line
* `d$` — delete to end of line

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

* No block caret

  Vi often distinguishes between Insert and Command mode by, respectively,
  changing the input caret between a block which is placed *on* a particular
  character, and a vertical bar which is placed *in-between* characters.



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

The status palette uses [CreatePalette](https://reference.wolfram.com/language/ref/CreatePalette.html)
and displays the state for `InputNotebook[]`. Re-enabling Vilfram reopens the
palette if it was closed; disabling Vilfram closes it.

Run the keyboard regression tests from the checkout directory:

```sh
WolframKernel -noinit -noprompt -script Tests/Run.wls
```

These tests run the real dispatcher with in-memory notebook state and front end
tokens replaced at the boundary. They do not simulate physical keyboard events
or verify rendered notebook layout.
