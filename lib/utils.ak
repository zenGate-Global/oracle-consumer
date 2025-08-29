use aiken/collection/list.{filter}
use cardano/assets.{AssetName, PolicyId, quantity_of}
use cardano/transaction.{Datum, InlineDatum, Input, Output}

pub fn get_inline_datum(datum: Datum) -> Data {
  when datum is {
    InlineDatum(d) -> d
    _ -> fail @"Expected Inline Datum"
  }
}

pub fn filter_inputs_by_token(
  inputs: List<Input>,
  policy_id: PolicyId,
  asset_name: AssetName,
) -> List<Input> {
  inputs
    |> filter(fn(i) { quantity_of(i.output.value, policy_id, asset_name) > 0 })
}
