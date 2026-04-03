# Go — Language and Framework Standards

Apply these rules when working in any Go package in this repository.

---

## Project Initialisation

Run these commands to scaffold a new Go project. Do not create files by hand.

```bash
go mod init github.com/<owner>/<repo-name>
mkdir -p cmd/<repo-name> internal
cat > cmd/<repo-name>/main.go << 'EOF'
package main

func main() {}
EOF
git add go.mod cmd/ internal/
```

- `go mod init` writes the correct installed Go version into `go.mod` automatically — never edit `go.mod` by hand.
- Commit: `chore: scaffold Go project structure`

---

## Build Verification

After any change to Go source, imports, or dependencies — run in this order:

```bash
go mod tidy
go build ./...
go test ./...
```

Never claim an implementation is complete without all three passing.

---

## Coding Standards

- **Context propagation**: Every I/O function (DB, HTTP, Kafka) accepts `context.Context` as first parameter and propagates it. Never use `context.Background()` inside business logic — only at entry points.
- **Nil safety**: Check all pointer, interface, slice, and map returns before use.
- **Panics**: Never use `panic` in business logic. Handlers must recover from unexpected panics.
- **Interface design**: Define interfaces at the point of consumption. Keep them small and focused. Accept interfaces, return concrete types.
- **Struct initialisation**: Always use named fields — positional initialisation is prohibited.
- **Constants**: Numeric literals and strings with business meaning must be named constants. Timeouts, retry counts, and thresholds come from YAML config.
- **Time**: Never call `time.Now()` inside business logic — inject as a parameter. Store/publish UTC. Use `.Equal()`, `.Before()`, `.After()` for comparison.
- **Financial values**: All financial values use `github.com/shopspring/decimal` — no float types. Read precision from `DecimalDigits int32` config field — never hardcode.
- **Sensitive data**: Never log subscriber identifiers, balances, or transaction amounts. Never return internal errors or stack traces to API callers. Credentials in YAML config only.
- **Concurrency**: Protect shared mutable state with `sync.Mutex`, `sync.RWMutex`, atomics, or channels. Every goroutine must terminate via context or stop channel. Run `go test -race ./...` for concurrent code.

---

## Error Handling

- All domain errors use typed error structs with a `Code` type and constructor functions — reference: `internal/chargeengine/ocserrors/errors.go`
- Never use `fmt.Errorf` or `errors.New` for domain errors
- Error codes must be meaningful stable identifiers: `"UNKNOWN_SUBSCRIBER"`, `"OUT_OF_FUNDS"`
- Use `errors.As` for type assertions — never string comparison
- `fmt.Errorf` is permitted only for wrapping infrastructure errors (DB, network, I/O)

---

## Testing

**Commands:**
```bash
go test ./...                    # all tests
go test -race ./...              # required for concurrent code
go test ./internal/quota/...     # specific package
go test -run TestName ./...      # specific test
```

**Requirements:**
- Every Go source file with functions must have an accompanying `_test.go` file
- Files that only declare structs, constants, types, or interfaces are exempt
- Tests must run and pass — writing without running does not satisfy this rule
- Unit tests must NOT require external services (PostgreSQL, Kafka)

**Table-driven tests** — required for functions with multiple input/output combinations:
```go
tests := []struct {
    name     string
    input    SomeType
    expected SomeResult
}{
    {name: "zero value returns default", ...},
    {name: "negative amount returns error", ...},
}
for _, tc := range tests {
    t.Run(tc.name, func(t *testing.T) { ... })
}
```

**Test naming:** `TestFunctionName_Scenario_ExpectedBehaviour`
e.g. `TestDebitQuota_InsufficientBalance_ReturnsOutOfFunds`

---

## Architecture Boundaries

- Transport handlers must be thin — delegate all logic to services
- No business logic in HTTP or Diameter handlers
- All database access through repository interfaces in `internal/store/`
- Kafka consumers must delegate to services — no business logic in consumers
- New applications must follow structural patterns of existing applications
- Configuration from YAML only — no environment variables in application code

---

## Dependency Management

- Prefer libraries already used in the project over introducing new ones
- Verify new module paths on `pkg.go.dev` before adding — do not assume import paths
- If internet access is unavailable, state explicitly that verification was not performed
- Never modify files marked `// Code generated ... DO NOT EDIT` — re-run the generator

---

## Contract Structures — Go-Specific Rules

For the full contract framework and approval rules, see AGENTS.md — "Contract Rules".

**Kafka event structs** in `internal/events/` are identified by:
- Structs with a field typed as `*EventType` (e.g. `WholesaleContractEventType`)
- Structs referenced in consumer `handleRecord` switch statements
- Any struct with JSON tags that is `json.Unmarshal`-ed from a Kafka record

**Database-serialised structs** are identified by:
- Structs stored via `json.Marshal` into a `pgtype.JSONB` column
- Any struct referenced in a sqlc query as a JSON column type

**Never add internal domain IDs to event structs.** Generate any internal identifier inside the service layer after consuming the event.

**`internal/events/` is read-only** for AI agents unless the task explicitly states "modify the event schema" and a human has approved it.

---

## Documentation

- All public functions and methods must have a Go doc comment
- Comments must describe what and why — not restate the code
