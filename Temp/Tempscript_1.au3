;Tempscript_1.au3
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>
#include <ProgressConstants.au3>

$dlForm = GUICreate("dlForm",360,460,-1,-1,$WS_POPUP,-1)
$dlProgress = GUICtrlCreateProgress(20,40,320,20,-1,-1)
$labelSize = GUICtrlCreateLabel("",20,82,320,15,$SS_CENTER,-1)
GUICtrlSetBkColor(-1,"-2")
$labelPercent = GUICtrlCreateLabel("",165,64,50,15,-1,-1)
GUICtrlSetState(-1,BitOr($GUI_SHOW,$GUI_ENABLE,$GUI_ONTOP))
GUICtrlSetBkColor(-1,"-2")
GUICtrlCreateLabel("Downloading...",80,15,210,15,$SS_CENTER,-1)
GUICtrlSetBkColor(-1,"-2")
