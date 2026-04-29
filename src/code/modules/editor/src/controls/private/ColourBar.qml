import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui

ColumnLayout
{
    id: control

    spacing: 0

    property string currentMode : ""
    property string currentSection : ""
    property string currentControl : ""
    property string activePreset : ""
    readonly property var presetItems : [
        { key: "noir", text: i18nd("mauikitimagetools", "Noir") },
        { key: "mono", text: i18nd("mauikitimagetools", "Mono") },
        { key: "focus", text: i18nd("mauikitimagetools", "Focus") },
        { key: "luna", text: i18nd("mauikitimagetools", "Luna") },
        { key: "valencia", text: i18nd("mauikitimagetools", "Valencia") },
        { key: "juno", text: i18nd("mauikitimagetools", "Juno") },
        { key: "gingham", text: i18nd("mauikitimagetools", "Gingham") },
        { key: "lark", text: i18nd("mauikitimagetools", "Lark") },
        { key: "aden", text: i18nd("mauikitimagetools", "Aden") }
    ]

    function controlsForSection(section)
    {
        switch (section)
        {
        case "lighting":
            return [
                { key: "exposure", text: i18nd("mauikitimagetools", "Exposure"), from: -100, to: 100, stepSize: 1 },
                { key: "brilliance", text: i18nd("mauikitimagetools", "Brilliance"), from: -100, to: 100, stepSize: 1 },
                { key: "highlights", text: i18nd("mauikitimagetools", "Highlights"), from: -100, to: 100, stepSize: 1 },
                { key: "shadows", text: i18nd("mauikitimagetools", "Shadows"), from: -100, to: 100, stepSize: 1 },
                { key: "brightness", text: i18nd("mauikitimagetools", "Brightness"), from: -255, to: 255, stepSize: 1 },
                { key: "contrast", text: i18nd("mauikitimagetools", "Contrast"), from: -100, to: 100, stepSize: 1 },
                { key: "blackPoint", text: i18nd("mauikitimagetools", "Black Point"), from: -100, to: 100, stepSize: 1 }
            ]
        case "color":
            return [
                { key: "saturation", text: i18nd("mauikitimagetools", "Saturation"), from: -100, to: 100, stepSize: 1 },
                { key: "vibrance", text: i18nd("mauikitimagetools", "Vibrance"), from: -100, to: 100, stepSize: 1 },
                { key: "warmth", text: i18nd("mauikitimagetools", "Warmth"), from: -100, to: 100, stepSize: 1 },
                { key: "tint", text: i18nd("mauikitimagetools", "Tint"), from: -100, to: 100, stepSize: 1 }
            ]
        case "refinement":
            return [
                { key: "sharpness", text: i18nd("mauikitimagetools", "Sharpness"), from: 0, to: 100, stepSize: 1 },
                { key: "definition", text: i18nd("mauikitimagetools", "Definition"), from: 0, to: 100, stepSize: 1 },
                { key: "noiseReduction", text: i18nd("mauikitimagetools", "Noise Reduction"), from: 0, to: 100, stepSize: 1 },
                { key: "vignette", text: i18nd("mauikitimagetools", "Vignette"), from: -100, to: 100, stepSize: 1 }
            ]
        default:
            return []
        }
    }

    function defaultControlForSection(section)
    {
        const controls = controlsForSection(section)
        return controls.length ? controls[0].key : ""
    }

    function currentControlSpec()
    {
        if (!currentControl)
            return null

        const controls = controlsForSection(currentSection)
        for (let i = 0; i < controls.length; ++i)
        {
            if (controls[i].key === currentControl)
                return controls[i]
        }

        return null
    }

    function adjustmentValue(key)
    {
        switch (key)
        {
        case "exposure":
            return editor.exposure
        case "brilliance":
            return editor.brilliance
        case "highlights":
            return editor.highlights
        case "shadows":
            return editor.shadows
        case "brightness":
            return editor.brightness
        case "contrast":
            return editor.contrast
        case "blackPoint":
            return editor.blackPoint
        case "saturation":
            return editor.saturation
        case "vibrance":
            return editor.vibrance
        case "warmth":
            return editor.warmth
        case "tint":
            return editor.tint
        case "sharpness":
            return editor.sharpness
        case "definition":
            return editor.definition
        case "noiseReduction":
            return editor.noiseReduction
        case "vignette":
            return editor.vignette
        default:
            return 0
        }
    }

    function setAdjustmentValue(key, value)
    {
        activePreset = ""

        switch (key)
        {
        case "exposure":
            editor.adjustExposure(Math.round(value))
            break
        case "brilliance":
            editor.adjustBrilliance(Math.round(value))
            break
        case "highlights":
            editor.adjustHighlights(Math.round(value))
            break
        case "shadows":
            editor.adjustShadows(Math.round(value))
            break
        case "brightness":
            editor.adjustBrightness(Math.round(value))
            break
        case "contrast":
            editor.adjustContrast(Math.round(value))
            break
        case "blackPoint":
            editor.adjustBlackPoint(Math.round(value))
            break
        case "saturation":
            editor.adjustSaturation(Math.round(value))
            break
        case "vibrance":
            editor.adjustVibrance(Math.round(value))
            break
        case "warmth":
            editor.adjustWarmth(Math.round(value))
            break
        case "tint":
            editor.adjustTint(Math.round(value))
            break
        case "sharpness":
            editor.adjustSharpness(Math.round(value))
            break
        case "definition":
            editor.adjustDefinition(Math.round(value))
            break
        case "noiseReduction":
            editor.adjustNoiseReduction(Math.round(value))
            break
        case "vignette":
            editor.adjustVignette(Math.round(value))
            break
        }
    }

    function commitPendingAdjustment()
    {
        if (!editor.changesApplied)
            editor.applyChanges()
    }

    function setMode(mode)
    {
        if (currentMode === mode)
        {
            currentMode = ""
            currentSection = ""
            currentControl = ""
            activePreset = ""
            return
        }

        commitPendingAdjustment()
        currentMode = mode
        currentSection = ""
        currentControl = ""

        if (mode !== "presets")
            activePreset = ""
    }

    function selectSection(section)
    {
        if (currentMode !== "manual")
            return

        if (section === currentSection)
        {
            commitPendingAdjustment()
            currentSection = ""
            currentControl = ""
            return
        }

        commitPendingAdjustment()
        currentSection = section
        currentControl = ""
    }

    function selectControl(controlKey)
    {
        if (currentMode !== "manual")
            return

        if (controlKey === currentControl)
        {
            commitPendingAdjustment()
            currentControl = ""
            return
        }

        commitPendingAdjustment()
        currentControl = controlKey
    }

    function applyPreset(presetKey)
    {
        if (currentMode !== "presets")
            currentMode = "presets"

        commitPendingAdjustment()
        activePreset = presetKey
        editor.applyColorPreset(presetKey)
    }

    Maui.ToolBar
    {
        id: _operationsToolBar
        Layout.fillWidth: true
        visible: control.currentMode === "manual"
        middleContent: Row
        {
            Layout.alignment: Qt.AlignHCenter
            spacing: Maui.Style.defaultSpacing

            Repeater
            {
                model: [
                    { key: "lighting", text: i18nd("mauikitimagetools", "Lighting") },
                    { key: "color", text: i18nd("mauikitimagetools", "Color") },
                    { key: "refinement", text: i18nd("mauikitimagetools", "Refinement") }
                ]

                Button
                {
                    highlighted: control.currentSection === modelData.key
                    text: modelData.text
                    onClicked: control.selectSection(modelData.key)
                }
            }
        }
        background: Rectangle
        {
            color: Maui.Theme.backgroundColor
        }
    }

    Maui.ToolBar
    {
        id: _controlsToolBar
        Layout.fillWidth: true
        visible: control.currentMode === "manual" && control.currentSection.length > 0
        middleContent: Row
        {
            Layout.alignment: Qt.AlignHCenter
            spacing: Maui.Style.defaultSpacing

            Repeater
            {
                model: control.controlsForSection(control.currentSection)

                Button
                {
                    highlighted: control.currentControl === modelData.key
                    text: modelData.text
                    onClicked: control.selectControl(modelData.key)
                }
            }
        }
        background: Rectangle
        {
            color: Maui.Theme.backgroundColor
        }
    }

    Maui.ToolBar
    {
        id: _sliderToolBar
        Layout.fillWidth: true
        visible: control.currentMode === "manual" && control.currentControl.length > 0
        middleContent: Ruler
        {
            Layout.fillWidth: true

            readonly property var spec: control.currentControlSpec()

            enabled: !!spec
            from: spec ? spec.from : 0
            to: spec ? spec.to : 0
            stepSize: spec ? spec.stepSize : 1
            value: spec ? control.adjustmentValue(spec.key) : 0

            onMoved:
            {
                if (spec)
                    control.setAdjustmentValue(spec.key, value)
            }
        }
        background: Rectangle
        {
            color: Maui.Theme.backgroundColor
        }
    }

    Maui.ToolBar
    {
        id: _presetsToolBar
        Layout.fillWidth: true
        visible: control.currentMode === "presets"
        middleContent: Row
        {
            Layout.alignment: Qt.AlignHCenter
            spacing: Maui.Style.defaultSpacing

            Repeater
            {
                model: control.presetItems

                Button
                {
                    highlighted: control.activePreset === modelData.key
                    text: modelData.text
                    onClicked: control.applyPreset(modelData.key)
                }
            }
        }
        background: Rectangle
        {
            color: Maui.Theme.backgroundColor
            opacity: 0.82
        }
    }
}
