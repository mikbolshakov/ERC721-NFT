// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// интерфейс, чтобы проверить, реализует ли наш контракт ERC721 другие интерфейсы
interface IERC165 {
  function supportsInterface(bytes4 interfaceId) external view returns(bool);
}