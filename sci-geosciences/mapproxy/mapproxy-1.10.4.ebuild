# Copyright 2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github"

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )
DISTUTILS_SINGLE_IMPL=true

# EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
inherit distutils-r1

DESCRIPTION="MapProxy is a tile cache and WMS proxy"
HOMEPAGE="https://mapproxy.org/ ${GH_HOMEPAGE}"
LICENSE="Apache-2.0"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=(
	"=sci-libs/proj-4*"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/pillow[${PYTHON_USEDEP}]"
	"dev-python/pyyaml[${PYTHON_USEDEP}]"
	"dev-python/lxml[${PYTHON_USEDEP}]"
)

inherit arrays

python_prepare_all() {
	sed -e 's|find_packages()|find_packages(exclude=["*.test", "*.test.*", "test.*", "test"])|' \
		-i -- setup.py || die

	distutils-r1_python_prepare_all
}

python_install_all() {
	distutils-r1_python_install_all
	find "${ED}" -name '*.pth' -delete || die
}
