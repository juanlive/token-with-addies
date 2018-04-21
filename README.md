# token-with-addies
Token with choosable addresses: transfer("Robert","Alice",20000);


assignAddy(string)

Assign any addy to the sender ethereum address. 
If the addy is already assigned, tx will fail.
If assinment is successfull, an event will be created:
AssignedAddy(_addy, msg.sender);


checkAddy(string)

A getter to retrieve which ethereum address is associated with an addy


Classic ERC20 functions now refers to addys instead of addresses.

balanceOf(string)

Retrieves the balance of an addy


transfer(string _from,string _to, uint _value)

It requires the sender to be the owner of the originating addy.


secureTransfer(string _from,string _to,address _addTo,uint _value)

It verifies that the recipient ethereum address (_addTo) is the owner of the recipient addy. It will fail if it is not.
If the recipient addy does not exist, it creates it and assign it to the recipient ethereum address, and creates an event.


Event Transfer also referes to addys instead addresses. 

Aproval allows to approve an addy to be used by an ethereum address.
approve(string _addy , address _spender, uint _value)


