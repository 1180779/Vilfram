Begin["ConnorGray`Vilfram`Private`"];

(* Replace only the front end boundary; run the real command dispatcher. *)
Internal`InheritedBlock[{getState, setState, EvaluationNotebook, FrontEndTokenExecute, SelectionMove},
	Unprotect[EvaluationNotebook, FrontEndTokenExecute, SelectionMove];
	Clear[getState, setState, EvaluationNotebook, FrontEndTokenExecute, SelectionMove];
	state[_, _] := Inherited;
	getState[nb_, key_] := Replace[state[nb, key], Inherited :> Switch[key, "Mode", "Insert", "KeySequence", {}]];
	setState[nb_, key_ -> value_] := (state[nb, key] = value);
	EvaluationNotebook[] := NotebookObject["test"];
	FrontEndTokenExecute[token_] := (AppendTo[tokens, token]; Null);
	SelectionMove[args___] := (AppendTo[moves, {args}]; Null);
	nb = EvaluationNotebook[];
	reset[] := (Clear[state]; state[_, _] := Inherited; tokens = {}; moves = {});
	press[keys__String] := Scan[processKeyDown[nb, #] &, {keys}];

	VerificationTest[stateDefault["Mode"], "Insert", TestID -> "new notebooks start in Insert"];
	Internal`InheritedBlock[{CurrentValue},
		Unprotect[CurrentValue]; Clear[CurrentValue];
		VerificationTest[
			reset[]; CurrentValue["EventKey"] = "\[RawEscape]";
			Replace["KeyUp", vilframEventActions[]];
			{modeLabel[nb], pendingKeys[nb]}, {"NORMAL", ""},
			TestID -> "Escape release returns to Normal when the press was consumed"
		];
		VerificationTest[
			reset[]; CurrentValue["EventKey"] = "a";
			Replace["KeyUp", vilframEventActions[]];
			{modeLabel[nb], tokens}, {"INSERT", {}},
			TestID -> "ordinary key releases leave Insert mode alone"
		];
		VerificationTest[
			reset[]; press["\[RawEscape]", "v", "l", "\[RawEscape]"];
			CurrentValue["EventKey"] = "\[RawEscape]";
			Replace["KeyUp", vilframEventActions[]];
			{modeLabel[nb], moves}, {"NORMAL", {{nb, After, Character}}},
			TestID -> "Escape press and release collapse a selection only once"
		];
	];
		VerificationTest[
			reset[];
			Replace["EscapeKeyDown", vilframEventActions[]];
			{modeLabel[nb], pendingKeys[nb]}, {"NORMAL", ""},
			TestID -> "dedicated Escape event returns to Normal without generic KeyDown"
		];
	VerificationTest[
		reset[]; press["\[RawEscape]", "v", "l", "\[RawEscape]", "i"];
		{moves, modeLabel[nb], pendingKeys[nb]},
		{{{nb, After, Character}}, "INSERT", ""},
		TestID -> "Escape collapses visual selection before entering Insert"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "v", "h", "\[RawEscape]"];
		{moves, modeLabel[nb]}, {{{nb, After, Character}}, "NORMAL"},
		TestID -> "Escape also collapses backward visual selections"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "v", "l", "y"];
		{tokens, moves, modeLabel[nb]},
		{{"SelectNext", "Copy"}, {{nb, Before, Character}}, "NORMAL"},
		TestID -> "visual yank collapses the selection after copying"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "v", "l", "v"];
		{moves, modeLabel[nb]}, {{{nb, After, Character}}, "NORMAL"},
		TestID -> "v toggles out of Visual and collapses the selection"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "d", "\[RawEscape]"]; moves,
		{}, TestID -> "canceling an ordinary prefix does not move the caret"
	];
	VerificationTest[
		reset[];
		Union[Flatten[Cases[statusBar[nb, 800], (expr : (_Pane | _Row | _Framed)) :>
			Complement[First /@ Select[List @@ expr, MatchQ[#, _Rule | _RuleDelayed] &],
				First /@ Options[Head[expr]]], {0, Infinity}]]],
		{}, TestID -> "status layout uses supported front end options"
	];
	VerificationTest[stateDefault["KeySequence"], {}, TestID -> "new notebooks have an empty buffer"];
	VerificationTest[
		reset[]; press["\[RawEscape]", "a"]; {tokens, getState[nb, "Mode"]},
		{{"MoveNext"}, "Insert"}, TestID -> "a advances before entering Insert"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "i"]; {tokens, getState[nb, "Mode"]},
		{{}, "Insert"}, TestID -> "i inserts at the current caret"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "O"]; {tokens, getState[nb, "Mode"]},
		{{"MoveLineBeginning", "InsertSoftReturn", "MovePreviousLine", "MoveLineBeginning"}, "Insert"},
		TestID -> "O opens above even when there is no previous line"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "d"]; {tokens, moves, pendingKeys[nb]},
		{{}, {}, "d"}, TestID -> "d waits for a motion or another d"
	];
	VerificationTest[
		press["d"]; {tokens, moves, getState[nb, "Mode"], pendingKeys[nb]},
		{{"Cut"}, {{nb, All, TextLine}}, "Command", ""},
		TestID -> "dd cuts a native notebook line and stays in Normal"
	];
	Internal`InheritedBlock[{SelectionMove},
		Clear[SelectionMove]; SelectionMove[___] := $Failed;
		VerificationTest[
			reset[]; press["\[RawEscape]", "d", "d"]; {tokens, pendingKeys[nb]},
			{{}, ""}, TestID -> "dd never cuts an old selection if line selection fails"
		];
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "D"]; {tokens, getState[nb, "Mode"]},
		{{"DeleteLineEnd"}, "Command"}, TestID -> "D deletes to the end of the line"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "C"]; {tokens, getState[nb, "Mode"], pendingKeys[nb]},
		{{"DeleteLineEnd"}, "Insert", ""}, TestID -> "C changes to the end of the line"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "c"]; {tokens, pendingKeys[nb], getState[nb, "Mode"]},
		{{}, "c", "Command"}, TestID -> "c waits without entering Insert"
	];
	VerificationTest[
		press["c"]; {tokens, getState[nb, "Mode"], pendingKeys[nb]},
		{{"MoveLineBeginning", "DeleteLineEnd"}, "Insert", ""},
		TestID -> "cc clears the line contents and enters Insert"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "0"]; tokens,
		{"MoveLineBeginning"}, TestID -> "zero moves to the line beginning"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "g", "g", "G"]; moves,
		{{nb, Before, Notebook}, {nb, After, Notebook}}, TestID -> "gg goes to the top and G to the bottom"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "v", "l", "d"]; {tokens, modeLabel[nb], pendingKeys[nb]},
		{{"SelectNext", "Cut"}, "NORMAL", ""}, TestID -> "visual d cuts and returns to Normal"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "v", "l", "c"]; {tokens, modeLabel[nb], pendingKeys[nb]},
		{{"SelectNext", "Cut"}, "INSERT", ""}, TestID -> "visual c cuts and enters Insert"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "I"]; {tokens, getState[nb, "Mode"], getState[nb, "KeySequence"]},
		{{"MoveLineBeginning"}, "Insert", {}}, TestID -> "I moves to line beginning and inserts"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "A"]; {tokens, getState[nb, "Mode"]},
		{{"MoveLineEnd"}, "Insert"}, TestID -> "A moves to line end and inserts"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "q", "h"]; {tokens, getState[nb, "KeySequence"]},
		{{"MovePrevious"}, {}}, TestID -> "invalid keys do not poison later commands"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", ":", "w"]; getState[nb, "KeySequence"],
		{":", "w"}, TestID -> "incomplete commands remain visible"
	];
	VerificationTest[
		press["\r"]; {tokens, getState[nb, "KeySequence"]},
		{{"Save"}, {}}, TestID -> "completed commands clear the buffer"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "v", "h", "l"]; {tokens, getState[nb, "KeySequence"], modeLabel[nb]},
		{{"SelectPrevious", "SelectNext"}, {"v"}, "VISUAL"}, TestID -> "visual mode keeps a bounded prefix"
	];
	VerificationTest[
		press["y"]; {tokens, getState[nb, "KeySequence"], modeLabel[nb]},
		{{"SelectPrevious", "SelectNext", "Copy"}, {}, "NORMAL"}, TestID -> "visual yank returns to Normal"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "d", "i", "i", "\[RawEscape]"];
		{tokens, getState[nb, "Mode"], getState[nb, "KeySequence"]},
		{{"ExpandSelection", "ExpandSelection"}, "Command", {}}, TestID -> "Escape cancels sticky commands"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "d"]; getState[NotebookObject["other"], "KeySequence"],
		{}, TestID -> "notebook buffers remain independent"
	];
	VerificationTest[
		reset[]; press["I", "A", "h"]; {tokens, getState[nb, "Mode"]},
		{{}, "Insert"}, TestID -> "Insert mode leaves typing alone"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "o"]; {Last[tokens], getState[nb, "Mode"]},
		{"InsertSoftReturn", "Insert"}, TestID -> "o enters Insert after opening a line"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "O"]; {Last[tokens], getState[nb, "Mode"]},
		{"MoveLineBeginning", "Insert"}, TestID -> "O enters Insert at the beginning of the new line"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", ":", "q", "h"]; {tokens, getState[nb, "KeySequence"]},
		{{"MovePrevious"}, {}}, TestID -> "invalid command continuations clear the buffer"
	];
	VerificationTest[
		reset[]; setState[nb, "Mode" -> "Insert"]; setState[nb, "KeySequence" -> {"d"}];
		press["\[RawEscape]"]; {getState[nb, "Mode"], getState[nb, "KeySequence"]},
		{"Command", {}}, TestID -> "Escape from Insert also clears stale keys"
	];
	VerificationTest[
		reset[]; statusText[nb],
		"INSERT", TestID -> "bottom status identifies Insert mode without branding"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", ":", "w"]; statusText[nb],
		"NORMAL    :w", TestID -> "bottom status shows pending command keys"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "v", "h"]; statusText[nb],
		"VISUAL    v", TestID -> "bottom status identifies Visual mode"
	];
	VerificationTest[
		reset[]; {modeColor[nb], press["\[RawEscape]"]; modeColor[nb], press["v"]; modeColor[nb]},
		{RGBColor["#c882e7"], RGBColor["#81a1c1"], RGBColor["#a3b8ef"]},
		TestID -> "mode colors match the active NvChad One Dark highlights"
	];
	Internal`InheritedBlock[{CurrentValue},
		Unprotect[CurrentValue]; Clear[CurrentValue];
		Block[{$originalCaretThickness = 1, $appliedCaretThickness},
			VerificationTest[
				reset[]; press["\[RawEscape]", "h"]; CurrentValue[$FrontEndSession, "InsertionCaretThickness"],
				6, TestID -> "Normal mode uses a thick caret"
			];
			VerificationTest[
				setState[nb, "Mode" -> "Insert"]; updateCaret[nb];
				CurrentValue[$FrontEndSession, "InsertionCaretThickness"],
				1, TestID -> "Insert restores the original caret width"
			];
			VerificationTest[
				$originalCaretThickness = $Failed; setState[nb, "Mode" -> "Command"]; updateCaret[nb];
				CurrentValue[$FrontEndSession, "InsertionCaretThickness"],
				1, TestID -> "unsupported front ends leave caret settings alone"
			];
			Block[{$originalCaretColor = GrayLevel[0], $appliedCaretColor},
				VerificationTest[
					reset[]; setState[nb, "Mode" -> "Command"]; updateCaret[nb];
					CurrentValue[$FrontEndSession, "InsertionCaretColor"], RGBColor["#81a1c1"],
					TestID -> "caret color works independently of unavailable thickness"
				];
				VerificationTest[
					setState[nb, "KeySequence" -> {"v"}]; updateCaret[nb];
					CurrentValue[$FrontEndSession, "InsertionCaretColor"], RGBColor["#a3b8ef"],
					TestID -> "Visual caret uses the Visual mode color"
				];
				VerificationTest[
					setState[nb, "Mode" -> "Insert"]; updateCaret[nb];
					CurrentValue[$FrontEndSession, "InsertionCaretColor"], GrayLevel[0],
					TestID -> "Insert restores the original caret color"
				];
				VerificationTest[
					$originalCaretColor = $Failed; setState[nb, "Mode" -> "Command"]; updateCaret[nb];
					CurrentValue[$FrontEndSession, "InsertionCaretColor"], GrayLevel[0],
					TestID -> "unsupported caret color remains unchanged"
				];
			]
		]
	];
	Internal`InheritedBlock[{AttachCell, CurrentValue, NotebookDelete},
		Unprotect[AttachCell, CurrentValue, NotebookDelete];
		Clear[AttachCell, CurrentValue, NotebookDelete];
		Block[{$statusCells, $originalStatusOptions},
			attachments = 0; deleted = {};
			CurrentValue[_, WindowFrame] := "Normal";
			AttachCell[_, _Cell, ___] := (attachments++; CellObject["status"]);
			NotebookDelete[cell_] := (AppendTo[deleted, cell]; Null);
			VerificationTest[
				ensureStatusBar[nb]; ensureStatusBar[nb]; attachments, 1,
				TestID -> "only one attached status strip is created per notebook"
			];
			VerificationTest[
				disableStatusBar[]; deleted, {CellObject["status"]},
				TestID -> "disabling removes attached status strips"
			];
		]
	];
	Internal`InheritedBlock[{CurrentValue},
		Unprotect[CurrentValue]; Clear[CurrentValue];
		Block[{$originalStatusOptions, $FrontEndSession = testSession},
			original = {WindowStatusArea -> "Previous status",
				WindowElements -> {"VerticalScrollBar", "MagnificationPopUp"}};
			Options[testSession] = original;
			CurrentValue[_, WindowElements] := WindowElements /. Options[testSession];
			VerificationTest[
				enableStatusBar[]; WindowElements /. Options[testSession],
				{"VerticalScrollBar", "MagnificationPopUp", "StatusArea"},
				TestID -> "bottom status preserves existing window controls"
			];
			VerificationTest[
				MatchQ[WindowStatusArea /. Options[testSession], _Dynamic], True,
				TestID -> "bottom status is dynamic"
			];
			VerificationTest[
				enableStatusBar[]; Count[WindowElements /. Options[testSession], "StatusArea"], 1,
				TestID -> "re-enabling does not duplicate the status area"
			];
			VerificationTest[
				disableStatusBar[]; Sort[Options[testSession]], Sort[original],
				TestID -> "disabling restores the original status and window controls"
			];
		]
	];
];

End[];
