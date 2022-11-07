// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";

// интерфейс для расширения ERC721Enumerable (поиск токенов по индексу)
interface IERC721Enumerable is IERC721 {
  function totalSupply() external view returns(uint);

  function tokenOfOwnerByIndex(address owner, uint index) external view returns(uint);

  function tokenByIndex(uint index) external view returns(uint);
}