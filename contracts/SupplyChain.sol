// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

contract SupplyChain {
    address public Owner;
    // Product count
    uint256 public productCtr = 0;
    // Farmer count
    uint256 public farmerCtr = 0;
    // Distributor counter
    uint256 public distributorCtr = 0;
    // Retailer counter
    uint256 public retailerCtr = 0;
    // Consumer counter
    uint256 public consumerCtr = 0;

    constructor() public {
        Owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == Owner, "Permission restricted to owner");
        _;
    }

    enum STATE {
        Created,
        Farmer,
        Dispatched,
        Retailed,
        Delivered
    }

    struct Product {
        uint id;
        string name;
        uint256 price;
        string desc;
        uint quantity;
        uint256 farmerId;
        uint256 distributorId;
        uint256 retailerId;
        uint256 consumerId;
        STATE state;
        uint256 createdAt;
        uint256 updatedAt;
    }

    mapping(uint256 => Product) public products;

    function productState(uint256 _productId) public view returns (string memory) {
        require(productCtr > 0, "No products available");
        if (products[_productId].state == STATE.Created)
            return "Product Created";
        else if (products[_productId].state == STATE.Farmer)
            return "Farming Stage";
        else if (products[_productId].state == STATE.Dispatched)
            return "Distribution Stage";
        else if (products[_productId].state == STATE.Retailed)
            return "Retail Stage";
        else if (products[_productId].state == STATE.Delivered)
            return "Product Delivered";
        else
            return "Unknown State";
    }

    struct FarmerInfo {
        address addr;
        string name;
        string place;
        uint256 id;
    }

    struct DistributorInfo {
        address addr;
        string name;
        string place;
        uint256 id;
    }

    struct RetailerInfo {
        address addr;
        string name;
        string place;
        uint256 id;
    }

    struct ConsumerInfo {
        address addr;
        string name;
        string place;
        uint256 id;
    }

    // Store the farmer information on the blockchain
    mapping(uint256 => FarmerInfo) public farmer;
    // Store the distributor information on the blockchain
    mapping(uint256 => DistributorInfo) public distributor;
    // Store the retailer information on the blockchain
    mapping(uint256 => RetailerInfo) public retailer;
    // Store the consumer information on the blockchain
    mapping(uint256 => ConsumerInfo) public consumer;

    function addFarmer(
        address _addr,
        string memory _name,
        string memory _place
    ) public onlyOwner {
        farmerCtr++;
        farmer[farmerCtr] = FarmerInfo(_addr, _name, _place, farmerCtr);
    }

    function addDistributor(
        address _addr,
        string memory _name,
        string memory _place
    ) public onlyOwner {
        distributorCtr++;
        distributor[distributorCtr] = DistributorInfo(_addr, _name, _place, distributorCtr);
    }

    function addRetailer(
        address _addr,
        string memory _name,
        string memory _place
    ) public onlyOwner {
        retailerCtr++;
        retailer[retailerCtr] = RetailerInfo(_addr, _name, _place, retailerCtr);
    }

    function addConsumer(
        address _addr,
        string memory _name,
        string memory _place
    ) public onlyOwner {
        consumerCtr++;
        consumer[consumerCtr] = ConsumerInfo(_addr, _name, _place, consumerCtr);
    }

    function findFarmer(address _addr) private view returns (uint256) {
        require(farmerCtr > 0, "No farmers available");
        for (uint256 i = 1; i <= farmerCtr; i++) {
            if (farmer[i].addr == _addr) return farmer[i].id;
        }
        return 0;
    }

    function findDistributor(address _addr) private view returns (uint256) {
        require(distributorCtr > 0, "No distributors available");
        for (uint256 i = 1; i <= distributorCtr; i++) {
            if (distributor[i].addr == _addr) return distributor[i].id;
        }
        return 0;
    }

    function findRetailer(address _addr) private view returns (uint256) {
        require(retailerCtr > 0, "No retailers available");
        for (uint256 i = 1; i <= retailerCtr; i++) {
            if (retailer[i].addr == _addr) return retailer[i].id;
        }
        return 0;
    }

    function findConsumer(address _addr) private view returns (uint256) {
        require(consumerCtr > 0, "No consumers available");
        for (uint256 i = 1; i <= consumerCtr; i++) {
            if (consumer[i].addr == _addr) return consumer[i].id;
        }
        return 0;
    }

    function transferFarmer(uint256 _productId) public {
        require(_productId > 0 && _productId <= productCtr, "Invalid product ID");
        uint256 _id = findFarmer(msg.sender);
        require(_id > 0, "Farmer not found");
        require(products[_productId].state == STATE.Created, "Product not in Created state");
        products[_productId].farmerId = _id;
        products[_productId].state = STATE.Farmer;
    }

    function transferDistributor(uint256 _productId) public {
        require(_productId > 0 && _productId <= productCtr, "Invalid product ID");
        uint256 _id = findDistributor(msg.sender);
        require(_id > 0, "Distributor not found");
        require(products[_productId].state == STATE.Farmer, "Product not in Farmer state");
        products[_productId].distributorId = _id;
        products[_productId].state = STATE.Dispatched;
    }

    function transferRetailer(uint256 _productId) public {
        require(_productId > 0 && _productId <= productCtr, "Invalid product ID");
        uint256 _id = findRetailer(msg.sender);
        require(_id > 0, "Retailer not found");
        require(products[_productId].state == STATE.Dispatched, "Product not in Dispatched state");
        products[_productId].retailerId = _id;
        products[_productId].state = STATE.Retailed;
    }

    function transferConsumer(uint256 _productId) public {
        require(_productId > 0 && _productId <= productCtr, "Invalid product ID");
        uint256 _id = findConsumer(msg.sender);
        require(_id > 0, "Consumer not found");
        require(products[_productId].state == STATE.Retailed, "Product not in Retailed state");
        products[_productId].consumerId = _id;
        products[_productId].state = STATE.Delivered;
    }

    function addProduct(
        string memory _name,
        uint256 _price,
        string memory _desc,
        uint _quantity
    ) public onlyOwner {
        productCtr++;
        products[productCtr] = Product(
            productCtr,
            _name,
            _price,
            _desc,
            _quantity,
            0,
            0,
            0,
            0,
            STATE.Created,
            block.timestamp,
            block.timestamp
        );
    }
}
