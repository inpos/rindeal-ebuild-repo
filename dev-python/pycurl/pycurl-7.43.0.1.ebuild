# Copyright 1999-2017 Gentoo Foundation
# Copyright 2017-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github"
GH_REF="REL_${PV//./_}"

## python-*.eclass:
# The selftests fail with pypy, and urlgrabber segfaults for me.
PYTHON_COMPAT=( python2_7 python3_{4,5,6} )

## distutils-r1.eclass:
# Needed for individual runs of testsuite by python impls.
DISTUTILS_IN_SOURCE_BUILD=1

## EXPORT_FUNCTIONS: src_unpack
## variables: GH_HOMEPAGE
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## functions: distutils-r1_python_prepare_all, distutils-r1_python_compile, distutils-r1_python_install_all
## variables: PYTHON_USEDEP
inherit distutils-r1

DESCRIPTION="Python interface to libcurl"
HOMEPAGE="
	${GH_HOMEPAGE}
	https://pypi.python.org/pypi/pycurl
	http://pycurl.io/"
LICENSE="LGPL-2.1"

SLOT="0"
KEYWORDS="amd64 arm arm64"
IUSE_A=( doc ssl_gnutls ssl_nss +ssl_openssl examples ssl test )

CDEPEND_A=(
	# If the libcurl ssl backend changes pycurl should be recompiled.
	">=net-misc/curl-7.25.0-r1[ssl=]"
	"ssl? ("
		# Depend on a curl with ssl_* USE flags.
		# libcurl must not be using an ssl backend we do not support.
		"net-misc/curl[ssl_gnutls(-)=,ssl_nss(-)=,ssl_openssl(-)=,-ssl_axtls(-),-ssl_cyassl(-),-ssl_polarssl(-)]"
		# If curl uses gnutls, depend on at least gnutls 2.11.0 so that pycurl
		# does not need to initialize gcrypt threading and we do not need to
		# explicitly link to libgcrypt.
		"ssl_gnutls? ( >=net-libs/gnutls-2.11.0 )"
	")"
)
DEPEND_A=( "${CDEPEND_A[@]}"
	"test? ("
		"dev-python/bottle[${PYTHON_USEDEP}]"
		"dev-python/flaky[${PYTHON_USEDEP}]"
		"dev-python/nose[${PYTHON_USEDEP}]"
		"dev-python/nose-show-skipped[${PYTHON_USEDEP}]"
		"net-misc/curl[ssl_gnutls(-)=,ssl_nss(-)=,ssl_openssl(-)=,-ssl_axtls(-),-ssl_cyassl(-),-ssl_polarssl(-),kerberos]"
		# bottle-0.12.7: https://github.com/pycurl/pycurl/issues/180
		# bottle-0.12.7: https://github.com/defnull/bottle/commit/f35197e2a18de1672831a70a163fcfd38327a802
		">=dev-python/bottle-0.12.7[${PYTHON_USEDEP}]"
	")"
)

inherit arrays

python_prepare_all() {
	esed -e "/setup_args\['data_files'\] = /d" -i -- setup.py
	esed -e '/pyflakes/d' -i -- Makefile

	distutils-r1_python_prepare_all
}

# python_configure_all() {
# 	# Override faulty detection in setup.py, bug 510974.
# 	export PYCURL_SSL_LIBRARY="${CURL_SSL/libressl/openssl}"
# }

python_compile() {
	python_is_python3 || local -x CFLAGS="${CFLAGS} -fno-strict-aliasing"

	emake gen

	distutils-r1_python_compile
}

python_test() {
	emake -j1 do-test
}

python_install_all() {
	use doc && local HTML_DOCS=( doc/. )
	use examples && local EXAMPLES=( examples/. )

	distutils-r1_python_install_all
}
