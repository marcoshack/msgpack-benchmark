#!/usr/bin/env ruby

require 'msgpack'
require 'benchmark'
require 'oj'
require 'ox'
require 'pry'

string_data = {
  "glossary" => {
    "title" => "example glossary",
    "GlossDiv" => {
      "title" => "S",
      "GlossList" => {
        "GlossEntry" => {
          "ID" => "SGML",
          "SortAs" => "SGML",
          "GlossTerm" => "Standard Generalized Markup Language",
          "Acronym" => "SGML",
          "Abbrev" => "ISO 8879:1986",
          "GlossDef" => {
            "para" => "A meta-markup language, used to create markup languages such as DocBook.",
            "GlossSeeAlso" => [ "GML" , "XML" ]
          },
          "GlossSee" => "markup"
        }
      }
    }
  }
}

number_data = [
  [1, 2, 3, 4, -1, true, nil],
  [3, 6, 5, 4,  1, false, 7],
  [3, 2, 8, 1,  0, true, 0],
  [10, 11, 12, 13,  14, false, true],
  [15, 16, 17, 18, 19, true, nil],
  [20, 21, 22, 23,  24, false, 7],
  [25, 26, 27, 28,  29, true, 0],
  100, 200, 300,
  [
    [1, 0, 0, 0, 0],
    [0, 1, 0, 0, 0],
    [0, 0, 1, 0, 0],
    [0, 0, 0, 1, 0],
    [0, 0, 0, 0, 1]
  ]
]

n = ARGV[0].nil? || ARGV[0] == "" ? 10000 : ARGV[0].to_i
puts "Running benchmark with n = #{n}"

executions = {
  "json number"    => Proc.new { Oj.load(Oj.dump(number_data)) },
  "msgpack number" => Proc.new { MessagePack.unpack(number_data.to_msgpack) },
  "xml number"     => Proc.new { Ox.load(Ox.dump(number_data)) },
  "json string"    => Proc.new { Oj.load(Oj.dump(string_data)) },
  "msgpack string" => Proc.new { MessagePack.unpack(string_data.to_msgpack) },
  "xml string"    => Proc.new { Ox.load(Ox.dump(string_data)) },
}
width = executions.keys.collect { |name| name.size }.max + 2
executions.each do |name, proc|
  bm = Benchmark.measure("name") { n.times { proc.call }}
  printf "%-#{width}s: %.5f (%d ops/sec)\n", name, bm.utime, n / bm.utime
end
