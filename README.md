# SampleTellorRNG
This is a sample contract for requesting and retrieving pseudorandom numbers from the tellor oracle. It uses the `TellorRNG` query type, which takes a `uint256 timestamp` as its only argument. Tellor reporters find the next bitcoin and ethereum blockhashes after this timestamp, hash them together, and submit this final hash as the random number.

## Requesting a Random Number
When requesting a random number from tellor, a timestamp argument must be chosen. At this timestamp, the final random number is not known because the next blockhashes are not yet known. In order to request data from the tellor oracle, one must (1) specify what data is being requested and (2) incentivize data reporters to retrieve and submit the data.

Both `queryData` and a `queryId` to specify exactly what data is being requested. The TellorRNG `queryData` for a timestamp of `1652075943` would be calculated as follows:

```solidity
bytes memory _queryData = abi.encode("TellorRNG", abi.encode(1652075943));
```

The corresponding `queryId` is equal to the keccak256 hash of the `queryData`:

```solidity
bytes32 _queryId = keccak256(_queryData);
```

Once these values are known, a tip can be added through the autopay contract's `tip` function:

```solidity
tellorToken.approve(address(autopay), tipAmount);
autopay.tip(_queryId, tipAmount, _queryData);
```
> The token used for tipping the autopay contract is the same token used for staking in the tellor oracle contract. This is usually the TRB token, except on some networks where token bridges are unavailable.

Once a tip has been added, assuming it covers gas plus some profit, a reporter will be incentivized to submit your random number.

## Retrieving a Random Number
After a reporter submits the random number, the value can be retrieved from the tellor oracle:

```solidity
(, _randomNumberBytes, ) = getDataBefore(_queryId, block.timestamp - 30 minutes);
```
> For best practice, use a time buffer when retrieving data from the tellor oracle to allow time for a bad value to be disputed.

Oracle data is stored in bytes form. You can decode bytes into uint256 using solidity's `decode` function:

```solidity
uint256 _randomNumber = abi.decode(_randomNumberBytes, (uint256));
```
