import QtQuick 
import QtQuick.Controls
import QtQuick.Layouts

import org.mauikit.controls as Maui
import org.mauikit.imagetools.editor as ITE

import "private" as Private


/**
 * @inherit org::mauikit::controls::Page
 * @brief A control with different tools for editingan image
 *
 */
Maui.Page
{
    id: control

    Keys.enabled: true
    Keys.onPressed: (event) =>
                    {
                        if(event.key  === Qt.Key_Escape)
                        {
                            control.cancel()
                            event.accepted = true
                            return
                        }

                        if(event.key == Qt.Key_S
                                && (event.modifiers & (Qt.ControlModifier | Qt.ShiftModifier)) === (Qt.ControlModifier | Qt.ShiftModifier))
                        {
                            control.saveAsRequested()
                            event.accepted =true
                            return
                        }

                        if((event.key == Qt.Key_Y && (event.modifiers & Qt.ControlModifier))
                                || (event.key == Qt.Key_Z
                                    && (event.modifiers & (Qt.ControlModifier | Qt.ShiftModifier)) === (Qt.ControlModifier | Qt.ShiftModifier)))
                        {
                            imageDoc.redo()
                            event.accepted =true
                            return
                        }

                        if(event.key == Qt.Key_Z
                                && (event.modifiers & Qt.ControlModifier)
                                && !(event.modifiers & Qt.ShiftModifier))
                        {
                            imageDoc.undo()
                            event.accepted =true
                            return
                        }

                        if(event.key == Qt.Key_S
                                && (event.modifiers & Qt.ControlModifier)
                                && !(event.modifiers & Qt.ShiftModifier))
                        {
                            control.save()
                            event.accepted =true
                            return
                        }
                    }

    property url url

    readonly property bool ready : String(control.url).length
    
    readonly property alias editor : imageDoc

    property Item middleContentBar : _private.currentAction.bar

    signal saved()
    signal savedAs(string url)
    signal saveAsRequested()
    signal canceled()

    enum ActionType
    {
        Colors,
        Transform,
        Layers,
        Filters
    }

    component EditorAction : Action
    {
        property Item bar : null
    }

    property int initialActionType : ImageEditor.ActionType.Transform

    QtObject
    {
        id: _private
        property EditorAction currentAction : switch(initialActionType)
                                              {
                                              case ImageEditor.ActionType.Colors: return filterAction
                                              case ImageEditor.ActionType.Transform: return transformAction
                                              case ImageEditor.ActionType.Layers: return transformAction
                                              case ImageEditor.ActionType.Filters: return filterAction
                                              default: return null
                                              }

    }

    function getCurrentActionType()
    {
        if(_private.currentAction == transformAction)
            return ImageEditor.ActionType.Transform

        if(_private.currentAction == filterAction)
            return ImageEditor.ActionType.Filters

        return ImageEditor.ActionType.Transform
    }

    function cancel()
    {
        if(imageDoc.edited)
        {
            openCloseDialog()
        }
        else
        {
            control.canceled()
        }
    }

    function openCloseDialog()
    {
        var dialog = _cancelDialogComponent.createObject(control)
        dialog.open()
    }

    function save()
    {
        if (imageDoc.save())
            control.saved()
    }

    function discard()
    {
        if (imageDoc.edited)
            imageDoc.cancel()

        control.canceled()
    }

    readonly property Action transformAction : EditorAction
    {
        icon.name: "transform-rotate"
        text: i18nd("mauikitimagetools","Transform")
        checked: _private.currentAction == this
        bar: _transBar.bar
        onTriggered: _private.currentAction = this
    }

    readonly property Action filterAction : EditorAction
    {
        icon.name: "edit-add-effect"
        text: i18nd("mauikitimagetools","Colors")
        checked: _private.currentAction == this
        bar: effectBar
        onTriggered: {
            _private.currentAction = this
        }
    }

    Component
    {
        id: _cancelDialogComponent

        Maui.InfoDialog
        {
            template.iconSource: "dialog-warning"
            message: i18n("Before closing the editor, do you want to save the changes made to the image or discard them? Pick cancel to return to the editor.")
            standardButtons: Dialog.Apply | Dialog.Discard | Dialog.Cancel

            onClosed: destroy()
            onDiscarded:
            {
                imageDoc.cancel()
                control.canceled()
            }

            onApplied: control.save()
            onRejected: close()
        }
    }

    altHeader: width < 600
    // splitIn: ToolBar.Footer
    // splitSection: Maui.PageLayout.Section.Middle
    // split: width < 600

    // footerMargins: Maui.Style.defaultPadding
    headBar.leftContent: [
        ToolButton
        {
            icon.name: "go-previous"
            onClicked: control.cancel()
        },

        ToolSeparator
        {
            bottomPadding: 10
            topPadding: 10
        },

        RowLayout
        {
            spacing: Maui.Style.defaultSpacing

            Repeater
            {
                model: [transformAction, filterAction]

                ToolButton
                {
                    action: modelData
                    display: ToolButton.IconOnly
                    flat: false
                }
            }
        }
    ]

    footBar.middleContent: control.middleContentBar

    headBar.rightContent: [
        ToolButton
        {
            icon.name: "edit-undo"
            enabled: imageDoc.edited
            onClicked: imageDoc.undo()
        },

        ToolButton
        {
            icon.name: "edit-redo"
            enabled: imageDoc.canRedo
            onClicked: imageDoc.redo()
        },

        ToolSeparator
        {
            bottomPadding: 10
            topPadding: 10
        },

        ToolButton
        {
            id: _saveButton
            flat: false
            enabled: imageDoc.edited
            icon.name: "document-save"
            Maui.Controls.status : imageDoc.edited ? Maui.Controls.Positive : Maui.Controls.Normal
            icon.color: enabled ? "#fafafa" : Qt.rgba(0.98, 0.98, 0.98, 0.55)
            background: Rectangle
            {
                radius: Maui.Style.radiusV
                color: !_saveButton.enabled
                    ? Maui.Theme.backgroundColor
                    : (_saveButton.pressed || _saveButton.down || _saveButton.checked
                       ? Qt.darker(Maui.Theme.positiveBackgroundColor, 1.12)
                       : (_saveButton.hovered
                          ? Qt.lighter(Maui.Theme.positiveBackgroundColor, 1.05)
                          : Maui.Theme.positiveBackgroundColor))
                border.color: "transparent"
                opacity: _saveButton.enabled ? 1 : 0.55
            }
            onClicked: control.save()
        },

        ToolButton
        {
            icon.name: "document-save-as"
            enabled: imageDoc.edited
            onClicked: control.saveAsRequested()
        },

        ToolButton
        {
            id: _cancelButton
            flat: false
            enabled: imageDoc.edited
            Maui.Controls.status : imageDoc.edited ? Maui.Controls.Negative : Maui.Controls.Normal
            icon.color: enabled ? "#fafafa" : Qt.rgba(0.98, 0.98, 0.98, 0.55)
            icon.name: "dialog-cancel"
            background: Rectangle
            {
                radius: Maui.Style.radiusV
                color: !_cancelButton.enabled
                    ? Maui.Theme.backgroundColor
                    : (_cancelButton.pressed || _cancelButton.down || _cancelButton.checked
                       ? Qt.darker(Maui.Theme.negativeBackgroundColor, 1.12)
                       : (_cancelButton.hovered
                          ? Qt.lighter(Maui.Theme.negativeBackgroundColor, 1.05)
                          : Maui.Theme.negativeBackgroundColor))
                border.color: "transparent"
                opacity: _cancelButton.enabled ? 1 : 0.55
            }
            onClicked: control.discard()
        }
    ]

    ITE.ImageItem
    {
        id: editImage
        readonly property real ratioX: editImage.paintedWidth / editImage.nativeWidth;
        readonly property real ratioY: editImage.paintedHeight / editImage.nativeHeight;

        fillMode: Image.PreserveAspectFit
        image: imageDoc.image
        anchors.fill: parent

        rotation: _transBar.rotationSlider.value

        ITE.ImageDocument
        {
            id: imageDoc
            path: control.url
        }

    }

    Canvas
    {
        visible: transformAction.checked
        opacity: 0.15
        anchors.fill : parent
        property int wgrid: control.width / 20
        onPaint: {
            var ctx = getContext("2d")
            ctx.lineWidth = 0.5
            ctx.strokeStyle = Maui.Theme.textColor
            ctx.beginPath()
            var nrows = height/wgrid;
            for(var i=0; i < nrows+1; i++){
                ctx.moveTo(0, wgrid*i);
                ctx.lineTo(width, wgrid*i);
            }

            var ncols = width/wgrid
            for(var j=0; j < ncols+1; j++){
                ctx.moveTo(wgrid*j, 0);
                ctx.lineTo(wgrid*j, height);
            }
            ctx.closePath()
            ctx.stroke()
        }
    }

    // footBar.visible: false
    footerColumn: [

        Private.TransformationBar
        {
            id: _transBar
            visible: _private.currentAction == transformAction && control.ready
            width: parent ? parent.width : 0
        },

        Private.ColourBar
        {
            id: _colourBar
            visible: _private.currentAction == filterAction && control.ready
            width: parent ? parent.width : 0
        }
    ]


    property Item effectBar :  Row
    {
        Layout.alignment: Qt.AlignHCenter
        spacing: Maui.Style.defaultSpacing

        Button
        {
            highlighted: _colourBar.currentMode === "manual"
            text: i18nd("mauikitimagetools", "Manual Color Adjustment")
            onClicked: _colourBar.setMode("manual")
        }

        Button
        {
            highlighted: _colourBar.currentMode === "presets"
            text: i18nd("mauikitimagetools", "Color Presets")
            onClicked: _colourBar.setMode("presets")
        }
    }
}
