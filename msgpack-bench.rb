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

data    = { "number" => number_data, "string" => string_data }
parsers = {
  "json"    => Proc.new { |data| Oj.load(Oj.dump(data)) },
  "msgpack" => Proc.new { |data| MessagePack.unpack(data.to_msgpack) },
  "xml"     => Proc.new { |data| Ox.load(Ox.dump(data)) },
}

n = ARGV[0].nil? || ARGV[0] == "" ? 10000 : ARGV[0].to_i
puts "Running benchmark with n = #{n}"

width = parsers.keys.collect { |p| data.keys.collect { |d| "#{p}:#{d}" }}.flatten.collect { |s| s.size }.max + 2

parsers.each do |parser_name, p|
  data.each do |data_type, d|
    bm = Benchmark.measure("name") { n.times { p.call(d) }}
    printf "%-#{width}s: %.5f (%d ops/sec)\n", "#{parser_name}:#{data_type}", bm.utime, n / bm.utime
  end
end
