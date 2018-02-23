# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:goldmann"

## python-*.eclass:
PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

## distutils-r1.eclass:
DISTUTILS_SINGLE_IMPL=1

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1

DESCRIPTION="Docker image squashing tool"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	# the 3.x versions are unstable for now
	# https://github.com/goldmann/docker-squash/issues/158
	"<dev-python/docker-py-3[${PYTHON_USEDEP}]"
)

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays
