import QtQuick
import QtQuick.Controls 
import QtQuick.Layouts 

import org.mauikit.controls as Maui

ColumnLayout
{
    id: control

    spacing: 0
    property bool committingRotation : false
    property string currentSection : ""
    property int cropAspectRatio : 0

    property alias rotationSlider: _freeRotationSlider
    readonly property bool cropMode : currentSection === "crop"

    signal cropRequested()
    signal cropResetRequested()
    signal cropAspectRatioSelected(int aspectRatio)

    property Item bar : Row
    {
        Layout.alignment: Qt.AlignHCenter
        spacing: Maui.Style.defaultSpacing

        Button
        {
            highlighted: control.currentSection === "transform"
            text: i18nd("mauikitimagetools", "Transform")
            onClicked: control.currentSection = control.currentSection === "transform" ? "" : "transform"
        }

        Button
        {
            highlighted: control.currentSection === "crop"
            text: i18nd("mauikitimagetools", "Crop")
            onClicked: control.currentSection = control.currentSection === "crop" ? "" : "crop"
        }
    }

    Maui.ToolBar
    {
        id: _transformOperations
        Layout.fillWidth: true
        visible: control.currentSection === "transform"
        middleContent: Row
        {
            Layout.alignment: Qt.AlignHCenter
            spacing: Maui.Style.defaultSpacing

            ToolButton
            {
                icon.name: "object-flip-vertical"
                text: i18nc("@action:button Mirror an image vertically", "Flip")
                onClicked: imageDoc.mirror(false, true)
            }

            ToolButton
            {
                icon.name: "object-flip-horizontal"
                text: i18nc("@action:button Mirror an image horizontally", "Mirror")
                onClicked: imageDoc.mirror(true, false)
            }

            ToolButton
            {
                icon.name: "object-rotate-left"
                text: i18nc("@action:button Rotate an image 90°", "Rotate 90°")
                onClicked: imageDoc.rotate(-90)
            }
        }
        background: Rectangle
        {
            color: Maui.Theme.backgroundColor
        }
    }

    Maui.ToolBar
    {
        id: _freeRotation
        position: ToolBar.Footer
        visible: control.currentSection === "transform"
        background: Rectangle
        {
            color: Maui.Theme.backgroundColor
        }

        Layout.fillWidth: true


        middleContent: Ruler
        {
            id: _freeRotationSlider
            live: true
            Layout.fillWidth: true
            from : -180
            to: 180
            value: 0
            snapMode: Slider.SnapAlways
            stepSize: 1
            clip: true

            onPressedChanged:
            {
                if (pressed || control.committingRotation)
                    return

                const rotationValue = Math.round(value)
                if (rotationValue === 0)
                    return

                control.committingRotation = true
                imageDoc.rotate(rotationValue)
                value = 0
                control.committingRotation = false
            }
        }
    }

    Maui.ToolBar
    {
        id: _cropOptions
        Layout.fillWidth: true
        visible: control.currentSection === "crop"
        middleContent: Row
        {
            Layout.alignment: Qt.AlignHCenter
            spacing: Maui.Style.defaultSpacing

            Button
            {
                highlighted: control.cropAspectRatio === 0
                text: i18nd("mauikitimagetools", "Free")
                onClicked: control.cropAspectRatioSelected(0)
            }

            Button
            {
                highlighted: control.cropAspectRatio === 1
                text: i18nd("mauikitimagetools", "Square")
                onClicked: control.cropAspectRatioSelected(1)
            }

            Button
            {
                text: i18nd("mauikitimagetools", "Reset")
                onClicked: control.cropResetRequested()
            }

            Button
            {
                text: i18nd("mauikitimagetools", "Apply Crop")
                onClicked: control.cropRequested()
            }
        }
        background: Rectangle
        {
            color: Maui.Theme.backgroundColor
        }
    }
}
