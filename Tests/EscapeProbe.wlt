probeFile = FileNameJoin[{DirectoryName[$InputFileName], "EscapeProbe.wl"}];
Internal`InheritedBlock[{CreateDocument, InputNotebook, CurrentValue},
	Unprotect[CreateDocument, InputNotebook, CurrentValue];
	Clear[CreateDocument, InputNotebook, CurrentValue];
	CreateDocument[___] := NotebookObject["escape-probe-test"];
	InputNotebook[] := NotebookObject["escape-probe-test"];
	CurrentValue[___] := Inherited;
	Options[probeSession] = {FrontEndEventActions -> {
		"KeyDown" :> originalCalls++, "MenuCommand" :> Null, PassEventsDown -> False
	}};
	Block[{$FrontEndSession = probeSession},
		originalOptions = Options[probeSession]; originalCalls = 0;
		Get[probeFile];
		VerificationTest[
			CurrentValue["EventKey"] = "\[RawEscape]";
			Replace["KeyDown", FrontEndEventActions /. Options[probeSession]];
			{ConnorGray`Vilfram`Private`modeLabel[InputNotebook[]], originalCalls,
				Length[ConnorGray`Vilfram`EscapeProbe`events]},
			{"NORMAL", 1, 1},
			TestID -> "probe handles a front-end Escape and preserves existing callback"
		];
		VerificationTest[
			InputNotebook[] := NotebookObject["other"];
			Replace["KeyDown", FrontEndEventActions /. Options[probeSession]];
			{originalCalls, Length[ConnorGray`Vilfram`EscapeProbe`events]}, {2, 1},
			TestID -> "probe does not record keys in other notebooks"
		];
		VerificationTest[
			ConnorGray`Vilfram`EscapeProbe`stop[];
			ConnorGray`Vilfram`EscapeProbe`stop[];
			Options[probeSession], originalOptions,
			TestID -> "stopping probe restores original handlers idempotently"
		];
	];
];
