use aiken/builtin.{slice_bytearray}
use aiken/primitive/bytearray

pub type Json {
  JString(String)
  JInt(Int)
  JBool(Bool)
}

pub fn marshal(j: Json) -> ByteArray {
  when j is {
    JString(s) -> marshal_string(s)
    JInt(i) -> int_to_ba(i)
    JBool(b) ->
      if b {
        bytearray.from_string(@"true")
      } else {
        bytearray.from_string(@"false")
      }
  }
}

fn marshal_string(s: String) -> ByteArray {
  let open = bytearray.from_string(@"\"")
  let body =
    foldr(
      s,
      bytearray.from_string(@""),
      fn(ch, acc) { bytearray.concat(acc, escape_char_bytes(ch)) },
    )
  let close = bytearray.from_string(@"\"")
  bytearray.concat(bytearray.concat(open, body), close)
}

fn escape_char_bytes(ch: String) -> ByteArray {
  let ba = bytearray.from_string(ch)
  let len = bytearray.length(ba)

  // Single-byte fast-path for ASCII/control checks
  if len == 1 {
    let b = bytearray.at(ba, 0)
    if b == 0x22 {
      // '"'
      bytearray.from_string(@"\"\"")
    } else if b == 0x5c {
      // '\'
      bytearray.from_string(@"\\")
    } else if b < 0x20 {
      fail @"not implemented"
    } else {
      ba
    }
  } else {
    ba
  }
}

fn int_to_ba(n: Int) -> ByteArray {
  if n == 0 {
    bytearray.from_string(@"0")
  } else {
    let neg = n < 0
    let abs =
      if neg {
        0 - n
      } else {
        n
      }
    let digits = to_digits_ba(abs, bytearray.from_string(@""))
    if neg {
      bytearray.concat(bytearray.from_string(@"-"), digits)
    } else {
      digits
    }
  }
}

fn to_digits_ba(n: Int, acc: ByteArray) -> ByteArray {
  if n == 0 {
    acc
  } else {
    let q = n / 10
    let r = n % 10
    to_digits_ba(q, bytearray.concat(digit_ba(r), acc))
  }
}

fn digit_ba(n: Int) -> ByteArray {
  when n is {
    0 -> bytearray.from_string(@"0")
    1 -> bytearray.from_string(@"1")
    2 -> bytearray.from_string(@"2")
    3 -> bytearray.from_string(@"3")
    4 -> bytearray.from_string(@"4")
    5 -> bytearray.from_string(@"5")
    6 -> bytearray.from_string(@"6")
    7 -> bytearray.from_string(@"7")
    8 -> bytearray.from_string(@"8")
    9 -> bytearray.from_string(@"9")
    _ -> fail @"digit out of range"
  }
}

pub type Decoder<a> =
  fn(ByteArray) -> a

type Char =
  String

pub fn foldr(
  self: String,
  zero: result,
  with: fn(Char, result) -> result,
) -> result {
  self
    |> bytearray.from_string
    |> next_char(with, False, zero)
}

fn next_char(
  yield: fn(String, st) -> st,
  is_escaped: Bool,
  st: st,
) -> Decoder<st> {
  fn(bytes) {
    let len = bytearray.length(bytes)

    if len < 1 {
      st
    } else {
      let char = bytearray.at(bytes, 0)

      let consume =
        fn(n) {
          if len < n {
            fail @"not enough bytes"
          } else if is_escaped {
            fail @"invalid escape"
          } else {
            let char = bytearray.to_string(bytearray.take(bytes, n))
            next_char(yield, False, yield(char, st))(
              slice_bytearray(n, len - n, bytes),
            )
          }
        }

      if char <= 127 {
        let step =
          if char == 0x5c && !is_escaped {
            next_char(yield, True, st)
          } else {
            let char = bytearray.to_string(bytearray.take(bytes, 1))
            next_char(yield, False, yield(char, st))
          }
        step(slice_bytearray(1, len - 1, bytes))
      } else if char <= 223 {
        consume(2)
      } else if char <= 239 {
        consume(3)
      } else {
        consume(4)
      }
    }
  }
}

test json_int() {
  bytearray.to_string(marshal(JInt(-12034))) == @"-12034"
}

test json_bool() {
  bytearray.to_string(marshal(JBool(True))) == @"true" && bytearray.to_string(
    marshal(JBool(False)),
  ) == @"false"
}
