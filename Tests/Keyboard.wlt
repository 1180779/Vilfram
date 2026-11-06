Begin["ConnorGray`Vilfram`Private`"];

(* Replace only the front end boundary; run the real command dispatcher. *)
Internal`InheritedBlock[{getState, setState, EvaluationNotebook, FrontEndTokenExecute},
	Unprotect[EvaluationNotebook, FrontEndTokenExecute];
	Clear[getState, setState, EvaluationNotebook, FrontEndTokenExecute];
	state[_, _] := Inherited;
	getState[nb_, key_] := Replace[state[nb, key], Inherited :> Switch[key, "Mode", "Insert", "KeySequence", {}]];
	setState[nb_, key_ -> value_] := (state[nb, key] = value);
	EvaluationNotebook[] := NotebookObject["test"];
	FrontEndTokenExecute[token_] := (AppendTo[tokens, token]; Null);
	nb = EvaluationNotebook[];
	reset[] := (Clear[state]; state[_, _] := Inherited; tokens = {});
	press[keys__String] := Scan[processKeyDown[nb, #] &, {keys}];

	VerificationTest[stateDefault["Mode"], "Insert", TestID -> "new notebooks start in Insert"];
	VerificationTest[stateDefault["KeySequence"], {}, TestID -> "new notebooks have an empty buffer"];
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
		{"InsertSoftReturn", "Insert"}, TestID -> "O enters Insert after opening a line"
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
		"Vilfram  INSERT", TestID -> "bottom status identifies Insert mode"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", ":", "w"]; statusText[nb],
		"Vilfram  NORMAL    Keys: :w", TestID -> "bottom status shows pending command keys"
	];
	VerificationTest[
		reset[]; press["\[RawEscape]", "v", "h"]; statusText[nb],
		"Vilfram  VISUAL    Keys: v", TestID -> "bottom status identifies Visual mode"
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
