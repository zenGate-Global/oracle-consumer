use aiken/crypto.{blake2b_256}
use aiken/math/rational
use aiken/merkle_patricia_forestry.{from_root, has}
use cardano/assets.{AssetName, PolicyId}
use cardano/transaction.{Input, Transaction}
use json.{JString, marshal}
use rational_helper.{rational_to_string}
use types.{ConsumerRedeemer, MerkleOracleDatum}
use utils.{filter_inputs_by_token, get_inline_datum}

pub fn consumer_validator(
  oracle_policy_id: PolicyId,
  oracle_asset_name: AssetName,
  threshold: Int,
  tx: Transaction,
  redeemer: ConsumerRedeemer,
) {
  expect [oracle_input]: List<Input> =
    filter_inputs_by_token(
      tx.reference_inputs,
      oracle_policy_id,
      oracle_asset_name,
    )

  expect MerkleOracleDatum { merkle_root, .. }: MerkleOracleDatum =
    get_inline_datum(oracle_input.output.datum)
  let merkle_oracle_trie = from_root(merkle_root)
  expect Some(rational_string) =
    rational_to_string(redeemer.item_value.1st, redeemer.item_value.2nd)
  let value_hash = blake2b_256(marshal(JString(rational_string)))
  expect
    has(
      merkle_oracle_trie,
      redeemer.item_key_hash,
      value_hash,
      redeemer.membership_proof,
    )
  expect Some(threshold_rational) = rational.new(threshold, 1)

  expect Some(item_value_rational) =
    rational.new(redeemer.item_value.1st, redeemer.item_value.2nd)

  when rational.compare(item_value_rational, threshold_rational) is {
    Greater -> True
    Less -> False
    Equal -> False
  }
}
