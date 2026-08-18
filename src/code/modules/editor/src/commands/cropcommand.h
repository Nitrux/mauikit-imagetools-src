/* SPDX-FileCopyrightText: (C) 2026 Uri Herrera <uri@nxos.org>
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#pragma once

#include "command.h"
#include <QImage>
#include <QRect>

class CropCommand : public Command
{
public:
    explicit CropCommand(const QRect &area);
    ~CropCommand() override = default;
    QImage redo(QImage image) override;
    QImage undo(QImage image) override;

private:
    QRect m_area;
    QImage m_image;
};
