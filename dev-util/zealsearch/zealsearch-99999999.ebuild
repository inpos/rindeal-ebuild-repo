# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# this is a fork which uses KF5 instead of KDELibs4
GH_RN="github:RJVB:ZealSearch"

inherit git-hosting
inherit cmake-utils

DESCRIPTION="Zeal integration plugin for KTextEditor (KDevelop, Kate, KWrite, ...)"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64"
IUSE_A=( doc )

CDEPEND_A=(
	"kde-base/kdelibs"

	"dev-qt/qtcore:5"
	"dev-qt/qtgui:5"
	"dev-qt/qtwidgets:5"

	"kde-frameworks/kcoreaddons"
	"kde-frameworks/ki18n"
	"kde-frameworks/ktexteditor"
	"kde-frameworks/kxmlgui"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"kde-frameworks/extra-cmake-modules" # `find_package(ECM`
)
RDEPEND_A=( "${CDEPEND_A[@]}"
	"app-doc/zeal"
)

src_configure() {
	local mycmakeargs=(
		-D USE_KDE4=OFF
	)

	cmake-utils_src_configure
}
