#! /usr/bin/tixwish

# $Id: tkmedit.tcl,v 1.39 2003/04/21 20:09:06 kteich Exp $

source $env(MRI_DIR)/lib/tcl/tkm_common.tcl

foreach sSourceFileName { tkm_wrappers.tcl } {

    set lPath [list "." "../scripts" "$env(MRI_DIR)/lib/tcl"]
    set bFound 0

    foreach sPath $lPath {
	
	if { $bFound == 0 } {
	    set sFullFileName [ file join $sPath $sSourceFileName ]
	    set nErr [catch { source $sFullFileName } sResult]
	    if { $nErr == 0 } {
		dputs "Reading $sFullFileName"
		set bFound 1;
	    }
	}
    }
    
    if { $bFound == 0 } {
	dputs "Couldn't load $sSourceFileName: Not found in $lPath"
    }
}

# constants
set ksWindowName "TkMedit Tools"
set ksImageDir   "$env(MRI_DIR)/lib/images/"

# mri_tOrientation
set mri_tOrientation_Coronal    0
set mri_tOrientation_Horizontal 1
set mri_tOrientation_Sagittal   2

# DspA_tDisplayFlag
set glDisplayFlag { \
  flag_AuxVolume \
  flag_Anatomical \
  flag_Cursor \
  flag_MainSurface \
  flag_OriginalSurface \
  flag_CanonicalSurface \
  flag_InterpolateSurfaceVertices \
  flag_DisplaySurfaceVertices \
  flag_ControlPoints \
  flag_Selection \
  flag_FunctionalOverlay \
  flag_FunctionalColorScaleBar \
  flag_MaskToFunctionalOverlay \
  flag_HistogramPercentChange \
  flag_SegmentationVolumeOverlay \
  flag_AuxSegmentationVolumeOverlay \
  flag_SegLabelVolumeCount \
  flag_DTIOverlay \
  flag_VectorField \
  flag_FocusFrame \
  flag_UndoVolume \
  flag_Axes \
  flag_MaxIntProj \
  flag_HeadPoints }
set nFlagIndex 1
foreach flag $glDisplayFlag {
    set gnFlagIndex($flag) $nFlagIndex
    incr nFlagIndex 
}
set glActiveFlags {}

# DspA_tTool
set DspA_tTool_Navigate   0
set DspA_tTool_Select     1
set DspA_tTool_Edit       2
set DspA_tTool_EditParc   3
set DspA_tTool_CtrlPts    4

# DspA_tBrush
set DspA_tBrush_EditOne 0
set DspA_tBrush_EditTwo 1

set ksaBrushString(0) "Button 2"
set ksaBrushString(1) "Button 3"

# DspA_tBrushTarget
set DspA_tBrushTarget_Main    0
set DspA_tBrushTarget_MainAux 1

# DspA_tBrushShape
set DspA_tBrushShape_Circle 0
set DspA_tBrushShape_Square 1

# DspA_tMarker
set DspA_tMarker_Crosshair 0
set DspA_tMarker_Diamond   1

# view presets
set MWin_tLinkPolicy_None                  0
set MWin_tLinkPolicy_MultipleOrientations  1
set MWin_tLinkPolicy_Mosaic                2

set tViewPreset_Single   0
set tViewPreset_Multiple 1
set tViewPreset_Mosaic   2

set ksaViewPresetString(0) "single"
set ksaViewPresetString(1) "multiple"
set ksaViewPresetString(2) "mosaic"

# tkm_tVolumeType
set tkm_tVolumeType_Main 0
set tkm_tVolumeType_Aux  1

# tkm_tVolumeTarget
set tkm_tVolumeTarget_MainAna 0
set tkm_tVolumeTarget_AuxAna  1
set tkm_tVolumeTarget_MainSeg 2
set tkm_tVolumeTarget_AuxSeg  3

set ksaDisplayedVolumeString(0) "main"
set ksaDisplayedVolumeString(1) "aux"

# Surf_tVertexSet
set Surf_tVertexSet_Main      0
set Surf_tVertexSet_Original  1
set Surf_tVertexSet_Canonical 2

set ksaSurfaceVertexSetString(0) "Main Surface"
set ksaSurfaceVertexSetString(1) "Original Surface"
set ksaSurfaceVertexSetString(2) "Pial Surface"

# tFunctionalVolume
set tFunctionalVolume_Overlay    0
set tFunctionalVolume_TimeCourse 1

# mri_tCoordSpace
set mri_tCoordSpace_VolumeIdx 0
set mri_tCoordSpace_RAS       1
set mri_tCoordSpace_Talairach 2

set ksaLinkedCursorString(0) notlinked
set ksaLinkedCursorString(1) linked

# current location
set gOrientation 0
set gbLinkedCursor 1
set gbLinkedCursorString $ksaLinkedCursorString($gbLinkedCursor)
set gnVolX 0
set gnVolY 0
set gnVolZ 0
set gnVolSlice 0
set gnZoomLevel 0

# for tool setting and buttons
set gTool $DspA_tTool_Select

set gDisplayIntermediateResults 1

# parc edit brush
set gParcBrush(color) 0
set gParcBrush(3d) 0
set gParcBrush(fuzzy) 0
set gParcBrush(distance) 0
set gParcBrush(src) $tkm_tVolumeType_Main
set glParcEditColors {}

# for view preset setting and buttons
set gDisplayCols 1
set gDisplayRows 1
set gViewPreset $tViewPreset_Single
set gViewPresetString $ksaViewPresetString($gViewPreset)

# display flags
foreach flag $glDisplayFlag {
    set gbDisplayFlag($flag) 0
}

# tool bar frames
set gfwaToolBar(main)  ""
set gfwaToolBar(nav)   ""
set gfwaToolBar(recon) ""

# labels
set glLabel { \
  kLabel_Coords_Vol \
  kLabel_Coords_Vol_RAS \
  kLabel_Coords_Vol_Scanner \
  kLabel_Coords_Vol_MNI \
  kLabel_Coords_Vol_Tal \
  kLabel_Value_Vol \
  kLabel_Value_Aux \
  kLabel_Coords_Func \
  kLabel_Coords_Func_RAS \
  kLabel_Value_Func \
  kLabel_Label_SegLabel \
  kLabel_Label_AuxSegLabel \
  kLabel_Label_Head \
  kLabel_SurfaceDistance }
foreach label $glLabel {
    set gfwaLabel($label,cursor) ""
    set gfwaLabel($label,mouseover) ""
}

set gsaLabelContents(kLabel_Coords_Vol,name) "Volume index"
set gsaLabelContents(kLabel_Coords_Vol_RAS,name) "Volume RAS"
set gsaLabelContents(kLabel_Coords_Vol_Scanner,name) "Volume Scanner"
set gsaLabelContents(kLabel_Coords_Vol_MNI,name) "MNI Talairach"
set gsaLabelContents(kLabel_Coords_Vol_Tal,name) "Talairach"
set gsaLabelContents(kLabel_Coords_Func,name) "Functional index"
set gsaLabelContents(kLabel_Coords_Func_RAS,name) "Functional RAS"
set gsaLabelContents(kLabel_Value_Func,name) "Functional value"
set gsaLabelContents(kLabel_Label_SegLabel,name) "Sgmtn label"
set gsaLabelContents(kLabel_Label_AuxSegLabel,name) "Aux Sgmtn label"
set gsaLabelContents(kLabel_Label_Head,name) "Head Point"
set gsaLabelContents(kLabel_SurfaceDistance,name) "Surface Distance"

foreach label $glLabel {
    set gsaLabelContents($label,value,cursor) "none"
    set gsaLabelContents($label,value,mouseover) "none"
}  


# brush info
set gBrushInfo(target)   $DspA_tBrushTarget_Main
set gBrushInfo(radius)   1
set gBrushInfo(shape)    $DspA_tBrushShape_Circle
set gBrushInfo(3d)       true

foreach tool "$DspA_tBrush_EditOne $DspA_tBrush_EditTwo" {
    set gEditBrush($tool,new)  0
    set gEditBrush($tool,high) 0
    set gEditBrush($tool,low)  0
}

# cursor
set gCursor(color,red) 0
set gCursor(color,green) 0
set gCursor(color,blue) 0
set gCursor(shape) $DspA_tMarker_Crosshair

# surface
foreach surface "$Surf_tVertexSet_Main $Surf_tVertexSet_Original \
  $Surf_tVertexSet_Canonical" {
    set gSurface($surface,width) 0
    set gSurface($surface,color,red)   0
    set gSurface($surface,color,green) 0
    set gSurface($surface,color,blue)  0
}

# volume color scale
set gfVolumeColorScaleThresh($tkm_tVolumeType_Main) 0
set gfVolumeColorScaleSquash($tkm_tVolumeType_Main) 0
set gfVolumeColorScaleThresh($tkm_tVolumeType_Aux) 0
set gfVolumeColorScaleSquash($tkm_tVolumeType_Aux) 0

# initialize global vars
set gsSubjectDirectory "/"
set gsSegmentationColorTable ""
set gbVolumeDirty 0
set gbAuxVolumeDirty 0
set gbTalTransformPresent 0

# determine the list of shortcut dirs for the file dlog boxes
proc BuildShortcutDirsList {} {
    global glShortcutDirs gsSubjectDirectory env
    set glShortcutDirs {}
    if { [info exists env(SUBJECTS_DIR)] } {
	lappend glShortcutDirs $env(SUBJECTS_DIR)
    }
    if { [info exists gsSubjectDirectory] } {
	lappend glShortcutDirs $gsSubjectDirectory
    }
    if { [info exists env(FREESURFER_DATA)] } {
	lappend glShortcutDirs $env(FREESURFER_DATA)
    }
    if { [info exists env(MRI_DIR)] } {
	lappend glShortcutDirs $env(MRI_DIR)
    }
    if { [info exists env(PWD)] } {
	lappend glShortcutDirs $env(PWD)
    }
    if { [info exists env(FSDEV_TEST_DATA)] } {
	lappend glShortcutDirs $env(FSDEV_TEST_DATA)
    }
}
BuildShortcutDirsList

# ========================================================= UPDATES FROM MEDIT

proc UpdateLinkedCursorFlag { ibLinked } {
    global gbLinkedCursor 
    set gbLinkedCursor $ibLinked
}

proc UpdateVolumeCursor { iSet inX inY inZ } {
    global gnVolX gnVolY gnVolZ gsaLabelContents
    set gsaLabelContents(kLabel_Coords_Vol,value,$iSet) \
      "($inX  $inY  $inZ)"
    # set the volume coords
    set gnVolX $inX
    set gnVolY $inY
    set gnVolZ $inZ
}

proc UpdateVolumeSlice { inSlice } {
    global gnVolSlice 
    set gnVolSlice $inSlice
}

proc UpdateRASCursor { iSet ifX ifY ifZ } {
    global gsaLabelContents
    set gsaLabelContents(kLabel_Coords_Vol_RAS,value,$iSet) \
      "($ifX  $ifY  $ifZ)"
}

proc UpdateTalCursor { iSet ifX ifY ifZ } {
    global gsaLabelContents
    set gsaLabelContents(kLabel_Coords_Vol_Tal,value,$iSet) \
      "($ifX  $ifY  $ifZ)"
}

proc UpdateScannerCursor { iSet ifX ifY ifZ } {
    global gsaLabelContents
    set gsaLabelContents(kLabel_Coords_Vol_Scanner,value,$iSet) \
      "($ifX  $ifY  $ifZ)"
}

proc UpdateMNICursor { iSet ifX ifY ifZ } {
    global gsaLabelContents
    set gsaLabelContents(kLabel_Coords_Vol_MNI,value,$iSet) \
      "($ifX  $ifY  $ifZ)"
}

proc UpdateVolumeName { isName } {
    global gsaLabelContents
    set gsaLabelContents(kLabel_Value_Vol,name) $isName
}

proc UpdateVolumeValue { iSet inValue } {
    global gsaLabelContents
    set gsaLabelContents(kLabel_Value_Vol,value,$iSet) $inValue
}

proc UpdateAuxVolumeName { isName } {
    global gsaLabelContents
    set gsaLabelContents(kLabel_Value_Aux,name) $isName
}

proc UpdateAuxVolumeValue { iSet inValue } {
    global gsaLabelContents
    set gsaLabelContents(kLabel_Value_Aux,value,$iSet) $inValue
}

proc UpdateSegLabel { iSet isLabel } {
    global gsaLabelContents
    set gsaLabelContents(kLabel_Label_SegLabel,value,$iSet) $isLabel
}

proc UpdateAuxSegLabel { iSet isLabel } {
    global gsaLabelContents
    set gsaLabelContents(kLabel_Label_AuxSegLabel,value,$iSet) $isLabel
}

proc UpdateHeadPointLabel { iSet isLabel } {
    global gsaLabelContents
    set gsaLabelContents(kLabel_Label_Head,value,$iSet) $isLabel
}

proc UpdateFunctionalValue { iSet ifValue } {
    global gsaLabelContents
    set gsaLabelContents(kLabel_Value_Func,value,$iSet) $ifValue
}

proc UpdateFunctionalCoords { iSet inX inY inZ } {
    global gsaLabelContents
    set gsaLabelContents(kLabel_Coords_Func,value,$iSet) \
      "($inX  $inY  $inZ)"
}

proc UpdateFunctionalRASCoords { iSet inX inY inZ } {
    global gsaLabelContents
    set gsaLabelContents(kLabel_Coords_Func_RAS,value,$iSet) \
      "($inX  $inY  $inZ)"
}

proc UpdateSurfaceDistance { iSet ifDistance } {
    global gsaLabelContents
    set gsaLabelContents(kLabel_SurfaceDistance,value,$iSet) $ifDistance
}

proc UpdateZoomLevel { inLevel } { 
    global gnZoomLevel
    set gnZoomLevel $inLevel
}

proc UpdateOrientation { iOrientation } {
    global gOrientation
    set gOrientation $iOrientation
}

proc UpdateDisplayFlag { iFlagIndex ibValue } {
    global gbDisplayFlag glDisplayFlag gnFlagIndex
    global glActiveFlags
    foreach flag $glDisplayFlag {
  if { $gnFlagIndex($flag) == $iFlagIndex } {
      set gbDisplayFlag($flag) $ibValue

      # put or remove the flag from a list of active flags.
      # this will only work if anyone is listening for our flags,
      # i.e. a toolbar
      set nIndex [lsearch $glActiveFlags $flag]
      if { $ibValue == 0 } {
    if { $nIndex >= 0 } {
        catch {set glActiveFlags [lreplace $glActiveFlags $nIndex $nIndex]} sResult
    }
      } else {
    if { $nIndex == -1 } {
        catch {lappend glActiveFlags $flag} sResult
    }
      }
  }
    }
}

proc UpdateTool { iTool } {
    global gTool gToolString
    set gTool $iTool
}

proc UpdateBrushTarget { iTarget } {
    global gBrushInfo
    set gBrushInfo(target) $iTarget
}

proc UpdateBrushShape { inRadius iShape ib3D } {
    global gBrushInfo
    set gBrushInfo(radius) $inRadius
    set gBrushInfo(shape)  $iShape
    set gBrushInfo(3d)     $ib3D
}

proc UpdateBrushInfo { inBrush inLow inHigh inNewValue } {
    global gEditBrush
    set gEditBrush($inBrush,low)  $inLow
    set gEditBrush($inBrush,high) $inHigh
    set gEditBrush($inBrush,new)  $inNewValue
}

proc UpdateCursorColor { ifRed ifGreen ifBlue } {
    global gCursor
    set gCursor(color,red) $ifRed
    set gCursor(color,blue) $ifBlue
    set gCursor(color,green) $ifGreen
}

proc UpdateCursorShape { iShape } {
    global gCursor
    set gCursor(shape) $iShape
}

proc UpdateSurfaceLineWidth { iSurface inWidth } {
    global gSurface
    set gSurface($iSurface,width) $inWidth
}

proc UpdateSurfaceLineColor { iSurface ifRed ifGreen ifBlue } {
    global gSurface
    set gSurface($iSurface,color,red) $ifRed
    set gSurface($iSurface,color,green) $ifGreen
    set gSurface($iSurface,color,blue) $ifBlue
}

proc UpdateParcBrushInfo { inColor ib3D iSrc inFuzzy inDistance } {
    global gParcBrush

    set oldSelection  $gParcBrush(color)

    set gParcBrush(color)   $inColor
    set gParcBrush(3d)      $ib3D
    set gParcBrush(src)     $iSrc
    set gParcBrush(fuzzy)   $inFuzzy
    set gParcBrush(sitance) $inDistance

    # if the parc brush info dialog box is open, we want to select the
    # item with the index of the parc brush color. do all this in a catch
    # because if the dialog is not open, this will fail.
    catch { \
     set fwColor [.wwEditParcBrushInfoDlog.lfwColor subwidget frame].fwColor; \
     $fwColor subwidget listbox selection clear $oldSelection; \
     $fwColor subwidget listbox selection set $gParcBrush(color); \
     $fwColor subwidget listbox see $gParcBrush(color) \
    } sResult
}

proc UpdateSegmentationVolumeAlpha { ifAlpha } {
    global gfSegmentationVolumeAlpha
    set gfSegmentationVolumeAlpha $ifAlpha
}

proc UpdateVolumeColorScaleInfo { inVolume inThresh inSquash } {
    global gfVolumeColorScaleThresh gfVolumeColorScaleSquash 
    set gfVolumeColorScaleThresh($inVolume) $inThresh
    set gfVolumeColorScaleSquash($inVolume) $inSquash
}

proc UpdateDTIVolumeAlpha { ifAlpha } {
    global gfDTIVolumeAlpha
    set gfDTIVolumeAlpha $ifAlpha
}

proc UpdateTimerStatus { ibOn } {
    global gbTimerOn
    set gbTimerOn $ibOn
}

proc UpdateVolumeDirty { ibDirty } {
    global gbVolumeDirty
    set gbVolumeDirty $ibDirty
}

proc UpdateAuxVolumeDirty { ibDirty } {
    global gbAuxVolumeDirty
    set gbAuxVolumeDirty $ibDirty
}

proc UpdateSubjectDirectory { isSubjectDir } {
    global gsSubjectDirectory
    set gsSubjectDirectory $isSubjectDir
    BuildShortcutDirsList
}

proc UpdateSegmentationColorTable { isColorTable } {
    global gsSegmentationColorTable
    set gsSegmentationColorTable $isColorTable
}

proc SendDisplayFlagValue { iFlag } {
    global gnFlagIndex gbDisplayFlag
    SetDisplayFlag $gnFlagIndex($iFlag) $gbDisplayFlag($iFlag)
}

proc SendLinkedCursorValue { } {
    global gbLinkedCursor
    SetLinkedCursorFlag $gbLinkedCursor
}

proc SendSurfaceInformation { iSurface } {
    global gSurface
    SetSurfaceLineWidth $iSurface $gSurface($iSurface,width)
    SetSurfaceLineColor $iSurface $gSurface($iSurface,color,red) $gSurface($iSurface,color,green) $gSurface($iSurface,color,blue)
}

proc SendCursorConfiguration {} {
    global gCursor
    SetCursorColor $gCursor(color,red) $gCursor(color,green) $gCursor(color,blue)
    SetCursorShape $gCursor(shape)
}

# =============================================================== DIALOG BOXES

proc GetDefaultLocation { iType } {
    global gsaDnefaultLocation 
    global gsSubjectDirectory gsSegmentationColorTable env
    if { [info exists gsaDefaultLocation($iType)] == 0 } {
	switch $iType {
	    LoadVolume - LoadAuxVolume - SaveVolumeAs - SaveAuxVolumeAs -
	    LoadSegmentation - LoadAuxSegmentation - SaveSegmentationAs -
	    SaveAuxSegmentationAs - ExportChangedSegmentationVolume -
	    ExportAuxChangedSegmentationVolume {
		set gsaDefaultLocation($iType) $gsSubjectDirectory/mri
	    }
	    LoadVolumeDisplayTransform - LoadAuxVolumeDisplayTransform  { 
	     set gsaDefaultLocation($iType) $gsSubjectDirectory/mri/transforms
	    }
	    SaveLabelAs - LoadLabel - ImportSurfaceAnnotation { 
		set gsaDefaultLocation($iType) $gsSubjectDirectory/label
	    }
	    LoadMainSurface - LoadOriginalSurface - LoadPialSurface -
	    LoadCanonicalSurface - LoadMainAuxSurface - 
	    LoadOriginalAuxSurface - LoadPialAuxSurface -
	    WriteSurfaceValues { 
		set gsaDefaultLocation($iType) $gsSubjectDirectory/surf
	    }
	    LoadHeadPts_Points { 
		set gsaDefaultLocation($iType) [exec pwd] 
	    }
	    LoadHeadPts_Transform { 
		set gsaDefaultLocation($iType) [exec pwd] 
	    }
	    Segmentation_ColorTable { 
		if { $gsSegmentationColorTable != "" } {
		    set gsaDefaultLocation($iType) $gsSegmentationColorTable
		} elseif { [info exists env(CSURF_DIR)] } {
		    set gsaDefaultLocation($iType) $env(CSURF_DIR)/
		} else {
		    set gsaDefaultLocation($iType) $gsSubjectDirectory 
		}
	    }
	    LoadFunctional-overlay - LoadFunctional-timecourse {
		set gsaDefaultLocation($iType) $gsSubjectDirectory/fmri
	    }
	    LoadGCA_Volume - SaveGCA {
		if { [info exists env(CSURF_DIR)] } {
		    set gsaDefaultLocation($iType) $env(CSURF_DIR)/average
		} else {
		    set gsaDefaultLocation($iType) $gsSubjectDirectory
		}
	    }
	    LoadGCA_Transform {
		set gsaDefaultLocation($iType) \
		    $gsSubjectDirectory/mri/transforms
	    }
	    default { 
		set gsaDefaultLocation($iType) $gsSubjectDirectory 
	    }
	}
    }
    return $gsaDefaultLocation($iType)
}
proc SetDefaultLocation { iType isValue } {
    global gsaDefaultLocation
    if { [string range $isValue 0 0] == "/" } {
	set gsaDefaultLocation($iType) $isValue
    }
}
set tDlogSpecs(LoadVolume) [list \
  -title "Load Volume" \
  -prompt1 "Load COR Volume:" \
  -note1 "The volume file (or COR-.info for COR volumes)" \
  -entry1 [list GetDefaultLocation LoadVolume] \
  -default1 [list GetDefaultLocation LoadVolume] \
  -presets1 $glShortcutDirs \
  -okCmd {LoadVolume %s1; SetDefaultLocation LoadVolume %s1} ]
set tDlogSpecs(LoadAuxVolume) [list \
  -title "Load Aux Volume" \
  -prompt1 "Load COR Volume:" \
  -note1 "The volume file (or COR-.info for COR volumes)" \
  -entry1 [list GetDefaultLocation LoadAuxVolume] \
  -default1 [list GetDefaultLocation LoadAuxVolume] \
  -presets1 $glShortcutDirs \
  -okCmd {LoadAuxVolume %s1; SetDefaultLocation LoadAuxVolume %s1} ]
set tDlogSpecs(LoadGCA) [list \
  -title "Load GCA" \
  -prompt1 "Load Classifier Array:" \
  -note1 "The GCA file (*.gca)" \
  -entry1 [list GetDefaultLocation LoadGCA_Volume] \
  -default1 [list GetDefaultLocation LoadGCA_Volume] \
  -presets1 $glShortcutDirs \
  -prompt2 "Load Transform:" \
  -note2 "The file containing the transform to the atlas space" \
  -entry2 [list GetDefaultLocation LoadGCA_Transform] \
  -default2 [list GetDefaultLocation LoadGCA_Transform] \
  -presets2 $glShortcutDirs \
  -okCmd {LoadGCA %s1 %s2; \
  SetDefaultLocation LoadGCA_Volume %s1; \
  SetDefaultLocation LoadGCA_Transform %s2} ]
set tDlogSpecs(SaveGCA) [list \
  -title "Save GCA" \
  -prompt1 "Save Classifier Array:" \
  -note1 "The GCA file (*.gca)" \
  -entry1 [list GetDefaultLocation SaveGCA] \
  -default1 [list GetDefaultLocation SaveGCA] \
  -presets1 $glShortcutDirs \
  -okCmd {SaveGCA %s1; SetDefaultLocation SaveGCA %s1} ]
set tDlogSpecs(SaveVolumeAs) [list \
  -title "Save Main Volume As" \
  -prompt1 "Save COR Volume:" \
  -type1 dir \
  -note1 "The directory in which to write the COR volume files" \
  -entry1 [list GetDefaultLocation SaveVolumeAs] \
  -default1 [list GetDefaultLocation SaveVolumeAs] \
  -presets1 $glShortcutDirs \
  -okCmd {SaveVolumeAs 0 %s1; SetDefaultLocation SaveVolumeAs %s1} ]
set tDlogSpecs(SaveAuxVolumeAs) [list \
  -title "Save Aux Volume As" \
  -prompt1 "Save COR Volume:" \
  -type1 dir \
  -note1 "The directory in which to write the COR volume files" \
  -entry1 [list GetDefaultLocation SaveVolumeAs] \
  -default1 [list GetDefaultLocation SaveVolumeAs] \
  -presets1 $glShortcutDirs \
  -okCmd {SaveVolumeAs 1 %s1; SetDefaultLocation SaveVolumeAs %s1} ]
set tDlogSpecs(LoadVolumeDisplayTransform) [list \
  -title "Load Transform" \
  -prompt1 "Load Transform File:" \
  -note1 "The .lta or .xfm file containing the transform to load" \
  -entry1 [list GetDefaultLocation LoadVolumeDisplayTransform] \
  -default1 [list GetDefaultLocation LoadVolumeDisplayTransform] \
  -presets1 $glShortcutDirs \
  -okCmd {LoadVolumeDisplayTransform 0 %s1; \
  SetDefaultLocation  LoadVolumeDisplayTransform %s1} ]
set tDlogSpecs(LoadAuxVolumeDisplayTransform) [list \
  -title "Load Aux Transform" \
  -prompt1 "Load Transform File:" \
  -note1 "The .lta or .xfm file containing the transform to load" \
  -entry1 [list GetDefaultLocation LoadAuxVolumeDisplayTransform] \
  -default1 [list GetDefaultLocation LoadAuxVolumeDisplayTransform] \
  -presets1 $glShortcutDirs \
  -okCmd {LoadVolumeDisplayTransform 1 %s1; \
  SetDefaultLocation LoadAuxVolumeDisplayTransform %s1} ]
set tDlogSpecs(SaveLabelAs) [list \
  -title "Save Label As" \
  -prompt1 "Save Label:" \
  -note1 "The file name of the label to save" \
  -entry1 [list GetDefaultLocation SaveLabelAs] \
  -default1 [list GetDefaultLocation SaveLabelAs] \
  -presets1 $glShortcutDirs \
  -okCmd {SaveLabel %s1; SetDefaultLocation SaveLabelAs %s1} ]
set tDlogSpecs(LoadLabel) [list \
  -title "Load Label" \
  -prompt1 "Load Label:" \
  -note1 "The file name of the label to load" \
  -entry1 [list GetDefaultLocation LoadLabel] \
  -default1 [list GetDefaultLocation LoadLabel] \
  -presets1 $glShortcutDirs \
  -okCmd {LoadLabel %s1; SetDefaultLocation LoadLabel %s1} ]
set tDlogSpecs(LoadMainSurface) [list \
  -title "Load Main Surface" \
  -prompt1 "Load Surface:" \
  -note1 "The file name of the surface to load" \
  -entry1 [list GetDefaultLocation LoadMainSurface] \
  -default1 [list GetDefaultLocation LoadMainSurface] \
  -presets1 $glShortcutDirs \
  -okCmd {LoadMainSurface %s1; SetDefaultLocation LoadMainSurface %s1} ]
set tDlogSpecs(LoadOriginalSurface) [list \
  -title "Load Original Surface" \
  -prompt1 "Load Surface:" \
  -note1 "The file name of the surface to load" \
  -entry1 [list GetDefaultLocation LoadOriginalSurface] \
  -default1 [list GetDefaultLocation LoadOriginalSurface] \
  -presets1 $glShortcutDirs \
  -okCmd {LoadOriginalSurface %s1; \
  SetDefaultLocation LoadOriginalSurface %s1} ]
set tDlogSpecs(LoadPialSurface) [list \
  -title "Load Pial Surface" \
  -prompt1 "Load Surface:" \
  -note1 "The file name of the surface to load" \
  -entry1 [list GetDefaultLocation LoadPialSurface] \
  -default1 [list GetDefaultLocation LoadPialSurface] \
  -presets1 $glShortcutDirs \
  -okCmd {LoadCanonicalSurface %s1; \
  SetDefaultLocation LoadPialSurface %s1} ]
set tDlogSpecs(LoadMainAuxSurface) [list \
  -title "Load Aux Main Surface" \
  -prompt1 "Load Surface:" \
  -note1 "The file name of the surface to load" \
  -entry1 [list GetDefaultLocation LoadMainAuxSurface] \
  -default1 [list GetDefaultLocation LoadMainAuxSurface] \
  -presets1 $glShortcutDirs \
  -okCmd {LoadMainSurface 1 %s1; SetDefaultLocation LoadMainAuxSurface %s1} ]
set tDlogSpecs(LoadOriginalAuxSurface) [list \
  -title "Load Aux Original Surface" \
  -prompt1 "Load Surface:" \
  -note1 "The file name of the surface to load" \
  -entry1 [list GetDefaultLocation LoadOriginalAuxSurface] \
  -default1 [list GetDefaultLocation LoadOriginalAuxSurface] \
  -presets1 $glShortcutDirs \
  -okCmd {LoadOriginalSurface 1 %s1; \
  SetDefaultLocation LoadOriginalAuxSurface %s1} ]
set tDlogSpecs(LoadPialAuxSurface) [list \
  -title "Load Aux Pial Surface" \
  -prompt1 "Load Surface:" \
  -note1 "The file name of the surface to load" \
  -entry1 [list GetDefaultLocation LoadPialAuxSurface] \
  -default1 [list GetDefaultLocation LoadPialAuxSurface] \
  -presets1 $glShortcutDirs \
  -okCmd {LoadCanonicalSurface 1 %s1; \
  SetDefaultLocation LoadPialAuxSurface %s1} ]
set tDlogSpecs(WriteSurfaceValues) [list \
  -title "Write Surface Values" \
  -prompt1 "Save Values As:" \
  -note1 "The file name of the values file to write" \
  -entry1 [list GetDefaultLocation WriteSurfaceValues] \
  -default1 [list GetDefaultLocation WriteSurfaceValues] \
  -presets1 $glShortcutDirs \
  -okCmd {WriteSurfaceValues %s1; \
  SetDefaultLocation WriteSurfaceValues %s1} ]
set tDlogSpecs(ImportSurfaceAnnotation) [list \
  -title "Import Surface Annotation" \
  -prompt1 "Load Annotation File:" \
  -note1 "A .annot file containing the annotation data" \
  -entry1 [list GetDefaultLocation ImportSurfaceAnnotation] \
  -default1 [list GetDefaultLocation ImportSurfaceAnnotation] \
  -presets1 $glShortcutDirs \
  -prompt2 "Load Color Table:" \
  -note2 "The file containing the colors and ROI definitions" \
  -entry2 [list GetDefaultLocation Segmentation_ColorTable] \
  -default2 [list GetDefaultLocation Segmentation_ColorTable] \
  -presets2 $glShortcutDirs \
  -okCmd {ImportSurfaceAnnotationToSegmentation 0 %s1 %s2; \
  SetDefaultLocation ImportSegmentation_Volume %s1; \
  SetDefaultLocation Segmentation_ColorTable %s2} ]
set tDlogSpecs(PrintTimeCourse) [list \
  -title "Print Time Course" \
  -prompt1 "Save Summary As:" \
  -note1 "The file name of the text summary to create" \
  -entry1 [list GetDefaultLocation PrintTimeCourse] \
  -default1 [list GetDefaultLocation PrintTimeCourse] \
  -presets1 $glShortcutDirs \
  -okCmd {TimeCourse_PrintSelectionRangeToFile %s1; \
  SetDefaultLocation PrintTimeCourse %s1} ]
set tDlogSpecs(SaveTimeCourseToPS) [list \
  -title "Save Time Course" \
  -prompt1 "Save Time Course As:" \
  -note1 "The file name of the PostScript file to create" \
  -entry1 [list GetDefaultLocation SaveTimeCourseToPS] \
  -default1 [list GetDefaultLocation SaveTimeCourseToPS] \
  -presets1 $glShortcutDirs \
  -okCmd {TimeCourse_SaveGraphToPS %s1; \
  SetDefaultLocation SaveTimeCourseToPS %s1} ]
set tDlogSpecs(NewSegmentation) [list \
  -title "New Segmentation" \
  -prompt1 "Load Color Table:" \
  -note1 "The file containing the colors and ROI definitions" \
  -entry1 [list GetDefaultLocation Segmentation_ColorTable] \
  -default1 [list GetDefaultLocation Segmentation_ColorTable] \
  -presets1 $glShortcutDirs \
  -okCmd {NewSegmentationVolume 0 0 %s1; \
  SetDefaultLocation Segmentation_ColorTable %s1} ]
set tDlogSpecs(NewAuxSegmentation) [list \
  -title "New Aux Segmentation" \
  -prompt1 "Load Color Table:" \
  -note1 "The file containing the colors and ROI definitions" \
  -entry1 [list GetDefaultLocation Segmentation_ColorTable] \
  -default1 [list GetDefaultLocation Segmentation_ColorTable] \
  -presets1 $glShortcutDirs \
  -okCmd {NewSegmentationVolume 1 1 %s1; \
  SetDefaultLocation Segmentation_ColorTable %s1} ]
set tDlogSpecs(LoadSegmentation) [list \
  -title "Load Segmentation" \
  -prompt1 "Load COR Volume:" \
  -note1 "The volume file (or COR-.info for COR volumes)" \
  -entry1 [list GetDefaultLocation LoadSegmentation] \
  -default1 [list GetDefaultLocation LoadSegmentation] \
  -presets1 $glShortcutDirs \
  -prompt2 "Load Color Table:" \
  -note2 "The file containing the colors and ROI definitions" \
  -entry2 [list GetDefaultLocation Segmentation_ColorTable] \
  -default2 [list GetDefaultLocation Segmentation_ColorTable] \
  -presets2 $glShortcutDirs \
  -okCmd {LoadSegmentationVolume 0 %s1 %s2; \
  SetDefaultLocation ImportSegmentation_Volume %s1; \
  SetDefaultLocation Segmentation_ColorTable %s2} ]
set tDlogSpecs(LoadAuxSegmentation) [list \
  -title "Load Aux Segmentation" \
  -prompt1 "Load COR Volume:" \
  -note1 "The volume file (or COR-.info for COR volumes)" \
  -entry1 [list GetDefaultLocation LoadAuxSegmentation] \
  -default1 [list GetDefaultLocation LoadAuxSegmentation] \
  -presets1 $glShortcutDirs \
  -prompt2 "Load Color Table:" \
  -note2 "The file containing the colors and ROI definitions" \
  -entry2 [list GetDefaultLocation Segmentation_ColorTable] \
  -default2 [list GetDefaultLocation Segmentation_ColorTable] \
  -presets2 $glShortcutDirs \
  -okCmd {LoadSegmentationVolume 1 %s1 %s2; \
  SetDefaultLocation ImportSegmentation_Volume %s1; \
  SetDefaultLocation Segmentation_ColorTable %s2} ]
set tDlogSpecs(SaveSegmentationAs) [list \
  -title "Save Segmenation As" \
  -prompt1 "Save COR Volume:" \
  -type1 dir \
  -note1 "The directory in which to write the COR volume files" \
  -entry1 [list GetDefaultLocation SaveSegmentationAs] \
  -default1 [list GetDefaultLocation SaveSegmentationAs] \
  -presets1 $glShortcutDirs \
  -okCmd {SaveSegmentation 0 %s1; \
  SetDefaultLocation SaveSegmentationAs %s1} ]
set tDlogSpecs(SaveAuxSegmentationAs) [list \
  -title "Save Aux Segmenation As" \
  -prompt1 "Save COR Volume:" \
  -type1 dir \
  -note1 "The directory in which to write the COR volume files" \
  -entry1 [list GetDefaultLocation SaveSegmentationAs] \
  -default1 [list GetDefaultLocation SaveSegmentationAs] \
  -presets1 $glShortcutDirs \
  -okCmd {SaveSegmentation 1 %s1; \
  SetDefaultLocation SaveSegmentationAs %s1} ]
set tDlogSpecs(ExportChangedSegmentationVolume) [list \
  -title "Save Changed Segmenation Values As" \
  -prompt1 "Save COR Volume:" \
  -type1 dir \
  -note1 "The directory in which to write the COR volume files" \
  -entry1 [list GetDefaultLocation SaveSegmentationAs] \
  -default1 [list GetDefaultLocation SaveSegmentationAs] \
  -presets1 $glShortcutDirs \
  -okCmd {ExportChangedSegmentationVolume 0 %s1; \
  SetDefaultLocation ExportChangedSegmentationVolume %s1} ]
set tDlogSpecs(ExportAuxChangedSegmentationVolume) [list \
  -title "Save Aux Changed Segmenation Values As" \
  -prompt1 "Save COR Volume:" \
  -type1 dir \
  -note1 "The directory in which to write the COR volume files" \
  -entry1 [list GetDefaultLocation SaveSegmentationAs] \
  -default1 [list GetDefaultLocation SaveSegmentationAs] \
  -presets1 $glShortcutDirs \
  -okCmd {ExportChangedSegmentationVolume 1 %s1; \
  SetDefaultLocation ExportChangedSegmentationVolume %s1} ]
set tDlogSpecs(LoadHeadPts) [list \
  -title "Load Head Points" \
  -prompt1 "Load Head Points:" \
  -note1 "The file name of the .hpts head points file" \
  -entry1 [list GetDefaultLocation LoadHeadPts_Points] \
  -default1 [list GetDefaultLocation LoadHeadPts_Points] \
  -presets1 $glShortcutDirs \
  -prompt2 "Load Transform File:" \
  -note2 "The file name of the .trans transform file" \
  -entry2 [list GetDefaultLocation LoadHeadPts_Transform] \
  -default2 [list GetDefaultLocation LoadHeadPts_Transform] \
  -presets2 $glShortcutDirs \
  -okCmd {LoadHeadPts %s1 %s2; \
  SetDefaultLocation LoadHeadPts_Points %s1; \
  SetDefaultLocation LoadHeadPts_Transform %s2} ]
set tDlogSpecs(SaveRGB) [list \
  -title "Save RGB" \
  -prompt1 "Save RGB File:" \
  -note1 "The file name of the RGB picture to create" \
  -entry1 [list GetDefaultLocation SaveRGB] \
  -default1 [list GetDefaultLocation SaveRGB] \
  -presets1 $glShortcutDirs \
  -okCmd {SaveRGB %s1; SetDefaultLocation SaveRGB %s1} ]

proc DoFileDlog { which } {
    global tDlogSpecs
    tkm_DoFileDlog $tDlogSpecs($which)
}

proc FindVertex { inVertex } {

    global Surf_tVertexSet_Main Surf_tVertexSet_Original
    global Surf_tVertexSet_Canonical
    global gFindingSurface

    if { $Surf_tVertexSet_Main   == $gFindingSurface } {
  GotoMainVertex $inVertex
    }
    if { $Surf_tVertexSet_Original  == $gFindingSurface } {
  GotoOriginalVertex $inVertex
    }
    if { $Surf_tVertexSet_Canonical == $gFindingSurface } {
  GotoCanonicalVertex $inVertex
    }
}

proc DoLoadFunctionalDlog { isType } {

    global gDialog gaLinkedVars
    global gaScalarValueID gsaLabelContents
    global glShortcutDirs
    global gfnFunctional gsFuncLoadType

    set wwDialog .wwLoadFunctionalDlog

    set knWidth 400

    set gsFuncLoadType $isType

    set sTitle ""
    set sPrompt ""
    if { $gsFuncLoadType == "overlay" } {
	set sTitle "Load Overlay"
	set sPrompt "Load Overlay:"
    } elseif { $gsFuncLoadType == "timecourse" } {
	set sTitle "Load Time Course"
	set sPrompt "Load Time Course:"
    }
    
    # try to create the dlog...
    if { [Dialog_Create $wwDialog $sTitle {-borderwidth 10}] } {
	
	set fwFile             $wwDialog.fwFile
	set fwFileNote         $wwDialog.fwFileNote
	set fwButtons          $wwDialog.fwButtons
	
	set gfnFunctional [GetDefaultLocation LoadFunctional-$gsFuncLoadType]
	tkm_MakeFileSelector $fwFile $sPrompt gfnFunctional \
	    [list GetDefaultLocation LoadFunctional-$gsFuncLoadType] \
	    $glShortcutDirs
	
	tkm_MakeSmallLabel $fwFileNote \
	    "One of the binary volume files (.bfloat/.bshort/.hdr)" 400
	
	# buttons.
        tkm_MakeCancelOKButtons $fwButtons $wwDialog \
	    {set fnFunctional $gfnFunctional; 
	      SetDefaultLocation LoadFunctional-$gsFuncLoadType $gfnFunctional;
		DoLoadFunctional $gsFuncLoadType $gfnFunctional }
	
	pack $fwFile $fwFileNote $fwButtons \
	    -side top       \
	    -expand yes     \
	    -fill x         \
	    -padx 5         \
	    -pady 5
	
	# after the next idle, the window will be mapped. set the min
	# width to our width and the min height to the mapped height.
	after idle [format {
	    update idletasks
	    wm minsize %s %d [winfo reqheight %s]
	    wm geometry %s =%dx[winfo reqheight %s]
	} $wwDialog $knWidth $wwDialog $wwDialog $knWidth $wwDialog] 
    }
}

proc DoLoadFunctional { isType ifnVolume } {

    # if ends in bfloat, pass to DoSpecifyStemAndRegistration
    set sExtension [file extension $ifnVolume]
    if { $sExtension == ".bfloat" || 
	 $sExtension == ".bshort" ||
	 $sExtension == ".hdr" } {
	DoSpecifyStemAndRegistration $isType $ifnVolume
    } 
}

proc DoSpecifyStemAndRegistration { isType ifnVolume } {

    global gfnFuncPath gsFuncStem gfnFuncRegistration gsFuncLoadType
    global gDialog gaLinkedVars
    global glShortcutDirs
    
    set wwDialog .wwDoSpecifyStemAndRegistration

    set knWidth 400
    set gfnFuncPath [file dirname $ifnVolume]
    set gsFuncStem [lindex [split [file rootname [file tail $ifnVolume]] _] 0]

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Specify Registration" {-borderwidth 10}] } {

	set fwStem             $wwDialog.fwStem
	set fwStemNote         $wwDialog.fwStemNote
	set fwReg              $wwDialog.fwReg
	set fwRegNote          $wwDialog.fwRegNote
	set fwButtons          $wwDialog.fwButtons
	
	tkm_MakeEntry $fwStem "Stem:" gsFuncStem
	
	tkm_MakeSmallLabel $fwStemNote "The stem of the volume" 400
	
	set gfnFuncRegistration [file join $gfnFuncPath register.dat]
	SetDefaultLocation SpecifyRegistration $gfnFuncRegistration
	tkm_MakeFileSelector $fwReg "Registration file:" gfnFuncRegistration \
	    [list GetDefaultLocation SpecifyRegistration] \
	    $glShortcutDirs
	
	tkm_MakeSmallLabel $fwRegNote \
	    "The file name of the registration file to load" 
	
	# buttons.
        tkm_MakeCancelOKButtons $fwButtons $wwDialog \
	    { 
		SetDefaultLocation SpecifyRegistration $gfnFuncRegistration;
		if { $gsFuncLoadType == "overlay" } {
		    LoadFunctionalOverlay \
			$gfnFuncPath $gsFuncStem $gfnFuncRegistration
		} elseif { $gsFuncLoadType == "timecourse" } {
		    LoadFunctionalTimeCourse \
			$gfnFuncPath $gsFuncStem $gfnFuncRegistration
		}
	    }
	
	pack $fwStem $fwStemNote $fwReg $fwRegNote $fwButtons \
	    -side top       \
	    -expand yes     \
	    -fill x         \
	    -padx 5         \
	    -pady 5
	
	# after the next idle, the window will be mapped. set the min
	# width to our width and the min height to the mapped height.
	after idle [format {
	    update idletasks
	    wm minsize %s %d [winfo reqheight %s]
	} $wwDialog $knWidth $wwDialog] 
    }
}

proc DoLoadDTIDlog {} {
    global gDialog glShortcutDirs
    global nColorX nColorY nColorZ

    set wwDialog .wwLoadDTIDlog

    set knWidth 400

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Load DTI Volume" {-borderwidth 10}] } {

	set fwEVFile           $wwDialog.fwEVFile
	set fwEVFileNote       $wwDialog.fwEVFileNote
	set fwFAFile           $wwDialog.fwFAFile
	set fwFAFileNote       $wwDialog.fwFAFileNote
	set lwColor            $wwDialog.lwColor
	set fwColorTable       $wwDialog.fwColorTable
	set fwButtons          $wwDialog.fwButtons
	
	set sEVFileName ""
	tkm_MakeFileSelector $fwEVFile "Load DTI Vector Volume:" sEVFileName \
	    [list GetDefaultLocation LoadDTIVolume] \
	    $glShortcutDirs

	tkm_MakeSmallLabel $fwEVFileNote "The DTI vector volume to load" 400
	
	set sFAFileName ""
	tkm_MakeFileSelector $fwFAFile "Load DTI FA Volume:" sFAFileName \
	    [list GetDefaultLocation LoadDTIVolume] \
	    $glShortcutDirs

	tkm_MakeSmallLabel $fwFAFileNote "The DTI FA volume to load" 400
	
	tkm_MakeNormalLabel $lwColor "Color orientation:"

	frame $fwColorTable

	set nRow 1
	foreach color {Red Green Blue} {
	    tkm_MakeSmallLabel $fwColorTable.lw$color "$color"
	    grid $fwColorTable.lw$color -column 0 -row $nRow
	    incr nRow
	}
	set nColumn 1
	foreach axis {X Y Z} {
	    tkm_MakeSmallLabel $fwColorTable.lw$axis "$axis"
	    grid $fwColorTable.lw$axis -column $nColumn -row 0

	    set nRow 1
	    foreach nColor {0 1 2} {
		radiobutton $fwColorTable.rb$axis-$nColor \
		    -variable nColor$axis -value $nColor
		grid $fwColorTable.rb$axis-$nColor \
		    -column $nColumn -row $nRow
		incr nRow
	    }
	    incr nColumn
	}
        set nColorX 0
        set nColorY 1
        set nColorZ 2
	

	# ok and cancel buttons.
	tkm_MakeCancelOKButtons $fwButtons $wwDialog \
	    { LoadDTIVolume $sEVFileName $sFAFileName $nColorX $nColorY $nColorZ;
	    SetDefaultLocation LoadDTIVolume $sEVFileName }
	
	pack $fwEVFile $fwEVFileNote $fwFAFile $fwFAFileNote \
	    $lwColor $fwColorTable $fwButtons \
	    -side top       \
	    -expand yes     \
	    -fill x         \
	    -padx 5         \
	    -pady 5

	# after the next idle, the window will be mapped. set the min
	# width to our width and the min height to the mapped height.
	after idle [format {
	    update idletasks
	    wm minsize %s %d [winfo reqheight %s]
	    wm geometry %s =%dx[winfo reqheight %s]
	} $wwDialog $knWidth $wwDialog $wwDialog $knWidth $wwDialog] 
    }
}

proc DoSaveDlog {} {

    global gDialog

    set wwDialog .wwSaveDlog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Save Main Volume" {-borderwidth 10}] } {

	set fwMain    $wwDialog.fwMain
	set fwButtons $wwDialog.fwButtons
	
	# prompt
	tkm_MakeNormalLabel $fwMain\
	    "Are you sure you wish to save changes to the main volume?"
	
	# ok and cancel buttons.
	tkm_MakeCancelOKButtons $fwButtons $wwDialog \
	    { SaveVolume 0 }
	
	pack $fwMain $fwButtons \
	    -side top       \
	    -expand yes     \
	    -fill x         \
	    -padx 5         \
	    -pady 5
    }
}

proc DoAuxSaveDlog {} {

    global gDialog

    set wwDialog .wwAuxSaveDlog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Save Aux Volume" {-borderwidth 10}] } {

	set fwMain    $wwDialog.fwMain
	set fwButtons $wwDialog.fwButtons
	
	# prompt
	tkm_MakeNormalLabel $fwMain\
	    "Are you sure you wish to save changes to the aux volume?"
	
	# ok and cancel buttons.
	tkm_MakeCancelOKButtons $fwButtons $wwDialog \
	    { SaveVolume 1 }
	
	pack $fwMain $fwButtons \
	    -side top       \
	    -expand yes     \
	    -fill x         \
	    -padx 5         \
	    -pady 5
    }
}

proc DoAskSaveChangesDlog {} {

    global gDialog

    set wwDialog .wwSaveDlog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Save Changes" {-borderwidth 10}] } {

	set fwMain    $wwDialog.fwMain
	set fwButtons $wwDialog.fwButtons
	
	# prompt
	tkm_MakeNormalLabel $fwMain\
	    "Do you wish to save changes to the main volume?"
	
	# ok and cancel buttons.
	tkm_MakeButtons $fwButtons { \
	    {text "Yes" {SaveVolume 0; QuitMedit} } \
   	    {text "No" { QuitMedit }} }
	
	pack $fwMain $fwButtons \
	    -side top       \
	    -expand yes     \
	    -fill x         \
	    -padx 5         \
	    -pady 5
    }
}


proc DoBrushInfoDlog {} {

    global gDialog
    global DspA_tBrushShape_Square DspA_tBrushShape_Circle
    global DspA_tBrushTarget_Main DspA_tBrushTarget_MainAux
    global gBrushInfo

    set wwDialog .wwBrushInfoDlog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Brush Info" {-borderwidth 10}] } {
  
	set fwTop                $wwDialog.fwTop
	set fwShape              $fwTop.fwShape
	set fwButtons            $wwDialog.fwButtons
	
	frame $fwTop
	
	set fwRadiusScale        $fwTop.fwRadiusScale
	set fwTargetLabel        $fwTop.fwTargetLabel
	set fwMain               $fwTop.fwMain
	set fwMainAux            $fwTop.fwMainAux
	set fwShapeLabel         $fwTop.fwShapeLabel
	set fwCircle             $fwTop.fwCircle
	set fwSquare             $fwTop.fwSquare
	set fw3DCheckbox         $fwTop.fw3DCheckbox
	
 	# target radio buttons
	tkm_MakeNormalLabel $fwTargetLabel "Target"
	tkm_MakeRadioButton $fwMain "Main volume only" \
	    gBrushInfo(target) $DspA_tBrushTarget_Main \
	    "SetBrushConfiguration"
	tkm_MakeRadioButton $fwMainAux "Main and aux volume" \
	    gBrushInfo(target) $DspA_tBrushTarget_MainAux \
	    "SetBrushConfiguration"

	# radius
	tkm_MakeSliders $fwRadiusScale { \
	       { {"Radius"} gBrushInfo(radius) 1 20 100 "" 1 } }
	
 	# shape radio buttons
	tkm_MakeNormalLabel $fwShapeLabel "Shape"
	tkm_MakeRadioButton $fwCircle "Circle" \
	    gBrushInfo(shape) $DspA_tBrushShape_Circle \
	    "SetBrushConfiguration"
	tkm_MakeRadioButton $fwSquare "Square" \
	    gBrushInfo(shape) $DspA_tBrushShape_Square \
	    "SetBrushConfiguration"
	
	# 3d checkbox
	tkm_MakeCheckboxes $fw3DCheckbox y { \
	      { text "3D" gBrushInfo(3d) "SetBrushConfiguration" } }
	
	# pack them in a column
	pack $fwTargetLabel $fwMain $fwMainAux \
	    $fwRadiusScale $fwShapeLabel $fwCircle \
	    $fwSquare $fw3DCheckbox             \
	    -side top                           \
	    -anchor w                           \
	    -expand yes                         \
	    -fill x
	
	# buttons. 
	tkm_MakeCloseButton $fwButtons $wwDialog
	
	pack $fwTop $fwButtons \
	    -side top       \
	    -expand yes     \
    -fill x
    }
}

proc DoEditBrushInfoDlog {} {

    global gDialog
    global ksaBrushString
    global DspA_tBrush_EditOne DspA_tBrush_EditTwo
    global gEditBrush

    set wwDialog .wwEditBrushInfoDlog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Edit Brush Info" {-borderwidth 10}] } {
  
  set fwTop                $wwDialog.fwTop
  set fwInfo               $fwTop.fwInfo
  set fwButtons            $wwDialog.fwButtons
  
  frame $fwTop
  
  tixNoteBook $fwInfo
  foreach tool "$DspA_tBrush_EditOne $DspA_tBrush_EditTwo" {

      $fwInfo add pane$tool -label $ksaBrushString($tool)

      set fw [$fwInfo subwidget pane$tool]
      set fwScales          $fw.fwScales
      set fwDefaults       $fw.fwDefaults

      # low, high, and new value sliders
      tkm_MakeSliders $fwScales [list \
        [list {"Low"} gEditBrush($tool,low) \
        0 255 100 "SetEditBrushConfiguration" 1] \
        [list {"High"} gEditBrush($tool,high) \
        0 255 100 "SetEditBrushConfiguration" 1 ]\
        [list {"New Value"} gEditBrush($tool,new) \
        0 255 100 "SetEditBrushConfiguration" 1 ]]

      # defaults button
      tkm_MakeButtons $fwDefaults \
        { {text "Restore Defaults" "SetBrushInfoToDefaults $tool"} }

      # pack them in a column
      pack $fwScales $fwDefaults \
        -side top                           \
        -anchor w                           \
        -expand yes                         \
        -fill x
  }

  # buttons. 
  tkm_MakeCloseButton $fwButtons $wwDialog

  pack $fwTop $fwInfo $fwButtons \
    -side top       \
    -expand yes     \
    -fill x
   }
}

proc DoSegmentationVolumeDisplayInfoDlog { } {

    global gDialog
    global gfSegmentationVolumeAlpha

    set wwDialog .wwSegmentationVolumeDisplay

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Segmentation Display" {-borderwidth 10}] } {
  
  set fwSlider             $wwDialog.fwSlider
  set fwButtons            $wwDialog.fwButtons
  
  # alpha
  tkm_MakeSliders $fwSlider { \
    { {"Overlay Alpha"} gfSegmentationVolumeAlpha \
    0 1 80 "SetSegmentationVolumeConfiguration" 1 0.1 } }

  # buttons. 
  tkm_MakeCloseButton $fwButtons $wwDialog 

  pack $fwSlider $fwButtons \
    -side top       \
    -expand yes     \
    -fill x
   }

}

proc DoDTIVolumeDisplayInfoDlog { } {

    global gDialog
    global gfDTIVolumeAlpha

    set wwDialog .wwDTIVolumeDisplay

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "DTI Display" {-borderwidth 10}] } {
  
  set fwSlider             $wwDialog.fwSlider
  set fwButtons            $wwDialog.fwButtons
  
  # alpha
  tkm_MakeSliders $fwSlider { \
    { {"Overlay Alpha"} gfDTIVolumeAlpha \
    0 1 80 "SetDTIVolumeConfiguration" 1 0.1 } }

  # buttons. 
  tkm_MakeCloseButton $fwButtons $wwDialog 

  pack $fwSlider $fwButtons \
    -side top       \
    -expand yes     \
    -fill x
   }

}

proc DoRecomputeSegmentation {} {

    global gDialog

    set wwDialog .wwRecomputeSegmentation

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Recompute Segmentation" {-borderwidth 10}] } {

  set fwMain    $wwDialog.fwMain
  set fwButtons $wwDialog.fwButtons
  set fwCheckbox $wwDialog.fwCheckbox


  # check button
  tkm_MakeCheckboxes $fwCheckbox h { \
          { text "Display Intermediate Results" \
           gDisplayIntermediateResults \
           { "SetSegmentationDisplayStatus" } \
           "Will show each iteration of Gibbs ICM algorithm" } \
       }

  # prompt
  tkm_MakeNormalLabel $fwMain\
    "Do you wish to recompute the segmentation?"

  # ok and cancel buttons.
  tkm_MakeButtons $fwButtons { \
    {text "Try" {RecomputeSegmentation 0} } \
    {text "Revert" {RestorePreviousSegmentation 0} } \
    {text "Cancel" { Dialog_Close .wwRecomputeSegmentation }}
    {text "Update Means" { Dialog_Close .wwRecomputeSegmentation } }}

  pack $fwMain $fwButtons $fwCheckbox \
    -side top       \
    -expand yes     \
    -fill x         \
    -padx 5         \
    -pady 5
    }
}


proc DoCursorInfoDlog { } {

    global gDialog
    global gCursor

    set wwDialog .wwCursorInfoDlog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Cursor Info" {-borderwidth 10}] } {
  
  set fwTop                $wwDialog.fwTop 
  set lfwColor             $fwTop.lfwColor
  set lfwShape             $fwTop.lfwShape
  set fwButtons            $wwDialog.fwButtons
  
  frame $fwTop
  
  # color
  tixLabelFrame $lfwColor \
    -label "Color" \
    -labelside acrosstop \
    -options { label.padX 5 }

  set fwColorSub           [$lfwColor subwidget frame]
  set fwColors             $fwColorSub.fwRedSlider

  tkm_MakeSliders $fwColors {\
    { {"Red"} \
    gCursor(color,red) 0 1 80 "SendCursorConfiguration" 1 0.1 } \
    { {"Green"} \
    gCursor(color,green) 0 1 80 "SendCursorConfiguration" 1 0.1 } \
    {  {"Blue"} \
    gCursor(color,blue) 0 1 80 "SendCursorConfiguration" 1 0.1 } }

  pack $fwColors \
    -side top \
    -anchor w \
    -expand yes \
    -fill x

  # shape
  tixLabelFrame $lfwShape \
    -label "Shape" \
    -labelside acrosstop \
    -options { label.padX 5 }

  set fwShapeSub           [$lfwShape subwidget frame]
  set fwShape              $fwShapeSub.fwShape

  tkm_MakeToolbar $fwShape \
    1 \
    gCursor(shape) \
    {puts "cursor toolbar"} { \
    { image 0 icon_marker_crosshair "Crosshair" } \
    { image 1 icon_marker_diamond "Diamond" } }

  pack $fwShape \
    -side left \
    -anchor w

  # buttons. 
  tkm_MakeApplyCloseButtons $fwButtons $wwDialog SendCursorConfiguration

  pack $fwTop $lfwColor $lfwShape $fwButtons \
    -side top       \
    -expand yes     \
    -fill x
   }

}

proc DoSurfaceInfoDlog { } {

    global gDialog
    global gSurface
    global Surf_tVertexSet_Main Surf_tVertexSet_Original 
    global Surf_tVertexSet_Canonical
    global ksaSurfaceVertexSetString

    set wwDialog .wwSurfaceInfoDlog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Surface Info" {-borderwidth 10}] } {
  
  set fwTop     $wwDialog.fwTop 
  set fwButtons $wwDialog.fwButtons

  frame $fwTop

  foreach surface "$Surf_tVertexSet_Main $Surf_tVertexSet_Original \
    $Surf_tVertexSet_Canonical" {
      
      set fwSurface $fwTop.fwSurface$surface
      set fwColor   $fwSurface.fwColor
      set fwWidth   $fwSurface.fwWidth
      
      frame $fwSurface 

      # color
      tkm_MakeColorPicker $fwColor $ksaSurfaceVertexSetString($surface) \
        gSurface($surface,color,red) \
        gSurface($surface,color,green) \
        gSurface($surface,color,blue) \
        "SendSurfaceInformation $surface" 80

      # width
      tkm_MakeSliders $fwWidth [list \
        [list {"Width"} gSurface($surface,width) 1 20 80 \
        "SendSurfaceInformation $surface" 1]]
      
      pack $fwSurface $fwColor $fwWidth \
        -side top \
        -anchor w
  }

  # buttons. 
  tkm_MakeCloseButton $fwButtons $wwDialog

  pack $fwTop  $fwButtons \
    -side top       \
    -expand yes     \
    -fill x
   }

}

proc DoEditParcBrushInfoDlog { } {

    global gDialog 
    global gParcBrush glParcEditColors
    global tkm_tVolumeTarget_MainAna
    global tkm_tVolumeTarget_AuxAna
    global tkm_tVolumeTarget_MainSeg
    global tkm_tVolumeTarget_AuxSeg

    set wwDialog .wwEditParcBrushInfoDlog

   # try to create the dlog...
    if { [Dialog_Create $wwDialog "Segmentation Brush Info" {-borderwidth 10}] } {

  set lfwColor     $wwDialog.lfwColor
  set lfwFill      $wwDialog.lfwFill
  set fwButtons    $wwDialog.fwButtons

  # color
  tixLabelFrame $lfwColor \
    -label "Color" \
    -labelside acrosstop \
    -options { label.padX 5}

  set fwColorSub           [$lfwColor subwidget frame]
  set fwColor              $fwColorSub.fwColor

  tixScrolledListBox $fwColor -scrollbar auto\
    -browsecmd SendParcBrushInfo
  
  # go thru the list of entry names and insert each into the listbox
  $fwColor subwidget listbox configure -selectmode single
  set nLength [llength $glParcEditColors]
  for { set nEntry 0 } { $nEntry < $nLength } { incr nEntry } {
      $fwColor subwidget listbox insert end \
        [lindex $glParcEditColors $nEntry]
  }

  # select the one with the index of the parc brush color
  $fwColor subwidget listbox selection set $gParcBrush(color)
  $fwColor subwidget listbox see $gParcBrush(color)

  pack $fwColor \
    -side top \
    -expand yes \
    -fill x

  # fill characteristics
  tixLabelFrame $lfwFill \
    -label "Fill Parameters" \
    -labelside acrosstop \
    -options { label.padX 5 }

  set fwFillSub       [$lfwFill subwidget frame]
  set fwFill          $fwFillSub.fwFill
  set fw3D            $fwFill.fw3D
  set fwLabel         $fwFill.fwLabel
  set fwMainSrc       $fwFill.fwMainSrc
  set fwAuxSrc        $fwFill.fwAuxSrc
  set fwParcSrc       $fwFill.fwParcSrc
  set fwSliders       $fwFill.fwSliders
  set fwDistanceNote  $fwFill.fwDistanceNote

  frame $fwFill

  # 3d
  tkm_MakeCheckboxes $fw3D y { \
    { text "3D" gParcBrush(3d) "SendParcBrushInfo" } }

  # source radios
  tkm_MakeNormalLabel $fwLabel "Use as source:"
  tkm_MakeRadioButton $fwMainSrc "Main Anatomical" \
    gParcBrush(src) $tkm_tVolumeTarget_MainAna "SendParcBrushInfo"
  tkm_MakeRadioButton $fwAuxSrc "Aux Anatomical" \
    gParcBrush(src) $tkm_tVolumeTarget_AuxAna "SendParcBrushInfo"
  tkm_MakeRadioButton $fwParcSrc "Segmentation" \
    gParcBrush(src) $tkm_tVolumeTarget_MainSeg "SendParcBrushInfo"
  
  # fuzziness and max distance
  tkm_MakeSliders $fwSliders { \
    { "Fuzziness" gParcBrush(fuzzy) \
    0 255 50 "SendParcBrushInfo" 1 } \
    {  "\"Max Distance\"" gParcBrush(distance) \
    0 255 50 "SendParcBrushInfo" 1 } }
  tkm_MakeSmallLabel $fwDistanceNote "enter 0 for no limit"
  

  pack $fw3D $fwLabel $fwMainSrc $fwAuxSrc \
    $fwParcSrc $fwSliders $fwDistanceNote $fwFill \
    -side top \
    -expand yes \
    -fill x

  # close button
  tkm_MakeCloseButton $fwButtons $wwDialog 

  pack $lfwColor $lfwFill $fwButtons \
    -side top \
    -expand yes \
    -fill x

    }
}


proc DoVolumeColorScaleInfoDlog { } {

    global gDialog
    global gfVolumeColorScaleThresh gfVolumeColorScaleSquash 
    global gfSavedVolumeColorScaleThresh gfSavedVolumeColorScaleSquash 

    set wwDialog .wwVolumeColorScaleInfoDlog

    set gfSavedVolumeColorScaleSquash(0) $gfVolumeColorScaleSquash(0)
    set gfSavedVolumeColorScaleThresh(0) $gfVolumeColorScaleThresh(0)
    set gfSavedVolumeColorScaleSquash(1) $gfVolumeColorScaleSquash(1)
    set gfSavedVolumeColorScaleThresh(1) $gfVolumeColorScaleThresh(1)

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Brightness / Contrast" {-borderwidth 10}] } {

  set fwSliders    $wwDialog.fwSliders
  set fwButtons    $wwDialog.fwButtons

  
  # brightness and contrast for main and aux sliders
  tkm_MakeSliders $fwSliders { \
    { {"Brightness"} gfVolumeColorScaleThresh(0) \
    1 0 100 "SendVolumeColorScale" 1 0.01 } \
    { {"Contrast"} gfVolumeColorScaleSquash(0) \
    0 30 100 "SendVolumeColorScale" 1 } \
    { {"Aux Brightness"} gfVolumeColorScaleThresh(1) \
    1 0 100 "SendVolumeColorScale" 1 0.01 } \
    { {"Aux Contrast"} gfVolumeColorScaleSquash(1) \
    0 30 100 "SendVolumeColorScale" 1 } }
  
  # buttons
  tkm_MakeCloseButton $fwButtons $wwDialog

  pack $fwSliders $fwButtons  \
    -side top    \
    -expand yes     \
    -fill x         \
    -padx 5         \
    -pady 5
    }
}

proc DoThresholdDlog {} {

    global gDialog
    
    set wwDialog .wwThresholdDlog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Threshold" {-borderwidth 10}] } {

  set fwLabel       $wwDialog.fwLabel
  set fwAbove       $wwDialog.fwAbove
  set fwBelow       $wwDialog.fwBelow
  set fwSliders     $wwDialog.fwSliders
  set fwButtons     $wwDialog.fwButtons

  # label 
  tkm_MakeNormalLabel $fwLabel "Change all values"
  
  # direction radios
  tkm_MakeRadioButton $fwAbove "above" bAbove 1
  tkm_MakeRadioButton $fwBelow "below" bAbove 0

  # threshold value
  tkm_MakeSliders $fwSliders { \
    { {"this value"} nThreshold 0 255 200 "" 1 } \
    { {"to this value"} nNewValue 0 255 200 "" 1 } }

  # pack them in a column
  pack $fwLabel $fwAbove $fwBelow $fwSliders \
    -side top                \
    -anchor w                \
    -expand yes              \
    -fill x

  # buttons.
  tkm_MakeCancelOKButtons $fwButtons $wwDialog \
    { Threshold $nThreshold $bAbove $nNewValue }

  pack  $fwButtons \
    -side top       \
    -expand yes     \
    -fill x         \
    -padx 5         \
    -pady 5
    }
}

proc DoRotateVolumeDlog {} {

    global gDialog
    
    set wwDialog .wwRotateVolumeDlog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Rotate Volume" {-borderwidth 10}] } {

  set fwDegrees     $wwDialog.fwRotateDegrees
  set fwDirection   $wwDialog.fwRotateDirection
  set fwX           $wwDialog.fwRotateX
  set fwY           $wwDialog.fwRotateY
  set fwZ           $wwDialog.fwRotateZ
  set fwButtons     $wwDialog.fwButtons

  set fRotateDegrees 0
  set sRotateDirection x

  # degrees
  tkm_MakeEntry \
    $fwDegrees "Degrees" \
    fRotateDegrees 5


  # direction radios
  tkm_MakeNormalLabel $fwDirection "Around anatomical axis:"
  # these are switched to match the internal representation of
  # the cor structure. x is ears, y is nose, z is thru top of head.
  tkm_MakeRadioButton $fwX "X (Ear to ear, perpendicular to Sagittal plane)" sRotateDirection x
  tkm_MakeRadioButton $fwY "Y (Back of head to nose, perpendicular to Coronal plane)" sRotateDirection z
  tkm_MakeRadioButton $fwZ "Z (Neck to top of head, perpendicular to Horizontal plane)" sRotateDirection y

  # buttons. 
  tkm_MakeCancelOKButtons $fwButtons $wwDialog \
    { RotateVolume $sRotateDirection $fRotateDegrees }

  pack $fwDegrees $fwDirection $fwX $fwY $fwZ $fwButtons \
    -side top       \
    -anchor w       \
    -expand yes     \
    -fill x         \
    -padx 5         \
    -pady 5
    }
}
proc DoFlipVolumeDlog {} {

    global gDialog
    
    set bFlipX 0
    set bFlipY 0
    set bFlipZ 0
    set wwDialog .wwFlipDialog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Flip Volume" {-borderwidth 10}] } {

  set fwFlip    $wwDialog.fwFlip
  set fwButtons $wwDialog.fwButtons

  # flip checks
  # these are switched to match the internal representation of
  # the cor structure. x is ears, y is nose, z is thru top of head.
  tkm_MakeCheckboxes $fwFlip y { \
    { text "Flip around middle Sagittal plane" bFlipX {} "" } \
    { text "Flip around middle Horizontal plane" bFlipY {} "" } \
    { text "Flip around middle Coronal plane" bFlipZ {} "" } }

  # buttons. 
  tkm_MakeCancelOKButtons $fwButtons $wwDialog \
    { FlipVolume $bFlipX $bFlipY $bFlipZ }

  pack $fwFlip $fwButtons \
    -side top       \
    -anchor w       \
    -expand yes     \
    -fill x         \
    -padx 5         \
    -pady 5
    }
}

proc DoRegisterHeadPtsDlog {} {

    global gDialog
    
    set wwDialog .wwRegisterHeadPtsDlog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Register Head Points" {-borderwidth 10}] } {

  set fwTop        $wwDialog.fwTop
  set lfwTranslate $fwTop.lfwTranslate
  set lfwRotate    $fwTop.lfwRotate
  set fwButtons    $fwTop.fwButtons

  frame $fwTop

  # make the label frames and get their subs.
  tixLabelFrame $lfwTranslate \
    -label "Translate" \
    -labelside acrosstop \
    -options { label.padX 5 }

  set fwTranslateSub     [$lfwTranslate subwidget frame]
  set fwTranslateButtons $fwTranslateSub.fwTranslateButtons
  set fwTranslateAmt     $fwTranslateSub.fwTranslateAmt

  # puts buttons in them
  tkm_MakeButtons $fwTranslateButtons { \
    { image icon_arrow_up \
    "TranslateHeadPts $fTranslateDistance y" } \
    { image icon_arrow_down \
    "TranslateHeadPts -$fTranslateDistance y" } \
    { image icon_arrow_left \
    "TranslateHeadPts $fTranslateDistance x" } \
    { image icon_arrow_right \
    "TranslateHeadPts -$fTranslateDistance x" } }

  tkm_MakeEntryWithIncDecButtons \
    $fwTranslateAmt "Distance" \
    fTranslateDistance \
    {} \
    0.5

  pack $fwTranslateButtons $fwTranslateAmt \
    $lfwTranslate \
    -side top                           \
    -anchor w                           \
    -expand yes                         \
    -fill x

  # rotate frame
  tixLabelFrame $lfwRotate \
    -label "Rotate" \
    -labelside acrosstop \
    -options { label.padX 5 }

  set fwRotateSub     [$lfwRotate subwidget frame]
  set fwRotateButtons $fwRotateSub.fwRotateButtons
  set fwRotateAmt     $fwRotateSub.fwRotateAmt

  # puts buttons in them
  tkm_MakeButtons $fwRotateButtons { \
    { image icon_arrow_ccw \
    "RotateHeadPts $fRotateDegrees z" } \
    { image icon_arrow_cw \
    "RotateHeadPts -$fRotateDegrees z" } }

  tkm_MakeEntryWithIncDecButtons \
    $fwRotateAmt "Degrees" \
    fRotateDegrees \
    {} \
    0.5

  pack $fwRotateButtons $fwRotateAmt \
    $lfwRotate \
    -side top                     \
    -anchor w                     \
    -expand yes                   \
    -fill x

  # just a close button here
  tkm_MakeButtons $fwButtons { \
    { text "Close" {Dialog_Close .wwRegisterHeadPtsDlog} } }

  pack $fwButtons \
    -side right \
    -anchor e

  pack $fwTop
    }
}

proc DoFindVertexDlog { iSurface } {

    global gDialog
    global gFindingSurface

    set gFindingSurface $iSurface
    set nVertex 0
    set wwDialog .wwFindVertexDlog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Find Vertex" {-borderwidth 10}] } {

  set fwMain    $wwDialog.fwMain
  set lwPrompt  $fwMain.lwPrompt
  set ewName    $fwMain.ewName

  set fwButtons $wwDialog.fwButtons
  set bwOK      $fwButtons.bwOK
  set bwCancel  $fwButtons.bwCancel

  # prompt and entry field
  tkm_MakeEntry $fwMain "Find vertex number:" nVertex 6
  
  # ok and cancel buttons.
  tkm_MakeCancelOKButtons $fwButtons $wwDialog \
    { FindVertex $nVertex } {}

  pack $fwMain $fwButtons \
    -side top       \
    -expand yes     \
    -fill x         \
    -padx 5         \
    -pady 5
    }
}

proc DoRegisterOverlayDlog {} {

    global gDialog
    global fScaleFactor

    set wwDialog .wwRegisterOverlayDlog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Register Functional Overlay" {-borderwidth 10}] } {

  set fwTop        $wwDialog.fwTop
  set lfwTranslate $fwTop.lfwTranslate
  set lfwRotate    $fwTop.lfwRotate
  set lfwScale     $fwTop.lfwScale
  set fwButtons    $fwTop.fwButtons
  
  frame $fwTop

  # make the label frames and get their subs.
  tixLabelFrame $lfwTranslate \
    -label "Translate" \
    -labelside acrosstop \
    -options { label.padX 5 }

  set fwTranslateSub     [$lfwTranslate subwidget frame]
  set fwTranslateButtons $fwTranslateSub.fwTranslateButtons
  set fwTranslateAmt     $fwTranslateSub.fwTranslateAmt

  # puts buttons in them
  tkm_MakeButtons $fwTranslateButtons { \
    { image icon_arrow_up \
    "TranslateOverlayRegistration $fTranslateDistance y" } \
    { image icon_arrow_down \
    "TranslateOverlayRegistration -$fTranslateDistance y" } \
    { image icon_arrow_left \
    "TranslateOverlayRegistration $fTranslateDistance x" } \
    { image icon_arrow_right \
    "TranslateOverlayRegistration -$fTranslateDistance x" } }

  tkm_MakeEntryWithIncDecButtons \
    $fwTranslateAmt "Distance" \
    fTranslateDistance \
    {} \
    0.5

  pack $fwTranslateButtons $fwTranslateAmt \
    $lfwTranslate \
    -side top                           \
    -anchor w                           \
    -expand yes                         \
    -fill x

  # rotate frame
  tixLabelFrame $lfwRotate \
    -label "Rotate" \
    -labelside acrosstop \
    -options { label.padX 5 }

  set fwRotateSub     [$lfwRotate subwidget frame]
  set fwRotateButtons $fwRotateSub.fwRotateButtons
  set fwRotateAmt     $fwRotateSub.fwRotateAmt

  # puts buttons in them
  tkm_MakeButtons $fwRotateButtons { \
    { image icon_arrow_ccw \
    "RotateOverlayRegistration $fRotateDegrees z" } \
    { image icon_arrow_cw \
    "RotateOverlayRegistration -$fRotateDegrees z" } }

  tkm_MakeEntryWithIncDecButtons \
    $fwRotateAmt "Degrees" \
    fRotateDegrees \
    {} \
    0.5

  pack $fwRotateButtons $fwRotateAmt \
    $lfwRotate \
    -side top                     \
    -anchor w                     \
    -expand yes                   \
    -fill x
  
  # scale frame
  tixLabelFrame $lfwScale \
    -label "Scale" \
    -labelside acrosstop \
    -options { label.padX 5 }

  set fwScaleSub     [$lfwScale subwidget frame]
  set fwScaleButtons $fwScaleSub.fwScaleButtons
  set fwScaleAmt     $fwScaleSub.fwScaleAmt

  # puts buttons in them
  tkm_MakeButtons $fwScaleButtons { \
    { image icon_arrow_expand_x \
    "ScaleOverlayRegistration $fScaleFactor x" } \
    { image icon_arrow_shrink_x \
    "ScaleOverlayRegistration [expr 1.0 / $fScaleFactor] x" }
    { image icon_arrow_expand_y \
    "ScaleOverlayRegistration $fScaleFactor y" } \
    { image icon_arrow_shrink_y \
    "ScaleOverlayRegistration [expr 1.0 / $fScaleFactor] y" } }

  set fScaleFactor 1.0
  tkm_MakeEntryWithIncDecButtons \
    $fwScaleAmt "Scale Factor" \
    fScaleFactor \
    {} \
    0.05

  pack $fwScaleButtons $fwScaleAmt \
    $lfwScale \
    -side top                           \
    -anchor w                           \
    -expand yes                         \
    -fill x

  # just a close button here
  tkm_MakeButtons $fwButtons { \
    { text "Close" {Dialog_Close .wwRegisterOverlayDlog} } }

  pack $fwButtons \
    -side right \
    -anchor e

  pack $fwTop
    }
}

proc DoSaveRGBSeriesDlog {} {

    global gDialog
    global gnVolSlice

    set sDir ""
    set sPrefix ""
    set nBegin $gnVolSlice
    set nEnd $gnVolSlice
    set wwDialog .wwSaveRGBSeriesDlog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Save RGB Series" {-borderwidth 10}] } {

  set fwDir     $wwDialog.fwDir
  set fwPrefix  $wwDialog.fwPrefix
  set fwDirection $wwDialog.fwDirection
  set fwBegin   $wwDialog.fwBegin
  set fwEnd     $wwDialog.fwEnd
  set fwButtons $wwDialog.fwButtons

  # the directory field
  tkm_MakeDirectorySelector $fwDir \
    "Directory to save files in:" sDir

  # the file prefix
  tkm_MakeEntry $fwPrefix "Prefix:" sPrefix

  # begin and end slices
  tkm_MakeEntryWithIncDecButtons $fwBegin \
    "From slice" nBegin {} 1
  tkm_MakeEntryWithIncDecButtons $fwEnd \
    "To slice" nEnd {} 1

  # ok and cancel buttons.
  tkm_MakeCancelOKButtons $fwButtons $wwDialog \
    "SaveRGBSeries \$sDir/\$sPrefix \$nBegin \$nEnd"

  pack $fwDir $fwPrefix $fwBegin $fwEnd $fwButtons \
    -side top       \
    -expand yes     \
    -fill x         \
    -padx 5         \
    -pady 5
    }
}

proc DoGotoPointDlog {} {

    global gDialog
    global mri_tCoordSpace_VolumeIdx mri_tCoordSpace_RAS 
    global mri_tCoordSpace_Talairach
    global gnVolX gnVolY gnVolZ
    global gbTalTransformPresent
    
    set wwDialog .wwGotoPointDlog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Goto Point" {-borderwidth 10}] } {

  set fwLabel       $wwDialog.fwLabel
  set fwCoordSpace  $wwDialog.fwCoordSpace
  set fwVolumeIdx   $fwCoordSpace.fwVolumeIdx
  set fwRAS         $fwCoordSpace.fwRAS
  set fwTalCoords   $fwCoordSpace.fwTalCoords
  set fwWhere       $wwDialog.fwWhere
  set fwX           $fwWhere.fwX
  set fwY           $fwWhere.fwY
  set fwZ           $fwWhere.fwZ
  set fwButtons     $wwDialog.fwButtons

  set fX $gnVolX
  set fY $gnVolY
  set fZ $gnVolZ
  set coordSpace $mri_tCoordSpace_VolumeIdx

  # coord space radios
  tkm_MakeNormalLabel $fwLabel "Coordinate space:"
  frame $fwCoordSpace
  tkm_MakeRadioButton $fwVolumeIdx "Volume Index" \
    coordSpace $mri_tCoordSpace_VolumeIdx
  tkm_MakeRadioButton $fwRAS "RAS" \
    coordSpace $mri_tCoordSpace_RAS
  pack $fwLabel $fwVolumeIdx $fwRAS \
    -side left

  # pack tal coords if we got 'em
  if { $gbTalTransformPresent == 1 } {

      tkm_MakeRadioButton $fwTalCoords "Talairach" \
        coordSpace $mri_tCoordSpace_Talairach
      pack $fwTalCoords \
        -side left
  }

  # x y z fields
  frame $fwWhere
  tkm_MakeEntry $fwX "X" fX 5
  tkm_MakeEntry $fwY "Y" fY 5
  tkm_MakeEntry $fwZ "Z" fZ 5
  pack $fwX $fwY $fwZ \
    -side left

  # buttons. 
  tkm_MakeCancelOKButtons $fwButtons $wwDialog \
    { SetCursor $coordSpace $fX $fY $fZ }

  pack $fwLabel $fwCoordSpace $fwWhere $fwButtons \
    -side top       \
    -anchor w       \
    -expand yes     \
    -fill x         \
    -padx 5         \
    -pady 5
    }
}

proc DoAverageSurfaceVertexPositionsDlog {} {

    global gDialog

    set nNumAverages 10
    set wwDialog .wwFindVertexDlog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Average Vertex Positions" {-borderwidth 10}] } {

	set fwMain    $wwDialog.fwMain
	set lwPrompt  $fwMain.lwPrompt
	set ewName    $fwMain.ewName
	
	set fwButtons $wwDialog.fwButtons
	set bwOK      $fwButtons.bwOK
	set bwCancel  $fwButtons.bwCancel
	
	# prompt and entry field
	tkm_MakeEntry $fwMain "Number of averages:" nNumAverages 6
  
	# ok and cancel buttons.
	tkm_MakeCancelOKButtons $fwButtons $wwDialog \
	    { AverageSurfaceVertexPositions $nNumAverages } {}
	
	pack $fwMain $fwButtons \
	    -side top       \
	    -expand yes     \
	    -fill x         \
	    -padx 5         \
	    -pady 5
    }
}

proc DoEditHeadPointLabelDlog {} {

    global gDialog
    global gsaLabelContents
    
    set wwDialog .wwEditHeadPointLabelDlog
    set sHeadPointLabel $gsaLabelContents(kLabel_Label_Head,value,cursor)

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Edit Head Point Label" {-borderwidth 10}] } {

  set fwMain    $wwDialog.fwMain

  set fwButtons $wwDialog.fwButtons
  set bwOK      $fwButtons.bwOK
  set bwCancel  $fwButtons.bwCancel

  # prompt and entry field
  tkm_MakeEntry $fwMain "Change label to:" sHeadPointLabel 20
  
  # ok and cancel buttons.
  tkm_MakeCancelOKButtons $fwButtons $wwDialog \
    { SetSelectedHeadPointLabel $sHeadPointLabel } {}

  pack $fwMain $fwButtons \
    -side top       \
    -expand yes     \
    -fill x         \
    -padx 5         \
    -pady 5
    }
}



proc SetSegmentationDisplayStatus { } {

    global gDisplayIntermediateResults
    SetGCADisplayStatus $gDisplayIntermediateResults
}
proc SetBrushConfiguration { } {
    global gBrushInfo

    SetBrushTarget $gBrushInfo(target)
    SetBrushShape $gBrushInfo(radius) $gBrushInfo(shape) $gBrushInfo(3d)
}

proc SetEditBrushConfiguration { } {

    global gEditBrush
    global DspA_tBrush_EditOne DspA_tBrush_EditTwo

    foreach tool "$DspA_tBrush_EditOne $DspA_tBrush_EditTwo" {
  SetBrushInfo $tool $gEditBrush($tool,low) $gEditBrush($tool,high) \
    $gEditBrush($tool,new)
    }
}

proc SetSegmentationVolumeConfiguration {} {

    global gfSegmentationVolumeAlpha
    SetSegmentationAlpha $gfSegmentationVolumeAlpha
}

proc SetDTIVolumeConfiguration {} {

    global gfDTIVolumeAlpha
    SetDTIAlpha $gfDTIVolumeAlpha
}

proc SendParcBrushInfo {} {
    global gParcBrush

    # get the selected item from the scrolled box in the dlog. this is the
    # index of the color to use.
    set nSelection [[.wwEditParcBrushInfoDlog.lfwColor subwidget frame].fwColor subwidget listbox curselection];

    SetParcBrushInfo $nSelection $gParcBrush(3d) \
      $gParcBrush(src) $gParcBrush(fuzzy) \
      $gParcBrush(distance)
}

proc SendVolumeColorScale { } {

    global gfVolumeColorScaleThresh gfVolumeColorScaleSquash 

    SetVolumeColorScale 0 \
      $gfVolumeColorScaleThresh(0) \
      $gfVolumeColorScaleSquash(0)
    SetVolumeColorScale 1 \
      $gfVolumeColorScaleThresh(1) \
      $gfVolumeColorScaleSquash(1)
}

# ======================================================== INTERFACE MODIFIERS


proc ShowLabel { isLabel ibShow } {

    global gbShowLabel
    PackLabel $isLabel cursor $ibShow 
    PackLabel $isLabel mouseover $ibShow
    set gbShowLabel($isLabel) $ibShow
}

proc PackLabel { isLabel iSet ibShow } {

    global glLabel gfwaLabel

    # find the label index in our list.
    set nLabel [lsearch -exact $glLabel $isLabel]
    if { $nLabel == -1 } {
  puts "Couldn't find $isLabel\n"
  return;
    }

    # are we showing or hiding?
    if { $ibShow == 1 } {

  # go back and try to pack it after the previous labels
  set lTemp [lrange $glLabel 0 [expr $nLabel - 1]]
  set lLabelsBelow ""
  foreach element $lTemp {
      set lLabelsBelow [linsert $lLabelsBelow 0 $element]
  }
  foreach label $lLabelsBelow {
      if {[catch { pack $gfwaLabel($isLabel,$iSet) \
        -after $gfwaLabel($label,$iSet)    \
        -side top                \
        -anchor w } sResult] == 0} {
    return;
      }
  }
  
  # if that fails, go forward and try to pack it before the later labels
  set lLabelsAbove [lrange $glLabel [expr $nLabel + 1] [llength $glLabel]]
  foreach label $lLabelsAbove {
      if {[catch { pack $gfwaLabel($isLabel,$iSet)  \
        -before $gfwaLabel($label,$iSet)    \
        -side top                  \
        -anchor w } sResult] == 0} {
    return;
      }
  }

  # must be the first one. just pack it.
  catch { pack $gfwaLabel($isLabel,$iSet)  \
    -side top                \
    -anchor w } sResult

    } else {
  
  # else just forget it
  pack forget $gfwaLabel($isLabel,$iSet)
    } 
}

proc ShowVolumeCoords { ibShow } {
    ShowLabel kLabel_Coords_Vol $ibShow
}

proc ShowRASCoords { ibShow } {
    ShowLabel kLabel_Coords_Vol_RAS $ibShow
}
 
proc ShowTalCoords { ibShow } {
    global gbTalTransformPresent
    set gbTalTransformPresent $ibShow
    ShowLabel kLabel_Coords_Vol_Tal $ibShow
}

proc ShowAuxValue { ibShow } {
    ShowLabel kLabel_Value_Aux $ibShow
}

proc ShowSegLabel { ibShow } {
    ShowLabel kLabel_Label_SegLabel $ibShow
}

proc ShowAuxSegLabel { ibShow } {
    ShowLabel kLabel_Label_AuxSegLabel $ibShow
}

proc ShowHeadPointLabel { ibShow } {
    ShowLabel kLabel_Label_Head $ibShow
    tkm_SetMenuItemGroupStatus tMenuGroup_HeadPoints $ibShow
}

proc ShowFuncCoords { ibShow } {
    ShowLabel kLabel_Coords_Func $ibShow
}

proc ShowFuncValue { ibShow } {
    ShowLabel kLabel_Value_Func $ibShow
}

proc ClearParcColorTable { } {

    global glParcEditColors
    set glParcEditColors {}
}

proc AddParcColorTableEntry { inIndex isString } {

    global glParcEditColors
    set glParcEditColors [linsert $glParcEditColors $inIndex $isString]
}

# =============================================================== VIEW PRESETS

proc SetViewPreset { iPreset } {

    global gViewPreset gViewPresetString ksaViewPresetString
    global tViewPreset_Single tViewPreset_Multiple tViewPreset_Mosaic
    global MWin_tLinkPolicy_None MWin_tLinkPolicy_MultipleOrientations
    global MWin_tLinkPolicy_Mosaic

    
    if { [catch {set gViewPreset $iPreset} sResult] == 1 } {
#  puts "caught: $sResult"
    }
    

    if { $iPreset == $tViewPreset_Single } {
  SetDisplayConfig 1 1 $MWin_tLinkPolicy_None
    }
    if { $iPreset == $tViewPreset_Multiple } {
  SetDisplayConfig 2 2 $MWin_tLinkPolicy_MultipleOrientations
    }
    if { $iPreset == $tViewPreset_Mosaic } {
  SetDisplayConfig 4 4 $MWin_tLinkPolicy_Mosaic
    }

}

# ========================================================= BUILDING INTERFACE

proc CreateWindow { iwwTop } {

    global ksWindowName
    frame $iwwTop
    wm title . $ksWindowName
    wm withdraw .
}

proc ToggleAndSendDisplayFlag { iFlag } {
    global gbDisplayFlag

    set gbDisplayFlag($iFlag) [expr 1 - $gbDisplayFlag($iFlag)]
    SendDisplayFlagValue $iFlag
}

proc SetAndSendDisplayFlag { iFlag iValue } {
    global gbDisplayFlag

    set gbDisplayFlag($iFlag) $iValue
    SendDisplayFlagValue $iFlag
}

proc MakeKeyBindings { iwTop } {

    bind $iwTop <Control-Key-1> \
	{SetAndSendDisplayFlag flag_AuxVolume 0}
    bind $iwTop <Control-Key-2> \
	{SetAndSendDisplayFlag flag_AuxVolume 1}
    bind $iwTop <Control-Key-m> \
	{ToggleAndSendDisplayFlag flag_MainSurace}
    bind $iwTop <Control-Key-o> \
	{ToggleAndSendDisplayFlag flag_OriginalSurface}
    bind $iwTop <Control-Key-p> \
	{ToggleAndSendDisplayFlag flag_CanonicalSurface}
    bind $iwTop <Control-Key-v> \
	{ToggleAndSendDisplayFlag flag_DisplaySurfaceVertices}
    bind $iwTop <Control-Key-i> \
	{ToggleAndSendDisplayFlag flag_InterpolateSurfaceVertices}
    bind $iwTop <Control-Key-f> \
	{ToggleAndSendDisplayFlag flag_FunctionalColorScaleBar}
    bind $iwTop <Control-Key-g> \
	{ToggleAndSendDisplayFlag flag_SegmentationVolumeOverlay}
    bind $iwTop <Alt-Key-g> \
	{ToggleAndSendDisplayFlag flag_AuxSegmentationVolumeOverlay}
    bind $iwTop <Control-Key-s> \
	{ToggleAndSendDisplayFlag flag_Selection}
    bind $iwTop <Control-Key-t> \
	{ToggleAndSendDisplayFlag flag_ControlPoints}
    bind $iwTop <Control-Key-c> \
	{ToggleAndSendDisplayFlag flag_Cursor}

    bind $iwTop <Key-n> \
	{SetTool $DspA_tTool_Navigate}
    bind $iwTop <Key-s> \
	{SetTool $DspA_tTool_Select}
    bind $iwTop <Key-a> \
	{SetTool $DspA_tTool_Edit}
    bind $iwTop <Key-g> \
	{SetTool $DspA_tTool_EditParc}
    bind $iwTop <Key-t> \
	{SetTool $DspA_tTool_CtrlPts}
}

proc CreateMenuBar { ifwMenuBar } {

    global mri_tOrientation_Sagittal mri_tOrientation_Horizontal 
    global mri_tOrientation_Coronal
    global DspA_tTool_Navigate DspA_tTool_Select
    global DspA_tTool_Edit DspA_tTool_EditParc  DspA_tTool_CtrlPts 
    global gDisplayCols gDisplayRows gViewPreset
    global tViewPreset_Single tViewPreset_Multiple tViewPreset_Mosaic    
    global gTool
    global gbShowToolBar gbShowLabel
    global glDisplayFlag gbDisplayFlag
    
    set mbwFile   $ifwMenuBar.mbwFile
    set mbwEdit   $ifwMenuBar.mbwEdit
    set mbwView   $ifwMenuBar.mbwView
    set mbwTools  $ifwMenuBar.mbwTools

    frame $ifwMenuBar -border 2 -relief raised

    # file menu button
    tkm_MakeMenu $mbwFile "File" {
	{ command
	    "Load Main Volume..."
	    {DoFileDlog LoadVolume} }
	{ command
	    "Save Main Volume"
	    DoSaveDlog
	    tMenuGroup_DirtyAnatomicalVolume }
	{ command
	    "Save Main Volume As..."
	    {DoFileDlog SaveVolumeAs}
	    tMenuGroup_DirtyAnatomicalVolume }
	{ cascade "Aux Volume" {
	    { command
		"Load Aux Volume..."
		{DoFileDlog LoadAuxVolume} }
	    { command
		"Save Aux Volume"
		DoAuxSaveDlog
		tMenuGroup_DirtyAuxAnatomicalVolume }
	    { command
		"Save Aux Volume As..."
		{DoFileDlog SaveAuxVolumeAs}
		tMenuGroup_DirtyAuxAnatomicalVolume }
	    { command
		"Unload Aux Volume"
		{UnloadVolume 1} 
	        tMenuGroup_AuxVolumeOptions }
	}}
	{ separator }
	{ command
	    "Load Main Surface..."
	    {DoFileDlog LoadMainSurface} }
	{ cascade "Load Surface Configuration..." {
	    { command
		"Original Verticies"
		{DoFileDlog LoadOriginalSurface}
		tMenuGroup_SurfaceLoading }
	    { command
		"Pial Verticies "
		{DoFileDlog LoadPialSurface}
		tMenuGroup_SurfaceLoading } 
	}}
	{ command
	    "Unload Surface"
	    {UnloadSurface 0}
	    tMenuGroup_SurfaceLoading }
	{ command
	    "Write Surface Values..."
	    {DoFileDlog WriteSurfaceValues}
	    tMenuGroup_SurfaceLoading }
	{ cascade "Aux Surface" {
	    { command
		"Load Aux Main Surface..."
		{DoFileDlog LoadMainAuxSurface}
		tMenuGroup_SurfaceLoading }
	    { cascade "Load Aux Surface Configuration..." {
		{ command
		    "Original Verticies"
		    {DoFileDlog LoadOriginalAuxSurface}
		    tMenuGroup_SurfaceLoading }
		{ command
		    "Pial Verticies "
		    {DoFileDlog LoadPialAuxSurface}
		    tMenuGroup_SurfaceLoading }
	    }}
	    { command
		"Unload Aux Surface"
		{UnloadSurface 1}
		tMenuGroup_SurfaceLoading }
	}}
	{ separator }
	{ command
	    "Load Overlay Data..."
	    {DoLoadFunctionalDlog overlay} }
	{ command
	    "Load Time Course Data..."
	    {DoLoadFunctionalDlog timecourse} }
	{ command
	    "Save Overlay Registration"
	    Overlay_SaveRegistration
	    tMenuGroup_Registration }
	{ separator }
	{ command
	    "New Segmentation..."
	    {DoFileDlog NewSegmentation} }
	{ command
	    "Load Segmentation..."
	    {DoFileDlog LoadSegmentation} }
	{ command
	    "Import Surface Annotation as Segmentation..."
	    {DoFileDlog ImportSurfaceAnnotation}
	    tMenuGroup_SurfaceLoading }
	{ command
	    "Save Segmentation"
	    "SaveSegmentationVolume 0"
	    tMenuGroup_Segmentation }
	{ command
	    "Save Segmentation As..."
	    {DoFileDlog SaveSegmentationAs}
	    tMenuGroup_Segmentation }
	{ command
	    "Save Changed Values"
	    {DoFileDlog ExportChangedSegmentationVolume}
	    tMenuGroup_Segmentation }
	{ cascade "Aux Segmentation" {
	    { command
		"New Aux Segmentation..."
		{DoFileDlog NewAuxSegmentation} }
	    
	    { command
		"Load Aux Segmentation..."
		{DoFileDlog LoadAuxSegmentation} }
	    
	    { command
		"Save Aux Segmentation"
		"SaveSegmentationVolume 1"
		tMenuGroup_AuxSegmentationOptions }
	    
	    { command
		"Save Aux Segmentation As..."
		{DoFileDlog SaveAuxSegmentationAs}
		tMenuGroup_AuxSegmentationOptions }
	    { command
		"Save Aux Changed Values"
		{DoFileDlog ExportAuxChangedSegmentationVolume}
		tMenuGroup_Segmentation }
	}}
	{ separator }
	{ cascade "Transforms" {
	    { command
		"Load Transform for Main Volume..."
		{DoFileDlog LoadVolumeDisplayTransform} }
	    { command
		"Load Transform for Aux Volume..."
		{DoFileDlog LoadAuxVolumeDisplayTransform} }
	    { command
		"Unload Transform for Main Volume"
		{UnloadVolumeDisplayTransform 0}
		tMenuGroup_VolumeMainTransformLoadedOptions }
	    { command
		"Unload Transform for Aux Volume"
		{UnloadVolumeDisplayTransform 1}
		tMenuGroup_VolumeAuxTransformLoadedOptions }
	}}
	{ cascade "Label" {
	    { command
		"Load Label..."
		{DoFileDlog LoadLabel} }
	    { command
		"Save Label As..."
		{DoFileDlog SaveLabelAs} }
	}}
	{ cascade "GCA" {
	    { command
		"Load GCA"
		{DoFileDlog LoadGCA} }
	    { command
		"Save GCA"
		{DoFileDlog SaveGCA}
		tMenuGroup_GCAOptions }
	    { command
		"Unload GCA"
		{UnloadGCA}
		tMenuGroup_GCAOptions }
	}}
	{ cascade "Head Points" {
	    { command
		"Load Head Points..."
		{DoFileDlog LoadHeadPts} }
	    { command
		"Save Head Point Transform"
		WriteHeadPointsTransform
		tMenuGroup_HeadPoints }
	    { command
		"Save Head Points"
		WriteHeadPointsFile
		tMenuGroup_HeadPoints }
	}}
	{ cascade "DTI" {
	    { command
		"Load DTI Volumes..."
		  {DoLoadDTIDlog} }
	}}
	{ command
	    "Save Control Points"
	    WriteControlPointFile }
	{ separator }
	{ command
	    "Quit"
	    AllowSaveThenQuit } 
    }
   
    # edit menu 
    tkm_MakeMenu $mbwEdit "Edit" {
	{ command
	    "Undo Last Edit:Ctrl Z"
	    UndoLastEdit }
	{ separator }
	{ command
	    "Take Snapshot of Volume"
	    SnapshotVolume }
	{ command
	    "Restore Volume to Snapshot"
	    RestoreVolumeFromSnapshot }
	{ separator }
	{ command
	    "Clear Selection / Label"
	    ClearSelection }
	{ command
	    "Clear Undo Volume"
	    ClearUndoVolume } 
    }

    # view menu
    tkm_MakeMenu $mbwView "View" {
	{ cascade "View Configurations" {
	    { radio 
		"Single View"
		"SetViewPreset $tViewPreset_None"
		gViewPreset
		0 }
	    { radio 
		"Multiple Orientations"
		"SetViewPreset $tViewPreset_Multiple"
		gViewPreset
		1 }
	    { radio 
		"Mosaic"
		"SetViewPreset $tViewPreset_Mosaic"
		gViewPreset
		2 } 
	}}
	{ separator }
	{ cascade "Tool Bars" {
	    { check
		"Main"
		"ShowToolBar main $gbShowToolBar(main)"
		gbShowToolBar(main) }
	    { check
		"Navigation"
		"ShowToolBar nav $gbShowToolBar(nav)"
		gbShowToolBar(nav) }
	    { check
		"Reconstruction"
		"ShowToolBar recon $gbShowToolBar(recon)"
		gbShowToolBar(recon) }
	}}
	{ cascade "Information" {
	    { check
		"Volume Index Coordinates"
		"ShowLabel kLabel_Coords_Vol $gbShowLabel(kLabel_Coords_Vol)"
		gbShowLabel(kLabel_Coords_Vol) }
	    { check
		"Volume RAS Coordinates"
		"ShowLabel kLabel_Coords_Vol_RAS $gbShowLabel(kLabel_Coords_Vol_RAS)"
		gbShowLabel(kLabel_Coords_Vol_RAS) }
	    { check
		"Volume Scanner Coordinates"
		"ShowLabel kLabel_Coords_Vol_Scanner $gbShowLabel(kLabel_Coords_Vol_Scanner)"
		gbShowLabel(kLabel_Coords_Vol_Scanner) }
	    { check
		"MNI Coordinates"
		"ShowLabel kLabel_Coords_Vol_MNI $gbShowLabel(kLabel_Coords_Vol_MNI)"
		gbShowLabel(kLabel_Coords_Vol_MNI) }
	    { check
		"Talairach Coordinates"
		"ShowLabel kLabel_Coords_Vol_Tal $gbShowLabel(kLabel_Coords_Vol_Tal)"
		gbShowLabel(kLabel_Coords_Vol_Tal) }
	    { check
		"Volume Value"
		"ShowLabel kLabel_Value_Vol $gbShowLabel(kLabel_Value_Vol)"
		gbShowLabel(kLabel_Value_Vol) }
	    { check
		"Aux Volume Value"
		"ShowLabel kLabel_Value_Aux $gbShowLabel(kLabel_Value_Aux)"
		gbShowLabel(kLabel_Value_Aux)
		tMenuGroup_AuxVolumeOptions }
	    { check
		"Functional Overlay Index Coordinates"
		"ShowLabel kLabel_Coords_Func $gbShowLabel(kLabel_Coords_Func)"
		gbShowLabel(kLabel_Coords_Func)
		tMenuGroup_OverlayOptions }
	    { check
		"Functional Overlay RAS Coordinates"
		"ShowLabel kLabel_Coords_Func_RAS $gbShowLabel(kLabel_Coords_Func_RAS)"
		gbShowLabel(kLabel_Coords_Func_RAS)
		tMenuGroup_OverlayOptions }
	    { check
		"Functional Overlay Value"
		"ShowLabel kLabel_Value_Func $gbShowLabel(kLabel_Value_Func)"
		gbShowLabel(kLabel_Value_Func)
		tMenuGroup_OverlayOptions }
	    { check
		"Segmentation Label"
		"ShowLabel kLabel_Label_SegLabel $gbShowLabel(kLabel_Label_SegLabel)"
		gbShowLabel(kLabel_Label_SegLabel)
		tMenuGroup_SegmentationOptions }
	    { check
		"Aux Segmentation Label"
		"ShowLabel kLabel_Label_AuxSegLabel $gbShowLabel(kLabel_Label_AuxSegLabel)"
		gbShowLabel(kLabel_Label_AuxSegLabel)
		tMenuGroup_AuxSegmentationOptions }
	    { check
		"Head Point Label"
		"ShowLabel kLabel_Label_Head $gbShowLabel(kLabel_Label_Head)"
		gbShowLabel(kLabel_Label_Head)
		tMenuGroup_HeadPoints }
	    { check
		"Surface Distance"
		"ShowLabel kLabel_SurfaceDistance $gbShowLabel(kLabel_SurfaceDistance)"
		gbShowLabel(kLabel_SurfaceDistance)
		tMenuGroup_SurfacexLoading} 
	}}
	{ separator }
	{ cascade "Configure..." {
	    { command
		"Brightness / Contrast..."
		DoVolumeColorScaleInfoDlog }
	    { command
		"Cursor..."
		DoCursorInfoDlog }
	    { command
		"Surface..."
		DoSurfaceInfoDlog
		tMenuGroup_SurfaceViewing }
	    { command
		"Functional Overlay..."
		Overlay_DoConfigDlog
		tMenuGroup_OverlayOptions }
	    { command
		"Time Course Graph..."
		TimeCourse_DoConfigDlog
		tMenuGroup_TimeCourseOptions }
	    { command
		"Segmentation Display..."
		DoSegmentationVolumeDisplayInfoDlog
		tMenuGroup_SegmentationOptions } 
	    { command
		"DTI Display..."
		DoDTIVolumeDisplayInfoDlog
		tMenuGroup_DTIOptions } 
	}}
	{ separator }
	{ check 
	    "Anatomical Volume:Ctrl A"
	    "SendDisplayFlagValue flag_Anatomical"
	    gbDisplayFlag(flag_Anatomical) }
	{ radio 
	    "Main Volume:Ctrl 1"
	    "SendDisplayFlagValue flag_AuxVolume"
	    gbDisplayFlag(flag_AuxVolume) 
	    0 }
	{ radio
	    "Aux Volume:Ctrl 2"
	    "SendDisplayFlagValue flag_AuxVolume"
	    gbDisplayFlag(flag_AuxVolume)
	    1
	    tMenuGroup_AuxVolumeOptions }
	{ separator }
	{ check
	    "Maximum Intensity Projection"
	    "SendDisplayFlagValue flag_MaxIntProj"
	    gbDisplayFlag(flag_MaxIntProj) 
	}
	{ check
	    "Main Surface:Ctrl M"
	    "SendDisplayFlagValue flag_MainSurface"
	    gbDisplayFlag(flag_MainSurface) 
	    tMenuGroup_SurfaceViewing }
	{ check
	    "Original Surface:Ctrl O"
	    "SendDisplayFlagValue flag_OriginalSurface"
	    gbDisplayFlag(flag_OriginalSurface) 
	    tMenuGroup_OriginalSurfaceViewing }
	{ check
	    "Pial Surface:Ctrl P"
	    "SendDisplayFlagValue flag_CanonicalSurface"
	    gbDisplayFlag(flag_CanonicalSurface) 
	    tMenuGroup_CanonicalSurfaceViewing }
	{ check
	    "Surface Vertices:Ctrl V"
		"SendDisplayFlagValue flag_DisplaySurfaceVertices"
	    gbDisplayFlag(flag_DisplaySurfaceVertices) 
	    tMenuGroup_SurfaceViewing }
	{ check
	    "Interpolate Surface Vertices:Ctrl I"
	    "SendDisplayFlagValue flag_InterpolateSurfaceVertices"
	    gbDisplayFlag(flag_InterpolateSurfaceVertices) 
	    tMenuGroup_SurfaceViewing }
	{ check
	    "Functional Overlay:Ctrl F"
	    "SendDisplayFlagValue flag_FunctionalOverlay"
	    gbDisplayFlag(flag_FunctionalOverlay) 
	    tMenuGroup_OverlayOptions }
	{ check
	    "Functional Color Scale Bar"
	    "SendDisplayFlagValue flag_FunctionalColorScaleBar"
	    gbDisplayFlag(flag_FunctionalColorScaleBar) 
	    tMenuGroup_OverlayOptions }
	{ check
	    "Mask to Functional Overlay"
	    "SendDisplayFlagValue flag_MaskToFunctionalOverlay"
	    gbDisplayFlag(flag_MaskToFunctionalOverlay) 
	    tMenuGroup_OverlayOptions }
	{ check
	    "Show Histogram Percent Change"
	    "SendDisplayFlagValue flag_HistogramPercentChange"
	    gbDisplayFlag(flag_HistogramPercentChange) 
	    tMenuGroup_VLIOptions }
	{ check
	    "Segmentation Overlay:Ctrl G"
	    "SendDisplayFlagValue flag_SegmentationVolumeOverlay"
	    gbDisplayFlag(flag_SegmentationVolumeOverlay) 
	    tMenuGroup_SegmentationOptions }
	{ check
	    "Aux Segmentation Overlay:Alt G"
	    "SendDisplayFlagValue flag_AuxSegmentationVolumeOverlay"
	    gbDisplayFlag(flag_AuxSegmentationVolumeOverlay) 
	    tMenuGroup_AuxSegmentationOptions }
	{ check
	    "Segmentation Label Volume Count"
	    "SendDisplayFlagValue flag_SegLabelVolumeCount"
	    gbDisplayFlag(flag_SegLabelVolumeCount) 
	    tMenuGroup_SegmentationOptions }
	{ check
	    "DTI Overlay"
	    "SendDisplayFlagValue flag_DTIOverlay"
	    gbDisplayFlag(flag_DTIOverlay) 
	    tMenuGroup_DTIOptions }
	{ check
	    "Selection / Label:Ctrl S"
	    "SendDisplayFlagValue flag_Selection"
	    gbDisplayFlag(flag_Selection) }
	{ check
	    "Head Points"
	    "SendDisplayFlagValue flag_HeadPoints"
	    gbDisplayFlag(flag_HeadPoints) 
	    tMenuGroup_HeadPoints }
	{ check
	    "Control Points:Ctrl T"
	    "SendDisplayFlagValue flag_ControlPoints"
	    gbDisplayFlag(flag_ControlPoints) }
	{ check
	    "Cursor:Ctrl C"
	    "SendDisplayFlagValue flag_Cursor"
	    gbDisplayFlag(flag_Cursor) }
	{ check
	    "Axes"
	    "SendDisplayFlagValue flag_Axes"
	    gbDisplayFlag(flag_Axes) }
	{ check
	    "Edited Voxels"
	    "SendDisplayFlagValue flag_UndoVolume"
	    gbDisplayFlag(flag_UndoVolume) }
    }
	
    # tools menu
    tkm_MakeMenu $mbwTools "Tools" {
	{ radio
	    "Navigate:N"
	    "SetTool $DspA_tTool_Navigate"
	    gTool
	    0 }
	{ radio
	    "Select Voxels:S"
	    "SetTool $DspA_tTool_Select"
	    gTool
	    1 }
	{ radio
	    "Edit Voxels:A"
	    "SetTool $DspA_tTool_Edit"
	    gTool
	    2 }
	{ radio
	    "Edit Segmentation:G"
	    "SetTool $DspA_tTool_EditParc"
	    gTool
	    3 }
	{ radio
	    "Edit Ctrl Pts:T"
	    "SetTool $DspA_tTool_CtrlPts"
	    gTool
	    4 }
	{ separator }
	{ command
	    "Configure Brush Info..."
	    DoBrushInfoDlog }
	{ command
	    "Configure Volume Brush..."
	    DoEditBrushInfoDlog }
	{ command
	    "Configure Segmentation Brush..."
	    DoEditParcBrushInfoDlog
	    tMenuGroup_Segmentation }
	{ separator }
	{ command
	    "Save Point"
	    SendCursor }
	{ command
	    "Goto Saved Point"
	    ReadCursor }
	{ separator }
	{ command
	    "Goto Point..."
	    DoGotoPointDlog }
	{ separator }
	{ cascade "Volume" {
	    { command
		"Threshold Volume..."
		DoThresholdDlog }
	    { command
		"Flip Volume..."
		DoFlipVolumeDlog }
	    { command
		"Rotate Volume..."
		DoRotateVolumeDlog }
	    { command
		"Smart Cut"
		SmartCutAtCursor } } }
	{ cascade "Surface" {
	    { command 
		"Show Nearest Main Vertex"
		ShowNearestMainVertex
		tMenuGroup_SurfaceViewing }
	    { command
		"Show Nearest Original Vertex"
		ShowNearestOriginalVertex
		tMenuGroup_OriginalSurfaceViewing }
	    { command
		"Show Nearest Pial Vertex"
		ShowNearestCanonicalVertex
		tMenuGroup_CanonicalSurfaceViewing }
	    { separator }
	    { command 
		"Show Nearest Main Surface Edge"
		ShowNearestInterpolatedMainVertex
		tMenuGroup_SurfaceViewing }
	    { command
		"Show Nearest Original Surface Edge"
		ShowNearestInterpolatedOriginalVertex
		tMenuGroup_OriginalSurfaceViewing }
	    { command
		"Show Nearest Pial Surface Edge"
		ShowNearestInterpolatedCanonicalVertex
		tMenuGroup_CanonicalSurfaceViewing }
	    { separator }
	    { command
		"Find Main Vertex..."
		{ DoFindVertexDlog $Surf_tVertexSet_Main } 
		tMenuGroup_SurfaceViewing }
	    { command
		"Find Original Vertex..."
		{ DoFindVertexDlog $Surf_tVertexSet_Original }
		tMenuGroup_OriginalSurfaceViewing }
	    { command
		"Find Pial Vertex..."
		{ DoFindVertexDlog $Surf_tVertexSet_Canonical }
		tMenuGroup_CanonicalSurfaceViewing }
	    { separator }
	    { command
		"Set Vertex Distance at Cursor"
		{ SetSurfaceDistanceAtCursor }
		tMenuGroup_SurfaceLoading }
	    { command
		"Average Vertex Positions..."
		{ DoAverageSurfaceVertexPositionsDlog }
		tMenuGroup_SurfaceViewing } 
	}}
	{ cascade "fMRI" {
	    { command
		"Select Contiguous Voxels by Func Value"
		{ SelectVoxelsByFuncValue 0 }
		tMenuGroup_OverlayOptions }
	    { command
		"Select Contiguous Voxels by Threshold"
		{ SelectVoxelsByFuncValue 2 }
		tMenuGroup_OverlayOptions }
	    { command
		"Select Functional Voxel"
		{ SelectVoxelsByFuncValue 1 }
		tMenuGroup_OverlayOptions }
	    { command
		"Register Functwional Overlay..."
		{ DoRegisterOverlayDlog }
		tMenuGroup_Registration }
	    { command
		"Restore Overlay Registration"
		{ Overlay_RestoreRegistration }
		tMenuGroup_Registration }
	    { command
		"Set Registration to Identity"
		{ Overlay_SetRegistrationToIdentity }
		tMenuGroup_Registration }
	    { command
		"Graph Current Selection"
		{ GraphSelectedRegion }
		tMenuGroup_TimeCourseOptions }
	    { command
		"Print Time Course Summary to File.."
		{ DoFileDlog PrintTimeCourse }
		tMenuGroup_TimeCourseOptions }
	    { command
		"Save Time Course Graph to Postscript File.."
		{ DoFileDlog SaveTimeCourseToPS }
		tMenuGroup_TimeCourseOptions } 
	}}
	{ cascade "Segmentation" {
	    { command
		"Select Current Label"
		SelectCurrentSegLabel
		tMenuGroup_Segmentation }
	    { command
		"Recompute Segmentation"
		DoRecomputeSegmentation
		tMenuGroup_GCAOptions }
	    { command
		"Graph Current Label Average"
		GraphCurrentSegLabelAvg
		tMenuGroup_Segmentation } 
	}}
	{ cascade "Head Points" {
	    { command
		"Restore Head Points"
		RestoreHeadPts
		tMenuGroup_HeadPoints }
	    { command
		"Edit Current Head Point Label..."
		DoEditHeadPointLabelDlog
		tMenuGroup_HeadPoints }
	    { command
		"Register Head Points..."
		DoRegisterHeadPtsDlog
		tMenuGroup_HeadPoints } 
	}}
	{ command
	    "Save RGB..."
	    {DoFileDlog SaveRGB} }
	{ command
	    "Save RGB Series..."
	    DoSaveRGBSeriesDlog }
    }

    pack $mbwFile $mbwEdit $mbwView $mbwTools \
      -side left
}

proc CreateCursorFrame { ifwTop } {

    global gbLinkedCursor 

    set fwLabel             $ifwTop.fwMainLabel
    set fwLinkCheckbox      $ifwTop.fwLinkCheckbox
    set fwLabels            $ifwTop.fwLabels

    frame $ifwTop

    # the label that goes at the top of the frame
    tkm_MakeBigLabel $fwLabel "Cursor"

    # make the labels
    CreateLabelFrame $fwLabels cursor

    # pack the subframes in a column. 
    pack $fwLabel $fwLabels \
      -side top             \
      -anchor w

}

proc CreateMouseoverFrame { ifwTop } {

    set fwLabel             $ifwTop.fwMainLabel
    set fwLabels            $ifwTop.fwLabels

    frame $ifwTop

    # the label that goes at the top of the frame
    tkm_MakeBigLabel $fwLabel "Mouse"

    # make the labels
    CreateLabelFrame $fwLabels mouseover

    # pack the subframes in a column. 
    pack $fwLabel $fwLabels \
      -side top             \
      -anchor w
}

proc CreateLabelFrame { ifwTop iSet } {

    global glLabel gfwaLabel gsaLabelContents
    global mri_tCoordSpace_VolumeIdx
    global mri_tCoordSpace_RAS
    global mri_tCoordSpace_Talairach

    frame $ifwTop

    # create the frame names
    foreach label $glLabel {
	set gfwaLabel($label,$iSet) $ifwTop.fw$label
    }
    
    # create two active labels in each label frame
    foreach label $glLabel {
	frame $gfwaLabel($label,$iSet)
	set fwLabel $gfwaLabel($label,$iSet).fwLabel
	set fwValue $gfwaLabel($label,$iSet).fwValue

	tkm_MakeActiveLabel $fwLabel "" gsaLabelContents($label,name) 14

	if { $label == "kLabel_Coords_Vol" && $iSet == "cursor" } {
	    tkm_MakeEntry $fwValue "" gsaLabelContents($label,value,$iSet) 18 \
		"set l \[set gsaLabelContents($label,value,$iSet)\]; SetCursor $mri_tCoordSpace_VolumeIdx \[lindex \$l 0\] \[lindex \$l 1\] \[lindex \$l 2\]"
	} elseif { $label == "kLabel_Coords_Vol_RAS" && $iSet == "cursor" } {
	    tkm_MakeEntry $fwValue "" gsaLabelContents($label,value,$iSet) 18 \
		"set l \[set gsaLabelContents($label,value,$iSet)\]; SetCursor $mri_tCoordSpace_RAS \[lindex \$l 0\] \[lindex \$l 1\] \[lindex \$l 2\]"
	} elseif { $label == "kLabel_Coords_Vol_Tal" && $iSet == "cursor" } {
	    tkm_MakeEntry $fwValue "" gsaLabelContents($label,value,$iSet) 18 \
		"set l \[set gsaLabelContents($label,value,$iSet)\]; SetCursor $mri_tCoordSpace_Talairach \[lindex \$l 0\] \[lindex \$l 1\] \[lindex \$l 2\]"
	} else {
	    tkm_MakeActiveLabel $fwValue "" gsaLabelContents($label,value,$iSet) 18
	}

	pack $fwLabel $fwValue \
	    -side left \
	    -anchor w
    }
    
    ShowLabel kLabel_Coords_Vol_RAS 1
    ShowLabel kLabel_Coords_Vol_Tal 1
    ShowLabel kLabel_Value_Vol 1
}

proc CreateToolBar { ifwToolBar } {

    global gfwaToolBar
    global gTool gViewPreset gDisplayedVolume
    global gbLinkedCursor
    global gBrushInfo DspA_tBrushShape_Square DspA_tBrushShape_Circle
    global gOrientation gnZoomLevel gnVolSlice
    global glActiveFlags gnFlagIndex

    frame $ifwToolBar

    # main toolbar
    set gfwaToolBar(main)  $ifwToolBar.fwMainBar
    set fwTools            $gfwaToolBar(main).fwTools
    set fwViews            $gfwaToolBar(main).fwViews
    set fwSurfaces         $gfwaToolBar(main).fwSurfaces
    set fwVolumeToggles    $gfwaToolBar(main).fwVolumeToggles

    frame $gfwaToolBar(main) -border 2 -relief raised
    
    tkm_MakeToolbar $fwTools \
      1 \
      gTool \
      UpdateToolWrapper { \
      { image 0 icon_navigate "Navigate Tool (n)" } \
      { image 1 icon_edit_label "Select Voxels Tool (s)" } \
      { image 2 icon_edit_volume "Edit Voxels Tool (a)" } \
      { image 3 icon_edit_parc "Edit Segmentation Tool (g)" } \
      { image 4 icon_edit_ctrlpts "Edit Ctrl Pts Tool (c)" } }

    tkm_MakeToolbar $fwViews \
      1 \
      gViewPreset \
      UpdateViewPresetWrapper { \
      { image 0 icon_view_single "Single View" } \
      { image 1 icon_view_multiple "Multiple Views" } \
      { image 2 icon_view_mosaic "Mosaic" } }
    
    tkm_MakeCheckboxes $fwSurfaces h { \
      { image icon_surface_main gbDisplayFlag(flag_MainSurface) \
      "SendDisplayFlagValue flag_MainSurface" "Show Main Surface" } \
      { image icon_surface_original gbDisplayFlag(flag_OriginalSurface) \
      "SendDisplayFlagValue flag_OriginalSurface" \
      "Show Original Surface" } \
      { image icon_surface_pial gbDisplayFlag(flag_CanonicalSurface) \
      "SendDisplayFlagValue flag_CanonicalSurface" \
      "Show Canonical Surface" } }

    tkm_MakeToolbar $fwVolumeToggles \
      1 \
      gbDisplayFlag(flag_AuxVolume) \
      UpdateVolumeToggleWrapper { \
      { image 0 icon_main_volume "Show Main Volume" } \
      { image 1 icon_aux_volume "Show Aux Volume" } }

    pack $fwTools $fwViews $fwSurfaces $fwVolumeToggles \
      -side left \
      -anchor w \
      -padx 5

    # navigation toolbar
    set gfwaToolBar(nav)   $ifwToolBar.fwNavBar
    set fwOrientation      $gfwaToolBar(nav).fwOrientation
    set fwCurSlice         $gfwaToolBar(nav).fwCurSlice
    set fwZoomButtons      $gfwaToolBar(nav).fwZoomButtons
    set fwZoomLevel        $gfwaToolBar(nav).fwZoomLevel
    set fwPoint            $gfwaToolBar(nav).fwPoint
    set fwLinkedCursor     $gfwaToolBar(nav).fwLinkedCursor

    frame $gfwaToolBar(nav) -border 2 -relief raised

    tkm_MakeToolbar $fwOrientation \
      1 \
      gOrientation \
      UpdateOrientationWrapper { \
      { image 0 icon_orientation_coronal "Coronal View" } \
      { image 1 icon_orientation_horizontal "Horizontal View" } \
      { image 2 icon_orientation_sagittal "Sagittal View" } }
    
    tkm_MakeEntryWithIncDecButtons $fwCurSlice "Slice" gnVolSlice \
      { SetSlice $gnVolSlice } 1

    tkm_MakeButtons $fwZoomButtons { \
      { image icon_zoom_out \
      { SetZoomLevelWrapper [expr $gnZoomLevel / 2] } "Zoom Out" } \
      { image icon_zoom_in \
      { SetZoomLevelWrapper [expr $gnZoomLevel * 2] } "Zoom In" } }
    
    tkm_MakeEntryWithIncDecButtons $fwZoomLevel "Zoom" gnZoomLevel \
      { SetZoomLevelWrapper } 1
    
    tkm_MakeButtons $fwPoint { \
      { image icon_cursor_save {SendCursor} "Save Point" } \
      { image icon_cursor_goto {ReadCursor} "Goto Saved Point" } }

    tkm_MakeCheckboxes $fwLinkedCursor h {
  { image icon_linked_cursors gbLinkedCursor \
    "SendLinkedCursorValue" "Link Cursors" } }

    pack $fwOrientation $fwCurSlice $fwZoomButtons $fwZoomLevel \
      $fwPoint $fwLinkedCursor \
      -side left \
      -anchor w \
      -padx 5
      
    # recon toolbar
    set gfwaToolBar(recon) $ifwToolBar.fwBrushBar
    set fwShape            $gfwaToolBar(recon).fwShape
    set fw3D               $gfwaToolBar(recon).fw3D
    set fwRadius           $gfwaToolBar(recon).fwRadius
    set fwSnapshot         $gfwaToolBar(recon).fwSnapshot
    set fwTimer            $gfwaToolBar(recon).fwTimer

    frame $gfwaToolBar(recon) -border 2 -relief raised

    tkm_MakeToolbar $fwShape \
      1 \
      gBrushInfo(shape) \
      UpdateShapeWrapper { \
      { image 0 icon_brush_circle "Circular Brush" } \
      { image 1 icon_brush_square "Square Brush" } }

    tkm_MakeCheckboxes $fw3D h { \
      { image icon_brush_3d gBrushInfo(3d) \
      "SetBrushConfiguration" "Activate 3D Brush" } }

    tkm_MakeEntryWithIncDecButtons $fwRadius "Radius" gBrushInfo(radius) \
      { UpdateBrushConfigurationWrapper } 1

    tkm_MakeButtons $fwSnapshot { \
      { image icon_snapshot_save \
      { SnapshotVolume } "Take Snapshot of Volume" } \
      { image icon_snapshot_load \
      { RestoreVolumeFromSnapshot } "Restore Volume from Snapshot" } }

    tkm_MakeCheckboxes $fwTimer h { \
      { image icon_stopwatch gbTimerOn \
      "SetTimerStatus $gbTimerOn" "Start/Stop TkTimer" } }

    pack $fwShape $fw3D $fwRadius $fwSnapshot $fwTimer \
      -side left \
      -anchor w \
      -padx 5
}

proc ShowToolBar { isWhich ibShow } {

    global gfwaToolBar gbShowToolBar

    if { $ibShow == 1 } {   

  if { [catch { pack $gfwaToolBar($isWhich) \
    -side top \
    -fill x \
    -expand yes \
    -after $gfwaToolBar(main) } sResult] == 1 } {
      
      pack $gfwaToolBar($isWhich) \
        -side top \
        -fill x \
        -expand yes
  }
  
    } else {

  pack forget $gfwaToolBar($isWhich)
    }

    set gbShowToolBar($isWhich) $ibShow
}


proc CreateImages {} {

    global ksImageDir

    foreach image_name { icon_edit_label icon_edit_volume \
      icon_navigate icon_edit_ctrlpts icon_edit_parc \
      icon_view_single icon_view_multiple icon_view_mosaic \
      icon_cursor_goto icon_cursor_save \
      icon_main_volume icon_aux_volume icon_linked_cursors \
      icon_arrow_up icon_arrow_down icon_arrow_left icon_arrow_right \
      icon_arrow_cw icon_arrow_ccw \
      icon_arrow_expand_x icon_arrow_expand_y \
      icon_arrow_shrink_x icon_arrow_shrink_y \
      icon_orientation_coronal icon_orientation_horizontal \
      icon_orientation_sagittal \
      icon_zoom_in icon_zoom_out \
      icon_brush_square icon_brush_circle icon_brush_3d \
      icon_surface_main icon_surface_original icon_surface_pial \
      icon_snapshot_save icon_snapshot_load \
      icon_marker_crosshair icon_marker_diamond \
      icon_stopwatch } {

  if { [catch {image create photo  $image_name -file \
    [ file join $ksImageDir $image_name.gif ]} sResult] != 0 } {
      dputs "Error loading $image_name:"
      dputs $sResult
  }
    }
}

proc UpdateVolumeToggleWrapper { iValue ibStatus } {
    SendDisplayFlagValue flag_AuxVolume
}

proc UpdateOrientationWrapper { iValue ibStatus } {
    if { $ibStatus == 1 } {
  SetOrientation $iValue
    }
}

proc UpdateShapeWrapper { iValue ibStatus } {
    if { $ibStatus == 1 } {
  SetBrushConfiguration
    }
}

proc UpdateBrushConfigurationWrapper { iValue } {
    SetBrushConfiguration
}

proc UpdateCursorInfoWrapper { iValue ibStatus } {
    global gCursor
    if { $ibStatus == 1 } {
  gCursor(shape) = $iValue
  SendCursorConfiguration
    }   
}

proc UpdateToolWrapper { iValue ibStatus } {
    if { $ibStatus == 1 } {
  SetTool $iValue
    }
}

proc UpdateViewPresetWrapper { iValue ibStatus } {
    if { $ibStatus == 1 } {
  SetViewPreset $iValue
    }
}

proc UpdateLinkedCursorWrapper { iValue ibStatus } {
    SetLinkedCursorFlag $iValue
}

proc SetZoomLevelWrapper { inLevel } {
    global gnZoomLevel
    set gnZoomLevel $inLevel
    SetZoomLevel $gnZoomLevel
}


# ================================================================== BAR CHART


# works just by passing it the following arguments:
#   -title <string> : the title of the window and graph
#   -xAxisTitle <string> : the title of the x axis
#   -yAxisTitle <string> : the title of the x axis
#   -label1 <string> : the label in the legend for the first element
#   -label2 <string> : the label in the legend for the second element
#   -values1 <list> : list of values for the first element
#   -values2 <list> : list of values for the second element
#   -xAxisLabels <list> : the list of labels for the x axis
# note that the number of elements in -values1, -values2, and -xAxisLabels
# should be the same.
proc BarChart_Draw { args } {

    global glsXAxisLabels
    global kNormalFont

    # default values
    set tArgs(-title) ""
    set tArgs(-xAxisTitle) ""
    set tArgs(-yAxisTitle) ""
    set tArgs(-xAxisLabels) ""
    set tArgs(-label1) ""
    set tArgs(-label2) ""
    set tArgs(-values1) ""
    set tArgs(-values2) ""

    # get the params
    array set tArgs $args
    
    # find an unused window name.
    set nSuffix 0
    set wwChartWindow .bcw0
#    while { [winfo exists $wwChartWindow] } {
#  incr nSuffix
#  set wwChartWindow .bcw$nSuffix
#    }


    # if the window doesn't exist already, make it.
    set bcw $wwChartWindow.bcw
    if { [winfo exists $wwChartWindow] == 0 } {

	# create window and set its size.
	toplevel $wwChartWindow
	wm geometry $wwChartWindow 600x800
	
	# create the chart. configure the x axis to call BarChart_GetXLabel
	# to get its labels. create two empty elements.
	blt::barchart $bcw -barmode aligned
	pack $bcw -expand true -fill both
	$bcw axis configure x \
	    -command { BarChart_GetXLabel } \
	    -rotate 90 \
	    -tickfont $kNormalFont
	$bcw element create V1
	$bcw element create V2
    }

    # set the window and chart title.
    wm title $wwChartWindow $tArgs(-title)
    $bcw config -title $tArgs(-title)
    
    # set the x axis labels.
    set glsXAxisLabels($bcw) $tArgs(-xAxisLabels)

    # set the label titles.
    $bcw axis config x -title $tArgs(-xAxisTitle)
    $bcw axis config y -title $tArgs(-yAxisTitle)
    
    # create a vector of indices for the elements. these are used
    # as indices into the x axis labels list.
    blt::vector vX
    vX seq 1 [llength $glsXAxisLabels($bcw)]

    # set the data in the two elements.
    $bcw element config V1 -label $tArgs(-label1) \
      -ydata $tArgs(-values1) -xdata vX -fg blue -bg blue
    $bcw element config V2 -label $tArgs(-label2) \
      -ydata $tArgs(-values2) -xdata vX -fg red -bg red
}


proc BarChart_GetXLabel { iwwTop ifValue } {

    global glsXAxisLabels

    if { [info exists glsXAxisLabels($iwwTop)] == 0 } {
  puts "error: labels for $iwwTop don't exist"
  return $ifValue
    }

    set nIndex [expr round($ifValue)]
    incr nIndex -1
    set sName [lindex $glsXAxisLabels($iwwTop) $nIndex]
    return $sName
}

# ================================================================== FUNCTIONS

proc AllowSaveThenQuit {} {
    global gbVolumeDirty

    if { $gbVolumeDirty } {
	DoAskSaveChangesDlog;
    } else {
	QuitMedit;
    }
}

proc SaveRGBSeries { isPrefix inBegin inEnd } {

    global gnVolX gnVolY gnVolZ gOrientation
    global mri_tOrientation_Sagittal mri_tOrientation_Horizontal 
    global mri_tOrientation_Coronal
    global mri_tCoordSpace_VolumeIdx

    dputs "SaveRGBSeries $isPrefix $inBegin $inEnd"

    # determine which way we're going
    if { $inBegin < $inEnd } {
  set nIncr 1 
    } else {
  set nIncr -1
    }

    set nX $gnVolX 
    set nY $gnVolY
    set nZ $gnVolZ
    for { set nSlice $inBegin } { $nSlice <= $inEnd } { incr nSlice $nIncr } {
  
  switch $gOrientation {
      2 { set nX $nSlice }
      1 { set nY $nSlice }
      0 { set nZ $nSlice }
  }

  SetCursor $mri_tCoordSpace_VolumeIdx $nX $nY $nZ
  RedrawScreen
  SaveRGB $isPrefix[format "%03d" $nSlice].rgb
    }
}

proc ErrorDlog { isMsg } {

    global gwwTop

    tk_messageBox -type ok \
      -icon error \
      -message $isMsg \
      -title "Error" \
      -parent $gwwTop
}

proc FormattedErrorDlog { isTitle isMsg isDesc } {

    global gDialog
    global kLabelFont kNormalFont kSmallFont

    set wwDialog .wwFormattedErrorDlog

    # try to create the dlog...
    if { [Dialog_Create $wwDialog "Error" {-borderwidth 10}] } {

  set fwText       $wwDialog.fwText
  set fwButtons    $wwDialog.fwButtons

  text $fwText -width 40 \
    -height 10 \
    -spacing3 10 \
    -relief flat \
    -wrap word
  $fwText insert end "Error: $isTitle \n" {tTitle}
  $fwText insert end "$isMsg \n" {tMsg}
  $fwText insert end "$isDesc \n" {tDesc}
  $fwText tag configure tTitle -font $kLabelFont
  $fwText tag configure tMsg -font $kNormalFont
  $fwText tag configure tDesc -font $kNormalFont
  $fwText configure -state disabled

  # button.
  tkm_MakeCloseButton $fwButtons $wwDialog

  pack $fwText $fwButtons \
    -side top       \
    -expand yes     \
    -fill x         \
    -padx 5         \
    -pady 5
    }

}

proc AlertDlog { isMsg } {

    global gwwTop

    tk_messageBox -type ok \
      -icon info \
      -message $isMsg \
      -title "Note" \
      -parent $gwwTop
}

# ======================================================================= MAIN

CreateImages

# build the window
set wwTop        .w
set fwMenuBar    $wwTop.fwMenuBar
set fwToolBar    $wwTop.fwToolBar
set fwLeft       $wwTop.fwLeft
set fwRight      $wwTop.fwRight
set fwCursor     $fwLeft.fwCursor

CreateWindow         $wwTop
MakeKeyBindings      .

frame $fwLeft

CreateMenuBar        $fwMenuBar
CreateToolBar        $fwToolBar
CreateCursorFrame    $fwCursor
CreateMouseoverFrame $fwRight

# pack the window
pack $fwMenuBar $fwToolBar \
  -side top    \
  -expand true \
  -fill x      \
  -anchor w

pack $fwCursor \
  -side top         \
  -expand true      \
  -fill x           \
  -anchor nw

pack $fwLeft $fwRight \
  -side left    \
  -padx 3       \
  -pady 3       \
  -expand true  \
  -fill x       \
  -fill y       \
  -anchor nw

pack $wwTop

# start out with the main bar enabled
    ShowToolBar main 1
    ShowToolBar nav 1

# look for environment variable settings to automatically show toolbars
foreach toolbar {main nav recon} {
    catch {
  if { $env(TKMEDIT_TOOLBAR_[string toupper $toolbar]) == 1 } {
      ShowToolBar $toolbar 1
  }
  if { $env(TKMEDIT_TOOLBAR_[string toupper $toolbar]) == 0 } {
      ShowToolBar $toolbar 0
  }
    }
}


# lets us execute scripts from the command line but only after the
# window is open
after idle { catch { ExecuteQueuedScripts } }

dputs "Successfully parsed tkmedit.tcl"

