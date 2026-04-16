/*
 * SPDX-FileCopyrightText: (C) 2020 Carl Schwan <carl@carlschwan.eu>
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include "mirrorcommand.h"

MirrorCommand::MirrorCommand(bool horizontal, bool vertical)
    : m_horizontal(horizontal)
    , m_vertical(vertical)
{
}

QImage MirrorCommand::undo(QImage image)
{
    Q_UNUSED(image);
    return m_image;
}

QImage MirrorCommand::redo(QImage image)
{
    m_image = image;

    Qt::Orientations orientations;
    if (m_horizontal) {
        orientations |= Qt::Horizontal;
    }
    if (m_vertical) {
        orientations |= Qt::Vertical;
    }

    return orientations ? image.flipped(orientations) : image;
}
