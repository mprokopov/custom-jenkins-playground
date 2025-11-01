# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a custom Jenkins Docker image project designed for iximiuz Labs playground environments. It builds a pre-configured Jenkins instance with specific plugins and security settings optimized for educational and experimentation purposes.

## Build and Deployment

### Building the Docker Image
```bash
make build
```
This builds the Docker image for linux/amd64 platform and tags it as defined in the Makefile (`ghcr.io/mprokopov/custom-jenkins-playground:1.2`).

### Pushing the Image
```bash
make push
```
Pushes the built image to GitHub Container Registry.

### Updating the Image Version
Modify the `IMAGE` variable in the Makefile to change the version tag.

## Architecture

### Base Image
Built on top of `ghcr.io/iximiuz/labs/rootfs:ubuntu-24-04` which provides the base rootfs for iximiuz Labs environments.

### Key Components

**Jenkins Setup:**
- Jenkins is installed via official Debian repository
- Runs with OpenJDK 21
- Pre-configured with plugins using jenkins-plugin-manager-tool
- Configuration-as-Code (JCasC) enabled via external YAML

**Security Configuration:**
The `override.conf` (Dockerfile:39) sets critical Jenkins environment variables:
- Setup wizard is disabled (`jenkins.install.runSetupWizard=false`)
- Permissive script security enabled (`permissive-script-security.enabled=no_security`)
- Local git checkouts allowed (`hudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true`)

These settings are intentionally permissive for playground/educational use and should NOT be used in production.

**Installed Plugins** (plugins.txt:1-15):
- Configuration as Code (JCasC)
- Pipeline and workflow tools
- Git/GitHub integration
- Golang support
- Job DSL
- Permissive script security

**Additional Tools:**
- Ansible (for automation scenarios)
- GitHub CLI (gh)
- Build essentials

### File Structure

- `Dockerfile` - Multi-stage build with root and user contexts
- `Makefile` - Build and push commands
- `plugins.txt` - Jenkins plugin manifest
- `override.conf` - systemd service override for Jenkins JAVA_OPTS
- `500.rootfs-custom-jenkins-m/welcome` - Welcome message displayed in the playground
- `plan.org` - Development notes (Org-mode format)

### Jenkins Configuration

Jenkins configuration is fetched from an external gist (Dockerfile:49) and placed at `/var/lib/jenkins/jenkins.yaml`. This enables Configuration-as-Code setup.

Plugins are installed at build time into `/var/lib/jenkins/plugins/` with proper jenkins:jenkins ownership.

## Development Notes

- The image targets linux/amd64 platform specifically for compatibility with iximiuz Labs infrastructure
- Plugin installation happens during image build (not at runtime) for faster startup
- The jenkins-plugin-manager resolves all plugin dependencies automatically
- systemd is used to manage the Jenkins service in the container environment
