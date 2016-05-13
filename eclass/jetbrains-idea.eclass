# Copyright 2016 Jan Chren (rindeal)
# Distributed under the terms of the GNU General Public License v2
# $Id$

# @ECLASS: jetbrains-idea.eclass
# @MAINTAINER:
# Jan Chren (rindeal) <dev.rindeal+gentoo-overlay@gmail.com>
# @BLURB: Boilerplate for IDEA-based IDEs
# @DESCRIPTION:

if [ -z "${_JETBRAINS_IDEA_ECLASS}" ] ; then

case "${EAPI:-0}" in
    6) ;;
    *) die "Unsupported EAPI='${EAPI}' for '${ECLASS}'" ;;
esac

inherit eutils versionator fdo-mime

HOMEPAGE="https://www.jetbrains.com/${PN}"
LICENSE="IDEA || ( IDEA_Academic IDEA_Classroom IDEA_OpenSource IDEA_Personal )"

SLOT="2016.1"
_JBIDEA_PN_SLOTTED="${PN}${SLOT}"

# @ECLASS-VARIABLE: JBIDEA_URI
: "${JBIDEA_URI:="${PN}/${P}"}"

SRC_URI="https://download.jetbrains.com/${JBIDEA_URI}.tar.gz"

KEYWORDS="~amd64 ~arm ~x86"
IUSE="system-jre"
RESTRICT="mirror strip test"

RDEPEND="system-jre? ( >=virtual/jre-1.8 )"

# @ECLASS-VARIABLE: JBIDEA_TAR_EXCLUDE

# @ECLASS-VARIABLE: JBIDEA_PN_PRETTY
: "${JBIDEA_PN_PRETTY:="${PN^}"}"

EXPORT_FUNCTIONS src_unpack src_compile src_install pkg_postinst

jetbrains-idea_src_unpack() {
	debug-print-function ${FUNCNAME} "$@"

	local A=( $A )
	[ ${#A[@]} -eq 1 ] || die "Your SRC_URI contains too many archives"
	local arch="${DISTDIR}/${A[0]}"

	mkdir -p "${S}" || die
	local tar=(
		tar --extract

		--no-same-owner --no-same-permissions
		--strip-components=1 # otherwise we'd have to specify excludes as `${P}/path`

		--file="${arch}"
		--directory="${S}"
	)

	local excludes=( 'license'  )
	use system-jre	 && excludes+=( 'jre' )
	use amd64	|| excludes+=( bin/{fsnotifier64,libbreakgen64.so,libyjpagent-linux64.so,LLDBFrontend} )
	use arm		|| excludes+=( bin/fsnotifier-arm )
	use x86		|| excludes+=( bin/{fsnotifier,libbreakgen.so,libyjpagent-linux.so} )

	excludes+=( "${JBIDEA_TAR_EXCLUDE[@]}" )
	readonly JBIDEA_TAR_EXCLUDE

	einfo "Unpacking '${arch}' to '${S}'"
	einfo "Excluding: $(printf "'%s' " "${excludes[@]}")"

	local e
	for e in "${excludes[@]}" ; do tar+=( --exclude="${e}" ) ; done
	einfo "Running: '${tar[@]}'"
	"${tar[@]}" || die
}

jetbrains-idea_src_compile() { : ;}

# @ECLASS-VARIABLE: JBIDEA_DESKTOP_CATEGORIES=()

# @ECLASS-VARIABLE: JBIDEA_DESKTOP_EXTRAS=()

# @ECLASS-VARIABLE: JBIDEA_INSTALL_DIR
: ${JBIDEA_INSTALL_DIR:="${EPREFIX}/opt/${_JBIDEA_PN_SLOTTED}"}

jetbrains-idea_src_install() {
	debug-print-function ${FUNCNAME} "$@"

	insinto "${JBIDEA_INSTALL_DIR}"
	doins -r *

	pushd "${D}/${JBIDEA_INSTALL_DIR}" >/dev/null || die
	{
		# globbing doesn't work with `fperms()`'
		chmod -v a+x bin/{${PN}.sh,fsnotifier*} || die
		use system-jre		|| { chmod -v a+x jre/jre/bin/*	|| die ;}

		[ -f "${JBIDEA_INSTALL_DIR}"/bin/${PN}.sh ] || die
		dosym "${JBIDEA_INSTALL_DIR}"/bin/${PN}.sh /usr/bin/${_JBIDEA_PN_SLOTTED}

		eshopts_push -s nullglob
		local svg=( bin/*.svg ) png=( bin/*.png )
		if [ ${#svg[@]} -gt 0 ] ; then
			newicon -s scalable "${svg[0]}" "${_JBIDEA_PN_SLOTTED}.svg"
		elif [ ${#png[@]} -gt 0 ] ; then
			# icons size is sometimes 128 and sometimes 256
			newicon -s 128 "${png[0]}" "${_JBIDEA_PN_SLOTTED}.png"
		else
			einfo "No icon found"
		fi
		eshopts_pop
	}
	popd >/dev/null || die

	make_desktop_entry_args=(
		"${EPREFIX}/usr/bin/${_JBIDEA_PN_SLOTTED} %U"	# exec
		"${JBIDEA_PN_PRETTY} ${SLOT}"	# name
		"${_JBIDEA_PN_SLOTTED}"		# icon
		"Development;IDE;$(IFS=';'; echo "${JBIDEA_DESKTOP_CATEGORIES[*]}")"	# categories
	)
	make_desktop_entry_extras=(
		"StartupWMClass=jetbrains-${PN}"
		"${JBIDEA_DESKTOP_EXTRAS[@]}"
	)
	make_desktop_entry "${make_desktop_entry_args[@]}" \
		"$( printf '%s\n' "${make_desktop_entry_extras[@]}" )"

	# recommended by: https://confluence.jetbrains.com/display/IDEADEV/Inotify+Watches+Limit
	mkdir -p "${D}"/etc/sysctl.d || die
	echo "fs.inotify.max_user_watches = 524288" \
		>"${D}"/etc/sysctl.d/30-idea-inotify-watches.conf || die
}

jetbrains-idea_pkg_postinst() {
	debug-print-function ${FUNCNAME} "$@"

	fdo-mime_desktop_database_update
}

_JETBRAINS_IDEA_ECLASS=1
fi