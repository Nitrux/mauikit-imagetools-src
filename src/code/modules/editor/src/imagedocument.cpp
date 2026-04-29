/*
 * SPDX-FileCopyrightText: (C) 2020 Carl Schwan <carl@carlschwan.eu>
 *
 * SPDX-License-Identifier: LGPL-2.1-or-later
 */

#include "imagedocument.h"

#include "commands/cropcommand.h"
#include "commands/mirrorcommand.h"
#include "commands/resizecommand.h"
#include "commands/rotatecommand.h"
#include "commands/transformcommand.h"
#include <QImageReader>
#include <QDebug>

ImageDocument::ImageDocument(QObject *parent)
    : QObject(parent)
{
    QImageReader::setAllocationLimit(2000);

    m_changesApplied = true;
    m_changesSaved = true;

    connect(this, &ImageDocument::pathChanged, this, [this](const QUrl &url) {
        clearUndoStack();
        clearRedoStack();
        m_image = QImage(url.isLocalFile() ? url.toLocalFile() : url.toString());
        m_originalImage = m_image;
        m_edited = false;
        m_changesApplied = true;
        m_changesSaved = true;

        Q_EMIT editedChanged();
        Q_EMIT imageChanged();
        Q_EMIT changesAppliedChanged();
        Q_EMIT changesSavedChanged();

        resetValues();
    });
}

void ImageDocument::clearUndoStack()
{
    while (!m_undos.empty()) {
        delete m_undos.pop();
    }

    Q_EMIT canUndoChanged();
}

void ImageDocument::clearRedoStack()
{
    while (!m_redos.empty()) {
        delete m_redos.pop();
    }
    m_redoImages.clear();

    Q_EMIT canRedoChanged();
}

void ImageDocument::pushCommand(Command *command)
{
    m_undos.append(command);
    clearRedoStack();
    Q_EMIT canUndoChanged();
}

void ImageDocument::applyTrackedAdjustment(int &member, int value, const QString &key, const std::function<QImage(QImage &)> &transformation, const std::function<void()> &emitChanged)
{
    if (value == member) {
        return;
    }

    const int oldValue = member;
    member = value;

    const auto command = new TransformCommand(m_image, transformation, nullptr);
    tagAdjustmentState(command, key, oldValue, value);
    command->addProperty(QStringLiteral("adjustmentBaseImage"), m_originalImage);

    m_image = command->redo(m_originalImage);
    command->addProperty(QStringLiteral("adjustmentResultImage"), m_image);
    pushCommand(command);
    setEdited(true);
    emitChanged();
    Q_EMIT imageChanged();
}

void ImageDocument::tagAdjustmentState(Command *command, const QString &key, int oldValue, int newValue)
{
    command->addProperty(QStringLiteral("adjustmentKey"), key);
    command->addProperty(QStringLiteral("adjustmentOldValue"), oldValue);
    command->addProperty(QStringLiteral("adjustmentNewValue"), newValue);
}

void ImageDocument::restoreCommandState(Command *command, bool redoState)
{
    if (!command->hasProperty(QStringLiteral("adjustmentKey"))) {
        return;
    }

    const QString key = command->getPropertyValue(QStringLiteral("adjustmentKey")).toString();
    const QString valueKey = redoState ? QStringLiteral("adjustmentNewValue") : QStringLiteral("adjustmentOldValue");
    if (command->hasProperty(QStringLiteral("adjustmentBaseImage"))) {
        m_originalImage = command->getPropertyValue(QStringLiteral("adjustmentBaseImage")).value<QImage>();
    }
    restoreAdjustmentValue(key, command->getPropertyValue(valueKey).toInt());
}

void ImageDocument::restoreAdjustmentValue(const QString &key, int value)
{
    if (key == QLatin1String("exposure")) {
        m_exposure = value;
        Q_EMIT exposureChanged();
    } else if (key == QLatin1String("brilliance")) {
        m_brilliance = value;
        Q_EMIT brillianceChanged();
    } else if (key == QLatin1String("highlights")) {
        m_highlights = value;
        Q_EMIT highlightsChanged();
    } else if (key == QLatin1String("shadows")) {
        m_shadows = value;
        Q_EMIT shadowsChanged();
    } else if (key == QLatin1String("brightness")) {
        m_brightness = value;
        Q_EMIT brightnessChanged();
    } else if (key == QLatin1String("contrast")) {
        m_contrast = value;
        Q_EMIT contrastChanged();
    } else if (key == QLatin1String("blackPoint")) {
        m_blackPoint = value;
        Q_EMIT blackPointChanged();
    } else if (key == QLatin1String("saturation")) {
        m_saturation = value;
        Q_EMIT saturationChanged();
    } else if (key == QLatin1String("vibrance")) {
        m_vibrance = value;
        Q_EMIT vibranceChanged();
    } else if (key == QLatin1String("warmth")) {
        m_warmth = value;
        Q_EMIT warmthChanged();
    } else if (key == QLatin1String("tint")) {
        m_tint = value;
        Q_EMIT tintChanged();
    } else if (key == QLatin1String("sharpness")) {
        m_sharpness = value;
        Q_EMIT sharpnessChanged();
    } else if (key == QLatin1String("definition")) {
        m_definition = value;
        Q_EMIT definitionChanged();
    } else if (key == QLatin1String("noiseReduction")) {
        m_noiseReduction = value;
        Q_EMIT noiseReductionChanged();
    } else if (key == QLatin1String("vignette")) {
        m_vignette = value;
        Q_EMIT vignetteChanged();
    }
}

void ImageDocument::cancel()
{
    while (!m_undos.empty()) {
        const auto command = m_undos.pop();
        if(m_undos.isEmpty())
            m_image = command->undo(m_image);
        delete command;
    }

    clearRedoStack();
    resetValues();
    setEdited(false);
    Q_EMIT imageChanged();
    Q_EMIT canUndoChanged();
}

QImage ImageDocument::image() const
{
    return m_image;
}

bool ImageDocument::edited() const
{
    return m_edited;
}

void ImageDocument::undo()
{
    if(m_undos.empty())
    {
        qDebug() << "No more commands to undo";
        return;
    }

    const auto command = m_undos.pop();
    m_redoImages.append(m_image);
    m_image = command->undo();
    m_originalImage = m_image;
    m_redos.append(command);
    restoreCommandState(command, false);
    Q_EMIT imageChanged();
    Q_EMIT canUndoChanged();
    Q_EMIT canRedoChanged();
    if (m_undos.empty()) {
        setEdited(false);
    }
}

void ImageDocument::redo()
{
    if (m_redos.empty())
    {
        qDebug() << "No more commands to redo";
        return;
    }

    const auto command = m_redos.pop();
    if (m_redoImages.empty())
    {
        qDebug() << "Redo image state missing";
        m_undos.append(command);
        Q_EMIT canUndoChanged();
        Q_EMIT canRedoChanged();
        return;
    }

    m_image = m_redoImages.pop();
    m_originalImage = m_image;
    m_undos.append(command);
    restoreCommandState(command, true);
    setEdited(true);
    Q_EMIT imageChanged();
    Q_EMIT canUndoChanged();
    Q_EMIT canRedoChanged();
}

void ImageDocument::crop(int x, int y, int width, int height)
{
    const auto command = new CropCommand(QRect(x, y, width, height));
    m_image = command->redo(m_image);
    pushCommand(command);
    setEdited(true);
    Q_EMIT imageChanged();
}

void ImageDocument::resize(int width, int height)
{
    const auto command = new ResizeCommand(QSize(width, height));
    m_image = command->redo(m_image);
    pushCommand(command);
    setEdited(true);
    Q_EMIT imageChanged();
}

void ImageDocument::mirror(bool horizontal, bool vertical)
{
    const auto command = new MirrorCommand(horizontal, vertical);
    m_image = command->redo(m_image);

    pushCommand(command);
    setEdited(true);
    Q_EMIT imageChanged();
}

void ImageDocument::rotate(int angle)
{
    QTransform transform;
    transform.rotate(angle);
    const auto command = new RotateCommand(transform);
    m_image = command->redo(m_image);
    pushCommand(command);
    setEdited(true);
    Q_EMIT imageChanged();
}

void ImageDocument::setEdited(bool value)
{
    m_changesApplied = !value;
    Q_EMIT changesAppliedChanged();

    m_changesSaved = !value;
    Q_EMIT changesSavedChanged();

    if (m_edited == value) {
        return;
    }
    m_edited = value;
    Q_EMIT editedChanged();
}

bool ImageDocument::save()
{
    applyChanges();

    const bool saved = m_originalImage.save(m_path.isLocalFile() ? m_path.toLocalFile() : m_path.toString());
    if (saved) {
        m_changesSaved = true;
        Q_EMIT changesSavedChanged();
        clearUndoStack();
        clearRedoStack();
        setEdited(false);
    }

    return saved;
}

bool ImageDocument::saveAs(const QUrl &location)
{
    applyChanges();

    const bool saved = m_originalImage.save(location.isLocalFile() ? location.toLocalFile() : location.toString());
    if (saved) {
        m_changesSaved = true;
        Q_EMIT changesSavedChanged();
        clearUndoStack();
        clearRedoStack();
        setEdited(false);
    }

    return saved;
}

void ImageDocument::adjustExposure(int value)
{
    applyTrackedAdjustment(m_exposure, value, QStringLiteral("exposure"), [val = value](QImage &ref) -> QImage {
        return Trans::adjustExposure(ref, val);
    }, [this]() {
        Q_EMIT exposureChanged();
    });
}

void ImageDocument::adjustBrilliance(int value)
{
    applyTrackedAdjustment(m_brilliance, value, QStringLiteral("brilliance"), [val = value](QImage &ref) -> QImage {
        return Trans::adjustBrilliance(ref, val);
    }, [this]() {
        Q_EMIT brillianceChanged();
    });
}

void ImageDocument::adjustHighlights(int value)
{
    applyTrackedAdjustment(m_highlights, value, QStringLiteral("highlights"), [val = value](QImage &ref) -> QImage {
        return Trans::adjustHighlights(ref, val);
    }, [this]() {
        Q_EMIT highlightsChanged();
    });
}

void ImageDocument::adjustShadows(int value)
{
    applyTrackedAdjustment(m_shadows, value, QStringLiteral("shadows"), [val = value](QImage &ref) -> QImage {
        return Trans::adjustShadows(ref, val);
    }, [this]() {
        Q_EMIT shadowsChanged();
    });
}

void ImageDocument::adjustBrightness(int value)
{
    applyTrackedAdjustment(m_brightness, value, QStringLiteral("brightness"), [val = value](QImage &ref) -> QImage {
        return Trans::adjustBrightness(ref, val);
    }, [this]() {
        Q_EMIT brightnessChanged();
    });
}

void ImageDocument::adjustContrast(int value)
{
    applyTrackedAdjustment(m_contrast, value, QStringLiteral("contrast"), [val = value](QImage &ref) -> QImage {
        return Trans::adjustContrast(ref, val);
    }, [this]() {
        Q_EMIT contrastChanged();
    });
}

void ImageDocument::adjustBlackPoint(int value)
{
    applyTrackedAdjustment(m_blackPoint, value, QStringLiteral("blackPoint"), [val = value](QImage &ref) -> QImage {
        return Trans::adjustBlackPoint(ref, val);
    }, [this]() {
        Q_EMIT blackPointChanged();
    });
}

void ImageDocument::adjustSaturation(int value)
{
    if (m_image.isGrayscale()) {
        return;
    }

    applyTrackedAdjustment(m_saturation, value, QStringLiteral("saturation"), [val = value](QImage &ref) -> QImage {
        return Trans::adjustSaturation(ref, val);
    }, [this]() {
        Q_EMIT saturationChanged();
    });
}

void ImageDocument::adjustVibrance(int value)
{
    if (m_image.isGrayscale()) {
        return;
    }

    applyTrackedAdjustment(m_vibrance, value, QStringLiteral("vibrance"), [val = value](QImage &ref) -> QImage {
        return Trans::adjustVibrance(ref, val);
    }, [this]() {
        Q_EMIT vibranceChanged();
    });
}

void ImageDocument::adjustWarmth(int value)
{
    applyTrackedAdjustment(m_warmth, value, QStringLiteral("warmth"), [val = value](QImage &ref) -> QImage {
        return Trans::adjustWarmth(ref, val);
    }, [this]() {
        Q_EMIT warmthChanged();
    });
}

void ImageDocument::adjustTint(int value)
{
    applyTrackedAdjustment(m_tint, value, QStringLiteral("tint"), [val = value](QImage &ref) -> QImage {
        return Trans::adjustTint(ref, val);
    }, [this]() {
        Q_EMIT tintChanged();
    });
}

void ImageDocument::adjustHue(int value)
{
    qDebug() << "adjust HUE DOCUMENT" << value;
    if(value == m_hue)
        return;

    if(m_image.isGrayscale())
        return;

    auto oldValue = m_hue;
    m_hue = value;

    auto transformation = [val = m_hue](QImage &ref) -> QImage
    {
        return Trans::adjustHue(ref, val);
    };

    auto undoCallback = [this, oldValue]()
    {
        this->m_hue = oldValue;
        Q_EMIT hueChanged();
    };

    const auto command = new TransformCommand(m_image, transformation, undoCallback);

    m_image = command->redo(m_originalImage);
    pushCommand(command);
    setEdited(true);
    Q_EMIT imageChanged();
    Q_EMIT hueChanged();
}

void ImageDocument::adjustGamma(int value)
{
    qDebug() << "adjust GAMMA DOCUMENT" << value;
    // if(m_image.isGrayscale())
    //     return;

    if(value == m_gamma)
        return;

    auto oldValue = m_gamma;
    m_gamma = value;

    auto transformation = [val = m_gamma](QImage &ref) -> QImage
    {
        return Trans::adjustGamma(ref, val);
    };

    auto undoCallback = [this, oldValue]()
    {
        this->m_gamma = oldValue;
        Q_EMIT gammaChanged();
    };

    const auto command = new TransformCommand(m_image, transformation, undoCallback);

    m_image = command->redo(m_originalImage);
    pushCommand(command);
    setEdited(true);
    Q_EMIT imageChanged();
    Q_EMIT gammaChanged();
}

void ImageDocument::adjustSharpness(int value)
{
    applyTrackedAdjustment(m_sharpness, value, QStringLiteral("sharpness"), [val = value](QImage &ref) -> QImage {
        return Trans::adjustSharpness(ref, val);
    }, [this]() {
        Q_EMIT sharpnessChanged();
    });
}

void ImageDocument::adjustDefinition(int value)
{
    applyTrackedAdjustment(m_definition, value, QStringLiteral("definition"), [val = value](QImage &ref) -> QImage {
        return Trans::adjustDefinition(ref, val);
    }, [this]() {
        Q_EMIT definitionChanged();
    });
}

void ImageDocument::adjustNoiseReduction(int value)
{
    applyTrackedAdjustment(m_noiseReduction, value, QStringLiteral("noiseReduction"), [val = value](QImage &ref) -> QImage {
        return Trans::adjustNoiseReduction(ref, val);
    }, [this]() {
        Q_EMIT noiseReductionChanged();
    });
}

void ImageDocument::adjustVignette(int value)
{
    applyTrackedAdjustment(m_vignette, value, QStringLiteral("vignette"), [val = value](QImage &ref) -> QImage {
        return Trans::adjustVignette(ref, val);
    }, [this]() {
        Q_EMIT vignetteChanged();
    });
}

void ImageDocument::adjustThreshold(int value)
{
    qDebug() << "adjust threshold DOCUMENT" << value;
    // if(m_image.isGrayscale())
    //     return;

    if(value == m_threshold)
        return;

    auto oldValue = m_threshold;
    m_threshold = value;

    auto transformation = [val = m_threshold](QImage &ref) -> QImage
    {
        return Trans::adjustThreshold(ref, val);
    };

    auto undoCallback = [this, oldValue]()
    {
        this->m_threshold = oldValue;
        Q_EMIT thresholdChanged();
    };

    const auto command = new TransformCommand(m_image, transformation, undoCallback);

    m_image = command->redo(m_originalImage);
    pushCommand(command);
    setEdited(true);
    Q_EMIT imageChanged();
    Q_EMIT thresholdChanged();
}

void ImageDocument::adjustGaussianBlur(int value)
{
    if(value == m_gaussianBlur)
        return;

    auto oldValue = m_gaussianBlur;
    m_gaussianBlur = value;
    auto transformation = [val = m_gaussianBlur](QImage &ref) -> QImage
    {
        qDebug() << "SXetting gaussian blur" << val;
        return Trans::adjustGaussianBlur(ref, val);
    };

    auto undoCallback = [this, oldValue]()
    {
        this->m_gaussianBlur = oldValue;
        Q_EMIT gaussianBlurChanged();
    };

    const auto command = new TransformCommand(m_image, transformation, undoCallback);
    m_image = command->redo(m_originalImage);
    pushCommand(command);
    setEdited(true);
    Q_EMIT imageChanged();
    Q_EMIT gaussianBlurChanged();
}

void ImageDocument::toGray()
{
    const auto command = new TransformCommand(m_image, &Trans::toGray, nullptr);

    m_image = command->redo(m_originalImage);
    pushCommand(command);
    setEdited(true);
    Q_EMIT imageChanged();
}

void ImageDocument::toBW()
{
    const auto command = new TransformCommand(m_image, &Trans::toBlackAndWhite, nullptr);

    m_image = command->redo(m_originalImage);
    pushCommand(command);
    setEdited(true);
    Q_EMIT imageChanged();
}

void ImageDocument::toSketch()
{
    const auto command = new TransformCommand(m_image, &Trans::sketch, nullptr);

    m_image = command->redo(m_originalImage);
    pushCommand(command);
    setEdited(true);
    Q_EMIT imageChanged();
}

void ImageDocument::addVignette()
{
    adjustVignette(55);
}

auto borderTrans(int thickness, const QColor &color, QImage &ref)
{
    return Trans::addBorder(ref, thickness, color);
}

void ImageDocument::addBorder(int thickness, const QColor &color)
{
    qDebug() << "SXetting add border blur" << thickness << color << color.red() << color.green()<<color.blue();
    auto transformation = [&](QImage &ref) -> QImage
    {
        qDebug() << "SXetting add border blur2" << thickness << color;
        return Trans::addBorder(ref, thickness, color);
    };

    const auto command = new TransformCommand(m_image, transformation, nullptr);

    m_image = command->redo(m_originalImage);
    pushCommand(command);
    setEdited(true);
    Q_EMIT imageChanged();
}

void ImageDocument::applyChanges()
{
    resetValues();

    m_originalImage = m_image;
    m_changesApplied = true;
    Q_EMIT changesAppliedChanged();
}

int ImageDocument::exposure() const
{
    return m_exposure;
}

int ImageDocument::brilliance() const
{
    return m_brilliance;
}

int ImageDocument::highlights() const
{
    return m_highlights;
}

int ImageDocument::shadows() const
{
    return m_shadows;
}

int ImageDocument::brightness() const
{
    return m_brightness;
}

int ImageDocument::contrast() const
{
    return m_contrast;
}

int ImageDocument::blackPoint() const
{
    return m_blackPoint;
}

int ImageDocument::saturation() const
{
    return m_saturation;
}

int ImageDocument::vibrance() const
{
    return m_vibrance;
}

int ImageDocument::warmth() const
{
    return m_warmth;
}

int ImageDocument::tint() const
{
    return m_tint;
}

int ImageDocument::hue() const
{
    return m_hue;
}

int ImageDocument::gamma() const
{
    return m_gamma;
}

int ImageDocument::sharpness() const
{
    return m_sharpness;
}

int ImageDocument::definition() const
{
    return m_definition;
}

int ImageDocument::noiseReduction() const
{
    return m_noiseReduction;
}

int ImageDocument::vignette() const
{
    return m_vignette;
}

int ImageDocument::threshold() const
{
    return m_threshold;
}

int ImageDocument::gaussianBlur() const
{
    return m_gaussianBlur;
}

QUrl ImageDocument::path() const
{
    return m_path;
}

void ImageDocument::setPath(const QUrl &path)
{
    m_path = path;
    Q_EMIT pathChanged(path);
}

QRectF ImageDocument::area() const
{
    return m_area;
}

void ImageDocument::setArea(const QRectF &newArea)
{
    if (m_area == newArea)
        return;
    m_area = newArea;
    Q_EMIT areaChanged();
}

void ImageDocument::resetArea()
{
    setArea({}); // TODO: Adapt to use your actual default value
}

void ImageDocument::resetValues()
{
    m_exposure = 0;
    m_brilliance = 0;
    m_highlights = 0;
    m_shadows = 0;
    m_contrast = 0;
    m_brightness = 0;
    m_blackPoint = 0;
    m_saturation = 0;
    m_vibrance = 0;
    m_warmth = 0;
    m_tint = 0;
    m_hue = 0;
    m_gamma = 0;
    m_sharpness = 0;
    m_definition = 0;
    m_noiseReduction = 0;
    m_vignette = 0;
    m_threshold = 0;
    m_gaussianBlur = 0;
    Q_EMIT exposureChanged();
    Q_EMIT brillianceChanged();
    Q_EMIT highlightsChanged();
    Q_EMIT shadowsChanged();
    Q_EMIT hueChanged();
    Q_EMIT saturationChanged();
    Q_EMIT brightnessChanged();
    Q_EMIT contrastChanged();
    Q_EMIT blackPointChanged();
    Q_EMIT vibranceChanged();
    Q_EMIT warmthChanged();
    Q_EMIT tintChanged();
    Q_EMIT gammaChanged();
    Q_EMIT thresholdChanged();
    Q_EMIT sharpnessChanged();
    Q_EMIT definitionChanged();
    Q_EMIT noiseReductionChanged();
    Q_EMIT vignetteChanged();
    Q_EMIT gaussianBlurChanged();
}

bool ImageDocument::changesApplied() const
{
    return m_changesApplied;
}

bool ImageDocument::changesSaved() const
{
    return m_changesSaved;
}

bool ImageDocument::canUndo() const
{
    return !m_undos.isEmpty();
}

bool ImageDocument::canRedo() const
{
    return !m_redos.isEmpty();
}
