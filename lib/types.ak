use aiken/merkle_patricia_forestry.{Proof}
use cardano/assets.{AssetName, PolicyId}

pub type MerkleOracleDatum {
  admin_singleton_policy_id: PolicyId,
  admin_singleton_asset_name: AssetName,
  merkle_root: ByteArray,
  ipfs_cid: ByteArray,
  created_at: Int,
}

pub type ConsumerRedeemer {
  item_key_hash: ByteArray,
  item_value: (Int, Int),
  membership_proof: Proof,
}
