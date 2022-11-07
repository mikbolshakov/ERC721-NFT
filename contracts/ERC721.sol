// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./IERC721.sol";
import "./IERC721Metadata.sol";
import "./Strings.sol";
import "./IERC721Receiver.sol";
import "./ERC165.sol";

// реализация интерфейса ERC721 (по стандарту) + дополнительная логика
contract ERC721 is ERC165, IERC721, IERC721Metadata {
    using Strings for uint;
    string private _name;
    string private _symbol;

    mapping(address => uint) private _balances; // адрес => количество нфт, которыми он владеет
    mapping(uint => address) private _owners; // айди токена => адрес-владелец токена
    mapping(uint => address) private _tokenApprovals; // айди токена => адресс, который может этим токеном распоряжаться
    mapping(address => mapping(address => bool)) private _operatorApprovals; // адрес владельца нфт => адрес оператора => может/не может оператор распоряжаться токенами владельца

    modifier _requireMinted(uint tokenId) {
        require(_exists(tokenId), "not minted!");
        _;
    }

    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() external view returns (string memory) {
        return _name;
    }

    function symbol() external view returns (string memory) {
        return _symbol;
    }

    // базовая ссылка, к которой будем приставлять результат функции tokenURI
    function _baseURI() internal pure virtual returns (string memory) {
        return ""; // https://erc721/...
    }

    // создаем полноценную ссылку на изображение
    function tokenURI(uint tokenId) public view virtual _requireMinted(tokenId) returns (string memory) {
        string memory baseURI = _baseURI();
        return
            bytes(baseURI).length > 0 // если есть базовая ссылка, тогда склеиваем результаты
                ? string(abi.encodePacked(baseURI, tokenId.toString()))
                : "";
    }

    function balanceOf(address owner) public view returns (uint) {
        require(owner != address(0), "owner cannot be zero");
        return _balances[owner];
    }

    function ownerOf(uint tokenId) public view _requireMinted(tokenId) returns (address) {
        return _owners[tokenId];
    }

    // проверка, что токен существует (что у него есть владелец)
    function _exists(uint tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function approve(address to, uint tokenId) public {
        address _owner = ownerOf(tokenId);
        require(_owner == msg.sender || isApprovedForAll(_owner, msg.sender),"not an owner!");
        require(to != _owner, "can't approve to self");
        _tokenApprovals[tokenId] = to;
        emit Approval(_owner, to, tokenId);
    }

    function setApprovalForAll(address operator, bool approved) public {
        require(msg.sender != operator, "can't approve to self");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    // проверка approve - управляет конкретным токеном
    function getApproved(uint tokenId) public view _requireMinted(tokenId) returns(address) {
        return _tokenApprovals[tokenId];
    }

    // проверка setApprovalForAll - управляет всеми токенами
    function isApprovedForAll(address owner, address operator) public view returns (bool) {
        return _operatorApprovals[owner][operator];
    }

    function transferFrom(address from, address to, uint tokenId) external {
        require(_isApprovedOrOwner(msg.sender, tokenId),"not approved or owner");
        _transfer(from, to, tokenId);
    }

    // безопасная отправка нфт
    function safeTransferFrom(address from, address to, uint tokenId) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    // безопасная отправка нфт с данными
    function safeTransferFrom(address from, address to, uint tokenId, bytes memory data) public {
        require(_isApprovedOrOwner(msg.sender, tokenId), "not an owner!");
        _safeTransfer(from, to, tokenId, data);
    }

    // безопасная - тот, кто получает нфт, может их принять
    function _safeTransfer(address from, address to, uint tokenId, bytes memory data) internal {
        _transfer(from, to, tokenId);
        require(_checkOnERC721Received(from, to, tokenId, data), "transfer to non-erc721 receiver");
    }

    // переписываем в нашей базе факт владения, что данным айди владеет новый адрес
    function _transfer(address from, address to, uint tokenId) internal {
        require(ownerOf(tokenId) == from, "incorrect owner!");
        require(to != address(0), "to address is zero!");
        _beforeTokenTransfer(from, to, tokenId);
        delete _tokenApprovals[tokenId];
        _balances[from]--;
        _balances[to]++;
        _owners[tokenId] = to;
        emit Transfer(from, to, tokenId);
        _afterTokenTransfer(from, to, tokenId);
    }

    // проверка, является ли получатель ск и может ли этот ск принимать нфт
    function _checkOnERC721Received(address from, address to, uint tokenId, bytes memory data) private returns (bool) {
        if (to.code.length > 0) {
            try IERC721Receiver(to).onERC721Received(msg.sender, from, tokenId, data) returns (bytes4 retval) { // если возвращает retval, то этот ск может принять нфт
                return retval == IERC721Receiver.onERC721Received.selector; // принимающий ск должен иметь функцию onERC721Received
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert("Transfer to non-erc721 receiver"); // стандартное сообщение: либо функция onERC721Received пустая, либо ее нет
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason)) // откатываем транзакцию с сообщением, которое хранится в reason (reason прописана в onERC721Received)
                    }
                }
            }
        } else {
            return true;
        }
    }

    function _isApprovedOrOwner(address spender, uint tokenId) internal view returns (bool) {
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            isApprovedForAll(owner, spender) ||
            getApproved(tokenId) == spender);
    }

    // обе функции пустые, так как никаких действий до или после перевода мы не делаем
    function _beforeTokenTransfer(address from, address to, uint tokenId) internal virtual {}

    function _afterTokenTransfer(address from, address to, uint tokenId) internal virtual {}

    // по функциям выше мы реализовали интерфейс IERC721
    // ниже функции, которые вводят и выводят нфт из оборота (не являются частью стандарта)

    // минтим
    function _safeMint(address to, uint tokenId) internal virtual {
        _safeMint(to, tokenId, "");
    }

    // минтим с данными
    function _safeMint(address to, uint tokenId, bytes memory data) internal virtual {
        _mint(to, tokenId);
        require(_checkOnERC721Received(address(0), to, tokenId, data), "non-erc721 receiver");
    }

    function _mint(address to, uint tokenId) internal virtual {
        require(to != address(0), "zero address to");
        require(!_exists(tokenId), "this token id is already minted");
        _beforeTokenTransfer(address(0), to, tokenId);
        _owners[tokenId] = to;
        _balances[to]++;
        emit Transfer(address(0), to, tokenId);
        _afterTokenTransfer(address(0), to, tokenId);
    }

    function burn(uint tokenId) public virtual {
        require(_isApprovedOrOwner(msg.sender, tokenId), "not owner!");
        _burn(tokenId);
    }

    function _burn(uint tokenId) internal virtual {
        address owner = ownerOf(tokenId);
        _beforeTokenTransfer(owner, address(0), tokenId);
        delete _tokenApprovals[tokenId];
        _balances[owner]--;
        delete _owners[tokenId];
        emit Transfer(owner, address(0), tokenId);
        _afterTokenTransfer(owner, address(0), tokenId);
    }

    // функция, которая показывает, что мы поддерживаем два наших интерфейса
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId ||
            super.supportsInterface(interfaceId);
    }
}
