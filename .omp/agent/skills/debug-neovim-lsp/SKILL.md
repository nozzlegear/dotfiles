---
name: debug-neovim-lsp
description: Debug Neovim LSP servers and configurations — servers not attaching, missing diagnostics/hover/completion, silent config failures, environment problems, and F#/C# (.NET) language servers. Use when an LSP client is defined but never starts, starts but produces no diagnostics, or features work in one project but not another; also for headless testing of LSP setups and for isolating client-vs-server-vs-environment failures.
---

# Debugging Neovim LSPs and Configurations

Diagnose LSP failures by isolating the layers: client attach → server process environment → server-internal workspace loading → per-file routing. Most "server starts but does nothing" failures are (a) environment variables not reaching the spawned process, or (b) the server's workspace never loading for the opened file.

## First Moves

1. **Check attach before blaming the server.** In the live session:
   `:lua print(vim.inspect(vim.lsp.get_clients({bufnr = 0})))`
   Zero clients = attach problem (enable list, filetype mismatch, config error). Client present = server-side problem. These are different investigations.
2. **Confirm the server is in the `vim.lsp.enable` list.** A `vim.lsp.config` entry alone does nothing — it must also be enabled. This exact mistake shipped unnoticed once.
3. **Read the LSP log**, not just `:messages`: `~/.local/state/nvim/lsp.log`. Server stderr is mirrored there line by line. Filter by timestamp; stale failures from prior sessions mislead.
4. **Find the server's own logs.** Many servers (Rust hosts, sidecars) write their real diagnostics to `$TMPDIR` subdirectories, not the LSP log. Grep for `workspace/open`, `initialized`, `Sidecar error`, `SDK discovery` — failure lines carry the actual cause; the LSP-facing symptom is usually downstream.

## Test in Headless Mode

Headless runs make the loop scriptable and reproducible:

```lua
-- nvim --headless -c 'lua ...' -c 'qa!'
local buf = vim.fn.bufadd("/abs/path/to/file.ext")
vim.fn.bufload(buf); vim.api.nvim_set_current_buf(buf); vim.cmd("edit")
print("M1 filetype:", vim.bo.filetype)
local id = vim.lsp.start({ name = "srv", cmd = {...}, root_dir = "...",
  filetypes = {...}, capabilities = vim.lsp.protocol.make_client_capabilities() })
local c = vim.lsp.get_client_by_id(id)
vim.wait(20000, function() return c and c.initialized end)
print("M2 initialized:", c ~= nil and c.initialized)
-- Inject a UNIQUE broken line, then wait for THAT symbol to appear in a
-- diagnostic - `#vim.diagnostic.get(buf) > 0` is true instantly if any
-- pre-existing diagnostic (hint, unused-open) exists, and the wait exits
-- before the server ever reacts to the change.
vim.api.nvim_buf_set_lines(buf, -1, -1, false, { "let broken = undefinedSymbolInjected42" })
vim.wait(60000, function()
  for _, d in ipairs(vim.diagnostic.get(buf)) do
    if d.message:find("undefinedSymbolInjected42") then return true end
  end
  return false
end)
print("M3 diagnostics:", vim.inspect(vim.tbl_map(function(d) return d.severity, d.code, d.message end, vim.diagnostic.get(buf))))
```

Print `M1`/`M2`/`M3` markers with `io.stdout:flush()` so partial output survives timeouts.

Known headless quirks — do not misdiagnose these:
- `vim.lsp.enable` attaching nothing headless has **real, fixable causes** — do not write it off as a quirk before checking both:
  1. `config.root_dir` signature: `enable`'s FileType handler calls `root_dir(bufnr, on_dir)` and spawns only from inside `on_dir`. `lspconfig.util.root_pattern` returns an old-style `(filename) -> string` function that never calls `on_dir` — silent no-op, no error, no log, interactive too. Wrap: `function(bufnr, on_dir) on_dir(root_pattern(...)(vim.api.nvim_buf_get_name(bufnr))) end`.
  2. Missed FileType events: some filetypes get their FileType event during init, before `enable` registers its autocmd, and `enable`'s own catch-up is guarded by `vim_did_enter`/`did_filetype()` (both false in this state — `did_filetype()` returns 0 even after detection). Add a one-shot `VimEnter` autocmd that runs `vim.cmd("doautoall nvim.lsp.enable FileType")`. Note `VimEnter` never fires under `--headless`; verify the mechanism by calling `doautoall nvim.lsp.enable FileType` directly in the test.
- Instrument the enable path by wrapping `vim.api.nvim_get_autocmds({group = "nvim.lsp.enable"})`'s callback (delete + recreate with a logging wrapper) — the runtime's failure is silent by design.
- Stale swap files abort `bufload` with `E325` — delete `~/.local/state/nvim/swap/*.swp` for the target file first. Timed-out headless runs leave these behind.
- `capabilities = require("cmp_nvim_lsp").default_capabilities()` resolves to a **table** in the stored config, not a function.
- Audit `vim.lsp.enable` names against the actual `lsp/<name>.lua` files (`vim.api.nvim_get_runtime_file("lsp/*.lua", true)`): an unknown name resolves to a config with nil cmd and never attaches, with no error anywhere. Names are lspconfig's (`html`, `jsonls`, `lua_ls`, `yamlls`, `ts_ls`, `svelte`, `astro`), not the server binary names.

## Trace the Event Chain When the Runtime Fails Silently

`vim.lsp.enable` failures produce no error, no notify, and no log. When manual `vim.lsp.start` works but enable doesn't, instrument the *events* instead of the spawn:

- **Timing matters: `--cmd` vs `-c`.** `-c` runs after the file's FileType has already fired, so observers registered there miss the interesting events. Register observers with `--cmd` (runs before init) to capture the full startup sequence.
- **Observer set:** a groupless FileType autocmd logging `ft` + buffer; a wrapper around `vim.lsp.enable` that re-registers the enable group's autocmd with logging (see quirks above); a wrapper around `vim.lsp.start` logging `name`, `root_dir` type, and return id.
- **Diff a working filetype against the broken one.** Run the identical instrumented flow for both (e.g. `.yml` attaches, `.lua` doesn't) and compare event ordering: which events fire before vs after the enable autocmd exists. One working/broken pair pins the defect faster than reading runtime source.
- **Signals that lie:** `vim.bo.filetype` is set while `vim.fn.did_filetype()` returns 0 (both for working and broken filetypes in 0.12.5 headless) — did_filetype is not proof the event fired. Check whether the *observer autocmd* actually ran; that's the ground truth.

## Verify Requests, Not Connectivity

A client attached and initialized does not mean features work. Three traps from real sessions:

- **Requests queue during workspace load.** Polling `hover`/`request_sync` while a server is still building its design-time workspace returns `null` for every request, often all at once after the load finishes (the log shows N "returned null" lines at the same millisecond). Wait for the server's own "workspace opened" log line, or poll with long deadlines. Cold first loads of large solutions take minutes; warm reruns are seconds — rerun before concluding failure.
- **Null can be the correct answer.** Hover on a keyword, whitespace, or a position between tokens returns null legitimately. Hover a concrete symbol (pick a type name from the file, compute its character offset).
- **Wait conditions must target the new signal.** `#vim.diagnostic.get() > 0` succeeds instantly on pre-existing diagnostics. Wait for a diagnostic whose message contains your injected symbol (see the harness above).

## Environment Variables Do Not Pass Through LSP Config

`env = { FOO = "bar" }` in `vim.lsp.config` / `vim.lsp.start` is **silently dropped** — the child inherits Neovim's full environment, not the provided table. The documented field is **`cmd_env`** (`vim.lsp.ClientConfig`: "Environment variables passed to the LSP process on spawn"); it merges with the inherited environment. Verify with a probe:

```lua
vim.lsp.start({ name = "envtest", cmd = {"/bin/sh", "-c", "env > /tmp/probe.txt"},
  cmd_env = { FOO = "bar" } })
-- then inspect /tmp/probe.txt for FOO and for PATH
```

Fallback when a config layer strips it: `vim.env.FOO = "value"` during init — every spawned child inherits it, but it leaks globally. When a server needs a version-specific path, prefer stable aliases (`/opt/homebrew/opt/<pkg>/...`) over Cellar version paths.

Watch for servers whose *apphost or wrapper* starts successfully in an incomplete environment while an internal subsystem (SDK discovery, MSBuild, BuildHost spawn) fails later — `READY` output is not proof that discovery succeeded. Read the server's own startup warnings.

## Isolate the Server From the Client

If the environment looks right but the server still misbehaves, drive the server directly:

- **Standard stdio LSP servers:** pipe JSON-RPC (`initialize` → `initialized` → `textDocument/didOpen` → `textDocument/diagnostics` waits) and read responses.
- **Custom-IPC servers:** inspect the wire format in the server's source (length-prefixed MessagePack envelopes are common); a ~50-line Python/JS driver with a venv-installed msgpack library beats guessing through Neovim.

A direct test that *succeeds* while the Neovim-mediated path *fails* proves the problem is the spawn environment or client transport, not the server binary. Vary one env dimension per run (`DOTNET_ROOT` present/absent, `PATH` stripped) and diff the failure signatures.

Failure-signature cheat sheet (.NET-flavored servers):
- `Could not load file or assembly 'Microsoft.Build...' ... cannot find the file specified` → SDK/MSBuild never registered; check `DOTNET_ROOT` and SDK discovery warnings.
- `An error occurred trying to start process 'dotnet'` → `dotnet` missing from the process `PATH`; BuildHost-style child spawn failed.
- `WARNING: ... Roslyn ... version mismatch` → usually cosmetic; verify workspace load still succeeds before treating it as the cause.

## F# and .NET Workspace Realities

- An F# file only gets project-aware analysis if it is a `<Compile>` item in a loaded `.fsproj`. Standalone `/tmp` scratch files produce nothing, and "file was not part of the project" errors mean the *server's loaded project list* does not contain the file — which can be a server bug (wrong project loaded), not user error. Check which project the server actually loaded in its log before assuming the fsproj is at fault.
- Verify diagnostics with real broken code **inside a real project** — temporarily corrupt line 0 of an existing project file, wait for `publishDiagnostics`, then revert. Zero diagnostics on clean code proves nothing.
- Multi-project solutions: confirm the server loads *all* projects, not just the first discovered. Grep the server log for the project list ("found N projects; loading X") and compare against `dotnet sln list`.

## Log Reading Discipline

- Server logs are append-only across sessions — always filter to the current run's timestamp window before drawing conclusions.
- The host/client log shows one layer (envelope traffic); sidecar/server logs show the real cause. Read both for the same time window.
- Success signatures to confirm before declaring victory: workspace/solution opened, analyzers configured, diagnostics published with real codes (e.g. `FS0039`, `CS0246`) — not `count=0` on a file you broke.
