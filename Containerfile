# syntax=docker.io/docker/dockerfile-upstream:1.29.0@sha256:572cebbc2b15e6f84c077742952674889cb63cd5e9b80abdffcbe587b6f19183
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
ARG TW_SNAPSHOT_AARCH64=20261116.1795023659-18f20df5-17d29f4a665e2bc0c8e2f5db22c18e802e62fd81818bed611aa2475b6b430dce
# renovate: datasource=custom.koh-snapshot depName=aarch64
ARG KOH_SNAPSHOT_AARCH64=20261119.1795051352-0f8d89a7654768e8018282aa436ba6111b2ade453ee44f775b495f3c4338a7c8

FROM registry.ole-hartwig.eu/devops/images/tumbleweed-builder:1@sha256:e4d5e6818bc8d9326e16865684abc512303faf4f9e384b0ab65b6ec8eda7be45 AS rootfs
ARG TW_SNAPSHOT_AARCH64
ARG KOH_SNAPSHOT_AARCH64
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
