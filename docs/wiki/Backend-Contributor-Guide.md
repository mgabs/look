# Backend Contributor Guide

See the full **[Developer & Contributor Guide](Developer-and-Contributor-Guide.md)** for complete build and testing workflows.

## Edit Map

* **Query parsing**: `core/engine/src/query.rs`
* **Scoring & Ranking**: `core/engine/src/scoring.rs`, `core/engine/src/config.rs`
* **Search orchestration**: `core/engine/src/search.rs`
* **Filesystem indexing**: `core/engine/src/index/*`
* **Persistence & Migrations**: `core/storage/src/lib.rs`
* **C FFI endpoints**: `bridge/ffi/src/*_api.rs`

## Verification

```bash
make core-check
make ffi-check
cargo test --workspace --manifest-path core/Cargo.toml
```
