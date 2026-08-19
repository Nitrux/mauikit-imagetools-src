import QtQuick 
import QtQuick.Controls
import QtQuick.Effects
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

    floatingFooter: true

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

    property Item middleContentBar : null

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
    property bool cropDebug: true
    property real debugCursorX: -1
    property real debugCursorY: -1
    function applyCrop()
    {
        if (!imageContainer.width || !imageContainer.height || !editImage.nativeWidth)
            return

        imageDoc.crop(Math.round(cropBox.x / imageContainer.width * editImage.nativeWidth),
                      Math.round(cropBox.y / imageContainer.height * editImage.nativeHeight),
                      Math.round(cropBox.width / imageContainer.width * editImage.nativeWidth),
                      Math.round(cropBox.height / imageContainer.height * editImage.nativeHeight))
        cropAction.checked = false
    }

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
        bar: null
        onTriggered: _private.currentAction = this
    }

    readonly property Action filterAction : EditorAction
    {
        icon.name: "edit-add-effect"
        text: i18nd("mauikitimagetools","Colors")
        checked: _private.currentAction == this
        bar: null
        onTriggered: {
            _transformSideBarView.sideBar.close()
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
        }
    ]

    footBar.middleContent: []
    footBar.rightContent: []

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
        fillMode: Image.PreserveAspectFit
        image: imageDoc.image
        anchors.fill: parent
        anchors.margins: Maui.Style.space.big

        rotation: 0

        ITE.ImageDocument
        {
            id: imageDoc
            path: control.url
        }


        MouseArea
        {
            id: cropDebugMouseArea
            anchors.fill: parent
            z: 0
            hoverEnabled: true
            acceptedButtons: Qt.NoButton

            onPositionChanged:
            {
                var point = mapToItem(imageContainer, mouseX, mouseY)
                debugCursorX = point.x
                debugCursorY = point.y
                if (cropDebug)
                    console.log("[CropDebug] hover cursor:", Math.round(debugCursorX), Math.round(debugCursorY),
                                "frame:", Math.round(cropBox.x), Math.round(cropBox.y),
                                Math.round(cropBox.width), Math.round(cropBox.height))
            }

            onExited:
            {
                debugCursorX = -1
                debugCursorY = -1
            }
        }

        Item
    {
        id: imageContainer
        visible: cropAction.checked
        z: 100
        width: editImage.paintedWidth
        height: editImage.paintedHeight
        anchors.centerIn: editImage

        Rectangle
        {
            id: cropBox
            x: 0
            y: 0
            width: 200
            height: 200
            color: "#33000000"
            border.color: "#26C6DA"
            border.width: 2

            MouseArea
            {
                anchors.fill: parent
                preventStealing: true

                property real startCropX
                property real startCropY
                property real startMouseX
                property real startMouseY

                onPressed:
                {
                    var point = mapToItem(imageContainer, mouseX, mouseY)
                    startCropX = cropBox.x
                    startCropY = cropBox.y
                    startMouseX = point.x
                    startMouseY = point.y
                    if (cropDebug)
                        console.log("[CropDebug] move start cursor:", Math.round(point.x), Math.round(point.y),
                                    "frame:", Math.round(cropBox.x), Math.round(cropBox.y),
                                    Math.round(cropBox.width), Math.round(cropBox.height))
                }

                onPositionChanged:
                {
                    if (pressed)
                    {
                        var point = mapToItem(imageContainer, mouseX, mouseY)
                        cropBox.x = Math.max(0, Math.min(imageContainer.width - cropBox.width,
                                                          startCropX + point.x - startMouseX))
                        cropBox.y = Math.max(0, Math.min(imageContainer.height - cropBox.height,
                                                          startCropY + point.y - startMouseY))
                        if (cropDebug)
                            console.log("[CropDebug] move cursor:", Math.round(point.x), Math.round(point.y),
                                        "frame:", Math.round(cropBox.x), Math.round(cropBox.y),
                                        Math.round(cropBox.width), Math.round(cropBox.height))
                    }
                }
            }

            Rectangle
            {
                width: 20
                height: 20
                color: "#26C6DA"
                anchors.bottom: parent.bottom
                anchors.right: parent.right

                MouseArea
                {
                    anchors.fill: parent
                    preventStealing: true
                    property real startMouseX
                    property real startMouseY
                    property real startWidth
                    property real startHeight

                    onPressed:
                    {
                        var point = mapToItem(imageContainer, mouseX, mouseY)
                        startMouseX = point.x
                        startMouseY = point.y
                        startWidth = cropBox.width
                        startHeight = cropBox.height
                        if (cropDebug)
                            console.log("[CropDebug] resize start cursor:", Math.round(point.x), Math.round(point.y),
                                        "frame:", Math.round(cropBox.x), Math.round(cropBox.y),
                                        Math.round(cropBox.width), Math.round(cropBox.height))
                    }

                    onPositionChanged:
                    {
                        if (pressed)
                        {
                            var point = mapToItem(imageContainer, mouseX, mouseY)
                            let newW = Math.floor(startWidth + (point.x - startMouseX))
                            let newH = Math.floor(startHeight + (point.y - startMouseY))

                            if (cropBox.x + newW <= imageContainer.width)
                            {
                                cropBox.width = Math.max(30, newW)
                            }

                            if (cropBox.y + newH <= imageContainer.height)
                            {
                                cropBox.height = Math.max(30, newH)
                            }
                            if (cropDebug)
                                console.log("[CropDebug] resize cursor:", Math.round(point.x), Math.round(point.y),
                                            "frame:", Math.round(cropBox.x), Math.round(cropBox.y),
                                            Math.round(cropBox.width), Math.round(cropBox.height))
                        }
                    }
                }
            }
        }
    }

    }

    Action
    {
        id: cropAction
        checkable: true
        icon.name: "transform-crop"
        text: i18nd("mauikitimagetools", "Crop")
        onTriggered:
        {
            if (checked)
                _transformSideBarView.sideBar.close()
            else
                applyCrop()
        }
    }

    Label
    {
        visible: cropDebug && cropAction.checked
        z: 200
        x: imageContainer.x
        y: imageContainer.y - height - Maui.Style.space.small
        text: "Frame: x=%1 y=%2 w=%3 h=%4\nCursor: x=%5 y=%6\nFrame-relative: x=%7 y=%8"
              .arg(Math.round(cropBox.x))
              .arg(Math.round(cropBox.y))
              .arg(Math.round(cropBox.width))
              .arg(Math.round(cropBox.height))
              .arg(Math.round(debugCursorX))
              .arg(Math.round(debugCursorY))
              .arg(Math.round(debugCursorX - cropBox.x))
              .arg(Math.round(debugCursorY - cropBox.y))
        color: Maui.Theme.textColor
        padding: Maui.Style.space.small
        background: Rectangle
        {
            color: Maui.Theme.alternateBackgroundColor
            radius: Maui.Style.radiusV
            border.color: Maui.Theme.highlightColor
        }
    }

    Canvas
    {
        visible: transformAction.checked
        opacity: 0.15
        z: 1
        anchors.centerIn: editImage
        width: editImage.paintedWidth
        height: editImage.paintedHeight
        rotation: editImage.rotation
        transformOrigin: Item.Center
        property real wgrid: Math.max(24, width / 12)
        onPaint: {
            var ctx = getContext("2d")
            ctx.clearRect(0, 0, width, height)
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

    Action
    {
        id: flipHorizontalAction
        icon.name: "object-flip-horizontal"
        text: i18nc("@action:button Mirror an image horizontally", "Flip")
        onTriggered: imageDoc.mirror(true, false)
    }


    Action
    {
        id: rotateLeftAction
        icon.name: "object-rotate-left"
        text: i18nc(":button Rotate an image 90°", "Rotate 90°")
        onTriggered: imageDoc.rotate(-90)
    }

    Action
    {
        id: transformSectionAction
        enabled: !cropAction.checked
        icon.name: "edit-advanced-effects"
        text: i18nd("mauikitimagetools", "Advanced")
        checkable: true
        checked: _transformSideBarView.sideBar.visible
        onTriggered:
        {
            if (_transformSideBarView.sideBar.visible)
                _transformSideBarView.sideBar.close()
            else
                _transformSideBarView.sideBar.open()
        }
    }

    footer: Item
    {
        id: _actionBarFooter
        visible: _private.currentAction == transformAction && control.ready
        width: parent ? parent.width : 0
        implicitHeight: _actionPane.implicitHeight
        height: implicitHeight

        Pane
        {
            id: _actionPane
            x: parent.width - width - Maui.Style.space.big
            y: 0
            padding: Maui.Style.space.medium
            visible: _actionBarFooter.visible

            ScaleAnimator on scale
            {
                from: 0
                to: 1
                duration: Maui.Style.units.longDuration
                running: visible
                easing.type: Easing.OutInQuad
            }

            OpacityAnimator on opacity
            {
                from: 0
                to: 1
                duration: Maui.Style.units.longDuration
                running: visible
            }

            Maui.Theme.colorSet: Maui.Theme.Complementary
            Maui.Theme.inherit: false

            background: Rectangle
            {
                radius: Maui.Style.radiusV
                color: Maui.Theme.alternateBackgroundColor
                border.color: Maui.Theme.alternateBackgroundColor

                layer.enabled: GraphicsInfo.api !== GraphicsInfo.Software
                layer.effect: MultiEffect
                {
                    autoPaddingEnabled: true
                    shadowEnabled: true
                    shadowColor: "#000000"
                }
            }

            contentItem: Row
            {
                spacing: Maui.Style.defaultSpacing

                Item
                {
                    width: Maui.Style.space.big
                    height: _actionsGrid.implicitHeight

                    Row
                    {
                        anchors.centerIn: parent
                        spacing: 3

                        Repeater
                        {
                            model: 2

                            Column
                            {
                                spacing: 3

                                Repeater
                                {
                                    model: 4

                                    Rectangle
                                    {
                                        width: 2
                                        height: width
                                        radius: width / 2
                                        color: Maui.Theme.textColor
                                        opacity: _dragHandleHandler.active ? 0.9 : 0.55
                                    }
                                }
                            }
                        }
                    }

                    DragHandler
                    {
                        id: _dragHandleHandler
                        target: _actionPane
                        xAxis.maximum: _actionBarFooter.width - _actionPane.width
                        xAxis.minimum: 0
                        yAxis.enabled: false

                        onActiveChanged:
                        {
                            if (!active)
                            {
                                const pos = centroid.velocity.x
                                _actionPane.x = Qt.binding(() => { return pos < 0 ? Maui.Style.space.big : _actionBarFooter.width - _actionPane.width - Maui.Style.space.big })
                            }
                        }
                    }

                    HoverHandler
                    {
                        cursorShape: _dragHandleHandler.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                    }
                }

                Grid
                {
                    id: _actionsGrid
                    rows: 2
                    columns: Math.ceil(_actionRepeater.count / 2)
                    spacing: Maui.Style.space.tiny

                    Repeater
                    {
                        id: _actionRepeater
                        model: [cropAction, flipHorizontalAction, rotateLeftAction, transformSectionAction]

                        ToolButton
                        {
                            id: _actionButton
                            readonly property bool destructive: modelData && modelData.Maui.Controls.status === Maui.Controls.Negative
                            Maui.Theme.colorSet: Maui.Theme.Complementary
                            Maui.Controls.status: modelData && modelData.Maui.Controls.status ? modelData.Maui.Controls.status : Maui.Controls.Normal

                            action: modelData
                            display: ToolButton.IconOnly
                            flat: false
                            icon.color: destructive ? "#fafafa" : color

                            background: Rectangle
                            {
                                radius: Maui.Style.radiusV
                                color: _actionButton.destructive
                                    ? (_actionButton.pressed || _actionButton.down || _actionButton.checked
                                       ? Qt.darker(Maui.Theme.negativeBackgroundColor, 1.12)
                                       : (_actionButton.hovered
                                          ? Qt.lighter(Maui.Theme.negativeBackgroundColor, 1.05)
                                          : Maui.Theme.negativeBackgroundColor))
                                    : (_actionButton.pressed || _actionButton.down || _actionButton.checked
                                       ? Maui.Theme.highlightColor
                                       : (_actionButton.highlighted || _actionButton.hovered
                                          ? Maui.Theme.hoverColor
                                          : Maui.Theme.backgroundColor))
                            }
                        }
                    }
                }
            }
        }
    }

    Maui.SideBarView
    {
        id: _transformSideBarView
        anchors.fill: parent
        z: cropAction.checked ? -1 : 10
        background: null
        visible: _private.currentAction === transformAction && control.ready

        sideBar.preferredWidth: Math.min(width * (height > width ? 0.84 : 0.38), Maui.Style.units.gridUnit * 24)
        sideBar.minimumWidth: Maui.Style.units.gridUnit * 14
        sideBar.maximumWidth: Maui.Style.units.gridUnit * 30
        sideBar.collapsed: height > width || width < Maui.Style.units.gridUnit * 42 || height < width * 0.75
        sideBar.autoShow: false
        sideBar.autoHide: true
        sideBar.floats: true

        sideBarContent: Maui.Page
        {
            anchors.fill: parent
            anchors.margins: Maui.Style.contentMargins
            clip: true
            Maui.Theme.colorSet: Maui.Theme.Window
            Maui.Theme.inherit: false

            background: Rectangle
            {
                color: Maui.Theme.alternateBackgroundColor
                radius: Maui.Style.radiusV
                border.color: Maui.Theme.backgroundColor
            }

            headBar.visible: false

            Private.TransformationBar
            {
                id: _transBar
                editor: imageDoc
                anchors.fill: parent
            }
        }
    }

}
