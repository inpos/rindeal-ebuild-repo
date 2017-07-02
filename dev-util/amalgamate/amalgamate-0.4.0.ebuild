# Copyright 2016-2017 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

GH_RN="gitlab:rindeal:Amalgamate"

inherit git-hosting

DESCRIPTION="Tool for creating an amalgamation from C and C++ sources"
LICENSE="MIT"

SLOT="0"

[[ "${PV}" == *9999* ]] || \
	KEYWORDS="amd64 arm arm64"

src_install() {
	dobin "${PN}"
	doman "${PN}.1"

	einstalldocs
}
