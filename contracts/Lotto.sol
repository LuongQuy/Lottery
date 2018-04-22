pragma solidity 0.4.21;

contract Lotto {
   address public owner;
   uint public ticketPrice = 0.01 ether;
   uint public maxPlayer = 3;
   uint  public maxNumber = 36;
   uint public numberCount = 5;
   uint[] public winNumber;
   uint[] public allNumber;
   address[] public players;
   address[] public winners;
   uint public winnerEtherAmount;
   bytes32 public blockHashPrevious;

   mapping(address => uint[]) public ticketOfPlayers;
   function() public payable {}
   function Lotto() public {
      owner = msg.sender;
   }
   function kill() public {
      if(msg.sender == owner) selfdestruct(owner);
   }
   
//   event gameInfo(
//     uint totalEth
//   );
   
   function checkPlayerExist(address playerAdress) public returns (bool) {
       uint playersLength = players.length;
       for(uint i = 0; i < playersLength; i++){
           if(playerAdress == players[i]){
               return true;
           }
       }
       return false;
   }
   
    // ok
   function buyTicket(uint[] numberSelected) public payable {
      assert(msg.value == ticketPrice);
      assert(! checkPlayerExist(msg.sender));
      players.push(msg.sender);
      for(uint i = 0; i < numberCount; i++){
        ticketOfPlayers[msg.sender].push(numberSelected[i]);
      }
    //   totalPlayer++;
    //   gameInfo(totalEth);
      if(players.length >= maxPlayer) generateWinNumber();
   }
   
   // ok
   function generateWinNumber() public {
        blockHashPrevious = block.blockhash(block.number - 1);
        bytes32 random = keccak256(blockHashPrevious);
        uint i = 0;
        for(i = 0; i < maxNumber; i++){
            allNumber.push(i + 1);
        }
        uint n = 0;
        uint randomIndex;
        for(i = 0; i < numberCount; i++){
            n = maxNumber - i;
            randomIndex = (uint(random[i*4]) + uint(random[i*4 + 1]) + uint(random[i*4 + 2]) + uint(random[i*4 + 3]))%n;
            winNumber.push(allNumber[randomIndex]);
            allNumber[randomIndex] = allNumber[n - 1];
        }
      distributePrizes();
   }
   
   function resetData() public {
       winNumber.length = 0;
       allNumber.length = 0;
       players.length = 0;
       winners.length = 0;
   }
   
   function distributePrizes() public {
     uint i = 0;
     uint playersLength = players.length;
     if(playersLength > 0){
         for(i = 0; i < playersLength; i++){
           address playerAddress = players[i];
          if(checkWinNumber(ticketOfPlayers[playerAddress])) {
             winners.push(playerAddress);
          }
         }
     }

     uint winnersLength = winners.length;
     if(winnersLength > 0){
         winnerEtherAmount = this.balance / winners.length;
         for(i = 0; i < winnersLength; i++){
          winners[i].send(winnerEtherAmount);
         }
     }
     resetData();
   }
   
   function checkWinNumber(uint[] _numberSelected) public returns (bool) {
     for(uint i = 0; i < numberCount; i++){
       if(winNumber[i] != _numberSelected[i]) {
         return false;
       }
     }
     return true;
   }
   
   function getWinnerEtherAmount() public constant returns (uint) {
       return winnerEtherAmount;
   }
   
   function getBalance() public constant returns (uint) {
       return this.balance;
   }
   
   function getPlayers() public constant returns (address[]) {
       return players;
   }
   
   function getTicketOfPlayer(address playerAdress) public constant returns(uint[]) {
       return ticketOfPlayers[playerAdress];
   }
   
   function getTotalPlayer() public constant returns (uint) {
       return players.length;
   }
   
   function getWinNumber() public constant returns (uint[]) {
       return winNumber;
   }
   
   function getWinner() public constant returns(address[]) {
       return winners;
   }
   
   function getBlockHashPrevious() public returns (bytes32) {
       return blockHashPrevious;
   }
}
