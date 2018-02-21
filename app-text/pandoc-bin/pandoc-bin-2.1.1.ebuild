# Copyright 2016-2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal

# to unpack .deb archive
## EXPORT_FUNCTIONS: src_unpack
inherit unpacker

DESCRIPTION="Universal markup converter"
HOMEPAGE="https://pandoc.org https://github.com/jgm/pandoc"
LICENSE="GPL-2"

PN_NOBIN="${PN//-bin/}"

SLOT="0"
SRC_URI="amd64? ( https://github.com/jgm/${PN_NOBIN}/releases/download/${PV}/${PN_NOBIN}-${PV}-1-amd64.deb )"

KEYWORDS="-* amd64"
IUSE_A=( citeproc )

CDEPEND_A=(
	"dev-libs/gmp:*"
	"sys-libs/zlib:*"
)
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}"
	"!app-text/${PN_NOBIN}"
	"citeproc? ( !dev-haskell/${PN_NOBIN}-citeproc )"
)

RESTRICT+=" mirror"

inherit arrays

S="${WORKDIR}"

src_prepare() {
	default

	# docs are gzipped
	find -name "*.gz" | xargs gunzip
	assert
}

src_install() {
	cd "${S}"/usr/bin || die
	dobin "${PN_NOBIN}"
	use citeproc && dobin "${PN_NOBIN}-citeproc"

	cd "${S}"/usr/share/man/man1 || die
	doman "${PN_NOBIN}.1"
	use citeproc && doman "${PN_NOBIN}-citeproc.1"
}

QA_EXECSTACK="usr/bin/.*"
QA_PRESTRIPPED="usr/bin/.*"
