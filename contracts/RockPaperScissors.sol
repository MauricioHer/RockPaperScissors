pragma solidity^0.4.19;

contract RockPaperScissors{
    
    enum answer {Vacio, Piedra, Papel, Tijeras}
    struct data{
        address player1;
        address player2;
        bytes32 secret_mov1;
        answer mov2;
        bool gameStatus;
        string whoWon;
    }
    
    mapping(bytes32 => data) public playersInfo;
    mapping(address => uint) public balances;
    uint public amountToBet;
    address public owner;
    uint public PlayerOneMovements=1;
    uint public PlayerTwoMovements=1;
    
    modifier onlyA(){			
        require(owner==msg.sender);		//Solo Alice puede interactuar.
        _;
    }
    event retirado(address to, uint amount);
    
    function RockPaperScissors() payable public{
        owner=msg.sender;
    }
    
    function startGame(bytes32 secret, answer _mov1, address player2, bytes32 onlyAlice, uint amount) public payable{
        balances[msg.sender]+=msg.value;
        require(owner==msg.sender);
        require(answer.Vacio != _mov1);
        require(player2!=0x0);
        require(player2!=msg.sender);
        require(PlayerOneMovements>0);
        require(amount==balances[msg.sender]);
        require(playersInfo[secret].gameStatus==false);
        amountToBet=amount;
        PlayerOneMovements=0;
        playersInfo[secret].player1=msg.sender;
        playersInfo[secret].secret_mov1=keccak256(onlyAlice,_mov1);
        playersInfo[secret].player2=player2;
        playersInfo[secret].gameStatus=true;
    }
    
    function answerPlayer2(bytes32 secret, answer _mov2) public payable{
        balances[msg.sender]+=msg.value;
        require(amountToBet==balances[msg.sender]);
        require(playersInfo[secret].player2==msg.sender);
        require(playersInfo[secret].gameStatus==true);
        require(answer.Vacio != _mov2);
        require(PlayerTwoMovements>0);
        PlayerTwoMovements=0;
        playersInfo[secret].mov2=_mov2;
    }
    
    function getTheResult(bytes32 secret, bytes32 onlyAlice)public returns(string){
        require(playersInfo[secret].gameStatus==true);
        require(playersInfo[secret].secret_mov1!=0x0);
        require(playersInfo[secret].mov2!=answer.Vacio);
        
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Piedra)
        && playersInfo[secret].mov2==answer.Piedra){
            playersInfo[secret].whoWon="Empate";
            playersInfo[secret].gameStatus=false;
        }
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Papel)
        && playersInfo[secret].mov2==answer.Papel){
            playersInfo[secret].whoWon="Empate";
            playersInfo[secret].gameStatus=false;
        }
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Tijeras)
        && playersInfo[secret].mov2==answer.Tijeras){
            playersInfo[secret].whoWon="Empate";
            playersInfo[secret].gameStatus=false;
        }
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Piedra)
        && playersInfo[secret].mov2==answer.Papel){
            playersInfo[secret].whoWon="BobGana";
            balances[playersInfo[secret].player2]+=amountToBet;
            balances[playersInfo[secret].player1]-=amountToBet;
            playersInfo[secret].gameStatus=false;
        }
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Papel)
        && playersInfo[secret].mov2==answer.Tijeras){
            playersInfo[secret].whoWon="BobGana";
            balances[playersInfo[secret].player2]+=amountToBet;
            balances[playersInfo[secret].player1]-=amountToBet;
            playersInfo[secret].gameStatus=false;
        }
        
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Piedra)
        && playersInfo[secret].mov2==answer.Tijeras){
            playersInfo[secret].whoWon="AliceGana";
            balances[playersInfo[secret].player1]+=amountToBet;
            balances[playersInfo[secret].player2]-=amountToBet;
            playersInfo[secret].gameStatus=false;
        }
        
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Tijeras)
        && playersInfo[secret].mov2==answer.Papel){
            playersInfo[secret].whoWon="AliceGana";
            balances[playersInfo[secret].player1]+=amountToBet;
            balances[playersInfo[secret].player2]-=amountToBet;
            playersInfo[secret].gameStatus=false;
        }
        
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Papel)
        && playersInfo[secret].mov2==answer.Piedra){
            playersInfo[secret].whoWon="AliceGana";
            balances[playersInfo[secret].player1]+=amountToBet;
            balances[playersInfo[secret].player2]-=amountToBet;
            playersInfo[secret].gameStatus=false;
        }
        
        if(playersInfo[secret].secret_mov1==keccak256(onlyAlice,answer.Tijeras)
        && playersInfo[secret].mov2==answer.Piedra){
            playersInfo[secret].whoWon="BobGana";
            balances[playersInfo[secret].player2]+=amountToBet;
            balances[playersInfo[secret].player1]-=amountToBet;
            playersInfo[secret].gameStatus=false;
        }
        return(playersInfo[secret].whoWon);
    }
    
    function ResetGame(bytes32 secret) public{
        require(playersInfo[secret].gameStatus==false);
        require(msg.sender==playersInfo[secret].player1 || msg.sender == playersInfo[secret].player2);
        PlayerOneMovements=1;
        PlayerTwoMovements=1;
        amountToBet=0;
        playersInfo[secret].player2=0x0;
        playersInfo[secret].secret_mov1=0x0;
        playersInfo[secret].mov2=answer.Vacio;
        playersInfo[secret].whoWon="";
        
    }
    
    function withDraw(uint amount)public payable{
        require(balances[msg.sender]>0);
        balances[msg.sender]-=amount;
        msg.sender.transfer(amount);
        retirado(msg.sender,amount);
    }
    
    function contractBalance() public view returns(uint){
        return address(this).balance;
    }
    
    function emergency()public onlyA{  //en caso de emergencia, devuelve los fondos y destruye el contrato.
        selfdestruct(owner);
    }
}