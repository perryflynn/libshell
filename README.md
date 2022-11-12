# libshell

The beginning of a collection of functions for smart bash shell scripts.

## Features

### configkey

`configkey` allows to define configuration parameters via JSON or Environment Variables.

See the [test cases](./tests/testconfigkey.sh) for code examples.

- Multiple JSON files for separate configurations per deploy environment (`config.dev.json`, `config.test.json`, `config.json`)
- Override values from JSON files by environment variables (supports separate deploy environments as well)

**Usage:**

```sh
#!/bin/bash
. src/libshell.sh

configkey foo.bar
```

**Example 1:** Single config file:

- `config.json`: `{ "foo": { "bar": "Hello World" } }`

Output: `Hello World`

**Example 2:** Override by environment variable:

- `config.json`: `{ "foo": { "bar": "Hello World" } }`
- `LIBSHELL_FOO__BAR="Lorem Ipsum"`

Output: `Lorem Ipsum`

**Example 3:** Multiple JSON files and define deploy environment:

- `config.json`: `{ "foo": { "bar": "Hello World" } }`
- `config.test.json`: `{ "foo": { "bar": "Hallo Welt" } }`
- `LIBSHELLENV=test`

Output: `Hallo Welt`

**Example 4:** Define environment variable for specific deploy environment:

- `LIBSHELLENV=test`
- `LIBSHELL_FOO__BAR="Hello World"`
- `LIBSHELL_TEST_FOO__BAR="Lorem Ipsum"`

Output: `Lorem Ipsum`

**Example 5:** Change environment variable prefix:

```sh
#!/bin/bash
CONFIGKEYPREFIX=MYAPP
. src/libshell.sh

configkey foo.bar
```

- `config.json`: `{ "foo": { "bar": "Hello World" } }`
- `LIBSHELL_FOO__BAR="Lorem Ipsum"`
- `MYAPP_FOO__BAR="Hallo Welt"`

Output: `Hallo Welt`

## Tests

Tests run by `shellcheck` and `bats`.


