/* SPDX-FileCopyrightText: (C) 2026 Uri Herrera <uri@nxos.org>
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include "cropcommand.h"

CropCommand::CropCommand(const QRect &area)
    : m_area(area)
{
}

QImage CropCommand::redo(QImage image)
{
    m_image = image;
    return image.copy(m_area);
}

QImage CropCommand::undo(QImage image)
{
    Q_UNUSED(image)
    return m_image;
}
