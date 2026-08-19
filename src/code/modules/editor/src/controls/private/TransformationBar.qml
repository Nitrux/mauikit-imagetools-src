import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui

ScrollView
{
    id: control

    property alias rotationSlider: _straightenSlider
    property var editor: null
    property int appliedValue: 0
    clip: true
    padding: Maui.Style.contentMargins
    leftPadding: Maui.Style.contentMargins
    rightPadding: Maui.Style.contentMargins
    contentWidth: availableWidth

    readonly property var presetKeys: [
        "noir", "mono", "focus", "luna", "valencia",
        "juno", "gingham", "lark", "aden"
    ]

    function adjustmentValue(key)
    {
        if (!editor)
            return 0

        switch (key)
        {
        case "exposure": return editor.exposure
        case "brilliance": return editor.brilliance
        case "highlights": return editor.highlights
        case "shadows": return editor.shadows
        case "brightness": return editor.brightness
        case "contrast": return editor.contrast
        case "blackPoint": return editor.blackPoint
        case "saturation": return editor.saturation
        case "vibrance": return editor.vibrance
        case "warmth": return editor.warmth
        case "tint": return editor.tint
        case "hue": return editor.hue
        case "gamma": return editor.gamma
        case "sharpness": return editor.sharpness
        case "definition": return editor.definition
        case "noiseReduction": return editor.noiseReduction
        case "vignette": return editor.vignette
        case "threshold": return editor.threshold
        case "gaussianBlur": return editor.gaussianBlur
        default: return 0
        }
    }

    function setAdjustmentValue(key, value)
    {
        if (!editor)
            return

        const nextValue = Math.round(value)

        switch (key)
        {
        case "exposure": editor.adjustExposure(nextValue); break
        case "brilliance": editor.adjustBrilliance(nextValue); break
        case "highlights": editor.adjustHighlights(nextValue); break
        case "shadows": editor.adjustShadows(nextValue); break
        case "brightness": editor.adjustBrightness(nextValue); break
        case "contrast": editor.adjustContrast(nextValue); break
        case "blackPoint": editor.adjustBlackPoint(nextValue); break
        case "saturation": editor.adjustSaturation(nextValue); break
        case "vibrance": editor.adjustVibrance(nextValue); break
        case "warmth": editor.adjustWarmth(nextValue); break
        case "tint": editor.adjustTint(nextValue); break
        case "hue": editor.adjustHue(nextValue); break
        case "gamma": editor.adjustGamma(nextValue); break
        case "sharpness": editor.adjustSharpness(nextValue); break
        case "definition": editor.adjustDefinition(nextValue); break
        case "noiseReduction": editor.adjustNoiseReduction(nextValue); break
        case "vignette": editor.adjustVignette(nextValue); break
        case "threshold": editor.adjustThreshold(nextValue); break
        case "gaussianBlur": editor.adjustGaussianBlur(nextValue); break
        }
    }

    Connections
    {
        target: control.editor

        function onImageChanged()
        {
            if (!_presetComboBox.applyingPreset)
                _presetComboBox.currentIndex = -1

            if (!_grayscaleSwitch.applyingEffect)
            {
                _grayscaleSwitch.effectApplied = false
                _grayscaleSwitch.checked = false
            }

            if (!_blackWhiteSwitch.applyingEffect)
            {
                _blackWhiteSwitch.effectApplied = false
                _blackWhiteSwitch.checked = false
            }

            if (!_borderSpinBox.applyingBorder)
                _borderSpinBox.value = 0
        }

        function onStraightenChanged()
        {
            if (!_straightenSlider.pressed)
                _straightenSlider.value = control.editor.straighten
        }

        function onHorizontalChanged()
        {
            if (!_horizontalSlider.pressed)
                _horizontalSlider.value = control.editor.horizontal
        }

        function onVerticalChanged()
        {
            if (!_verticalSlider.pressed)
                _verticalSlider.value = control.editor.vertical
        }
    }

    ColumnLayout
    {
        id: _content
        width: control.availableWidth
        spacing: Maui.Style.space.medium

        Maui.SectionGroup
        {
            Layout.fillWidth: true
            template.visible: false

            Maui.SectionHeader
            {
                Layout.fillWidth: true
                text1: i18nd("mauikitimagetools", "Transform")
                text2: i18nd("mauikitimagetools", "Change the image perspective")
            }
            background: Rectangle
            {
                color: Maui.Theme.backgroundColor
                radius: Maui.Style.radiusV
                border.color: Maui.Theme.alternateBackgroundColor
            }

            Maui.FlexSectionItem
            {
                label1.text: i18nd("mauikitimagetools", "Straighten")
                label2.text: i18nd("mauikitimagetools", "Rotate the image to level it")

                Slider
                {
                    id: _straightenSlider
                    Layout.fillWidth: true
                    Layout.minimumWidth: Maui.Style.units.gridUnit * 10
                    Layout.maximumWidth: Maui.Style.units.gridUnit * 20
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    from: -45
                    to: 45
                    stepSize: 1
                    value: editor ? editor.straighten : 0
                    snapMode: Slider.SnapAlways
                    property bool committingTransform: false

                    onPressedChanged:
                    {
                        if (pressed || committingTransform)
                            return

                        const angle = Math.round(value)
                        committingTransform = true
                        editor.transform(0, angle)
                        value = editor.straighten
                        committingTransform = false
                    }
                }

                ToolButton
                {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    text: Math.round(_straightenSlider.value)
                    display: ToolButton.TextOnly
                    font.bold: true
                    font.pointSize: Maui.Style.fontSizes.small
                    onClicked: {}
                    background: Rectangle
                    {
                        color: Maui.Theme.alternateBackgroundColor
                        radius: Maui.Style.radiusV
                    }
                }
            }

            Maui.FlexSectionItem
            {
                label1.text: i18nd("mauikitimagetools", "Horizontal")
                label2.text: i18nd("mauikitimagetools", "Adjust the horizontal perspective")

                Slider
                {
                    id: _horizontalSlider
                    Layout.fillWidth: true
                    Layout.minimumWidth: Maui.Style.units.gridUnit * 10
                    Layout.maximumWidth: Maui.Style.units.gridUnit * 20
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    from: -45
                    to: 45
                    stepSize: 1
                    value: editor ? editor.horizontal : 0
                    snapMode: Slider.SnapAlways
                    property bool committingTransform: false

                    onPressedChanged:
                    {
                        if (pressed || committingTransform)
                            return

                        const angle = Math.round(value)
                        committingTransform = true
                        editor.transform(1, angle)
                        value = editor.horizontal
                        committingTransform = false
                    }
                }

                ToolButton
                {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    text: Math.round(_horizontalSlider.value)
                    display: ToolButton.TextOnly
                    font.bold: true
                    font.pointSize: Maui.Style.fontSizes.small
                    onClicked: {}
                    background: Rectangle
                    {
                        color: Maui.Theme.alternateBackgroundColor
                        radius: Maui.Style.radiusV
                    }
                }
            }

            Maui.FlexSectionItem
            {
                label1.text: i18nd("mauikitimagetools", "Vertical")
                label2.text: i18nd("mauikitimagetools", "Adjust the vertical perspective")

                Slider
                {
                    id: _verticalSlider
                    Layout.fillWidth: true
                    Layout.minimumWidth: Maui.Style.units.gridUnit * 10
                    Layout.maximumWidth: Maui.Style.units.gridUnit * 20
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    from: -45
                    to: 45
                    stepSize: 1
                    value: editor ? editor.vertical : 0
                    snapMode: Slider.SnapAlways
                    property bool committingTransform: false

                    onPressedChanged:
                    {
                        if (pressed || committingTransform)
                            return

                        const angle = Math.round(value)
                        committingTransform = true
                        editor.transform(2, angle)
                        value = editor.vertical
                        committingTransform = false
                    }
                }

                ToolButton
                {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    text: Math.round(_verticalSlider.value)
                    display: ToolButton.TextOnly
                    font.bold: true
                    font.pointSize: Maui.Style.fontSizes.small
                    onClicked: {}
                    background: Rectangle
                    {
                        color: Maui.Theme.alternateBackgroundColor
                        radius: Maui.Style.radiusV
                    }
                }
            }
        }

        Maui.SectionGroup
        {
            Layout.fillWidth: true
            template.visible: false

            Maui.SectionHeader
            {
                Layout.fillWidth: true
                text1: i18nd("mauikitimagetools", "Lighting")
                text2: i18nd("mauikitimagetools", "Adjust the light and tonal range")
            }
            background: Rectangle
            {
                color: Maui.Theme.backgroundColor
                radius: Maui.Style.radiusV
                border.color: Maui.Theme.alternateBackgroundColor
            }

            Repeater
            {
                model: [
                    { key: "exposure", title: i18nd("mauikitimagetools", "Exposure"), description: i18nd("mauikitimagetools", "Adjust the overall lightness"), from: -100, to: 100 },
                    { key: "brilliance", title: i18nd("mauikitimagetools", "Brilliance"), description: i18nd("mauikitimagetools", "Recover detail and light"), from: -100, to: 100 },
                    { key: "highlights", title: i18nd("mauikitimagetools", "Highlights"), description: i18nd("mauikitimagetools", "Adjust the brightest areas"), from: -100, to: 100 },
                    { key: "shadows", title: i18nd("mauikitimagetools", "Shadows"), description: i18nd("mauikitimagetools", "Adjust the darkest areas"), from: -100, to: 100 },
                    { key: "brightness", title: i18nd("mauikitimagetools", "Brightness"), description: i18nd("mauikitimagetools", "Adjust the image brightness"), from: -255, to: 255 },
                    { key: "contrast", title: i18nd("mauikitimagetools", "Contrast"), description: i18nd("mauikitimagetools", "Adjust the difference between light and dark"), from: -100, to: 100 },
                    { key: "blackPoint", title: i18nd("mauikitimagetools", "Black Point"), description: i18nd("mauikitimagetools", "Set the darkest image values"), from: -100, to: 100 }
                ]

                delegate: Maui.FlexSectionItem
                {
                    required property var modelData
                    label1.text: modelData.title
                    label2.text: modelData.description

                    Slider
                    {
                        id: _adjustmentSlider
                        Layout.fillWidth: true
                        Layout.minimumWidth: Maui.Style.units.gridUnit * 10
                        Layout.maximumWidth: Maui.Style.units.gridUnit * 20
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        from: modelData.from
                        to: modelData.to
                        stepSize: 1
                        value: control.adjustmentValue(modelData.key)
                        snapMode: Slider.SnapAlways
                        onValueChanged:
                        {
                            if (pressed)
                                control.setAdjustmentValue(modelData.key, value)
                        }
                    }
                    ToolButton
                {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    text: Math.round(_adjustmentSlider.value)
                    display: ToolButton.TextOnly
                    font.bold: true
                    font.pointSize: Maui.Style.fontSizes.small
                    onClicked: {}
                    background: Rectangle
                    {
                        color: Maui.Theme.alternateBackgroundColor
                        radius: Maui.Style.radiusV
                    }
                }
                }
            }
        }

        Maui.SectionGroup
        {
            Layout.fillWidth: true
            template.visible: false

            Maui.SectionHeader
            {
                Layout.fillWidth: true
                text1: i18nd("mauikitimagetools", "Color")
                text2: i18nd("mauikitimagetools", "Adjust color and tone")
            }
            background: Rectangle
            {
                color: Maui.Theme.backgroundColor
                radius: Maui.Style.radiusV
                border.color: Maui.Theme.alternateBackgroundColor
            }

            Repeater
            {
                model: [
                    { key: "saturation", title: i18nd("mauikitimagetools", "Saturation"), description: i18nd("mauikitimagetools", "Adjust color intensity"), from: -100, to: 100 },
                    { key: "vibrance", title: i18nd("mauikitimagetools", "Vibrance"), description: i18nd("mauikitimagetools", "Adjust muted color intensity"), from: -100, to: 100 },
                    { key: "warmth", title: i18nd("mauikitimagetools", "Warmth"), description: i18nd("mauikitimagetools", "Adjust the warm or cool tone"), from: -100, to: 100 },
                    { key: "tint", title: i18nd("mauikitimagetools", "Tint"), description: i18nd("mauikitimagetools", "Adjust the green and magenta balance"), from: -100, to: 100 },
                    { key: "hue", title: i18nd("mauikitimagetools", "Hue"), description: i18nd("mauikitimagetools", "Shift the color hue"), from: 0, to: 180 },
                    { key: "gamma", title: i18nd("mauikitimagetools", "Gamma"), description: i18nd("mauikitimagetools", "Adjust midtone luminance"), from: -100, to: 100 }
                ]

                delegate: Maui.FlexSectionItem
                {
                    required property var modelData
                    label1.text: modelData.title
                    label2.text: modelData.description

                    Slider
                    {
                        id: _adjustmentSlider
                        Layout.fillWidth: true
                        Layout.minimumWidth: Maui.Style.units.gridUnit * 10
                        Layout.maximumWidth: Maui.Style.units.gridUnit * 20
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        from: modelData.from
                        to: modelData.to
                        stepSize: 1
                        value: control.adjustmentValue(modelData.key)
                        snapMode: Slider.SnapAlways
                        onValueChanged:
                        {
                            if (pressed)
                                control.setAdjustmentValue(modelData.key, value)
                        }
                    }
                    ToolButton
                {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    text: Math.round(_adjustmentSlider.value)
                    display: ToolButton.TextOnly
                    font.bold: true
                    font.pointSize: Maui.Style.fontSizes.small
                    onClicked: {}
                    background: Rectangle
                    {
                        color: Maui.Theme.alternateBackgroundColor
                        radius: Maui.Style.radiusV
                    }
                }
                }
            }

            Maui.FlexSectionItem
            {
                label1.text: i18nd("mauikitimagetools", "Color Preset")
                label2.text: i18nd("mauikitimagetools", "Apply a predefined color treatment")

                ComboBox
                {
                    id: _presetComboBox
                    property bool applyingPreset: false
                    Layout.fillWidth: true
                    Layout.preferredWidth: Maui.Style.units.gridUnit * 20 + Maui.Style.space.small + Maui.Style.units.gridUnit * 4
                    Layout.maximumWidth: Layout.preferredWidth
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                    currentIndex: -1
                    displayText: currentIndex < 0 ? i18nd("mauikitimagetools", "Select a color preset") : currentText
                    model: [
                        i18nd("mauikitimagetools", "Noir"),
                        i18nd("mauikitimagetools", "Mono"),
                        i18nd("mauikitimagetools", "Focus"),
                        i18nd("mauikitimagetools", "Luna"),
                        i18nd("mauikitimagetools", "Valencia"),
                        i18nd("mauikitimagetools", "Juno"),
                        i18nd("mauikitimagetools", "Gingham"),
                        i18nd("mauikitimagetools", "Lark"),
                        i18nd("mauikitimagetools", "Aden")
                    ]
                    onActivated: function(index)
                    {
                        applyingPreset = true
                        editor.applyColorPreset(control.presetKeys[index])
                        applyingPreset = false
                    }
                }
            }
        }

        Maui.SectionGroup
        {
            Layout.fillWidth: true
            template.visible: false

            Maui.SectionHeader
            {
                Layout.fillWidth: true
                text1: i18nd("mauikitimagetools", "Detail")
                text2: i18nd("mauikitimagetools", "Refine image definition and edges")
            }
            background: Rectangle
            {
                color: Maui.Theme.backgroundColor
                radius: Maui.Style.radiusV
                border.color: Maui.Theme.alternateBackgroundColor
            }

            Repeater
            {
                model: [
                    { key: "sharpness", title: i18nd("mauikitimagetools", "Sharpness"), description: i18nd("mauikitimagetools", "Enhance edge definition"), from: 0, to: 100 },
                    { key: "definition", title: i18nd("mauikitimagetools", "Definition"), description: i18nd("mauikitimagetools", "Enhance fine image detail"), from: 0, to: 100 },
                    { key: "noiseReduction", title: i18nd("mauikitimagetools", "Noise Reduction"), description: i18nd("mauikitimagetools", "Reduce image noise"), from: 0, to: 100 },
                    { key: "vignette", title: i18nd("mauikitimagetools", "Vignette"), description: i18nd("mauikitimagetools", "Darken or lighten the edges"), from: -100, to: 100 },
                    { key: "threshold", title: i18nd("mauikitimagetools", "Threshold"), description: i18nd("mauikitimagetools", "Set the black and white threshold"), from: 0, to: 180 },
                    { key: "gaussianBlur", title: i18nd("mauikitimagetools", "Gaussian Blur"), description: i18nd("mauikitimagetools", "Soften the image"), from: 0, to: 100 }
                ]

                delegate: Maui.FlexSectionItem
                {
                    required property var modelData
                    label1.text: modelData.title
                    label2.text: modelData.description

                    Slider
                    {
                        id: _adjustmentSlider
                        Layout.fillWidth: true
                        Layout.minimumWidth: Maui.Style.units.gridUnit * 10
                        Layout.maximumWidth: Maui.Style.units.gridUnit * 20
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        from: modelData.from
                        to: modelData.to
                        stepSize: 1
                        value: control.adjustmentValue(modelData.key)
                        snapMode: Slider.SnapAlways
                        onValueChanged:
                        {
                            if (pressed)
                                control.setAdjustmentValue(modelData.key, value)
                        }
                    }
                    ToolButton
                {
                    Layout.alignment: Qt.AlignVCenter | Qt.AlignRight
                    text: Math.round(_adjustmentSlider.value)
                    display: ToolButton.TextOnly
                    font.bold: true
                    font.pointSize: Maui.Style.fontSizes.small
                    onClicked: {}
                    background: Rectangle
                    {
                        color: Maui.Theme.alternateBackgroundColor
                        radius: Maui.Style.radiusV
                    }
                }
                }
            }
        }

        Maui.SectionGroup
        {
            Layout.fillWidth: true
            template.visible: false

            Maui.SectionHeader
            {
                Layout.fillWidth: true
                text1: i18nd("mauikitimagetools", "Effects")
                text2: i18nd("mauikitimagetools", "Additional image effects")
            }
            background: Rectangle
            {
                color: Maui.Theme.backgroundColor
                radius: Maui.Style.radiusV
                border.color: Maui.Theme.alternateBackgroundColor
            }

            Maui.FlexSectionItem
            {
                label1.text: i18nd("mauikitimagetools", "Grayscale")
                label2.text: i18nd("mauikitimagetools", "Convert the image to grayscale")

                Switch
                {
                    id: _grayscaleSwitch
                    property bool effectApplied: false
                    property bool applyingEffect: false
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    onClicked:
                    {
                        if (checked)
                        {
                            applyingEffect = true
                            editor.toGray()
                            applyingEffect = false
                            effectApplied = true
                        }
                        else if (!checked && effectApplied)
                        {
                            applyingEffect = true
                            editor.undo()
                            applyingEffect = false
                            effectApplied = false
                        }
                    }
                }
            }

            Maui.FlexSectionItem
            {
                label1.text: i18nd("mauikitimagetools", "Black and White")
                label2.text: i18nd("mauikitimagetools", "Convert the image to black and white")

                Switch
                {
                    id: _blackWhiteSwitch
                    property bool effectApplied: false
                    property bool applyingEffect: false
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    onClicked:
                    {
                        if (checked)
                        {
                            applyingEffect = true
                            editor.toBW()
                            applyingEffect = false
                            effectApplied = true
                        }
                        else if (!checked && effectApplied)
                        {
                            applyingEffect = true
                            editor.undo()
                            applyingEffect = false
                            effectApplied = false
                        }
                    }
                }
            }

            Maui.FlexSectionItem
            {
                label1.text: i18nd("mauikitimagetools", "Border")
                label2.text: i18nd("mauikitimagetools", "Add a border around the image")

                SpinBox
                {
                    id: _borderSpinBox
                    property bool applyingBorder: false
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.preferredWidth: Maui.Style.units.gridUnit * 6
                    from: 0
                    to: 100
                    value: 0
                    onValueModified:
                    {
                        applyingBorder = true
                        editor.addBorder(value, Maui.Theme.textColor)
                        applyingBorder = false
                    }
                }
            }
        }
    }
}