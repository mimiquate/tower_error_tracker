# TowerErrorTracker

[![ci](https://github.com/mimiquate/tower_error_tracker/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/mimiquate/tower_error_tracker/actions?query=branch%3Amain)
[![Hex.pm](https://img.shields.io/hexpm/v/tower_error_tracker.svg)](https://hex.pm/packages/tower_error_tracker)
[![Documentation](https://img.shields.io/badge/Documentation-purple.svg)](https://hexdocs.pm/tower_error_tracker)

[Tower](https://github.com/mimiquate/tower) reporter for [ErrorTracker](https://github.com/elixir-error-tracker/error-tracker).

## Installation

Package can be installed by adding `tower_error_tracker` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:tower_error_tracker, "~> 0.3.4"}
  ]
end
```

> [!NOTE]
> Don't list `:error_tracker` in the dependencies, it is already included as part of `:tower_error_tracker`.
> If you really must list it, list it with [`runtime: false`](https://hexdocs.pm/mix/Mix.Tasks.Deps.html#module-dependency-definition-options), so you don't get [duplicated](https://github.com/mimiquate/tower_error_tracker/issues/38) errors reports.

## Usage

Tell `Tower` to inform `TowerErrorTracker` reporter about errors.

```elixir
# config/config.exs

config(
  :tower,
  :reporters,
  [
    # along any other possible reporters
    TowerErrorTracker
  ]
)
```

And configure and set up `:error_tracker` new database tables by following just these two ErrorTracker sections:

- [Configure](https://github.com/elixir-error-tracker/error-tracker/blob/main/guides/Getting%20Started.md#configuring-errortracker)
- [Set up the database](https://github.com/elixir-error-tracker/error-tracker/blob/main/guides/Getting%20Started.md#setting-up-the-database)


That's it.

It will try report any errors (exceptions, throws or abnormal exits) within your application. That includes errors in
any plug call (including Phoenix), Oban job, async task or any other Elixir process.

### Manual reporting

You can manually report errors just by informing `Tower` about any manually caught exceptions, throws or abnormal exits.


```elixir
try do
  # possibly crashing code
rescue
  exception ->
    Tower.report_exception(exception, __STACKTRACE__)
end
```

More details on https://hexdocs.pm/tower/Tower.html#module-manual-reporting.

## License

Copyright 2024 Mimiquate

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
