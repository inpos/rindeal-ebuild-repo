Rindeal's Ebuild Repository <img src="./assets/logo_96.png" title="Sir Benjamin the Bull" alt="logo" align="right">
============================

_Packages done right™_

[![Build Status][ci-master-badge]][ci-master]
<br/>
[![Last Commit][last-commit-badge]](https://github.com/rindeal/rindeal-ebuild-repo/commits/master)
[![Commit Activity in 4 Weeks][commit-activity-4w-badge]](https://github.com/rindeal/rindeal-ebuild-repo/pulse/monthly)
[![Commit Activity in a year][commit-activity-y-badge]](https://github.com/rindeal/rindeal-ebuild-repo/pulse/monthly)
<br/>
[![Issue Stats](http://issuestats.com/github/rindeal/rindeal-ebuild-repo/badge/issue?style=flat-square)](http://issuestats.com/github/rindeal/rindeal-ebuild-repo)
[![Issue Stats](http://issuestats.com/github/rindeal/rindeal-ebuild-repo/badge/pr?style=flat-square)](http://issuestats.com/github/rindeal/rindeal-ebuild-repo)


Many ebuilds here are my own creatures, others are heavily modified forks, but all share the following:

 - code in ebuilds is **clean and documented**
 - **USE flags** are provided for almost any build-time option
     - instead of packing multitude of options under a single feature as _[Gentoo™]_ devs do
 - _mostly_ sane **default configurations** (default USE-flags, config files, ...)
     - this means default config files of some programs is modified for a better UX from the start
 - exclusive **_systemd_** support
     - systemd is in no way perfect, but it's definitely better than OpenRC+cron
 - no _libav_, _libressl_, ... support
     - [because ...](https://youtu.be/92cwKCU8Z5c)
 - **locales** support (`nls`/`l10n_*` USE-flags)
     - because I don't like having hundreds of MBs consumed by translation files
 - **x86_64**/**armv6**/**armv7**/**armv8** architectures only
     - a lot of branching and patching goes into maintaining exotic arches
 - only the **native targets** are supported
     - the support for non-native targets increases the complexity of ebuilds by an order of magnitude
     - ARM arches are backwards compatible so it shouldn't be a problem to compile natively on newer HW
     - the question of how to take care of legacy 32-bit binaries is yet to be decided

You can visit a user-friendly [list of packages][LISTING], where the chances are high for you to discover some great new software!
Also if you know about a not-yet-packaged software that is really worth packaging, you can demand it [on the issue tracker][New issue].


How to install this repository
-------------------------------

### Manually (recommended)

#### 1. Add an entry to [`/etc/portage/repos.conf`](https://wiki.gentoo.org/wiki//etc/portage/repos.conf):

```ini
[rindeal]
## set this to any location you want
location = /var/cache/portage/repos/rindeal
sync-uri = https://ebuilds.janchren.eu/repos/rindeal/.git
sync-type = git
auto-sync = yes
## prefer my packages over the Gentoo™ ones to improve UX and stability (recommended by 9/10 IT experts)
priority = 9999
```

#### 2. Sync

```sh
# Preferrably
eix-sync
# or if you need to
emerge --sync
```

### Automatically with Layman

```sh
layman -o 'https://ebuilds.janchren.eu/repos/rindeal/repositories.xml' -f -a rindeal
```

#### 3. Enable "unstable" packages

`/etc/portage/package.accepted_keywords`:
```sh
*/*::rindeal ~amd64 # or ~arm/~arm64
```


Quality Assurance
------------------

You should be able to use any package from my repository without regrets, because I do and I have quite high standards.
To achieve this goal I'm using several safety guards:

- my brain (not always so obvious)
- _[CI](https://travis-ci.org/)_, which runs:
    - _[repoman](https://wiki.gentoo.org/wiki/Repoman)_ checks
    - custom checks
- _GitHub_'s feature called _[protected branches]_, which means that all merges to _master_ must pass CI tests
- last but not least I wish _really hard_ it would all just work

This all, of course, doesn't prevent build failures, missing dependencies, etc. So, should you find
any issues, don't like something or just want to report morning news, please send me a PR or [file an issue][New issue].


Not so FAQ
-----------

#### How up-to-date are the packages here?

- No automated upstream release checker a la Fedora exists yet, but neither does at [Gentoo™], so the freshness is provided on the best effort basis.
- Very few packages in my repo have a "stable" version that is artificially kept back behind the upstream release schedule.
- My goal is to have no package more than 6 months late with updates, but you can always ping me if you feel like your favourite package needs a bump.

#### I have a problem building/running a package from official [Gentoo™] repos, can I use yours instead?

Yes, in fact, one of the most common reasons for including a package in my repo is the presence of a buggy/messy version in [Gentoo™] repos.

#### May I trust your packages?

If you trust official [Gentoo™] repos, you can trust this, too. Getting commit access to [Gentoo™] repos is possible for any person with an internet connection and enough social engineering skills, physical identity is never verified, so the only difference is then the amount of exposure each repository gets. But then again, issues reported to bugs.gentoo.org are often not resolved for weeks, months, years if ever, while issues reported to me are fixed within hours or days.


-------------------------------------------------------------------------------


### Colophon

- All code in this repo is licenced under GPL-2 ([full licence](./LICENSE)), if not stated otherwise. As opposed to other similar repositories the copyright to work that goes into developing this repository is not dedicated to the&nbsp;_Gentoo&nbsp;Foundation,&nbsp;Inc._, which means it cannot be copied into the main [Gentoo™] ebuild repository. TL;DR: if you're trying to get a code from here to the main [Gentoo™] ebuild repository, you're out of luck.
- _Gentoo_ is a trademark of the _Gentoo Foundation, Inc._
- [Animal vector designed by Freepik](http://www.freepik.com/free-photos-vectors/animal)

[protected branches]: https://help.github.com/articles/about-protected-branches/
[LISTING]: ./LISTING.md
[New issue]: https://github.com/rindeal/rindeal-ebuild-repo/issues/new
[ci-master]: https://travis-ci.org/rindeal/rindeal-ebuild-repo
[ci-master-badge]: https://img.shields.io/travis/rindeal/rindeal-ebuild-repo/master.svg?style=flat-square&label=master%20build&maxAge=300
[Gentoo™]: https://www.gentoo.org/ "main Gentoo project website"
[commit-activity-4w-badge]: https://img.shields.io/github/commit-activity/4w/rindeal/rindeal-ebuild-repo.svg?style=flat-square
[commit-activity-y-badge]: https://img.shields.io/github/commit-activity/y/rindeal/rindeal-ebuild-repo.svg?style=flat-square
[last-commit-badge]: https://img.shields.io/github/last-commit/rindeal/rindeal-ebuild-repo/master.svg?style=flat-square
