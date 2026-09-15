---
name: pkl
description: Write, edit, and review Pkl configuration and template files (.pkl, PklProject). Use when creating or modifying Pkl code, defining typed schemas or templates for configuration, producing YAML/JSON/plist/XML/properties output via pkl eval, managing Pkl projects and package dependencies, or when the user mentions Pkl, pkl eval, PklProject, or .pkl files.
---

# Writing Pkl

Pkl is a configuration language built on immutable objects, amending, and late binding.
It is renderer-agnostic: one `.pkl` source can emit YAML, JSON, plist, XML, properties, and more.

Ground every claim in the docs under `docs/modules/language-reference`, `docs/modules/language-tutorial`, and `docs/modules/style-guide` when working inside the pkl repo.
Always validate with `pkl` (installed CLI) before declaring a file correct.

## Workflow

1. Decide the artifact's role. A *template/schema* (imported or amended by others) declares `class`es and typed properties with defaults and constraints. A *config* fills in values by amending a template or defining untyped literals.
2. Write the module header in the required order (see below).
3. Define members in style-guide order: properties, then methods, then classes/typealiases, then `output`.
4. Validate: `pkl eval -f pcf <file>` (structural check), then `pkl eval -f <target-format> <file>` for the real output. Use `-x '<expr>'` to evaluate a single expression, e.g. `pkl eval -x 'foo.bar' file.pkl`.
5. Format: `pkl format -w <file>` (or `pkl format --diff-name-only` to check). Two-space indent, 100-column lines.
6. Tests, if the file defines tests: `pkl test <file>`.

## Module file structure

Clauses must appear in this order; each section separated by one blank line.

```pkl
/// Module doc comment (Markdown).
@ModuleInfo { minPklVersion = "0.24.0" }
module com.example.MyModule   // module clause

amends "Base.pkl"             // OR extends "Base.pkl"; at most one; before imports

import "util.pkl"             // imports after amends/extends, before the body
import "pkl:math"

// body: properties, methods, classes/typealiases, output
```

- `amends` obtains a template's type and structure and fills it in; the amending module **cannot add** members (except `local`).
- `extends` adds members; the extended module must be declared `open module`.
- `import "x.pkl"` binds a `const local` property named after the file (`pigeon.pkl` -> `pigeon`); rename with `as`, or scope inline with `import("...")`.
- `import* "birds/*.pkl"` yields a `Mapping` of matches; `read*()` and glob patterns work the same way for resources.

## Syntax cheat sheet

```pkl
// literals
n = 1_000_000            // Int; also 0x1F, 0b1010, 0o755
f = 1.23e-2              // Float; .23, NaN, Infinity
b = true
s = "Hi, \(name)!"       // interpolation; \n \t \" \\ \u{1F600}
raw = #"C:\path\"#       // custom delimiters: escape char becomes \#
ml = """
  line one
  line two
  """                    // indentation measured against the closing """

d = 30.min               // Duration: ns us ms s min h d
size = 100.mb            // DataSize: b kb mb gb tb pb | kib mib gib tib pib

// collections
list = List(1, 2, 3)                 // eager
set = Set(1, 2, 3)
map = Map("a", 1, "b", 2)
mapping = new Mapping { ["a"] = 1 }  // ordered; prefer Mapping over Map in schemas
pair = Pair("a", 1)
re = Regex(#".+@.+"#)

// objects: properties, elements, entries (can be mixed, but most renderers cannot)
bird {
  name = "Pigeon"        // property
  "seed"                 // element (indexed by int, zero-based)
  ["diet"] = "Seeds"     // entry (keyed)
  local scratch = 1      // local: lexical scope only
}

class Bird {
  hidden internals: String = "not rendered, not converted"  // class/module members only
  name: String
}
```

Property forms:

```pkl
a = value                       // untyped
b: String = "x"                 // typed with default
c: String                       // typed, no default (uses type default / errors if none)
d: UInt16                       // predefined range aliases: Int8..UInt32, UInt, Uri
e: Listing<Bird>                // generic types
f: Bird?                        // nullable
g: "a" | "b" | *"c"             // union; * marks the default branch
h: String(length >= 3)          // type constraint
i: Bird = (base) { name = "x" } // amends expression
j { k = 1 }                     // amends declaration: amends super.j or Dynamic
k = new { name = "x" }          // contextual new (use when type is known)
l = new Bird { name = "x" }     // explicit new (only when type is not known)

fixed derived = other * 2       // cannot be assigned/amended
const species = "Pandion"       // fixed + may only reference const members
```

Classes and functions:

```pkl
abstract class Bird { name: String }
open class Pigeon extends Bird { diet: String = "Seeds" }
class Falcon extends Bird {
  function dive(speed: Int): String = "diving at \(speed)"
}
```

Type annotations are optional (`unknown` when omitted) — but schema-backed models should type every property.

## Amending and late binding

- Amending produces a new object and **never changes its type**. Amending a typed object cannot add properties.
- A property defined in terms of another re-evaluates when the dependency is amended:

```pkl
penguin { eggIncubation = 40.d; adultWeight = eggIncubation.value * 100 }
madeUp = (penguin) { eggIncubation = 11.d }
// madeUp.adultWeight == 1100
```

- Inside an amending body, `this` is the current receiver, `super` the parent in the prototype chain, `outer` the enclosing lexical object (not chainable; use a `local self = this` pattern for deeper references).
- Mixins: `withDiet = new Mixin { diet = "Seeds" }`, applied with the pipe: `pigeon |> withDiet`.

## Generators, spread, and predicates

```pkl
birds {
  for (name, lifespan in namesToLifespans) {     // for generator
    [name] { name = name; lifespan = lifespan }
  }
  when (includeParrot) { ["Parrot"] = 20 } else { ["Falcon"] = 15 }
  ...otherBirds                                   // spread object members
  ...?maybeBirds                                  // nullable spread (skips null)
  [[this is Bird]] { canFly = true }              // member predicate
}
```

Prefer `for` generators over the collection API: they preserve late binding.

## Conditionally adding members

`if` is an expression (`if (c) a else b`) — there is no statement-level `if` block, so it cannot be used to conditionally add object members. Use the `when` generator instead; it works in any object body, including `output.files`:

```pkl
output {
  files {
    ["app.container"] { text = "..." }
    when (env == "staging") {
      ["influx.container"] { text = "..." }
      ["couchdb.container"] { text = "..." }
    }
  }
}
```

`when (cond) { ... }` contributes nothing when `cond` is false; `else { ... }` is optional. To build the conditional value separately, use a typed `Mapping` and spread it:

```pkl
local extra: Mapping<String, FileOutput> =
  if (env == "staging") new { ["influx.container"] { text = "..." } } else new {}

output { files { ["app.container"] { text = "..." }; ...extra } }
```

- `new { ... }` inherits `V`'s default (here `FileOutput`) from the declared `Mapping<K, V>` type, so entry values are typed. A bare `new Mapping { ... }` has no such context and makes every entry value `Dynamic`; either annotate the property (`Mapping<K, V>`) or pass type arguments (`new Mapping<K, V> { ... }`).
- `...extra` spreads a `Mapping` directly; a `Map` must be converted first (`...m.toMapping()`).

## Templates and output

- Typed data models: declare `class`es, type properties, give defaults, and constrain values (`Int(isBetween(0, 1023))`, `String(matches(Regex(...)))`). Constraint expressions can `throw()` for readable messages.
- Nullable `X?` defaults to `Null(x)` when `X` has a default — amend it to "switch it on": `pet { name = "Parry" }`.
- `Duration`, `DataSize`, `Regex`, `Pair`, and functions are not natively renderable by Json/Yaml/etc.; add a converter or rendering fails.
- Control rendering in-language:

```pkl
output {
  value = birds                       // defaults to `outer` (whole module)
  renderer = new YamlRenderer {}      // Json, Yaml, Pcf, PList, Properties, xml, protobuf, jsonnet
  // renderer = new YamlRenderer { converters { [DataSize] = (s) -> "\(s.value) \(s.unit)" } }
  // text = "raw final output"        // bypasses value/renderer
  files {                             // multi-file output (pkl eval -m <dir>)
    ["birds/pigeon.json"] { value = pigeon; renderer = new JsonRenderer {} }
  }
}
```

## Critical gotchas

- Objects are immutable and lazily evaluated. Converting to an eager type (`toList()`, `toMap()`) resolves all references permanently; convert back explicitly (`toListing()`, `toMapping()`).
- `name { ... }` amends whatever `name` resolves to; listing elements are written `new { ... }`, never `name { ... }` (that would define a property).
- Renderers reject objects mixing properties/entries with elements — use `Listing` or `Mapping` for collections.
- A module's own `output.renderer` overrides `pkl eval -f <format>`; omit it to let callers pick the format.
- `class` is a keyword; quote it as `` `class` ``.
- Union types have no default unless one branch is marked `*`; string literal unions (`"a"|"b"`) are the enum idiom.
- `nothing` has no values; `unknown` is both top and bottom type. Unannotated members are `unknown`.
- Methods take positional parameters only — no named or default parameters.
- Spread and duplicate keys conflict; `Mapping` keys are eagerly evaluated while values are lazy.
- Classes, annotations, and typealiases are not late-bound: they may only reference `const` module members (or self-import the module).
- `UInt`'s maximum is `Int`'s maximum (9,223,372,036,854,775,807), not `2*Int.MaxValue`.
- Reserved words that cannot be plain identifiers: `protected`, `override`, `record`, `delete`, `case`, `switch`, `vararg`. Use backticks.
- `if` is an expression, never a statement: `if (c) a else b` (the `else` is required). For conditional members use `when (cond) { ... } else { ... }` or spread a conditional `Mapping`; an `if` block in an object body is a syntax error.
- `Map` is an external class — `new Map { ... }` fails ("Cannot instantiate, or amend an instance of, external class `Map`"), surfacing when the value is evaluated (objects are lazy). Construct with `Map(k1, v1, k2, v2, ...)` and convert with `toMapping()`. `Mapping` is a distinct, non-open class: `new Mapping { ... }` / `new Mapping<K, V> { ... }` work, it spreads directly (`...m`), and it converts with `toMap()`. `Map` and `Mapping` are not assignable to each other.
- Entry values in a `new Mapping { ... }` literal are `Dynamic` unless the literal carries type arguments (`new Mapping<K, V> { ... }`) or the enclosing declared type supplies `V`'s default (bare `new { ... }`).

## Style (summary; full rules in references/style-guide.md)

- `.pkl` files only, UTF-8. PascalCase for template/class files, camelCase for value files, kebab-case for CLI tools, and match the output filename when a file renders to a static config (`config.pkl` -> `config.yml`). `PklProject` has no extension.
- Two-space indent, max 100 columns (string literals and doc-comment snippets excepted). Opening brace stays on the same line.
- One blank line at most between members; separate successive property definitions with a blank line.
- Every newly defined property gets a type annotation and a doc comment; overridden properties get neither.
- Prefer `new {}` over `new Foo {}` when the property's type is known, and prefer interpolation (`"\(x)"`) over concatenation.
- Use custom string delimiters (`#"..."#`) for strings dense in `\` or `"`, e.g. regexes.
- Imports are naturally sorted; relative/package imports get their own section; no unused imports. Prefer `.../ancestor.pkl` over stacked `../`.

## References

- `references/language-reference.md` — complete condensed language reference: values, objects, listings, mappings, classes, modules, imports, type system, constraints, generators, spread, annotations, projects, name resolution. Read when you need exact semantics or a feature not covered above.
- `references/templates.md` — schema/template authoring patterns, validation, renderer configuration, multi-file output, projects and packages.
- `references/style-guide.md` — the Pkl team's full style guide with good/bad examples.