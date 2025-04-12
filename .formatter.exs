# .formatter.exs

[
  import_deps: [:phoenix, :ecto, :plug],
  inputs: [
    "mix.exs",
    "{config,lib,test}/**/*.{ex,exs}"
  ],
  line_length: 100
]
