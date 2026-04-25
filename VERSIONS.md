# custom-jenkins-playground — Version History

## 1.3.2 — 2026-04-25

### Fixed
- `jenkins.yaml`: trimmed deprecated/dropped keys that JCasC rejects on
  modern Jenkins LTS (`myViewsTabBar`, `viewsTabBar`, `markupFormatter`,
  `primaryView`, `views`, `nodeMonitors`, `labelAtoms`,
  `disabledAdministrativeMonitors`, `updateCenter`, `appearance.prism`,
  `unclassified.buildDiscarders`, `unclassified.fingerprints`,
  `unclassified.pollSCM`, `apiToken.creationOfLegacyTokenEnabled`,
  `tool.mavenGlobalConfig`). Kept only the essential config: admin user,
  auth strategy, script-security relaxations, Go toolchain, location.

## 1.3.1 — 2026-04-25

### Fixed
- `jenkins.yaml`: removed `jenkins.crumbIssuer.standard.excludeClientIPFromCrumb`
  — that attribute was dropped from `DefaultCrumbIssuer` in newer Jenkins LTS.
  JCasC failed to apply, taking Jenkins down on startup. Defaults are fine.
- `Dockerfile`: bumped Jenkins APT GPG key URL from `jenkins.io-2023.key` to
  `jenkins.io-2026.key` (the 2023 key stopped serving the current signing
  key; `apt-get update` failed with `NO_PUBKEY 7198F4B714ABFC68`).

## 1.3.0 — 2026-04 (CS411 Barcelona refresh)

### Fixed (the build was broken in 1.2.1)
- `Dockerfile` line 51: typo `/usrf/share/java/jenkins.war` → `/usr/share/java/jenkins.war`
- `Dockerfile`: plugin install was `COPY plugins.txt $HOME/plugins.txt` but
  then referenced `$HOME/$LAB_USER/plugins.txt` — path mismatch made the
  build fail. Moved plugin install to `/tmp/plugins.txt`.
- `Dockerfile`: plugin install ran as `USER $LAB_USER` but wrote to
  `/var/lib/jenkins/plugins/` which only root can write. Moved the whole
  plugin-install stanza before the `USER $LAB_USER` switch.

### Changed
- `Dockerfile`: plugin-manager version is now an `ARG` (default 2.13.2) so
  future bumps don't require a Dockerfile edit — just `make build
  PLUGIN_MANAGER_VERSION=2.14.0`.
- `Makefile`: new `test` target boots Jenkins in a local container on
  `localhost:8080` for smoke testing before push.
- Image tag bumped 1.2.1 → 1.3.0 (minor, since we're fixing a broken
  build and restoring a working image for the CS411 Barcelona 2026
  delivery).

### Unchanged (already current)
- Base: `ghcr.io/iximiuz/labs/rootfs:ubuntu-24-04`
- JRE: OpenJDK 21 (previous course used 17; already bumped in earlier edit)
- Jenkins: installed from `pkg.jenkins.io/debian-stable` → whatever LTS
  is current at build time
- Ansible + `gh` CLI: from Ubuntu 24.04 repos
- `plugins.txt`: 14 plugins (configuration-as-code, workflow-aggregator,
  pipeline-stage-view, golang, git, github, job-dsl, rebuild, and
  support plugins). Not bumped.
- `jenkins.yaml`: JCasC config for admin user + Go 1.24.1 toolchain.
  Reviewed and current.

### Rationale
CS411 Barcelona 2026 refresh (course code CS411 — AI Assisted DevOps,
May 18 – Jun 5, 2026). The student-facing tutorials reference playground
`custom-jenkins-l-127630f8` which is built from this image. See
`harbour-space-devops` repo, `docs/superpowers/specs/2026-04-18-cs411-refresh-design.md`
for the broader context.

## 1.2.1 — previous

Pre-CS411 refresh state. Build was broken (see 1.3.0 fixes).

## 1.1.x and earlier

See `git log` for pre-documented history.
