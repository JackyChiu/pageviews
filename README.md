# `pageviews`

An experimental project to compute the top 25 viewed Wikipedia pages in a given hour.
This gave me the opportunity to play around with Elixir and it's [GenStage](https://github.com/elixir-lang/gen_stage) and [Flow](https://github.com/plataformatec/flow/) libraries.

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

### Sample Output

```
22:03:58.379 [info]  Starting run...

22:03:58.490 [info]  Requesting data for 2019-05-23 at 02h

22:04:19.130 [info]  HTTP request done streaming
TOP: [
  {"Mauro_Icardi", 8987},
  {"Wikipedia:Portada", 9435},
  {"Mike_Evans_(actor)", 10033},
  {"Carroll_O'Connor", 10055},
  {"Pagina_principale", 10639},
  {"小嶺麗奈", 10821},
  {"Farrah_Fawcett", 11710},
  {"All_in_the_Family", 11785},
  {"Doordarshan", 11975},
  {"Isabel_Sanford", 12564},
  {"Especial:Buscar", 12649},
  {"Che_Guevara", 12677},
  {"メインページ", 12945},
  {"Sally_Struthers", 13294},
  {"小嶺麗奈", 13549},
  {"Norman_Lear", 14838},
  {"Wikipedia:Portada", 15330},
  {"Javier_Mascherano", 16289},
  {"Roxie_Roker", 16487},
  {"Chernobyl_disaster", 16760},
  {"Steve_Jobs", 18382},
  {"Sherman_Hemsley", 18992},
  {"The_Jeffersons", 23008},
  {"Marla_Gibbs", 55348},
  {"Billboard_year-end_top_30_singles_of_1950", 88604}
]
```
