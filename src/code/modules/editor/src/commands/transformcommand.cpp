#include "transformcommand.h"
#include "opencv2/photo.hpp"
#include <algorithm>
#include <cmath>
#include <vector>
#include <preprocessimage.hpp>
#include <convertimage.hpp>
#include <cvmatandqimage.h>

namespace
{
double clampValue(double value, double minimum = 0.0, double maximum = 1.0)
{
    return std::max(minimum, std::min(maximum, value));
}

double smoothstep(double edge0, double edge1, double value)
{
    if (std::abs(edge1 - edge0) < 0.000001) {
        return value < edge0 ? 0.0 : 1.0;
    }

    const double t = clampValue((value - edge0) / (edge1 - edge0));
    return t * t * (3.0 - (2.0 * t));
}

cv::Mat ensureColorMat(const cv::Mat &image)
{
    if (image.channels() == 1) {
        cv::Mat colorImage;
        cv::cvtColor(image, colorImage, cv::COLOR_GRAY2BGR);
        return colorImage;
    }

    return image.clone();
}

template<typename Transform>
QImage applyLightnessTransform(QImage &ref, Transform transform)
{
    auto mat = ensureColorMat(QtOcv::image2Mat(ref));

    cv::Mat lab;
    cv::cvtColor(mat, lab, cv::COLOR_BGR2Lab);

    std::vector<cv::Mat> channels;
    cv::split(lab, channels);

    cv::Mat lightness;
    channels[0].convertTo(lightness, CV_32F, 1.0 / 255.0);

    for (int row = 0; row < lightness.rows; ++row)
    {
        auto *line = lightness.ptr<float>(row);
        for (int column = 0; column < lightness.cols; ++column)
        {
            line[column] = static_cast<float>(clampValue(transform(line[column])));
        }
    }

    lightness.convertTo(channels[0], CV_8U, 255.0);
    cv::merge(channels, lab);

    cv::Mat output;
    cv::cvtColor(lab, output, cv::COLOR_Lab2BGR);
    return QtOcv::mat2Image(output);
}
}

TransformCommand::TransformCommand(QImage image, Transformation trans, const std::function<void ()> &undo)
    : m_image(image)
    ,m_transform(trans)
    ,m_cb(undo)
{

}

QImage TransformCommand::redo(QImage image)
{
    if(m_transform != nullptr)
    {
        return m_transform(image);
    }

    return QImage{};
}

QImage TransformCommand::undo(QImage image)
{
    Q_UNUSED(image)

    if(m_cb != nullptr)
    {
        m_cb();
    }
    return m_image;
}


QImage Trans::toGray(QImage &ref)
{
    auto m_imgMat = QtOcv::image2Mat(ref);
    auto newMat = PreprocessImage::grayscale(m_imgMat);
    auto img = QtOcv::mat2Image(newMat);
    return img;
}

QImage Trans::sketch(QImage &ref)
{
    auto m_imgMat = QtOcv::image2Mat(ref);

    if(m_imgMat.channels() == 1)
    {
        cv::cvtColor(m_imgMat, m_imgMat, cv::COLOR_GRAY2BGR);
    }

    cv::Mat graySketch, colorSketch;
    cv::pencilSketch(m_imgMat, graySketch, colorSketch, 60, 0.07f, 0.02f);

    auto img = QtOcv::mat2Image(colorSketch);
    return img;
}

QImage Trans::adjustGaussianBlur(QImage &ref, int value)
{
    auto m_imgMat = QtOcv::image2Mat(ref);
    cv::Mat out;

    cv::GaussianBlur(m_imgMat, out, cv::Size(), value);

    auto img = QtOcv::mat2Image(out);
    return img;
}

QImage Trans::adjustExposure(QImage &ref, int value)
{
    value = std::max(-100, std::min(100, value));

    auto mat = ensureColorMat(QtOcv::image2Mat(ref));
    cv::Mat output;

    const double exposureFactor = std::pow(2.0, value / 100.0);
    mat.convertTo(output, -1, exposureFactor, 0);

    return QtOcv::mat2Image(output);
}

QImage Trans::adjustBrilliance(QImage &ref, int value)
{
    value = std::max(-100, std::min(100, value));
    const double amount = value / 100.0;

    return applyLightnessTransform(ref, [amount](double lightness) {
        const double midtoneWeight = 1.0 - std::abs((2.0 * lightness) - 1.0);
        const double liftFactor = amount >= 0.0 ? (1.0 - lightness) : lightness;
        const double lifted = lightness + (amount * midtoneWeight * liftFactor * 0.5);
        const double contrasted = 0.5 + ((lifted - 0.5) * (1.0 + (amount * 0.18)));
        return contrasted;
    });
}

QImage Trans::adjustHighlights(QImage &ref, int value)
{
    value = std::max(-100, std::min(100, value));
    const double amount = value / 100.0;

    return applyLightnessTransform(ref, [amount](double lightness) {
        const double weight = smoothstep(0.45, 1.0, lightness);
        if (amount >= 0.0) {
            return lightness + (amount * weight * (1.0 - lightness) * 0.7);
        }

        return lightness + (amount * weight * lightness * 0.85);
    });
}

QImage Trans::adjustShadows(QImage &ref, int value)
{
    value = std::max(-100, std::min(100, value));
    const double amount = value / 100.0;

    return applyLightnessTransform(ref, [amount](double lightness) {
        const double weight = smoothstep(0.0, 0.55, 1.0 - lightness);
        if (amount >= 0.0) {
            return lightness + (amount * weight * (1.0 - lightness) * 0.8);
        }

        return lightness + (amount * weight * lightness * 0.75);
    });
}

QImage Trans::adjustContrast(QImage &ref, int value)
{
    if(value > 100)
        value = 100;
    else if(value < -100)
        value = -100;

    auto m_imgMat = QtOcv::image2Mat(ref);
    auto newMat = PreprocessImage::adjustContrast(m_imgMat, value);
    auto img = QtOcv::mat2Image(newMat); //remember to delete
    // qDebug() << "IS PROCESSED IMAGE VALIUD" << img.isNull() <<  img.format();

    qDebug() << m_imgMat.rows << m_imgMat.cols << m_imgMat.step << m_imgMat.empty();

    return img;
}

QImage Trans::adjustBrightness(QImage &ref, int value)
{
    if(value > 255)
        value = 255;

    else if(value < -255)
        value = -255;

    auto m_imgMat = QtOcv::image2Mat(ref);
    auto newMat = PreprocessImage::adjustBrightness(m_imgMat, value);
    auto img = QtOcv::mat2Image(newMat);
    return img;
}

QImage Trans::adjustBlackPoint(QImage &ref, int value)
{
    value = std::max(-100, std::min(100, value));
    const double amount = value / 100.0;

    return applyLightnessTransform(ref, [amount](double lightness) {
        const double shadowWeight = smoothstep(0.0, 0.6, 1.0 - lightness);
        if (amount >= 0.0) {
            return lightness - (amount * shadowWeight * (1.0 - lightness) * 0.6);
        }

        return lightness + ((-amount) * shadowWeight * (1.0 - lightness) * 0.45);
    });
}

QImage Trans::adjustSaturation(QImage &ref, int value)
{
    if(value > 100)
        value = 100;

    if(value < -100)
        value = -100;

    auto m_imgMat = QtOcv::image2Mat(ref);
    auto newMat = PreprocessImage::adjustSaturation(m_imgMat, value);

    auto img = QtOcv::mat2Image(newMat);
    return img;
}

QImage Trans::adjustVibrance(QImage &ref, int value)
{
    value = std::max(-100, std::min(100, value));
    const double amount = value / 100.0;

    auto mat = ensureColorMat(QtOcv::image2Mat(ref));
    cv::Mat hsv;
    cv::cvtColor(mat, hsv, cv::COLOR_BGR2HSV);

    cv::Mat hsvFloat;
    hsv.convertTo(hsvFloat, CV_32F);

    for (int row = 0; row < hsvFloat.rows; ++row)
    {
        auto *line = hsvFloat.ptr<cv::Vec3f>(row);
        for (int column = 0; column < hsvFloat.cols; ++column)
        {
            auto &pixel = line[column];
            double saturation = pixel[1] / 255.0;

            if (amount >= 0.0) {
                saturation += amount * (1.0 - saturation) * 0.8;
            } else {
                saturation += amount * saturation * 0.7;
            }

            pixel[1] = static_cast<float>(clampValue(saturation) * 255.0);
        }
    }

    hsvFloat.convertTo(hsv, CV_8U);
    cv::Mat output;
    cv::cvtColor(hsv, output, cv::COLOR_HSV2BGR);
    return QtOcv::mat2Image(output);
}

QImage Trans::adjustWarmth(QImage &ref, int value)
{
    value = std::max(-100, std::min(100, value));

    auto mat = ensureColorMat(QtOcv::image2Mat(ref));
    cv::Mat lab;
    cv::cvtColor(mat, lab, cv::COLOR_BGR2Lab);

    std::vector<cv::Mat> channels;
    cv::split(lab, channels);

    cv::Mat warmthChannel;
    channels[2].convertTo(warmthChannel, CV_32F);
    warmthChannel += value * 0.8f;
    cv::min(warmthChannel, 255.0, warmthChannel);
    cv::max(warmthChannel, 0.0, warmthChannel);
    warmthChannel.convertTo(channels[2], CV_8U);

    cv::merge(channels, lab);
    cv::Mat output;
    cv::cvtColor(lab, output, cv::COLOR_Lab2BGR);
    return QtOcv::mat2Image(output);
}

QImage Trans::adjustTint(QImage &ref, int value)
{
    value = std::max(-100, std::min(100, value));

    auto mat = ensureColorMat(QtOcv::image2Mat(ref));
    cv::Mat lab;
    cv::cvtColor(mat, lab, cv::COLOR_BGR2Lab);

    std::vector<cv::Mat> channels;
    cv::split(lab, channels);

    cv::Mat tintChannel;
    channels[1].convertTo(tintChannel, CV_32F);
    tintChannel += value * 0.8f;
    cv::min(tintChannel, 255.0, tintChannel);
    cv::max(tintChannel, 0.0, tintChannel);
    tintChannel.convertTo(channels[1], CV_8U);

    cv::merge(channels, lab);
    cv::Mat output;
    cv::cvtColor(lab, output, cv::COLOR_Lab2BGR);
    return QtOcv::mat2Image(output);
}

QImage Trans::adjustHue(QImage &ref, int value)
{
    if(value > 180)
        value = 180;
    else if(value < 0)
        value = 0;
    qDebug() << "Creating command for hue" << value;

    auto m_imgMat = QtOcv::image2Mat(ref);
    auto newMat = PreprocessImage::hue(m_imgMat, value);
    auto img = QtOcv::mat2Image(newMat); //remember to delete
    // qDebug() << "IS PROCESSED IMAGE VALIUD" << img.isNull() <<  img.format();

    qDebug() << m_imgMat.rows << m_imgMat.cols << m_imgMat.step << m_imgMat.empty();

    return img;
}

QImage Trans::adjustGamma(QImage &ref, int value)
{
    auto m_imgMat = QtOcv::image2Mat(ref);
    auto newMat = PreprocessImage::gamma(m_imgMat, value);
    auto img = QtOcv::mat2Image(newMat);

    qDebug() << m_imgMat.rows << m_imgMat.cols << m_imgMat.step << m_imgMat.empty();
    return img;
}

QImage Trans::adjustSharpness(QImage &ref, int value)
{
    qDebug() << "Creating command for sharpness" << value;

    auto m_imgMat = QtOcv::image2Mat(ref);
    auto newMat = PreprocessImage::sharpness(m_imgMat, value);
    auto img = QtOcv::mat2Image(newMat);
    qDebug() << m_imgMat.rows << m_imgMat.cols << m_imgMat.step << m_imgMat.empty();
    return img;
}

QImage Trans::adjustDefinition(QImage &ref, int value)
{
    value = std::max(0, std::min(100, value));

    auto mat = ensureColorMat(QtOcv::image2Mat(ref));
    cv::Mat lab;
    cv::cvtColor(mat, lab, cv::COLOR_BGR2Lab);

    std::vector<cv::Mat> channels;
    cv::split(lab, channels);

    cv::Mat blurred;
    cv::GaussianBlur(channels[0], blurred, cv::Size(), 1.4);

    const double amount = value / 100.0;
    cv::addWeighted(channels[0], 1.0 + (amount * 1.25), blurred, -(amount * 1.15), 0, channels[0]);

    cv::merge(channels, lab);
    cv::Mat output;
    cv::cvtColor(lab, output, cv::COLOR_Lab2BGR);
    return QtOcv::mat2Image(output);
}

QImage Trans::adjustNoiseReduction(QImage &ref, int value)
{
    value = std::max(0, std::min(100, value));

    auto mat = ensureColorMat(QtOcv::image2Mat(ref));
    if (value == 0) {
        return QtOcv::mat2Image(mat);
    }

    cv::Mat output;
    const float lumaStrength = 2.0f + (value / 8.0f);
    const float chromaStrength = 1.5f + (value / 10.0f);
    cv::fastNlMeansDenoisingColored(mat, output, lumaStrength, chromaStrength, 7, 21);
    return QtOcv::mat2Image(output);
}

QImage Trans::adjustThreshold(QImage &ref, int value)
{
    auto m_imgMat = QtOcv::image2Mat(ref);
    auto newMat = PreprocessImage::manualThreshold(m_imgMat, value);
    auto img = QtOcv::mat2Image(newMat);
    qDebug() << m_imgMat.rows << m_imgMat.cols << m_imgMat.step << m_imgMat.empty();
    return img;
}

static double dist(cv::Point a, cv::Point b)
{
    return sqrt(pow((double) (a.x - b.x), 2) + pow((double) (a.y - b.y), 2));
}

// Helper function that computes the longest distance from the edge to the center point.
static double getMaxDisFromCorners(const cv::Size& imgSize, const cv::Point& center)
{
    // given a rect and a line
    // get which corner of rect is farthest from the line

    std::vector<cv::Point> corners(4);
    corners[0] = cv::Point(0, 0);
    corners[1] = cv::Point(imgSize.width, 0);
    corners[2] = cv::Point(0, imgSize.height);
    corners[3] = cv::Point(imgSize.width, imgSize.height);

    double maxDis = 0;
    for (int i = 0; i < 4; ++i)
    {
        double dis = dist(corners[i], center);
        if (maxDis < dis)
            maxDis = dis;
    }

    return maxDis;
}

static void generateGradient(cv::Mat& mask)
{
    cv::Point firstPt = cv::Point(mask.size().width/2, mask.size().height/2);
    double radius = 1.0;
    double power = 0.8;

    double maxImageRad = radius * getMaxDisFromCorners(mask.size(), firstPt);

    mask.setTo(cv::Scalar(1));
    for (int i = 0; i < mask.rows; i++)
    {
        for (int j = 0; j < mask.cols; j++)
        {
            double temp = dist(firstPt, cv::Point(j, i)) / maxImageRad;
            temp = temp * power;
            double temp_s = pow(cos(temp), 4);
            mask.at<double>(i, j) = temp_s;
        }
    }
}

QImage Trans::adjustVignette(QImage &ref, int value)
{
    value = std::max(-100, std::min(100, value));
    const double amount = value / 100.0;

    auto mat = ensureColorMat(QtOcv::image2Mat(ref));

    cv::Mat maskImg(mat.size(), CV_64F);
    generateGradient(maskImg);

    cv::Mat labImg(mat.size(), CV_8UC3);
    cv::cvtColor(mat, labImg, cv::COLOR_BGR2Lab);

    for (int row = 0; row < labImg.size().height; row++)
    {
        for (int col = 0; col < labImg.size().width; col++)
        {
            cv::Vec3b value = labImg.at<cv::Vec3b>(row, col);
            const double mask = maskImg.at<double>(row, col);
            const double edgeWeight = 1.0 - mask;
            double lightness = value.val[0] / 255.0;

            if (amount >= 0.0) {
                lightness *= 1.0 - (amount * edgeWeight * 0.9);
            } else {
                lightness += (-amount) * edgeWeight * (1.0 - lightness) * 0.7;
            }

            value.val[0] = static_cast<uchar>(clampValue(lightness) * 255.0);
            labImg.at<cv::Vec3b>(row, col) =  value;
        }
    }

    cv::Mat output;
    cv::cvtColor(labImg, output, cv::COLOR_Lab2BGR);
    auto img = QtOcv::mat2Image(output);
    return img;
}

QImage Trans::vignette(QImage &ref)
{
    return adjustVignette(ref, 55);
}

QImage Trans::addBorder(QImage &ref, int thickness, const QColor &color)
{
    auto mat = QtOcv::image2Mat(ref);
    cv::Mat output, out2;
    // int top = (int) (0.05*mat.rows);; int bottom = top;
    // int left = (int) (0.05*mat.cols);; int right = left;

    int top = (int)thickness;; int bottom = top;
    int left = (int)thickness;; int right = left;
    cv::Scalar value(color.red(), color.green(), color.blue()); //in RGB order
    // cv::Scalar value(color.blue(), color.green(), color.red()); //in BGR order
    cv::cvtColor(mat, mat, cv::COLOR_RGB2BGR);
    copyMakeBorder(mat, output, top, bottom, left, right, cv::BORDER_CONSTANT,  value);
    cv::cvtColor(output, output, cv::COLOR_BGR2RGB);

    auto img = QtOcv::mat2Image(output);
    return img;
}

QImage Trans::toBlackAndWhite(QImage &ref)
{
    auto mat = QtOcv::image2Mat(ref);

  // Convert the image to grayscale
    cv::Mat grayImage, res;
    cv::cvtColor(mat, grayImage, cv::COLOR_BGR2GRAY);
    // auto thing = cv::InputOutputArrayOfArrays([grayImage, grayImage, grayImage]);
    // std::vector<cv::Mat>channels;
    // channels.push_back(grayImage);
    // channels.push_back(grayImage);
    // channels.push_back(grayImage);
    //  cv::merge(channels, res);
    //        // Apply a threshold to get a black and white image
    // cv::Mat bwImage;
    // threshold(grayImage, bwImage, 128, 255, cv::THRESH_BINARY);


           // Adjust brightness and contrast
    double alpha = 1.2; // Contrast control (1.0-3.0)
    int beta = -10;    // Brightness control (0-100)
    cv::Mat adjustedImage;
    grayImage.convertTo(adjustedImage, -1, alpha, beta);

           // Apply threshold to get black and white image
    // cv::Mat bwImage;
    // threshold(adjustedImage, bwImage, 115, 125, cv::THRESH_TOZERO);
    // cv::imshow("adjusted", bwImage);
     cv::cvtColor(adjustedImage, adjustedImage, cv::COLOR_GRAY2RGB);


    auto img = QtOcv::mat2Image(adjustedImage);
    return img;
}
