# AI Context Map (AGENTS.md)

**Welcome.** If you are an AI assistant or agent interacting with this codebase, this document is your primary source of truth. It is designed to help you quickly understand the project's architecture, execution flow, and future roadmap so you can assist effectively without losing context.

## 1. Project Identity & Goal
This project is a highly customized C/C++ cryptocurrency miner, forked from the `ccminer` architecture.
*   **Primary Target:** It is currently strictly optimized for mining **Verus Coin (VerusHash)**.
*   **Build System:** Autotools (`configure.ac`, `Makefile.am`). We use a custom `./build.sh` script.
*   **Portability:** The build process is intentionally configured to statically link `libcurl`, `OpenSSL`, `zlib`, and `jansson` (using a bundled version in `compat/jansson`) to ensure the resulting binary (`ccminer`) is fully portable across different Linux distributions (especially fresh Docker containers) without dependency hell.

## 2. Directory Tree & Module Locations
Understanding where things live is critical for future scaling.

```text
.
├── ccminer.cpp           # The main entry point. Handles arg parsing, thread creation, and core execution loop.
├── build.sh              # The primary build script. (Runs build-libcurl.sh, autogen, configure, make).
├── build-libcurl.sh      # Downloads and statically compiles a minimal libcurl without bloat.
├── Makefile.am           # Defines linking flags (forces static linking for core network/crypto dependencies).
├── configure.ac          # Defines system checks and sets up static/dynamic fallback logic.
├── miner.h / algos.h     # Core header files defining the `work` structs, algorithm definitions, and global state.
├── verus/                # [CORE MODULE] Contains the VerusHash algorithm implementations.
│   ├── verus_hash.cpp    # High-level VerusHash logic.
│   ├── haraka.c          # Haraka v2 hash function (core to VerusHash).
│   ├── verus_clhash.cpp  # CLHash implementation used by Verus.
│   └── verusscan.cpp     # The actual hash-scanning loop (`scanhash_verus`) called by miner threads.
├── equi/                 # Legacy/Alternative algorithm module (Equihash - partially implemented/leftover from ccminer).
├── compat/               # Cross-platform compatibility layers and bundled libraries.
│   └── jansson/          # Bundled JSON parsing library (statically linked to avoid libjansson.so errors).
├── pools.cpp             # Pool management, failover logic, and connection routing.
├── util.cpp              # General utilities, logging (`gpulog`), JSON RPC calls, and standard Stratum connection handling.
├── api.cpp               # A local API server thread that can be queried for miner stats.
└── hashlog.cpp / stats.cpp # Hashrate calculation and statistic tracking.
```

## 3. Main Execution Flow
When the binary is executed, the flow generally follows this pattern inside `ccminer.cpp`:

1.  **Initialization (`main()` in `ccminer.cpp`):**
    *   Parses command-line arguments (pool URL, user, pass, algorithm, thread count).
    *   Initializes global variables, thread contexts (`thr_info`), and connects to the primary pool.
2.  **Thread Spawning:**
    *   `workio_thread`: Handles fetching work from non-stratum RPC pools (fallback).
    *   `longpoll_thread`: Listens for longpolling updates from pools.
    *   `stratum_thread`: **(Primary)** Maintains the persistent TCP Stratum connection to the mining pool, receives new jobs, and submits shares (`util.cpp` handles the socket/JSON logic).
    *   `api_thread`: Starts a local server to serve statistics to local monitoring tools.
    *   `miner_thread`: Spawns $N$ instances (based on `-t` or CPU cores).
3.  **Mining Loop (`miner_thread` -> `scanhash_verus`):**
    *   The miner thread waits for a valid `work` packet from the stratum thread.
    *   It passes the data to the specific algorithm scanner (currently `scanhash_verus` in `verus/verusscan.cpp`).
    *   The scanner iterates through nonces, hashing the block header (using `haraka` and `verus_clhash`).
    *   If a hash meets the pool's target difficulty, it is passed back to `submit_nonce()` and sent to the pool via the Stratum thread.

## 4. Network & Communication
*   **Current State:** The miner relies exclusively on the standard **Stratum protocol** for receiving jobs and submitting shares. The Stratum logic relies on the statically linked `libcurl` for initial handshakes and pure sockets/JSON (`jansson`) for the persistent TCP connection.
*   **Important Files:** `util.cpp` (JSON parsing, socket handling), `pools.cpp` (Stratum session state).

## 5. Future Roadmap & Scaling Plans
As you (the AI) help scale this project, keep these future goals in mind. They dictate how you should write new code:

1.  **Metamorphic Obfuscation & Polymorphism:**
    *   **Goal:** Prevent code theft, signature detection, and third-party analysis.
    *   **Implementation Strategy:** In the future, we will implement dynamic rewriting of the mining engine (`verus/` directory). When adding new features to the core hashing loops, design them in a way that allows function pointers, instruction substitution, or macro-based polymorphism to be injected easily later. Avoid rigid, easily signaturable assembly blocks if possible, or isolate them so they can be scrambled at compile/runtime.
2.  **Remote Telemetry (VPS Integration):**
    *   **Goal:** Connect the miner to a remote VPS for real-time monitoring (status, hashrates, worker health) independently of the mining pool.
    *   **Implementation Strategy:** We will need to build custom API/RPC interactions. We should expand upon the existing `api.cpp` (which currently only serves local requests) or create a new `telemetry.cpp` module that uses our statically linked `libcurl` to POST JSON payloads to a remote server asynchronously.

**End of AI Context Map.** Always check this file first when starting a new task to understand the boundaries and goals of the project.