// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "usingtellor/contracts/UsingTellor.sol";
import "./interfaces/IAutopay.sol";

contract SampleTellorRNG is UsingTellor {
  IAutopay public autopay;
  uint256 public tipAmount;

  constructor(address payable _tellor, address _autopay, uint256 _tipAmount) UsingTellor(_tellor) {
    autopay = IAutopay(_autopay);
  }

  function requestRandomNumber(uint256 _timestamp) public {
    bytes memory _queryData = abi.encode("TellorRNG", abi.encode(_timestamp));
    bytes32 _queryId = keccak256(_queryData);
    autopay.tip(_queryId, tipAmount, _queryData);
  }

  function retrieveRandomNumber(uint256 _timestamp) public view returns(uint256) {
    bytes memory _queryData = abi.encode("TellorRNG", abi.encode(_timestamp));
    bytes32 _queryId = keccak256(_queryData);
    bytes memory _randomNumberBytes;
    (, _randomNumberBytes, ) = getDataBefore(_queryId, block.timestamp - 30 minutes);
    uint256 _randomNumber = abi.decode(_randomNumberBytes, (uint256));
    return _randomNumber;
  }
}
