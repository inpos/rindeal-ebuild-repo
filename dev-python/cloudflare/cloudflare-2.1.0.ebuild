# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="github:cloudflare:python-cloudflare"

PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## functions: distutils-r1_python_prepare_all
inherit distutils-r1

DESCRIPTION="Python wrapper for the Cloudflare Client API v4"
LICENSE="MIT"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"dev-python/future[${PYTHON_USEDEP}]"
	"dev-python/requests[${PYTHON_USEDEP}]"
	"dev-python/pyyaml[${PYTHON_USEDEP}]"
)

inherit arrays

python_prepare_all() {
	esed -r -e "/packages *=/ s|\[[^]]*\]\+||" -i -- setup.py

	erm -r examples

	distutils-r1_python_prepare_all
}
