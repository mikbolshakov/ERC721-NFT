// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";
import "./ERC721URIStorage.sol";
import "./ERC721Enumerable.sol";

// контракт с nft
contract NToken is ERC721, ERC721Enumerable, ERC721URIStorage {
    address public owner;
    uint currentTokenId; // числовой айди для минта и переводов

    constructor() ERC721("NToken", "NTK") {
        owner = msg.sender;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://";
    }

    // минтим и сопоставляем id токена с ссылкой в ipfs (через интерфейс ERC721URIStorage)
    function safeMint(address to, string calldata tokenId) public {
        require(owner == msg.sender, "not an owner!");
        _safeMint(to, currentTokenId);
        _setTokenURI(currentTokenId, tokenId); // tokenId - ссылка в ipfs (ipfs://adc242)
        currentTokenId++;
    }

    //переопределяем нижние 4 функции в двух случаях (ERC721, ERC721URIStorage), 
    // в остальных случаях поднимаемся по иерархии выше
    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721, ERC721Enumerable) returns (bool) {
        return interfaceId == type(IERC721Enumerable).interfaceId ||
            super.supportsInterface(interfaceId);
    } 

    function _burn(uint tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function _beforeTokenTransfer(address from, address to, uint tokenId) internal override(ERC721, ERC721Enumerable) {
        super._beforeTokenTransfer(from, to, tokenId);
    }
}
