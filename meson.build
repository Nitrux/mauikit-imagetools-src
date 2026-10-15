project('mauikit-imagetools', 'cpp', version: '4.0.5', meson_version: '>=1.0.0', default_options: ['cpp_std=c++17', 'buildtype=release'])

cpp_compiler = meson.get_compiler('cpp')
if cpp_compiler.get_id() == 'gcc' and cpp_compiler.has_argument('-Wno-sfinae-incomplete')
    add_project_arguments('-Wno-sfinae-incomplete', language: 'cpp')
endif
qt6 = import('qt6')
qt = dependency('qt6', version: '>=6.4', modules: ['Concurrent', 'Core', 'Gui', 'Quick', 'Qml', 'Sql', 'Positioning'])
qt_moc_args = ['-I' + qt.get_variable('includedir')]
kf6_core = declare_dependency(include_directories: include_directories(get_option('prefix') / 'include' / 'KF6' / 'KCoreAddons'), dependencies: [cpp_compiler.find_library('KF6CoreAddons')])
kf6_i18n = declare_dependency(include_directories: include_directories(get_option('prefix') / 'include' / 'KF6' / 'KI18n'), dependencies: [cpp_compiler.find_library('KF6I18n')])
mauikit = dependency('MauiKit4', version: '>=4.0.5')
kexiv2 = declare_dependency(include_directories: include_directories(get_option('prefix') / 'include', get_option('prefix') / 'include' / 'KF6', get_option('prefix') / 'include' / 'KExiv2Qt6'), dependencies: [cpp_compiler.find_library('KExiv2Qt6')])
cpp_args = host_machine.cpu_family() == 'x86_64' ? ['-march=x86-64-v3', '-DIMAGE2TEXT_ENABLED'] : ['-DIMAGE2TEXT_ENABLED']
opencv_cpp_args = cpp_args + ['-Wno-sign-compare', '-Wno-overloaded-virtual']
export_header = configure_file(
    input: 'meson-content.in',
    output: 'imagetools_export.h',
    configuration: {'CONTENT': ('''#pragma once
#define IMAGETOOLS_EXPORT __attribute__((visibility("default")))
''')}
)
imagetools_version_header = configure_file(input: 'meson-content.in', output: 'imagetools_version.h', configuration: {'CONTENT': ('#pragma once\n#define ImageTools_VERSION_STRING "4.0.5"\n#define GIT_BRANCH "Stable"\n#define GIT_COMMIT_HASH "4.0.5"\n')})
opencv_export_header = configure_file(input: 'meson-content.in', output: 'opencvlib_export.h', configuration: {'CONTENT': ('#pragma once\n#define OPENCVLIB_EXPORT\n')})
image2text_export_header = configure_file(input: 'meson-content.in', output: 'image2text_export.h', configuration: {'CONTENT': ('#pragma once\n#define IMAGE2TEXT_EXPORT\n')})
opencv_dep = dependency('opencv4', required: true)
tesseract = dependency('tesseract', required: true)
leptonica = dependency('lept', required: true)
opencv = static_library('MauiKitImageToolsOpenCV', [opencv_export_header] + files('src/code/modules/opencv/code/preprocessimage.cpp', 'src/code/modules/opencv/code/mycroplayer.cpp', 'src/code/modules/opencv/code/cvmatandqimage.cpp'), dependencies: [qt, opencv_dep], include_directories: include_directories('src/code/modules/opencv/code'), cpp_args: opencv_cpp_args, pic: true)
image2text = static_library('MauiKitImageToolsImage2Text', [image2text_export_header] + files('src/code/modules/image2text/src/ocs.cpp', 'src/code/modules/image2text/src/OCRLanguageModel.cpp') + qt6.preprocess(moc_extra_arguments: qt_moc_args, moc_headers: ['src/code/modules/image2text/src/OCRLanguageModel.h', 'src/code/modules/image2text/src/ocs.h']), dependencies: [qt, tesseract, leptonica, opencv_dep], link_with: [opencv], include_directories: include_directories('src/code/modules/image2text/src', 'src/code/modules/opencv/code'), cpp_args: opencv_cpp_args + ['-DIMAGE2TEXT_ENABLED'], pic: true)
editor = static_library('MauiKitImageToolsEditor', files('src/code/modules/editor/src/imagedocument.cpp', 'src/code/modules/editor/src/imageitem.cpp', 'src/code/modules/editor/src/commands/command.cpp', 'src/code/modules/editor/src/commands/transformcommand.cpp', 'src/code/modules/editor/src/commands/mirrorcommand.cpp', 'src/code/modules/editor/src/commands/resizecommand.cpp', 'src/code/modules/editor/src/commands/cropcommand.cpp', 'src/code/modules/editor/src/commands/rotatecommand.cpp') + qt6.preprocess(moc_extra_arguments: qt_moc_args, moc_headers: ['src/code/modules/editor/src/imagedocument.h', 'src/code/modules/editor/src/imageitem.h']), dependencies: [qt, opencv_dep], link_with: [opencv], include_directories: include_directories('src/code/modules/editor/src', 'src/code/modules/opencv/code'), cpp_args: opencv_cpp_args, pic: true)
main_sources = files('src/code/imagetools_plugin.cpp', 'src/code/picinfomodel.cpp', 'src/code/imagemetadata.cpp', 'src/code/exiv2extractor.cpp', 'src/code/geolocation/city.cpp', 'src/code/geolocation/cities.cpp', 'src/code/geolocation/citiesdb.cpp', 'src/code/geolocation/kdtree.cpp', 'src/code/moduleinfo.cpp', 'src/code/textscanner.cpp')
main_moc = qt6.preprocess(moc_extra_arguments: qt_moc_args, moc_headers: ['src/code/imagetools_plugin.h', 'src/code/picinfomodel.h', 'src/code/imagemetadata.h', 'src/code/geolocation/city.h', 'src/code/geolocation/cities.h', 'src/code/geolocation/citiesdb.h', 'src/code/textscanner.h'])

lib = shared_library('MauiKitImageTools4', main_sources + main_moc + [imagetools_version_header, export_header], dependencies: [qt, kf6_core, kf6_i18n, kexiv2, mauikit], link_with: [image2text, editor], include_directories: include_directories('src/code', 'src/code/modules/opencv/code', 'src/code/modules/image2text/src', 'src/code/modules/editor/src'), cpp_args: cpp_args, version: '4.0.5', soversion: '4', install: true)
plugin_moc = qt6.preprocess(moc_extra_arguments: qt_moc_args, moc_headers: ['src/code/imagetools_plugin.h', 'src/code/picinfomodel.h', 'src/code/imagemetadata.h'])
plugin_qt = qt6.preprocess(qresources: ['src/data/assets.qrc'])
plugin = shared_module('MauiKitImageTools4plugin', ['src/code/imagetools_plugin.cpp', 'src/code/picinfomodel.cpp', 'src/code/imagemetadata.cpp'] + plugin_moc + plugin_qt, link_with: [lib, image2text, editor], dependencies: [qt, mauikit, kexiv2], include_directories: include_directories('src/code', 'src/code/modules/image2text/src'), cpp_args: cpp_args, install: true, install_dir: get_option('libdir') / 'qt6/qml/org/mauikit/imagetools')
qml_dir = get_option('libdir') / 'qt6/qml/org/mauikit/imagetools'
install_data(configure_file(
    input: 'meson-content.in',
    output: 'qmldir',
    configuration: {'CONTENT': ('''module org.mauikit.imagetools 1.0
plugin MauiKitImageTools4plugin
''')}
), install_dir: qml_dir)
install_subdir('src/controls.6', install_dir: qml_dir, strip_directory: true)
editor_qml_dir = get_option('libdir') / 'qt6/qml/org/mauikit/imagetools/editor'
editor_plugin_source = configure_file(
    input: 'meson-content.in',
    output: 'imagetools_editor_plugin.cpp',
    configuration: {'CONTENT': ('''#include <QQmlExtensionPlugin>
#include <qqml.h>

#include "imagedocument.h"
#include "imageitem.h"

class MauiKitImageToolsEditorPlugin : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "org.qt-project.Qt.QQmlExtensionInterface")

public:
    void registerTypes(const char *) override
    {
        qmlRegisterType<ImageDocument>("org.mauikit.imagetools.editor", 1, 0, "ImageDocument");
        qmlRegisterType<ImageItem>("org.mauikit.imagetools.editor", 1, 0, "ImageItem");
    }
};
''')}
)
editor_plugin_moc = qt6.preprocess(moc_extra_arguments: qt_moc_args, moc_sources: [editor_plugin_source])
editor_plugin = shared_module('MauiKitImageToolsEditor4', [editor_plugin_source, editor_plugin_moc], link_with: [editor, opencv], dependencies: [qt, opencv_dep], include_directories: include_directories('src/code/modules/editor/src'), cpp_args: cpp_args, install: true, install_dir: editor_qml_dir)
install_data(configure_file(
    input: 'meson-content.in',
    output: 'editor_qmldir',
    configuration: {'CONTENT': ('''module org.mauikit.imagetools.editor 1.0
plugin MauiKitImageToolsEditor4
''')}
), install_dir: editor_qml_dir, rename: 'qmldir')
install_subdir('src/code/modules/editor/src/controls', install_dir: editor_qml_dir, strip_directory: true)
install_data('src/data/cities.db', install_dir: get_option('datadir') / 'org/mauikit/imagetools')
install_headers(files('src/code/exiv2extractor.h', 'src/code/geolocation/city.h', 'src/code/geolocation/cities.h', 'src/code/moduleinfo.h', 'src/code/textscanner.h') + [export_header], subdir: 'MauiKit4/ImageTools')
pkg = import('pkgconfig')
pkg.generate(lib, name: 'MauiKit Image Tools 4', filebase: 'MauiKitImageTools4', version: meson.project_version(), description: 'MauiKit image tools library', requires: 'MauiKit4')

cmake_targets = configure_file(
    input: 'meson-content.in',
    output: 'MauiKitImageTools4Targets.cmake',
    configuration: {'CONTENT': (('''get_filename_component(_MAUIKIT_PREFIX "${CMAKE_CURRENT_LIST_DIR}/../../.." ABSOLUTE)
if(NOT TARGET MauiKitImageTools4)
  add_library(MauiKitImageTools4 SHARED IMPORTED)
  set_target_properties(MauiKitImageTools4 PROPERTIES
    IMPORTED_LOCATION "${_MAUIKIT_PREFIX}/@LIBDIR@/libMauiKitImageTools4.so.4.0.5"
    INTERFACE_INCLUDE_DIRECTORIES "${_MAUIKIT_PREFIX}/include/MauiKit4/ImageTools")
endif()
if(NOT TARGET MauiKit4::ImageTools)
  add_library(MauiKit4::ImageTools ALIAS MauiKitImageTools4)
endif()
if(NOT TARGET MauiKit::ImageTools)
  add_library(MauiKit::ImageTools ALIAS MauiKitImageTools4)
endif()
''')).replace('@LIBDIR@', (get_option('libdir')))}
)
cmake_config = configure_file(
    input: 'meson-content.in',
    output: 'MauiKitImageTools4Config.cmake',
    configuration: {'CONTENT': ('''include(CMakeFindDependencyMacro)
find_dependency(Qt6 6.4 COMPONENTS Core)
include("${CMAKE_CURRENT_LIST_DIR}/MauiKitImageTools4Targets.cmake")
set(MauiKitImageTools4_FOUND TRUE)
''')}
)
cmake_version = configure_file(
    input: 'meson-content.in',
    output: 'MauiKitImageTools4ConfigVersion.cmake',
    configuration: {'CONTENT': (('''set(PACKAGE_VERSION "@VERSION@")
if(PACKAGE_FIND_VERSION VERSION_LESS_EQUAL PACKAGE_VERSION)
  set(PACKAGE_VERSION_COMPATIBLE TRUE)
endif()
if(PACKAGE_FIND_VERSION VERSION_EQUAL PACKAGE_VERSION)
  set(PACKAGE_VERSION_EXACT TRUE)
endif()
''')).replace('@VERSION@', (meson.project_version()))}
)
install_data([cmake_targets, cmake_config, cmake_version], install_dir: get_option('libdir') / 'cmake' / 'MauiKitImageTools4')
