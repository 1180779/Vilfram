root = DirectoryName[DirectoryName[$InputFileName]];
Get[FileNameJoin[{root, "Kernel", "Vilfram.wl"}]];
report = TestReport[FileNameJoin[{root, "Tests", #}] & /@ {"Keyboard.wlt", "EscapeProbe.wlt"}];
Print["Passed: ", report["TestsSucceededCount"], "; failed: ", report["TestsFailedCount"]];
Scan[If[#["Outcome"] =!= "Success", Print[{#["TestID"], #["ActualOutput"]}]] &,
	Values[report["TestResults"]]];
Quit[If[report["TestsFailedCount"] === 0, 0, 1]];
