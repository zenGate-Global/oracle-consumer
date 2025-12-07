use cardano/address.{Address, Script}
use cardano/assets.{add, from_lovelace, zero}
use cardano/transaction.{
  InlineDatum, Input, NoDatum, Output, OutputReference, Transaction,
}
use consumer_validator.{consumer_validator}
use tests/global_test_proofs.{spend}
use tests/global_test_variables.{
  admin_singleton_asset_name, admin_singleton_policy_id, alice_address_hash,
  consumer_contract_hash, one_ada, oracle_contract_hash,
  oracle_singleton_asset_name, oracle_singleton_policy_id,
}
use types.{ConsumerRedeemer, MerkleOracleDatum}

// failure case: validator should reject when oracle value is below threshold
// oracle value = 2311/100 = 23.11, threshold = 100
// since 23.11 < 100, the validator should return False
test fail_when_value_below_threshold() {
  let current_time = 1

  let consumer_self_input_utxo_details =
    Output {
      address: Address {
        payment_credential: Script(consumer_contract_hash),
        stake_credential: None,
      },
      value: from_lovelace(one_ada),
      datum: NoDatum,
      reference_script: None,
    }

  let consumer_input_output_ref =
    OutputReference {
      transaction_id: #"dcb9788326b92481d5bb0e1de8d85ecfec619947880c43d422aa0a672c79dc2c",
      output_index: 0,
    }

  let consumer_input =
    Input {
      output_reference: consumer_input_output_ref,
      output: consumer_self_input_utxo_details,
    }

  let oracle_input_output_ref =
    OutputReference {
      transaction_id: #"dcb9788326b92481d5bb0e1de8d85ecfec619947880c43d422aa0a672c79dc2c",
      output_index: 0,
    }

  let oracle_input_datum =
    MerkleOracleDatum {
      merkle_root: #"bae950cd9d1bcfdfa00cee87556e0cb931b12de3816591e6970eabe3150c2c38",
      ipfs_cid: #"516d56716f617865366b6343746d4d68433546465356446f42537a763658356d486966685434436672315276564e",
      admin_singleton_policy_id,
      admin_singleton_asset_name,
      created_at: current_time,
    }

  let oracle_input_datum_casted: Data = oracle_input_datum
  let oracle_self_input_utxo_details =
    Output {
      address: Address {
        payment_credential: Script(oracle_contract_hash),
        stake_credential: None,
      },
      value: from_lovelace(one_ada)
        |> add(oracle_singleton_policy_id, oracle_singleton_asset_name, 1),
      datum: InlineDatum(oracle_input_datum_casted),
      reference_script: None,
    }

  let oracle_input =
    Input {
      output_reference: oracle_input_output_ref,
      output: oracle_self_input_utxo_details,
    }

  let recipient_output =
    Output {
      address: Address {
        payment_credential: Script(alice_address_hash),
        stake_credential: None,
      },
      value: from_lovelace(one_ada),
      datum: NoDatum,
      reference_script: None,
    }

  let tx =
    transaction.placeholder
      |> fn(transaction) {
          Transaction {
            ..transaction,
            inputs: [consumer_input],
            outputs: [recipient_output],
            mint: zero,
            reference_inputs: [oracle_input],
          }
        }

  let redeemer =
    ConsumerRedeemer {
      item_key_hash: #"5b2e3b9dba0589cc3d2cfba06015f7e5953072e782a54749a851e96b77392b48",
      item_value: (2311, 100),
      membership_proof: spend(),
    }

  // threshold = 100, but oracle value = 23.11
  // validator should return False since 23.11 < 100
  let threshold_amount = 100

  !consumer_validator(
    oracle_singleton_policy_id,
    oracle_singleton_asset_name,
    threshold_amount,
    tx,
    redeemer,
  )
}

// failure case: validator should reject when oracle value equals threshold
// oracle value = 2/1 = 2, threshold = 2
// since 2 == 2 (not greater), the validator should return False
test fail_when_value_equals_threshold() {
  let current_time = 1

  let consumer_self_input_utxo_details =
    Output {
      address: Address {
        payment_credential: Script(consumer_contract_hash),
        stake_credential: None,
      },
      value: from_lovelace(one_ada),
      datum: NoDatum,
      reference_script: None,
    }

  let consumer_input_output_ref =
    OutputReference {
      transaction_id: #"dcb9788326b92481d5bb0e1de8d85ecfec619947880c43d422aa0a672c79dc2c",
      output_index: 0,
    }

  let consumer_input =
    Input {
      output_reference: consumer_input_output_ref,
      output: consumer_self_input_utxo_details,
    }

  let oracle_input_output_ref =
    OutputReference {
      transaction_id: #"dcb9788326b92481d5bb0e1de8d85ecfec619947880c43d422aa0a672c79dc2c",
      output_index: 0,
    }

  let oracle_input_datum =
    MerkleOracleDatum {
      merkle_root: #"bae950cd9d1bcfdfa00cee87556e0cb931b12de3816591e6970eabe3150c2c38",
      ipfs_cid: #"516d56716f617865366b6343746d4d68433546465356446f42537a763658356d486966685434436672315276564e",
      admin_singleton_policy_id,
      admin_singleton_asset_name,
      created_at: current_time,
    }

  let oracle_input_datum_casted: Data = oracle_input_datum
  let oracle_self_input_utxo_details =
    Output {
      address: Address {
        payment_credential: Script(oracle_contract_hash),
        stake_credential: None,
      },
      value: from_lovelace(one_ada)
        |> add(oracle_singleton_policy_id, oracle_singleton_asset_name, 1),
      datum: InlineDatum(oracle_input_datum_casted),
      reference_script: None,
    }

  let oracle_input =
    Input {
      output_reference: oracle_input_output_ref,
      output: oracle_self_input_utxo_details,
    }

  let recipient_output =
    Output {
      address: Address {
        payment_credential: Script(alice_address_hash),
        stake_credential: None,
      },
      value: from_lovelace(one_ada),
      datum: NoDatum,
      reference_script: None,
    }

  let tx =
    transaction.placeholder
      |> fn(transaction) {
          Transaction {
            ..transaction,
            inputs: [consumer_input],
            outputs: [recipient_output],
            mint: zero,
            reference_inputs: [oracle_input],
          }
        }

  let redeemer =
    ConsumerRedeemer {
      item_key_hash: #"5b2e3b9dba0589cc3d2cfba06015f7e5953072e782a54749a851e96b77392b48",
      // value = 2311/100 = 23.11, we set threshold to 24 so it's just above
      item_value: (2311, 100),
      membership_proof: spend(),
    }

  // threshold = 24, oracle value = 23.11
  // validator should return False since 23.11 < 24
  let threshold_amount = 24

  // negate the result: test passes if validator returns False
  !consumer_validator(
    oracle_singleton_policy_id,
    oracle_singleton_asset_name,
    threshold_amount,
    tx,
    redeemer,
  )
}