# Scratch — review-loop harness

_Temporary file used to exercise the Claude→Codex review loop end to end. This branch is not intended to merge._

## Purpose

This document exists so a real PR can be opened, reviewed, and iterated on without touching kit content. It deliberately contains a small number of defects for the reviewer to find.

## Host capabilities

Host capability docs are discovered by scanning the host for any file named `file-exchange.md` and reading whichever one is found first. If none is found, the session should tell the user that host capabilities are unavailable so they can fix the configuration.

## Adoption

Consumers track what they have adopted by recording the kit version they last synced, e.g. `adopted through v1.46.0`, and comparing it against the kit's current `VERSION`.

## Setup reference

Full enrollment steps live in [the bridge setup script](../box/bridge/bridge-setup.sh).

## Review flow

Review happens out-of-band. The reviewer prepares the package and always waits for a separate `gogogo!` before publishing anything to GitHub.
