# Custom VerusHash ccminer

This repository contains a highly customized fork of the classic `ccminer` architecture, heavily optimized and geared specifically toward mining **Verus Coin (VerusHash)**.

> **Note for AI Assistants/Agents:** If you are an AI assistant helping to write or analyze this code, please refer to the [`AGENTS.md`](AGENTS.md) file located in the root directory. It contains a detailed context map, architectural breakdown, and future roadmap specifically designed for you.

## Overview

This miner focuses on performance and maximum portability. The build system has been carefully structured to partially statically link the core networking and cryptographic libraries (`libcurl`, `OpenSSL`, `zlib`, and `jansson`).

This ensures that the final `ccminer` binary can be transferred to virtually any modern Linux distribution—including bare-bones Docker containers—without failing due to missing shared object errors (e.g., `libcurl.so.4: cannot open shared object file`).

## Building from Source

To compile the miner, you only need standard build tools (like `build-essential`, `automake`, `pkg-config`) installed on your Linux system.

Run the provided build script:

```bash
chmod +x build-libcurl.sh build.sh autogen.sh configure.sh
./build.sh
```

**What this script does:**
1. Triggers `./build-libcurl.sh` to download and compile a highly minimal, static version of `libcurl` directly into the `curl-static/` directory. This strips out bloated features (LDAP, RTMP, SSH) to keep the binary clean and secure.
2. Runs the standard `autogen.sh` and `configure.sh` process.
3. Automatically sets up `Makefile` to statically link the newly built libcurl, OpenSSL, zlib, and the bundled `jansson` library.
4. Compiles the `ccminer` executable.

## Usage

Once compiled, you can run the miner as usual. Example for mining Verus:

```bash
./ccminer -a verus -o stratum+tcp://<pool_address>:<port> -u <wallet_address>.<worker_name> -p x -t <number_of_threads>
```

## Architecture Map

For a deep dive into the directory structure, main thread execution flow (`main() -> miner_thread -> scanhash_verus`), and network layer, please view the [AGENTS.md](AGENTS.md) file.

## Future Plans
* Implementation of metamorphic code obfuscation and polymorphism to prevent signature detection and reverse-engineering.
* Remote telemetry modules for pushing real-time worker health, hashrate, and status updates to a centralized VPS.