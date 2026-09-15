# Pkl Language Reference (condensed)

Distilled from `docs/modules/language-reference`. Pkl version target: 0.32.x.
Use `pkl eval -f pcf <file>` to check a file compiles, `pkl eval -x '<expr>' <file>` to probe one expression.

## Contents

1. [Comments](#comments)
2. [Numbers, booleans](#numbers-booleans)
3. [Strings](#strings)
4. [Durations and data sizes](#durations-and-data-sizes)
5. [Objects](#objects)
6. [Property modifiers](#property-modifiers)
7. [Listings](#listings)
8. [Mappings](#mappings)
9. [Classes and inheritance](#classes-and-inheritance)
10. [Methods](#methods)
11. [Modules](#modules)
12. [Module output](#module-output)
13. [Type system](#type-system)
14. [Null values](#null-values)
15. [Expressions and utilities](#expressions-and-utilities)
16. [Advanced topics](#advanced-topics)
17. [Diagnostics and tooling](#diagnostics-and-tooling)

## Comments

```pkl
// line comment
/* nestable
   block comment */
/// Doc comment, one per line, merged; Markdown with CommonMark + GFM tables.
dodo: Bird
```

Doc comments attach to modules, classes, typealiases, properties, methods. First paragraph is the summary.
Link members with `[name]`, custom text `[text][name]`.

## Numbers, booleans

- `Int` is 64-bit signed; literals decimal, `0x`, `0b`, `0o`, with `_` separators. Overflow errors.
- `Float` is 64-bit double; `.23`, `1.23`, `1.23e2`, `1_000.4_400`. Specials: `NaN`, `Infinity`, `-Infinity`.
- Operators: `+ - * / ~/ % **`, comparisons `== < > <= >=`, logical `&& || !`, `.xor()`, `.implies()`.
- `/` always returns `Float`; `~/` is integer division (always `Int`). `%` remainder.
- Prefer `Number` over `Float` in annotations when a zero-fraction value is acceptable.
- Ranges: use predefined aliases (`UInt8`, `UInt16`, `UInt32`, `Int8`, `Int16`, `Int32`, `UInt`, `Uri`) or `Int(isBetween(0, 1023))`, `Float(isFinite)`.

## Strings

- `String` is a sequence of Unicode code points. Literals use `"..."` with Swift 5-like escapes: `\t \n \r \" \\`, unicode `\u{1F600}`.
- Concatenate with `+`; interpolate with `\(expr)` (result is converted to string).
- Multiline literals: `"""` — content starts on the next line, closing delimiter on its own line. Line indentation is measured relative to the closing delimiter's indentation; further leading whitespace is preserved. A trailing `\` suppresses the line break.
- Custom delimiters: `#"..."#`, `##"..."##`, … each extra `#` changes the escape character (`\#`, `\#\#`, …). Use for regexes and backslash-heavy strings.

```pkl
str = """
  Although the Dodo is extinct, \
  the species will be remembered.
  """
emailRegex = Regex(#"([\w\.]+)@([\w\.]+)"#)
```

Useful API: `length`, `reverse()`, `contains()`, `trim()`, `matches(regex)`, `toInt()`, `split()`, `base64DecodedBytes`.

## Durations and data sizes

- `Duration`: value + unit in `DurationUnit`. Construct via `5.ns 5.us 5.ms 5.s 5.min 5.h 3.d`; negative and fractional allowed (`-5.min`, `5.13.min`). `.value` and `.unit` access components.
- `DataSize`: value + unit in `DataSizeUnit`. Decimal: `5.b 5.kb 5.mb 5.gb 5.tb 5.pb`; binary: `5.kib 5.mib 5.gib 5.tib 5.pib`. `.value`, `.unit`, `.toUnit("mb")`.
- Both support comparison and the numeric arithmetic operators. Both prevent unit errors that plague plain numbers.

## Objects

An object is an ordered collection of values indexed by name. Three member kinds, freely mixable:

- **properties**: `name = value`, `name { ... }`, `name: Type = value`
- **elements**: bare expressions, indexed zero-based (`obj[0]`)
- **entries**: `["key"] = value`, `["key"] { ... }`; keys can be any value

Property values are lazily evaluated on first read. Objects are immutable.

```pkl
dodo { name = "Dodo"; extinct = true }
tortoise = (dodo) { name = "Galápagos tortoise" }   // amends expression; parens required
```

- `foo { ... }` is an *amends declaration*: shorthand for `foo = (super.foo) { ... }`. It amends an existing parent property of the same name, otherwise it implicitly amends `Dynamic`.
- Chained amending is allowed: `pigeon { ... } { ... }`, `(x) { ... } { ... }`.
- **Late binding**: a property defined in terms of another re-evaluates when the dependency is amended. Treat properties like spreadsheet cells; amending makes a new "copy".
- Transforming an object: `obj.toMap()` -> transform with `Map` API -> `.toDynamic()` / `.toTyped(Class)`. Conversion is lazy -> eager and severs late binding.

### Dynamic vs Typed

- `Dynamic` (untyped) has no fixed structure; amending may add properties.
- `Typed` is backed by a `class`; amending may override/amend existing properties but not add new ones (`Cannot find property ...`).
- Every module is a typed object; its properties are the module class.

## Property modifiers

- `hidden` — omitted from rendered output and conversions; ignored for equality/hashing. Still accessible by name.
- `local` — visible only in the lexical scope of its definition; observable as not part of the object. Allowed on listings/mappings. Import clauses are effectively `const local`.
- `fixed` — cannot be assigned to or amended when defining an instance/amending. Fixedness must be preserved when overriding in a subclass. Use for derived values (`fixed wingspanWeightRatio = wingspan / weight`) and class-tied constants.
- `const` — `fixed` plus may only reference other `const` members (and its own body). Not late-bound. Class bodies, annotation bodies, and typealiased constrained types may only reference `const` module members; the alternative is self-importing the module and referencing through it.

## Listings

`Listing` is an ordered, indexed collection of elements; elements are lazy and late-bound, indexed zero-based.

```pkl
birds = new Listing {
  new { name = "Pigeon"; diet = "Seed" }
  new { name = "Parrot"; diet = "Berries" }
}
first = birds[0].name

birds2 = (birds) {
  new { name = "Barn owl"; diet = "Mice" }  // plain element = ADD
  [0] { diet = "Worms" }                    // amend element at index
  [1] = new { name = "Albatross" }          // replace element at index
}
```

- Elements can reference earlier elements via `this[index]`; amendment propagates (late binding).
- Declaring `x: Listing<T>` initializes an empty listing whose default element is `T`'s default, so `new { ... }` inherits `T`'s defaults. Constrain with `Listing<T>(isDistinct)` or `isDistinctBy((it) -> it.name)`.
- Transform via `toList()` -> `List` API -> `.toListing()`. Most renderers treat lists like listings, so conversion back is often unnecessary.
- `default { ... }` element supplies shared defaults; it is late-bound and can be amended retroactively.

## Mappings

`Mapping` is an ordered collection of values indexed by key. Keys are eager; values are lazy and late-bound.

```pkl
birds = new Mapping {
  ["Pigeon"] { lifespan = 8; diet = "Seeds" }
  ["Parrot"] = (this["Pigeon"]) { lifespan = 20 }
}
ParrotDiet = birds["Parrot"].diet

birds2 = (birds) {
  ["Barn owl"] { lifespan = 15 }   // new key = ADD
  ["Pigeon"] { diet = "Seeds" }    // existing key = amend value
  ["Parrot"] = new { lifespan = 20 }  // replace value
}
```

- Declaring `x: Mapping<K, V>` initializes an empty mapping whose default value is `V`'s default.
- `default { key -> ... }` / `default { ... }` supplies per-entry defaults (function amending; see below).
- Transform via `toMap()` -> `.toMapping()`. Prefer mappings over maps in schemas.
- `Mapping` is non-open and distinct from `Map`; neither is assignable to the other. `new Mapping {}` / `new Mapping<K, V> {}` create one but it cannot be extended. `Map` is external: `new Map {}` is an error (`Cannot instantiate, or amend an instance of, external class Map`), raised when the value is evaluated — construct with `Map(k1, v1, k2, v2, ...)`.
- Entry values in a `new Mapping { ... }` literal are `Dynamic` unless the literal carries type arguments (`new Mapping<K, V> { ... }`) or the enclosing declared type `Mapping<K, V>` supplies `V`'s default (bare `new { ... }`).
- Spread a `Mapping` directly (`...m`); a `Map` converts first (`...m.toMapping()`). `when (cond) { ... } else { ... }` adds members conditionally in place of a statement-level `if`.

## Classes and inheritance

```pkl
class Bird { name: String }
abstract class Base { }               // cannot be instantiated
open class Parent extends Base { }     // `open` required for extension
class Child extends Parent { }
```

- Single inheritance; top is `Any`, bottom is `nothing`.
- Instances: `new Bird { ... }` (explicit) or `new { ... }` when the target type is known from context.
- Misspelled/new properties on typed instances are errors; wrong value types are errors.
- `getClass()` returns the `Class` value.
- Prefer typed objects for schema-backed data models; dynamic objects for schema-less/ad-hoc data.
- `Dynamic` can be converted with `toTyped(Class)`.

## Methods

```pkl
class Bird {
  name: String
  function greet(other: Bird): String = "Hello, \(other.name)!"
}
function greetPigeon(bird: Bird): String = bird.greet(pigeon)  // module method
```

- `function` defines methods on classes and modules; single dispatch on receiver runtime type; overridable in subclasses/submodules; call parent with `super.method(...)`.
- No named parameters, no default parameter values, no arity/type-based overloading.
- For parameterless behavior prefer a `fixed` property over a method.
- `function TODO(): nothing = throw("TODO")` — `nothing` return means it never returns normally.

## Modules

Every `.pkl` file is a module; a module is a typed object. Runtime type is a subclass of `Module`.

### Names and URIs

- Optional module clause: `module com.animals.Birds` (qualified names recommended for shared modules). Otherwise the name is inferred from the URI's filename.
- URI schemes: `file:///path/x.pkl`, `https://...`, `modulepath:/x.pkl` (`--module-path`), `package://host/pkg@1.0.0#/x.pkl`, `pkl:math` (stdlib), relative paths (`parrot.pkl`, `/animals/birds/x.pkl`), triple-dot `.../foo/bar.pkl` (searches ancestors), dependency notation `@birds/bird.pkl`.
- Evaluate URIs directly: `pkl eval`, `pkl eval pkl:math`, `pkl eval --module-path=... modulepath:/x.pkl`.
- Triple-dot never resolves to the current module. Importing a relative path starting with `@` requires a `./` prefix to avoid dependency notation.
- `pkl:` modules are the standard library; `pkl:base` members are always in scope without importing.

### Amends / extends

```pkl
// template.pkl
name: String
timeout: Int(this >= 3)
```

```pkl
amends "template.pkl"

name = "x"
timeout = 3
```

- At most one `amends` or `extends` clause; never both. An amending module has the same module class: it can only override existing members (plus `local` ones). This catches typos immediately.
- `extends` requires the target to be declared `open module`; it defines a new module class and may add members and functions.

### Imports

- Order: module clause, amends/extends clause, import clauses, body.
- Import name = URI minus scheme, minus up-to-last-slash, minus `.pkl`. Use `as` to rename; `import("...")` imports a value without a type; import clauses define `const local` properties (hence usable as types).
- `import* "<glob>"` -> `Mapping` keyed by matched path. Only `file` and `package` schemes glob for modules (within a package only the asset path globs). Reads glob `modulepath`, `file`, `env`, `prop`.

### Security

- Module allowlist (`--allowed-modules`), resource allowlist (`--allowed-resources`): comma-separated regexes matched as URI prefixes.
- Trust levels (highest to lowest): `repl:` > `file:` > `modulepath:` > other (`https:`) > `pkl:`. A module may only load modules of equal or lower trust.

## Module output

Default output is the whole module rendered as PCF.

```pkl
output {
  value = birds                                        // defaults to `outer`
  renderer = new YamlRenderer {}                       // Json/Yaml/Pcf/PList/Properties/xml/protobuf/jsonnet
  // text = "final output"                             // bypass renderer entirely
}
```

- CLI form: `pkl eval -f yaml|json|pcf|plist|properties|xml|textproto|jsonnet|pkl-binary file.pkl`. `-f` sets the *default* renderer; a module that sets `output.renderer` uses its own renderer regardless of `-f`.
- Renderers accept value converters, by class or by path:
  `converters { [DataSize] = (s) -> "\(s.value) \(s.unit)" }`, `["quota.memory"] = (s) -> ...`.
- Annotation-based converters: `ConvertProperty` and subclasses.
- Multi-file output:

```pkl
output {
  files {
    ["birds/pigeon.json"] { value = pigeon; renderer = new JsonRenderer {} }
    ["birds/parrot.yaml"] = parrot.output       // aggregate another module's output
  }
}
```

Run with `pkl eval -m <outdir> birds.pkl`. Paths escaping the output dir error; parent directories are created; file extensions via `pigeon.output.renderer.extension`.
- Custom renderers extend `ValueRenderer`.

## Type system

Type annotations are optional (omitted = `unknown`) and serve documentation, runtime validation, defaults, and codegen.

### Forms

- Class types: `Bird`; module types: `pigeon: bird` (an imported module used as a type); `module` is the enclosing module's self type (self type follows extension).
- Type aliases: `typealias EmailAddress = String(matches(Regex(#".+@.+"#)))`; parameterized `typealias StringMap<Value> = Map<String, Value>`.
- Nullable: `Bird?` admits `null`. `Any` and `Null` admit `null` implicitly; `Any?` == `Any`.
- Generics: `Pair<A,B>`, `Collection<T>`, `Listing<T>`, `List<T>`, `Mapping<K,V>`, `Set<T>`, `Map<K,V>`, `Function0`..`Function5`, `Class<T>`. Omitting args means `unknown`.
- Unions: `A | B`; a value is either. No implicit default unless one branch is starred: `"a"|*"b"` -> default from `"b"`.
- String literal types: `"Seeds"`; enumerate via `typealias Diet = "Seeds"|"Berries"|"Insects"`.
- `nothing`: bottom type, assignment-compatible everywhere, has no values.
- `unknown`: both top and bottom type; static analyzers back off.

### Default values

| Type | Default |
| --- | --- |
| `Collection<T>` / `List<T>` / `Set<T>` / `Map<K,V>` | empty collection |
| `Listing<T>` | empty listing; default element = default of `T` |
| `Mapping<K,V>` | empty mapping; default value = default of `V` |
| non-external class `X` | `new X {}` |
| `X?` | `Null(x)` if `X` has default `x`, else `null` |
| string literal type `"a"` | `"a"` |
| `Null` | `null` |
| union | none, unless a branch is starred with `*` |

No implicit defaults for: `abstract` classes (incl. `Any`, `NotNull`), unions without `*`, external classes (`String`, `Boolean`, `Int`, `Float`, `Duration`, `DataSize`, `Pair`, `Regex`). Reading an undefined property throws.

### Constraints

```pkl
class Bird {
  name: String(length >= 3)
  parent: String(this != name)
  email: String((str) -> str.matches(Regex(#".+@.+"#)))
  port: UInt16(this > 1000)
}
```

- Comma-separated boolean expressions in parens; `this` is the value being validated. Constraints may be lambdas for reuse.
- Composite types constrain parts and/or the whole: `Map<String(!isEmpty), String(emailAddress)>(length <= 5)`.
- `is` / `as` test and cast: `42 is Number`, `value as List<String>`.

## Null values

- `null` is `Null(new Dynamic {})`; `Null(x) { ... }` is equivalent to `x { ... }`. All null values compare equal.
- `!!` asserts non-null; `??` supplies a default; `?.` null-safe member access; `ifNonNull((it) -> ...)` generalizes `?.`.
- Nullable properties default to "switched off" but amendable to the underlying default — the template idiom for optional blocks.

## Expressions and utilities

```pkl
result = if (cond) a else b             // expression only; else required; no statement form
name = let (x = expensive()) x + x      // immutable local; stackable; typed: let (x: Int = 1)
value = throw("fatal; errors are unrecoverable")
traced = trace(expr)                    // prints to stderr, returns expr
port = read?("env:PORT")?.toInt() ?? 1234
path = read("env:PATH")
files = read*("birds/*.pkl")
```

Resource schemes: `env:`, `prop:` (from `-p name=value`), `file:`, `http(s):`, `modulepath:`, `package:`; relative URIs resolve against the module. Resources are cached after first read.

## Advanced topics

### Meaning of `new`

- `new Type { ... }` amends `Type`'s default value. In `Listing`/`Mapping`, an explicitly typed `new` bypasses the enclosing `default`.
- `new { ... }` infers the parent: the declared property's default (or `Dynamic` if untyped); an element/entry amends `default` applied to that index/key. Otherwise: "Cannot tell which parent to amend".
- Method parameter annotations do not participate in inference; annotate the argument explicitly.

### Anonymous functions, mixins, function amending

```pkl
add = (a, b) -> a + b
added = add.apply(2, 3)
num = 4 |> mul3 |> add2                 // single-arg pipe
withDiet = new Mixin { diet = "Seeds" } // mixin; typed: new Mixin<Bird> { ... }
seedPigeon = pigeon |> withDiet
factor = (n: Number(isPositive)) -> if (n < 2) n else n * factor.apply(n - 1)
```

- Anonymous functions are `Function0`..`Function5` values (max 5 params), closures over lexical scope, recursive via `.apply`.
- An anonymous function returning an object can be amended with object syntax; parameters can be named after `{`: `default { key -> name = key }`. This is how `Listing.default` and `Mapping.default` work.

### Generators and spread

```pkl
birds {
  for (_name in names) { new { name = _name } }              // element generator
  for (_key, _value in map) { [_key] { v = _value } }        // entry generator
  when (cond) { a = 1 } else { a = 2 }
  ...otherObject        // spread (properties/entries/elements)
  ...?maybeObject       // nullable spread == when (x != null) { ...x }
  [[name == "PARROT"]] { value = "new-value" }               // member predicate
}
```

- Iterables: `IntSeq`, `List`, `Set`, `Map`, `Bytes`, `Listing`, `Mapping`, `Dynamic`. Indices are zero-based; `for` may generate elements/entries but not properties with non-constant names.
- Spread unpacks `Dynamic`/`Listing`/`Mapping` members (typed objects are not iterable); other iterables produce elements (or entries for `Map`). Duplicate keys are errors.

### Keywords and identifiers

- `this`: enclosing receiver; in a type constraint, the tested value; in a member predicate, the matched member.
- `outer`: receiver of the immediately outer lexical object; not chainable.
- `super`: parent in the prototype chain; must be followed by member access or subscript.
- `module`: as a value, the enclosing module's receiver; as a type, its class.
- Quoted identifiers: backtick any illegal/reserved name, e.g. `` `class` ``, `` `A Bird's Time` ``.
- Reserved (unusable without backticks): `protected`, `override`, `record`, `delete`, `case`, `switch`, `vararg`.
- Blank identifier `_` ignores a parameter/binding; `_` alone is never a valid identifier (backtick it to use).

### Annotations

```pkl
@SomeAnnotation
module myModule

class SomeAnnotation extends Annotation { description: String = "some annotation" }

class Bird {
  @SomeAnnotation { description = "some property" }
  name: String
  @Unlisted
  function greet(g: String): String = g
}
```

Annotation instances use `@ClassName` instead of `new`; body omitted when no overrides. Multiple annotations per member; annotations go after the doc comment and before the member. Metadata is available via `pkl.reflect` and the Java API.

### Name resolution and prototype chain

- LAMP lookups (let, anonymous-fn param, method param, property): search lexically enclosing scopes outward to module top level; then `pkl.base` top-level; then the prototype chain of `this`.
- Method calls: lexical scopes; then `pkl.base`; then the class inheritance chain of `this`. No arity/type overloads.
- Prototype chain of an object runs from the amends chain (bottom: the object itself) through the top object's class prototype, then superclass prototypes up to `Any`. The receiver is the bottom-most object, so inside an amended object `this` is the amended one.
- Non-object values chain through their class prototypes.

### Projects and packages

`PklProject` (no extension) amends `pkl:Project`:

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

- `pkl project resolve` writes `PklProject.deps.json`, picking the latest semver minor per package (MVS-like, idempotent).
- `pkl project package` prepares publishable artifacts.
- Local dependencies: `["fruit"] = import("../fruit/PklProject")`, then import with `@fruit/Pear.pkl`.
- Import dependencies with dependency notation `@birds/Bird.pkl`.
- Mirrors via `--http-rewrite from=to`. External readers via `--external-resource-reader` / `--external-module-reader` or `evaluatorSettings`.

### Glob patterns

`*` (no `/`), `**` (crosses `/`), `?`, `[...]` character classes (negate with `!`, ranges), `{a,b}` sub-patterns (not nestable), escapes `\[ \* \? \\ \{`.
Unlike shells, `*` matches dot-prefixed names. Files globbing skips `.`/`..` and does not follow symlinks. Prefer custom string delimiters when embedding escapes: `import*(#"\{foo.pkl"#)`.

## Diagnostics and tooling

```bash
pkl eval -f pcf file.pkl          # structural check
pkl eval -f json file.pkl         # render
pkl eval -x 'birds[0].name' file.pkl
pkl format -w file.pkl            # format in place (check: --diff-name-only, exit 11)
pkl test file.pkl                 # run tests
pkl analyze imports file.pkl      # import graph
pkl repl                          # interactive
```

Error messages print the failing constraint, the offending value, and both the expectation site and value site with clickable source links.