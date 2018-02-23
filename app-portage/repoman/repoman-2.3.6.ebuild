# Copyright 1999-2018 Gentoo Foundation
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

## git-hosting.eclass:
GH_RN="github:gentoo:portage"
GH_REF="${P}"

## python-*.eclass:
PYTHON_COMPAT=( python2_7 python3_{4,5,6} )
PYTHON_REQ_USE='bzip2(+)'

## variables: GH_HOMEPAGE
inherit git-hosting
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
## variables: PYTHON_USEDEP
inherit distutils-r1
## EXPORT_FUNCTIONS: src_unpack

DESCRIPTION="Repoman is a Quality Assurance tool for Gentoo ebuilds"
HOMEPAGE="${GH_HOMEPAGE} https://wiki.gentoo.org/wiki/Project:Portage"
LICENSE="GPL-2"

SLOT="0"

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( nls )

CDEPEND_A=(
	">=sys-apps/portage-2.3.14[${PYTHON_USEDEP}]"
	">=dev-python/lxml-3.6.0[${PYTHON_USEDEP}]"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

inherit arrays

S+="/repoman"

python_prepare_all() {
	# do not install tests that are never used at runtime
	esed -e "/if '__init__.py' in filenames/ s@:\$@ and '/tests' not in dirpath:@" -i -- setup.py

	cat <<'_EOF_' > "${T}/class_deleter.awk"
BEGIN {
	skipping = 0
}

/^class EbuildHeader/ {
	skipping = 1
	next
}

{
	if ( skipping ) {
		if (match($0, /^class /)) {
			skipping = 0
			print
		}
		next
	}
	print
}

_EOF_

	gawk -i inplace -f "${T}/class_deleter.awk" pym/repoman/modules/scan/ebuild/checks.py || die

	distutils-r1_python_prepare_all
}

python_test() {
	esetup.py test
}

python_install() {
	local my_args=(
		--system-prefix="${EPREFIX}/usr"
		--bindir="$(python_get_scriptdir)"
		--docdir="${EPREFIX}/usr/share/doc/${PF}"
		--htmldir="${EPREFIX}/usr/share/doc/${PF}/html"
		# Install sbin scripts to bindir for python-exec linking
		# they will be relocated in pkg_preinst()
		--sbindir="$(python_get_scriptdir)"
		--sysconfdir="${EPREFIX}/etc"
		"${@}"
	)

	distutils-r1_python_install "${my_args[@]}"
}
