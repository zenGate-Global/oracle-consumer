# oracle-consumer

This is an example implementation of a contract which consumes merkle oracle data. 

- The oracle box is validated by checking that the singleton asset is present in the box
- The merkle trie is built by extracting the merkle root from the oracle box's datum
- The keyHash, raw value, and membership proof are extracted from the redeemer which is done by the transaction builder
- the contract hashes the raw value then checks that it is present in the merkle trie by using the keyHash and membership proof

After these checks, any business logic can be done as the data in the redeemer is now validated.

In this exapmle, the business logic is to check that the value is greater than a threshold. If it is, the transaction builder can withdraw assets from this utxo.

## Building

```sh
aiken build
```

## Configuring

**aiken.toml**
```toml
[config.default]
network_id = 41
```

Or, alternatively, write conditional environment modules under `env`.

## Testing

You can write tests in any module using the `test` keyword. For example:

```aiken
use config

test foo() {
  config.network_id + 1 == 42
}
```

To run all tests, simply do:

```sh
aiken check
```

To run only tests matching the string `foo`, do:

```sh
aiken check -m foo
```

## Documentation

If you're writing a library, you might want to generate an HTML documentation for it.

Use:

```sh
aiken docs
```

## Resources

Find more on the [Aiken's user manual](https://aiken-lang.org).
