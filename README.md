# protoc-erl2

[![Build Status](https://secure.travis-ci.org/ShionRyuu/protoc-erl2.png?branch=master)](http://travis-ci.org/ShionRyuu/protoc-erl2)

It's almost the same with [protoc-erl](https://github.com/shionryuu/protoc-erl), except that protoc-erl2 use protobuffs library optimized by sunface

## Usage

```sh
$ ./protoc-erl ./proto ./ebin ./include

=INFO REPORT==== 1-Jan-2016::16:20:28 ===
Writing header file to "./include/pt10_pb.hrl"

=INFO REPORT==== 1-Jan-2016::16:20:28 ===
Writing src file to "./src/pt10_pb.erl"

=INFO REPORT==== 1-Jan-2016::16:20:28 ===
Writing header file to "./include/protobuffs.hrl"
```

## Authors

- Shion Ryuu <shionryuu@outlook.com>

## License

  [`The MIT License (MIT)`](http://shionryuu.mit-license.org/)
