use aiken/primitive/bytearray

pub fn rational_to_string(num0: Int, den0: Int) -> Option<String> {
  if den0 == 0 {
    None
  } else {
    // normalize sign to denominator > 0
    let (num1, den1) =
      if den0 < 0 {
        (0 - num0, 0 - den0)
      } else {
        (num0, den0)
      }

    // zero is canonicalized to 0/1
    if num1 == 0 {
      Some(@"0/1")
    } else {
      let g = gcd(abs(num1), den1)
      let n2 = num1 / g
      let d2 = den1 / g

      let out =
        bytearray.to_string(
          bytearray.concat(
            bytearray.concat(int_to_ba(n2), bytearray.from_string(@"/")),
            int_to_ba(d2),
          ),
        )

      Some(out)
    }
  }
}

fn gcd(a: Int, b: Int) -> Int {
  if b == 0 {
    a
  } else {
    gcd(b, a % b)
  }
}

fn abs(x: Int) -> Int {
  if x < 0 {
    0 - x
  } else {
    x
  }
}

fn int_to_ba(n: Int) -> ByteArray {
  if n == 0 {
    bytearray.from_string(@"0")
  } else {
    let neg = n < 0
    let absn =
      if neg {
        0 - n
      } else {
        n
      }
    let digits = to_digits_ba(absn, bytearray.from_string(@""))
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

test r_basic() {
  rational_to_string(1603, 50) == Some(@"1603/50")
}

test r_reduce_and_sign() {
  rational_to_string(-4, 8) == Some(@"-1/2") && rational_to_string(5, -10) == Some(
    @"-1/2",
  ) && rational_to_string(-6, -9) == Some(@"2/3")
}

test r_zero() {
  rational_to_string(0, 5) == Some(@"0/1")
}

test r_den_zero() {
  rational_to_string(1, 0) == None
}
