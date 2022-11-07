// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./ERC721.sol";

// дополнение к NToken'у для того, чтобы состыковать id нфт и ссылку в ipfs
abstract contract ERC721URIStorage is ERC721 {
    mapping(uint => string) private _tokenURIs; // айди токена => ссылка в ipfs

    function _setTokenURI(uint tokenId, string memory _tokenURI) internal virtual _requireMinted(tokenId) {
        _tokenURIs[tokenId] = _tokenURI;
    }

    // делаем полноценную ссылку на картинку склеивая базу и токенURI
    function tokenURI(uint tokenId) public view virtual override _requireMinted(tokenId) returns (string memory) {
        string memory _tokenURI = _tokenURIs[tokenId];
        string memory base = _baseURI();
        if (bytes(base).length == 0) {
            return _tokenURI;
        }
        if (bytes(_tokenURI).length > 0) {
            return string(abi.encodePacked(base, _tokenURI));
        }
        return super.tokenURI(tokenId); // если база есть, а токенURI нету
    }

    // также переопределяем burn - чистим наш мэппинг
    function _burn(uint tokenId) internal virtual override {
        super._burn(tokenId);
        if (bytes(_tokenURIs[tokenId]).length != 0) {
            delete _tokenURIs[tokenId];
        }
    }
}
