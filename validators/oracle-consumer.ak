use cardano/assets.{AssetName, PolicyId}
use cardano/transaction.{OutputReference, Transaction}
use consumer_validator.{consumer_validator}
use types.{ConsumerRedeemer}

validator oracle_consumer_validator(
  oracle_policy_id: PolicyId,
  oracle_asset_name: AssetName,
  threshold: Int,
) {
  spend(
    _datum: Option<Data>,
    redeemer: ConsumerRedeemer,
    _my_output_reference: OutputReference,
    tx: Transaction,
  ) {
    consumer_validator(
      oracle_policy_id,
      oracle_asset_name,
      threshold,
      tx,
      redeemer,
    )?
  }

  else(_) {
    fail
  }
}
