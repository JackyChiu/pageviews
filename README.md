# `pageviews`

An experimental project to compute the top 25 viewed Wikipedia pages in a given hour
using Elixir and it's [GenStage](https://github.com/elixir-lang/gen_stage) and [Flow](https://github.com/plataformatec/flow/) library.

## Components

### `Pageviews.Wiki`
Streams the data from Wikipedia to itself and acts as a GenStage producer with back pressure.

### `Pageviews`
Consumes and processes data from `Pageviews.Wiki` with Flow.

### `Pageviews.Topviews`
Agent used to store the top 25 pageviews pages seen.

## Run

```bash
# clone project

mix deps.get
mix run
```
