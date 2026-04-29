#pragma once
#include "command.h"
#include <functional>

typedef const std::function<QImage (QImage&)> & Transformation;
template< class T>
using TransformationVal = const  std::function<QImage (QImage&, T value)> & ;


class TransformCommand : public Command
{
public:
    TransformCommand(QImage image, Transformation trans = nullptr, const std::function<void ()> &undo = nullptr);
    ~TransformCommand() override = default;

    QImage redo(QImage image) override;
    QImage undo(QImage image) override;

private:
    QImage m_image;
    Transformation m_transform;
    std::function<void ()> m_cb;
};

namespace Trans
{
QImage toGray(QImage &ref);
QImage sketch(QImage &ref);
QImage adjustGaussianBlur(QImage &ref, int value);
QImage adjustExposure(QImage &ref, int value);
QImage adjustBrilliance(QImage &ref, int value);
QImage adjustHighlights(QImage &ref, int value);
QImage adjustShadows(QImage &ref, int value);
QImage adjustContrast(QImage &ref, int value);
QImage adjustBrightness(QImage &ref, int value);
QImage adjustBlackPoint(QImage &ref, int value);
QImage adjustSaturation(QImage &ref, int value);
QImage adjustVibrance(QImage &ref, int value);
QImage adjustWarmth(QImage &ref, int value);
QImage adjustTint(QImage &ref, int value);
QImage adjustHue(QImage &ref, int value);
QImage adjustGamma(QImage &ref, int value);
QImage adjustSharpness(QImage &ref, int value);
QImage adjustDefinition(QImage &ref, int value);
QImage adjustNoiseReduction(QImage &ref, int value);
QImage adjustVignette(QImage &ref, int value);
QImage adjustThreshold(QImage &ref, int value);
QImage vignette(QImage &ref);
QImage addBorder(QImage &ref, int thickness, const QColor &color);
QImage toBlackAndWhite(QImage &ref);

};
