//SPDX-License-Identifier: UNLICENSED

pragma solidity >=0.8.11;

contract TradeMarket {

    // 사용자 정보
    struct User {
        address owner;
        string[] ownItemNames;
        mapping (string => uint) ownItems;
    }

    // 거래 물건
    struct Item {
        address register;
        string name;
        uint price;
        // false: 판매중, ture: 판매완료(판매취소)
        bool status;
    }

    mapping (address => User) public users;
    Item[] public items;
    // 계약 주인
    address payable owner;


    // 생성자
    constructor() {
        owner = payable(msg.sender);
    }

    // 사용자 정보 등록 (보유중인 물건 확인을 위함)
    function register()  public returns(bool){
        if (users[msg.sender].owner != msg.sender) {
            // User storage user = users[msg.sender];
            users[msg.sender].owner = msg.sender;
            return true;
        }
        return false;
    }

    function sellItem(string memory itemName, uint price) public {
        // 유저가 아이템을 1개이상 갖고 있는지 확인한다.
        if(users[msg.sender].ownItems[itemName] <= 0) {
            revert();
        }
        // 유저가 보유중인 아이템 하나를 거래소에 올리므로 -1 해준다.
        users[msg.sender].ownItems[itemName] -= 1;
        Item memory item = Item(msg.sender, itemName, price, false);
        items.push(item);
    }

    function buyItem(uint number) public payable{
        // 계정 등록 여부 확인
        require(users[msg.sender].owner == msg.sender);

        // 아이템 구매 시도
        Item memory item = items[number];
        if(!payable(item.register).send(msg.value)) {
            revert();
        }

        // 구매 완료시 구매자의 정보에 물건 추가
        registerItem(item.name, 1);
        // item 을 거래 완료로 변경
        items[number].status = true;
    }

    // 판매 취소
    function cancelItem(uint number) public {
        // 거래 등록자와 판매 취소자가 같은지 확인
        require(items[number].register == msg.sender);

        // 물건 추가
        registerItem(items[number].name, 1);
        // item 을 거래 완료로 변경
        items[number].status = true;
    }

    // 사용자 물건 등록
    function registerItem(string memory itemName, uint itemCount) public returns(bool){
        // 계정 등록 여부 확인
        if(users[msg.sender].owner == msg.sender) {
            // 물건을 기존에 갖고 있지 않는경우
            if(users[msg.sender].ownItems[itemName] == 0) {
                users[msg.sender].ownItems[itemName] = itemCount;
                users[msg.sender].ownItemNames.push(itemName);
            }
            // 물건을 기존에 갖고 있는 경우
            else {
                users[msg.sender].ownItems[itemName] += itemCount;
            }
            return true;
        }
        return false;
    }

    // 사용자가 갖고 있는 물건의 종류
    function checkItem() view public returns(string[] memory) {
        return users[msg.sender].ownItemNames;
    }

    // 사용자가 갖고 있는 물건의 개수
    function getItemNumber(string memory itemName) view public returns(uint) {
        return users[msg.sender].ownItems[itemName];
    }

    // 거래소에 등록된 물건들
    function getItems() view public returns(Item[] memory) {
        return items;
    }

    // 계정 등록 여부 확인
    function checkRegister() view public returns(bool) {
        if(users[msg.sender].owner == msg.sender)
            return true;
        return false;
    }
}
