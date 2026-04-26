// SPDX-FileCopyrightText: 2020 Carl Schwan <carl@carlschwan.eu>
//
// SPDX-License-Identifier: LGPL-2.1-or-later

#include <QDebug>
#include <QQmlEngine>
#include <QResource>

#include "picinfomodel.h"
#include "imagetools_plugin.h"
#ifndef Q_OS_ANDROID
#include <ocs.h>
#endif

void ImageToolsPlugin::registerTypes(const char *uri)
{
    qDebug() << "REGISTER MAUIKITIMAGETOOLS TYPES <<<<<<<<<<<<<<<<<<<<<<";
#if defined(Q_OS_ANDROID)
    QResource::registerResource(QStringLiteral("assets:/android_rcc_bundle.rcc"));
#endif

    Q_ASSERT(QLatin1String(uri) == QLatin1String("org.mauikit.imagetools"));
    qDebug() << "REGISTER MAUIKITIMAGETOOLS TYPES 2 <<<<<<<<<<<<<<<<<<<<<<";

    qmlRegisterType(componentUrl(QStringLiteral("ImageViewer.qml")), uri, 1, 0, "ImageViewer");
    qDebug() << "REGISTER MAUIKITIMAGETOOLS TYPES 3 <<<<<<<<<<<<<<<<<<<<<<";

#ifdef Q_OS_ANDROID
    qmlRegisterType(componentUrl(QStringLiteral("android/ImageEditor.qml")), uri, 1, 0, "ImageEditor");
#else
    qmlRegisterType(componentUrl(QStringLiteral("linux/ImageEditor.qml")), uri, 1, 0, "ImageEditor");
#endif
    qDebug() << "REGISTER MAUIKITIMAGETOOLS TYPES 4 <<<<<<<<<<<<<<<<<<<<<<";

    qmlRegisterType<PicInfoModel>(uri, 1, 3, "PicInfoModel");
    qDebug() << "REGISTER MAUIKITIMAGETOOLS TYPES 5 <<<<<<<<<<<<<<<<<<<<<<";
    qmlRegisterType(componentUrl(QStringLiteral("ImageInfoDialog.qml")), uri, 1, 3, "ImageInfoDialog");
    qmlRegisterType(componentUrl(QStringLiteral("MetadataEditor.qml")), uri, 1, 3, "MetadataEditor");
    qDebug() << "REGISTER MAUIKITIMAGETOOLS TYPES 6 <<<<<<<<<<<<<<<<<<<<<<";

#ifndef Q_OS_ANDROID
    qmlRegisterType<OCS>(uri, 1, 3, "OCR");
    qDebug() << "REGISTER MAUIKITIMAGETOOLS TYPES 7 (OCR registered) <<<<<<<<<<<<<<<<<<<<<<";
    qmlRegisterType(componentUrl(QStringLiteral("image2text/OCRPage.qml")), uri, 1, 3, "OCRPage");
    qDebug() << "REGISTER MAUIKITIMAGETOOLS TYPES 8 (done) <<<<<<<<<<<<<<<<<<<<<<";
#endif
}

QUrl ImageToolsPlugin::componentUrl(const QString &fileName) const
{
    return QUrl(resolveFileUrl(fileName));
}


