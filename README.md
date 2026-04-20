# GodPool

> Control the pool of Gods offered to you and the number of Gods available in the pool.

Part of the [Run Director modpack](https://github.com/h2pack-rundirector/run-director-modpack).

## What It Does

GodPool controls the Olympian side of the run pool before individual boon filtering happens.

The module lets you:

- set the maximum number of Olympian gods that can enter a run
- enable or disable each Olympian god individually
- decide whether god keepsakes are allowed to add a new god to the pool
- prevent early Selene and Hermes appearances
- force a hammer into the first room
- guarantee an element reward from the gathering tool

Use it when you want to shape which Olympian sources are even eligible to participate in the run before a module like BoonBans starts filtering individual boons.

## Current Coverage

- `God Pool`
  Per-god toggles for Aphrodite, Apollo, Ares, Demeter, Hephaestus, Hera, Hestia, Poseidon, and Zeus.
- `Max Gods Per Run`
  Caps how many Olympian gods can enter the run.
- `God Keepsakes Add to The Pool`
  Controls whether keepsakes can introduce a new god that was not already in the active pool.
- `Prevent Early Selene/Hermes`
  Suppresses those early appearances so the run opens more cleanly around the main Olympian pool.
- `Guarantee Element from Gathering Tool`
  Forces the gathering-tool reward support behavior on.
- `Force Hammer First Room`
  Pushes the opening room toward a hammer start.

## Installation

Install via [r2modman](https://thunderstore.io/c/hades-ii/) or manually place in your `ReturnOfModding/plugins` folder.

This module is usually installed as part of the full [Run Director modpack](https://github.com/h2pack-rundirector/run-director-modpack), where it appears in the shared Run Director UI with the other run-control modules.
