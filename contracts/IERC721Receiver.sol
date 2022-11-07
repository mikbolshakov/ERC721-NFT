// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// интерфейс, который нужен в ск, чтобы тот мог принимать нфт
// в таком ск должна быть функция onERC721Received, которая возвращает собственный селектор
interface IERC721Receiver {
    function onERC721Received(
        address operator,
        address from,
        uint tokenId,
        bytes calldata data
    ) external returns (bytes4);
}
