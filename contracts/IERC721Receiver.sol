// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC721Recevier {
  function onERC721Receiver(
    address operator,
    address from,
    uint tokenId,
    bytes calldata data
  ) external returns(bytes4);
}