import QtQuick
import QtQuick.Controls 
import QtQuick.Layouts 

import org.mauikit.controls as Maui

ColumnLayout
{
    id: control

    spacing: 0
    property bool committingRotation : false
    property alias rotationSlider: _freeRotationSlider

    Maui.ToolBar
    {
        id: _freeRotation
        position: ToolBar.Footer
        background: Rectangle
        {
            color: Maui.Theme.backgroundColor
        }

        Layout.fillWidth: true


        middleContent: SpinBox
        {
            id: _freeRotationSlider
            from: -180
            to: 180
            stepSize: 1
            value: 0
            Layout.maximumWidth: Maui.Style.units.gridUnit * 7
            Layout.preferredWidth: Maui.Style.units.gridUnit * 7

            onValueModified:
            {
                if (control.committingRotation || value === 0)
                    return

                control.committingRotation = true
                imageDoc.rotate(value)
                value = 0
                control.committingRotation = false
            }
        }
    }

}
