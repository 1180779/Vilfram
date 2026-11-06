(* ::Package:: *)

(* ::Input:: *)
(*ConnorGray`Vilfram`EnableVilfram[EvaluationNotebook[]]*)


(* ::Input:: *)
(*Dynamic[CurrentValue[EvaluationNotebook[], {TaggingRules,"Vilfram"}]]*)


BeginPackage["ConnorGray`Vilfram`"];

Needs["GeneralUtilities`"]

GeneralUtilities`SetUsage[$VilframCommands, "
$VilframCommands contains the recognized command sequences and actions to be executed.
"];

GeneralUtilities`SetUsage[EnableVilfram, "
EnableVilfram[] enables Vilfram for the current and future front end sessions.

EnableVilfram[$FrontEndSession] enables Vilfram for the current front end session.

EnableVilfram[$FrontEndSession] is called automatically at the beginning of
every front end session if the ConnorGray/Vilfram paclet is installed and enabled.
"];

(* EnableVilfram[nbobj$] enables Vilfram keyboard behavior in the notebook represented by the notebook object nbobj$. *)

GeneralUtilities`SetUsage[DisableVilfram, "
DisableVilfram[] disables Vilfram for the current and future front end sessions.

DisableVilfram[$FrontEndSession] disables Vilfram for the current front end session.

DisableVilfram uninstalls the global event handlers used by Vilfram, and uses
PacletDisable to prevent the ConnorGray/Vilfram paclet from automatically
loading in future front end sessions.
"];

GeneralUtilities`SetUsage[$RetainKeyCommandSequence, "
RetainKeySequence is a special value that, when returned from a Vilfram command handler, indicates
that the current key sequence should not be reset.

This is intended to be used by Vilfram command that is 'sticky'.
"];


Begin["`Private`"];

(*====================================*)

$VilframCommands = {
	(*--------------------*)
	(* Common Vi Commands *)
	(*--------------------*)
	{"i"} :> (
		setState[EvaluationNotebook[], "Mode" -> "Insert"]
	),
	{"a"} :> (
		FrontEndTokenExecute["MoveNext"];
		setState[EvaluationNotebook[], "Mode" -> "Insert"]
	),
	{"I"} :> (
		FrontEndTokenExecute["MoveLineBeginning"];
		setState[EvaluationNotebook[], "Mode" -> "Insert"]
	),
	{"A"} :> (
		FrontEndTokenExecute["MoveLineEnd"];
		setState[EvaluationNotebook[], "Mode" -> "Insert"]
	),
	{"j"} :> FrontEndTokenExecute["MoveNextLine"],
	{"k"} :> FrontEndTokenExecute["MovePreviousLine"],
	{"h"} :> FrontEndTokenExecute["MovePrevious"],
	{"l"} :> FrontEndTokenExecute["MoveNext"],
	(* TODO: This should be MovePreviousWord, however that token appears to a
		have a bug when used in textual cells: it gets "stuck" at the beginning
		of a word boundary and won't move back. MovePreviousNaturalWord doesn't
		have that problem, and also works in box/typesetting cells. *)
	{"b"} :> FrontEndTokenExecute["MovePreviousNaturalWord"],
	(* TODO: This isn't the right behavior. `B` should move back through all
		consecutive non-whitespace. *)
	{"B"} :> FrontEndTokenExecute["MovePreviousNaturalWord"],
	{"e"} :> FrontEndTokenExecute["MoveNextWord"],
	{"0" | "^"} :> FrontEndTokenExecute["MoveLineBeginning"],
	{"$"} :> FrontEndTokenExecute["MoveLineEnd"],
	{"G"} :> SelectionMove[EvaluationNotebook[], After, Notebook],
	{"g", "g"} :> SelectionMove[EvaluationNotebook[], Before, Notebook],
	{"u"} :> FrontEndTokenExecute["Undo"],
	{"x"} :> FrontEndTokenExecute["Cut"],
	{"y"} :> FrontEndTokenExecute["Copy"],
	{"p"} :> FrontEndTokenExecute["Paste"],
	{"o"} :> (
		FrontEndTokenExecute["MoveLineEnd"];
		FrontEndTokenExecute["InsertSoftReturn"];
		setState[EvaluationNotebook[], "Mode" -> "Insert"]
	),
	{"O"} :> (
		FrontEndTokenExecute["MoveLineBeginning"];
		FrontEndTokenExecute["InsertSoftReturn"];
		FrontEndTokenExecute["MovePreviousLine"];
		FrontEndTokenExecute["MoveLineBeginning"];
		setState[EvaluationNotebook[], "Mode" -> "Insert"]
	),
	{":", "w", "\r"} :> (
		FrontEndTokenExecute["Save"];
	),
	{":", "x", "\r"} :> (
		FrontEndTokenExecute["Save"];
		FrontEndTokenExecute["Close"];
	),
	{"d", "e"} :> FrontEndTokenExecute["DeleteNextWord"],
	{"d", "b"} :> FrontEndTokenExecute["DeletePreviousWord"],
	{"d", "w"} :> FrontEndTokenExecute["DeleteNextNaturalWord"],
	{"d", "^"} :> FrontEndTokenExecute["DeleteLineBeginning"],
	{"d", "$"} :> FrontEndTokenExecute["DeleteLineEnd"],
	{"D"} :> FrontEndTokenExecute["DeleteLineEnd"],
	{"d", "d"} :> (
		(* Use the native line unit so structured boxes are not flattened to text. *)
		If[SelectionMove[EvaluationNotebook[], All, TextLine] =!= $Failed,
			FrontEndTokenExecute["Cut"]
		]
	),
	{"C"} :> (
		FrontEndTokenExecute["DeleteLineEnd"];
		setState[EvaluationNotebook[], "Mode" -> "Insert"]
	),
	{"c", "c"} :> (
		FrontEndTokenExecute["MoveLineBeginning"];
		FrontEndTokenExecute["DeleteLineEnd"];
		setState[EvaluationNotebook[], "Mode" -> "Insert"]
	),
	(*--------------------------------*)
	(* Visual selection sub-commands. *)
	(*--------------------------------*)
	{"v", ___, "h"} :> (
		FrontEndTokenExecute["SelectPrevious"];
		$RetainKeyCommandSequence
	),
	{"v", ___, "l"} :> (
		FrontEndTokenExecute["SelectNext"];
		$RetainKeyCommandSequence
	),
	{"v", ___, "j"} :> (
		FrontEndTokenExecute["SelectNextLine"];
		$RetainKeyCommandSequence
	),
	{"v", ___, "k"} :> (
		FrontEndTokenExecute["SelectPreviousLine"];
		$RetainKeyCommandSequence
	),
	{"v", ___, "e"} :> (
		FrontEndTokenExecute["SelectNextWord"];
		$RetainKeyCommandSequence
	),
	{"v", ___, "b"} :> (
		FrontEndTokenExecute["SelectPreviousWord"];
		$RetainKeyCommandSequence
	),
	{"v", ___, "$"} :> (
		FrontEndTokenExecute["SelectLineEnd"];
		$RetainKeyCommandSequence
	),
	{"v", ___, "^"} :> (
		FrontEndTokenExecute["SelectLineBeginning"];
		$RetainKeyCommandSequence
	),
	{"v", ___, "i"} :> (
		FrontEndTokenExecute["ExpandSelection"];
		$RetainKeyCommandSequence
	),
	{"v", ___, "x" | "d"} :> (
		FrontEndTokenExecute["Cut"];
	),
	{"v", ___, "c"} :> (
		FrontEndTokenExecute["Cut"];
		setState[EvaluationNotebook[], "Mode" -> "Insert"]
	),
	{"v", ___, "y"} :> (
		FrontEndTokenExecute["Copy"];
		SelectionMove[EvaluationNotebook[], Before, Character]
	),
	{"v", ___, "v"} :> SelectionMove[EvaluationNotebook[], After, Character],
	(*------------------*)
	(* Vi-like Commands *)
	(*------------------*)
	{"d", Repeated["i"]} :> (
		FrontEndTokenExecute["ExpandSelection"];
		$RetainKeyCommandSequence
	),
	{"d", Repeated["i"], "\r"} :> (
		NotebookDelete[EvaluationNotebook[]]
	)
};

(*====================================*)

EnableVilfram[] := (
	EnableVilfram[$FrontEndSession];
	PacletEnable["ConnorGray/Vilfram"]
)

EnableVilfram[obj:$FrontEndSession] := (
	setVilframOptions[obj];
	If[!ValueQ[$originalCaretThickness],
		$originalCaretThickness = Quiet[CurrentValue[$FrontEndSession, "InsertionCaretThickness"]]
	];
	If[!ValueQ[$originalCaretColor],
		$originalCaretColor = Quiet[CurrentValue[$FrontEndSession, "InsertionCaretColor"]]
	];
	(* Close the palette left by a previously loaded version. *)
	If[MatchQ[$statusPalette, _NotebookObject], Quiet[NotebookClose[$statusPalette]]];
	$statusPalette = None;
	enableStatusBar[];
)

setVilframOptions[obj : $FrontEndSession | _NotebookObject] :=
	SetOptions[obj, {
		NotebookEventActions -> {
			PassEventsDown :> (
				getState[EvaluationNotebook[], "Mode"] =!= "Command"
				&& CurrentValue["EventKey"] =!= "\[RawEscape]"
			),
			"KeyDown" :> processKeyDown[EvaluationNotebook[], CurrentValue["EventKey"]]
		}
	}]

(*====================================*)

DisableVilfram[] := (
	DisableVilfram[$FrontEndSession];
	PacletDisable["ConnorGray/Vilfram"]
)

DisableVilfram[$FrontEndSession] := (
	SetOptions[$FrontEndSession, {
		NotebookEventActions -> Inherited
	}];
	If[MatchQ[$statusPalette, _NotebookObject], Quiet[NotebookClose[$statusPalette]]];
	$statusPalette = None;
	disableStatusBar[];
	If[NumberQ[$originalCaretThickness],
		CurrentValue[$FrontEndSession, "InsertionCaretThickness"] = $originalCaretThickness
	];
	If[MatchQ[$originalCaretColor, _RGBColor | _GrayLevel | _Hue | _CMYKColor],
		CurrentValue[$FrontEndSession, "InsertionCaretColor"] = $originalCaretColor
	];
	Clear[$originalCaretThickness, $appliedCaretThickness, $originalCaretColor, $appliedCaretColor];
)

(*====================================*)

processKeyDown[nb_NotebookObject, key_?StringQ] := Module[{
	currentMode = getState[nb, "Mode"],
	keySequence,
	result
},
	updateCaret[nb];
	If[key === "\[RawEscape]",
		If[MatchQ[getState[nb, "KeySequence"], {"v", ___} | {"d", Repeated["i"]}],
			SelectionMove[nb, After, Character]
		];
		setState[nb, "Mode" -> "Command"];
		setState[nb, "KeySequence" -> {}];
		Return[Null];
	];

	(* We're not in Command mode, so do no further processing. *)
	If[currentMode =!= "Command",
		Return[Null];
	];

	(*----------------------------------*)
	(* Process the key command sequence *)
	(*----------------------------------*)

	(* Construct the key command sequence by appending the latest key to
		any keys stored keys that were previously pressed but didn't match
		a key command pattern. *)
	keySequence = Replace[getState[nb, "KeySequence"], {
		Inherited -> {key},
		keys:{___?StringQ} :> Append[keys, key],
		other_ :> (
			(* FIXME: Generate a better error. *)
			Throw["ERROR: Unrecognized Vilfram KeySequence stored: ", InputForm[other]];
		)
	}];

	(* Clear before execution so a failed command cannot leave stale keys. *)
	setState[nb, "KeySequence" -> {}];
	result = Replace[
		keySequence,
		Append[
			$VilframCommands,
			_ :> Missing["NoCommandKeySequenceMatches"]
		]
	];

	If[First[keySequence] === "v" &&
		MemberQ[{Missing["NoCommandKeySequenceMatches"], $RetainKeyCommandSequence}, result],
		(* Visual mode needs only its prefix, not an ever-growing motion history. *)
		setState[nb, "KeySequence" -> {"v"}],
		If[result === $RetainKeyCommandSequence ||
			(result === Missing["NoCommandKeySequenceMatches"] && commandPrefixQ[keySequence]),
			setState[nb, "KeySequence" -> keySequence]
		]
	];
]

commandPrefixQ[keys_List] := AnyTrue[$VilframCommands,
	Replace[#, HoldPattern[RuleDelayed[pattern_List, _]] :>
		MatchQ[keys, Take[pattern, UpTo[Length[keys]]]]] &
];

(*====================================*)

modeLabel[nb_NotebookObject] := If[getState[nb, "Mode"] === "Insert", "INSERT",
	If[MatchQ[getState[nb, "KeySequence"], {"v", ___}], "VISUAL", "NORMAL"]
];

(* NvChad One Dark: St_NormalMode, St_InsertMode, St_VisualMode. *)
modeColor[nb_NotebookObject] := Switch[modeLabel[nb],
	"NORMAL", RGBColor["#81a1c1"],
	"INSERT", RGBColor["#c882e7"],
	"VISUAL", RGBColor["#a3b8ef"]
];

(* This private front end setting gives a thick bar, not a glyph-width Vim block. *)
updateCaret[nb_NotebookObject] := (
	If[NumberQ[$originalCaretThickness],
		With[{thickness = If[getState[nb, "Mode"] === "Insert", $originalCaretThickness, 6]},
			If[thickness =!= $appliedCaretThickness,
				CurrentValue[$FrontEndSession, "InsertionCaretThickness"] = thickness;
				$appliedCaretThickness = thickness
			]
		]
	];
	If[MatchQ[$originalCaretColor, _RGBColor | _GrayLevel | _Hue | _CMYKColor],
		With[{color = If[getState[nb, "Mode"] === "Insert", $originalCaretColor, modeColor[nb]]},
			If[color =!= $appliedCaretColor,
				CurrentValue[$FrontEndSession, "InsertionCaretColor"] = color;
				$appliedCaretColor = color
			]
		]
	];
);

pendingKeys[nb_NotebookObject] := StringJoin[getState[nb, "KeySequence"] /. "\r" -> "<Enter>"];

statusText[nb_NotebookObject] := With[{
	keys = pendingKeys[nb]
},
	modeLabel[nb] <> If[keys === "", "", "    " <> keys]
];

statusBar[nb_NotebookObject, width_?NumericQ] := With[{w = Max[160, width]},
	Framed[
		Row[{
			Framed[Pane[Style[modeLabel[nb], Bold, FontColor -> RGBColor["#1e222a"]],
				{100, 26}, Alignment -> Center],
				Background -> modeColor[nb], FrameStyle -> None, FrameMargins -> 0],
			Pane[Style[pendingKeys[nb], FontColor -> RGBColor["#abb2bf"]],
				{w - 112, 26}, Alignment -> {Right, Center}],
			Spacer[12]
		}, ""],
		Background -> RGBColor["#22262e"], FrameStyle -> None, FrameMargins -> 0,
		BaseStyle -> {FontFamily -> "Monospace", FontSize -> 11}
	]
];

ensureStatusBar[nb_NotebookObject] := Module[{cell},
	If[CurrentValue[nb, WindowFrame] =!= "Normal", Return[Null]];
	If[!AssociationQ[$statusCells], $statusCells = <||>];
	If[KeyExistsQ[$statusCells, nb], Return[Null]];
	cell = AttachCell[nb,
		Cell[BoxData[ToBoxes[Dynamic[Refresh[
			statusBar[nb, First[CurrentValue[nb, WindowSize]] - 24],
			UpdateInterval -> 0.2, TrackedSymbols :> {}
		]]]], "Text", CellMargins -> 0, CellFrame -> 0,
			ShowCellBracket -> False, Deployed -> True, Magnification -> 1],
		{Left, Bottom}, 0, {Left, Bottom}, RemovalConditions -> {"EvaluatorQuit"}
	];
	If[MatchQ[cell, _CellObject], AssociateTo[$statusCells, nb -> cell]];
];

enableStatusBar[] := (
	If[!ValueQ[$originalStatusOptions],
		$originalStatusOptions = Options[$FrontEndSession, {WindowStatusArea, WindowElements}]
	];
	SetOptions[$FrontEndSession, {
		WindowElements -> DeleteDuplicates[Append[CurrentValue[$FrontEndSession, WindowElements], "StatusArea"]],
		WindowStatusArea -> Dynamic[Refresh[
			With[{nb = EvaluationNotebook[]},
				If[MatchQ[nb, _NotebookObject],
					ensureStatusBar[nb];
					(* Background notebooks must not change the active caret. *)
					If[nb === InputNotebook[], updateCaret[nb]];
					If[AssociationQ[$statusCells] && KeyExistsQ[$statusCells, nb], "", statusText[nb]],
					""
				]
			], UpdateInterval -> 0.2, TrackedSymbols :> {}]]
	}];
)

disableStatusBar[] := (
	If[AssociationQ[$statusCells], Scan[Quiet[NotebookDelete[#]] &, Values[$statusCells]]];
	Clear[$statusCells];
	If[ValueQ[$originalStatusOptions],
		SetOptions[$FrontEndSession, $originalStatusOptions];
		Clear[$originalStatusOptions]
	];
);

(*====================================*)

(*
	Store Vilfram state on a per-notebook basis, but without storing it into
	the notebook itself.

	These use $FrontEndSession so that separate command state is maintained in
	different notebooks, but the overall state is cleared when the FrontEnd is
	restarted.
*)

getState[nb_NotebookObject, key_?StringQ] :=
	Replace[CurrentValue[
		$FrontEndSession,
		{PrivateFrontEndOptions, "InterfaceSettings", "ConnorGray/Vilfram", nb, key}
	], Inherited :> stateDefault[key]];

stateDefault["Mode"] := "Insert";
stateDefault["KeySequence"] := {};

setState[nb_NotebookObject, key_?StringQ -> value_] := (
	CurrentValue[
		$FrontEndSession,
		{PrivateFrontEndOptions, "InterfaceSettings", "ConnorGray/Vilfram", nb, key}
	] = value;
	If[key === "Mode", updateCaret[nb]];
);

(*====================================*)

End[];

EndPackage[];

