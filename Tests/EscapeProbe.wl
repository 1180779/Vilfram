(* Run with Get in Mathematica. This is a temporary routing experiment, not an installed fix. *)
Get[FileNameJoin[{DirectoryName[DirectoryName[$InputFileName]], "Kernel", "Vilfram.wl"}]];

Begin["ConnorGray`Vilfram`EscapeProbe`"];

If[TrueQ[active], stop[]];
original = Options[$FrontEndSession, FrontEndEventActions];
previousActions = Replace[FrontEndEventActions /. original, Except[_List] -> {}];
events = {};
active = True;
stop[] := If[TrueQ[active],
	SetOptions[$FrontEndSession, original];
	active = False
];
record[layer_, event_] := Module[{key = CurrentValue["EventKey"]},
	If[Length[events] < 100,
		AppendTo[events, {layer, event, ToString[key, InputForm]}]
	];
	If[event === "EscapeKeyDown" || key === "\[RawEscape]",
		ConnorGray`Vilfram`Private`processKeyDown[notebook, "\[RawEscape]"]
	]
];
frontEvent[event_] := (
	If[TrueQ[active] && InputNotebook[] === notebook, record["Front end", event]];
	(* Preserve pre-existing callbacks while observing these events. *)
	Replace[event, previousActions];
);

notebook = CreateDocument[{
	Cell["Vilfram Escape routing test", "Title"],
	Cell["Type Integr below, wait for the completion popup, then press Escape once. Check whether the mode becomes NORMAL. Press Escape again as a control if needed. Copy the report, then close this window to restore the original front-end handlers.", "Text"],
	Cell[BoxData[""], "Input"],
	Cell[BoxData[ToBoxes[Column[{
		Dynamic[Row[{"Mode: ", ConnorGray`Vilfram`Private`modeLabel[notebook]}]],
		Dynamic[Column[Row[#, " | "] & /@ events]],
		Button["Copy report", CopyToClipboard[ToString[
			{$Version, "Mode" -> ConnorGray`Vilfram`Private`modeLabel[notebook], events},
			InputForm]], Method -> "Preemptive"],
		Button["Stop and restore handlers", stop[], Method -> "Preemptive"]
	}]]], "Output"]
}, WindowTitle -> "Vilfram Escape probe", Saveable -> False,
	NotebookEventActions -> {
		PassEventsDown -> True,
		"EscapeKeyDown" :> record["Notebook", "EscapeKeyDown"],
		"KeyDown" :> record["Notebook", "KeyDown"],
		"KeyUp" :> record["Notebook", "KeyUp"],
		"WindowClose" :> stop[]
	}
];
If[MatchQ[notebook, _NotebookObject],
	ConnorGray`Vilfram`Private`setState[notebook, "Mode" -> "Insert"];
	SetOptions[$FrontEndSession, FrontEndEventActions -> Join[{
		PassEventsDown -> True,
		"EscapeKeyDown" :> frontEvent["EscapeKeyDown"],
		"KeyDown" :> frontEvent["KeyDown"],
		"KeyUp" :> frontEvent["KeyUp"]
	}, previousActions]],
	stop[]
];

End[];
