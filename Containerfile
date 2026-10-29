# syntax=docker.io/docker/dockerfile-upstream:1.28.0@sha256:bb22d9815c728170f72750f4e5b0d672e06176142e1d602c7e66c050100b7e5b
# The yasrt release tool, packaged for the CI job it runs in.
#
# A root filesystem from openSUSE Tumbleweed, built by
# devops/images/tumbleweed-builder and copied into FROM scratch (handbook:
# engineering/delivery/tumbleweed-migration.md, wave 2); until 2026-10 it
# was wolfi-base. This image needs a real git binary - yasrt drives git
# through os/exec precisely so that signing, credential handling and
# shallow-clone behaviour are git's own rather than a library's
# approximation.
#
# The binary is not built here. yasrt/cli releases it to its generic package
# registry; the pipeline fetches it into dist/ with a job token and this file
# only packages it. That is the same split devops/images/deploy-opkssh uses,
# and it keeps the Go toolchain out of the image.
#
# One snapshot pin per architecture, moved by pinup
# (custom.tumbleweed-snapshot), is the only package pin.
# renovate: datasource=custom.tumbleweed-snapshot depName=aarch64
ARG TW_SNAPSHOT_AARCH64=20261020.1793084719-3dcddf13

FROM registry.ole-hartwig.eu/devops/images/tumbleweed-builder:1@sha256:2f25b2cdd6b4266b2fe037373e8dc4dd450971dd8b1892b51d876855c949c28b AS rootfs
ARG TW_SNAPSHOT_AARCH64
# @userland is bash as /bin/sh and the GNU tools; openssh-clients brings
# ssh-keygen (openssh-common). The yasrt user gets the UID the jobs run as.
RUN koh-rootfs /rootfs --user yasrt:1000 @userland git-core gpg2 openssh-clients ca-certificates-mozilla

FROM scratch
COPY --from=rootfs /rootfs/ /
ARG TARGETARCH

COPY dist/yasrt-linux-${TARGETARCH} /usr/local/bin/yasrt

# safe.directory: the runner mounts CI_PROJECT_DIR with a different owner than
# the job user and git then refuses to touch it, so declare it once here rather
# than in every consuming job.
RUN chmod 0755 /usr/local/bin/yasrt \
 && git config --system --add safe.directory '*'

# Smoke test. Deliberately not `git --version`: yasrt drives git through
# os/exec for everything it does — tag creation, log parsing, signing,
# credential handling — so a git that answers --version and then cannot init a
# repository or read a log back would pass a version check and fail every
# consumer. Exercise the cycle instead.
RUN set -eu; \
    yasrt version; \
    gpg --version > /dev/null; \
    ssh-keygen -t ed25519 -N "" -C smoke -f /tmp/smoke_key -q; \
    d="$(mktemp -d)"; \
    git -C "$d" init -q -b main; \
    git -C "$d" -c user.email=smoke@invalid -c user.name=Smoke commit -q --allow-empty -m "feat: smoke"; \
    git -C "$d" -c user.email=smoke@invalid -c user.name=Smoke tag -a -m 1.0.0 1.0.0; \
    test "$(git -C "$d" log -1 --format=%s)" = "feat: smoke"; \
    test "$(git -C "$d" tag --points-at HEAD)" = "1.0.0"; \
    test -n "$(git -C "$d" rev-parse HEAD)"; \
    rm -rf "$d" /tmp/smoke_key /tmp/smoke_key.pub; \
    grep -q '^ID="opensuse-tumbleweed"' /usr/lib/os-release

USER 1000
WORKDIR /workspace

ENTRYPOINT ["/usr/local/bin/yasrt"]
CMD ["--help"]
