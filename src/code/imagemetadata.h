// <one line to give the program's name and a brief idea of what it does.>
// SPDX-FileCopyrightText: 2022 <copyright holder> <email>
// SPDX-License-Identifier: GPL-3.0-or-later

#pragma once
#include <QObject>
/**
 * @brief Provides the base object for exposing image metadata.
 *
 * This class currently defines no metadata properties. It is retained as the
 * public extension point for metadata support.
 */
class ImageMetadata : public QObject
{
    Q_OBJECT
    
public:
    explicit ImageMetadata(QObject *parent = nullptr);
};

