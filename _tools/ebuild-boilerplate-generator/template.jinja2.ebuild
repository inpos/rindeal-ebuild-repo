{#
 # Copyright 2018 Jan Chren (rindeal)
 # Distributed under the terms of the GNU General Public License v2
 #}
# Copyright 2018 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2

EAPI=6
inherit rindeal
{% if distutils or python_any or python_single or python_utils %}

## python-*.eclass:
PYTHON_COMPAT=( python2_7 python3_{4,5,6} )
{% endif %}
{% if distutils %}

## distutils-r1.eclass:
DISTUTILS_SINGLE_IMPL=true
{% endif %}
{% if git_hosting %}

## git-hosting.eclass:
GH_RN="github:<user>:<repo>"
{% endif %}

{% if git_hosting %}
## EXPORT_FUNCTIONS: src_unpack
inherit git-hosting
{% endif %}
{% if autoconf %}
## functions: eautoreconf
inherit autotools
## functions: prune_libtool_files
inherit ltprune
{% endif %}
{% if desktop %}
## functions: make_desktop_entry, doicon
inherit desktop
## EXPORT_FUNCTIONS: src_prepare pkg_preinst pkg_postinst pkg_postrm
inherit xdg
{% endif %}
{% if cmake %}
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit cmake-utils
{% endif %}
{% if distutils %}
## EXPORT_FUNCTIONS: src_prepare src_configure src_compile src_test src_install
inherit distutils-r1
{% endif %}
{% if meson %}
## EXPORT_FUNCTIONS: src_configure src_compile src_test src_install
inherit meson
{% endif %}

DESCRIPTION="<DESCRIPTION>"
{% if not git_hosting %}
HOMEPAGE="<HOMEPAGE>"
{% endif %}
LICENSE="<LICENSE>"

SLOT="0"
{% if not git_hosting %}
SRC_URI="<SRC_URI>"
{% endif %}

KEYWORDS="~amd64 ~arm ~arm64"
IUSE_A=( )

CDEPEND_A=()
DEPEND_A=( "${CDEPEND_A[@]}" )
RDEPEND_A=( "${CDEPEND_A[@]}" )

REQUIRED_USE_A=(  )
RESTRICT+=""

inherit arrays
{% if autoconf %}

src_prepare() {
	eapply_user

	{% if cmake %}
	cmake-utils_src_prepare
	{% endif %}
	{% if autoconf %}
	eautoreconf
	{% endif %}
}
{% endif %}
{% if autoconf or cmake or meson %}

src_configure() {
	{% if autoconf %}
	local my_econf_args=(
		### Fine tuning of the installation directories:
		--docdir=...

		### Optional Features:
		$(use_enable largefile)
		$(use_enable shared-libs shared)
		$(use_enable static-libs static)
		$(use_enable nls)
		$(use_enable rpath)

		### Optional Packages:
		$(use_with pic)
		$(use_with gnu-ld)
	)
	econf "${my_econf_args[@]}"
	{% endif %}
	{% if cmake %}
	local mycmakeargs=(
		-D WITH_FOO=$(usex foo)
	)

	cmake-utils_src_configure
	{% endif %}
	{% if meson %}
	local emesonargs=(
		$(meson_use USE_flag option) # outputs: `-Doption=true` if USE_flag else `-Doption=false`
	)
	meson_src_configure
	{% endif %}
}
{% endif %}
{% if autoconf or desktop %}

src_install() {
	default
	{% if meson %}

	meson_src_install
	{% endif %}
	{% if desktop %}

	doicon -s foo.svg

	local make_desktop_entry_args=(
		"${EPREFIX}/usr/bin/${PN} -- %f"    # exec
		"${PN^}"    # name
		"${PN}"     # icon
		"Network;InstantMessaging;Chat" # categories; https://standards.freedesktop.org/menu-spec/latest/apa.html
	)
	local make_desktop_entry_extras=(
		'MimeType=x-scheme-handler/tg;'
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"
	{% endif %}
	{% if autoconf %}

	prune_libtool_files
	{% endif %}
}
{% endif %}
