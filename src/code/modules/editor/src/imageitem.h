/*
 * SPDX-FileCopyrightText: (C) 2011 Marco Martin <mart@kde.org>
 * SPDX-FileCopyrightText: (C) 2020 Luca Beltrame <lbeltrame@kde.org>
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#pragma once

#include <QImage>
#include <QQuickPaintedItem>

/**
 * @brief Paints a QImage in a Qt Quick scene using a configurable fill mode.
 *
 * The item reports both the source image dimensions and the dimensions and
 * padding of the painted image, which is useful for mapping item coordinates
 * back to pixels in the source image.
 */
class ImageItem : public QQuickPaintedItem
{
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QImage image READ image WRITE setImage NOTIFY imageChanged RESET resetImage)
    Q_PROPERTY(int nativeWidth READ nativeWidth NOTIFY nativeWidthChanged)
    Q_PROPERTY(int nativeHeight READ nativeHeight NOTIFY nativeHeightChanged)
    Q_PROPERTY(int paintedWidth READ paintedWidth NOTIFY paintedWidthChanged)
    Q_PROPERTY(int paintedHeight READ paintedHeight NOTIFY paintedHeightChanged)
    Q_PROPERTY(int verticalPadding READ verticalPadding NOTIFY verticalPaddingChanged)
    Q_PROPERTY(int horizontalPadding READ horizontalPadding NOTIFY horizontalPaddingChanged)
    Q_PROPERTY(FillMode fillMode READ fillMode WRITE setFillMode NOTIFY fillModeChanged)
    Q_PROPERTY(bool null READ isNull NOTIFY nullChanged)

public:
    /** Describes how the source image is fitted or repeated within the item. */
    enum FillMode {
        Stretch, // the image is scaled to fit
        PreserveAspectFit, // the image is scaled uniformly inside the bounds
        Tile, // the image is duplicated horizontally and vertically
        TileVertically, // the image is stretched horizontally and tiled vertically
        TileHorizontally // the image is stretched vertically and tiled horizontally
    };
    Q_ENUM(FillMode)

    explicit ImageItem(QQuickItem *parent = nullptr);
    ~ImageItem() override = default;

    /** Sets the source image painted by this item. */
    void setImage(const QImage &image);
    /** Returns the source image. */
    QImage image() const;
    /** Clears the source image. */
    void resetImage();

    /** Returns the source image width in pixels. */
    int nativeWidth() const;
    /** Returns the source image height in pixels. */
    int nativeHeight() const;

    /** Returns the width occupied by the painted image. */
    int paintedWidth() const;
    /** Returns the height occupied by the painted image. */
    int paintedHeight() const;
    /** Returns the vertical space outside the painted image. */
    int verticalPadding() const;
    /** Returns the horizontal space outside the painted image. */
    int horizontalPadding() const;

    /** Returns the mode used to fit or repeat the image. */
    FillMode fillMode() const;
    /** Sets the mode used to fit or repeat the image. */
    void setFillMode(FillMode mode);

    void paint(QPainter *painter) override;

    /** Returns whether no source image is set. */
    bool isNull() const;

Q_SIGNALS:
    void nativeWidthChanged();
    void nativeHeightChanged();
    void fillModeChanged();
    void imageChanged();
    void nullChanged();
    void paintedWidthChanged();
    void paintedHeightChanged();
    void verticalPaddingChanged();
    void horizontalPaddingChanged();

protected:
    void geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry) override;

private:
    QImage m_image;
    bool m_smooth;
    FillMode m_fillMode;
    QRect m_paintedRect;

private Q_SLOTS:
    void updatePaintedRect();
};
