# Pkl Templates and Schemas

Patterns for authoring templates and schema-backed configuration. See `language-reference.md` for semantics.

## Choose the shape

- **Untyped config** — one-off data with no reuse. Plain properties, objects, listings, mappings. No classes.
- **Typed template/schema** — a model others amend or import. Declare `class`es, annotate every property, give defaults, add constraints, and configure `output`. Consumers import/amend it and get validation.

A file is a template by *intent*, not syntax: nothing distinguishes it structurally. Convention: name templates PascalCase, put a `module` clause on them, and document them with `///`.

## Template anatomy

```pkl
/// Configuration for one deployment pipeline.
@ModuleInfo { minPklVersion = "0.24.0" }
module com.example.Deploy

class Deployment {
  /// Human-facing name.
  name: String(length > 0)

  /// Git branch to build from.
  branch: String

  /// Optional build timeout.
  timeout: Duration(isPositive)?
}

/// Pipelines that will run.
pipelines: Listing<Deployment>

output {
  // Json/Yaml cannot natively render Duration/DataSize/... — teach the renderer:
  renderer = new YamlRenderer {
    converters {
      [Duration] = (d) -> "\(d.value) \(d.unit)"
    }
  }
}
```

Consumers then fill it in:

```pkl
amends "Deploy.pkl"

pipelines {
  new {
    name = "release"
    branch = "main"
    timeout = 10.min
  }
}
```

Run `pkl eval -f yaml config.pkl` to render.

## Schema patterns

### Typed nested objects, listings, mappings

```pkl
class Session { time: Duration; date: String }

class Event { name: String; year: Int }

event: Event
instructors: Listing<String>
sessions: Listing<Session>
assistants: Mapping<String, String> // fixed value type, open key set
agenda: Mapping<String, TutorialPart>  // TutorialPart is an imported module
```

- `Listing<T>` beats `List<T>` for literal data and for anything a consumer might amend.
- `Mapping<K,V>` beats `Map<K,V>` for the same reason.
- Declaring `Listing<T>`/`Mapping<K,V>` also gives each `new {}` element the default of `T`/`V`, so `new { ... }` is enough inside.

### Reuse via imported module as a type

```pkl
import "TutorialPart.pkl"

agenda: Mapping<String, TutorialPart>
```

An imported module is usable directly as a type; `new {}` then amends that module.

### Enums and legacy data

```pkl
typealias Diet = "Seeds" | "Berries" | "Insects"
diet: Diet = "Seeds"

// legacy payloads where a value may be several shapes:
value: String | Int | Mapping<String, String> = "unset"
```

Union types have no implicit default; mark one branch with `*` (`*"sum" | "mean" | "count"`) or give an explicit value.

### Constraints and informative errors

```pkl
class Pipeline {
  timeout: Int(this >= 3)

  name: String(nameRequiresBranchName)?

  hidden nameRequiresBranchName = (_) ->
      if (branchName == null)
        throw("Pipelines that set a 'name' must also set a 'branchName'.")
      else true

  branchName: String?
}
```

- Prefer a boolean-predicate constraint when it is self-explanatory; define a `local` lambda when reused.
- Use `throw(...)` with a readable sentence when the rule is complex or application-specific.

### Optional blocks with nullable defaults

A property typed `X?` where `X` has a default is "off" by default (`Null(x)`) but can be amended into existence:

```pkl
class Pet { name: String; animal: String = "bird" }
pet: Pet?
```

```pkl
amends "template.pkl"
pet { name = "Parry the Parrot" }   // switches the block on
```

Use `pet {}` to switch on defaults with no overrides, or omit it to stay `null`.

### Derived and fixed values

```pkl
class Bird {
  wingspan: Int
  weight: Int
  fixed wingspanWeightRatio: Int = wingspan / weight   // computed, not assignable
}
```

`const` additionally forbids references to non-`const` module members — required when a class body, annotation body, or constrained typealias references module members. Either mark the referenced member `const`, or self-import the module and reference `Module.member`.

## Output and renderers

```pkl
output {
  value = pipelines                       // default: the whole module (`outer`)
  renderer = new YamlRenderer {}          // Json, Yaml, Pcf, PList, Properties, xml, protobuf, jsonnet

  // Teach the renderer to handle types YAML cannot express:
  // renderer = new YamlRenderer { converters { [DataSize] = (s) -> "\(s.value) \(s.unit)" } }

  // Path-based converters target specific fields:
  // converters { ["quota.memory"] = (s) -> "\(s.value) \(s.unit)" }

  // Bypass value/renderer entirely:
  // text = "raw output"
}
```

- Format precedence: `--format`/`-f` selects the default renderer, but a module that configures `output.renderer` uses **its own** renderer regardless of `-f`. Omit `output.renderer` if you want callers to choose the format.
- `Duration`, `DataSize`, `Regex`, `Pair`, and functions are not natively renderable by Json/Yaml/etc.; add a converter (`converters { [Duration] = (d) -> "\(d.value) \(d.unit)" }`) or the render errors.
- Renderers reject objects that mix properties/entries with elements. Use `Listing`/`Mapping` for anything that must render to JSON/YAML arrays/objects.
- Multi-file output (requires `-m <dir>`):

```pkl
output {
  files {
    ["birds/pigeon.json"] { value = pigeon; renderer = new JsonRenderer {} }
    ["birds/parrot.yaml"] = parrot.output
  }
}
```

`pkl eval -m out/ birds.pkl`. Keys are paths relative to the output dir; escaping it is an error; parent dirs are created. Get the extension programmatically with `parrot.output.renderer.extension`.

- Add files conditionally with the `when` generator — `if` is an expression only and cannot guard a block:

```pkl
output {
  files {
    ["app.conf"] { text = "..." }
    when (env == "staging") { ["db.conf"] { text = "..." } }   // omitted when false; `else { ... }` optional
  }
}
```

Alternatively spread a typed `Mapping`: `local extra: Mapping<String, FileOutput> = if (cond) new { ["db.conf"] { text = "..." } } else new {}` then `...extra` inside `files`.

## Projects and dependencies

`PklProject` (no extension) amends `pkl:Project`; it provides shared evaluator settings, package dependency management, packaging, and dependency-notation imports.

```pkl
amends "pkl:Project"

dependencies {
  ["birds"] { uri = "package://example.com/birds@1.0.0" }
}

package {
  name = "mypackage"
  baseUri = "package://example.com/\(name)"
  version = "1.0.0"
  packageZipUrl = "https://example.com/\(name)/\(name)@\(version).zip"
}
```

- `pkl project resolve` writes `PklProject.deps.json` (latest semver minor per package; idempotent).
- `pkl project package` prepares publishable artifacts.
- Import a dependency with `import "@birds/Bird.pkl"`.
- Local dependency: `["fruit"] = import("../fruit/PklProject")` (its `PklProject` must define `package`); import as `@fruit/Pear.pkl`.
- Local paths starting with `@` need a `./` prefix to avoid dependency notation.

## Testing

Test modules extend `pkl:test` and run with `pkl test <file>`:

```pkl
amends "pkl:test"

facts {
  ["arithmetic"] {
    1 + 1 == 2
    "abc".length == 3
  }
}
```

- `facts`: boolean assertions; failures report power-assertion diagrams.
- `examples`: map names to rendered output compared against `pkl-expected.pcf`; `--overwrite` regenerates them. The value is typically `(someCommandModule) { options { ... } }.output.text`.
- Renderers in test files are ignored by `pkl test`.
- Options include `--junit-reports`, `--test-reporter spec|minimal`, `--overwrite`.

## Validation checklist

1. `pkl eval -f pcf <file>` — structure, types, constraints, required properties.
2. `pkl eval -f <target> <file>` — actual rendering; watch for mixed-member object errors.
3. `pkl eval -x '<expr>' <file>` — probe individual values without rendering everything.
4. `pkl format --diff-name-only <file>` — style; `pkl format -w` to fix.
5. `pkl test <file>` — if the module defines tests.

Common errors: undefined property (missing value or no default), type mismatch, constraint violation, unknown property on a typed object (typo or non-amendable member), and duplicate member from spread.