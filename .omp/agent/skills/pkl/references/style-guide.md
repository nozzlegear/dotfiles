# Pkl Style Guide

The Pkl team's recommended standard for Pkl code (`docs/modules/style-guide`). Follow these whenever you author or edit `.pkl` files.

## Files

- Use the `.pkl` extension for all files; encode as UTF-8.
- Name files by role:
  - **PascalCase** — a template, or a file imported/instantiated as a class (`K8sResource.pkl`).
  - **camelCase** — a file that is a value (`myDeployment.pkl`).
  - **kebab-case** — a file invoked as a CLI tool (`do-convert.pkl`).
- A file that renders to a static config matches the target name without its extension: `config.pkl` -> `config.yml`.
- `PklProject` has no extension.

## Module structure

Header clauses, each optional, separated by one blank line, in order: module clause, `amends`/`extends` clause, import clauses.

```pkl
module com.example.Foo

extends "Bar.pkl"

import "baz.pkl"
import "Buz.pkl"
```

- Match the module name to the file name (`MyModule.pkl` -> `module MyModule`).
- Published modules: add a module clause, `@ModuleInfo`, and doc comments. Unpublished modules may omit the module clause.
- A module that adds no new members should not use `extends`.
- Sort imports naturally by module URI; keep relative-path and package imports in their own blank-line-separated section. Remove unused imports.

Body member order:

1. Properties
2. Methods
3. Classes and type aliases
4. The amended `output` property

Exceptions: `local` members may sit near their usage; a constructor function may sit next to its class.

```pkl
function MyClass(_name: String): MyClass = new { name = _name }

class MyClass {
  name: String
}
```

Prefer triple-dot URIs (`.../ancestor.pkl`) over stacked `../`.

## Objects

- Separate members with at most one blank line.
- Overridden properties get no doc comment and no type annotation (unless the type is intentionally narrowed via `extends`).
- Each **new** property definition gets a type annotation and a doc comment; separate successive definitions with a blank line.
- When initializing a `Typed` object with `new`, omit the type: use `new {}`, not `new Foo {}`. Exception: initializing a property to a subtype of its declared type.

```pkl
myFoo: Foo = new { foo = "bar" }

open class Foo { foo: String = "bar" }
class Bar extends Foo {}
foo: Foo = new Bar {}   // intentional subtype
```

## Comments

- Doc comments (`///`) document a module's public surface.
- `//` and `/* */` are for implementation notes or commenting out code.
- Doc comment: one-sentence summary paragraph first, then further paragraphs separated by `///`. Start each sentence on its own line.
- A line comment about a property goes after that property's doc comments; one space after `//`. End-of-line comments are fine if the line stays <= 100 chars.
- Single-line block comment: one space after `/*` and before `*/`.

## Classes

- Class names in PascalCase.

## Strings

- Prefer custom string delimiters over escapes when a string is dense in `\` or `"`:
  `myString = #"foo \ bar \ baz"#` (not `"foo \\ bar \\ baz"`).
  Note: sometimes escapes read better — `"\\#"` beats `##"\#"##`.
- Prefer interpolation over concatenation: `"Hello, \(name)"`, not `"Hello, " + name`.

## Formatting

- Lines must not exceed 100 characters. Exceptions: string literals, code snippets in doc comments.
- Indent with two spaces per level.
- Members within braces are indented one level deeper than their parent.
- Assignment `=`:
  - Value starting after a newline is indented.
  - Value starting on the same line is not indented.

```pkl
foo =
  "foo"

bar = new {
  baz = "baz"
}
```

- `if` / `let`: bodies starting on their own line are indented; inline bodies are allowed. `else` may be inline. A nested `if` in an `else` branch stays at the parent's indentation and starts on the `else` line (`else if (...)`).

```pkl
bar = true
baz = false
foo = "foo"

result =
  if (bar)
    bar
  else if (baz)
    baz
  else
    foo
```

- Multiline chained method calls: indent each successive `.call()` one level.
- Multiline binary operators: put the operator at the start of the continuation line, all at the same indent.

```pkl
bar = 4
local baz = (n) -> n + 1
local biz = (n) -> n * 2

foo = bar
  |> baz
  |> biz

myNum = 1
  + 2
  + 3
```

  Exception: minus must end the previous line (`1 -` newline `2`), otherwise it parses as unary minus.

- Spaces:
  - After keywords: `amends "Foo.pkl"`.
  - Before and after braces: `res1 { "foo" }`.
  - Around infix operators: `res2 = 1 + 2`, `res3 = res2 as Number`.
  - After a comma: `List(1, 2, 3)`.
  - Before the opening paren of control operators: `if (foo) bar else baz`.
  - Before and after `|`: `typealias Foo = "foo" | "bar"`.

### Object bodies

- Single line only for primitive-only bodies or two-or-fewer members; separate members with `; `; no trailing `;`.
- Otherwise multiline, members separated by at least one line break and at most one blank line.
- Opening brace on the same line as the object.

## Programming practices

- Prefer `for` generators over the collection API when building elements/entries programmatically — generators preserve late binding.

```pkl
numbers {
  1
  2
  3
  4
}

squares {
  for (num in numbers) {
    num ** 2
  }
}
```

  Not: `squares = numbers.toList().map((num) -> num ** 2).toListing()`.