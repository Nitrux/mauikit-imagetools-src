import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui

ScrollView
{
    id: control

    property alias rotationSlider: _straightenSlider
    property int appliedValue: 0
    clip: true
    contentWidth: availableWidth

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
                    value: 0
                    snapMode: Slider.SnapAlways
                    property int appliedValue: 0

                    onMoved:
                    {
                        const nextValue = Math.round(_straightenSlider.value)
                        const delta = nextValue - appliedValue
                        if (delta === 0)
                            return

                        imageDoc.transform(0, delta)
                        appliedValue = nextValue
                    }

                    onPressedChanged:
                    {
                        if (!pressed)
                        {
                            value = 0
                            appliedValue = 0
                        }
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
                    value: 0
                    snapMode: Slider.SnapAlways
                    property int appliedValue: 0

                    onMoved:
                    {
                        const nextValue = Math.round(value)
                        const delta = nextValue - appliedValue
                        if (delta === 0)
                            return

                        imageDoc.transform(1, delta)
                        appliedValue = nextValue
                    }

                    onPressedChanged:
                    {
                        if (!pressed)
                        {
                            value = 0
                            appliedValue = 0
                        }
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
                    value: 0
                    snapMode: Slider.SnapAlways
                    property int appliedValue: 0

                    onMoved:
                    {
                        const nextValue = Math.round(value)
                        const delta = nextValue - appliedValue
                        if (delta === 0)
                            return

                        imageDoc.transform(2, delta)
                        appliedValue = nextValue
                    }

                    onPressedChanged:
                    {
                        if (!pressed)
                        {
                            value = 0
                            appliedValue = 0
                        }
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
                    { title: i18nd("mauikitimagetools", "Exposure"), description: i18nd("mauikitimagetools", "Adjust the overall lightness"), from: -100, to: 100 },
                    { title: i18nd("mauikitimagetools", "Brilliance"), description: i18nd("mauikitimagetools", "Recover detail and light"), from: -100, to: 100 },
                    { title: i18nd("mauikitimagetools", "Highlights"), description: i18nd("mauikitimagetools", "Adjust the brightest areas"), from: -100, to: 100 },
                    { title: i18nd("mauikitimagetools", "Shadows"), description: i18nd("mauikitimagetools", "Adjust the darkest areas"), from: -100, to: 100 },
                    { title: i18nd("mauikitimagetools", "Brightness"), description: i18nd("mauikitimagetools", "Adjust the image brightness"), from: -255, to: 255 },
                    { title: i18nd("mauikitimagetools", "Contrast"), description: i18nd("mauikitimagetools", "Adjust the difference between light and dark"), from: -100, to: 100 },
                    { title: i18nd("mauikitimagetools", "Black Point"), description: i18nd("mauikitimagetools", "Set the darkest image values"), from: -100, to: 100 }
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
                        value: 0
                        snapMode: Slider.SnapAlways
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
                    { title: i18nd("mauikitimagetools", "Saturation"), description: i18nd("mauikitimagetools", "Adjust color intensity"), from: -100, to: 100 },
                    { title: i18nd("mauikitimagetools", "Vibrance"), description: i18nd("mauikitimagetools", "Adjust muted color intensity"), from: -100, to: 100 },
                    { title: i18nd("mauikitimagetools", "Warmth"), description: i18nd("mauikitimagetools", "Adjust the warm or cool tone"), from: -100, to: 100 },
                    { title: i18nd("mauikitimagetools", "Tint"), description: i18nd("mauikitimagetools", "Adjust the green and magenta balance"), from: -100, to: 100 },
                    { title: i18nd("mauikitimagetools", "Hue"), description: i18nd("mauikitimagetools", "Shift the color hue"), from: 0, to: 180 },
                    { title: i18nd("mauikitimagetools", "Gamma"), description: i18nd("mauikitimagetools", "Adjust midtone luminance"), from: -100, to: 100 }
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
                        value: 0
                        snapMode: Slider.SnapAlways
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
                    Layout.fillWidth: true
                    Layout.maximumWidth: Maui.Style.units.gridUnit * 20
                    Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
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
                    { title: i18nd("mauikitimagetools", "Sharpness"), description: i18nd("mauikitimagetools", "Enhance edge definition"), from: 0, to: 100 },
                    { title: i18nd("mauikitimagetools", "Definition"), description: i18nd("mauikitimagetools", "Enhance fine image detail"), from: 0, to: 100 },
                    { title: i18nd("mauikitimagetools", "Noise Reduction"), description: i18nd("mauikitimagetools", "Reduce image noise"), from: 0, to: 100 },
                    { title: i18nd("mauikitimagetools", "Vignette"), description: i18nd("mauikitimagetools", "Darken or lighten the edges"), from: -100, to: 100 },
                    { title: i18nd("mauikitimagetools", "Threshold"), description: i18nd("mauikitimagetools", "Set the black and white threshold"), from: 0, to: 180 },
                    { title: i18nd("mauikitimagetools", "Gaussian Blur"), description: i18nd("mauikitimagetools", "Soften the image"), from: 0, to: 100 }
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
                        value: 0
                        snapMode: Slider.SnapAlways
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
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }
            }

            Maui.FlexSectionItem
            {
                label1.text: i18nd("mauikitimagetools", "Black and White")
                label2.text: i18nd("mauikitimagetools", "Convert the image to black and white")

                Switch
                {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                }
            }

            Maui.FlexSectionItem
            {
                label1.text: i18nd("mauikitimagetools", "Border")
                label2.text: i18nd("mauikitimagetools", "Add a border around the image")

                SpinBox
                {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    Layout.preferredWidth: Maui.Style.units.gridUnit * 6
                    from: 0
                    to: 100
                    value: 0
                }
            }
        }
    }
}