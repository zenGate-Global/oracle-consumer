use aiken/crypto.{blake2b_256}
use aiken/math/rational.{denominator, numerator}
use json.{JString, marshal}
use rational_helper.{rational_to_string}

test hash_rational_test() {
  expect Some(rational_num) = rational.new(1603, 50)
  expect Some(rational_string) =
    rational_to_string(numerator(rational_num), denominator(rational_num))

  expect rational_string == @"1603/50"

  let encoded = marshal(JString(rational_string))
  let hash = blake2b_256(encoded)

  hash == #"5751680ab15ca4718bd95b7180124568ed17d466c971c77f61ef5eceea0d5dcc"
}
